#!/usr/bin/env python3
"""Preserve the pending constructor field's seal policy in private TRMC state."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve(); raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--parent', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    parent = json.loads(args.parent.read_text())
    assert parent['complete'] and parent['inverseExact']
    for item in [parent['source'], parent['candidate']]:
        assert pin(item['file']) == item
    source = Path(parent['candidate']['file']).read_text()
    original = source; edits = []

    def replace(old, new):
        nonlocal source
        assert source.count(old) == 1, (old, source.count(old))
        at = source.index(old)
        edits.append(dict(offset=at, old=old, new=new))
        source = source[:at] + new + source[at + len(old):]

    replace('def ntr_emitted(+book: List<&2, KDef>, +fields: U32,',
            'def ntr_emitted(+book: List<&2, KDef>, +ctor: String, +fields: U32,')
    replace('  ntr_emitted(book, ix(t), ntr_drop_words(words, ix(t)), target,',
            '  ntr_emitted(book, nm(t), ix(t), ntr_drop_words(words, ix(t)), target,')
    replace('e.mem[nf_out[1]] = rfc_seal(e, " ++ node ++ "); } else {',
            'e.mem[nf_out[1]] = nf_out[4] ? rfc_seal(e, " ++ node ++ ") : " ++ node ++ "; } else {')
    replace('++ U32.show(fields) ++ ";\\n",\n        nf_call_local',
            '++ U32.show(fields) ++ ";\\n" ++ ntr_hole_policy(ctor),\n        nf_call_local')
    replace('e.mem[nf_out[1]] = rfc_seal(e, " ++ nc_head(words) ++ "); } else {',
            'e.mem[nf_out[1]] = nf_out[4] ? rfc_seal(e, " ++ nc_head(words) ++ ") : " ++ nc_head(words) ++ "; } else {')
    replace('Term ntr_state[4] = { TERM_HOLE, 0, 0, 0 };',
            'Term ntr_state[5] = { TERM_HOLE, 0, 0, 0, 0 };')
    helper = '\n' + (HERE / 'hole-policy.bend').read_text()
    edits.append(dict(offset=len(source), old='', new=helper))
    source += helper
    changes = parent['changes'] + edits
    inverse = source
    for row in reversed(changes):
        at = row['offset']; assert inverse[at:at + len(row['new'])] == row['new']
        inverse = inverse[:at] + row['old'] + inverse[at + len(row['new']):]
    assert inverse == Path(parent['source']['file']).read_text()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    dest = out / 'compiler.bend'; dest.write_text(source)
    report = dict(complete=True, targetsRun=False, releaseQualified=False,
        method=pin(__file__), helpers=pin(HERE / 'hole-policy.bend'),
        parentRecipe=pin(args.parent), parentCandidate=parent['candidate'],
        source=parent['source'], candidate=pin(dest), changes=changes, addedChanges=edits,
        inverseExact=True, physicalLineDelta=len(source.splitlines()) - len(original.splitlines()),
        scope='Private fifth TRMC state slot records the pending destination constructor field policy. '
              'Both recursive and terminal publication use it before setting the next hole policy. '
              'Policy exactly follows ne_ctor_node hot=True, including COLD_CTORS/HOT_CID and '
              'COLD_USER_CTORS fallback. No public ABI, admission, argument order or cache-ownership change.')
    (out / 'changes.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ['candidate', 'physicalLineDelta']}))


if __name__ == '__main__':
    main()
