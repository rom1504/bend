"""Freeze one-declaration range policy and root-only three-family comparison."""
import importlib.util
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('C', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
out = ROOT/'selfhost/build/phase144/range-skip-source01'
assert not out.exists()
parent = ROOT/'selfhost/build/phase144/integrated-source01/manifest.json'
pm = json.loads(parent.read_text())
assert pm['complete'] and pm['source'] == C.pin(pm['source']['file'])
assert pm['source']['sha256'] == '992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b'
module = HERE/'range-skip-v01.bend'
text, added, protected = C.compose(Path(pm['source']['file']).read_text(),
                                  [module.read_text()], {'p114s_ranges'}, set())
assert not added
out.mkdir()
source = out/'compiler.bend'
source.write_text(text)
(out/'module.bend').write_bytes(module.read_bytes())
manifest = dict(kind='phase144-optional-outer-range-skip', complete=True, checked=False,
    targetsRun=False, selected=False, source=C.pin(source), inputs=[C.pin(__file__), C.pin(C.__file__),
    C.pin(parent), pm['source'], C.pin(module)], overrides=['p114s_ranges'], added=[],
    protectedDeclarationsUnchanged=protected,
    scope='Optional pass policy, not byte-preserving cleanup: no outer range transform/commit; incoming and independent final verifiers and original inline pipeline remain exact.')
(out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
api = ROOT/'selfhost/build/phase111/p144-range-skip-api01'
assert not api.exists()
corpus_file = ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
corpus = json.loads(corpus_file.read_text())
selected_file = ROOT/'selfhost/build/phase131/combined-programs01/selected-emission.json'
runtime_file = ROOT/'selfhost/build/phase131/combined-programs01/runtime/report.json'
runtime = json.loads(runtime_file.read_text())
assert runtime['complete']
names = ['lexer', 'coverage-map-churn-128', 'coverage-closures-256']
cases = []
for name in names:
    original = next(x for x in corpus['cases'] if x['name'] == name)
    retained = next(x for x in runtime['builds'] if x['name'] == name)['report']
    br = json.loads(Path(retained['file']).read_text())
    qbe = next(x for x in br['inputs'] if x['file'].endswith('.ssa'))
    cases.append({**{k: original[k] for k in ['name', 'family', 'source', 'expectedStdout',
        'expectedStdoutEvidence', 'runtimeArgs', 'repetitions', 'warmups']},
        'stdoutEvidence': original['expectedStdoutEvidence'], 'retainedQbe': qbe,
        'retainedBuild': retained,
        'historicalArgumentVector': list(map(str, [original['repetitions'], original['warmups'], *original['runtimeArgs']])),
        'scope': 'Exact frozen benchmark45 manifest01 source and counts; compare current binaries only.'})
    for p in [original['source'], original['expectedStdoutEvidence'], retained, qbe]:
        assert C.pin(p['file']) == p
cases_file = HERE/'range-skip-bench-cases-v01.json'
assert not cases_file.exists()
cases_file.write_text(json.dumps(dict(complete=True, inputs=[C.pin(corpus_file), C.pin(selected_file), C.pin(runtime_file)], cases=cases), indent=2)+'\n')

# Derive bounded orchestration only. No compiler transformation is implemented
# by these host tools; all semantic lowering stays in the checked Bend API.
append = ROOT/'selfhost/tools/performance/phase144/emission/string-append'
derivations = []
for name, replacements in [
    ('bench-build-v01.py', [('parents[6]', 'parents[5]'),
       ("HERE/'bench-cases-v01.json'", "HERE/'range-skip-bench-cases-v01.json'"),
       ('p144-append-bench-', 'p144-range-skip-bench-'),
       ('phase144-append-benchmark-builds', 'phase144-range-skip-benchmark-builds')]),
    ('bench-time-v01.py', [('parents[6]', 'parents[5]'),
       ("HERE/'bench-cases-v01.json'", "HERE/'range-skip-bench-cases-v01.json'"),
       ("len(b['smokes'])==8", "len(b['smokes'])==6"),
       ('rounds=4', 'rounds=3'), ('range(4)', 'range(3)'),
       ('phase144-append-frozen-count-screen', 'phase144-range-skip-frozen-count-screen'),
       ('Four-case diagnostic subset, four balanced baseline/candidate pairs.',
        'Three-case diagnostic subset, three alternating baseline/candidate pairs.')])]:
    original = append/name
    derived = HERE/('range-skip-'+name)
    assert not derived.exists()
    body = original.read_text()
    for before, after in replacements:
        assert before in body, before
        body = body.replace(before, after)
    derived.write_text(body)
    derivations.append(dict(original=C.pin(original), derived=C.pin(derived), replacements=replacements))
(out/'orchestration-derivation.json').write_text(json.dumps(dict(complete=True, targetsRun=False,
    derivations=derivations), indent=2)+'\n')
baseline_api = ROOT/'selfhost/build/phase111/p144-integrated-api01/report.json'
bun = ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
emit = append/'emit-v01.mjs'
jobs = []


def job(name, cmd, seconds):
    jobs.append(dict(name=name, seconds=seconds+20, command=[sys.executable, '-B',
        str(ROOT/'selfhost/tools/performance/phase111/guard.py'), '--out', str(out/(name+'-guard')),
        '--seconds', str(seconds), '--cpu', '3', '--rss-mib', '3072', '--available-mib', '16384',
        '--file-mib', '100', '--', *map(str, cmd)]))


job('checked-api', [sys.executable, '-B', ROOT/'selfhost/tools/performance/phase111/check-api.py',
    '--source', source, '--out', api, 'p88_cache_prepare', 'p86_plan', 'p134e_plan', 'p134e_begin',
    'p134e_next', 'p114s_ranges', 'p134v_controls', 'p114st_controls'], 120)
emissions = {}
for role, ar in [('baseline', baseline_api), ('candidate', api/'report.json')]:
    dest = ROOT/'selfhost/build/phase144'/('range-skip-'+role+'-emit01')
    assert not dest.exists()
    emissions[role] = dest/'report.json'
    job(role+'-emit', [bun, emit, ar, cases_file, dest], 180)
builds = ROOT/'selfhost/build/phase144/range-skip-builds01'
timing = ROOT/'selfhost/build/phase144/range-skip-times01'
assert not builds.exists() and not timing.exists()
job('three-family-builds', [sys.executable, '-B', HERE/'range-skip-bench-build-v01.py',
    '--baseline', emissions['baseline'], '--candidate', emissions['candidate'], '--out', builds], 240)
job('three-family-timing', [sys.executable, '-B', HERE/'range-skip-bench-time-v01.py',
    '--builds', builds/'report.json', '--out', timing], 90)
(out/'jobs.json').write_text(json.dumps(dict(kind='phase144-range-policy-root-jobs', complete=True,
    targetsRun=False, sequential=True, inputs=[C.pin(out/'manifest.json'), C.pin(cases_file),
    C.pin(out/'orchestration-derivation.json'), C.pin(emit), C.pin(baseline_api)], jobs=jobs,
    gate='Root executes sequentially. API must be checked; emissions complete before machine builds; exact output/count smokes before paired timings. Keep qualified compiler and production selection unchanged.'), indent=2)+'\n')
print(json.dumps(dict(source=C.pin(source), plan=C.pin(out/'jobs.json'), overrides=manifest['overrides'])))
