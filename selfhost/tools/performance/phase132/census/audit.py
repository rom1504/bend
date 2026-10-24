#!/usr/bin/env python3
"""Cross-check census arithmetic and exact source -> QBE -> ELF receipt joins."""
import argparse
import hashlib
import json
from pathlib import Path


def pin(path):
    p = Path(path).resolve()
    h = hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda: f.read(1 << 20), b''):
            h.update(b)
    return {'file': str(p), 'bytes': p.stat().st_size, 'sha256': h.hexdigest()}


def identity(a, b):
    assert a['sha256'] == b['sha256'] and a['bytes'] == b['bytes'], (a, b)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--census', required=True)
    p.add_argument('--emission', required=True)
    p.add_argument('--build', required=True)
    p.add_argument('--compact', required=True)
    p.add_argument('--out', required=True)
    a = p.parse_args()
    c, e, b, compact = [json.loads(Path(x).read_text()) for x in [a.census, a.emission, a.build, a.compact]]
    assert all(x['complete'] for x in [c, e, b, compact])
    for key in ['source', 'base']:
        identity(c['inputs'][key], e[key])
    identity(c['inputs']['qbe'], e['product'])
    identity(c['inputs']['binary'], b['binary'])
    assert any(x['sha256'] == e['product']['sha256'] and x['bytes'] == e['product']['bytes'] for x in b['inputs'])
    for item in c['inputs'].values():
        identity(pin(item['file']), item)
    assert sum(c['sectionBytes'].values()) == c['rawBytes']
    assert sum(c['lexicalBytes'].values()) == c['rawBytes']
    assert sum(x['bytes'] for x in c['globalSymbolRoles'].values()) == c['lexicalBytes']['global_symbols']
    for key in ['functions', 'blocks', 'instructions', 'calls']:
        assert sum(x[key] for x in c['disjointFunctionCategories'].values()) == c[key]
    assert sum(x['bytes'] for x in c['disjointFunctionCategories'].values()) == c['sectionBytes']['functions']
    assert sum(x['bytes'] for x in c['data']) == c['sectionBytes']['data']
    assert sum(c['opcodes'].values()) == c['instructions']
    assert c['allDirectCallSites'] + c['indirectCallSites'] == c['calls']
    definitions = sum(x['distinct'] for k, x in c['globalSymbolRoles'].items() if k != 'unresolved_external')
    exports = sum(x['distinct'] for k, x in c['globalSymbolRoles'].items() if k.startswith('exported_'))
    assert definitions == compact['globalDefinitions']
    assert exports == compact['exports']
    assert compact['originalStrings']['bytes'] == c['lexicalBytes'].get('quoted_strings', 0)
    out = Path(a.out)
    assert not out.exists()
    out.write_text(json.dumps({'kind': 'phase132-census-arithmetic-and-lineage-audit-v1', 'complete': True,
                              'inputs': [pin(x) for x in [a.census, a.emission, a.build, a.compact, __file__]],
                              'qbe': c['inputs']['qbe'], 'source': c['inputs']['source'], 'binary': c['inputs']['binary'],
                              'crossCheckedDefinitions': definitions, 'crossCheckedExports': exports,
                              'scope': 'Authenticates exact source/Base -> emitted QBE -> built ELF receipt joins and census arithmetic. Does not requalify compiler semantics or prove duplicate bodies mergeable.'}, indent=2) + '\n')
    print(out)


if __name__ == '__main__':
    main()
