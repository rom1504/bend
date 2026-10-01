#!/usr/bin/env python3
"""Derive narrowly rebound Phase37 integration tools; execute no gates."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
P35, P36 = HERE.parent/'phase35', HERE.parent/'phase36'


def identity(file):
    return dict(file=str(file.resolve()), sha256=hashlib.sha256(file.read_bytes()).hexdigest(), bytes=file.stat().st_size)


def derive(source, expected, name, kind, replacements):
    parent = identity(source)
    assert parent['sha256'] == expected, source
    target = HERE/name
    proof = target.with_suffix('.json')
    assert not target.exists() and not proof.exists(), 'Derived tools must be new'
    text = source.read_text()
    changes = []
    for before, after, count in replacements:
        assert text.count(before) == count, (name, before, count, text.count(before))
        text = text.replace(before, after)
        changes.append(dict(before=before, after=after, count=count))
    target.write_text(text)
    proof.write_text(json.dumps(dict(kind=kind, complete=True, parent=parent,
        producer=identity(Path(__file__)), derived=identity(target), changes=changes,
        scope='Exact source derivation only. No compiler, gate, timing, install or publication executed.'), indent=2)+'\n')
    return identity(target)


def main():
    parent_proof = json.loads((P36/'final-integration-plan.json').read_text())
    assert parent_proof['derived'] == identity(P36/'final-integration-plan.py')
    assert parent_proof['parent'] == identity(P35/'final-integration-plan.py')
    assert parent_proof['kind'] == 'phase36-inherited-final-planner-derivation' and parent_proof['complete']
    freeze = identity(HERE.parent/'programs/freeze-reference.py')
    assert freeze['sha256'] == 'a3daa6004187a8713d041043e7e3d72c3377c18e629b43c61af12f8f5310fc6d', 'Unexpected Phase37 packer bytes; review before rebinding'
    audit = derive(P35/'final-gate-audit-v2.py',
        '1474ed3f83eb0b02df77705c36b419dc2a1854b5fd8f9435a96e6a670ebbeb29',
        'final-gate-audit.py', 'phase37-inherited-final-audit-derivation', [
        ('"""Audit Phase35 receipts; resolve only the pinned portable reference via frozen provenance."""',
         '"""Audit inherited Phase37 receipts; preserve exact historical archive provenance."""', 1),
        ("original_audit = Path(__file__).with_name('final-gate-audit.py')",
         "original_audit = Path(__file__).resolve().parent.parent/'phase35/final-gate-audit.py'", 1),
        ("('freeze-reference.py', 'f230fffbd70ea26e020b88520c94dceee71833b5054c72b5f753dca648f6e760')]:",
         "('freeze-reference.py', '"+freeze['sha256']+"')]:", 1),
        ("identity(__file__)\n", """identity(__file__)
derivation_file = Path(__file__).with_suffix('.json')
derivation = read(derivation_file)
assert derivation['kind'] == 'phase37-inherited-final-audit-derivation' and derivation['complete']
assert Path(derivation['derived']['file']).resolve() == Path(__file__).resolve()
verify(derivation['derived']); verify(derivation['parent']); verify(derivation['producer'])
""", 1),
    ])
    planner = derive(P36/'final-integration-plan.py',
        '6b05713f240e91394c0e7abe78f955016c138610b7a92a1adc080cbc125de7f0',
        'final-integration-plan.py', 'phase37-inherited-final-planner-derivation', [
        ('"""Freeze Phase36 gates using the unchanged Phase35 assertions; execute nothing."""',
         '"""Freeze Phase37 gates using inherited semantic assertions; execute nothing."""', 1),
        ("'src/back/js/producer.bend': 'src/back/js/fold.bend'}",
         "'src/back/js/producer.bend': 'src/back/js/fold.bend',\n             'src/back/js/finite.bend': 'src/back/js/producer.bend'}", 1),
        ("'phase36-inherited-final-planner-derivation'", "'phase37-inherited-final-planner-derivation'", 1),
        ("keep(proof['parent']['file'], proof['parent']['sha256'])",
         "keep(proof['parent']['file'], proof['parent']['sha256'])\nkeep(proof['producer']['file'], proof['producer']['sha256'])\nkeep(Path(__file__).with_name('final-gate-audit.py'))\nkeep(Path(__file__).with_name('final-gate-audit.json'))\nkeep(HERE.parent/'phase36/final-integration-plan.json')", 1),
        ("save(out/'phase36-parentage.json'", "save(out/'phase37-parentage.json'", 1),
        ("parent=keep(HERE/'final-integration-plan.py'), successor=keep(__file__)",
         "parent=keep(HERE.parent/'phase36/final-integration-plan.py'), successor=keep(__file__)", 1),
        ("assertionPolicy='All Phase35 frontend/backend/inherited/15 owner assertions and auditors remain unchanged. Successor provenance, one explicit named module position and two previously established report-pointer corrections are added. Phase36-specific owner controls are separately required.'",
         "assertionPolicy='All inherited frontend/backend/15 owner semantic assertions remain unchanged. Add finite.bend only after producer.bend. Preserve known scope/vector report-pointer corrections. The Phase37 auditor pins the current packer separately while preserving historical archived producer checks.'", 1),
        ("phase36Owners='Separate explicit final-API producer, scoped-guard and compiler-cost controls; not discharged by this inherited plan.'",
         "separateOwners='Reacquire all seven Phase36 producer/scoped-guard groups on the final API. New Phase37 finite/native/cast owner groups and normal compiler costs remain separate mandatory admission requirements.'", 1),
    ])
    print(json.dumps(dict(complete=True, executed=False, planner=planner, audit=audit)))


if __name__ == '__main__':
    main()
