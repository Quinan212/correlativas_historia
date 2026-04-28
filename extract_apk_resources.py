import zipfile
import os
import shutil

# Archivos a extraer
apk_path = r"C:\Users\alanm\Downloads\378.apk"
output_dir = r"C:\Users\alanm\Desktop\recorridos_patrimoniales_extracted"

# Crear carpeta de salida
if os.path.exists(output_dir):
    shutil.rmtree(output_dir)
os.makedirs(output_dir)

print(f"Extrayendo recursos de: {apk_path}")
print(f"Destino: {output_dir}")

with zipfile.ZipFile(apk_path, 'r') as zip_ref:
    file_list = zip_ref.namelist()
    
    # Categorías de archivos a extraer
    categories = {
        'assets': [],
        'res': [],
        'lib': [],
        'root': []
    }
    
    for file in file_list:
        if file.startswith('assets/'):
            categories['assets'].append(file)
        elif file.startswith('res/'):
            categories['res'].append(file)
        elif file.startswith('lib/'):
            categories['lib'].append(file)
        else:
            categories['root'].append(file)
    
    print(f"\nTotal de archivos: {len(file_list)}")
    print(f"- assets/: {len(categories['assets'])}")
    print(f"- res/: {len(categories['res'])}")
    print(f"- lib/: {len(categories['lib'])}")
    print(f"- root/: {len(categories['root'])}")
    
    # Extraer todo
    zip_ref.extractall(output_dir)
    
    # Guardar lista de archivos
    with open(os.path.join(output_dir, "file_list.txt"), "w", encoding="utf-8") as f:
        f.write(f"APK: {apk_path}\n")
        f.write(f"Total archivos: {len(file_list)}\n\n")
        
        for cat, files in categories.items():
            f.write(f"\n=== {cat}/ ({len(files)} files) ===\n")
            for file in sorted(files):
                f.write(f"{file}\n")

print(f"\n✅ Extracción completa!")
print(f"Archivos guardados en: {output_dir}")
print(f"\nLista de archivos en: {os.path.join(output_dir, 'file_list.txt')}")
