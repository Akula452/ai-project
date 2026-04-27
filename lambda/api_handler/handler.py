import json
import os
import uuid

import boto3
from botocore.exceptions import ClientError

_client = boto3.client(
    "bedrock-agent-runtime",
    region_name=os.environ.get("AWS_REGION", "us-east-1"),
)

AGENT_ID = os.environ["BEDROCK_AGENT_ID"]
AGENT_ALIAS_ID = os.environ["BEDROCK_AGENT_ALIAS_ID"]


def lambda_handler(event, context):
    """REST API handler: GET /price?symbol=<TICKER>"""
    params = event.get("queryStringParameters") or {}
    symbol = (params.get("symbol") or "").upper().strip()

    if not symbol:
        return _error(400, "symbol query parameter is required")

    # Accept standard ticker formats: letters, digits, dot, hyphen; max 15 chars
    if not all(c.isalnum() or c in (".", "-") for c in symbol) or len(symbol) > 15:
        return _error(400, "invalid symbol format")

    session_id = str(uuid.uuid4())
    prompt = f"What is the current stock price for {symbol}?"

    try:
        resp = _client.invoke_agent(
            agentId=AGENT_ID,
            agentAliasId=AGENT_ALIAS_ID,
            sessionId=session_id,
            inputText=prompt,
            endSession=True,
        )
        completion = _collect_response(resp["completion"])
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"symbol": symbol, "response": completion}),
        }
    except ClientError as e:
        code = e.response["Error"]["Code"]
        if code in ("ResourceNotFoundException", "ValidationException"):
            return _error(404, f"Agent or alias not found: {code}")
        return _error(500, "Internal server error")
    except Exception:
        return _error(500, "Internal server error")


def _collect_response(completion_stream) -> str:
    parts = []
    for item in completion_stream:
        if "chunk" in item:
            parts.append(item["chunk"]["bytes"].decode("utf-8"))
    return "".join(parts)


def _error(status_code, message):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"error": message}),
    }
