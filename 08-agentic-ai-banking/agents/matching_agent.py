"""
==============================================================================
PROYECTO 8: Agente de Afinidad Comercial (Matching Agent) (Sesión 12)
Autor: Rendo
Rol: Senior Cloud Architect
==============================================================================
"""

import json
import os
from typing import List, Dict, Any

class CommercialMatchingAgent:
    def __init__(self, catalog_path: str = None):
        if not catalog_path:
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            catalog_path = os.path.join(base_dir, "data", "campaigns_catalog.json")
        self.catalog_path = catalog_path
        self.catalog = self._load_catalog()

    def _load_catalog(self) -> List[Dict[str, Any]]:
        with open(self.catalog_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def calculate_affinity(self, customer: Dict[str, Any], campaign: Dict[str, Any]) -> float:
        """Calcula una puntuación de afinidad del 0 al 100 basada en perfil y hábitos."""
        score = 0.0

        # 1. Capacidad de Ingreso (Max 35 pts)
        min_income = campaign.get("min_income", 0)
        income = customer.get("monthly_income", 0)
        if income >= min_income:
            income_ratio = income / (min_income if min_income > 0 else 1)
            score += min(35.0, 20.0 + (income_ratio * 3.0))

        # 2. Estado Civil y Ciclo de Vida (Max 25 pts)
        marital = customer.get("marital_status", "")
        children = customer.get("children", 0)
        target_marital = campaign.get("target_marital_status", [])
        if marital in target_marital:
            score += 15.0

        # Filtros por hijos
        if "min_children" in campaign and children >= campaign["min_children"]:
            score += 10.0
        elif "max_children" in campaign and children <= campaign["max_children"]:
            score += 10.0

        # 3. Hábitos de Consumo / Categorías de Gasto (Max 40 pts)
        customer_cats = set(c.lower() for c in customer.get("primary_spending_categories", []))
        campaign_cats = set(c.lower() for c in campaign.get("target_spending_categories", []))
        overlap = customer_cats.intersection(campaign_cats)
        if len(campaign_cats) > 0:
            category_score = (len(overlap) / len(campaign_cats)) * 40.0
            score += min(40.0, category_score)

        return round(score, 2)

    def select_top_campaigns(self, customer: Dict[str, Any], top_k: int = 3) -> List[Dict[str, Any]]:
        """Evalúa todo el catálogo y selecciona las top_k campañas más afines."""
        ranked_campaigns = []
        for camp in self.catalog:
            affinity_score = self.calculate_affinity(customer, camp)
            ranked_campaigns.append({
                "campaign_id": camp["id"],
                "name": camp["name"],
                "category": camp["category"],
                "affinity_score": affinity_score,
                "benefits": camp["benefits"],
                "cta": camp["cta"]
            })

        # Ordenar descendentemente por afinidad
        ranked_campaigns.sort(key=lambda x: x["affinity_score"], reverse=True)
        return ranked_campaigns[:top_k]
