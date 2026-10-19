# Azure Enterprise Projects & Generative AI Multi-Agent System

**Autor:** Rendo Alfonte Tarqui  
**Cuenta de Azure:** `rendoaltar@hotmail.com`  
**Directorio Entra ID:** `rendoaltarhotmail.onmicrosoft.com`  
**Suscripción:** Azure for Students (`03b04657-b7ac-4a69-a451-53641d1e2002`)  
**Documento Oficial Compilado (PDF):** [`report-latex/main.pdf`](report-latex/main.pdf)

---

## 📌 Descripción del Proyecto

Repositorio integral con la arquitectura, scripts de aprovisionamiento automatizado mediante **Azure CLI**, plantillas modulares en **Azure Bicep**, pipelines de **Azure DevOps (CI/CD)** y la implementación de un **Sistema Agéntico de Campañas para Banca (LangGraph + RAG + FastAPI)**.

El proyecto abarca las 12 sesiones del Azure Bootcamp, aplicando estrictos criterios de **FinOps** para optimizar el crédito disponible ($100 USD) mediante niveles gratuitos (App Service F1 Free), cómputo serverless y autenticación Zero Trust sin contraseñas estáticas.

---

## 🏗️ Estructura del Repositorio

- **`01-cost-and-sql/`**: Configuración inicial de Grupos de Recursos, presupuestos mensuales con alertas en Azure Cost Management y base de datos Azure SQL (`AdventureWorksLT`) con autenticación Microsoft Entra ID Only (`--enable-ad-only-auth`).
- **`02-compute-apps-containers/`**: Cómputo PaaS con Azure App Service (.NET 8 en Linux Tier F1), registro privado en Azure Container Registry (`acrrendobc01`) y despliegue de microservicios en contenedores.
- **`03-networking-security/`**: Redes Virtuales (`VNet-01` en `10.0.0.0/16`), segmentación de subredes (`Subnet-Frontend`, `Subnet-Backend`), Network Security Groups (NSG) con filtrado granular de puertos (80, 443, 22, 3389) e IP pública estática.
- **`04-retail-andes-data/`**: Pipeline de ingesta y orquestación ETL con Azure Data Factory (`adf-retail-andes-64808`) hacia Azure Data Lake Storage Gen2 (`stretailandes64808`) en formato columnar Apache Parquet para la capa *Bronze*.
- **`05-identity-keyvault-logicapps/`**: Gobernanza con grupos de seguridad en Microsoft Entra ID (`GRP_bootcamp_LEAD_UTP`), identidades administradas (`uami-storage-reader`) para acceso sin contraseñas (RBAC), Azure Key Vault (`kv-rendo-7935`) y flujos en Azure Logic Apps para auditoría de vencimiento de secretos.
- **`06-iac-bicep/`**: Infraestructura como Código modular en Azure Bicep (Log Analytics, Application Insights, UAMI y Key Vault) y publicación de módulos inmutables OCI en Azure Container Registry (`bicep/modules/monitoring:v1`).
- **`07-hero-agency-devops/`**: Aplicación web de votación en Node.js/Express, Dockerfile, pruebas unitarias automatizadas en Jest (6/6 pasadas) y pipeline multinivel en Azure Pipelines (`azure-pipelines.yml`) con 5 etapas: *Build*, *Test*, *Policies*, *Staging* y *Producción* con Health Check automatizado.
- **`08-agentic-ai-banking/`**: Sistema multi-agente para banca minorista (BCP / Banco ABC) orquestado con LangGraph:
  - *Commercial Matching Agent*: Scoring analítico de afinidad según perfil demográfico y transaccional.
  - *Brand RAG Engine*: Inyección de manual de marca y auditoría de cumplimiento normativo SBS.
  - *Creative Copy Agent*: Generación de correos, SMS, notificaciones push y prompts en inglés para modelos de visión (Flux.1, Nano Banana, Gemini Imagen 3).
  - *FastAPI Microservice*: Exposición de endpoints REST para integración de inferencia.
- **`report-latex/`**: Código fuente LaTeX en tipografía corporativa **Montserrat** y documento maestro compilado de 20 páginas: [`main.pdf`](report-latex/main.pdf).

---

## 🚀 Despliegue y Validación

Cada proyecto contiene su respectivo script Bash determinístico (`deploy_part0X.sh`) listo para ser ejecutado con Azure CLI:

```bash
# Ejemplo: Despliegue de IaC con Bicep
cd 06-iac-bicep && bash deploy_part06.sh

# Ejemplo: Ejecución de pruebas unitarias y construcción Docker
cd 07-hero-agency-devops && bash deploy_part07.sh

# Ejemplo: Ejecución del sistema multi-agente
cd 08-agentic-ai-banking && python3 test_flow.py
```
