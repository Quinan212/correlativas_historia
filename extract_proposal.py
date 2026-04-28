import fitz

# Extraer propuesta de cátedra completa
filepath = r"C:\Users\alanm\Desktop\MATERIAL\Propuesta de Cátedra PSPE YCA 2026.pdf"
doc = fitz.open(filepath)

# Guardar texto completo
with open("propuesta_catedra_extracted.txt", "w", encoding="utf-8") as f:
    for page_num in range(len(doc)):
        page = doc[page_num]
        text = page.get_text()
        f.write(f"\n{'='*60}\nPÁGINA {page_num + 1}\n{'='*60}\n\n")
        f.write(text)

doc.close()
print("Propuesta extraída a propuesta_catedra_extracted.txt")
