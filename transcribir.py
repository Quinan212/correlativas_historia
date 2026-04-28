import whisper
import warnings
import os
import sys

# Ignorar advertencias de FP16 si usas CPU
warnings.filterwarnings("ignore", message="FP16 is not supported on CPU; using FP32 instead")

def transcribir_audio(ruta_audio):
    # Verificar si el archivo existe
    if not os.path.exists(ruta_audio):
        print(f"\nError: No se encontró el archivo '{ruta_audio}'.")
        print("Asegurate de que el archivo esté en la misma carpeta que este script.")
        return

    # Usar GPU si está disponible (tienes una RTX 4060)
    import torch
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"\nDispositivo detectado: {device.upper()}")
    if device == "cuda":
        print(f"Usando potencia de tu NVIDIA RTX 4060 para transcribir... mucho más rápido.")

    print("\nCargando el modelo Whisper (esto puede tardar unos segundos)...")
    # El modelo 'base' es rápido. Podés cambiarlo a 'medium' para más precisión.
    modelo = whisper.load_model("base", device=device) 
    
    print(f"Transcribiendo: {ruta_audio}...")
    print("Por favor, esperá. Este proceso consume recursos de tu PC.")
    
    # El proceso de transcripción
    # Especificamos language='es' para forzar español si es necesario
    try:
        resultado = modelo.transcribe(ruta_audio, verbose=False)
        texto_transcrito = resultado["text"]
        
        # Guardar el resultado en un archivo de texto con el mismo nombre que el audio
        nombre_base = os.path.splitext(ruta_audio)[0]
        nombre_archivo_salida = f"transcripcion_{nombre_base}.txt"
        
        with open(nombre_archivo_salida, "w", encoding="utf-8") as archivo:
            archivo.write(texto_transcrito)
            
        print(f"\n¡Éxito! La transcripción se guardó en: {nombre_archivo_salida}")
    except Exception as e:
        print(f"\nOcurrió un error hardware/software: {e}")

if __name__ == "__main__":
    # Si el usuario pasa un archivo por argumento, lo usamos.
    # Si no, buscamos el primer archivo de audio que encontremos.
    if len(sys.argv) > 1:
        archivo_a_procesar = sys.argv[1]
    else:
        # Buscar archivos comunes de audio en la carpeta
        extensiones = ('.mp3', '.wav', '.m4a', '.mp4', '.aac')
        archivos = [f for f in os.listdir('.') if f.lower().endswith(extensiones)]
        
        if archivos:
            archivo_a_procesar = archivos[0]
            print(f"No se especificó archivo. Procesando el primero que encontré: {archivo_a_procesar}")
        else:
            print("No encontré ningún archivo de audio (.mp3, .wav, etc.) en esta carpeta.")
            print("Uso: python transcribir.py nombre_del_audio.mp3")
            sys.exit(1)
            
    transcribir_audio(archivo_a_procesar)
