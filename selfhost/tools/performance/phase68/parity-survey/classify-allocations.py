#!/usr/bin/env python3
"""Classify measured allocation sites by their explicit emitted-C consumer.

This is a fail-closed source classifier, not C alias analysis or a profiler.
Unknown/ambiguous construction remains unknown. Never use counts as time.
"""
import collections
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase68/parity-survey23-counts01/report.json'
OUT = ROOT / 'research/phase68/c23-allocation-categories.json'


def pin(p):
    b = p.read_bytes()
    return dict(path=str(p.relative_to(ROOT)), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def decode(s):
    return re.sub(r'(?:FID_|CID_(?:_CTOR_)?)((?:\d+_)+)',
        lambda m: ''.join(chr(int(x)) for x in m[1].split('_') if x), s)


def main():
    raw = json.loads(RAW.read_text())
    assert raw['complete']
    result = dict(schema='phase68-c23-allocation-categories-v1', complete=True,
        method='Signed17 minus1 runs (formatting/scheduling sites may decrease); all explicit term_ctr/term_clo consumers of an allocation variable in its lexical scope must agree on kind/constructor; runtime rfc_wrap/task_node classified by exact enclosing function; all else unknown.',
        inputs=[pin(Path(__file__)), pin(RAW)], records=[])
    for row in raw['records']:
        if row['job']['case'] not in ('tree', 'lexer', 'map', 'closures'):
            continue
        low, high = row['runs']
        assert low['repetitions'] == 1 and high['repetitions'] == 17
        assert low['correct'] and high['correct']
        p = Path(row['job']['source']['path'])
        assert pin(p)['sha256'] == row['job']['source']['sha256']
        result['inputs'].append(pin(p))
        code = p.read_text(); lines = code.splitlines()
        owners = []
        pattern = r'^(?:INLINE|NF_INLINE|OUTLINE|FAR|static)\s+[^\n;]*?\b(\w+)\([^;\n]*\)\s*\{|^\s*WL_CASE\((\w+)\)'
        for m in re.finditer(pattern, code, re.M):
            owners.append((code.count('\n', 0, m.start()) + 1, decode(m[1] or m[2])))
        cats = collections.Counter(); ctors = collections.Counter(); sites = []
        for s, a, b in zip(row['sites'], low['allocationSites'], high['allocationSites']):
            calls = b - a
            if not calls:
                continue
            line = s['sourceLine']; text = lines[line - 1]
            assert text.strip() == s['text'].strip(), (p, line)
            owner = next((name for at, name in reversed(owners) if at <= line), 'unknown')
            category = 'unknown'; constructor = None; consumer = None
            if owner == 'rfc_wrap':
                category = 'rfc_redirect'
            elif owner == 'task_node':
                category = 'task_node'
            else:
                var = re.search(r'\b(?:u64|Loc|Term)\s+(\w+)\s*=.*\bheap_alloc\(', text)
                candidates = []
                if var:
                    var = var[1]; depth = 0
                    for j in range(line, min(len(lines), line + 100)):
                        candidate = lines[j]
                        # The generated allocation declaration belongs to the
                        # current scope; never match a later reused local name.
                        if re.search(r'\b(?:u64|Loc|Term)\s+' + re.escape(var) + r'\b', candidate):
                            break
                        for m in re.finditer(r'\bterm_(ctr|clo)\((\w+)\s*,\s*' + re.escape(var) + r'\s*\)', candidate):
                            candidates.append((m[1], m[2], j + 1, candidate.strip()))
                        depth += candidate.count('{') - candidate.count('}')
                        if depth < 0:
                            break
                    if candidates and len({(x[0], x[1]) for x in candidates}) == 1:
                        kind, constructor, at, consumer = candidates[0]
                        constructor = decode(constructor)
                        if kind == 'clo': category = 'closure_environment'
                        elif constructor == 'CID_TUPLE': category = 'product_tuple'
                        elif constructor.endswith(':St') or constructor.endswith('_TREE_BITONIC_ST'): category = 'product_stat'
                        elif constructor == 'CID_SCON': category = 'data_string'
                        elif constructor in ('CID_MNODE', 'CID_MLEAF') or constructor.endswith(':Node') or constructor.endswith('_TREE_BITONIC_NODE'): category = 'data_tree_map_node'
                        else: category = 'data_other_constructor'
                        consumer = [dict(line=x[2], text=x[3]) for x in candidates]
            cats[category] += calls
            if constructor: ctors[constructor] += calls
            sites.append(dict(**s, calls=calls, owner=owner, category=category,
                constructor=constructor, consumer=consumer))
        total = high['counts']['heapAllocCalls'] - low['counts']['heapAllocCalls']
        assert sum(cats.values()) == total
        cats.setdefault('unknown', 0)
        result['records'].append(dict(case=row['job']['case'], role=row['job']['role'],
            source=pin(p), total=total, categories=dict(cats), constructors=dict(ctors),
            sites=sorted(sites, key=lambda x: -x['calls'])))
    OUT.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps([dict(case=r['case'], role=r['role'], total=r['total'], categories=r['categories']) for r in result['records']], indent=2))


if __name__ == '__main__':
    main()
