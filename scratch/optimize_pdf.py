import fitz
import os

def optimize_pdf(input_path, output_path):
    print(f"Abriendo {input_path}...")
    doc = fitz.open(input_path)
    
    # Optimizamos guardando con ajustes que reducen el tamaño
    # garbage=4: elimina todo lo redundante y limpia enlaces
    # deflate=True: comprime corrientes de datos
    # clean=True: intenta sanear la estructura interna
    print("Guardando versión optimizada (esto puede tardar un momento)...")
    doc.save(output_path, garbage=4, deflate=True, clean=True)
    doc.close()
    
    initial_size = os.path.getsize(input_path) / (1024 * 1024)
    final_size = os.path.getsize(output_path) / (1024 * 1024)
    print(f"Tamaño original: {initial_size:.2f} MB")
    print(f"Tamaño optimizado: {final_size:.2f} MB")
    print(f"Reducción: {((initial_size - final_size) / initial_size) * 100:.2f}%")

if __name__ == "__main__":
    desktop_path = os.path.join(os.environ['USERPROFILE'], 'Desktop')
    input_file = os.path.join(desktop_path, 'tomo1.pdf')
    output_file = os.path.join(desktop_path, 'tomo1_ligero.pdf')
    
    optimize_pdf(input_file, output_file)
