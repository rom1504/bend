"""Seal six frozen ordinary-passing binaries for root-only paired timing."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / 'selfhost/build/phase131/field-ceiling-timing01'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


assert not OUT.exists()
inputs = [pin(__file__)]
workloads = []
for family, original, count, prefix in [
    ('uses', 'p131-regions-uses01-candidate-build', 2047, '2\n4094\n'),
    ('packet', 'p131-regions-late02-run-record-transfer-build', 1000000, '1\n1000000\n'),
]:
    variants = []
    for role, directory in [('baseline', original), ('dead-fields', f'p131-field-ceiling-{family}-mask01'),
                            ('nullary-pointer', f'p131-field-ceiling-{family}-null01')]:
        path = ROOT / 'selfhost/build/phase111' / directory / 'report.json'
        report = json.loads(path.read_text())
        assert report['complete'] and report['outputExact']
        inputs.append(pin(path))
        for item in [*report['inputs'], report['binary']]:
            assert pin(item['file']) == item, item['file']
            inputs.append(item)
        if role != 'baseline':
            mode = 'mask' if role == 'dead-fields' else 'null'
            ceiling = ROOT / f'selfhost/build/phase131/field-ceiling-{family}-{mode}01/report.json'
            inputs.append(pin(ceiling))
        binary = report['binary']
        variants.append(dict(name=role, binary=binary,
            command=[binary['file'], '--threads', '1', '--gpu', 'off', '--', str(count)],
            expected=dict(exitCode=0, stdout=dict(kind='prefix-integer-line', prefix=prefix),
                stderr=dict(kind='exact', bytes=0, sha256=hashlib.sha256(b'').hexdigest()))))
    workloads.append(dict(name=family, timeoutSeconds=30, variants=variants))
OUT.mkdir()
(OUT / 'manifest.json').write_text(json.dumps(dict(schema='bend-native-profile-workloads-v1',
    cwd=str(ROOT), inputs=inputs, workloads=workloads,
    scope='Frozen-QBE ceilings only. Exact same runtime and guards; all six ordinary outputs independently checked. No compiler pass or full-compiler claim.',
    calibration='Reuse existing source-frozen calibrations: uses2047 (prior1024 pilot to500ms), packet1000000 (prior100k pilot35ms).'), indent=2) + '\n')
print(json.dumps(dict(complete=True, targetsRun=False, manifest=str(OUT / 'manifest.json'))))
