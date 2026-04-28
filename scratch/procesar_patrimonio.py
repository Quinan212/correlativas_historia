import json
import re

def parse_heritage_data(ids_file, texts_file, urls_file):
    with open(ids_file, 'r', encoding='utf-8') as f:
        ids = [line.strip() for line in f if line.strip()]

    with open(texts_file, 'r', encoding='utf-8') as f:
        texts = f.readlines()

    with open(urls_file, 'r', encoding='utf-8') as f:
        urls = [line.strip() for line in f if line.strip()]

    data = {}
    for item_id in ids:
        # Simplify ID for matching (remove 'r1-', 'r2-', etc)
        simple_id = re.sub(r'^r\d-', '', item_id).replace('-', ' ')
        
        data[item_id] = {
            "id": item_id,
            "name": simple_id.title(),
            "description": "",
            "images": [],
            "audio": ""
        }

        # Try to find images in postimg URLs
        for url in urls:
            if "i.postimg.cc" in url:
                # Basic fuzzy match between name and filename
                filename = url.split('/')[-1].lower()
                clean_name = simple_id.replace(' ', '').lower()
                
                # Check for direct match or partial match
                if clean_name in filename or filename in clean_name:
                    data[item_id]["images"].append(url)

    # Try to extract audio ID if there's only one interesting drive URL
    # or if we find a mapping logic. For now, let's just list the main one found in analysis.
    audio_id = "1YOZNGs9p7ejUS6WAgPcsnG_bNpUs83Wx" # Found in urls_encontradas.txt

    return data

if __name__ == "__main__":
    base_path = r"C:\Users\alanm\Desktop\378_extraido"
    ids_p = f"{base_path}\\ids_puntos_40.txt"
    texts_p = f"{base_path}\\texto_espanol_relevante.txt"
    urls_p = f"{base_path}\\urls_encontradas.txt"
    
    result = parse_heritage_data(ids_p, texts_p, urls_p)
    
    output_path = f"{base_path}\\puntos_patrimoniales_v1.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    
    print(f"Dataset preliminar generado en: {output_path}")
