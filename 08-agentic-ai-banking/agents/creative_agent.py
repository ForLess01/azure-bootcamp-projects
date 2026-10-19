"""
==============================================================================
PROYECTO 8: Agente Redactor y Creativo (Creative Agent) (Sesión 12)
Autor: Rendo
Rol: Senior Cloud Architect
==============================================================================
"""

from typing import Dict, Any, List

class CreativeCopyAgent:
    def __init__(self, rag_engine=None):
        self.rag_engine = rag_engine

    def generate_campaign_creative(self, customer: Dict[str, Any], campaign: Dict[str, Any], brand_context: Dict[str, Any]) -> Dict[str, Any]:
        """Genera piezas multicanal (Email, SMS, Push) y prompt para generación de imagen."""
        first_name = customer.get("first_name", "Cliente")
        camp_name = campaign.get("name", "")
        category = campaign.get("category", "")
        benefits = campaign.get("benefits", [])
        cta = campaign.get("cta", "Ingresa a tu App")

        # 1. Email Personalizado
        email_data = self._generate_email(first_name, camp_name, category, benefits, cta, customer)

        # 2. SMS (160 caracteres max)
        sms_data = self._generate_sms(first_name, camp_name, cta)

        # 3. Notificación Push en Banca Móvil
        push_data = self._generate_push(first_name, camp_name, category)

        # 4. Prompt para Generación de Imagen (Inglés - Flux / Nano Banana / Gemini)
        image_prompt = self._generate_image_prompt(customer, category)

        return {
            "campaign_id": campaign.get("campaign_id"),
            "campaign_name": camp_name,
            "category": category,
            "affinity_score": campaign.get("affinity_score"),
            "email": email_data,
            "sms": sms_data,
            "push_notification": push_data,
            "image_generation_prompt": image_prompt
        }

    def _generate_email(self, name: str, camp_name: str, category: str, benefits: List[str], cta: str, customer: Dict[str, Any]) -> Dict[str, str]:
        if "Tarjetas" in category:
            subject = f"{name}, tus viajes soñados te esperan hoy"[:50]
            preheader = "Descubre los beneficios exclusivos de tu nueva tarjeta Signature"[:90]
            hook = f"Sabemos que disfrutas explorar nuevos destinos gastronómicos y viajar por el mundo sin preocupaciones."
        elif "Hipotecario" in category:
            subject = f"{name}, el hogar de tu familia está cerca"[:50]
            preheader = "Precalifica hoy mismo con tasa preferencial y cuotas a tu medida"[:90]
            hook = f"Dar el gran paso hacia una casa propia para tu familia es más sencillo cuando cuentas con el respaldo adecuado."
        elif "Educativo" in category or "Prestamos" in category:
            subject = f"{name}, impulsa la educación de los tuyos"[:50]
            preheader = "Financiamiento educativo con periodo de gracia para tus proyectos"[:90]
            hook = f"Invertir en la educación de tus seres queridos es la mejor decisión para construir un futuro sólido y prometedor."
        else:
            subject = f"{name}, una oportunidad diseñada para ti"[:50]
            preheader = "Accede a beneficios financieros pensados exclusivamente en tu bienestar"[:90]
            hook = f"Queremos acompañarte en cada una de tus metas con soluciones digitales ágiles y transparentes."

        bullets = "".join([f"  • {b}\n" for b in benefits[:3]])
        body = (
            f"Hola, {name}.\n\n"
            f"{hook}\n\n"
            f"Por ello, hemos preparado para ti: **{camp_name}** con ventajas diferenciales:\n"
            f"{bullets}\n"
            f"Aprovecha esta oportunidad antes de fin de mes.\n\n"
            f"👉 {cta}\n\n"
            f"---\n"
            f"TCEA referencial. Sujeto a evaluación crediticia. Banco ABC / BCP. El banco de todos."
        )

        return {
            "subject": subject,
            "preheader": preheader,
            "body": body
        }

    def _generate_sms(self, name: str, camp_name: str, cta: str) -> str:
        text = f"Banco ABC: {name}, aprovecha hoy {camp_name}. {cta}. Mas info: bcp.pe/oferta T&C aplican."
        if len(text) > 160:
            text = text[:157] + "..."
        return text

    def _generate_push(self, name: str, camp_name: str, category: str) -> Dict[str, str]:
        title = f"✨ {name}, tu oferta exclusiva"[:40]
        if "Tarjetas" in category:
            body = "Acumula 10,000 millas de bienvenida con tu Signature. ¡Pídela aquí!"[:100]
        elif "Hipotecario" in category:
            body = "Bono de S/5,000 para tu nuevo hogar. Simula tu crédito en segundos."[:100]
        else:
            body = f"Descubre tu beneficio especial en {camp_name}. Toca para ver."[:100]

        return {
            "title": title,
            "body": body
        }

    def _generate_image_prompt(self, customer: Dict[str, Any], category: str) -> Dict[str, str]:
        age = customer.get("age", 30)
        gender = "man" if customer.get("marital_status") != "Casada" and customer.get("first_name") != "Valeria" else "woman"
        marital = customer.get("marital_status", "Single")
        children = customer.get("children", 0)

        if "Tarjetas" in category:
            scene = f"A stylish Latin American {gender} around {age} years old relaxing at a modern international airport lounge, holding a premium passport case, warm golden hour ambient lighting, depth of field, candid smile of freedom, high-end lifestyle photography, 35mm lens, f/1.8, cinematic."
        elif "Hipotecario" in category:
            scene = f"A young Latin American couple in their early 30s with a cheerful child, entering an airy, bright newly purchased apartment, natural morning sunlight streaming through large windows, emotional expressions of joy and pride, interior design magazine aesthetic, Sony Alpha 7 IV style."
        elif "Educativo" in category:
            scene = f"A caring Latin American mother around {age} years old lovingly helping her young daughter with science homework in a cozy living room, warm table lamp illumination, atmosphere of dedication and optimism, editorial portrait, crisp details."
        else:
            scene = f"A confident Latin American professional around {age} checking banking mobile app on a sleek smartphone in an urban cafe, genuine expression of financial peace of mind, morning city bokeh background, realistic textures."

        return {
            "model_compatibility": "Flux.1 / Nano Banana / Gemini Imagen 3",
            "prompt_en": scene,
            "aspect_ratio": "16:9",
            "target_demographic": f"{age}yo, {marital}, {children} children, Peru/LatAm"
        }
