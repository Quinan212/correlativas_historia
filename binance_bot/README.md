# 🤖 Bot de Trading Autónomo - Binance Futures

Bot 100% autónomo que opera en Binance Futures usando IA local por reglas o usando OpenAI/Anthropic para tomar decisiones LONG/SHORT/HOLD, con **cálculo automático de comisiones** para evitar operar a pérdida por fees.

El bot intenta leer la comisión real de tu cuenta Binance Futures usando el endpoint oficial `/fapi/v1/commissionRate`. Si no puede consultarla, usa los valores de respaldo del `.env`.
Por defecto está pensado para correr en `AI_PROVIDER=rules` y `BINANCE_TESTNET=true`.

## 🎯 Funcionalidad principal

1. **Lee el mercado** en tiempo real (precio, velas, balance)
2. **Consulta a la IA** que analiza y decide LONG / SHORT / HOLD
3. **Calcula comisiones automáticamente** y determina si la ganancia esperada supera los fees
4. **Valida riesgo** (stop loss, take profit, límite diario de pérdidas)
5. **Ejecuta órdenes** en Binance Futures (testnet o real)
6. **Monitorea posiciones** abiertas y cierra cuando corresponde
7. **Loop 24/7** — completamente autónomo

## 🧮 La calculadora de comisiones

El bot calcula automáticamente:

```
Fee total = (maker/taker real de Binance) x 2
Breakeven = Fee total × apalancamiento
Ganancia mínima recomendada = max(Breakeven × MIN_PROFIT_OVER_FEES_X, MIN_NET_PROFIT_PCT)

La IA debe devolver `expected_pnl_pct` como movimiento esperado del precio antes de apalancamiento. El bot lo convierte a retorno real sobre margen usando el leverage configurado.

Si no tenés API key de IA, dejá `AI_PROVIDER=rules` y el bot usará una estrategia local con RSI, EMA y ATR.

Para prueba en Binance Futures Demo/Testnet, el bot apunta al endpoint oficial `https://demo-fapi.binance.com`.
```

Ejemplo con $50 de margen y apalancamiento x5:

| Concepto | Valor |
|----------|-------|
| Taker fee (entrada) | 0.04% |
| Taker fee (salida) | 0.04% |
| Fee total sobre nocional | 0.08% |
| **Costo real en USD** | **$0.20** |
| Breakeven (PnL %) | **0.40%** |
| Ganancia mínima recomendada (2x) | **0.80%** |

**Si la IA estima una ganancia menor al breakeven, el bot NO opera.** Así no regalás plata al exchange.

## 📦 Instalación

```bash
cd binance_bot
pip install -r requirements.txt
```

## ⚙️ Configuración

1. Copiá `.env.example` a `.env`:
```bash
copy .env.example .env   # Windows
cp .env.example .env     # Linux/Mac
```

2. Editá `.env` con tus API keys:

```env
# Binance Futures Testnet (gratis, para probar)
BINANCE_API_KEY=tu_api_key_de_testnet
BINANCE_SECRET_KEY=tu_secret_key_de_testnet
BINANCE_TESTNET=true

# IA - elegí UNA
AI_PROVIDER=openai
OPENAI_API_KEY=sk-tu_key_aqui
```

3. **Obtené API keys de testnet**: https://testnet.binancefuture.com/

## 🚀 Ejecución

```bash
# Loop infinito (24/7)
python main.py

# Una sola iteración (modo debug)
python main.py --once

# Demo de la calculadora de comisiones
python fee_calculator.py
```

## 📊 Estructura del proyecto

```
binance_bot/
├── main.py              # Loop principal, entry point
├── config.py            # Configuración desde .env
├── exchange.py          # Conexión a Binance Futures (ccxt)
├── fee_calculator.py    # Calculadora de comisiones y viabilidad
├── ai_engine.py         # Motor de decisión IA (OpenAI/Claude)
├── risk_manager.py      # Gestión de riesgo (SL, TP, límite diario)
├── .env.example         # Template de configuración
├── requirements.txt     # Dependencias
└── README.md            # Este archivo
```

## 🛡️ Gestión de riesgo

- **Máximo riesgo por trade**: 1.5% del capital (configurable)
- **Límite diario de pérdidas**: 8% (el bot se detiene hasta el día siguiente)
- **Ratio riesgo/beneficio mínimo**: 2:1
- **Confianza mínima de IA**: 0.5 (50%)
- **Tamaño de posición**: calculado automáticamente según riesgo

## 📝 Logs

- Salida por consola con colores (INFO)
- Archivo `bot_trades.log` con rotación automática (DEBUG)

## ⚠️ Advertencia

**Este bot es para fines educativos y de prueba.** Operar con dinero real implica riesgos. Probá siempre en testnet primero durante al menos 24-72 horas antes de usar fondos reales. Con apalancamiento x5 o x10, movimientos pequeños pueden liquidar tu posición rápidamente.

## 🔧 Personalización

Editá `.env` para ajustar:

| Variable | Default | Descripción |
|----------|---------|-------------|
| `SYMBOL` | BTCUSDT | Par a operar |
| `LEVERAGE` | 5 | Apalancamiento (1-125) |
| `TIMEFRAME` | 5m | Temporalidad de velas |
| `LOOP_INTERVAL_SECONDS` | 3 | Segundos entre iteraciones |
| `RUN_MINUTES` | 1440 | Duracion por defecto del loop en minutos |
| `MAX_DAILY_LOSS_PCT` | 8 | % máximo de pérdida diaria |
| `MAX_RISK_PER_TRADE_PCT` | 1.5 | % de riesgo por operación |
| `MIN_PROFIT_OVER_FEES_X` | 2.0 | Multiplicador sobre fees para ganancia mínima |
| `MIN_NET_PROFIT_PCT` | 5.0 | Piso mínimo de ganancia neta esperado |
