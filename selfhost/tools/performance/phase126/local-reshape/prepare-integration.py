"""Pinned one-helper extension; source composition only, no checking/building.

The generic Phase126 composer intentionally does not admit new private imports.
This narrow authority permits the exact reviewed transpose2 import module and
requires every previous hook implementation to survive as an unchanged alias.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
PAT = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
ALIASES = {'p121f_selected': 'p126lr_previous_selected',
           'p113e_scalar_safe': 'p126lr_previous_scalar_safe',
           'p113e_stmt': 'p126lr_previous_stmt'}


def pin(p):
    p = Path(p).resolve()
    data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(p):
    assert pin(p['file']) == p, 'Changed input: ' + p['file']


def blocks(text):
    hits = list(PAT.finditer(text))
    return {m[1]: text[m.start():hits[i + 1].start() if i + 1 < len(hits) else len(text)]
            for i, m in enumerate(hits)}


def norm(text):
    return '\n'.join(line.rstrip() for line in text.splitlines()
                     if line.strip() and not line.lstrip().startswith('#'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    authority_file = HERE / 'manifest03.json'
    authority = json.loads(authority_file.read_text())
    source = json.loads(args.source.read_text())
    assert source['complete'] and not authority['selected']
    inputs = [pin(__file__), pin(authority_file), pin(args.source), source['source'],
              *source['inputs'], *authority['modules'], authority['runtime']]
    for entry in inputs:
        verify(entry)
    old = Path(source['source']['file']).read_text()
    before = blocks(old)
    recognizer, integration, controls = [Path(x['file']).read_text() for x in authority['modules']]
    for name, text in blocks(recognizer).items():
        assert name in before and norm(before[name]) == norm(text), 'Recognizer mismatch: ' + name
    added = blocks(integration)
    assert not (set(added) & set(blocks(controls))), 'Duplicate control names'
    added.update(blocks(controls))
    assert set(before) & set(added) == set(ALIASES), 'Unexpected declaration replacement'
    for original, alias in ALIASES.items():
        expected = before[original].replace('def ' + original + '(', 'def ' + alias + '(', 1)
        assert norm(expected) == norm(added[alias]), 'Previous implementation lost: ' + original
    hits = list(PAT.finditer(old))
    pieces = [old[:hits[0].start()]]
    for i, match in enumerate(hits):
        original = old[match.start():hits[i + 1].start() if i + 1 < len(hits) else len(old)]
        pieces.append(added[match[1]].rstrip() + '\n\n' if match[1] in added else original)
    pieces.extend('\n' + text for name, text in added.items() if name not in before)
    result = ''.join(pieces)
    after = blocks(result)
    assert set(after) == set(before) | set(added), 'Declaration inventory changed'
    for name, text in before.items():
        assert norm(after[name]) == norm(added[name] if name in ALIASES else text), name
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase126') and not out.exists()
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(result)
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    report = dict(complete=True, checked=False, targetsRun=False, source=pin(out / 'compiler.bend'),
                  parent=source['source'], inputs=inputs, overrides=list(ALIASES),
                  runtimeExtension=dict(symbol='p126_rt_transpose2', signature=['state*', 'U64', 'U64', 'CtorId(arity2)'],
                                        result='U64', runtime=authority['runtime'], authority=pin(authority_file)),
                  unchangedAliases=ALIASES, allOtherOriginalDeclarationsUnchanged=True,
                  scope='Exact pinned whole-worker source certificate and additive one-helper import. Original fallback checks remain exact aliases; original N111 verifier, request/runtime admission and all other declaration bodies unchanged. No target runs or qualification.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['source']))


if __name__ == '__main__':
    main()
