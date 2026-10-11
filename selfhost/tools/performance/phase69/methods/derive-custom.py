#!/usr/bin/env python3
"""Derive the retained-C gate for explicit custom selections; data only."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT/'selfhost/build/phase69/methods01/prepare-integration.py'
EXPECTED = '03e81d418678300c6c1145987829bb1589ea1c806be6caab89797eacfa28608b'


def pin(p):
    p = Path(p).resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
parent = pin(PARENT)
assert parent['sha256'] == EXPECTED
text = PARENT.read_text()
edits = []


def replace(old, new):
    global text
    assert text.count(old) == 1, old
    text = text.replace(old, new)
    edits.append(dict(before=old, after=new, count=1))


replace('    parser.add_argument("--set", choices=["product-branch-drop", "product-fast", "integration"], required=True)',
'''    parser.add_argument("--selection", type=Path, action="append", required=True)
    parser.add_argument("--expected-cases", type=int, required=True)''')
replace('    args = parser.parse_args()', '''    args = parser.parse_args()
    assert 0 < args.expected_cases <= 100
    # Preserve the parent's existing short/integration deadline choices.
    args.set = "integration" if args.expected_cases > 10 else "custom"''')
start = text.index('    catalog_pin = pin(HERE / "catalog-v1.json")')
end = text.index('    workflow = snapshot / "tools/development/workflow.mjs"', start)
replace(text[start:end], '''    upstream = Path(attempt["config"]["upstream"]).resolve(strict=True)
    assert upstream == (ROOT / "selfhost/.bootstrap/upstream-phase66").resolve(strict=True)
    assert pin(upstream / "bend2/base.bend")["sha256"] == attempt["base"]["sha256"]
    selections, cases, duplicate_ids, goldens = [], {}, [], []
    for path in args.selection:
        selection_pin = pin(path)
        selected = json.loads(Path(selection_pin["file"]).read_text())
        assert set(selected) == {"cases"} and isinstance(selected["cases"], list)
        assert selected["cases"], path
        inputs.append(selection_pin)
        selections.append(selection_pin)
        for row in selected["cases"]:
            assert set(row) == {"id", "file", "lanes"}, row
            assert isinstance(row["id"], str) and row["id"] and row["lanes"] == ["native"]
            file = Path(row["file"])
            assert file.is_absolute() and file.suffix == ".bend", file
            source = pin(file)
            assert str(file) == source["file"], "Use canonical absolute fixture paths"
            golden = [line[2:] for line in file.read_text().splitlines() if line.startswith("#|")]
            assert golden, (row["id"], "Each selected source needs an explicit #| golden")
            if row["id"] in cases:
                assert cases[row["id"]] == row, (row["id"], "Conflicting duplicate selection")
                duplicate_ids.append(dict(id=row["id"], selection=selection_pin))
                continue
            cases[row["id"]] = row
            inputs.append(source)
            goldens.append(dict(id=row["id"], source=source, goldenLines=golden))
    wanted = list(cases)
    assert len(wanted) == args.expected_cases, (len(wanted), args.expected_cases)
    selection = dict(cases=list(cases.values()))
    inputs.append(pin(Path(__file__).with_suffix(".derivation.json")))
''')
replace('        set=args.set, expectedCases=len(wanted), selection=pin(frozen_selection),',
'''        set="custom", expectedCases=len(wanted), selection=pin(frozen_selection),
        originalSelections=selections, identicalDuplicateIds=duplicate_ids, fixtureGoldens=goldens,''')
replace('kind="phase68-native-selected-control-plan"', 'kind="phase69-native-custom-control-plan"')
replace('"Existing paired workflow and unchanged independent fixture goldens; no test framework or compiler changes. Outer orchestration unrestricted, target workers pinned by checked config CPU3/jobs1. No timing or all-native-conformance claim."',
'''"Existing paired workflow and literal source #| goldens from explicit native selections. Identical duplicate IDs are listed and merged; conflicts and unexpected case counts refuse. Retained C, snapshot/recipe pins, CC environment and resource guard are unchanged. The inherited deadline is360s for up to10cases,900s above10. Outer orchestration unrestricted, target workers CPU3/jobs1. No target success, performance or all-native-conformance claim."''')
ast.parse(text)
with a.out.open('x') as f:
    f.write(text)
derivation = dict(kind='phase69-custom-selection-method-derivation', producer=pin(__file__),
                  parent=parent, output=pin(a.out), edits=edits, dataOnly=True,
                  targetsExecuted=False,
                  scope='Replace fixed catalog selection with explicit source-backed native selections and exact expected-case count. Preserve all downstream retained-workflow generation, snapshot/native recipe checking, command environment, per-worker affinity and parent guard limits.')
with a.out.with_suffix('.derivation.json').open('x') as f:
    json.dump(derivation, f, indent=2)
    f.write('\n')
print(json.dumps(pin(a.out)))
