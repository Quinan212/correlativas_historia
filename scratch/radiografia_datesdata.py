import openpyxl
import sys

sys.stdout.reconfigure(encoding='utf-8')

file_path = r'C:\Users\alanm\Desktop\wqwe\Mesas Extraordinarias de Mayo Ciclo 2026 (2).xlsx'

try:
    wb = openpyxl.load_workbook(file_path, data_only=True)
    ws = wb['_DatesData']
    
    print("\n--- RADIOGRAFÍA DE _DATESDATA (Estructura Interna) ---")
    for r in range(1, 100):
        row_data = []
        for c in range(1, 20): # Ampliamos columnas
            val = ws.cell(row=r, column=c).value
            row_data.append(str(val) if val is not None else "")
        print(f"R{r}: " + " | ".join(row_data))

except Exception as e:
    print(f"Error: {e}")
