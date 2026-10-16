#!/usr/bin/env python3
"""One guarded discovery request; --baseline selects a separate baseline-only run."""
import argparse, hashlib, importlib.util, json, re, shutil, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
SUPPORT = ROOT / 'selfhost/tools/performance/programs/support.py'
spec = importlib.util.spec_from_file_location('discovery_guard', SUPPORT)
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
read = lambda p: json.loads(Path(p).read_text())
def pin(p):
    p = Path(p).resolve(); b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
inputs = {}
def bind(p):
    old = p if isinstance(p, dict) else None
    row = pin(old['file'] if old else p)
    if old: assert all(row[k] == old[k] for k in ['file', 'bytes', 'sha256']), row['file']
    assert inputs.setdefault(row['file'], row) == row
    return row
def unchanged():
    for row in inputs.values(): assert pin(row['file']) == row, row['file']

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--discovery', type=Path, required=True)
g = p.add_mutually_exclusive_group(required=True)
g.add_argument('--image', type=Path); g.add_argument('--baseline', type=Path)
p.add_argument('--build-guard', type=Path, help='Candidate only; defaults to IMAGE.parent/build')
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); image = (a.image or a.baseline).resolve(); out = a.out.resolve()
assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
assert not (a.baseline and a.build_guard)
out.mkdir(parents=True); discovery = read(bind(a.discovery)['file'])
assert discovery['kind'] == 'phase99-discovery-prepared-C' and discovery['complete'] and not discovery.get('error')
for row in discovery['inputs']: bind(row)
source, oracle = bind(discovery['source']), bind(discovery['output'])
bind(__file__); bind(SUPPORT); binary = bind(image)
transport_file = ROOT / 'selfhost/build/phase90/runtime-accessor-transport02/transport.json'
assert bind(transport_file)['sha256'] == '07c49e15a8cfce79b12a2909edd4015876725bc2f099d855b8dcd58ef21d5510'
t = read(transport_file)
for row in [t['base'], t['runtime'], t['template'], *t['parts'], *t['effects']]: bind(row)
prior = ROOT / 'selfhost/build/phase99/static-qualification-plan01'
original = read(bind(prior / 'b2-self/execution/guard/process.json')['file'])
assert original['complete'] and original['returncode'] == 0
argv = original['command'][7:].copy()
assert len(argv) == 15 and argv[1:7] == ['--threads', '1', '--gpu', 'off', '--', 'phase90-native']
assert argv[8:11] == [t['base']['file'], t['runtime']['file'], t['effectsDir']] and argv[12] == '1'
carrier = bind(argv[13])
assert carrier['sha256'] == '07af8cddb84820d861fc9f5d9475907754a64a9319de7d597c925149d8b186a7'
build = None
if a.image:
    directory = (a.build_guard or image.parent / 'build').resolve()
    build = read(bind(directory / 'process.json')['file'])
    assert build['complete'] and build['returncode'] == 0 and not build.get('stoppedFor') and not build.get('interrupted')
    old_build = read(bind(prior / 'b2-build/process.json')['file'])['command'][7:]
    expected = old_build.copy(); expected[4] = oracle['file']; expected[6] = str(image)
    assert build['command'][7:] == expected, 'Require the same Clang/O2 command and exact discovery C'
    build_inputs = read(bind(directory / 'inputs.json')['file'])
    for row in build_inputs: bind(dict(file=row['path'], bytes=row['bytes'], sha256=row['sha256']))
    assert any(x['path'] == oracle['file'] and x['sha256'] == oracle['sha256'] and x['bytes'] == oracle['bytes'] for x in build_inputs)
argv[0], argv[7], argv[11] = str(image), source['file'], str(out / 'output')
command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase98', 'taskset', '-c', '3', *argv]
report = dict(kind='phase99-discovery-native-request', complete=False, passed=False, releaseQualified=False,
    role='baseline' if a.baseline else 'candidate', source=source, binary=binary, oracle=oracle,
    discovery=pin(a.discovery), build=build, command=command, inputs=list(inputs.values()),
    scope='One cached-Base discovery request. Request clock excludes preparation/output writing; process wall includes them. No qualified B1/B2 chain or promotion claim.')
S.save(out / 'report.json', report)
try:
    assert shutil.disk_usage(ROOT).free > 210 * 1024**2
    unchanged()
    with S.ExecutionGuard(rss_mib=4096, available_mib=16384) as guard:
        process = guard.run(command, out / 'guard', time.monotonic() + 300)
    report['process'] = process
    report['raw'] = [pin(out / 'guard' / name) for name in ['process.json', 'stdout.log', 'stderr.log']]
    stdout = (out / 'guard/stdout.log').read_text(); stderr = (out / 'guard/stderr.log').read_text()
    diagnostic = re.sub(r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n', '', stderr, flags=re.M)
    (out / 'diagnostic.txt').write_text(diagnostic)
    report.update(diagnostic=diagnostic, diagnosticFile=pin(out / 'diagnostic.txt'), diagnosticExact=diagnostic == discovery['verdict'] + '\n' and not stdout)
    clocks = re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$', stderr, re.M)
    report['clocks'] = clocks; output = out / 'output.1.c'
    if output.exists():
        report['output'] = pin(output)
        report['exactC'] = output.read_bytes() == Path(oracle['file']).read_bytes()
    if len(clocks) == 1: report.update(requestMs=int(clocks[0][1]), processWallMs=process['wallSeconds'] * 1000)
    unchanged(); report['inputsUnchanged'] = True
    assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')
    assert len(clocks) == 1 and clocks[0][0] == '1' and output.exists() and report['diagnosticExact']
    assert 0 < report['requestMs'] <= report['processWallMs'] + 2
    if a.image: assert report['exactC'], 'Native discovery image must reproduce entire JS discovery C'
    report.update(complete=True, passed=True)
except BaseException as error:
    report['error'] = repr(error); raise
finally:
    report['inputs'] = list(inputs.values()); S.save(out / 'report.json', report)
    print(json.dumps({k: report.get(k) for k in ['role', 'complete', 'requestMs', 'processWallMs', 'exactC', 'diagnosticExact', 'error']}), flush=True)
