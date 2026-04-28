import os
import openpyxl

def find_file_and_sheets():
    search_paths = [
        r'C:\Users\alanm\Desktop',
        r'C:\Users\alanm\Downloads',
        r'C:\Users\alanm\Desktop\wqwe'
    ]
    
    print("--- Buscando archivos y sus hojas ---")
    for delta_path in search_paths:
        if not os.path.exists(delta_path):
            continue
        print(f"\nRevisando: {delta_path}")
        for file in os.listdir(delta_path):
            if file.lower().endswith(".xlsx") and "fwew" in file.lower():
                full_path = os.path.join(delta_path, file)
                try:
                    wb = openpyxl.load_workbook(full_path, read_only=True)
                    print(f"Archivo: {file} | Hojas: {wb.sheetnames}")
                    wb.close()
                except Exception as e:
                    print(f"Error leyendo {file}: {e}")

if __name__ == "__main__":
    find_file_and_sheets()
