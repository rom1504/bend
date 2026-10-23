"""Copy exact selected usage-query declarations into a bounded native proxy."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PAT = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
TOKEN = re.compile(r'\b[A-Za-z_][A-Za-z0-9_.]*\b')


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def blocks(text, combine=False):
    hits = list(PAT.finditer(text))
    result = {}
    for i, hit in enumerate(hits):
        value = text[hit.start():hits[i + 1].start() if i + 1 < len(hits) else len(text)]
        if hit[1] in result and not combine:
            raise ValueError('Duplicate declaration: ' + hit[1])
        result[hit[1]] = result.get(hit[1], '') + value
    return result


def words(text):
    # Comments and quoted strings cannot introduce declaration dependencies.
    clean = re.sub(r'"(?:[^"\\]|\\.)*"', '""', text)
    clean = '\n'.join(line.split('#', 1)[0] for line in clean.splitlines())
    return set(TOKEN.findall(clean))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase131'):
        raise ValueError('Fresh Phase131 output required')
    selection_path = ROOT / 'implementation/phase130/candidate.json'
    selection = json.loads(selection_path.read_text())
    assert selection['complete'] and selection['nativeQualified']
    parent = selection['source']
    assert pin(parent['file']) == parent
    original = blocks(Path(parent['file']).read_text(), combine=True)
    paths = [HERE.parent / 'laws/production.bend', HERE / 'summary-v02.bend',
             HERE / 'controls-v01.bend', HERE / 'kernel-v02.bend']
    extra = {}
    for path in paths:
        declarations = blocks(path.read_text())
        assert not (set(extra) & set(declarations))
        extra.update(declarations)
    assert set(extra) & set(original) == {'main'}
    needed = (set.union(*(words(body) for body in extra.values())) & set(original)) - set(extra)
    while True:
        expanded = needed | ((set.union(*(words(original[name]) for name in needed)) & set(original)) - set(extra))
        if expanded == needed:
            break
        needed = expanded
    # A surprise dependency explosion is a failed extraction, not permission to
    # acquire another full compiler image.
    assert len(needed) <= 40, sorted(needed)
    names = [name for name in original if name in needed]
    common = 'import Base\n\n' + '\n'.join(original[name] for name in names)
    inputs = [pin(__file__), pin(selection_path), parent, *[pin(path) for path in paths]]
    out.mkdir(parents=True)
    variants = {}
    for label in ['original', 'summary']:
        declarations = dict(extra)
        if label == 'summary':
            declarations['p131k_query'] = ('@unsafe\ndef p131k_query(term: KTerm, count: Nat) -> U32:\n'
                                           '  p131k_summary(p131u_build(term),count,0,0)\n')
        source = common + '\n' + '\n'.join(declarations.values())
        assert (words(source) & set(original)) - set(blocks(source, combine=True)) == set()
        folder = out / label
        folder.mkdir()
        (folder / 'main.bend').write_text(source)
        variants[label] = dict(source=pin(folder / 'main.bend'), changed=[] if label == 'original' else ['p131k_query'])
    def digest(value):
        acc = 0
        for _ in range(64):
            acc = (acc * 17 + value) & 0xffffffff
        return (acc * 100) & 0xffffffff
    oracle = [str(digest(4)), str(digest(4)), str(digest(3))]
    (out / 'expected.txt').write_text('\n'.join(oracle) + '\n')
    report = dict(complete=True, checked=False, targetsRun=False, inputs=inputs,
                  parent=parent, copiedDeclarations=names, variants=variants,
                  expected=pin(out / 'expected.txt'), oracle=oracle,
                  scope='Exact selected nq_uses/min/NWPattern and representation helpers; shared test bodies. '
                  'Only p131k_query differs. Includes summary building on every iteration. '
                  'Three 64-ID families: ordinary single-use, exact two-arm choice, NW rows. '
                  'This synthetic proxy is a discriminator, not actual compiler-request evidence. '
                  'Finite controls, real consumer equivalence and complete request QBE remain separate gates.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, variants=variants, oracle=oracle)))


if __name__ == '__main__':
    main()
