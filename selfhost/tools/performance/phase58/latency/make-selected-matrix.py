#!/usr/bin/env python3
"""Select the smaller final measurement queue; launch nothing and preserve parents."""
import argparse, copy, hashlib, json, shlex
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RAW = ROOT / 'selfhost/build/phase58'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('matrix', type=Path)
p.add_argument('out', type=Path)
p.add_argument('--retained-baseline', type=Path, default=RAW / 'comparison-shared01/own-source-baseline/report.json')
p.add_argument('--retained-supervisor', type=Path, default=RAW / 'comparison-shared01/own-source-baseline-supervisor/run.json')
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW.resolve()) and not out.exists() and not out.with_suffix('.txt').exists()
inputs = {}
def pin(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''): h.update(block)
    row = dict(file=str(file), sha256=h.hexdigest())
    if isinstance(value, dict): assert row['sha256'] == value['sha256']
    inputs[str(file)] = row
    return row
def read(value): return json.loads(Path(pin(value)['file']).read_text())
matrix = read(a.matrix)
assert matrix['kind'] == 'phase58-final-compiler-measurement-matrix' and matrix['complete'] and not matrix['executed']
assert pin(matrix['producer'])['sha256'] == '89ad4d0be9d8dc220e7be3c97ce911b3841267449312cee635b45c2ee0694465'
for item in matrix['inputs']: pin(item)
recipe = read(matrix['comparison'])
b2 = next(s for s in recipe['suites'] if s['suite'] == 'b2')
old = read(a.retained_baseline)
supervisor = read(a.retained_supervisor)
assert old['kind'] == 'phase58-b2-own-source-emission' and old['complete'] and old['pass']
assert old['mode'] == 'clean' and old['cleanTiming'] and old['byteEquality'] is True
assert supervisor['complete'] and supervisor['returncode'] == 0 and 'stoppedFor' not in supervisor
assert pin(old['b2'])['sha256'] == b2['baseline']['api']['sha256']
assert old['subject'] == b2['baseline']['subject']
assert pin(old['producer'])['sha256'] == '1f65e04939c7dd3d90232e1c18848fb88415b92fce8ac8446fb2a27bfe8e63d6'
assert supervisor['command'][-5:] == [old['producer']['file'], old['binding']['file'], 'baseline', str(a.retained_baseline.resolve().parent), 'clean']
assert supervisor['secondsLimit'] == 420 and supervisor['rssLimitBytes'] == 2048 * 1024**2
commands = []
names = ['b1-prepare', 'b2-prepare', 'b1-clean', 'b2-clean', 'b2-allocation', 'b2-cpu', 'own-source-candidate']
for name in names:
    matches = [row for row in matrix['commands'] if row['name'] == name]
    assert len(matches) == 1
    row = copy.deepcopy(matches[0])
    if name == 'b2-cpu':
        at = row['command'].index('--roles')
        assert row['command'][at + 1] == 'baseline,candidate,typescript'
        row['command'][at + 1] = 'candidate'
        row['workers'] = 1
        row['scope'] = 'Selected B2 lexer CPU attribution only; no fresh old/TS CPU comparison.'
    if name == 'own-source-candidate':
        assert row['command'][-5] == old['producer']['file']
        row['scope'] = 'Fresh selected B2 own-source clean emission with exact B2/B3 oracle; compare only with explicitly retained earlier baseline under the same method. Different source, not fresh consecutive pairing or isolated-pass causality.'
    commands.append(row)
producer = pin(__file__)
for item in list(inputs.values()): assert pin(item) == item
result = dict(kind='phase58-selected-compiler-measurement-subset', complete=True, executed=False,
    producer=producer, parent=pin(a.matrix), commands=commands, inputs=list(inputs.values()),
    retainedBaseline=dict(report=pin(a.retained_baseline), supervisor=pin(a.retained_supervisor),
        seconds=old['seconds'], api=old['b2'], source=old['subject']['source'],
        started=supervisor['started'], finished=supervisor['finished'], freshlyReexecuted=False),
    omitted=['b1-allocation', 'b1-cpu', 'baseline-and-typescript-b2-cpu', 'fresh-own-source-baseline', 'all-own-source-allocation'],
    scope='Two fresh three-round old/new/TS clean matrices, separate B2 old/new/TS lexer allocation, selected B2 lexer CPU, and selected own-source clean emission. Historical B1 allocation is not selected-image evidence. Retained own-source baseline is explicitly dated; no retry of the failed baseline allocation capture.')
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(result, indent=2) + '\n')
out.with_suffix('.txt').write_text('\n\n'.join('# ' + r['name'] + '\n' + shlex.join(r['command']) for r in commands) + '\n')
print(json.dumps(dict(plan=pin(out), commands=len(commands), executed=False)))
