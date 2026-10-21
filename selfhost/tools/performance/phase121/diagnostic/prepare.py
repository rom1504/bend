"""Construct pinned source-only ceiling diagnostics; never modify a frozen input.

These are source-specialized experiments, not a compiler pass or benchmark result.
Each original wrapper, expected value, timing interval and iteration count is kept.
"""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
MANIFEST = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'


def pin(path):
    raw = path.read_bytes()
    return {'file': str(path), 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


rows = []
for case in json.loads(MANIFEST.read_text())['cases']:
    name = case['name']
    if name not in ['coverage-list-pipeline-128', 'coverage-list-pipeline-512',
                    'coverage-map-churn-32', 'coverage-map-churn-128']:
        continue
    source = Path(case['source']['file'])
    assert pin(source) == case['source']
    text = source.read_text()
    if 'list-pipeline' in name:
        old = '  suma(dbl(keep_gt1(p37.list(U32.to_nat(size), seed))), 0)'
        variants = [
            ('mapfold', 'list-mapfold-helper.bend',
             '  p121.mapfold(keep_gt1(p37.list(U32.to_nat(size), seed)), 0)'),
            ('full', 'list-full-helper.bend', '  p121.pipeline(U32.to_nat(size), seed, 0)'),
        ]
    else:
        old = '  p37.map.digest(Map.to_list(&2, U32, m), 2166136261)'
        variants = [('treefold', 'map-digest-helper.bend', '  p121.map_digest(m, 2166136261)')]
    assert text.count(old) == 1
    prefix, suffix = text.split('# Phase93:', 1)
    for variant, helper_name, replacement in variants:
        helper = HERE / helper_name
        target = HERE / (name + '-' + variant + '.bend')
        result = prefix.replace(old, replacement) + '\n' + helper.read_text() + '\n# Phase93:' + suffix
        # Wrapper validation and timing code must remain byte-identical.
        assert result.split('# Phase93:', 1)[1] == suffix
        if target.exists():
            assert target.read_text() == result, f'refuse to overwrite {target}'
        else:
            target.write_text(result)
        rows.append({'name': name, 'variant': variant, 'source': pin(target),
                     'original': case['source'], 'helper': pin(helper),
                     'runtimeArgs': case['runtimeArgs'], 'expectedStdout': case['expectedStdout'],
                     'expectedStdoutEvidence': case['expectedStdoutEvidence'],
                     'manifestRepetitions': case['repetitions'], 'manifestWarmups': case['warmups'],
                     'wrapperSuffixSha256': hashlib.sha256(suffix.encode()).hexdigest()})
out = {'kind': 'phase121-source-specialized-ceiling-diagnostics', 'targetRuns': False,
       'compilerTransformation': False, 'manifest': pin(MANIFEST), 'generator': pin(Path(__file__)),
       'cases': rows}
target = HERE / 'manifest.json'
body = json.dumps(out, indent=2) + '\n'
if target.exists():
    assert target.read_text() == body, 'refuse to overwrite manifest'
else:
    target.write_text(body)
print(json.dumps({'sources': len(rows), 'manifest': str(target), 'targetRuns': False}))
