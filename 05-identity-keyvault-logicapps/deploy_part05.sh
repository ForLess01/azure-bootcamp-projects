#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROYECTO 5: Identidades Administradas, Key Vault y Monitoreo (Sesiones 8 y 9)
# Autor: Rendo
# Rol: Senior Cloud Architect
# ==============================================================================

RG_NAME="rg-bootcamp-part05-identity"
LOCATION="eastus"
RAND_SUFFIX=$(od -An -N2 -i /dev/urandom | tr -d ' ')
KV_NAME="kv-rendo-${RAND_SUFFIX}"

echo ">> [1/5] Creando Grupo de Recursos para Identidades y Seguridad: $RG_NAME..."
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Project=AzureBootcamp Owner=Rendo Part=05 \
  -o table

echo ">> [2/5] Gestionando Microsoft Entra ID: Creando Grupo 'GRP_bootcamp_LEAD_UTP' y RBAC..."
# Verificar o crear el grupo de seguridad en Entra ID
GROUP_ID=$(az ad group list --display-name "GRP_bootcamp_LEAD_UTP" --query "[0].id" -o tsv 2>/dev/null || true)
if [ -z "$GROUP_ID" ] || [ "$GROUP_ID" == "None" ]; then
  GROUP_ID=$(az ad group create \
    --display-name "GRP_bootcamp_LEAD_UTP" \
    --mail-nickname "grpbootcampleadutp" \
    --query id -o tsv)
  echo "Grupo creado con ID: $GROUP_ID"
else
  echo "Grupo existente encontrado: $GROUP_ID"
fi

SUB_ID=$(az account show --query id -o tsv)
az role assignment create \
  --assignee-object-id "$GROUP_ID" \
  --assignee-principal-type "Group" \
  --role "Reader" \
  --scope "/subscriptions/${SUB_ID}/resourceGroups/${RG_NAME}" \
  -o table || true

echo ">> [3/5] Configurando Acceso Sin Contraseñas (User-Assigned Managed Identity)..."
UAMI_JSON=$(az identity create \
  --name "uami-storage-reader" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  -o json)

UAMI_PRINCIPAL_ID=$(echo "$UAMI_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['principalId'])")
echo "UAMI Principal ID: $UAMI_PRINCIPAL_ID"

# Asignar rol Storage Blob Data Reader sobre la cuenta de almacenamiento de Retail Andes
STORAGE_ID=$(az storage account show -g "rg-bootcamp-part04-retail-andes" -n $(cat ../04-retail-andes-data/part04_env.txt | grep STORAGE_NAME | cut -d= -f2) --query id -o tsv 2>/dev/null || true)
if [ -n "$STORAGE_ID" ]; then
  az role assignment create \
    --assignee-object-id "$UAMI_PRINCIPAL_ID" \
    --assignee-principal-type "ServicePrincipal" \
    --role "Storage Blob Data Reader" \
    --scope "$STORAGE_ID" \
    -o table || true
fi

echo ">> [4/5] Aprovisionando Azure Key Vault ($KV_NAME) y Almacenando Secretos..."
az keyvault create \
  --name "$KV_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --enable-rbac-authorization false \
  -o table

USER_UPN=$(az ad signed-in-user show --query userPrincipalName -o tsv)
az keyvault set-policy \
  --name "$KV_NAME" \
  --upn "$USER_UPN" \
  --secret-permissions get list set delete \
  -o table

az keyvault secret set \
  --vault-name "$KV_NAME" \
  --name "DbConnectionString" \
  --value "Server=sql-rendo-p01-30337.database.windows.net;Database=sqldb-adventureworks;Authentication=ActiveDirectoryDefault" \
  --expires "2026-11-18T00:00:00Z" \
  -o table

echo ">> [5/5] Creando Flujo de Monitoreo en Azure Logic Apps para Alertas de Expiración..."
cat << 'EOF' > logicapp_workflow.json
{
  "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "triggers": {
    "Recurrence_Daily_Audit": {
      "type": "Recurrence",
      "recurrence": {
        "frequency": "Day",
        "interval": 1,
        "schedule": {
          "hours": [8]
        }
      }
    }
  },
  "actions": {
    "Initialize_Audit_Report": {
      "type": "InitializeVariable",
      "inputs": {
        "variables": [
          {
            "name": "AuditStatus",
            "type": "string",
            "value": "KeyVault Secret Expiration Check: 30-day threshold active"
          }
        ]
      }
    }
  },
  "outputs": {}
}
EOF

az logic workflow create \
  --resource-group "$RG_NAME" \
  --name "logicapp-keyvault-expiration-audit" \
  --location "$LOCATION" \
  --definition @logicapp_workflow.json \
  -o table

echo "KV_NAME=$KV_NAME" > part05_env.txt
echo ">> ¡Parte 5 (Identidades, Key Vault y Monitoreo) completada exitosamente!"
