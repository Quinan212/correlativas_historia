import fitz

# Extraer ambos PDFs
files = [
    r"C:\Users\alanm\Desktop\MATERIAL\fdocuments.ec_resolucion-1888-07-ayudante-de-catedra.pdf",
    r"C:\Users\alanm\Desktop\MATERIAL\Steiman_Mas_Didactica_Nivel_Superior.pdf"
]

output = []
for filepath in files:
    output.append(f"\n{'='*80}")
    output.append(f"ARCHIVO: {filepath}")
    output.append('='*80)
    try:
        doc = fitz.open(filepath)
        for page_num in range(len(doc)):
            page = doc[page_num]
            text = page.get_text()
            output.append(f"\n--- Página {page_num + 1} ---")
            output.append(text)
        doc.close()
    except Exception as e:
        output.append(f"Error: {e}")

with open("ayudante_steiman_extracted.txt", "w", encoding="utf-8") as f:
    f.write('\n'.join(output))
print("Extraído a ayudante_steiman_extracted.txt")
