import openpyxl

file_path = r'C:\Users\alanm\Desktop\wqwe\Nueva carpeta\Mesas Extraordinarias de Mayo Ciclo 2026 (1).xlsx'

try:
    wb = openpyxl.load_workbook(file_path)
    
    for sheet_name in ['HOJA 1', 'Coloquios']:
        ws = wb[sheet_name]
        print(f"\n=== DETALLES DE HOJA: {sheet_name} ===")
        print(f"Dimensiones: {ws.dimensions}")
        
        # Verificamos si hay celdas combinadas (que indican bloques)
        merged_cells = list(ws.merged_cells.ranges)
        print(f"Cantidad de rangos combinados: {len(merged_cells)}")
        
        # Leemos las primeras 20 celdas con contenido
        print("Contenido de las primeras filas:")
        count = 0
        for row in ws.iter_rows(min_row=1, max_row=40, min_col=1, max_col=10):
            row_vals = [str(cell.value) if cell.value is not None else "" for cell in row]
            if any(row_vals):
                print(f"Fila {row[0].row}: {' | '.join(row_vals)}")
                count += 1
            if count > 20: break

except Exception as e:
    print(f"Error: {e}")
