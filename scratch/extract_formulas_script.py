import openpyxl
import sys

sys.stdout.reconfigure(encoding='utf-8')

file_path = r'C:\Users\alanm\Desktop\wqwe\Mesas Extraordinarias de Mayo Ciclo 2026 (2).xlsx'

try:
    wb = openpyxl.load_workbook(file_path) # NO data_only=True para ver FÓRMULAS
    ws = wb['Mesas Trivunal']
    
    print("\n--- MOLDE DE FUNCIONES (Bloque de Didáctica General) ---")
    cells = ['D6','D7','J7','L8','L9','L10','N8','D9','G9']
    for c in cells:
        val = ws[c].value
        print(f"Celda {c}: {val}")

except Exception as e:
    print(f"Error: {e}")
