import srt
from deep_translator import GoogleTranslator
import time

def translate_srt(input_file, output_file, src_lang='sv', dest_lang='en'):
    with open(input_file, 'r', encoding='utf-8') as f:
        subs = list(srt.parse(f.read()))

    translator = GoogleTranslator(source=src_lang, target=dest_lang)
    
    translated_subs = []
    total = len(subs)
    
    print(f"Translating {total} subtitles...")
    
    for i, sub in enumerate(subs):
        if sub.content.strip():
            try:
                # Replace newlines with a placeholder to preserve them if needed, 
                # but deep-translator usually handles them okay.
                # However, for better results we can translate line by line or as a block.
                sub.content = translator.translate(sub.content)
            except Exception as e:
                print(f"Error translating sub {sub.index}: {e}")
                # Wait a bit and retry once
                time.sleep(2)
                try:
                    sub.content = translator.translate(sub.content)
                except:
                    pass 
        
        translated_subs.append(sub)
        
        if (i + 1) % 50 == 0:
            print(f"Processed {i + 1}/{total}...")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(srt.compose(translated_subs))

if __name__ == "__main__":
    translate_srt('swedish.srt', 'english.srt')
