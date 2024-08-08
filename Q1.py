import json
from collections import Counter

def word_count(txt):
    words = txt.split()
    return dict(Counter(words))

def save_to_json(data, filename):
    with open(filename, 'w') as f:
        json.dump(data, f)

def gen_file(data, current=1, max_files=100):
    if current>max_files:
        return
    filename = f'file_{current}.json'
    save_to_json(data, filename)
    gen_file(data, current+1, max_files)

txt = "Hello. I am a Data Engineer"
data = word_count(txt)
save_to_json(data, 'word_count.json')
gen_file(data)
