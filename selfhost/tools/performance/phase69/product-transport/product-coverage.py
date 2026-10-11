#!/usr/bin/env python3
"""Cross-check emitted product calls against a frozen dynamic-counter receipt.

Reads saved C and JSON only. It does not compile or execute any target.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import re
from pathlib import Path


def pin(path: Path) -> dict:
    data = path.read_bytes()
    return dict(path=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def decode(token: str) -> str:
    digits = token.removeprefix('NF_').removeprefix('FID_')
    if not re.fullmatch(r'[0-9_]+', digits):
        return token  # Runtime-reserved IDs such as FID_ENTER are not encoded.
    return ''.join(chr(int(x)) for x in digits.split('_') if x)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--receipt', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), args.out
    receipt = json.loads(args.receipt.read_text())
    assert receipt['complete']
    rows = []
    for record in receipt['records']:
        job = record['job']
        if job['role'] != 'selfhost' or job['case'] not in ('map', 'tree', 'lexer'):
            continue
        source_path = Path(job['source']['path'])
        assert pin(source_path)['sha256'] == job['source']['sha256']
        source = source_path.read_text()
        runs = {x['repetitions']: x for x in record['runs']}
        assert runs[1]['correct'] and runs[17]['correct']
        counters = {n: x['counts']['segments'] for n, x in runs.items()}
        dynamic = {decode(s['symbol']): counters[17].get(str(s['index']), 0) - counters[1].get(str(s['index']), 0)
                   for s in record['segments']}
        products = []
        for token in re.findall(r'(?:NF_INLINE|INLINE) Term (NF_FID_[0-9_]+)\([^\n]*\) \{', source):
            name = decode(token)
            if not name.startswith('$product.'):
                continue
            # The frozen generated-C schema has one declaration and one definition.
            occurrences = source.count(token + '(')
            assert occurrences >= 2
            ordinary = '$direct.' + name.removeprefix('$product.')
            products.append(dict(name=name, sourceCallSites=occurrences - 2,
                                 ordinaryDynamicEntries=dynamic.get(ordinary, 0)))
        unused = [x for x in products if x['sourceCallSites'] == 0]
        rows.append(dict(case=job['case'], source=job['source'],
                         products=sorted(products, key=lambda x: (-x['ordinaryDynamicEntries'], x['name'])),
                         unusedProducts=len(unused),
                         unusedOrdinaryDynamicEntries=sum(x['ordinaryDynamicEntries'] for x in unused)))
    output = dict(kind='phase69-product-coverage-source-cross-check-v1', targetExecuted=False,
                  producer=pin(Path(__file__)), receipt=pin(args.receipt),
                  interpretation='Call-site counts are structural; dynamic entries are frozen c23 17-minus-1 counter differences, not a new profile or timing.',
                  records=rows)
    args.out.write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps(dict(targetExecuted=False, records=len(rows), output=str(args.out))))


if __name__ == '__main__':
    main()
