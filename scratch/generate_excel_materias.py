import json
import pandas as pd

def generate_excel():
    paths = {
        'Historia': r'C:\Users\alanm\StudioProjects\correlativas_historia\assets\data\historia.json',
        'Geografía': r'C:\Users\alanm\StudioProjects\correlativas_historia\assets\data\geografia.json',
        'Ciencias Políticas': r'C:\Users\alanm\StudioProjects\correlativas_historia\assets\data\politica.json'
    }
    
    output_file = r'C:\Users\alanm\StudioProjects\correlativas_historia\scratch\Lista_Materias_Profesorados.xlsx'
    
    with pd.ExcelWriter(output_file, engine='openpyxl') as writer:
        for career, path in paths.items():
            with open(path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                materias = data.get('materias', [])
                
                # Extract relevant fields
                df_data = []
                for m in materias:
                    df_data.append({
                        'Año': m.get('año') or m.get('anio'),
                        'Materia': m.get('nombre'),
                        'Tipo/Formato': m.get('formato'),
                        'Categoría': m.get('tipo'),
                        'Horas': m.get('horas'),
                        'Código': m.get('codigo')
                    })
                
                df = pd.DataFrame(df_data)
                
                # Sort by year
                df = df.sort_values(by=['Año', 'Materia'])
                
                # Write to sheet
                df.to_excel(writer, sheet_name=career[:31], index=False)
                
                # Adjust column widths
                worksheet = writer.sheets[career[:31]]
                for idx, col in enumerate(df.columns):
                    max_len = max(df[col].astype(str).map(len).max(), len(col)) + 2
                    worksheet.column_dimensions[chr(65+idx)].width = min(max_len, 50)

    print(f"Excel file generated at: {output_file}")

if __name__ == "__main__":
    generate_excel()
