import fitz
import os

def check_pdf(file_path):
    doc = fitz.open(file_path)
    print(f"Páginas: {len(doc)}")
    doc.close()

if __name__ == "__main__":
    desktop_path = os.path.join(os.environ['USERPROFILE'], 'Desktop')
    check_pdf(os.path.join(desktop_path, 'tomo1.pdf'))
