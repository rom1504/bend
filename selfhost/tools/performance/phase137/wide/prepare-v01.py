#!/usr/bin/env python3
"""Rebase exactly four audited field-count bounds on qualified Phase134, source only."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
COMPOSER = ROOT / 'selfhost/tools/performance/phase131/prepare.py'
spec = importlib.util.spec_from_file_location('phase137_compose', COMPOSER)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
CHANGES = {
    'nol_fields': ('U32.is_le(left, 8)', 'U32.is_le(left, 16)'),
    'nol_ctor_fields': ('U32.is_le(da(ctr), 8)', 'U32.is_le(da(ctr), 16)'),
    'p131rg_width': ('U32.is_le(width,8)', 'U32.is_le(width,16)'),
    'p118b_project_borrow': ('U32.is_le(count,8)', 'U32.is_le(count,16)'),
}


def digest(text):
    value = text.encode()
    return dict(bytes=len(value), sha256=hashlib.sha256(value).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase137')
    selection_path = ROOT / 'implementation/phase134/final/candidate.json'
    selected = json.loads(selection_path.read_text())
    assert selected['complete'] and selected['nativeQualified']
    assert selected['source']['sha256'] == 'a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57'
    for key in ['source', 'sourceManifest', 'checkedApi', 'runtime']:
        assert C.pin(selected[key]['file']) == selected[key], key
    parent = json.loads(Path(selected['sourceManifest']['file']).read_text())
    checked = json.loads(Path(selected['checkedApi']['file']).read_text())
    assert checked['complete'] and checked['checked'] and checked['status'] == 0
    assert selected['source'] in checked['inputs']
    before = Path(selected['source']['file']).read_text()
    old = C.blocks(before)
    wide = HERE / 'wide-v01.bend'
    controls = HERE / 'controls-v01.bend'
    module = C.blocks(wide.read_text())
    assert set(module) == set(CHANGES)
    legacy_wide = ROOT / 'selfhost/tools/performance/phase131/identity/wide/wide.bend'
    legacy_controls = ROOT / 'selfhost/tools/performance/phase131/identity/wide/controls-v02.bend'
    assert wide.read_bytes() == legacy_wide.read_bytes()
    assert controls.read_text().replace('p137w_', 'p131w_') == legacy_controls.read_text()
    text, audit = before, []
    for name, (old_bound, new_bound) in CHANGES.items():
        assert old[name].count(old_bound) == 1 and old[name].count(new_bound) == 0, name
        replaced = old[name].replace(old_bound, new_bound)
        assert C.norm(replaced) == C.norm(module[name]), name
        assert text.count(old[name]) == 1, name
        text = text.replace(old[name], replaced, 1)
        audit.append(dict(declaration=name, before=old_bound, after=new_bound,
                          occurrences=1, original=digest(old[name]), candidate=digest(replaced)))
    # Byte-preserving construction: reversing just four bound substitutions
    # restores every parent source byte, before adding the renamed old controls.
    recovered = text
    for name, (old_bound, new_bound) in CHANGES.items():
        recovered = recovered.replace(old[name].replace(old_bound, new_bound), old[name], 1)
    assert recovered == before
    control_text = controls.read_text()
    # The control module's introductory comments are retained in module1.bend;
    # omit them here so they do not become part of the last parent declaration.
    appendix = '\n' + control_text[next(C.PAT.finditer(control_text)).start():]
    text += appendix
    composed, added, protected = C.compose(before, [wide.read_text(), controls.read_text()], set(CHANGES), set())
    after, expected = C.blocks(text), C.blocks(composed)
    assert set(after) == set(expected)
    assert all(C.norm(after[n]) == C.norm(expected[n]) for n in after)
    changed = sorted(n for n in old if C.norm(old[n]) != C.norm(after[n]))
    assert changed == sorted(CHANGES)
    unchanged = sorted(set(old) - set(CHANGES))
    assert all(old[n].rstrip('\n') == after[n].rstrip('\n') for n in unchanged)
    assert all(old[n] == after[n] for n in protected)
    proofs = parent['unchangedProofDeclarations']
    assert all(old[n] == after[n] for n in proofs)
    assert old['p128bf_match'] == after['p128bf_match']
    assert old['p111_native_args'] == after['p111_native_args']
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(text)
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    for i, path in enumerate([wide, controls]):
        (out / f'module{i}.bend').write_bytes(path.read_bytes())
    report = dict(kind='phase137-four-bound-wide-record-rebase', complete=True,
        checked=False, targetsRun=False, nativeQualified=False, selected=False,
        source=C.pin(out / 'compiler.bend'), parent=selected['source'],
        parentSelection=C.pin(selection_path), sourceManifest=selected['sourceManifest'],
        checkedParent=selected['checkedApi'], runtime=selected['runtime'],
        overrides=changed, semanticBoundChanges=audit, added=added,
        protectedDeclarations=protected, unchangedOriginalDeclarations=unchanged,
        unchangedProofDeclarations=proofs, controlEntry='p137w_controls', controlCount=17,
        reverseParentBytesExact=True, oldControlsExactModuloPrefix=True,
        physicalLines=len(text.splitlines()), parentLines=len(before.splitlines()),
        inputs=[C.pin(__file__), C.pin(COMPOSER), C.pin(C.DIRECT_VERIFIER),
                C.pin(selection_path), selected['source'], selected['sourceManifest'],
                selected['checkedApi'], selected['runtime'], C.pin(wide), C.pin(controls),
                C.pin(legacy_wide), C.pin(legacy_controls),
                C.pin(ROOT / 'research/phase131/wide-records.md'),
                C.pin(ROOT / 'selfhost/tools/performance/phase131/regions/identity-width-audit.md')],
        scope='Exactly four field-count limits8→16 plus17 legacy predicates renamed p137w_. Every other parent byte remains recoverable unchanged. Original protected verifiers, proofs, runtime, ordinary entry, held-root/alias rules, constructor-count and helper-parameter limits and late inline field template remain unchanged. New source is not checked or native-qualified by this metadata composition.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(source=report['source'], overrides=changed, controls=17,
                         protected=len(protected), proofs=len(proofs), targetsRun=False)))


if __name__ == '__main__':
    main()
