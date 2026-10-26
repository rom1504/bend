"""Create root-only matched product-retry kernel jobs; never execute a target."""
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve()
    body = path.read_bytes()
    return dict(file=str(path), bytes=len(body), sha256=hashlib.sha256(body).hexdigest())


out = ROOT/'selfhost/build/phase144/product-retry-native-plan01'
assert not out.exists()
original = ROOT/'selfhost/build/phase144/verifier-lexer-native01/manifest.json'
old = json.loads(original.read_text())
source, expected = old['variants']['new']['source'], old['variants']['new']['expected']
assert Path(expected['file']).read_bytes() == b'2048\n'
seed_file = ROOT/'selfhost/build/phase144/integrated-hosted-lexer01/input.json'
seed = json.loads(seed_file.read_text())
selected_file = ROOT/'implementation/phase143/candidate.json'
selected = json.loads(selected_file.read_text())
census_file = ROOT/'selfhost/build/phase144/product-retry-census02/report.json'
census = json.loads(census_file.read_text())
assert census['complete'] and census['allCandidatesVerified']
apis = {mode: ROOT/'selfhost/build/phase111'/name/'report.json' for mode, name in
        [('old', 'p144-integrated-api01'), ('new', 'p144-product-retry-api01')]}
inputs = [pin(__file__), pin(original), pin(seed_file), pin(selected_file), pin(census_file),
          source, expected, seed['base'], seed['carrier'], selected['runtime'],
          pin(HERE/'product-retry-native-v01.mjs'), pin(HERE/'product-retry-time-v01.py'),
          pin(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),
          pin(ROOT/'selfhost/tools/performance/phase111/guard.py'),
          pin(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun')]
for f in apis.values():
    ar = json.loads(f.read_text())
    assert ar['complete'] and ar['checked']
    inputs += [pin(f), ar['api'], *ar['inputs']]
inputs = list({x['file']: x for x in inputs}.values())
for x in inputs:
    assert pin(x['file']) == x
emission = ROOT/'selfhost/build/phase144/product-retry-native-emission01'
timing = ROOT/'selfhost/build/phase144/product-retry-native-times01'
assert not emission.exists() and not timing.exists()
variants = {}
for mode in ['old', 'new']:
    build = ROOT/'selfhost/build/phase111'/f'p144-product-retry-{mode}-build01'
    assert not build.exists()
    variants[mode] = dict(qbe=str(emission/(mode+'.ssa')), build=str(build/'report.json'), binary=str(build/'program'))
out.mkdir(parents=True)
manifest = dict(kind='phase144-product-retry-native-plan', complete=True, targetsRun=False,
                inputs=inputs, source=source, expected=expected, runtime=selected['runtime'],
                base=seed['base'], carrier=seed['carrier'], stamp=seed['stamp'],
                apis={k: str(v) for k, v in apis.items()}, census=pin(census_file),
                emission=str(emission/'report.json'), variants=variants,
                scope='Unchanged compact V02 complete Lexer verifier workload. Checked baseline integrated source01 versus exact-prefix additive retry. No production selection change or fresh API acquisition.')
mf = out/'manifest.json'
mf.write_text(json.dumps(manifest, indent=2)+'\n')
jobs = []


def job(name, command, seconds):
    jobs.append(dict(name=name, seconds=seconds+20, command=[sys.executable, '-B',
        str(ROOT/'selfhost/tools/performance/phase111/guard.py'), '--out', str(out/(name+'-guard')),
        '--seconds', str(seconds), '--cpu', '3', '--rss-mib', '3072', '--available-mib', '16384',
        '--file-mib', '100', '--', *map(str, command)]))


job('matched-emission', [ROOT/'selfhost/.bootstrap/bun-1.4.3/bun',
    HERE/'product-retry-native-v01.mjs', mf, emission], 180)
for mode in ['old', 'new']:
    v = variants[mode]
    job(mode+'-build', [sys.executable, '-B', ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
        '--source', v['qbe'], '--runtime', selected['runtime']['file'],
        '--out', Path(v['build']).parent, '--expected', expected['file'], '--seconds', '45'], 70)
job('adaptive-paired-timing', [sys.executable, '-B', HERE/'product-retry-time-v01.py',
    '--plan', mf, '--out', timing], 80)
(out/'jobs.json').write_text(json.dumps(dict(kind='phase144-product-retry-native-root-jobs', complete=True,
    targetsRun=False, inputs=[pin(mf)], gate='Run sequentially; each predecessor receipt must pass. Ordinary2048 oracle gates each binary. Adaptive timing1pair then3total iff first executions both<3s.',
    jobs=jobs), indent=2)+'\n')
print(json.dumps(dict(plan=pin(out/'jobs.json'), source=source, jobs=len(jobs))))
