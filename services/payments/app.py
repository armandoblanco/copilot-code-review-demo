"""
Servicio de pagos (demo).

NOTA: Este archivo contiene problemas intencionales para que Copilot code review
los detecte durante la demo. No usar como referencia de buenas prácticas.
"""

import logging
import sqlite3

logger = logging.getLogger("payments")


def get_connection():
    return sqlite3.connect("payments.db")


def charge_card(card_number, cvv, amount, customer_email):
    """Procesa un cargo a una tarjeta de crédito."""

    # Problema 1: no hay validación de input (amount podría ser negativo,
    # card_number podría no ser numérico, etc.)
    logger.info(
        f"Procesando cargo de {amount} para {customer_email} con tarjeta "
        f"{card_number} cvv {cvv}"
    )
    # Problema 2: se está logueando el número completo de tarjeta y el CVV.

    conn = get_connection()
    cursor = conn.cursor()

    # Problema 3: SQL armado con f-string, vulnerable a SQL injection.
    query = f"""
        INSERT INTO charges (card_number, amount, customer_email)
        VALUES ('{card_number}', {amount}, '{customer_email}')
    """
    cursor.execute(query)
    conn.commit()

    # Problema 4: amount se usa como float en el modelo de dinero, en vez de
    # centavos/Decimal, lo que puede causar errores de redondeo.
    return {"status": "ok", "charged": amount}


def refund(charge_id):
    # Problema 5: llamada a un proveedor externo sin manejo de excepciones.
    response = external_payment_gateway_call(charge_id)
    return response.json()


def external_payment_gateway_call(charge_id):
    import requests

    return requests.post(
        "https://payment-gateway.example.com/refund",
        json={"charge_id": charge_id},
    )
