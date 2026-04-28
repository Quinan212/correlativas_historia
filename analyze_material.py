import fitz  # PyMuPDF
import os
from pathlib import Path

def extract_full_pdf_text(filepath, max_pages=None):
    """Extrae texto completo de un PDF"""
    try:
        doc = fitz.open(filepath)
        pages_to_read = max_pages if max_pages else len(doc)
        text_parts = []
        for page_num in range(min(pages_to_read, len(doc))):
            page = doc[page_num]
            text = page.get_text()
            if text.strip():
                text_parts.append(f"--- Página {page_num + 1} ---\n{text}")
        doc.close()
        return '\n'.join(text_parts)
    except Exception as e:
        return f"Error: {str(e)}"

def extract_pdf_info(filepath):
    """Extrae información básica de un PDF"""
    try:
        doc = fitz.open(filepath)
        info = {
            'title': doc.metadata.get('title', ''),
            'author': doc.metadata.get('author', ''),
            'subject': doc.metadata.get('subject', ''),
            'pages': len(doc),
            'filename': os.path.basename(filepath),
            'size_kb': os.path.getsize(filepath) / 1024
        }
        doc.close()
        return info
    except Exception as e:
        return {'filename': os.path.basename(filepath), 'error': str(e), 'pages': 0}

def analyze_catedra_proposal():
    """Analiza la propuesta de cátedra en detalle"""
    filepath = r"C:\Users\alanm\Desktop\MATERIAL\Propuesta de Cátedra PSPE YCA 2026.pdf"
    print("="*80)
    print("PROPUESTA DE CÁTEDRA PSPE YCA 2026")
    print("="*80)
    text = extract_full_pdf_text(filepath)
    print(text)
    return text

def analyze_by_section(base_path):
    """Analiza el material por secciones temáticas"""
    sections = {
        'Núcleo Introductorio': [],
        'Cercano Oriente': [],
        'Grecia y Roma': [],
        'Lejano Oriente': []
    }
    
    root = Path(base_path)
    
    for section in sections.keys():
        section_path = root / section
        if section_path.exists():
            for f in section_path.glob('*.pdf'):
                info = extract_pdf_info(str(f))
                # Extraer algunas páginas para preview
                preview = extract_full_pdf_text(str(f), max_pages=2)[:800]
                sections[section].append({
                    'file': f.name,
                    'info': info,
                    'preview': preview
                })
    
    return sections

def count_totals(base_path):
    """Cuenta estadísticas totales"""
    root = Path(base_path)
    total_pdfs = 0
    total_pages = 0
    total_size_mb = 0
    
    # PDF en raíz
    for f in root.glob('*.pdf'):
        total_pdfs += 1
        total_pages += extract_pdf_info(str(f)).get('pages', 0)
        total_size_mb += os.path.getsize(str(f)) / (1024 * 1024)
    
    # PDF en subcarpetas
    for subfolder in ['Núcleo Introductorio', 'Cercano Oriente', 'Grecia y Roma', 'Lejano Oriente']:
        subfolder_path = root / subfolder
        if subfolder_path.exists():
            for f in subfolder_path.glob('*.pdf'):
                total_pdfs += 1
                total_pages += extract_pdf_info(str(f)).get('pages', 0)
                total_size_mb += os.path.getsize(str(f)) / (1024 * 1024)
    
    return total_pdfs, total_pages, total_size_mb

if __name__ == '__main__':
    base = r"C:\Users\alanm\Desktop\MATERIAL"
    
    # Análisis de la propuesta de cátedra
    proposal_text = analyze_catedra_proposal()
    
    print("\n\n")
    print("="*80)
    print("ANÁLISIS POR SECCIONES")
    print("="*80)
    
    sections = analyze_by_section(base)
    
    for section, materials in sections.items():
        print(f"\n\n{'='*40}")
        print(f"📂 {section.upper()}")
        print(f"{'='*40}")
        total_pages = sum(m['info'].get('pages', 0) for m in materials)
        print(f"Total de materiales: {len(materials)}, Páginas totales: {total_pages}\n")
        
        for i, mat in enumerate(materials, 1):
            print(f"{i}. {mat['file']}")
            print(f"   Páginas: {mat['info'].get('pages', 0)} | Tamaño: {mat['info'].get('size_kb', 0):.1f} KB")
            preview = mat['preview'][:300].replace('\n', ' ').strip()
            print(f"   Contenido: {preview}...")
            print()
    
    # Totales
    print("\n\n")
    print("="*80)
    print("RESUMEN ESTADÍSTICO TOTAL")
    print("="*80)
    total_pdfs, total_pages, total_size_mb = count_totals(base)
    print(f"Total de archivos PDF: {total_pdfs}")
    print(f"Total de páginas: {total_pages}")
    print(f"Tamaño total: {total_size_mb:.2f} MB")


