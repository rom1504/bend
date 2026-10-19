#!/usr/bin/env python3
"""Freeze existing batch sources/products and prepare acquisition argv; no targets."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
NAMES = ['lexer', 'variation-ray-active-256-2240', 'coverage-closures-256',
         'coverage-unicode-text-64', 'coverage-map-churn-128', 'coverage-numeric-recurrence-1024']


def pin(path):
    path = (ROOT / path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(row):
    result = pin(row['file'])
    assert all(result[k] == row[k] for k in ['bytes', 'sha256']), row['file']
    return result


def main():
    assert not (HERE / 'manifest01.json').exists()
    acquisition_file = ROOT / 'selfhost/build/phase93/broad01/report.json'
    timing_file = ROOT / 'selfhost/build/phase93/measure-broad01/report.json'
    exclusion_file = ROOT / 'selfhost/build/phase93/calibration-continuation01/unmeasured.json'
    qualified_file = ROOT / 'implementation/phase111/selection.json'
    a, timing, exclusion, qualified = [json.loads(p.read_text()) for p in
                                      [acquisition_file, timing_file, exclusion_file, qualified_file]]
    assert a['complete'] and timing['complete'] and exclusion['complete'] and qualified['qualified']
    image, runtime = verify(qualified['successor']), verify(qualified['runtime'])
    assets_file = ROOT / 'selfhost/tools/performance/phase111/native-assets01.json'
    assets = json.loads(assets_file.read_text())
    base, carrier = verify(assets['base']), verify(assets['cache']['carrier'])
    assert [verify(x) for x in a['upstreamInputs'] if x['file'] == base['file']] == [base]
    batch_manifest = json.loads(Path(verify(a['manifest'])['file']).read_text())
    old_cases = {x['name']: x for x in a['cases']}
    batch_cases = {x['name']: x for x in batch_manifest['cases']}
    controls = json.loads((ROOT / 'selfhost/tools/performance/phase111/coverage/full45/manifest.json').read_text())
    oracles = {x['name']: x for x in controls['fixtures']}
    build_file = ROOT / 'selfhost/build/phase111/successor-representatives01/0-native/build/report.json'
    built = json.loads(build_file.read_text())
    assert built['complete']
    build_inputs = {str(Path(x['file']).resolve()): x for x in built['inputs']}
    jobs = {x['label']: x for x in built['jobs']}
    direct = {key: verify(build_inputs[str(Path(jobs[label]['command'][0]).resolve())])
              for key, label in [('qbe','qbe'),('assembler','assemble'),('linker','link')]}
    inputs = [pin(__file__), pin(acquisition_file), pin(timing_file), pin(exclusion_file), pin(qualified_file),
              pin(assets_file), verify(a['manifest']), pin(build_file), base, carrier,
              pin(ROOT / 'selfhost/tools/performance/phase111/coverage/full45/manifest.json'),
              image, runtime, *direct.values()]
    rows, commands, reports = [], [], {}
    for name in NAMES:
        row = old_cases[name]
        assert row['passed'] and row['source'] == batch_cases[name]['source']
        source = verify(row['source'])
        assert verify(row['source88']) == verify(oracles[name]['source'])
        expected = row['expectedStdout']
        assert expected == oracles[name]['expect']['stdout']
        oracle = verify(oracles[name]['stdoutFile'])
        assert Path(oracle['file']).read_bytes() == expected.encode()
        upstream = row['products']['upstream']
        binary, c = verify(upstream['binary']), verify(upstream['c'])
        command = upstream['build']['command']
        assert command[-7:] == ['-std=c11','-O3',c['file'],'-o',binary['file'],'-lpthread','-lm']
        clang = verify(a['authentication']['clang'])
        assert clang['file'] in command
        counts = timing['plan'][name]
        assert all(r['qualified'] and r['correct'] for r in timing['records'] if r['case'] == name)
        rows.append(dict(name=name, source=source, source88=verify(row['source88']), original=verify(row['original']),
            expectedStdout=expected, expectedStdoutEvidence=oracle, runtimeArgs=row['runtimeArgs'],
            repetitions=counts['repetitions'], warmups=counts['warmups'],
            upstream=dict(binary=binary, source=source, generatedC=c, buildCommand=command, clang=clang),
            oracleProvenance='Unchanged full Phase93 expected value, equal to independent prior Phase92/105 output preserved in Phase111 full45; repeated success counts derive only from requested counts.',
            historicalSamplesMs={role:[r['elapsedMs'] for r in timing['records'] if r['case']==name and r['role']==role]
                                 for role in ['own','upstream']}))
        inputs += [source, c, binary, oracle, clang]
        out = ROOT / 'selfhost/build/phase111' / ('p112-baseline01-' + name)
        argv = ['python3','-B',str(ROOT / 'selfhost/tools/performance/phase111/native-emit.py'),
                '--image',image['file'],'--source',source['file'],'--out',str(out),'--mode','cache',
                '--runtime',runtime['file'],'--seconds','120','--build-seconds','30']
        commands.append(dict(name=name, command=argv,
            expected='Build only here; timed-batch output checked independently by benchmark/run.py.'))
        reports[name] = str(out / 'report.json')
    manifest = dict(kind='phase112-frozen-matched-program-screen', version=1, preparedOnly=True, targetsRun=False,
        frozenUtc=datetime.now(timezone.utc).isoformat(), cases=rows, inputs=inputs,
        base=base, carrier=carrier, phase111Compiler=image, phase111Runtime=runtime, directToolchain=direct,
        rounds=3, minimumMs=100, sampleDeadlineSeconds=30,
        zeroWorkExclusions=[dict(name=x['id'], reason=x['reason'], ratio=None, evidence=pin(exclusion_file))
                            for x in exclusion['cases']],
        clock='Existing Phase93 in-program IO.now milliseconds: workload, full-result validation, loop, final success-count print. Excludes startup, initial result and warmups. Process wall recorded separately; compiler requests/builds excluded.',
        ordering='Per case/round rotate roles by (caseIndex+roundIndex) modulo role count; two roles alternate order. Equal counts and flags in every role.',
        aggregate='Ratio of role median milliseconds to comparator median; geometric mean equally weights all six selected distinct programs. No aggregate for incomplete/unqualified runs. Not a replacement for the historical 44-point score.',
        workload='Exact existing Phase93 batch files and old counts; no new benchmark algorithm, input variation or changed old 45 corpus.',
        limits='The six Phase111 one-shot binaries are different sources and are not reused here. Upstream Clang -O3 differs from direct QBE; each backend configuration is pinned, not claimed identical across backends.')
    for item in inputs:
        verify(item)
    (HERE / 'manifest01.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (HERE / 'phase111-reports01.json').write_text(json.dumps(reports,indent=2)+'\n')
    (HERE / 'acquire-phase11101.json').write_text(json.dumps(dict(preparedOnly=True,targetsRun=False,
        manifest=pin(HERE/'manifest01.json'),guard='Root serial CPU3 process-tree guard; execute commands in order.',jobs=commands),indent=2)+'\n')
    print(json.dumps(dict(preparedOnly=True,targetsRun=False,cases=6,manifest=pin(HERE/'manifest01.json'))))


if __name__ == '__main__':
    main()
