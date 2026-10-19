#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROYECTO 3: Redes Virtuales y Seguridad (VNet, Subredes, NSG y NICs)
# Autor: Rendo
# Rol: Senior Cloud Architect
# ==============================================================================

RG_NAME="rg-bootcamp-part03-networking"
LOCATION="eastus"

echo ">> [1/4] Creando Grupo de Recursos para Redes: $RG_NAME..."
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Project=AzureBootcamp Owner=Rendo Part=03 \
  -o table

echo ">> [2/4] Creando Red Virtual 'VNet-01' con segmentación de subredes..."
az network vnet create \
  --resource-group "$RG_NAME" \
  --name "VNet-01" \
  --address-prefix "10.0.0.0/16" \
  --subnet-name "Subnet-Frontend" \
  --subnet-prefix "10.0.1.0/24" \
  --location "$LOCATION" \
  -o table

az network vnet subnet create \
  --resource-group "$RG_NAME" \
  --vnet-name "VNet-01" \
  --name "Subnet-Backend" \
  --address-prefix "10.0.2.0/24" \
  -o table

echo ">> [3/4] Creando Network Security Group (NSG) y Reglas de Filtrado..."
az network nsg create \
  --resource-group "$RG_NAME" \
  --name "nsg-bootcamp-sec" \
  --location "$LOCATION" \
  -o table

# Reglas de Entrada: HTTP (80), HTTPS (443), SSH (22), RDP (3389)
az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "nsg-bootcamp-sec" \
  --name "Allow-HTTP" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80 \
  -o table

az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "nsg-bootcamp-sec" \
  --name "Allow-HTTPS" \
  --priority 110 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 \
  -o table

az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "nsg-bootcamp-sec" \
  --name "Allow-SSH" \
  --priority 120 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  -o table

az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "nsg-bootcamp-sec" \
  --name "Allow-RDP" \
  --priority 130 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 3389 \
  -o table

echo ">> [4/4] Aprovisionando Direcciones IP y Network Interfaces (NICs) asociadas..."
az network public-ip create \
  --resource-group "$RG_NAME" \
  --name "pip-vm01" \
  --sku Standard \
  --allocation-method Static \
  --location "$LOCATION" \
  -o table

az network nic create \
  --resource-group "$RG_NAME" \
  --name "nic-vm01" \
  --vnet-name "VNet-01" \
  --subnet "Subnet-Frontend" \
  --network-security-group "nsg-bootcamp-sec" \
  --public-ip-address "pip-vm01" \
  -o table

az network nic create \
  --resource-group "$RG_NAME" \
  --name "nic-vm02" \
  --vnet-name "VNet-01" \
  --subnet "Subnet-Backend" \
  --network-security-group "nsg-bootcamp-sec" \
  -o table

echo ">> ¡Parte 3 (Redes y Seguridad) completada exitosamente!"
