import pandas as pd

def inspect_definitive():
    file_path = r'C:\Users\alanm\Desktop\AYUDANTIA\Calendario_Operativo_Preceptores_FINAL_VERDADERO.xlsx'
    xl = pd.ExcelFile(file_path)
    print(f"Sheets: {xl.sheet_names}")
    
    # Common sheet names for definitive data
    target_sheets = [s for s in xl.sheet_names if 'DOCENTE' in s.upper() or 'LISTA' in s.upper() or 'FINAL' in s.upper()]
    
    for sheet in target_sheets:
        print(f"\n--- Sheet: {sheet} ---")
        df = xl.parse(sheet)
        print(df.head(10).to_string())

if __name__ == "__main__":
    inspect_definitive()
