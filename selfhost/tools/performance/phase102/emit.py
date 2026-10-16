#!/usr/bin/env python3
"""Run the exact native request path of a checked Bend compiler testing API."""
import argparse
from pathlib import Path
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
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    acq = R.read(a.acquisition); assert acq['complete']
    for item in [acq['api'], acq['source'], acq['snapshot'], acq['recipe']]: R.verify(item)
    report = dict(complete=False, started=time.time(), method=R.pin(__file__),
                  acquisition=R.pin(a.acquisition), compilerSource=acq['source'], api=acq['api'],
                  programs=[], scope='C produced by the compiler written in Bend through a checked upstream-built JS testing API. Native-host B1/B2 qualification is separate.')
    method = R.pin(Path(__file__).with_name('compile-api.mjs')); report['emissionMethod'] = method
    (out/'snapshot-compile-api.mjs').write_bytes(Path(method['file']).read_bytes())
    def save(): R.save(out/'report.json', report)
    save()
    try:
        sources = {}
        for app in filter(None, a.apps.split(',')): sources[app] = ROOT/'selfhost/apps'/app/'main.bend'
        for source in a.source: sources[source.stem] = source.resolve()
        if a.manifest:
            manifest = R.read(a.manifest); assert manifest['complete']
            report['manifest'] = R.pin(a.manifest)
            for record in manifest['records']:
                source = Path(record['source']); sources[source.stem] = source
        assert sources
        for name, source in sources.items():
            folder = out/name; output = folder/'emitted'; folder.mkdir()
            row = dict(id=name, source=R.pin(source)); report['programs'].append(row); save()
            row['job'], _ = R.guarded(folder/'emit', [acq['context']['bun']['file'], method['file'],
                acq['api']['file'], source, output], seconds=180)
            result = R.read(output/'report.json'); assert result['complete']
            assert result['api'] == acq['api'] and result['source'] == row['source']
            row.update(receipt=R.pin(output/'report.json'), c=result['output'], complete=True)
            save(); print(R.json.dumps(dict(id=name, c=row['c'])), flush=True)
        for row in report['programs']: R.verify(row['source']); R.verify(row['c']); R.verify(row['receipt'])
        for item in [report['method'], report['acquisition'], acq['api'], acq['source'], method]: R.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: report['finished'] = time.time(); save()


if __name__ == '__main__': main()
