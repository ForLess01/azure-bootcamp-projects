"""
==============================================================================
PROYECTO 8: Microservicio FastAPI - Orquestación Agéntica para Banco BCP / ABC
Autor: Rendo
Rol: Senior Cloud Architect
==============================================================================
"""

import os
import json
import sys
from typing import Dict, Any, List, Optional
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field

# Agregar directorio raíz al PYTHONPATH
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

from agents.workflow import BankingCampaignWorkflow

app = FastAPI(
    title="Sistema Agéntico de Campañas para Banco (BCP / Banco ABC)",
    description="Orquestación Multi-Agente con LangGraph, RAG de Directrices Corporativas y FastAPI",
    version="1.0.0"
)

# Inicializar orquestador de agentes
workflow = BankingCampaignWorkflow()

# Cargar clientes de prueba
DATA_DIR = os.path.join(parent_dir, "data")
with open(os.path.join(DATA_DIR, "sample_customers.json"), "r", encoding="utf-8") as f:
    SAMPLE_CUSTOMERS = json.load(f)

with open(os.path.join(DATA_DIR, "campaigns_catalog.json"), "r", encoding="utf-8") as f:
    CAMPAIGNS_CATALOG = json.load(f)

class CustomerRequest(BaseModel):
    dni: Optional[str] = Field(None, description="DNI del cliente si ya está registrado")
    first_name: Optional[str] = "Cliente"
    last_name: Optional[str] = "Demo"
    age: Optional[int] = 30
    marital_status: Optional[str] = "Soltero"
    children: Optional[int] = 0
    monthly_income: Optional[float] = 4000.0
    monthly_expenses: Optional[float] = 2000.0
    primary_spending_categories: Optional[List[str]] = ["Supermercado", "Servicios"]
    banking_segment: Optional[str] = "General"

@app.get("/health", tags=["Monitoreo"])
def health_check():
    return {
        "status": "HEALTHY",
        "service": "banking-agentic-campaigns-api",
        "version": "1.0.0",
        "agents_active": ["CommercialMatchingAgent", "BrandRAGEngine", "CreativeCopyAgent", "BrandComplianceGuard"]
    }

@app.get("/api/v1/customers", tags=["Datos de Prueba"])
def list_sample_customers():
    """Retorna la lista de clientes de muestra con perfiles demográficos diferenciados."""
    return {"success": True, "count": len(SAMPLE_CUSTOMERS), "data": SAMPLE_CUSTOMERS}

@app.get("/api/v1/catalog", tags=["Catálogo de Campañas"])
def list_campaigns():
    """Retorna el catálogo corporativo de campañas financieras disponibles."""
    return {"success": True, "count": len(CAMPAIGNS_CATALOG), "data": CAMPAIGNS_CATALOG}

@app.post("/api/v1/campaigns/generate", tags=["Orquestación Agéntica"])
def generate_campaigns(request: CustomerRequest):
    """
    Ejecuta el flujo agéntico secuencial completo:
    1. Agente de Matching: Identifica las 3 campañas de mayor afinidad comercial.
    2. Motor RAG: Recupera directrices de marca y restricciones regulatorias SBS.
    3. Agente Creativo: Redacta Asuntos, Preheaders, Cuerpo, SMS y Prompts de Imagen (Flux/Gemini).
    4. Compliance Guard: Audita que no existan violaciones de marca.
    """
    customer_dict = None

    # Si se envió DNI, buscar en clientes precargados
    if request.dni:
        for c in SAMPLE_CUSTOMERS:
            if c["dni"] == request.dni:
                customer_dict = c
                break
        if not customer_dict and not request.first_name:
            raise HTTPException(status_code=404, detail=f"Cliente con DNI {request.dni} no encontrado en base de datos")

    if not customer_dict:
        customer_dict = request.model_dump()

    result = workflow.run_pipeline(customer_dict)
    return {
        "success": True,
        "customer": {
            "dni": customer_dict.get("dni", "N/A"),
            "name": f"{customer_dict.get('first_name')} {customer_dict.get('last_name')}",
            "segment": customer_dict.get("banking_segment", "General")
        },
        "matched_campaigns_count": len(result["matched_campaigns"]),
        "matched_campaigns": result["matched_campaigns"],
        "creatives": result["creatives"],
        "compliance_audit": result["compliance_audit"],
        "pipeline_status": result["pipeline_status"]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
