#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROYECTO 6: Infraestructura como Código (IaC) con Bicep (Sesión 10)
# Autor: Rendo
# Rol: Senior Cloud Architect
# ==============================================================================

RG_NAME="rg-bootcamp-part06-iac"
LOCATION="eastus"

echo ">> [1/5] Creando Grupo de Recursos para IaC: $RG_NAME..."
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Project=AzureBootcamp Owner=Rendo Part=06 \
  -o table

echo ">> [2/5] Compilando y Verificando Sintaxis Bicep..."
az bicep build --file main.bicep

echo ">> [3/5] Publicando Módulo Bicep en Azure Container Registry Privado (ACR OCI)..."
az bicep publish \
  --file modules/monitoring.bicep \
  --target "br:acrrendobc01.azurecr.io/bicep/modules/monitoring:v1"

echo ">> [4/5] Ejecutando Validación Preflight en Azure ARM..."
az deployment group validate \
  --resource-group "$RG_NAME" \
  --template-file main.bicep \
  --parameters main.bicepparam \
  -o table

echo ">> [5/5] Desplegando Arquitectura Completa con Bicep..."
az deployment group create \
  --resource-group "$RG_NAME" \
  --template-file main.bicep \
  --parameters main.bicepparam \
  -o table

echo ">> ¡Parte 6 (IaC con Bicep) completada exitosamente!"
