#!/usr/bin/env python3
"""Count frozen compiler modules only; execute no compiler or native target."""
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
KEYS = ('physicalLines', 'codeLines', 'definitions', 'laws', 'types', 'utf8Bytes')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pin(path):
    return {'file': str(path.relative_to(ROOT)), 'sha256': digest(path)}


def census(relative):
    build = ROOT / relative
    attempt_path = build / 'attempt.json'
    attempt = json.loads(attempt_path.read_text())
    snapshot = build / 'snapshot'
    old_root = Path(attempt['snapshot']['root'])
    frozen = {str(Path(row['frozen']['file']).relative_to(old_root)):
              row['frozen']['sha256'] for row in attempt['snapshot']['sources']}
    manifest_path = snapshot / 'src/compiler.json'
    assert digest(manifest_path) == frozen['src/compiler.json']
    modules = json.loads(manifest_path.read_text())['modules']
    assert len(modules) == len(set(modules))
    rows = {}
    for name in modules:
        assert name.startswith('src/') and name.endswith('.bend')
        path = snapshot / name
        assert path.resolve().is_relative_to(snapshot.resolve())
        data = path.read_bytes()
        assert digest(path) == frozen[name], name
        lines = data.decode('utf-8').splitlines()
        metrics = dict(physicalLines=len(lines),
                       codeLines=sum(bool(s.strip()) and not s.lstrip().startswith('#')
                                     for s in lines),
                       definitions=sum(bool(re.match(r'^def\s', s)) for s in lines),
                       laws=sum(bool(re.match(r'^law\s', s)) for s in lines),
                       types=sum(bool(re.match(r'^type\s', s)) for s in lines),
                       utf8Bytes=len(data))
        rows[name] = dict(sha256=frozen[name], **metrics)
    actual = {str(p.relative_to(snapshot)) for p in (snapshot / 'src').rglob('*.bend')}
    assert set(modules).issubset(actual)
    return dict(attempt=pin(attempt_path), manifest=pin(manifest_path),
                apiSha256=attempt['api']['sha256'],
                excludedSnapshotBend=sorted(actual - set(modules)), modules=rows,
                totals=dict(modules=len(rows), **{k: sum(r[k] for r in rows.values())
                                                  for k in KEYS}))


baseline = census('selfhost/build/phase67/scalars-build01')
candidate = census('selfhost/build/phase68/inline-build09')
report = dict(kind='phase68-frozen-module-census', version=1, complete=True,
              scope='Manifest compiler Bend modules only; no targets executed or release qualified.',
              method='UTF-8 splitlines; code excludes blank and full-line # comments; '
                     'def/law/type count anchored declarations. Same counting rules as Phase66.',
              exclusions='Assembled compiler, fixture modules, proposals, tests, docs, '
                         'host tooling, runtime C/JS and generated images.',
              producer=pin(Path(__file__).resolve()), baseline=baseline, candidate=candidate,
              delta={k: candidate['totals'][k] - baseline['totals'][k]
                     for k in candidate['totals']})
with Path(sys.argv[1]).open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps({k: report[k]['totals'] for k in ('baseline', 'candidate')} |
                 {'delta': report['delta']}, indent=2))
