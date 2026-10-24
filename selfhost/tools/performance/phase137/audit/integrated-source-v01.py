#!/usr/bin/env python3
"""Independently audit the exact Phase137 integrated source delta; no targets."""
import argparse
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
CHANGES = {
    'lookup': [('p88_string_eq(dk(d), "BookCache")', 'p137q_is_cache(d)'),
               ('p88_string_eq(dn(d), name)', 'p137q_name_eq(name, d)')],
    'f_find': [('f_eq(name, dn(d))', 'p137q_key_eq(name, d)')],
    'nc_ctor_owned': [('p88_string_eq(dk(d), "ADT")', 'p137q_is_adt(d)'),
                      ('p88_string_eq(dk(lookup(dc(d), name)), "Ctr")', 'p137q_is_ctr(lookup(dc(d), name))')],
    'nol_fields': [('U32.is_le(left, 8)', 'U32.is_le(left, 16)')],
    'nol_ctor_fields': [('U32.is_le(da(ctr), 8)', 'U32.is_le(da(ctr), 16)')],
    'p131rg_width': [('U32.is_le(width,8)', 'U32.is_le(width,16)')],
    'p118b_project_borrow': [('U32.is_le(count,8)', 'U32.is_le(count,16)')],
    'p113i_eligible': [('p113j_returns(body,result)', 'p137qi_returns(body,result)')],
    'p131rg_controls': [('"region-wide-refused",Bool.not(p131rg_width(9))',
                        '"region-width-seventeen-refused",Bool.not(p131rg_width(17))')],
}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--manifest', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'implementation/phase137/audit')
    m = json.loads(a.manifest.read_text())
    assert m['complete'] and m['source']['sha256'] == '2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38'
    assert m['qualified']['sha256'] == 'a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57'
    qualified = C.blocks(Path(m['qualified']['file']).read_text(), combine=True)
    parent = C.blocks(Path(m['parent']['file']).read_text(), combine=True)
    candidate = C.blocks(Path(m['source']['file']).read_text(), combine=True)
    fixture_path = ROOT / 'selfhost/tools/performance/phase137/queries/queries-fused-v02.bend'
    fixture = C.blocks(fixture_path.read_text(), combine=True)
    assert not set(qualified) - set(candidate)
    changed = sorted(n for n in qualified if C.norm(qualified[n]) != C.norm(candidate[n]))
    assert changed == sorted(CHANGES)
    for name, replacements in CHANGES.items():
        expected = qualified[name]
        for before, after in replacements:
            assert expected.count(before) == 1, (name, before)
            expected = expected.replace(before, after)
        assert C.norm(expected) == C.norm(candidate[name]), name
    helpers = {'p137q_name_eq', 'p137q_key_eq', 'p137q_is_cache', 'p137q_is_adt', 'p137q_is_ctr'}
    assert set(candidate) - set(parent) == helpers
    for name in helpers | {'lookup', 'f_find', 'nc_ctor_owned'}:
        assert C.norm(candidate[name]) == C.norm(fixture[name]), name
    parent_changes = {'lookup', 'f_find', 'nc_ctor_owned', 'p131rg_controls'}
    assert all(C.norm(parent[n]) == C.norm(candidate[n]) for n in parent if n not in parent_changes)
    protected = C.ENTRY_GATES | set(C.blocks(C.DIRECT_VERIFIER.read_text())) | {n for n in qualified if n.startswith('p111v_')}
    assert all(C.norm(qualified[n]) == C.norm(candidate[n]) for n in protected if n in qualified)
    assert all(C.norm(qualified[n]) == C.norm(candidate[n]) for n in m['unchangedProofDeclarations'])
    inputs = [C.pin(__file__), C.pin(METHOD), C.pin(C.DIRECT_VERIFIER), C.pin(a.manifest),
              C.pin(fixture_path), m['source'], m['parent'], m['qualified'], *m['inputs']]
    for item in inputs:
        assert C.pin(item['file']) == item, item['file']
    report = dict(kind='phase137-independent-integrated-source-audit', complete=True, targetsRun=False,
                  inputs=inputs, changedQualifiedDeclarations=changed,
                  addedFromQualified=sorted(set(candidate)-set(qualified)), addedFromRetain=sorted(helpers),
                  exactQueryFixtureDefinitions=sorted(helpers | {'lookup', 'f_find', 'nc_ctor_owned'}),
                  unchangedProtectedDeclarations=sorted(protected & set(qualified)),
                  unchangedProofDeclarations=m['unchangedProofDeclarations'],
                  scope='Whole declaration inventory and exact expected source substitutions, ignoring whitespace/comment-only differences. Proof/verifier/runtime/entry identities preserved. This is not a bootstrap, finite execution or whole-program speed claim.')
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, overrides=len(changed), report=C.pin(out))))


if __name__ == '__main__':
    main()
