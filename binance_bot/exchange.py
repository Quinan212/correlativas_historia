"""
Direct Binance Futures HTTP client for market data and trading.

This avoids ccxt sandbox routing issues and talks to the official Futures
endpoints directly.
"""

import hashlib
import hmac
import json
import time
from dataclasses import dataclass
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from loguru import logger

import config


@dataclass
class FuturesExchange:
    base_url: str
    api_key: str
    secret_key: str

    def close(self):
        """Compatibility no-op."""
        return None


def _base_url() -> str:
    return "https://demo-fapi.binance.com" if config.BINANCE_TESTNET else "https://fapi.binance.com"


def create_exchange() -> FuturesExchange:
    """
    Create a lightweight exchange handle.
    """
    logger.info(
        f"Conectado a Binance Futures {'TESTNET/DEMO' if config.BINANCE_TESTNET else 'REAL'}"
    )
    return FuturesExchange(
        base_url=_base_url(),
        api_key=config.BINANCE_API_KEY,
        secret_key=config.BINANCE_SECRET_KEY,
    )


def _public_get(exchange: FuturesExchange, path: str, params: dict | None = None):
    query = f"?{urlencode(params)}" if params else ""
    url = f"{exchange.base_url}{path}{query}"
    with urlopen(url, timeout=10) as response:
        return json.loads(response.read().decode("utf-8"))


def get_book_ticker(exchange: FuturesExchange, symbol: str = None) -> dict | None:
    """Best bid/ask for a symbol."""
    try:
        sym = symbol or config.SYMBOL
        data = _public_get(exchange, "/fapi/v1/ticker/bookTicker", {"symbol": sym})
        return {
            "bid_price": float(data.get("bidPrice", 0.0)),
            "ask_price": float(data.get("askPrice", 0.0)),
            "raw": data,
        }
    except Exception as e:
        logger.error(f"Error obteniendo book ticker: {e}")
        return None


def get_open_orders(exchange: FuturesExchange, symbol: str = None) -> list[dict]:
    """Return current open orders for a symbol."""
    try:
        sym = symbol or config.SYMBOL
        orders = _signed_request(exchange, "GET", "/fapi/v1/openOrders", {"symbol": sym})
        return orders if isinstance(orders, list) else []
    except Exception as e:
        logger.error(f"Error obteniendo open orders: {e}")
        return []


def _signed_request(
    exchange: FuturesExchange,
    method: str,
    path: str,
    params: dict | None = None,
):
    payload = dict(params or {})
    payload["timestamp"] = int(time.time() * 1000)
    query = urlencode(payload)
    signature = hmac.new(
        exchange.secret_key.encode("utf-8"),
        query.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()
    url = f"{exchange.base_url}{path}?{query}&signature={signature}"
    headers = {"X-MBX-APIKEY": exchange.api_key}
    request = Request(url, headers=headers, method=method)
    with urlopen(request, timeout=10) as response:
        return json.loads(response.read().decode("utf-8"))


def get_futures_commission_rate(symbol: str = None, exchange: FuturesExchange | None = None) -> dict | None:
    """
    Fetch live USD-M Futures commission for the configured account.
    """
    sym = symbol or config.SYMBOL
    exchange = exchange or create_exchange()
    try:
        payload = _signed_request(exchange, "GET", "/fapi/v1/commissionRate", {"symbol": sym})
        maker = payload.get("makerCommissionRate")
        taker = payload.get("takerCommissionRate")
        if maker is None or taker is None:
            logger.warning(f"Binance commission response incomplete: {payload}")
            return None
        maker_pct = float(maker) * 100.0
        taker_pct = float(taker) * 100.0
        logger.info(
            f"Comision real Binance {sym}: maker {maker_pct:.4f}% | taker {taker_pct:.4f}%"
        )
        return {"symbol": sym, "maker_pct": maker_pct, "taker_pct": taker_pct, "raw": payload}
    except Exception as e:
        logger.warning(f"No se pudo obtener la comision real de Binance para {sym}: {e}")
        return None


def get_balance(exchange: FuturesExchange) -> dict:
    """Return USDT futures balance."""
    try:
        balances = _signed_request(exchange, "GET", "/fapi/v2/balance")
        usdt = next((b for b in balances if b.get("asset") == "USDT"), None)
        if not usdt:
            return {"free": 0.0, "used": 0.0, "total": 0.0}
        total = float(usdt.get("balance", 0.0))
        available = float(usdt.get("availableBalance", 0.0))
        used = max(total - available, 0.0)
        return {"free": available, "used": used, "total": total}
    except Exception as e:
        logger.error(f"Error obteniendo balance: {e}")
        return {"free": 0.0, "used": 0.0, "total": 0.0}


def get_current_price(exchange: FuturesExchange, symbol: str = None) -> float | None:
    """Public ticker price."""
    try:
        sym = symbol or config.SYMBOL
        data = _public_get(exchange, "/fapi/v1/ticker/price", {"symbol": sym})
        return float(data.get("price"))
    except Exception as e:
        logger.error(f"Error obteniendo precio de {symbol or config.SYMBOL}: {e}")
        return None


def _round_price(price: float, precision: int) -> float:
    return round(price, max(0, precision))


def _round_qty(quantity: float, precision: int) -> float:
    return round(quantity, max(0, precision))


def _symbol_precision(exchange: FuturesExchange, symbol: str = None) -> tuple[int, int]:
    try:
        sym = symbol or config.SYMBOL
        info = _public_get(exchange, "/fapi/v1/exchangeInfo")
        for item in info.get("symbols", []):
            if item.get("symbol") == sym:
                return int(item.get("pricePrecision", 2)), int(item.get("quantityPrecision", 3))
    except Exception as e:
        logger.warning(f"No se pudo leer precision de {symbol or config.SYMBOL}: {e}")
    return 2, 3


def get_candles(exchange: FuturesExchange, symbol: str = None, timeframe: str = None, limit: int = 50):
    """Public OHLCV candles."""
    try:
        sym = symbol or config.SYMBOL
        tf = timeframe or config.TIMEFRAME
        raw = _public_get(exchange, "/fapi/v1/klines", {"symbol": sym, "interval": tf, "limit": limit})
        candles = []
        for row in raw:
            candles.append(
                [
                    int(row[0]),
                    float(row[1]),
                    float(row[2]),
                    float(row[3]),
                    float(row[4]),
                    float(row[5]),
                ]
            )
        return candles
    except Exception as e:
        logger.error(f"Error obteniendo velas: {e}")
        return []


def set_leverage(exchange: FuturesExchange, symbol: str = None, leverage: int = None):
    """Set leverage via signed request."""
    try:
        sym = symbol or config.SYMBOL
        lev = leverage or config.LEVERAGE
        _signed_request(exchange, "POST", "/fapi/v1/leverage", {"symbol": sym, "leverage": lev})
        logger.info(f"Apalancamiento {lev}x seteado para {sym}")
    except Exception as e:
        logger.error(f"Error seteando leverage: {e}")


def open_long(
    exchange: FuturesExchange,
    usdt_amount: float,
    symbol: str = None,
    leverage: int = None,
    stop_loss_pct: float = None,
    take_profit_pct: float = None,
) -> dict | None:
    """Open a market long position."""
    try:
        sym = symbol or config.SYMBOL
        lev = leverage or config.LEVERAGE
        price = get_current_price(exchange, sym)
        if not price:
            return None

        notional = usdt_amount * lev
        price_precision, quantity_precision = _symbol_precision(exchange, sym)
        quantity = notional / price
        quantity = _round_qty(quantity, quantity_precision)
        if quantity <= 0:
            logger.warning("Cantidad calculada es 0 o menor.")
            return None

        if config.ENTRY_ORDER_TYPE.lower() == "maker":
            book = get_book_ticker(exchange, sym)
            entry_price = book["bid_price"] if book else price
            entry_price = entry_price * (1.0 - config.MAKER_ENTRY_OFFSET_PCT / 100.0)
            entry_price = _round_price(entry_price, price_precision)
            order = _signed_request(
                exchange,
                "POST",
                "/fapi/v1/order",
                {
                    "symbol": sym,
                    "side": "BUY",
                    "type": "LIMIT",
                    "timeInForce": "GTX",
                    "price": entry_price,
                    "quantity": quantity,
                },
            )
            logger.success(
                f"LONG maker enviada: {quantity} {sym} @ ${entry_price:.{price_precision}f} | Margen: ${usdt_amount:.2f}"
            )
            return {
                "order": order,
                "quantity": quantity,
                "entry_price": entry_price,
                "margin": usdt_amount,
                "leverage": lev,
                "order_type": "maker",
            }

        order = _signed_request(
            exchange,
            "POST",
            "/fapi/v1/order",
            {"symbol": sym, "side": "BUY", "type": "MARKET", "quantity": quantity},
        )
        logger.success(f"LONG abierta: {quantity} {sym} @ ~${price:.2f} | Margen: ${usdt_amount:.2f}")
        return {"order": order, "quantity": quantity, "entry_price": price, "margin": usdt_amount, "leverage": lev, "order_type": "market"}
    except Exception as e:
        logger.error(f"Error abriendo LONG: {e}")
        return None


def open_short(
    exchange: FuturesExchange,
    usdt_amount: float,
    symbol: str = None,
    leverage: int = None,
    stop_loss_pct: float = None,
    take_profit_pct: float = None,
) -> dict | None:
    """Open a market short position."""
    try:
        sym = symbol or config.SYMBOL
        lev = leverage or config.LEVERAGE
        price = get_current_price(exchange, sym)
        if not price:
            return None

        notional = usdt_amount * lev
        price_precision, quantity_precision = _symbol_precision(exchange, sym)
        quantity = notional / price
        quantity = _round_qty(quantity, quantity_precision)
        if quantity <= 0:
            logger.warning("Cantidad calculada es 0 o menor.")
            return None

        if config.ENTRY_ORDER_TYPE.lower() == "maker":
            book = get_book_ticker(exchange, sym)
            entry_price = book["ask_price"] if book else price
            entry_price = entry_price * (1.0 + config.MAKER_ENTRY_OFFSET_PCT / 100.0)
            entry_price = _round_price(entry_price, price_precision)
            order = _signed_request(
                exchange,
                "POST",
                "/fapi/v1/order",
                {
                    "symbol": sym,
                    "side": "SELL",
                    "type": "LIMIT",
                    "timeInForce": "GTX",
                    "price": entry_price,
                    "quantity": quantity,
                },
            )
            logger.success(
                f"SHORT maker enviada: {quantity} {sym} @ ${entry_price:.{price_precision}f} | Margen: ${usdt_amount:.2f}"
            )
            return {
                "order": order,
                "quantity": quantity,
                "entry_price": entry_price,
                "margin": usdt_amount,
                "leverage": lev,
                "order_type": "maker",
            }

        order = _signed_request(
            exchange,
            "POST",
            "/fapi/v1/order",
            {"symbol": sym, "side": "SELL", "type": "MARKET", "quantity": quantity},
        )
        logger.success(f"SHORT abierta: {quantity} {sym} @ ~${price:.2f} | Margen: ${usdt_amount:.2f}")
        return {"order": order, "quantity": quantity, "entry_price": price, "margin": usdt_amount, "leverage": lev, "order_type": "market"}
    except Exception as e:
        logger.error(f"Error abriendo SHORT: {e}")
        return None


def get_open_position(exchange: FuturesExchange, symbol: str = None) -> dict | None:
    """Return an open futures position if it exists."""
    try:
        sym = symbol or config.SYMBOL
        positions = _signed_request(exchange, "GET", "/fapi/v2/positionRisk", {"symbol": sym})
        for pos in positions:
            amount = float(pos.get("positionAmt", 0.0))
            if amount != 0.0:
                side = "long" if amount > 0 else "short"
                entry_price = float(pos.get("entryPrice", 0.0))
                unrealized = float(pos.get("unRealizedProfit", 0.0))
                leverage = float(pos.get("leverage", config.LEVERAGE))
                margin = abs(amount) * entry_price / max(leverage, 1.0)
                pnl_pct = 0.0 if margin <= 0 else (unrealized / margin) * 100.0
                return {
                    "side": side,
                    "contracts": abs(amount),
                    "entry_price": entry_price,
                    "unrealized_pnl": unrealized,
                    "pnl_pct": pnl_pct,
                    "leverage": leverage,
                    "margin": margin,
                }
        return None
    except Exception as e:
        logger.error(f"Error obteniendo posicion: {e}")
        return None


def close_position(exchange: FuturesExchange, symbol: str = None) -> dict | None:
    """Close any open position at market."""
    try:
        sym = symbol or config.SYMBOL
        pos = get_open_position(exchange, sym)
        if not pos:
            logger.info("No hay posicion abierta para cerrar.")
            return None

        contracts = abs(float(pos["contracts"]))
        if pos["side"] == "long":
            order = _signed_request(
                exchange,
                "POST",
                "/fapi/v1/order",
                {"symbol": sym, "side": "SELL", "type": "MARKET", "quantity": contracts, "reduceOnly": "true"},
            )
        else:
            order = _signed_request(
                exchange,
                "POST",
                "/fapi/v1/order",
                {"symbol": sym, "side": "BUY", "type": "MARKET", "quantity": contracts, "reduceOnly": "true"},
            )
        logger.success(f"Posicion cerrada: {contracts} {sym}")
        return order
    except Exception as e:
        logger.error(f"Error cerrando posicion: {e}")
        return None
