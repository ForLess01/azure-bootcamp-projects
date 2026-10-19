from fastapi import FastAPI
import os

app = FastAPI(
    title="Banking Campaigns API - Rendo Architecture",
    version="1.0.0",
    description="Microservicio de Campañas Bancarias desplegado en Azure Container Apps"
)

@app.get("/")
def read_root():
    return {
        "status": "online",
        "service": "Banking Marketing Campaigns Engine",
        "architect": "Rendo",
        "environment": os.getenv("ENVIRONMENT", "Production"),
        "platform": "Azure Container Apps"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "api-banking-campaigns"}

@app.get("/api/v1/campaigns")
def list_campaigns():
    return [
        {
            "id": "CAMP-001",
            "name": "Tarjeta Black Millas Latam",
            "target": "High Net Worth / Viajeros",
            "benefit": "15,000 millas de bienvenida + Sala VIP"
        },
        {
            "id": "CAMP-002",
            "name": "Préstamo Vehicular Tasa Preferencial",
            "target": "Familia / Consumo Automotriz",
            "benefit": "TEA 8.99% + SOAT Gratis por 1 año"
        },
        {
            "id": "CAMP-003",
            "name": "Fondo Mutuo Visión Global",
            "target": "Inversionistas / Ahorristas",
            "benefit": "Rendimiento proyectado 9.5% anual en USD"
        }
    ]
