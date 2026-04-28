import fitz
import os

def count_images(file_path):
    doc = fitz.open(file_path)
    img_count = 0
    for page in doc:
        img_count += len(page.get_images())
    doc.close()
    return img_count

if __name__ == "__main__":
    desktop_path = os.path.join(os.environ['USERPROFILE'], 'Desktop')
    input_file = os.path.join(desktop_path, 'tomo1.pdf')
    count = count_images(input_file)
    print(f"Total imágenes: {count}")
