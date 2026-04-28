import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

try:
    with open('scratch/full_excel_audit_v2.json', 'r', encoding='utf-8') as f:
        audit = json.load(f)
    
    # 1. Materias en Data (Hoja Maestra)
    data_subjects = {}
    for i, r in enumerate(audit['_DatesData']):
        if len(r) > 6 and r[6].strip():
            nombre = r[6].strip()
            data_subjects[nombre] = {"row": i+1, "anio": r[5]}
            
    # 2. Materias ya ubicadas en Dashboard (Mesas Trivunal)
    placed_in_mesas = []
    for i, r in enumerate(audit['Mesas Trivunal']):
        for cell_val in r:
            if cell_val.strip() in data_subjects:
                placed_in_mesas.append(cell_val.strip())
                
    # 3. Materias ya ubicadas en Coloquios
    placed_in_coloquios = []
    for i, r in enumerate(audit['Coloquios']):
        for cell_val in r:
            if cell_val.strip() in data_subjects:
                placed_in_coloquios.append(cell_val.strip())
                
    # 4. Materias "Huérfanas" (están en data pero no en el dashboard)
    missing_mesas = [s for s in data_subjects if s not in placed_in_mesas]
    missing_coloquios = [s for s in data_subjects if s not in placed_in_coloquios]

    print("\n--- MATERIAS QUE FALTA UBICAR EN MESAS ---")
    for m in missing_mesas: print(f"⚠️ {m} (Año: {data_subjects[m]['anio']})")

    print("\n--- MATERIAS QUE FALTA UBICAR EN COLOQUIOS ---")
    for m in missing_coloquios: print(f"⚠️ {m} (Año: {data_subjects[m]['anio']})")

except Exception as e:
    print(f"Error: {e}")
