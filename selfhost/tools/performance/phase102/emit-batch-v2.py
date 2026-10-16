#!/usr/bin/env python3
"""Emit independent C requests in one guarded checked-API/Base-preparation batch."""
import argparse
from pathlib import Path
import re
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--acquisition', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--apps', default='')
    p.add_argument('--manifest', type=Path)
    p.add_argument('--source', type=Path, nargs='*', default=[])
    p.add_argument('--seconds', type=int, default=180)
    a = p.parse_args()
    assert 1 <= a.seconds <= 600
    out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase102-batch-emission', complete=False, started=time.time(),
                  method=R.pin(__file__), acquisition=R.pin(a.acquisition), programs=[],
                  scope='C through a checked upstream-built JS testing API, with one shared Base preparation. Independent request plans/effects/emissions; native-host qualification and cold timings are separate.')
    def save(): R.save(out / 'report.json', report)
    save()
    try:
        acq = R.read(a.acquisition); assert acq['complete']
        for item in [acq['api'], acq['source'], acq['snapshot'], acq['recipe'], acq['context']['bun']]: R.verify(item)
        method = R.pin(Path(__file__).with_name('compile-batch.mjs'))
        report.update(compilerSource=acq['source'], api=acq['api'], emissionMethod=method,
                      bun=acq['context']['bun'], seconds=a.seconds)
        for source, name in [(Path(__file__), 'snapshot-emit-batch-v2.py'),
                             (Path(method['file']), 'snapshot-compile-batch.mjs')]:
            (out / name).write_bytes(source.read_bytes())
            report.setdefault('methodSnapshots', []).append(R.pin(out / name))
        sources = {}
        def add(name, source):
            assert re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]*', name), name
            assert name not in ('batch', 'batch-emit'), ('reserved id', name)
            resolved = Path(source).resolve()
            if name in sources:
                assert sources[name] == resolved, ('conflicting sources for id', name, sources[name], resolved)
                return
            sources[name] = resolved
        for app in filter(None, a.apps.split(',')): add(app, ROOT / 'selfhost/apps' / app / 'main.bend')
        for source in a.source: add(source.stem, source)
        if a.manifest:
            manifest = R.read(a.manifest); assert manifest['complete']
            report['manifest'] = R.pin(a.manifest)
            for record in manifest['records']:
                source = Path(record['source']); add(source.stem, source)
        assert sources
        plan = dict(kind='phase102-batch-emission-inputs', complete=True, api=acq['api'],
                    acquisition=report['acquisition'], compilerSource=acq['source'], programs=[])
        for name, source in sources.items():
            row = dict(id=name, source=R.pin(source), complete=False, status='not-run')
            report['programs'].append(row)
            plan['programs'].append(dict(id=name, source=row['source'], output=str(out / name / 'emitted')))
        R.save(out / 'batch-inputs.json', plan); report['batchInputs'] = R.pin(out / 'batch-inputs.json'); save()
        report['job'], _ = R.guarded(out / 'batch-emit', [acq['context']['bun']['file'], method['file'],
            acq['api']['file'], out / 'batch-inputs.json', out / 'batch'], seconds=a.seconds)
        result = R.read(out / 'batch/report.json'); assert result['complete']
        assert result['api'] == acq['api'] and result['method'] == method
        assert result['batchInputs'] == report['batchInputs']
        assert [row['id'] for row in result['programs']] == list(sources)
        report['sharedPreparation'] = result['sharedPreparation']; R.verify(result['sharedPreparation'])
        preparation = R.read(result['sharedPreparation']['file'])
        assert preparation['complete'] and preparation['calls'] == 1 and preparation['api'] == acq['api']
        for row, product in zip(report['programs'], result['programs']):
            assert product['complete'] and product['source'] == row['source']
            receipt = R.read(product['receipt']['file'])
            assert receipt['complete'] and receipt['source'] == row['source'] and receipt['api'] == acq['api']
            assert receipt['sharedPreparation'] == result['sharedPreparation'] and receipt['output'] == product['c']
            row.update(receipt=product['receipt'], c=product['c'], complete=True, status='complete')
            for item in [row['source'], row['receipt'], row['c']]: R.verify(item)
        for item in [report['method'], report['acquisition'], acq['api'], acq['source'], acq['snapshot'],
                     acq['recipe'], acq['context']['bun'], method, report['batchInputs'],
                     *report['methodSnapshots']]: R.verify(item)
        if 'manifest' in report: R.verify(report['manifest'])
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        # A stopped guard or failed source retains completed and in-flight records;
        # no later source is run and no failed batch is labeled complete.
        batch = out / 'batch/report.json'
        if batch.exists():
            result = R.read(batch); report['batchReceipt'] = R.pin(batch)
            report['batchStatus'] = result.get('phase')
            report['basePrepareMs'] = result.get('basePrepareMs')
            report['batchPrograms'] = result.get('programs', [])
            for row, actual in zip(report['programs'], report['batchPrograms']):
                if actual.get('id') == row['id'] and actual.get('source') == row['source']:
                    for key in ('status', 'complete', 'c', 'receipt'):
                        if key in actual: row[key] = actual[key]
            if result.get('sharedPreparation'): report['sharedPreparation'] = result['sharedPreparation']
        job = out / 'batch-emit-job.json'
        if job.exists(): report['jobReceipt'] = R.pin(job)
        report['finished'] = time.time(); save()
    print(R.json.dumps(dict(complete=report['complete'], programs=len(report['programs']),
                           basePrepareMs=report.get('basePrepareMs'))), flush=True)


if __name__ == '__main__': main()
