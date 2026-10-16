#!/usr/bin/env python3
"""Baseline admission and full-byte checks of independent native String cases."""
import argparse
from pathlib import Path
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R
P = R.module('p101_prepare_controls', Path(__file__).with_name('prepare.py'))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--append', action='store_true')
    p.add_argument('--compare', action='store_true')
    p.add_argument('--reuse', type=Path)
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    manifest = R.read(a.manifest)
    report = dict(complete=False, started=time.time(), manifest=R.pin(a.manifest), append=a.append, compare=a.compare,
                  inputs=[], products={}, executions=[], method=R.pin(__file__))
    def save(): R.save(out / 'report.json', report)
    save()
    try:
        for item in manifest['pins']:
            current = R.pin(item['path'])
            assert current['sha256'] == item['sha256'] and current['bytes'] == item['bytes'], item['path']
        release, context = R.authenticate(); report['context'] = context
        old = R.read(a.reuse) if a.reuse else None
        if old:
            assert old['complete'] and old['manifest'] == report['manifest']
            report['reuse'] = R.pin(a.reuse)
        inputs = [R.pin(P.__file__), R.pin(Path(__file__).with_name('chunk-runtime.c')),
                  R.pin(Path(__file__).with_name('chunk-append.c')), R.pin(Path(__file__).with_name('chunk-compare.c'))]
        for item in inputs:
            (out / ('snapshot-' + Path(item['file']).name)).write_bytes(Path(item['file']).read_bytes())
        report['inputs'] = inputs; save()
        for source in dict.fromkeys(c['source'] for c in manifest['records']):
            key = Path(source).stem; folder = out / key; folder.mkdir()
            info = dict(source=R.pin(source), variants={}); report['products'][source] = info; save()
            upstream = folder / 'upstream'
            baseline = folder / 'baseline'
            if old:
                previous = old['products'][source]
                assert previous['source'] == info['source']
                R.verify(previous['upstreamAdmission'])
                info['upstreamAdmission'] = previous['upstreamAdmission']
                original = Path(previous['variants']['baseline']['c']['file'])
                upstream_c = Path(previous['variants']['upstream']['c']['file'])
            else:
                R.guarded(folder / 'admit', [context['bun']['file'], R.PERF / 'phase86/reference.mjs',
                                          'typescript', source, upstream, '1'])
                admission = R.read(str(upstream) + '.json')
                assert admission['complete'] and admission['calls'][0]['observation'] == dict(status='ok', checked=True)
                info['upstreamAdmission'] = R.pin(str(upstream) + '.json')
                R.guarded(folder / 'emit', R.NATIVE.native_args(release, source, baseline, stage='b2'))
                original = Path(str(baseline) + '.1.c')
                upstream_c = Path(str(upstream) + '.1.c')
            code, counts = P.transform(original.read_text(), 'all', a.append, a.compare)
            candidate = folder / 'candidate.c'; candidate.write_text(code); info['rewrites'] = counts
            for role, c in [('baseline', original), ('candidate', candidate), ('upstream', upstream_c)]:
                if old and role != 'candidate':
                    info['variants'][role] = previous['variants'][role]
                    R.verify(info['variants'][role]['c']); R.verify(info['variants'][role]['binary'])
                    continue
                binary = folder / (role + '.program'); cc = context['clang']['file']
                build, _ = R.guarded(folder / (role + '-build'), [cc, '-isystem',
                    Path(cc).parents[1] / 'include/clang', '-std=c11', '-O3', c, '-o', binary, '-lpthread', '-lm'])
                info['variants'][role] = dict(c=R.pin(c), binary=R.pin(binary), build=build); save()
            for case in (c for c in manifest['records'] if c['source'] == source):
                expected = Path(case['expected']).read_bytes()
                report['inputs'].append(R.pin(case['expected']))
                if case.get('input'): report['inputs'].append(R.pin(case['input']))
                for workers in case['workers']:
                    for role in ['baseline', 'candidate', 'upstream']:
                        label = f'{case["id"]}-t{workers}-{role}'; directory = out / label
                        record = dict(case=case['id'], workers=workers, role=role, passed=False)
                        report['executions'].append(record); save()
                        record['job'], child = R.guarded(directory, [info['variants'][role]['binary']['file'],
                            '--threads', str(workers), '--gpu', 'off', '--', *case['argv']],
                            cpu={1:'3',2:'2,3',4:'0,1,2,3'}[workers], seconds=15)
                        record['passed'] = ((directory/'stdout.log').read_bytes() == expected and not child['stderr'])
                        save(); assert record['passed'], label
                print(R.json.dumps(dict(case=case['id'], passed=True)), flush=True)
        for item in report['inputs']: R.verify(item)
        report['complete'] = True
    except BaseException as e:
        report['error'] = repr(e); raise
    finally:
        report['finished'] = time.time(); save()


if __name__ == '__main__': main()
