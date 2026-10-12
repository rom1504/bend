#!/usr/bin/env python3
"""Count saved candidate C; reuse byte-proven compiler23/upstream diagnostics."""
import argparse
import hashlib
import importlib.util
import json
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT/'selfhost/tools/performance/phase68/parity-survey/run.py'
spec = importlib.util.spec_from_file_location('phase68_survey', PARENT)
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
S, N = M.S, M.N
read = M.read
CACHE = ROOT/'selfhost/build/phase68/parity-survey23-counts01/report.json'


def checked_counts(dest, process, case, n):
    observation = M.observed(dest, process, case, n)
    assert observation['correct'], (case, n, observation)
    assert process['complete'] and process['returncode'] == 0
    logs = [json.loads(x) for x in (dest/'stderr.log').read_text().splitlines()]
    assert len(logs) == 2
    counts = next(x for x in logs if x['kind'] == 'phase68-native-counts')
    sites = next(x for x in logs if x['kind'] == 'phase68-allocation-sites')['sites']
    assert counts['invalidClassCalls'] == 0
    assert sum(sites) == counts['heapAllocCalls']
    return dict(repetitions=n, process=process, **observation,
                counts=counts, allocationSites=sites)


def delta(item):
    low, high = sorted(item['runs'], key=lambda x:x['repetitions'])
    assert [low['repetitions'], high['repetitions']] == [1,17]
    counts = {key:high['counts'][key]-value for key,value in low['counts'].items()
              if isinstance(value, int)}
    assert len(high['allocationSites']) == len(low['allocationSites'])
    sites = [a-b for a,b in zip(high['allocationSites'], low['allocationSites'])]
    assert sum(sites) == counts['heapAllocCalls']
    assert len(item['sites']) == len(sites)
    top = sorted((dict(site=site, addedCalls=count) for site,count in zip(item['sites'],sites)
                  if count), key=lambda x:-x['addedCalls'])[:30]
    return dict(case=item['job']['case'], role=item['job']['role'],
                extraWorkloads=16, counts=counts, topAllocationSites=top)


def prepare(acquisitions, cases):
    old, pins = M.products()
    pins += [S.identity(__file__), S.identity(PARENT), S.identity(CACHE)]
    cached = read(CACHE)
    assert cached['complete']
    assert S.identity(cached['plan']['path']) == cached['plan']
    pins.append(cached['plan'])
    source_records, recipes = {}, {}
    for path in acquisitions:
        path = path/'report.json' if path.is_dir() else path
        report = read(path)
        assert report['complete']
        pins += [S.identity(path), report['recipe']]
        recipe = read(report['recipe']['path'])
        assert recipe['upstreamCommit'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        toolroot = str(Path(recipe['clang']).parent.parent)+'/'
        pins += [x for x in recipe['inputs'] if x['path'].startswith(toolroot)
                 or x['path'] == recipe['api']
                 or Path(x['path']).name in ('ld','ld.bfd','x86_64-linux-gnu-ld.bfd')]
        for row in report['records']:
            if row['role'] != 'selfhost' or row['case'] not in cases:
                continue
            case = row['case']
            assert case not in source_records and row['correct']
            emission = read(row['emissionReceipt']['path'])
            assert emission['complete'] and emission['output'] == row['nativeSource']
            assert emission['observation']['checked'] and emission['observation']['status'] == 'ok'
            before = old[(case,'selfhost')]
            assert row['source'] == before['source']
            for key in ('clang','clangArgs','linkArgs','cpu','compilerEnvironment'):
                assert recipe[key] == before['recipe'][key], key
            pins += [row[k] for k in ('source','nativeSource','executable','emissionReceipt')]
            source_records[case], recipes[case] = row, recipe
    assert set(source_records) == set(cases)
    reuse = []
    for case in cases:
        for role in ('selfhost','upstream'):
            matches = [r for r in cached['records'] if r['job']['case'] == case and r['job']['role'] == role]
            assert len(matches) == 1
            record = matches[0]
            assert record['complete'] and record['build']['complete']
            assert record['job']['source'] == old[(case,role)]['nativeSource']
            assert record['job']['originalExecutable'] == old[(case,role)]['executable']
            # Replay both pure instrumentation functions and require the entire
            # historical diagnostic C to match, rather than trusting a label.
            code, sites = M.site_counts(Path(record['job']['source']['path']).read_text())
            code, segments = N.instrument(code)
            assert sites == record['sites'] and segments == record['segments']
            assert hashlib.sha256(code.encode()).hexdigest() == record['source']['sha256']
            assert S.identity(record['source']['path']) == record['source']
            pins += [record['source'], record['executable']]
            parent = Path(record['source']['path']).parent
            for run in record['runs']:
                dest = parent/('run-'+str(run['repetitions']))
                verified = checked_counts(dest, run['process'], case, run['repetitions'])
                assert verified == run
                pins += [S.identity(dest/name) for name in ('stdout.log','stderr.log','process.json')]
            frozen = dict(record)
            frozen['job'] = dict(record['job'], role='baseline23' if role=='selfhost' else role)
            frozen['reuse'] = dict(report=S.identity(CACHE), originalRole=role,
                fullInstrumentedCReproduced=True, targetsExecutedThisCampaign=False)
            reuse.append(frozen)
    pins = list({x['path']:x for x in pins}.values())
    M.verify(pins)
    return source_records, recipes, reuse, pins


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--candidate', type=Path, nargs='+', required=True)
    p.add_argument('--cases', default='closures,lexer')
    p.add_argument('--out', type=Path)
    p.add_argument('--check-only', action='store_true')
    a = p.parse_args()
    cases = a.cases.split(',')
    assert cases and len(cases) == len(set(cases)) and set(cases) <= {'closures','lexer','tree','map'}
    data, recipes, reuse, pins = prepare(a.candidate, cases)
    if a.check_only:
        print(json.dumps(dict(dataOnly=True, cases=cases, exactCachedRows=len(reuse), inputs=len(pins))))
        return
    assert a.out is not None
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase69')
    out.mkdir(parents=True, exist_ok=False)
    S.save(out/'plan.json', dict(inputs=pins, mode='allocation-counts', cases=cases,
        cachedRows=[dict(job=x['job'], reuse=x['reuse']) for x in reuse],
        diagnosticOnly=True, newTargets='candidate only; each1/17repetitions, zero warmup, threads1/GPUoff',
        scope='Exact inherited atomic operation/site instrumentation. Whole diagnostic C and independently checked historical outputs proved before cache reuse. Source-operation frequencies, not time attribution or performance timings.'))
    report = dict(complete=False, started=time.time(), plan=S.identity(out/'plan.json'), records=reuse)
    S.save(out/'report.json', report)
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            def run(command, dest, seconds=90):
                return guard.run(['taskset','-c','3',*map(str,command)], dest, time.monotonic()+seconds)
            for case in cases:
                row, recipe = data[case], recipes[case]
                dest = out/(case+'-candidate')
                dest.mkdir()
                code, sites = M.site_counts(Path(row['nativeSource']['path']).read_text())
                code, segments = N.instrument(code)
                source, executable = dest/'program.c', dest/'program'
                source.write_text(code)
                record = dict(job=dict(case=case, role='candidate', source=row['nativeSource'],
                    originalExecutable=row['executable']), source=S.identity(source), sites=sites,
                    segments=segments, runs=[], reuse=False)
                report['records'].append(record)
                record['build'] = run([recipe['clang'],*recipe['clangArgs'],source,*recipe['linkArgs'],'-o',executable], dest/'build')
                S.save(out/'report.json', report)
                assert record['build']['complete'], case
                record['executable'] = S.identity(executable)
                for n in (1,17):
                    run_dir = dest/('run-'+str(n))
                    process = run([executable,'--threads','1','--gpu','off','--',n,0], run_dir, 30)
                    record['runs'].append(checked_counts(run_dir, process, case, n))
                    S.save(out/'report.json', report)
                record['complete'] = True
                print(json.dumps(dict(case=case, counts=delta(record)['counts'])), flush=True)
        M.verify(pins)
        report['deltas'] = [delta(x) for x in report['records']]
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time()
        S.save(out/'report.json', report)


if __name__ == '__main__':
    main()
