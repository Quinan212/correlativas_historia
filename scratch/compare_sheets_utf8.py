import openpyxl
import sys

# Forzar salida UTF-8 para evitar errores de codificación en consola Windows
sys.stdout.reconfigure(encoding='utf-8')

file_path = r'C:\Users\alanm\Desktop\wqwe\Nueva carpeta\Mesas Extraordinarias de Mayo Ciclo 2026 (1).xlsx'

try:
    wb = openpyxl.load_workbook(file_path)
    
    for sheet_name in ['Mesas Trivunal', 'Coloquios']:
        ws = wb[sheet_name]
        print(f"\n=== DETALLES DE HOJA: {sheet_name} ===")
        print(f"Dimensiones: {ws.dimensions}")
        
        merged_cells = list(ws.merged_cells.ranges)
        print(f"Cantidad de rangos combinados: {len(merged_cells)}")
        
        count = 0
        for row in ws.iter_rows(min_row=1, max_row=40, min_col=1, max_col=15):
            row_vals = [str(cell.value) if cell.value is not None else "" for cell in row]
            if any(row_vals):
                print(f"Fila {row[0].row}: {' | '.join(row_vals)}")
                count += 1
            if count > 30: break

except Exception as e:
    print(f"Error: {e}")
