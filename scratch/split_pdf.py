import fitz
import os

def split_pdf(input_path, output_dir, pages_per_part=200):
    doc = fitz.open(input_path)
    total_pages = len(doc)
    
    for i in range(0, total_pages, pages_per_part):
        start = i
        end = min(i + pages_per_part, total_pages)
        part_num = (i // pages_per_part) + 1
        output_filename = os.path.join(output_dir, f"tomo1_parte{part_num}.pdf")
        
        print(f"Creando parte {part_num} (páginas {start+1} a {end})...")
        new_doc = fitz.open()
        new_doc.insert_pdf(doc, from_page=start, to_page=end-1)
        new_doc.save(output_filename, garbage=4, deflate=True)
        new_doc.close()
    
    doc.close()

if __name__ == "__main__":
    desktop_path = os.path.join(os.environ['USERPROFILE'], 'Desktop')
    input_file = os.path.join(desktop_path, 'tomo1.pdf')
    # Creamos una carpeta para no llenar el escritorio de archivos
    output_folder = os.path.join(desktop_path, 'tomo1_partes')
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    split_pdf(input_file, output_folder)
