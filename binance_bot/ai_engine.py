"""
AI decision engine for LONG / SHORT / HOLD trading signals.

Supported providers:
- rules: local strategy, no external key required
- openai: OpenAI chat completions
- anthropic: Anthropic Claude
"""

import json
import math
from dataclasses import dataclass
from typing import Literal

from loguru import logger

import config


Decision = Literal["LONG", "SHORT", "HOLD", "CLOSE"]


@dataclass
class AIDecision:
    """Structured trading decision."""

    action: Decision
    confidence: float
    expected_pnl_pct: float  # Expected price move before leverage
    reasoning: str
    stop_loss_pct: float
    take_profit_pct: float


def _ema(values: list[float], period: int) -> float | None:
    if len(values) < period:
        return None
    k = 2 / (period + 1)
    ema = sum(values[:period]) / period
    for value in values[period:]:
        ema = value * k + ema * (1 - k)
    return ema


def _rsi(values: list[float], period: int = 14) -> float | None:
    if len(values) < period + 1:
        return None
    gains = 0.0
    losses = 0.0
    for i in range(-period, 0):
        change = values[i] - values[i - 1]
        if change >= 0:
            gains += change
        else:
            losses += abs(change)
    if losses == 0:
        return 100.0
    rs = gains / losses
    return 100.0 - (100.0 / (1.0 + rs))


def _atr(candles: list, period: int = 14) -> float | None:
    if len(candles) < period + 1:
        return None
    trs = []
    for i in range(-period, 0):
        _, _, high, low, close = candles[i][:5]
        prev_close = candles[i - 1][4]
        tr = max(high - low, abs(high - prev_close), abs(low - prev_close))
        trs.append(tr)
    return sum(trs) / len(trs)


def _sma(values: list[float], period: int) -> float | None:
    if len(values) < period:
        return None
    return sum(values[-period:]) / period


def _price_momentum_pct(closes: list[float], lookback: int = 5) -> float | None:
    if len(closes) <= lookback:
        return None
    past = closes[-lookback - 1]
    if past <= 0:
        return None
    return ((closes[-1] / past) - 1.0) * 100.0


def _ema_slope_pct(values: list[float], period: int, lookback: int = 3) -> float | None:
    if len(values) < period + lookback:
        return None
    current = _ema(values, period)
    previous = _ema(values[:-lookback], period)
    if current is None or previous is None or current <= 0:
        return None
    return ((current - previous) / current) * 100.0


def _volume_ratio(candles: list, period: int = 20) -> float | None:
    if len(candles) < period + 1:
        return None
    volumes = [float(c[5]) for c in candles]
    avg_volume = _sma(volumes[:-1], period)
    if avg_volume is None or avg_volume <= 0:
        return None
    return volumes[-1] / avg_volume


def _build_market_context(
    candles: list,
    current_price: float,
    open_position: dict | None,
    balance: dict,
) -> str:
    """Build prompt context for external providers."""
    ohlcv_summary = ""
    for i, c in enumerate(candles[-20:]):
        ts, o, h, l, cl, vol = c
        ohlcv_summary += (
            f"  Candle {i+1}: O={o:.2f} H={h:.2f} L={l:.2f} C={cl:.2f} V={vol:.0f}\n"
        )

    position_str = "None"
    if open_position:
        pnl = open_position.get("unrealized_pnl", 0)
        pnl_pct = open_position.get("pnl_pct", 0)
        position_str = (
            f"{open_position['side'].upper()} | "
            f"Entry: ${open_position['entry_price']:.2f} | "
            f"PnL: ${pnl:.4f} ({pnl_pct:.2f}%)"
        )

    context = f"""MARKET DATA - {config.SYMBOL} | {config.TIMEFRAME}
Current price: ${current_price:.2f}
USDT balance: ${balance.get('free', 0):.2f} free | ${balance.get('total', 0):.2f} total
Leverage: {config.LEVERAGE}x
Open position: {position_str}

LAST 20 CANDLES ({config.TIMEFRAME}):
{ohlcv_summary}

FEES: Taker {config.TAKER_FEE_PCT}% | Maker {config.MAKER_FEE_PCT}%
Min profit recommended after fees: {config.MIN_PROFIT_PCT}%
IMPORTANT: expected_pnl_pct is the expected PRICE MOVE before leverage, not the return on margin.
If there is an open position, you may answer CLOSE when the trade is exhausted, loses trend support, or momentum/volume weakens.
"""
    return context


def _rule_based_decision(
    candles: list,
    current_price: float,
    open_position: dict | None,
) -> AIDecision:
    closes = [float(c[4]) for c in candles]
    if len(closes) < 20:
        return AIDecision(
            action="HOLD",
            confidence=0.0,
            expected_pnl_pct=0.0,
            reasoning="Not enough candle history.",
            stop_loss_pct=0.0,
            take_profit_pct=0.0,
        )

    ema20 = _ema(closes, 20)
    ema50 = _ema(closes, 50) if len(closes) >= 50 else _ema(closes, min(len(closes), 30))
    rsi14 = _rsi(closes, 14)
    atr14 = _atr(candles, 14)
    atr_pct = (atr14 / current_price) * 100.0
    volume_ratio = _volume_ratio(candles, 20)
    momentum_pct = _price_momentum_pct(closes, 5)
    ema20_slope = _ema_slope_pct(closes, 20, 3)
    ema50_slope = _ema_slope_pct(closes, 50, 3) if len(closes) >= 50 else None

    if ema20 is None or rsi14 is None or atr14 is None:
        return AIDecision(
            action="HOLD",
            confidence=0.0,
            expected_pnl_pct=0.0,
            reasoning="Indicators not ready yet.",
            stop_loss_pct=0.0,
            take_profit_pct=0.0,
        )

    trend_up = ema50 is None or ema20 > ema50
    trend_down = ema50 is not None and ema20 < ema50
    price_above_ema = current_price > ema20
    price_below_ema = current_price < ema20
    volume_ratio = volume_ratio or 1.0
    momentum_pct = momentum_pct or 0.0
    ema20_slope = ema20_slope or 0.0
    ema50_slope = ema50_slope or 0.0
    trend_strength = abs(ema20 - (ema50 or ema20)) / current_price * 100.0

    stop_loss_pct = max(1.0, min(3.0, atr_pct * 1.6))
    take_profit_pct = max(stop_loss_pct * 2.2, 2.5)

    if open_position:
        side = open_position.get("side", "")
        if side == "long":
            should_close = (
                (trend_down and price_below_ema)
                or (rsi14 >= 72 and momentum_pct <= 0.0)
                or (price_below_ema and momentum_pct < -0.15)
                or (trend_strength < 0.08 and volume_ratio < 0.9)
                or (ema20_slope < -0.04 and ema50_slope <= 0.0)
            )
            if should_close:
                return AIDecision(
                    action="CLOSE",
                    confidence=0.76,
                    expected_pnl_pct=0.0,
                    reasoning=(
                        f"Close long: trend/volume weakened. RSI {rsi14:.1f}, "
                        f"momentum {momentum_pct:.2f}%, volume x{volume_ratio:.2f}."
                    ),
                    stop_loss_pct=0.0,
                    take_profit_pct=0.0,
                )
            if trend_up and price_above_ema and rsi14 >= 45 and volume_ratio >= 0.8:
                return AIDecision(
                    action="HOLD",
                    confidence=0.62,
                    expected_pnl_pct=0.6,
                    reasoning=(
                        f"Keep long: trend still healthy. RSI {rsi14:.1f}, "
                        f"momentum {momentum_pct:.2f}%, volume x{volume_ratio:.2f}."
                    ),
                    stop_loss_pct=stop_loss_pct,
                    take_profit_pct=take_profit_pct,
                )
        if side == "short":
            should_close = (
                (trend_up and price_above_ema)
                or (rsi14 <= 28 and momentum_pct >= 0.0)
                or (price_above_ema and momentum_pct > 0.15)
                or (trend_strength < 0.08 and volume_ratio < 0.9)
                or (ema20_slope > 0.04 and ema50_slope >= 0.0)
            )
            if should_close:
                return AIDecision(
                    action="CLOSE",
                    confidence=0.76,
                    expected_pnl_pct=0.0,
                    reasoning=(
                        f"Close short: trend/volume weakened. RSI {rsi14:.1f}, "
                        f"momentum {momentum_pct:.2f}%, volume x{volume_ratio:.2f}."
                    ),
                    stop_loss_pct=0.0,
                    take_profit_pct=0.0,
                )
            if trend_down and price_below_ema and rsi14 <= 55 and volume_ratio >= 0.8:
                return AIDecision(
                    action="HOLD",
                    confidence=0.62,
                    expected_pnl_pct=0.6,
                    reasoning=(
                        f"Keep short: trend still healthy. RSI {rsi14:.1f}, "
                        f"momentum {momentum_pct:.2f}%, volume x{volume_ratio:.2f}."
                    ),
                    stop_loss_pct=stop_loss_pct,
                    take_profit_pct=take_profit_pct,
                )

    long_signal = trend_up and price_above_ema and rsi14 <= 42 and volume_ratio >= 0.9
    short_signal = trend_down and price_below_ema and rsi14 >= 58 and volume_ratio >= 0.9

    if long_signal:
        momentum = max(0.0, 50.0 - rsi14) / 20.0
        volume_bonus = max(0.0, volume_ratio - 1.0) * 0.35
        expected_move = min(4.5, max(0.8, atr_pct * 1.2 + momentum + volume_bonus))
        confidence = min(
            0.94,
            0.54 + (50.0 - rsi14) / 80.0 + min(0.2, atr_pct / 10.0) + min(0.1, volume_bonus),
        )
        reasoning = (
            f"Uptrend confirmation with EMA20 above EMA50, price above EMA20, RSI {rsi14:.1f}, "
            f"volume x{volume_ratio:.2f}."
        )
        return AIDecision(
            action="LONG",
            confidence=round(confidence, 2),
            expected_pnl_pct=round(expected_move, 2),
            reasoning=reasoning,
            stop_loss_pct=round(stop_loss_pct, 2),
            take_profit_pct=round(take_profit_pct, 2),
        )

    if short_signal:
        momentum = max(0.0, rsi14 - 50.0) / 20.0
        volume_bonus = max(0.0, volume_ratio - 1.0) * 0.35
        expected_move = min(4.5, max(0.8, atr_pct * 1.2 + momentum + volume_bonus))
        confidence = min(
            0.94,
            0.54 + (rsi14 - 50.0) / 80.0 + min(0.2, atr_pct / 10.0) + min(0.1, volume_bonus),
        )
        reasoning = (
            f"Downtrend confirmation with EMA20 below EMA50, price below EMA20, RSI {rsi14:.1f}, "
            f"volume x{volume_ratio:.2f}."
        )
        return AIDecision(
            action="SHORT",
            confidence=round(confidence, 2),
            expected_pnl_pct=round(expected_move, 2),
            reasoning=reasoning,
            stop_loss_pct=round(stop_loss_pct, 2),
            take_profit_pct=round(take_profit_pct, 2),
        )

    if rsi14 < 30 and trend_up:
        expected_move = min(3.0, max(0.6, atr_pct))
        return AIDecision(
            action="LONG",
            confidence=0.6,
            expected_pnl_pct=round(expected_move, 2),
            reasoning=f"Mean reversion long setup with RSI {rsi14:.1f} in an uptrend.",
            stop_loss_pct=round(stop_loss_pct, 2),
            take_profit_pct=round(take_profit_pct, 2),
        )

    if rsi14 > 70 and trend_down:
        expected_move = min(3.0, max(0.6, atr_pct))
        return AIDecision(
            action="SHORT",
            confidence=0.6,
            expected_pnl_pct=round(expected_move, 2),
            reasoning=f"Mean reversion short setup with RSI {rsi14:.1f} in a downtrend.",
            stop_loss_pct=round(stop_loss_pct, 2),
            take_profit_pct=round(take_profit_pct, 2),
        )

    return AIDecision(
        action="HOLD",
        confidence=0.42,
        expected_pnl_pct=0.0,
        reasoning=(
            f"No clear edge. RSI {rsi14:.1f}, trend is mixed, "
            f"momentum {momentum_pct:.2f}%, volume x{volume_ratio:.2f}."
        ),
        stop_loss_pct=0.0,
        take_profit_pct=0.0,
    )


def _call_openai(prompt: str) -> AIDecision:
    """Ask OpenAI for a trading decision."""
    from openai import OpenAI

    client = OpenAI(api_key=config.OPENAI_API_KEY)
    system_prompt = """You are a professional crypto trader on Binance Futures.
You analyze market data and decide LONG, SHORT, or HOLD.

MANDATORY RULES:
1. If the expected gain does not cover fees, do not trade -> HOLD.
2. Always propose stop loss and take profit with risk/reward >= 2:1.
3. Confidence should be low (<0.6) when the signal is not clear.
4. If there is already an open position, decide whether to keep it or close it.
5. With x5 or x10 leverage, moves are amplified. Be conservative.
6. expected_pnl_pct must be the expected PRICE MOVE before leverage, not the return on margin.

Respond ONLY with valid JSON, no extra text:
{
  "action": "LONG" | "SHORT" | "HOLD" | "CLOSE",
  "confidence": 0.0-1.0,
  "expected_pnl_pct": number,
  "reasoning": "brief explanation in Spanish",
  "stop_loss_pct": number,
  "take_profit_pct": number
}"""

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt},
            ],
            temperature=0.3,
            max_tokens=500,
        )
        content = response.choices[0].message.content.strip()
        if content.startswith("```"):
            content = content.split("\n", 1)[1]
            if content.endswith("```"):
                content = content[:-3]
        data = json.loads(content)
        return AIDecision(
            action=data["action"],
            confidence=float(data["confidence"]),
            expected_pnl_pct=float(data["expected_pnl_pct"]),
            reasoning=data.get("reasoning", ""),
            stop_loss_pct=float(data.get("stop_loss_pct", 2.0)),
            take_profit_pct=float(data.get("take_profit_pct", 4.0)),
        )
    except Exception as e:
        logger.error(f"Error calling OpenAI: {e}")
        return AIDecision("HOLD", 0.0, 0.0, f"Error: {str(e)[:100]}", 0.0, 0.0)


def _call_anthropic(prompt: str) -> AIDecision:
    """Ask Anthropic Claude for a trading decision."""
    from anthropic import Anthropic

    client = Anthropic(api_key=config.ANTHROPIC_API_KEY)
    system_prompt = """You are a professional crypto trader on Binance Futures.
You analyze market data and decide LONG, SHORT, or HOLD.

MANDATORY RULES:
1. If the expected gain does not cover fees, do not trade -> HOLD.
2. Always propose stop loss and take profit with risk/reward >= 2:1.
3. Confidence should be low (<0.6) when the signal is not clear.
4. If there is already an open position, decide whether to keep it or close it.
5. With x5 or x10 leverage, moves are amplified. Be conservative.
6. expected_pnl_pct must be the expected PRICE MOVE before leverage, not the return on margin.

Respond ONLY with valid JSON, no extra text:
{
  "action": "LONG" | "SHORT" | "HOLD" | "CLOSE",
  "confidence": 0.0-1.0,
  "expected_pnl_pct": number,
  "reasoning": "brief explanation in Spanish",
  "stop_loss_pct": number,
  "take_profit_pct": number
}"""

    try:
        response = client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=500,
            temperature=0.3,
            system=system_prompt,
            messages=[{"role": "user", "content": prompt}],
        )
        content = response.content[0].text.strip()
        if content.startswith("```"):
            content = content.split("\n", 1)[1]
            if content.endswith("```"):
                content = content[:-3]
        data = json.loads(content)
        return AIDecision(
            action=data["action"],
            confidence=float(data["confidence"]),
            expected_pnl_pct=float(data["expected_pnl_pct"]),
            reasoning=data.get("reasoning", ""),
            stop_loss_pct=float(data.get("stop_loss_pct", 2.0)),
            take_profit_pct=float(data.get("take_profit_pct", 4.0)),
        )
    except Exception as e:
        logger.error(f"Error calling Anthropic: {e}")
        return AIDecision("HOLD", 0.0, 0.0, f"Error: {str(e)[:100]}", 0.0, 0.0)


def get_ai_decision(
    candles: list,
    current_price: float,
    open_position: dict | None,
    balance: dict,
) -> AIDecision:
    """
    Get a trading decision from the configured AI provider.
    """
    if config.AI_PROVIDER == "rules":
        logger.info("AI: using local rules engine...")
        return _rule_based_decision(candles, current_price, open_position)

    prompt = _build_market_context(candles, current_price, open_position, balance)
    if config.AI_PROVIDER == "openai":
        logger.info("AI: consulting OpenAI GPT-4o...")
        return _call_openai(prompt)

    logger.info("AI: consulting Anthropic Claude...")
    return _call_anthropic(prompt)
