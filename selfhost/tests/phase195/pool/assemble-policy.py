#!/usr/bin/env python3
"""Mechanically assemble a policy into the frozen allocator, without targets."""
import hashlib
import json
import re
import sys
from pathlib import Path

here = Path(__file__).resolve().parent
mode = sys.argv[1]
assert mode in ('rcx', 'adaptive')
base = here/'allocator-v2.bend'
common = here/'color-policy-v1.bend'
policy = here/('rcx-policy-v1.bend' if mode == 'rcx' else 'adaptive-policy-v1.bend')
replacement = 'x195_p_color' if mode == 'rcx' else 'x195_p_graphed'
output = here/f'allocator-{mode}-v3.bend'
receipt = here/f'allocator-{mode}-v3.inputs.json'
assert not output.exists() and not receipt.exists(), 'Frozen output already exists'


def declaration(text, name):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?def '+re.escape(name)+r'\(', text))
    assert len(matches) == 1, name
    start = matches[0].start()
    end = text.find('\n\n', matches[0].end())
    return start, len(text) if end == -1 else end


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


assert pin(base)['sha256'] == '64f061c13cd730dba091c0e403215dfdb37dafc661982730c7052d2f61dd3354'
base_text, policy_text = base.read_text(), policy.read_text()
a, b = declaration(base_text, replacement)
c, d = declaration(policy_text, replacement)
assembled = ('# Mechanically assembled by assemble-policy.py; see adjacent inputs receipt.\n'
             + base_text[:a] + policy_text[c:d] + base_text[b:] + '\n\n'
             + common.read_text() + '\n\n' + policy_text[:c] + policy_text[d:] + '\n')
names = re.findall(r'(?m)^def\s+(\w+)', assembled)
assert len(names) == len(set(names)), 'Duplicate definitions'
assert all('(' not in line for line in assembled.splitlines() if line.lstrip().startswith('match '))
output.write_text(assembled)
receipt.write_text(json.dumps(dict(kind='phase195-mechanical-policy-assembly', mode=mode,
    targetsRun=False, replacement=replacement, inputs=[pin(base),pin(common),pin(policy),pin(Path(__file__).resolve())],
    output=pin(output)), indent=2)+'\n')
print(json.dumps(pin(output)))
