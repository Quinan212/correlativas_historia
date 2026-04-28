import openpyxl
import sys

sys.stdout.reconfigure(encoding='utf-8')

file_path = r'C:\Users\alanm\Desktop\wqwe\Mesas Extraordinarias de Mayo Ciclo 2026 (2).xlsx'

try:
    wb = openpyxl.load_workbook(file_path)
    
    for sn in ['Mesas Trivunal', 'Coloquios']:
        ws = wb[sn]
        print(f"\n--- FORMATO CONDICIONAL EN {sn} ---")
        for cf in ws.conditional_formatting:
            print(f"Rango: {cf.sqref}")
            for rule in cf.rules:
                print(f"  Tipo: {rule.type}")
                if rule.formula:
                    print(f"  Fórmula: {rule.formula}")
                if rule.dxfId:
                    print(f"  Estilo (dxfId): {rule.dxfId}")

except Exception as e:
    print(f"Error: {e}")
