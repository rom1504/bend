#!/usr/bin/env python3
"""Read-only source audit; writes evidence only when --out is explicitly given."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
NAMES = {
    'p140p_def_context_header', 'p140p_def_header_prior', 'p140p_def_prior',
    'p140p_def_base', 'p140p_def_type', 'p140p_def_body',
}

def pin(path):
    data = path.read_bytes()
    return {'path': str(path.relative_to(ROOT)), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}

def declarations(text):
    lines = text.splitlines(keepends=True)
    result = {}
    for i, line in enumerate(lines):
        match = re.match(r'^(def|law) (\w+)(?=[(:])', line)
        if not match:
            continue
        end = i + 1
        if match[1] == 'def' and not line.rstrip().endswith(':'):
            while not (lines[end-1].rstrip().endswith(':') and not lines[end-1].startswith(' ')):
                end += 1
        while end < len(lines) and (not lines[end].strip() or lines[end].startswith(' ')):
            end += 1
        key = (match[1], match[2])
        assert key not in result, key
        result[key] = ''.join(lines[i:end]).rstrip()
    return result

parser = argparse.ArgumentParser()
parser.add_argument('--out', type=Path)
args = parser.parse_args()
baseline = HERE / 'compact-parser-before.bend'
maintained = ROOT / 'selfhost/src/front/compact-parser.bend'
a, b = declarations(baseline.read_text()), declarations(maintained.read_text())
removed = sorted(set(a) - set(b))
assert not set(b) - set(a), 'Unexpected new declarations'
assert {name for kind, name in removed} == NAMES
assert sum(kind == 'def' for kind, name in removed) == 6
assert sum(kind == 'law' for kind, name in removed) == 3
assert all(a[key] == body for key, body in b.items()), 'Surviving declaration changed'
fast_start = 'law p177dr_resolve:'
assert baseline.read_text().split(fast_start, 1)[1] == maintained.read_text().split(fast_start, 1)[1]

# Inspect the original call graph by substituting the frozen module for the
# edited file. Declaration headers and comments are not runtime call edges.
edges = []
for source in sorted((ROOT / 'selfhost/src').rglob('*.bend')):
    text = baseline.read_text() if source == maintained else source.read_text()
    owner = None
    for line_number, line in enumerate(text.splitlines(), 1):
        match = re.match(r'^(def|law|type) (\w+)', line)
        if match:
            owner = match[2]
            continue
        if line.lstrip().startswith('#'):
            continue
        for name in sorted(NAMES):
            if re.search(r'\b' + name + r'\s*\(', line):
                edges.append({'file': str(source.relative_to(ROOT)), 'line': line_number,
                              'caller': owner, 'callee': name})
assert all(edge['caller'] in NAMES for edge in edges), 'Incoming production call'
manifest = json.loads((ROOT / 'selfhost/src/compiler.json').read_text())
for key in ['profiles', 'protectedDeclarations']:
    assert not NAMES.intersection(re.findall(r'\bp140p_def_\w+', json.dumps(manifest[key])))
public_roots = ['docs/self_hosted', 'selfhost/tools/build', 'selfhost/tools/conformance', 'selfhost/manifests']
checked = 0
for directory in public_roots:
    for path in (ROOT / directory).rglob('*'):
        if not path.is_file() or path.suffix not in {'.md','.json','.py','.mjs','.js','.ts','.bend'}:
            continue
        checked += 1
        assert not NAMES.intersection(re.findall(r'\bp140p_def_\w+', path.read_text(errors='replace'))), str(path)
report = {'kind': 'phase178-parser-dead-continuation-source-audit', 'complete': True,
          'baseline': pin(baseline), 'maintained': pin(maintained),
          'removed': [{'kind': kind, 'name': name} for kind, name in removed],
          'retainedDeclarationsExact': len(b), 'fastChainTextExact': True,
          'originalInternalEdges': edges, 'incomingProductionEdges': [],
          'publicProfilesAndProtectedDeclarationsUnaffected': True,
          'publicContractRootsChecked': public_roots, 'publicContractFilesChecked': checked,
          'scope': 'Lexical dependency and exact-source audit; no compiler, runtime, proof or performance claim.'}
if args.out:
    args.out.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({'complete': True, 'removed': len(removed), 'retainedExact': len(b),
                  'incomingProductionEdges': 0, 'fastChainTextExact': True}))
