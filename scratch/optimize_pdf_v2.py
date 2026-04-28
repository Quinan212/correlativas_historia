import fitz
import os

def aggressive_optimize(input_path, output_path):
    print(f"Abriendo {input_path} para optimización agresiva...")
    doc = fitz.open(input_path)
    
    # Intentamos una compresión más fuerte
    # linear=True: permite que el PDF se empiece a cargar antes de terminar de descargarse/leerse (bueno para visualizadores)
    # expand=False: evita expandir objetos
    print("Comprimiendo imágenes y limpiando estructura...")
    doc.save(output_path, 
             garbage=4, 
             deflate=True, 
             clean=True, 
             linear=True)
    doc.close()
    
    initial_size = os.path.getsize(input_path) / (1024 * 1024)
    final_size = os.path.getsize(output_path) / (1024 * 1024)
    print(f"Tamaño original: {initial_size:.2f} MB")
    print(f"Tamaño ligero: {final_size:.2f} MB")

if __name__ == "__main__":
    desktop_path = os.path.join(os.environ['USERPROFILE'], 'Desktop')
    input_file = os.path.join(desktop_path, 'tomo1.pdf')
    output_file = os.path.join(desktop_path, 'tomo1_ultra_ligero.pdf')
    
    aggressive_optimize(input_file, output_file)
