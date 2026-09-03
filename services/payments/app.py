"""
Servicio de pagos (demo).

Versión base segura. Las ramas de feature introducirán variantes con
problemas intencionales para demostrar el gate de Copilot code review.
"""

import logging
from decimal import Decimal

logger = logging.getLogger("payments")


def charge_card(amount_cents: int, customer_email: str) -> dict:
    """Procesa un cargo. No maneja número de tarjeta directamente (lo hace
    un proveedor de pagos externo vía token)."""
    if amount_cents <= 0:
        raise ValueError("amount_cents debe ser positivo")

    logger.info("Procesando cargo de %s centavos para %s", amount_cents, customer_email)
    return {"status": "ok", "charged_cents": amount_cents}
