import json
import urllib.request
import urllib.error
from datetime import datetime, timezone


def lambda_handler(event, context):
    """Bedrock Agent action group handler for real-time stock price retrieval."""
    action_group = event.get("actionGroup", "")
    function_name = event.get("function", "")
    parameters = {p["name"]: p["value"] for p in event.get("parameters", [])}

    ticker = parameters.get("ticker", "").upper().strip()

    if not ticker:
        return _response(action_group, function_name, "Error: ticker parameter is required", "FAILURE")

    try:
        price_data = _fetch_yahoo_price(ticker)
        body = (
            f"Ticker: {ticker}\n"
            f"Price: {price_data['price']} {price_data['currency']}\n"
            f"Exchange: {price_data['exchange']}\n"
            f"As of: {price_data['timestamp']}"
        )
        return _response(action_group, function_name, body, "SUCCESS")
    except ValueError as e:
        return _response(action_group, function_name, str(e), "FAILURE")
    except Exception:
        return _response(
            action_group,
            function_name,
            f"Unable to retrieve price for {ticker}. Please check the symbol and try again.",
            "FAILURE",
        )


def _fetch_yahoo_price(ticker: str) -> dict:
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{ticker}?interval=1m&range=1d"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})

    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            raise ValueError(f"Ticker '{ticker}' not found on Yahoo Finance.")
        raise

    chart = data.get("chart", {})
    error = chart.get("error")
    if error:
        raise ValueError(f"Yahoo Finance error: {error.get('description', 'unknown error')}")

    results = chart.get("result")
    if not results:
        raise ValueError(f"No data returned for ticker '{ticker}'.")

    meta = results[0]["meta"]
    price = meta.get("regularMarketPrice") or meta.get("previousClose")
    if price is None:
        raise ValueError(f"Price data unavailable for '{ticker}'.")

    currency = meta.get("currency", "USD")
    exchange = meta.get("exchangeName", "Unknown")
    ts = datetime.fromtimestamp(
        meta.get("regularMarketTime", 0), tz=timezone.utc
    ).isoformat()

    return {"price": price, "currency": currency, "exchange": exchange, "timestamp": ts}


def _response(action_group, function_name, body, state):
    return {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": action_group,
            "function": function_name,
            "functionResponse": {
                "responseState": state,
                "responseBody": {"TEXT": {"body": body}},
            },
        },
    }
