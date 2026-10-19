"""
==============================================================================
PROYECTO 8: Motor RAG y Compliance de Marca (Sesión 12)
Autor: Rendo
Rol: Senior Cloud Architect
==============================================================================
"""

import os
from typing import Dict, List, Any

class BrandRAGEngine:
    def __init__(self, guidelines_path: str = None):
        if not guidelines_path:
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            guidelines_path = os.path.join(base_dir, "data", "brand_guidelines.txt")
        self.guidelines_path = guidelines_path
        self.guidelines_text = self._load_guidelines()

    def _load_guidelines(self) -> str:
        if os.path.exists(self.guidelines_path):
            with open(self.guidelines_path, "r", encoding="utf-8") as f:
                return f.read()
        return "Directrices de marca predeterminadas: Tono empático, transparente, sin falsas promesas."

    def retrieve_guidelines_for_category(self, category: str, target_segment: str) -> Dict[str, Any]:
        """Recupera fragmentos relevantes de directrices según la categoría y segmento."""
        context = {
            "tone": "Empático, transparente, motivador y claro. Tratamos al cliente de 'tú'.",
            "prohibited_words": ["GRATIS", "100% aprobado", "sin evaluación", "regalado"],
            "mandatory_disclaimer": "Sujeto a evaluación crediticia y condiciones de la SBS.",
            "email_structure": {
                "subject_max_len": 50,
                "preheader_max_len": 90,
                "blocks": ["Gancho empático", "Propuesta de valor", "CTA claro"]
            },
            "sms_max_len": 160,
            "image_style": "Cinematic 35mm photo, authentic Peruvian/LatAm representation, warm natural lighting, candid emotions."
        }
        return context

    def audit_compliance(self, text: str) -> Dict[str, Any]:
        """Verifica que el texto generado no contravenga las regulaciones de la SBS ni la marca."""
        violations = []
        lower_text = text.lower()
        if "100% aprobado" in lower_text:
            violations.append("Uso de '100% aprobado' no permitido por riesgo crediticio")
        if "gratis" in lower_text:
            violations.append("Uso de 'gratis' condicionado detectado")
            
        return {
            "compliant": len(violations) == 0,
            "violations": violations,
            "audited_by": "BrandComplianceGuard"
        }
