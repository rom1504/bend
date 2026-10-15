#!/usr/bin/env python3
"""Record exact pre/post origin-guard C shapes; source/data inspection only."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
BUILD = ROOT / 'selfhost/build/phase98'
EXPECTED = {
    'oldSource': '59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714',
    'newSource': '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051',
    'oldC': '5782601ed24d0215669e0fe27a62ff240c452219b510b9ab70c312645dc60767',
    'newC': '21c0e6b6a71a4bd409f0945bb0c1ff8928e3f4917cd445df06d4c5b07aa4e128',
}


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def section(text, name):
    pattern = r'^  WL_CASE\(' + re.escape(name) + r'\)\n.*?^  }}\n'
    matches = list(re.finditer(pattern, text, re.M | re.S)); assert len(matches) == 1, name
    match = matches[0]
    return dict(line=text.count('\n', 0, match.start()) + 1, text=match.group())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); assert not args.out.exists()
    paths = dict(oldSource=BUILD/'permission-tag-source02/compiler.bend',
                 newSource=BUILD/'origin-guard-source01/compiler.bend',
                 oldC=BUILD/'combined-checked01/program.c', newC=BUILD/'origin-checked01/program.c')
    inputs = {key: pin(path) for key, path in paths.items()}
    assert all(inputs[key]['sha256'] == value for key, value in EXPECTED.items())
    recipe = json.loads((BUILD/'origin-guard-source01/changes.json').read_text())
    assert len(recipe['localChanges']) == 1
    change = recipe['localChanges'][0]
    before = paths['oldSource'].read_text(); after = paths['newSource'].read_text()
    at = change['offset']
    assert before[at:at+len(change['old'])] == change['old']
    assert before[:at] + change['new'] + before[at+len(change['old']):] == after
    names = {
        'old': ['FID_NOA_BELOW', 'FID_NOA_BELOW_K894', 'FID_NOA_BELOW_C895',
                'FID_NOA_BELOW_C896', 'FID_NOA_BELOW_K897', 'FID_NOA_BELOW_K898'],
        'new': ['FID_NOA_BELOW', 'FID_NOA_BELOW_K894', 'FID_NOA_BELOW_C895',
                'FID_NOA_BELOW_C896', 'FID_NOA_BELOW_C897', 'FID_NOA_BELOW_K898',
                'FID_NOA_BELOW_K899', 'FID_NOA_BELOW_C900'],
    }
    shapes = {side: {name: section(paths[side+'C'].read_text(), name) for name in identifiers}
              for side, identifiers in names.items()}
    old = {key: row['text'] for key, row in shapes['old'].items()}
    new = {key: row['text'] for key, row in shapes['new'].items()}
    checks = dict(
        oldFallbackCallsKid='WL_JMP(FID_KID)' in old['FID_NOA_BELOW_C896'],
        oldFallbackHasNoTagCheck='spin_1(' not in old['FID_NOA_BELOW_C896'],
        oldChildContinuationRecurses='WL_JMP(FID_NOA_BELOW)' in old['FID_NOA_BELOW_K897'],
        oldTagCheckWaitsForRecursiveResult='spin_1(' in old['FID_NOA_BELOW_K898'] and 'u32 _h_2 = r0;' in old['FID_NOA_BELOW_K898'],
        newFallbackChecksTagBeforeChoose=new['FID_NOA_BELOW_C896'].index('spin_1(') < new['FID_NOA_BELOW_C896'].index('FID_NT_CHOOSE'),
        newFallbackDoesNotCallKidOrRecurse=not re.search(r'FID_(?:KID|NOA_BELOW)\)', new['FID_NOA_BELOW_C896']),
        newChooseBranches='term_clo(FID_NOA_BELOW_C897, _nd_1)' in new['FID_NOA_BELOW_C896'] and 'term_clo(FID_NOA_BELOW_C900, 0)' in new['FID_NOA_BELOW_C896'],
        newTrueBranchCallsKid='WL_JMP(FID_KID)' in new['FID_NOA_BELOW_C897'],
        newTrueContinuationRecurses='WL_JMP(FID_NOA_BELOW)' in new['FID_NOA_BELOW_K898'],
        newFalseBranchReturnsFalse='r0 = term_pak(CID_FALSE, 0);' in new['FID_NOA_BELOW_C900'] and 'WL_RETN(1);' in new['FID_NOA_BELOW_C900'],
        newFalseBranchHasNoCallsOrAllocation=not re.search(r'FID_|spin_|heap_alloc|task_node', new['FID_NOA_BELOW_C900'].split('WL_OPEN', 1)[1]),
    )
    assert all(checks.values()), checks
    for key, record in inputs.items(): assert pin(paths[key]) == record
    result = dict(kind='phase98-origin-guard-generated-c-shape-audit', complete=True,
                  targetsRun=False, method=pin(__file__), inputs=inputs,
                  recipe=pin(BUILD/'origin-guard-source01/changes.json'),
                  sourceChange=change, physicalLineDelta=len(after.splitlines())-len(before.splitlines()),
                  byteDelta=inputs['newSource']['bytes']-inputs['oldSource']['bytes'],
                  generatedC=shapes, checks=checks,
                  conclusion='New C evaluates the OField predicate before choosing the recursive branch; its false branch returns False without kid, recursion or allocation. Old C evaluates kid and recursion before its tag conjunction.',
                  limitations=['Exact generated-C/source inspection, not a compiler execution or whole-compiler proof.',
                               'Fix extends termination to prior divergent inputs; no equivalence with divergent old behavior is claimed.',
                               'Actual final B1/B2 self, semantic, resource and release gates remain separate.'])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, checks=len(checks), output=pin(args.out))))


if __name__ == '__main__': main()
