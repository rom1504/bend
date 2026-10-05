#!/usr/bin/env python3
"""Freeze narrow Phase47 publication derivatives; never package or execute targets."""
import argparse
import ast
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
TOOLS = HERE.parent
PARENTS = {
    'freeze-current.py': (TOOLS / 'phase47/freeze-current.py', 'b4e8956bbcf861934c36cafdd02f2b8f1acb264f3e3d543b37d4be11af53320b'),
    'publish-archive-parts.py': (TOOLS / 'phase47/evidence/publish-archive-parts.py', '20f92ae81c6d1a0857c843183848880780ee2f28d1553837694999771fa43327'),
}


def identity(p):
    data = p.read_bytes()
    return dict(file=str(p.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True, help='Fresh Phase48 raw derivation directory')
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase48') and not out.exists()
    changes = {
        'freeze-current.py': [
            ('HERE = Path(__file__).resolve().parent', f'HERE = Path({str(HERE)!r})'),
            ("default='e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c'", "default='28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'"),
            ("default='4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26'", "default='880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'"),
            ("assert not target.is_relative_to(TOOLS / 'phase45'), 'Phase45 bundles are immutable'",
             "assert any(target.is_relative_to(prefix) for prefix in [TOOLS / 'phase48', TOOLS.parents[2] / 'selfhost/build/phase48']), 'Only fresh Phase48 outputs are permitted'"),
            ("protected = {str(p.parent): inventory(p.parent) for p in (TOOLS / 'phase45').glob('*/manifest.json')}",
             "protected = {str(p.parent): inventory(p.parent) for phase in ['phase45', 'phase46', 'phase47'] for p in (TOOLS / phase).glob('*/manifest.json')}"),
            ("kind='phase47-portable-candidate-label-derivation'", "kind='phase48-portable-candidate-label-derivation'"),
            ("kind='phase47-portable-benchmark-publication'", "kind='phase48-portable-benchmark-publication'"),
            ("'Phase45 bundle changed'", "'Historical bundle changed'"),
        ],
        'publish-archive-parts.py': [
            ('Phase47 v1: split', 'Phase48 v1: split'),
            ("here=Path(__file__).resolve().parent;dest=here/'raw';meta=dest/'archive.json'",
             f"here=Path({str(HERE / 'evidence')!r});dest=here/'raw';meta=dest/'archive.json'"),
            ("PARENT_SHA256='ac467d13d08ee4c28c5c9c21634831e16112dabb0285de4f69b9373819564d19'",
             "PARENT_SHA256='20f92ae81c6d1a0857c843183848880780ee2f28d1553837694999771fa43327'"),
            ("Path(a['rawRoot']).name=='phase47','Requires the Phase47 raw capsule'",
             "Path(a['rawRoot']).resolve()==here.parents[4]/'selfhost/build/phase48','Requires the exact Phase48 raw capsule'"),
            ("'kind':'phase47-verified-archive-parts'", "'kind':'phase48-verified-archive-parts'"),
            ("'parent':'selfhost/tools/performance/phase45/evidence/publish-archive-parts.py'",
             "'parent':'selfhost/tools/performance/phase47/evidence/publish-archive-parts.py'"),
            ('Phase47 identity/destination;', 'Phase48 identity/destination;'),
            ('closed Phase47 full raw capsule.', 'closed Phase48 full raw capsule.'),
        ],
    }
    prepared = []
    for name, (file, sha) in PARENTS.items():
        parent = identity(file)
        assert parent['sha256'] == sha
        text = file.read_text()
        for before, after in changes[name]:
            assert text.count(before) == 1, (name, before)
            text = text.replace(before, after, 1)
        ast.parse(text)
        prepared.append((name, file, parent, text))
    out.mkdir(parents=True)
    rows = []
    for name, file, parent, text in prepared:
        (out / ('parent-' + name)).write_bytes(file.read_bytes())
        (out / name).write_text(text)
        assert identity(file) == parent
        rows.append(dict(parent=parent, preservedParent=identity(out / ('parent-' + name)),
                         derived=identity(out / name), changes=changes[name]))
    result = dict(kind='phase48-publication-method-derivation', complete=True,
        producer=identity(Path(__file__)), derivatives=rows,
        compilerExecuted=False, generatedProgramsExecuted=False, bundlesPublished=False, archiveCreated=False,
        scope='Metadata, exact starting compiler, destination confinement and historical-bundle preservation updates only. Candidate audit, byte/reopen checks, current reader verification, 40 MiB parts and concatenation verification retained. Root runs each derived tool separately on CPU0 after timing stops; raw closure is a separate explicit declaration.')
    with (out / 'derivation.json').open('x') as f:
        json.dump(result, f, indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, tools=[str(out / name) for name in PARENTS], bundlesPublished=False, archiveCreated=False)))


if __name__ == '__main__':
    main()
