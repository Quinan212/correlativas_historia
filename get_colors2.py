import os
from PIL import Image
from collections import Counter

# Find the latest folder matching ??? or containing .png files
base_dir = r"C:\Users\alanm\Downloads"
target_dir = None
for root, dirs, files in os.walk(base_dir):
    if "1.png" in files and "10.png" in files:
        target_dir = root
        break

if target_dir:
    img_path = os.path.join(target_dir, "1.png")
    try:
        img = Image.open(img_path)
        img = img.convert('RGB')
        img.thumbnail((100, 100))
        pixels = list(img.getdata())
        counts = Counter(pixels)
        print("Colors in 1.png:", counts.most_common(5))
    except Exception as e:
        print(e)
else:
    print("Could not find the images.")
