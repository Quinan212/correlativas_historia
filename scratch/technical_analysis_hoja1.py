import openpyxl

def detailed_analysis():
    file_path = r'C:\Users\alanm\Desktop\wqwe\fwew.xlsx'
    wb = openpyxl.load_workbook(file_path)
    sheet = wb['Sheet1'] # This is Hoja1
    
    print("--- ANÁLISIS TÉCNICO DE HOJA1 ---")
    
    # 1. Measurement of Columns
    cols_to_check = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N']
    for col in cols_to_check:
        width = sheet.column_dimensions[col].width
        print(f"Columna {col}: Ancho = {width if width else 'Default (8.43)'}")
        
    # 2. Measurement of Rows in a block
    # A block seems to be Rows 3 to 7
    rows_to_check = range(3, 10)
    for r in rows_to_check:
        height = sheet.row_dimensions[r].height
        print(f"Fila {r}: Alto = {height if height else 'Default (15)'}")
        
    # 3. Text Sizes in specific cells
    # Row 3 Col D: Subject Name
    # Row 4 Col D: Year
    # Row 5 Col D: Call
    # Row 5 Col N: Countdown
    # Row 6 Col L: Date
    # Row 7 Col L: Time
    
    samples = [
        (3, 4, "Nombre Materia"),
        (4, 4, "Año/Tipo"),
        (5, 4, "Llamado"),
        (6, 4, "Docente"),
        (6, 12, "Fecha"),
        (7, 12, "Hora"),
        (5, 14, "Countdown")
    ]
    
    for r, c, label in samples:
        cell = sheet.cell(row=r, column=c)
        font = cell.font
        print(f"[{label}] (R{r}C{c}): Font Size = {font.sz}, Bold = {font.b}, Value = '{cell.value}'")

if __name__ == "__main__":
    detailed_analysis()
