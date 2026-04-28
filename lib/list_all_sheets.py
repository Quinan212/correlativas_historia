import openpyxl, os

carpeta = r'C:\Users\alanm\Desktop\wqwe\Nueva carpeta'
archivos = [f for f in os.listdir(carpeta) if f.endswith('.xlsx')]

for archivo in archivos:
    ruta = os.path.join(carpeta, archivo)
    try:
        wb = openpyxl.load_workbook(ruta, read_only=True)
        print(f"Archivo: {archivo} | Hojas: {wb.sheetnames}")
        wb.close()
    except:
        continue
