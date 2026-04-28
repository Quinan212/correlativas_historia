import fitz # PyMuPDF
import sys
try:
    doc = fitz.open(r'C:\Users\alanm\Downloads\guia (1).pdf')
    text = ''
    for page in doc:
        text += page.get_text()
    print(text)
except ImportError:
    import PyPDF2
    with open(r'C:\Users\alanm\Downloads\guia (1).pdf', 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        for page in reader.pages:
            print(page.extract_text())
