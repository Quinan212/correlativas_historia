"""
Automatic fee calculator and breakeven estimation.

The bot should only trade when the expected profit comfortably clears:
- entry fee
- exit fee
- leverage amplification
- a minimum safety floor
"""

from dataclasses import dataclass
import config


@dataclass
class FeeBreakdown:
    """Full fee breakdown for a trade."""

    entry_fee_pct: float
    exit_fee_pct: float
    total_fee_pct: float
    total_fee_usdt: float
    breakeven_pnl_pct: float
    breakeven_price_move_pct: float
    min_profit_pct: float
    min_profit_price_move_pct: float
    min_profit_usdt: float


class FeeCalculator:
    """
    Compares expected profit against fees and a minimum safety floor.
    """

    def __init__(self, taker_fee_pct: float | None = None, maker_fee_pct: float | None = None):
        self.taker_fee = (taker_fee_pct if taker_fee_pct is not None else config.TAKER_FEE_PCT) / 100.0
        self.maker_fee = (maker_fee_pct if maker_fee_pct is not None else config.MAKER_FEE_PCT) / 100.0
        self.min_multiplier = config.MIN_PROFIT_OVER_FEES_X
        self.min_profit_floor_pct = config.MIN_NET_PROFIT_PCT

    def calculate(
        self,
        margin_usdt: float,
        use_maker_entry: bool = False,
        use_maker_exit: bool = False,
    ) -> FeeBreakdown:
        """
        Calculate fees and breakeven for a trade.
        """
        entry_fee_pct = self.maker_fee if use_maker_entry else self.taker_fee
        exit_fee_pct = self.maker_fee if use_maker_exit else self.taker_fee
        total_fee_pct = entry_fee_pct + exit_fee_pct

        leverage = config.LEVERAGE
        total_fee_usdt = margin_usdt * leverage * total_fee_pct
        breakeven_pnl_pct = total_fee_pct * leverage * 100.0
        breakeven_price_move_pct = breakeven_pnl_pct / leverage

        min_profit_pct = max(
            breakeven_pnl_pct * self.min_multiplier,
            self.min_profit_floor_pct,
        )
        min_profit_price_move_pct = min_profit_pct / leverage
        min_profit_usdt = margin_usdt * (min_profit_pct / 100.0)

        return FeeBreakdown(
            entry_fee_pct=entry_fee_pct * 100,
            exit_fee_pct=exit_fee_pct * 100,
            total_fee_pct=total_fee_pct * 100,
            total_fee_usdt=round(total_fee_usdt, 4),
            breakeven_pnl_pct=round(breakeven_pnl_pct, 4),
            breakeven_price_move_pct=round(breakeven_price_move_pct, 4),
            min_profit_pct=round(min_profit_pct, 4),
            min_profit_price_move_pct=round(min_profit_price_move_pct, 4),
            min_profit_usdt=round(min_profit_usdt, 4),
        )

    def is_trade_viable(
        self,
        expected_pnl_pct: float,
        margin_usdt: float,
    ) -> tuple[bool, str, FeeBreakdown]:
        """
        Decide whether a trade is worth taking after fees.
        """
        breakdown = self.calculate(margin_usdt)
        expected_margin_pnl_pct = expected_pnl_pct * config.LEVERAGE

        if expected_margin_pnl_pct <= breakdown.breakeven_pnl_pct:
            return (
                False,
                f"INVIABLE: expected move {expected_pnl_pct}% -> margin PnL {expected_margin_pnl_pct:.2f}% <= breakeven {breakdown.breakeven_pnl_pct}%. "
                f"Fees consume the move (${breakdown.total_fee_usdt:.2f}).",
                breakdown,
            )

        if expected_margin_pnl_pct < breakdown.min_profit_pct:
            return (
                False,
                f"INSUFFICIENT: expected move {expected_pnl_pct}% -> margin PnL {expected_margin_pnl_pct:.2f}% < required minimum {breakdown.min_profit_pct}%. "
                f"That floor is the larger of breakeven x{self.min_multiplier} or {self.min_profit_floor_pct}%.",
                breakdown,
            )

        net_pnl = expected_margin_pnl_pct - breakdown.breakeven_pnl_pct
        return (
            True,
            f"VIABLE: expected move {expected_pnl_pct}% -> margin PnL {expected_margin_pnl_pct:.2f}% -> approx net {net_pnl:.2f}% after fees "
            f"(${margin_usdt * expected_margin_pnl_pct / 100:.2f} gross - ${breakdown.total_fee_usdt:.2f} fees).",
            breakdown,
        )

    def get_required_pnl_for_target(self, target_net_usdt: float, margin_usdt: float) -> float:
        """
        Return the gross price-move % required to hit a target net USDT amount.
        """
        breakdown = self.calculate(margin_usdt)
        required_bruto_usdt = target_net_usdt + breakdown.total_fee_usdt
        required_bruto_margin_pnl_pct = (required_bruto_usdt / margin_usdt) * 100.0
        required_bruto_price_move_pct = required_bruto_margin_pnl_pct / config.LEVERAGE
        return round(required_bruto_price_move_pct, 4)


_fee_calculator: FeeCalculator | None = None


def get_fee_calculator(taker_fee_pct: float | None = None, maker_fee_pct: float | None = None) -> FeeCalculator:
    global _fee_calculator
    if _fee_calculator is None:
        _fee_calculator = FeeCalculator(taker_fee_pct=taker_fee_pct, maker_fee_pct=maker_fee_pct)
    return _fee_calculator


if __name__ == "__main__":
    fc = FeeCalculator()
    margin = 50.0
    print("=" * 60)
    print("CALCULADORA DE COMISIONES - SIMULACION")
    print("=" * 60)
    print(f"Margen: ${margin:.2f} | Apalancamiento: {config.LEVERAGE}x")
    print(f"Taker fee: {config.TAKER_FEE_PCT}% | Maker fee: {config.MAKER_FEE_PCT}%")
    print(f"Breakeven PnL: {config.BREAKEVEN_PNL_PCT:.4f}%")
    print(f"Min profit floor: {config.MIN_NET_PROFIT_PCT:.2f}%")
    print("-" * 60)

    bd = fc.calculate(margin)
    print("Fee Breakdown (taker/taker):")
    print(f"   Entry fee: {bd.entry_fee_pct}%")
    print(f"   Exit fee:  {bd.exit_fee_pct}%")
    print(f"   Total fee: {bd.total_fee_pct}% of notional")
    print(f"   Cost fees: ${bd.total_fee_usdt:.4f}")
    print(f"   Breakeven: {bd.breakeven_pnl_pct}% PnL")
    print(f"   Min recommended: {bd.min_profit_pct}% PnL (${bd.min_profit_usdt:.4f})")
    print()

    print("-" * 60)
    print("VIABILITY TESTS")
    print("-" * 60)

    scenarios = [0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    for pnl in scenarios:
        viable, msg, _ = fc.is_trade_viable(pnl, margin)
        print(msg)
