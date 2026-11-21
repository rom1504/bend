"""Count primitive ABI calls from relocations in paired checked direct objects."""
from collections import Counter, deque
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
PRIMITIVES = (24, 25, 63, 67)
TARGET = "$product.nearest"

def pin_source(receipt):
    path = Path(receipt["file"])
    assert hashlib.sha256(path.read_bytes()).hexdigest() == receipt["sha256"]
    return path

def decode(symbol):
    match = re.fullmatch(r'p113d_FID_((?:[0-9]+_)+)', symbol)
    if match:
        return ''.join(chr(int(c)) for c in match[1].strip('_').split('_'))
    return symbol

def audit(receipt):
    path = pin_source(receipt)
    calls, near, near_ops = Counter(), Counter(), Counter()
    prev = deque(maxlen=9)
    owner = None
    text = subprocess.check_output(['objdump', '-drw', '--no-show-raw-insn', path], text=True)
    for line in text.splitlines():
        label = re.match(r'^\s*[\da-f]+ <([^>]+)>:$', line)
        if label:
            owner = decode(label[1])
            prev.clear()
            continue
        instruction = re.match(r'^\s*[0-9a-f]+:\s*([a-z][a-z0-9]*)\s*(.*)', line)
        if not instruction:
            continue
        mnemonic, operands = instruction.groups()
        if owner == TARGET:
            near_ops[mnemonic] += 1
        if mnemonic in ('callq', 'call') and re.search(r'R_X86_64_\w+\s+p111_rt_op-0x4\b', operands):
            code = next((int(m[1], 16) for line in reversed(prev)
                         if (m := re.search(r'mov(?:abs)?\s+\$0x([0-9a-f]+),%(?:e|r)si$', line))), None)
            assert code is not None, (path, owner, list(prev))
            calls[code] += 1
            if owner == TARGET:
                near[code] += 1
        prev.append(mnemonic + ' ' + operands)
    return dict(object=receipt, calls={str(k):v for k,v in sorted(calls.items())},
                selectedCalls={str(k):calls[k] for k in PRIMITIVES}, nearestCalls=dict(near),
                nearestOps={k:near_ops[k] for k in ('divss','sqrtss','ucomiss','callq')})

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--emission', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    rows = json.loads(args.emission.read_text())
    assert rows['complete']
    result = {r['id']:{'incumbent':audit(r['baseline']),'candidate':audit(r['object'])} for r in rows['cases']}
    args.out.write_text(json.dumps(result,indent=2)+'\n')
