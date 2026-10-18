#!/usr/bin/env python3
"""Finite scalar-array concatenation oracle, independent of candidate output."""
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent

def expected(case):
    left=case['left']*case['leftRepeats']
    right=left if case['overlap']==1 else left[case['suffix']:] if case['overlap']==2 else case['right']*case['rightRepeats']
    aliases=([left] if case['aliases']&1 else [])+([right] if case['aliases']&2 else [])
    result=left+right
    return [dict(name=case['name'],dropOrder=order,result=result,aliases=aliases,
        resultAfterAliasRelease=result if order=='aliases-first' else None,released=True)
        for order in ['result-first','aliases-first']]

if __name__=='__main__':
    for case in json.loads((HERE/'cases.json').read_text())['cases']:
        for row in expected(case):print(json.dumps(row,separators=(',',':')))
