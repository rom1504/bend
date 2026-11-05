#!/usr/bin/env python3
"""Offline QBE identity census; never executes compiler or generated products."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def decode(symbol):
    if '_FID_' not in symbol:
        return symbol, symbol
    family, encoded = symbol.split('_FID_', 1)
    return family, ''.join(chr(int(x)) for x in encoded.rstrip('_').split('_'))


def subtype(owner):
    if owner.startswith('$p111.k.'):
        return 'continuation'
    if owner.startswith('$direct.'):
        return 'boxed-owner'
    if 'borrow' in owner:
        return 'borrow-helper'
    return 'other-entry-or-helper'


def inspect(report_path):
    report = json.loads(report_path.read_text())
    assert report['complete']
    ir = Path(report['ir']['file'])
    actual = pin(ir)
    assert actual['bytes'] == report['ir']['bytes']
    assert actual['sha256'] == report['ir']['sha256']
    text = ir.read_text()
    entries = {}
    families = collections.defaultdict(lambda: dict(functions=0, textBytes=0, subtypes=collections.Counter()))
    pattern = r'^(?:export )?function [wl] \$([A-Za-z0-9_]+)\([^\n]*\) \{\n.*?^\}'
    for match in re.finditer(pattern, text, re.M | re.S):
        symbol, body = match[1], match[0]
        family, owner = decode(symbol)
        assert symbol not in entries
        entries[symbol] = dict(family=family, owner=owner, body=body)
        row = families[family]
        row['functions'] += 1
        row['textBytes'] += len(body.encode())
        row['subtypes'][subtype(owner)] += 1
    assert len(entries) == report['functions']
    return dict(report=pin(report_path), ir=actual, inputs=report['inputs'],
                functions=len(entries), families=families), entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    old, a = inspect(args.baseline)
    new, b = inspect(args.candidate)
    # Both emit receipts bind source, Base, checked API receipt and actual API.
    assert old['inputs'] == new['inputs'], 'Different input or observer identities'
    result = dict(kind='phase167-offline-qbe-census', method=pin(Path(__file__)),
                  baseline=old, candidate=new, identityInputsEqual=True,
                  familyChanges={})
    for family in sorted(set(x['family'] for x in a.values()) | set(x['family'] for x in b.values())):
        aa = {k: v for k, v in a.items() if v['family'] == family}
        bb = {k: v for k, v in b.items() if v['family'] == family}
        common = aa.keys() & bb.keys()
        removed = sorted(aa[k]['owner'] for k in aa.keys() - bb.keys())
        added = sorted(bb[k]['owner'] for k in bb.keys() - aa.keys())
        result['familyChanges'][family] = dict(
            old=len(aa), new=len(bb), exactSymbolCommon=len(common),
            exactBodiesCommon=sum(aa[k]['body'] == bb[k]['body'] for k in common),
            removedSymbols=len(removed), addedSymbols=len(added),
            removedNonContinuationOwners=[x for x in removed if not x.startswith('$p111.k.')],
            addedNonContinuationOwners=[x for x in added if not x.startswith('$p111.k.')])
    result['limits'] = [
        'Static emitted function/text counts, not executed calls or allocation events.',
        'Fresh continuation identities change with lowering order; removed/added symbols do not prove corresponding semantic bodies disappeared.',
        'All raw admitted direct workers are retained by source policy; final QBE cannot reconstruct rejected candidate fates.',
        'Body equality includes exact numerical IDs and text; differences do not imply semantic differences.',
        'The inherited p111q_segment_chunks still builds a region registry; p112w output witnesses this route.'
    ]
    assert not args.out.exists(), 'Use a fresh output'
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: {'old': v['old'], 'new': v['new'],
                         'removedNamed': len(v['removedNonContinuationOwners']),
                         'addedNamed': len(v['addedNonContinuationOwners'])}
                      for k, v in result['familyChanges'].items()}))


if __name__ == '__main__':
    main()
