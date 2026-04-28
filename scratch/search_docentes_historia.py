import os
import pandas as pd
import glob

def search_docentes():
    desktop_path = r'C:\Users\alanm\Desktop\AYUDANTIA'
    files = glob.glob(os.path.join(desktop_path, "*.xlsx"))
    
    results = []
    
    for file in files:
        try:
            xl = pd.ExcelFile(file)
            for sheet in xl.sheet_names:
                df = xl.parse(sheet)
                # Search for keywords in the dataframe
                contains_historia = df.stack().astype(str).str.contains("Historia", case=False).any()
                contains_docente = df.stack().astype(str).str.contains("Docente|Profesor|Prof", case=False).any()
                
                if contains_historia and contains_docente:
                    results.append((file, sheet))
                    print(f"Match found in: {file} [Sheet: {sheet}]")
        except Exception as e:
            # Skip files that are open or encrypted
            continue
            
    if not results:
        print("No matches found.")

if __name__ == "__main__":
    search_docentes()
