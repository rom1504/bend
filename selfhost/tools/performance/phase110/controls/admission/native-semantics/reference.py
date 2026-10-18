#!/usr/bin/env python3
"""Independent short-value specification; no candidate or graph execution."""
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent

def expected(case):
    root, shape = case['root'], case['shape']
    empty, cross = shape == 0, shape == 4
    xs = [] if empty else ([0,101,769,128578,1114111] if root == 1 else [[97],[955,128578],[]])
    h = xs[0] if cross and root == 2 else ([] if empty else [104,128578])
    ys = xs if cross else ([] if empty else [[122]])
    result = xs if root < 2 else ([h] + xs if root == 2 else ys)
    aliases = [] if shape < 2 else [xs] + ([h] if root == 2 else [ys] if root == 3 else [])
    return [dict(name=case['name'],dropOrder=order,result=result,aliases=aliases,
                 resultAfterAliasRelease=result if order == 'aliases-first' else None,released=True)
            for order in ['result-first','aliases-first']]

if __name__ == '__main__':
    for case in json.loads((HERE/'cases.json').read_text())['cases']:
        for row in expected(case): print(json.dumps(row,separators=(',',':')))
