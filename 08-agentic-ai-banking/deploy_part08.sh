#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# PROYECTO 8: Sistema Agéntico de Campañas para Banco (BCP / Banco ABC) (Sesión 12)
# Autor: Rendo
# Rol: Senior Cloud Architect
# ==============================================================================

echo ">> [1/3] Ejecutando Validación Multi-Agente (Matching + RAG + Creativo + Compliance)..."
python3 08-agentic-ai-banking/test_flow.py

echo ">> [2/3] Verificando Sintaxis y Tipado del Microservicio FastAPI..."
python3 -m py_compile 08-agentic-ai-banking/app/main.py

echo ">> [3/3] Ejecutando Simulación de Inferencia API para Mateo Quispe (DNI: 45892147)..."
PYTHONPATH=08-agentic-ai-banking python3 -c "
import json
from agents.workflow import BankingCampaignWorkflow
wf = BankingCampaignWorkflow()
with open('08-agentic-ai-banking/data/sample_customers.json') as f:
    cust = json.load(f)[0]
res = wf.run_pipeline(cust)
print(json.dumps({
    'customer': cust['first_name'] + ' ' + cust['last_name'],
    'top_campaign': res['matched_campaigns'][0]['name'],
    'affinity_score': res['matched_campaigns'][0]['affinity_score'],
    'image_prompt': res['creatives'][0]['image_generation_prompt']['prompt_en'][:80] + '...',
    'compliance': res['compliance_audit']['compliant']
}, indent=2))
"

echo ">> ¡Parte 8 (Sistema Agéntico de Campañas para Banco) completada exitosamente!"
