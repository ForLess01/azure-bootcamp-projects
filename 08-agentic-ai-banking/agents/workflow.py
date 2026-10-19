"""
==============================================================================
PROYECTO 8: Orquestación Agéntica con Patrón StateGraph / LangGraph (Sesión 12)
Autor: Rendo
Rol: Senior Cloud Architect
==============================================================================
"""

import os
from typing import Dict, Any, List
from .matching_agent import CommercialMatchingAgent
from .rag_engine import BrandRAGEngine
from .creative_agent import CreativeCopyAgent

class BankingCampaignWorkflow:
    def __init__(self):
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        catalog_path = os.path.join(base_dir, "data", "campaigns_catalog.json")
        guidelines_path = os.path.join(base_dir, "data", "brand_guidelines.txt")

        self.matching_agent = CommercialMatchingAgent(catalog_path)
        self.rag_engine = BrandRAGEngine(guidelines_path)
        self.creative_agent = CreativeCopyAgent(self.rag_engine)

    def run_pipeline(self, customer: Dict[str, Any]) -> Dict[str, Any]:
        """
        Ejecuta el grafo secuencial multi-agente:
        [Matching Agent] -> [RAG Guidelines] -> [Creative Copy Agent] -> [Compliance Guard]
        """
        state = {
            "customer": customer,
            "matched_campaigns": [],
            "brand_context": {},
            "creatives": [],
            "compliance_audit": {},
            "pipeline_status": "PENDING"
        }

        # Paso 1: Matching Comercial (Top 3 Campañas)
        top_campaigns = self.matching_agent.select_top_campaigns(customer, top_k=3)
        state["matched_campaigns"] = top_campaigns

        # Paso 2: RAG de Directrices de Marca
        segment = customer.get("banking_segment", "General")
        state["brand_context"] = self.rag_engine.retrieve_guidelines_for_category("All", segment)

        # Paso 3: Agente Creativo y Redactor (Email, SMS, Push, Image Prompts)
        creatives = []
        all_text_to_audit = ""
        for camp in top_campaigns:
            creative = self.creative_agent.generate_campaign_creative(customer, camp, state["brand_context"])
            creatives.append(creative)
            all_text_to_audit += f" {creative['email']['body']} {creative['sms']}"

        state["creatives"] = creatives

        # Paso 4: Auditoría de Compliance (SBS / Marca)
        audit = self.rag_engine.audit_compliance(all_text_to_audit)
        state["compliance_audit"] = audit
        state["pipeline_status"] = "SUCCESS" if audit["compliant"] else "FLAGGED"

        return state
