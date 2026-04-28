from PIL import Image
import os
from collections import Counter

def get_dominant_colors(image_path, num_colors=3):
    try:
        img = Image.open(image_path)
        img = img.convert('RGB')
        # Resize to speed up
        img.thumbnail((100, 100))
        pixels = list(img.getdata())
        counts = Counter(pixels)
        return counts.most_common(num_colors)
    except Exception as e:
        return str(e)

folder = [f for f in os.listdir(r'C:\Users\alanm\Downloads') if os.path.isdir(os.path.join(r'C:\Users\alanm\Downloads', f))][0]
img_path = os.path.join(r'C:\Users\alanm\Downloads', folder, '1.png')
print("Colors in 1.png:", get_dominant_colors(img_path))
