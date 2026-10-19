#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROYECTO 1: Configuración Inicial, FinOps y Azure SQL Database
# Autor: Rendo
# Rol: Senior Cloud Architect
# ==============================================================================

echo "=============================================================================="
echo ">> [1/4] Creando Grupo de Recursos 'rg-bootcamp-part01-costsql' en 'eastus'..."
echo "=============================================================================="
az group create \
  --name "rg-bootcamp-part01-costsql" \
  --location "eastus" \
  --tags Project=AzureBootcamp Owner=Rendo Part=01 Environment=Production \
  -o table

echo "=============================================================================="
echo ">> [2/4] Configurando Presupuesto de Costos (FinOps) en Resource Group..."
echo "=============================================================================="
cat << 'EOF' > budget-notifications.json
{
  "notification1": {
    "contactEmails": [
      "renforalltasks@hotmail.com"
    ],
    "enabled": true,
    "operator": "GreaterThan",
    "threshold": 80.0
  }
}
EOF

az consumption budget create-with-rg \
  --budget-name "budget-rg-part01" \
  --resource-group "rg-bootcamp-part01-costsql" \
  --amount 25 \
  --category Cost \
  --time-grain Monthly \
  --time-period start-date=2026-10-01 end-date=2027-10-01 \
  --notifications @budget-notifications.json \
  -o table

echo "=============================================================================="
echo ">> [3/4] Aprovisionando Azure SQL Server con Microsoft Entra ID Only Auth..."
echo "=============================================================================="
SERVER_NAME=$(cat server_name.txt 2>/dev/null || echo "sql-rendo-p01-$RANDOM")
USER_ID=$(az ad signed-in-user show --query id -o tsv)
USER_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv)

az sql server create \
  --name "$SERVER_NAME" \
  --resource-group "rg-bootcamp-part01-costsql" \
  --location "westus" \
  --enable-ad-only-auth \
  --external-admin-principal-type User \
  --external-admin-name "$USER_NAME" \
  --external-admin-sid "$USER_ID" \
  -o table

echo "=============================================================================="
echo ">> [4/4] Configurando Regla de Firewall y Desplegando Base de Datos..."
echo "=============================================================================="
az sql server firewall-rule create \
  --resource-group "rg-bootcamp-part01-costsql" \
  --server "$SERVER_NAME" \
  --name "AllowAllWindowsAzureIps" \
  --start-ip-address "0.0.0.0" \
  --end-ip-address "0.0.0.0" \
  -o table

az sql db create \
  --resource-group "rg-bootcamp-part01-costsql" \
  --server "$SERVER_NAME" \
  --name "sqldb-adventureworks" \
  --edition Basic \
  --capacity 5 \
  --sample-name AdventureWorksLT \
  -o table

echo ">> ¡Parte 1 completada exitosamente por Rendo!"
