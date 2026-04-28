"""
Gestion de riesgo: valida que cada operacion respete limites de perdida,
tamano de posicion, stop loss y take profit.

Este modulo es el guardrail final antes de ejecutar cualquier orden.
"""

from dataclasses import dataclass, field
from datetime import datetime
from loguru import logger

import config


@dataclass
class DailyTracker:
    """Trackea PnL del dia para no exceder MAX_DAILY_LOSS_PCT."""
    date: str = field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d"))
    starting_balance: float = 0.0
    current_pnl: float = 0.0
    trades_today: int = 0
    stopped_out: bool = False  # si ya alcanzo el limite diario

    @property
    def pnl_pct(self) -> float:
        if self.starting_balance <= 0:
            return 0.0
        return (self.current_pnl / self.starting_balance) * 100.0

    @property
    def max_loss_reached(self) -> bool:
        return self.pnl_pct <= -config.MAX_DAILY_LOSS_PCT

    def reset_if_new_day(self):
        today = datetime.now().strftime("%Y-%m-%d")
        if today != self.date:
            logger.info(f"📅 Nuevo dia: {today}. Reset diario.")
            self.date = today
            self.starting_balance = 0.0
            self.current_pnl = 0.0
            self.trades_today = 0
            self.stopped_out = False


# Singleton
_daily_tracker: DailyTracker = DailyTracker()


def get_daily_tracker() -> DailyTracker:
    return _daily_tracker


class RiskValidator:
    """
    Valida decisiones de trading contra reglas de riesgo.
    """

    def __init__(self):
        self.max_risk_pct = config.MAX_RISK_PER_TRADE_PCT
        self.min_rr_ratio = config.MIN_RISK_REWARD_RATIO
        self.max_position_pct = config.MAX_POSITION_PCT

    def validate_decision(self, expected_move_pct: float,
                          stop_loss_pct: float,
                          take_profit_pct: float,
                          confidence: float,
                          current_balance: float,
                          proposed_margin: float) -> tuple[bool, str]:
        """
        Valida si una decision de trading es aceptable segun reglas de riesgo.
        
        Returns:
            (aprobado: bool, motivo: str)
        """
        tracker = get_daily_tracker()
        tracker.reset_if_new_day()

        # 1. Limite diario de perdidas
        if tracker.stopped_out or tracker.max_loss_reached:
            return (False,
                    f"🔴 Limite diario de perdida alcanzado ({tracker.pnl_pct:.2f}%). "
                    f"Maximo configurado: {config.MAX_DAILY_LOSS_PCT}%. "
                    "Esperar al siguiente dia.")

        # 2. Confianza minima
        if confidence < 0.5:
            return (False,
                    f"🟡 Confianza baja ({confidence:.2f}). Minimo requerido: 0.5. NO operar.")

        # 3. Risk/Reward ratio
        if take_profit_pct > 0 and stop_loss_pct > 0:
            rr_ratio = take_profit_pct / stop_loss_pct
            if rr_ratio < self.min_rr_ratio:
                return (False,
                        f"🟡 Ratio R/R bajo: {rr_ratio:.2f} < {self.min_rr_ratio}. "
                        f"(TP={take_profit_pct}%, SL={stop_loss_pct}%)")

        # 4. Riesgo maximo por trade
        max_loss_per_trade = current_balance * (self.max_risk_pct / 100.0)
        potential_loss = proposed_margin * (stop_loss_pct / 100.0) * config.LEVERAGE
        if potential_loss > max_loss_per_trade:
            return (False,
                    f"🔴 Riesgo excesivo: perdida potencial ${potential_loss:.2f} > "
                    f"max permitido ${max_loss_per_trade:.2f} ({self.max_risk_pct}%).")

        # 5. Posicion maxima
        max_margin = current_balance * (self.max_position_pct / 100.0)
        if proposed_margin > max_margin:
            return (False,
                    f"🔴 Margen excesivo: ${proposed_margin:.2f} > "
                    f"max permitido ${max_margin:.2f} ({self.max_position_pct}% del capital).")

        return (True, "✅ Operacion validada por riesgo.")

    def calculate_position_size(self, balance: float,
                                stop_loss_pct: float) -> float:
        """
        Calcula el tamano de posicion optimo basado en riesgo maximo por trade.
        
        Formula: margin = (balance * risk_pct) / (stop_loss_pct * leverage)
        """
        risk_amount = balance * (self.max_risk_pct / 100.0)
        margin = risk_amount / ((stop_loss_pct / 100.0) * config.LEVERAGE)
        max_margin = balance * (self.max_position_pct / 100.0)
        return min(margin, max_margin)


def record_trade_result(pnl_usdt: float):
    """Registra resultado de un trade en el tracker diario."""
    tracker = get_daily_tracker()
    tracker.reset_if_new_day()
    tracker.current_pnl += pnl_usdt
    tracker.trades_today += 1

    if tracker.max_loss_reached:
        tracker.stopped_out = True
        logger.warning(
            f"⛔ STOP DIARIO: Perdida acumulada {tracker.pnl_pct:.2f}% "
            f"supera limite {config.MAX_DAILY_LOSS_PCT}%. Bot detenido hasta mañana."
        )

    logger.info(f"📊 PnL diario: ${tracker.current_pnl:.4f} "
                f"({tracker.pnl_pct:.2f}%) | Trades hoy: {tracker.trades_today}")
