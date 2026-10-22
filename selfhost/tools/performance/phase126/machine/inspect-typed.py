#!/usr/bin/env python3
"""Read-only QBE text accounting; never executes or compiles a target."""
import argparse, hashlib, json, re
from pathlib import Path

def decode(text):
    return re.sub(r'FID_((?:\d+_)+)', lambda m: ''.join(chr(int(v)) for v in m[1].split('_') if v), text)

def inspect(path):
    text = path.read_text()
    rows = []
    for match in re.finditer(r'^(?:export )?function\s+(\w+)\s+\$(\S+)\(([^\n]*)\)\s*\{\n(.*?)^\}\s*$', text, re.M | re.S):
        result, encoded, formals, body = match.groups()
        name = decode(encoded)
        floats = re.findall(r'(?:^|, )s (%[^, ]+)', formals)
        if not (name.startswith('p126_typed_') or any(x in name for x in ('isect5', 'nearest', 'recurrence'))):
            continue
        rows.append({
            'name': name, 'return': result, 'formals': decode(formals),
            'float_formal_count': len(floats), 'float_formals': list(map(decode, floats)),
            'body_lines': len(body.splitlines()),
            'word_to_float_casts': len(re.findall(r'=s cast ', body)),
            'float_to_word_casts': len(re.findall(r'=w cast ', body)),
            'calls': [decode(x.strip()) for x in body.splitlines() if ' call $' in x],
            'allocations': [x.strip() for x in body.splitlines() if ' alloc' in x],
            'backedge_jumps': len(re.findall(r'^jmp @p113_loop$', body, re.M)),
        })
    return {'path': str(path.resolve()), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(), 'functions': rows}

parser = argparse.ArgumentParser()
parser.add_argument('ssa', nargs='+', type=Path)
parser.add_argument('--out', type=Path)
args = parser.parse_args()
report = {'method': 'Static QBE text counts; no dynamic cost or machine-cycle inference.', 'inputs': [inspect(path) for path in args.ssa]}
data = json.dumps(report, indent=2) + '\n'
if args.out:
    args.out.write_text(data)
else:
    print(data, end='')
