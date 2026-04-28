import json
import re
import unicodedata

def normalize(s):
    return ''.join(c for c in unicodedata.normalize('NFD', s.lower())
                  if unicodedata.category(c) != 'Mn').replace('ñ', 'n')

# Found via web research
ADDRESSES = {
    "r1-casa-del-dr-pendola-diaz": "Güemes (entre San Luis y Entre Ríos)",
    "r1-casa-woolmer": "Mitre y D. P. Garat",
    "r1-casa-suburo": "Mitre 237",
    "r1-casa-masvernat": "Mitre 259",
    "r1-casa-dr-camano": "La Rioja y Mitre",
    "r1-casa-juan-antonio-castro": "Pellegrini y 3 de Febrero",
    "r1-casa-de-bernardino-horne": "Pellegrini 937",
    "r1-casa-artaghnan": "Entre Ríos y Avellaneda",
    "r1-casa-juana-c-de-salduna": "Urquiza 862",
    "r1-casa-dr-orlando-marcone": "V. Sarsfield y San Luis",
    "r1-casa-minones": "Urquiza 685",
    "r1-banco-popular-de-concordia": "Urquiza y Mitre",
    "r2-palacio-arruabarrena": "Entre Ríos y Ramírez",
    "r2-club-progreso": "Pellegrini 660",
}

def parse_heritage_data(ids_file, texts_file, urls_file):
    with open(ids_file, 'r', encoding='utf-8-sig') as f:
        ids = [line.strip() for line in f if line.strip()]

    with open(texts_file, 'r', encoding='utf-8-sig') as f:
        texts = [line.strip() for line in f if line.strip()]

    with open(urls_file, 'r', encoding='utf-8-sig') as f:
        urls = [line.strip() for line in f if line.strip()]

    data = {}
    for item_id in ids:
        name_parts = re.sub(r'^r\d-', '', item_id).split('-')
        display_name = ' '.join(name_parts).title()
        
        entry = {
            "id": item_id,
            "name": display_name,
            "address": ADDRESSES.get(item_id, ""),
            "description": "",
            "images": [],
            "audio": ""
        }

        norm_name = normalize(display_name).replace(' ', '')
        
        for url in urls:
            url_lower = url.lower()
            if "i.postimg.cc" in url_lower or "i.pinimg.com" in url_lower:
                filename = url_lower.split('/')[-1]
                if norm_name in filename.replace('-', '').replace('_', ''):
                    entry["images"].append(url)
                elif any(part in filename for part in normalize(display_name).split() if len(part) > 3):
                    if "casa" not in filename:
                         entry["images"].append(url)

        for i, line in enumerate(texts):
            if display_name.lower() in line.lower():
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
    
    output_path = f"{base_path}\\puntos_patrimoniales_v3.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False)
    
    print(f"Dataset v3 generado en: {output_path}")
