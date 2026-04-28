import json
import re
import unicodedata

def normalize(s):
    return ''.join(c for c in unicodedata.normalize('NFD', s.lower())
                  if unicodedata.category(c) != 'Mn').replace('ñ', 'n')

def parse_heritage_data(ids_file, texts_file, urls_file):
    # Handle BOM by using utf-8-sig
    with open(ids_file, 'r', encoding='utf-8-sig') as f:
        ids = [line.strip() for line in f if line.strip()]

    with open(texts_file, 'r', encoding='utf-8-sig') as f:
        texts = [line.strip() for line in f if line.strip()]

    with open(urls_file, 'r', encoding='utf-8-sig') as f:
        urls = [line.strip() for line in f if line.strip()]

    data = {}
    for item_id in ids:
        # Simplify ID for matching (remove 'r1-', 'r2-', etc)
        name_parts = re.sub(r'^r\d-', '', item_id).split('-')
        display_name = ' '.join(name_parts).title()
        
        entry = {
            "id": item_id,
            "name": display_name,
            "description": "",
            "images": [],
            "audio": ""
        }

        norm_name = normalize(display_name).replace(' ', '')
        
        # 1. Match Images (Postimg & Pinterest)
        for url in urls:
            url_lower = url.lower()
            # Postimg files often have bits of the name
            if "i.postimg.cc" in url_lower or "i.pinimg.com" in url_lower:
                filename = url_lower.split('/')[-1]
                # If name is in filename (e.g. "camano" in "casa-dr-cama-o.jpg")
                if norm_name in filename.replace('-', '').replace('_', ''):
                    entry["images"].append(url)
                elif any(part in filename for part in normalize(display_name).split() if len(part) > 3):
                    # Partial match for longer words
                    if "casa" not in filename: # exclude generic "casa"
                         entry["images"].append(url)

        # 2. Extract Description (Fuzzy)
        # We look for lines in texts that mention the name or appear near it
        for i, line in enumerate(texts):
            if display_name.lower() in line.lower():
                # Found a mention. Let's grab some context.
                # Usually descriptions follow the name or contain it.
                context = []
                for j in range(max(0, i-1), min(len(texts), i+5)):
                    if len(texts[j]) > 30 and "r1-" not in texts[j] and "r2-" not in texts[j]:
                        context.append(texts[j])
                if context:
                    entry["description"] = " ".join(context)
                    break

        data[item_id] = entry

    return data

if __name__ == "__main__":
    base_path = r"C:\Users\alanm\Desktop\378_extraido"
    ids_p = f"{base_path}\\ids_puntos_40.txt"
    texts_p = f"{base_path}\\texto_espanol_relevante.txt"
    urls_p = f"{base_path}\\urls_encontradas.txt"
    
    result = parse_heritage_data(ids_p, texts_p, urls_p)
    
    output_path = f"{base_path}\\puntos_patrimoniales_v2.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    
    print(f"Dataset v2 generado en: {output_path}")
