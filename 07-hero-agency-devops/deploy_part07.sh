#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROYECTO 7: Pipeline de Integración CI/CD y DevOps: "Hero Agency" (Sesión 11)
# Autor: Rendo
# Rol: Senior Cloud Architect
# ==============================================================================

ACR_NAME="acrrendobc01"
ACR_LOGIN_SERVER="acrrendobc01.azurecr.io"
IMAGE_NAME="hero-agency-voting"
IMAGE_TAG="v1"
FULL_IMAGE="${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

echo ">> [1/4] Ejecutando Suite de Pruebas Unitarias Automatizadas (Stage 2: Test)..."
cd "$(dirname "$0")/app"
npx jest tests/server.test.js --verbose
cd ..

echo ">> [2/4] Construyendo Imagen Docker OCI (Stage 1: Build)..."
docker build -t "${FULL_IMAGE}" -t "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest" .

echo ">> [3/4] Publicando Imagen en Azure Container Registry Privado (ACR)..."
az acr login --name "${ACR_NAME}"
docker push "${FULL_IMAGE}"
docker push "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest"

echo ">> [4/4] Verificando Repositorio en Azure Container Registry..."
az acr repository show --name "${ACR_NAME}" --image "${IMAGE_NAME}:${IMAGE_TAG}" -o json

echo ">> ¡Parte 7 (DevOps & CI/CD Hero Agency) completada exitosamente!"
