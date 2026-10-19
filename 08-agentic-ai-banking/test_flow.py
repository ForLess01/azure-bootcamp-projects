#!/usr/bin/env python3
"""
==============================================================================
PROYECTO 8: Script de Prueba End-to-End del Sistema Agéntico
==============================================================================
"""

import json
import os
import sys

current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

from agents.workflow import BankingCampaignWorkflow

def main():
    print("=" * 80)
    print("SISTEMA AGÉNTICO MULTI-AGENTE DE CAMPAÑAS BANCARIAS (BCP / BANCO ABC)")
    print("=" * 80)

    workflow = BankingCampaignWorkflow()

    customers_path = os.path.join(current_dir, "data", "sample_customers.json")
    with open(customers_path, "r", encoding="utf-8") as f:
        customers = json.load(f)

    for i, customer in enumerate(customers, 1):
        print(f"\n[CLIENTE {i}/3]: {customer['first_name']} {customer['last_name']} (DNI: {customer['dni']})")
        print(f"  • Segmento: {customer['banking_segment']} | Ingreso: S/ {customer['monthly_income']:,.2f}")
        print(f"  • Estado Civil: {customer['marital_status']} | Hijos: {customer['children']}")
        print(f"  • Hábitos: {', '.join(customer['primary_spending_categories'])}")
        
        result = workflow.run_pipeline(customer)

        print("\n  >> [AGENTE 1: MATCHING COMERCIAL] Top 3 Campañas Seleccionadas:")
        for idx, camp in enumerate(result["matched_campaigns"], 1):
            print(f"     {idx}. {camp['name']} (Score Afinidad: {camp['affinity_score']}/100)")

        print("\n  >> [AGENTE 2: REDACTOR CREATIVO & PROMPTER] Muestra de Piezas:")
        lead_creative = result["creatives"][0]
        print(f"     [EMAIL]")
        print(f"       Asunto:    {lead_creative['email']['subject']}")
        print(f"       Preheader: {lead_creative['email']['preheader']}")
        print(f"     [SMS]")
        print(f"       Texto:     {lead_creative['sms']}")
        print(f"     [PUSH]")
        print(f"       Notif:     {lead_creative['push_notification']['title']} - {lead_creative['push_notification']['body']}")
        print(f"     [GENERATIVE VISION PROMPT]")
        print(f"       Modelo:    {lead_creative['image_generation_prompt']['model_compatibility']}")
        print(f"       Prompt EN: {lead_creative['image_generation_prompt']['prompt_en']}")

        print(f"\n  >> [COMPLIANCE SBS / AUDITOR]: Estado {result['pipeline_status']} (Violaciones: {len(result['compliance_audit']['violations'])})")
        print("-" * 80)

if __name__ == "__main__":
    main()
