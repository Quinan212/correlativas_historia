import pandas as pd
import os

def read_excel():
    file_path = r'C:\Users\alanm\Desktop\wqwe\eqwewq.xlsx'
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return

    try:
        # Load the excel file
        xl = pd.ExcelFile(file_path)
        print(f"Sheets: {xl.sheet_names}")
        
        for sheet_name in xl.sheet_names:
            print(f"\n--- Sheet: {sheet_name} ---")
            df = xl.parse(sheet_name)
            print(df.head(20).to_string())
    except Exception as e:
        print(f"Error reading excel: {e}")

if __name__ == "__main__":
    read_excel()
