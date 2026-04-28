"""
Binance Futures trading bot entrypoint.
"""

import signal
import sys
import time
from datetime import datetime

from dotenv import load_dotenv
from loguru import logger

load_dotenv()

import config
from ai_engine import get_ai_decision
from exchange import (
    close_position,
    create_exchange,
    get_balance,
    get_candles,
    get_current_price,
    get_futures_commission_rate,
    get_open_position,
    get_open_orders,
    open_long,
    open_short,
    set_leverage,
)
from fee_calculator import get_fee_calculator
from risk_manager import RiskValidator, get_daily_tracker, record_trade_result


logger.remove()
logger.add(
    sys.stderr,
    format="{time:HH:mm:ss} | {level:<8} | {message}",
    level="INFO",
)
logger.add(
    "bot_trades.log",
    rotation="10 MB",
    retention="7 days",
    format="{time:YYYY-MM-DD HH:mm:ss} | {level:<8} | {message}",
    level="DEBUG",
)

_should_stop = False


def _handle_stop(signum, frame):
    global _should_stop
    logger.warning("Stop signal received. Shutting down cleanly...")
    _should_stop = True


signal.signal(signal.SIGINT, _handle_stop)
signal.signal(signal.SIGTERM, _handle_stop)


def _check_should_stop() -> bool:
    if _should_stop:
        return True
    tracker = get_daily_tracker()
    return tracker.stopped_out


def _get_run_minutes() -> int | None:
    if "--minutes" not in sys.argv:
        return config.RUN_MINUTES
    try:
        idx = sys.argv.index("--minutes")
        return int(sys.argv[idx + 1])
    except Exception:
        raise SystemExit("Usage: python main.py --minutes 30")


def _safe_close_exchange(exchange):
    close_fn = getattr(exchange, "close", None)
    if callable(close_fn):
        close_fn()


def _build_fee_calculator(exchange):
    commission = get_futures_commission_rate(config.SYMBOL, exchange)
    if commission:
        return get_fee_calculator(
            taker_fee_pct=commission["taker_pct"],
            maker_fee_pct=commission["maker_pct"],
        )
    return get_fee_calculator()


def trading_iteration(exchange, risk: RiskValidator, fc) -> dict:
    result = {
        "timestamp": datetime.now().isoformat(),
        "action_taken": "NONE",
        "reason": "",
        "balance_before": 0.0,
        "balance_after": 0.0,
    }

    try:
        balance = get_balance(exchange)
        current_price = get_current_price(exchange)
        candles = get_candles(exchange)
        open_pos = get_open_position(exchange)
        open_orders = get_open_orders(exchange)

        if not current_price:
            result["reason"] = "No se pudo obtener precio actual."
            result["balance_after"] = balance.get("total", 0)
            return result

        result["balance_before"] = balance.get("total", 0)
        logger.info(f"Balance: ${balance['total']:.2f} | Price {config.SYMBOL}: ${current_price:.2f}")

        if open_pos:
            logger.info(
                f"Open position: {open_pos['side']} | PnL {open_pos.get('pnl_pct', 0):.2f}% | "
                f"Entry ${open_pos.get('entry_price', 0):.2f}"
            )

            pnl_pct = float(open_pos.get("pnl_pct", 0.0))
            realized_pnl = float(open_pos.get("unrealized_pnl", 0.0))
            if pnl_pct >= config.AUTO_TAKE_PROFIT_PCT:
                logger.info(
                    f"Take profit alcanzado: {pnl_pct:.2f}% >= {config.AUTO_TAKE_PROFIT_PCT:.2f}%. Cerrando posicion..."
                )
                close_position(exchange)
                record_trade_result(realized_pnl)
                result["action_taken"] = f"CLOSE_{open_pos['side'].upper()}"
                result["reason"] = (
                    f"TP alcanzado en {pnl_pct:.2f}% (objetivo {config.AUTO_TAKE_PROFIT_PCT:.2f}%)."
                )
                result["balance_after"] = get_balance(exchange).get("total", 0)
                return result

            if pnl_pct <= -config.AUTO_STOP_LOSS_PCT:
                logger.info(
                    f"Stop loss alcanzado: {pnl_pct:.2f}% <= -{config.AUTO_STOP_LOSS_PCT:.2f}%. Cerrando posicion..."
                )
                close_position(exchange)
                record_trade_result(realized_pnl)
                result["action_taken"] = f"CLOSE_{open_pos['side'].upper()}"
                result["reason"] = (
                    f"SL alcanzado en {pnl_pct:.2f}% (limite {config.AUTO_STOP_LOSS_PCT:.2f}%)."
                )
                result["balance_after"] = get_balance(exchange).get("total", 0)
                return result

        if open_orders and not open_pos:
            logger.info(f"Hay {len(open_orders)} orden(es) pendiente(s) en Binance. Esperando fill...")
            result["reason"] = f"Orden maker pendiente ({len(open_orders)}). Sin nueva entrada."
            result["balance_after"] = balance.get("total", 0)
            return result

        decision = get_ai_decision(candles, current_price, open_pos, balance)
        logger.info(
            f"AI: {decision.action} | confidence {decision.confidence:.2f} | "
            f"expected move {decision.expected_pnl_pct}%"
        )
        logger.info(f"Reason: {decision.reasoning}")

        if decision.action == "HOLD":
            result["reason"] = f"IA decidio HOLD: {decision.reasoning}"
            result["balance_after"] = balance.get("total", 0)
            return result

        if decision.action == "CLOSE":
            if not open_pos:
                result["reason"] = "IA sugirio CLOSE pero no habia posicion abierta."
                result["balance_after"] = balance.get("total", 0)
                return result

            logger.info(f"AI requested CLOSE for {open_pos['side']} position")
            closed = close_position(exchange)
            if closed:
                record_trade_result(float(open_pos.get("unrealized_pnl", 0.0)))
                result["action_taken"] = f"CLOSE_{open_pos['side'].upper()}"
                result["reason"] = f"Posicion cerrada por senal AI: {decision.reasoning}"
            else:
                result["reason"] = "Error al cerrar la posicion por senal AI."
            result["balance_after"] = get_balance(exchange).get("total", 0)
            return result

        if open_pos:
            if open_pos["side"] == decision.action.lower():
                result["reason"] = f"Ya hay posicion {decision.action} abierta. Esperando cierre."
                result["balance_after"] = balance.get("total", 0)
                return result
            logger.info(f"Reversing: closing {open_pos['side']} to open {decision.action}")
            close_position(exchange)
            time.sleep(2)
            balance = get_balance(exchange)

        proposed_margin = risk.calculate_position_size(balance["total"], decision.stop_loss_pct)
        if proposed_margin <= 0:
            result["reason"] = "Margen propuesto es 0 o menor. No se opera."
            result["balance_after"] = balance.get("total", 0)
            return result

        viable, fee_msg, breakdown = fc.is_trade_viable(decision.expected_pnl_pct, proposed_margin)
        logger.info(
            f"Fees: ${breakdown.total_fee_usdt:.4f} | breakeven margin {breakdown.breakeven_pnl_pct}% | "
            f"breakeven move {breakdown.breakeven_price_move_pct}% | "
            f"min margin {breakdown.min_profit_pct}% | min move {breakdown.min_profit_price_move_pct}%"
        )
        logger.info(f"Fee check: {fee_msg}")
        if not viable:
            result["reason"] = fee_msg
            result["balance_after"] = balance.get("total", 0)
            return result

        risk_ok, risk_msg = risk.validate_decision(
            decision.expected_pnl_pct,
            decision.stop_loss_pct,
            decision.take_profit_pct,
            decision.confidence,
            balance["total"],
            proposed_margin,
        )
        logger.info(f"Risk: {risk_msg}")
        if not risk_ok:
            result["reason"] = risk_msg
            result["balance_after"] = balance.get("total", 0)
            return result

        logger.info(f"Executing {decision.action} with margin ${proposed_margin:.2f}...")
        trade = open_long(exchange, proposed_margin) if decision.action == "LONG" else open_short(exchange, proposed_margin)

        if trade:
            order_status = str(trade.get("order", {}).get("status", "")).upper()
            if order_status in ("NEW", "PARTIALLY_FILLED"):
                result["action_taken"] = f"PENDING_{decision.action}"
                result["reason"] = (
                    f"Orden maker enviada y pendiente ({order_status}). Movimiento esperado: {decision.expected_pnl_pct}% | "
                    f"SL: {decision.stop_loss_pct}% | TP: {decision.take_profit_pct}% | Fees: ${breakdown.total_fee_usdt:.4f}"
                )
            else:
                result["action_taken"] = decision.action
                result["reason"] = (
                    f"{decision.action} ejecutado. Movimiento esperado: {decision.expected_pnl_pct}% | "
                    f"SL: {decision.stop_loss_pct}% | TP: {decision.take_profit_pct}% | Fees: ${breakdown.total_fee_usdt:.4f}"
                )
                tracker = get_daily_tracker()
                if tracker.starting_balance == 0:
                    tracker.starting_balance = balance["total"]
        else:
            result["reason"] = f"Error al ejecutar {decision.action}."

        time.sleep(1)
        balance_after = get_balance(exchange)
        result["balance_after"] = balance_after.get("total", 0)

    except Exception as e:
        logger.exception(f"Error en iteracion: {e}")
        result["reason"] = f"Excepcion: {str(e)[:200]}"

    return result


def run_once():
    exchange = create_exchange()
    set_leverage(exchange)
    risk = RiskValidator()
    fc = _build_fee_calculator(exchange)
    result = trading_iteration(exchange, risk, fc)
    logger.info(f"Resultado: {result}")
    _safe_close_exchange(exchange)


def run_loop(max_minutes: int | None = None):
    exchange = create_exchange()
    set_leverage(exchange)
    risk = RiskValidator()
    fc = _build_fee_calculator(exchange)

    logger.info("=" * 50)
    logger.info(
        f"BOT INICIADO - {config.SYMBOL} | {config.LEVERAGE}x | {config.TIMEFRAME} | "
        f"{'TESTNET' if config.BINANCE_TESTNET else 'REAL'}"
    )
    logger.info(f"AI: {config.AI_PROVIDER} | Fee min profit: {config.MIN_PROFIT_PCT}%")
    logger.info(
        f"Max riesgo/dia: {config.MAX_DAILY_LOSS_PCT}% | "
        f"Max riesgo/trade: {config.MAX_RISK_PER_TRADE_PCT}%"
    )
    if max_minutes is not None:
        logger.info(f"Duracion fija: {max_minutes} minutos")
    logger.info("=" * 50)

    iteration = 0
    started_at = time.time()
    while not _check_should_stop():
        if max_minutes is not None and (time.time() - started_at) >= max_minutes * 60:
            logger.info(f"Duracion objetivo alcanzada ({max_minutes} minutos).")
            break

        iteration += 1
        logger.info("-" * 40)
        logger.info(f"Iteracion #{iteration} - {datetime.now().strftime('%H:%M:%S')}")
        logger.info("-" * 40)

        result = trading_iteration(exchange, risk, fc)
        status = "OK" if result["action_taken"] != "NONE" else "IDLE"
        logger.info(f"{status} Iteracion #{iteration}: {result['action_taken']} | {result['reason'][:100]}")

        if not _check_should_stop():
            time.sleep(config.LOOP_INTERVAL_SECONDS)

    logger.info("Cerrando posiciones abiertas si las hay...")
    try:
        close_position(exchange)
    except Exception:
        pass

    _safe_close_exchange(exchange)
    logger.info("Bot detenido.")


if __name__ == "__main__":
    if "--once" in sys.argv:
        logger.info("Modo: UNA SOLA ITERACION (debug)")
        run_once()
    else:
        logger.info("Modo: LOOP CONTINUO")
        run_loop(_get_run_minutes())
