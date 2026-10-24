#!/usr/bin/env python3
"""Independent byte-prefix and policy-walk audit; never executes compiler targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
METHOD = ROOT / 'selfhost/tools/performance/phase131/prepare.py'
spec = importlib.util.spec_from_file_location('blocks', METHOD)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--manifest', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'implementation/phase137/audit')
    m = json.loads(a.manifest.read_text())
    assert m['complete'] and m['parent']['sha256'] == '863e28f8bba8a285332875ce99bf82a20d2ea3052c6f4b6aed3606b0d67485b5'
    parent = Path(m['parent']['file']).read_bytes()
    source = Path(m['source']['file']).read_bytes()
    before = b'p113i_params(params) && p113j_returns(body,result)'
    after = b'p113i_params(params) && p137qi_returns(body,result)'
    assert parent.count(before) == source.count(after) == 1
    restored = source.replace(after, before, 1)
    assert restored.startswith(parent), 'Changing the one eligibility callee must restore every parent byte.'
    tail = restored[len(parent):].decode()
    old = C.blocks(parent.decode(), combine=True)
    added = C.blocks(tail, combine=True)
    assert set(added) == set(m['added']) and not set(added).intersection(old)
    assert len(added) == 10
    plain = old['p113j_plain'].replace('p113j_plain', 'p137qi_plain')
    plain = plain.replace('case Con{P113DScalar{stmt},rest}: p137qi_plain(rest)',
                          'case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_plain(rest)')
    returns = old['p113j_returns'].replace('p113j_returns', 'p137qi_returns').replace('p113j_plain', 'p137qi_plain')
    returns = returns.replace('case Con{P113DScalar{stmt},rest}: p137qi_returns(rest,width)',
                              'case Con{P113DScalar{stmt},rest}: p137qi_scalar(stmt) && p137qi_returns(rest,width)')
    assert C.norm(plain) == C.norm(added['p137qi_plain'])
    assert C.norm(returns) == C.norm(added['p137qi_returns'])
    assert added['p137qi_controls'].count('p113ft_row(') == 20
    inputs = [C.pin(__file__), C.pin(METHOD), C.pin(a.manifest), m['parent'], m['source'], *m['inputs']]
    for pin in inputs:
        assert C.pin(pin['file']) == pin, pin['file']
    report = dict(kind='phase137-independent-retention-policy-audit', complete=True,
                  targetsRun=False, inputs=inputs, exactParentBytePrefixAfterOneCalleeReversal=True,
                  addedDeclarations=sorted(added), controlRows=20,
                  identicalShapeWalksExceptScalarConjunction=True,
                  scope='Source audit only. Actual p113i_eligible is exercised by five new rows; malformed-IR rows test profitability, not semantic admission. Checked controls, ordinary output, emitted-call reachability and runtime require independent target receipts.')
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, report=C.pin(out))))


if __name__ == '__main__':
    main()
