#!/usr/bin/env python3
"""Replay independent String controls using pinned Phase101 admission/products.

Root executes this serial guarded queue. This module never reacquires a compiler
image or silently reruns frontend admission when reusable evidence is missing.
"""
import argparse
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R
P = R.module('p102_text_controls', Path(__file__).with_name('prepare.py'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path,
        default=ROOT / 'selfhost/build/phase101/string-controls-independent03/controls.json')
    parser.add_argument('--reuse', type=Path,
        default=ROOT / 'selfhost/build/phase101/controls-compare01/report.json')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--copy', action='store_true')
    args = parser.parse_args()
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    manifest = R.read(args.manifest)
    report = dict(complete=False, started=time.time(), method=R.pin(__file__),
        manifest=R.pin(args.manifest), reuse=R.pin(args.reuse), reuseCells=not args.copy,
        inputs=[], products={}, executions=[],
        scope='Linked String append intervention; inherited pinned source admission, new full-output executions')
    def save(): R.save(out / 'report.json', report)
    save()
    try:
        for item in manifest['pins']:
            current = R.pin(item['path'])
            assert (current['sha256'], current['bytes']) == (item['sha256'], item['bytes']), item['path']
        old = R.read(args.reuse)
        assert old['complete'] and old['manifest'] == report['manifest'], 'Pinned manifest/admission mismatch'
        assert old['executions'] and all(item['passed'] for item in old['executions'])
        release, context = R.authenticate(); report['context'] = context
        inputs = [report['method'], R.pin(P.__file__),
                  R.pin(Path(__file__).with_name('linked-append.c')), R.pin(R.__file__),
                  report['manifest'], report['reuse']]
        for index, item in enumerate(inputs):
            (out / ('snapshot-' + str(index) + '-' + Path(item['file']).name)).write_bytes(Path(item['file']).read_bytes())
        report['inputs'] = inputs; save()
        for source in dict.fromkeys(case['source'] for case in manifest['records']):
            key = Path(source).stem; folder = out / key; folder.mkdir()
            info = dict(source=R.pin(source), variants={})
            report['products'][source] = info; save()
            previous = old['products'][source]
            assert previous['source'] == info['source']
            R.verify(previous['upstreamAdmission'])
            admission = R.read(previous['upstreamAdmission']['file'])
            assert admission['complete'] and admission['calls'][0]['observation'] == dict(status='ok', checked=True)
            info['upstreamAdmission'] = previous['upstreamAdmission']
            for role in ('baseline', 'upstream'):
                product = previous['variants'][role]
                R.verify(product['c']); R.verify(product['binary'])
                info['variants'][role] = product
            original = Path(info['variants']['baseline']['c']['file'])
            code, counts = P.transform(original.read_text(), reuse=not args.copy)
            candidate = folder / 'candidate.c'; candidate.write_text(code)
            info['rewrites'] = counts
            binary = folder / 'candidate.program'; cc = context['clang']['file']
            build, _ = R.guarded(folder / 'candidate-build', [cc, '-isystem',
                Path(cc).parents[1] / 'include/clang', '-std=c11', '-O3', candidate,
                '-o', binary, '-lpthread', '-lm'])
            info['variants']['candidate'] = dict(c=R.pin(candidate), binary=R.pin(binary), build=build)
            save()
            for case in (case for case in manifest['records'] if case['source'] == source):
                expected = Path(case['expected']).read_bytes()
                report['inputs'].append(R.pin(case['expected']))
                if case.get('input'): report['inputs'].append(R.pin(case['input']))
                for workers in case['workers']:
                    for role in ('baseline', 'candidate', 'upstream'):
                        label = f'{case["id"]}-t{workers}-{role}'; directory = out / label
                        record = dict(case=case['id'], workers=workers, role=role, passed=False)
                        report['executions'].append(record); save()
                        R.verify(info['variants'][role]['binary'])
                        record['job'], child = R.guarded(directory,
                            [info['variants'][role]['binary']['file'], '--threads', str(workers),
                             '--gpu', 'off', '--', *case['argv']],
                            cpu={1:'3', 2:'2,3', 4:'0,1,2,3'}[workers], seconds=15)
                        record.update(stdout=R.pin(directory / 'stdout.log'), stderr=R.pin(directory / 'stderr.log'))
                        record['passed'] = ((directory / 'stdout.log').read_bytes() == expected and not child['stderr'])
                        save(); assert record['passed'], label
                print(R.json.dumps(dict(case=case['id'], passed=True)), flush=True)
        for item in report['inputs']: R.verify(item)
        for item in report['products'].values():
            R.verify(item['source']); R.verify(item['upstreamAdmission'])
            for product in item['variants'].values():
                R.verify(product['c']); R.verify(product['binary'])
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time(); save()


if __name__ == '__main__':
    main()
