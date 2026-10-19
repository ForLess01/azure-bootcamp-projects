#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROYECTO 4: Ingesta y Orquestación de Datos: "Retail Andes" (Sesión 7)
# Autor: Rendo
# Rol: Senior Cloud Architect
# ==============================================================================

RG_NAME="rg-bootcamp-part04-retail-andes"
LOCATION="eastus"
RAND_SUFFIX=$(od -An -N2 -i /dev/urandom | tr -d ' ')
STORAGE_NAME="stretailandes${RAND_SUFFIX}"
ADF_NAME="adf-retail-andes-${RAND_SUFFIX}"

echo ">> [1/5] Creando Grupo de Recursos para Retail Andes: $RG_NAME..."
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Project=AzureBootcamp Owner=Rendo Part=04 ProjectName="Retail Andes" \
  -o table

echo ">> [2/5] Creando Azure Data Lake Storage Gen2 ($STORAGE_NAME)..."
az storage account create \
  --name "$STORAGE_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --enable-hierarchical-namespace true \
  -o table

STORAGE_KEY=$(az storage account keys list -g "$RG_NAME" -n "$STORAGE_NAME" --query "[0].value" -o tsv)

echo ">> [3/5] Creando contenedor 'bronze' en ADLS Gen2..."
az storage container create \
  --name "bronze" \
  --account-name "$STORAGE_NAME" \
  --account-key "$STORAGE_KEY" \
  -o table

echo ">> [4/5] Aprovisionando Azure Data Factory ($ADF_NAME)..."
az datafactory create \
  --resource-group "$RG_NAME" \
  --name "$ADF_NAME" \
  --location "$LOCATION" \
  -o table

echo ">> [5/5] Definiendo Linked Services y Pipeline de Ingesta hacia Capa Bronze..."
# Creando definición de Linked Service para ADLS Gen2
cat << EOF > ls_adls_gen2.json
{
  "type": "AzureBlobFS",
  "typeProperties": {
    "url": "https://${STORAGE_NAME}.dfs.core.windows.net",
    "accountKey": {
      "type": "SecureString",
      "value": "${STORAGE_KEY}"
    }
  }
}
EOF

az datafactory linked-service create \
  --resource-group "$RG_NAME" \
  --factory-name "$ADF_NAME" \
  --linked-service-name "LS_ADLS_Gen2_Bronze" \
  --properties @ls_adls_gen2.json \
  -o table

# Creando Dataset de Destino Parquet en Bronze
cat << 'EOF' > ds_bronze_parquet.json
{
  "type": "Parquet",
  "linkedServiceName": {
    "referenceName": "LS_ADLS_Gen2_Bronze",
    "type": "LinkedServiceReference"
  },
  "typeProperties": {
    "location": {
      "type": "AzureBlobFSLocation",
      "fileSystem": "bronze",
      "folderPath": "sales/adventureworks",
      "fileName": "SalesOrderHeader.parquet"
    }
  }
}
EOF

az datafactory dataset create \
  --resource-group "$RG_NAME" \
  --factory-name "$ADF_NAME" \
  --dataset-name "DS_Bronze_Parquet" \
  --properties @ds_bronze_parquet.json \
  -o table

# Creando Pipeline de Ingesta y Orquestación
cat << 'EOF' > pipeline_retail_andes.json
{
  "activities": [
    {
      "name": "Copy_AdventureWorks_to_Bronze_Parquet",
      "type": "Copy",
      "typeProperties": {
        "source": {
          "type": "AzureSqlSource",
          "sqlReaderQuery": "SELECT * FROM SalesLT.SalesOrderHeader WHERE ModifiedDate >= '2008-01-01'"
        },
        "sink": {
          "type": "ParquetSink",
          "storeSettings": {
            "type": "AzureBlobFSWriteSettings"
          },
          "formatSettings": {
            "type": "ParquetWriteSettings"
          }
        }
      },
      "outputs": [
        {
          "referenceName": "DS_Bronze_Parquet",
          "type": "DatasetReference"
        }
      ]
    }
  ]
}
EOF

az datafactory pipeline create \
  --resource-group "$RG_NAME" \
  --factory-name "$ADF_NAME" \
  --pipeline-name "PL_Ingesta_Retail_Andes_Bronze" \
  --pipeline @pipeline_retail_andes.json \
  -o table

echo "STORAGE_NAME=$STORAGE_NAME" > part04_env.txt
echo "ADF_NAME=$ADF_NAME" >> part04_env.txt
echo ">> ¡Parte 4 (Retail Andes - Ingesta y Orquestación) completada exitosamente!"
