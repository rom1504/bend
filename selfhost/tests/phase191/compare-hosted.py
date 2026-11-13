#!/usr/bin/env python3
"""Authenticate the frozen eight-case B1/N1 intersection; execute no targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
METHOD = Path(__file__).resolve().parents[1] / 'phase190/compare-products.py'
spec = importlib.util.spec_from_file_location('p190_product_evidence', METHOD)
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--left', type=Path, required=True)
p.add_argument('--right', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
part = Path(__file__).with_name('cases.json')
names = P.bench.read(part)['development']
P.common.require(len(names) == len(set(names)) == 8, 'Exactly eight frozen cases')
e = P.Evidence()
for file in (__file__, METHOD, part, P.CATALOG, P.bench.__file__, P.common.__file__, P.product_compare.__file__, P.request.__file__):
    e.verify(P.common.pin(file))
out = P.common.fresh_output(a.out, P.ROOT)
r = dict(kind='phase191-hosted-native-product-equivalence', complete=False, targetsRun=False, selected=names, rows=[])
try:
    left, right = P.load_side(a.left, 'candidate', e), P.load_side(a.right, 'candidate', e)
    P.common.require(left['role']['host'] == 'js' and left['role']['stage'] == 'B1' and right['role']['host'] == 'native' and right['role']['stage'] == 'N1', 'Actual B1/N1 required')
    P.common.require(set(left['rows']) & set(right['rows']) == set(names), 'Exact frozen intersection')
    P.common.require(left['role']['runtime'] == right['role']['runtime'], 'Matching runtime required')
    cases = {c['id']: c for c in P.bench.catalog(P.CATALOG)['cases']}
    for name in names:
        x, y = P.authenticate_product(left, cases[name], e), P.authenticate_product(right, cases[name], e)
        same = {section: x['sections'][section] == y['sections'][section] for section in x['sections']}
        row = dict(id=name, left=x, right=y, objectIdentical=P.product_compare.same(x['object'], y['object']), linkedSectionsIdentical=same)
        r['rows'].append(row)
        P.common.require(row['objectIdentical'] and all(same.values()), 'Machine product differs: ' + name)
    r['complete'] = True
except BaseException as error:
    r['error'] = repr(error)
r['inputs'] = list(e.inputs.values())
r['changedInputs'] = P.common.changed_inputs(r['inputs'])
if r['changedInputs']: r['complete'] = False
P.common.write_json(out/'report.json', r)
print(json.dumps({k: r.get(k) for k in ('complete', 'selected', 'error')}))
sys.exit(0 if r['complete'] else 1)
