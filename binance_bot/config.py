"""
Configuration loaded from .env.
"""

import os
from dotenv import load_dotenv

load_dotenv()


def _env(key: str, default=None):
    return os.getenv(key, default)


def _env_float(key: str, default: float) -> float:
    val = os.getenv(key)
    return float(val) if val is not None else default


def _env_bool(key: str, default: bool) -> bool:
    val = os.getenv(key)
    if val is None:
        return default
    return val.lower() in ("true", "1", "yes")


# Binance API
BINANCE_API_KEY = _env("BINANCE_API_KEY")
BINANCE_SECRET_KEY = _env("BINANCE_SECRET_KEY")
BINANCE_TESTNET = _env_bool("BINANCE_TESTNET", True)

# AI provider
AI_PROVIDER = _env("AI_PROVIDER", "rules")  # "rules" | "openai" | "anthropic"
OPENAI_API_KEY = _env("OPENAI_API_KEY")
ANTHROPIC_API_KEY = _env("ANTHROPIC_API_KEY")

# Trading
SYMBOL = _env("SYMBOL", "BTCUSDT")
LEVERAGE = int(_env("LEVERAGE", 5))
MAX_POSITION_PCT = _env_float("MAX_POSITION_PCT", 90.0)
MAX_DAILY_LOSS_PCT = _env_float("MAX_DAILY_LOSS_PCT", 8.0)
MAX_RISK_PER_TRADE_PCT = _env_float("MAX_RISK_PER_TRADE_PCT", 1.5)
MIN_RISK_REWARD_RATIO = _env_float("MIN_RISK_REWARD_RATIO", 2.0)
AUTO_TAKE_PROFIT_PCT = _env_float("AUTO_TAKE_PROFIT_PCT", 25.0)
AUTO_STOP_LOSS_PCT = _env_float("AUTO_STOP_LOSS_PCT", 8.0)
ENTRY_ORDER_TYPE = _env("ENTRY_ORDER_TYPE", "maker")  # maker | market
MAKER_ENTRY_OFFSET_PCT = _env_float("MAKER_ENTRY_OFFSET_PCT", 0.0)

# Fees
TAKER_FEE_PCT = _env_float("TAKER_FEE_PCT", 0.04)
MAKER_FEE_PCT = _env_float("MAKER_FEE_PCT", 0.02)
MIN_PROFIT_OVER_FEES_X = _env_float("MIN_PROFIT_OVER_FEES_X", 2.0)
MIN_NET_PROFIT_PCT = _env_float("MIN_NET_PROFIT_PCT", 5.0)

# Timeframe
TIMEFRAME = _env("TIMEFRAME", "5m")
LOOP_INTERVAL_SECONDS = int(_env("LOOP_INTERVAL_SECONDS", 3))
RUN_MINUTES = int(_env("RUN_MINUTES", 1440))

# Derived values
TOTAL_FEE_PCT = TAKER_FEE_PCT * 2  # entry + exit if both are taker, still expressed as a percent
BREAKEVEN_PNL_PCT = TOTAL_FEE_PCT * LEVERAGE
MIN_PROFIT_PCT = max(
    BREAKEVEN_PNL_PCT * MIN_PROFIT_OVER_FEES_X,
    MIN_NET_PROFIT_PCT,
)

assert BINANCE_API_KEY and BINANCE_SECRET_KEY, (
    "Falta BINANCE_API_KEY o BINANCE_SECRET_KEY en el .env"
)
assert "put_your_" not in BINANCE_API_KEY and "tu_api_key" not in BINANCE_API_KEY.lower(), (
    "BINANCE_API_KEY parece ser un placeholder. Reemplazala por una key real de Binance Futures Demo/Testnet."
)
assert "put_your_" not in BINANCE_SECRET_KEY and "tu_secret" not in BINANCE_SECRET_KEY.lower(), (
    "BINANCE_SECRET_KEY parece ser un placeholder. Reemplazala por un secret real de Binance Futures Demo/Testnet."
)
assert AI_PROVIDER in ("rules", "openai", "anthropic"), (
    "AI_PROVIDER debe ser 'rules', 'openai' o 'anthropic'"
)
if AI_PROVIDER == "openai":
    assert OPENAI_API_KEY, "Falta OPENAI_API_KEY para AI_PROVIDER=openai"
elif AI_PROVIDER == "anthropic":
    assert ANTHROPIC_API_KEY, "Falta ANTHROPIC_API_KEY para AI_PROVIDER=anthropic"
