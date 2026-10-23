"""Plan the frozen45 wrapper screen and classify already checked products.

Metadata/read-only machine inspection only; root executes the emitted jobs.
"""
import argparse
import filecmp
import importlib.util
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from run import pin, verify, save

CORPUS = ROOT / 'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
BASELINE = ROOT / 'selfhost/build/phase128/native-runtime01/report.json'
OLD_EMISSION = ROOT / 'selfhost/build/phase128/native-wrappers01/report.json'
RUNTIME_REPORT = ROOT / 'selfhost/build/phase128/runtime-borrow01/report.json'
SCREEN = HERE / 'screen.py'


def read(path):
    return json.loads(Path(path).read_text())


def guarded(out, name, command, seconds, rss=3072):
    return dict(name=name, seconds=seconds + 15, command=[sys.executable, '-B',
        str(ROOT / 'selfhost/tools/performance/phase111/guard.py'), '--out',
        str(out / (name + '-guard')), '--seconds', str(seconds), '--rss-mib', str(rss),
        '--available-mib', '16384', '--file-mib', '128', '--cpu', '3', '--', *map(str, command)])


def authorities():
    manifest, baseline, old, runtime = map(read, [CORPUS, BASELINE, OLD_EMISSION, RUNTIME_REPORT])
    assert len(manifest['cases']) == 45 and baseline['complete'] and old['complete'] and runtime['complete']
    assert old['runtime'] == runtime['object']
    assert len(baseline['rows']) == 405 and all(r['correct'] for r in baseline['rows'])
    derivation = read(HERE / 'screen-derivation.json')
    assert derivation['inverseExact'] and pin(SCREEN) == derivation['derived']
    source = SCREEN.read_text()
    for row in reversed(derivation['replacements']):
        assert source.count(row['derived']) == 1
        source = source.replace(row['derived'], row['original'], 1)
    verify(derivation['original']); assert source == Path(derivation['original']['file']).read_text()
    inputs = [pin(__file__), *map(pin, [CORPUS, BASELINE, OLD_EMISSION, RUNTIME_REPORT,
        SCREEN, HERE / 'screen-derivation.json']), runtime['object']]
    for item in inputs: verify(item)
    return manifest, baseline, old, runtime, inputs


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('action', choices=['prepare', 'classify'])
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--api', type=Path)
    ap.add_argument('--source-manifest', type=Path)
    ap.add_argument('--tag')
    args = ap.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase131')
    corpus, baseline, old, runtime, inputs = authorities()
    names = [c['name'] for c in corpus['cases']]
    if args.action == 'prepare':
        assert not out.exists() and args.api and args.source_manifest and args.tag
        assert all(x.isalnum() or x in '-_' for x in args.tag)
        api, source = read(args.api), read(args.source_manifest)
        assert api['complete'] and api['checked'] and source['complete'] and source['source'] in api['inputs']
        for item in api['inputs'] + [api['api']] + source['inputs']: verify(item)
        inputs += [pin(args.api), pin(args.source_manifest), api['api'], source['source']]
        emitted = ROOT / 'selfhost/build/phase118' / (args.tag + '-wrappers')
        assert not emitted.exists(); out.mkdir(parents=True)
        jobs = [guarded(out, 'emit45', ['env', 'P118_CASE_MANIFEST=' + str(CORPUS),
            'P118_RUNTIME_REPORT=' + str(RUNTIME_REPORT),
            ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun',
            ROOT / 'selfhost/tools/performance/phase128/emit-entry.mjs',
            args.api.resolve(), args.source_manifest.resolve(), emitted, *names], 900, 4096),
            guarded(out, 'smoke45', [sys.executable, '-B', SCREEN, '--emission', emitted / 'report.json',
                '--baseline', BASELINE, '--out', out / 'smoke', '--label', args.tag + '-smoke', '--check-only'], 180),
            dict(name='classify-products', seconds=60, command=[sys.executable, '-B', __file__, 'classify', '--out', str(out)])]
        save(out / 'plan.json', dict(complete=True, targetsRun=False, inputs=inputs, tag=args.tag,
            emitted=str(emitted / 'report.json'), smoke=str(out / 'smoke/report.json'), jobs=jobs,
            scope='Run only after small source/finite/request gates pass. Actual checked hosted entry, original45 historical wrappers, aligned cached runtime and independent wrapper output/count oracle. This is not native self-host qualification. Each target job has its own CPU3 guard; no outer guard required.'))
        print(json.dumps(dict(complete=True, targetsRun=False, plan=str(out / 'plan.json'), cases=45))); return
    plan = read(out / 'plan.json')
    for item in plan['inputs']: verify(item)
    emission, smoke = read(plan['emitted']), read(plan['smoke'])
    assert emission['complete'] and smoke['complete'] and smoke['correctnessOnly']
    assert emission['runtime'] == runtime['object']
    assert [c['name'] for c in emission['cases']] == names
    assert len(smoke['rows']) == 45 and all(r['correct'] and r['role'] == 'candidate' for r in smoke['rows'])
    method = ROOT / 'selfhost/tools/performance/phase127/compare-machine.py'
    spec = importlib.util.spec_from_file_location('p127_machine', method)
    machine = importlib.util.module_from_spec(spec); spec.loader.exec_module(machine)
    inputs += [pin(out / 'plan.json'), pin(plan['emitted']), pin(plan['smoke']), pin(method)]
    builds = {r['name']: r['report'] for r in smoke['builds']}; rows = []
    for case, produced in zip(corpus['cases'], emission['cases']):
        name = case['name']; previous = next(c for c in old['cases'] if c['name'] == name)
        assert case['source'] == produced['source'] == previous['source']
        build = read(builds[name]['file']); assert build['complete']
        assert produced['qbe'] in build['inputs'] and runtime['object'] in build['inputs']
        before = next(r['binary'] for r in baseline['rows'] if r['name'] == name and r['role'] == 'candidate')
        for item in [builds[name], before, build['binary'], produced['qbe'], previous['qbe']]: verify(item)
        a, _, _ = machine.inspect(Path(before['file'])); b, _, _ = machine.inspect(Path(build['binary']['file']))
        changed_sections = sorted(k for k in a.keys() | b.keys() if a.get(k) != b.get(k))
        exact = filecmp.cmp(produced['qbe']['file'], previous['qbe']['file'], shallow=False)
        allocation_exact = not (set(changed_sections) - {'.note.gnu.build-id'})
        rows.append(dict(name=name, source=case['source'], candidateQbe=produced['qbe'], baselineQbe=previous['qbe'],
            qbeByteIdentical=exact, baselineBinary=before, candidateBinary=build['binary'],
            textByteIdentical=a.get('.text') == b.get('.text'), changedAllocatedSections=changed_sections,
            runtimeByteIdentical=True, allocatedSectionsIdenticalExceptBuildId=allocation_exact,
            unchangedExecutableEvidence=exact and allocation_exact))
    changed = [r['name'] for r in rows if not r['unchangedExecutableEvidence']]
    selected = names if len(changed) >= 23 else changed
    assert not (out / 'classification.json').exists()
    save(out / 'classification.json', dict(complete=True, targetsRun=False, inputs=inputs, rows=rows,
        changed=changed, selectedForRuntime=selected, full405Required=len(changed) >= 23,
        decision='At least23 changed products triggers full45 ×3roles ×3rounds. Otherwise measure only changed products, retaining exact QBE/runtime/allocated-machine evidence for unchanged products. No mixed historical/current aggregate score.',
        ordinaryQualification='The smoke is one repetition/no warmup of historical wrappers through the frozen count/output oracle; ordinary native full45 qualification remains separate.'))
    save(out / 'build-map.json', builds)
    selected_emission = dict(emission, inputs=emission['inputs'] + [pin(plan['emitted']), pin(out / 'classification.json')],
        cases=[c for c in emission['cases'] if c['name'] in selected])
    save(out / 'selected-emission.json', selected_emission)
    jobs = []
    if selected:
        jobs = [guarded(out, 'runtime', [sys.executable, '-B', SCREEN, '--emission', out / 'selected-emission.json',
            '--baseline', BASELINE, '--build-map', out / 'build-map.json', '--out', out / 'runtime',
            '--label', plan['tag'] + '-runtime', '--rounds', '3', '--scale', '4'], 600, 2048)]
    save(out / 'runtime-jobs.json', dict(complete=True, targetsRun=False, inputs=[pin(out / 'classification.json')], jobs=jobs))
    print(json.dumps(dict(complete=True, targetsRun=False, changed=len(changed), selected=len(selected), observations=9 * len(selected))))


if __name__ == '__main__': main()
