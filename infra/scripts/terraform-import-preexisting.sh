#!/usr/bin/env bash
# Antes de terraform apply: enlaza en el state recursos que ya existen en AWS
# con nombres fijos (mismo síntoma que ECR: state nuevo vs cuenta ya usada).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f envs_poc.tfvars ] && [ -s envs_poc.tfvars ]; then
  VARFILE=(-var-file=envs_poc.tfvars)
else
  VARFILE=()
fi

import_if_missing () {
  local addr=$1
  local id=$2
  if ! terraform state show "$addr" >/dev/null 2>&1; then
    echo "terraform import (if needed): $addr"
    terraform import "${VARFILE[@]}" "$addr" "$id" || true
  fi
}

LAMBDA_NAME="${LAMBDA_NAME:-tickets-support-agent}"

import_if_missing aws_ecr_repository.support_agent tickets-support-agent
import_if_missing aws_dynamodb_table.tickets_history TicketsHistoryPoC
import_if_missing aws_iam_role.lambda_support_role lambda-support-agent-role

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --no-cli-pager)
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/SupportAgentPolicy"
if aws iam get-policy --policy-arn "$POLICY_ARN" --no-cli-pager >/dev/null 2>&1; then
  import_if_missing aws_iam_policy.support_agent_policy "$POLICY_ARN"
fi

import_if_missing "module.lambda_support_agent.aws_cloudwatch_log_group.this" "/aws/lambda/${LAMBDA_NAME}"

if aws lambda get-function --function-name "$LAMBDA_NAME" --no-cli-pager >/dev/null 2>&1; then
  import_if_missing "module.lambda_support_agent.aws_lambda_function.this" "$LAMBDA_NAME"
fi

STATEMENT_ID="AllowExecutionFromAPIGateway-${LAMBDA_NAME}"
# Formato import AWS provider: function_name/statement_id
import_if_missing "module.lambda_support_agent.aws_lambda_permission.apigw" "${LAMBDA_NAME}/${STATEMENT_ID}"

echo "Pre-import pass finished."
