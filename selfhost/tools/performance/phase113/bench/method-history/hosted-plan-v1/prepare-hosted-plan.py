#!/usr/bin/env python3
"""Create an authenticated emission/build job plan without executing targets."""
import argparse
import importlib.util
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('phase113_adapter', HERE/'run.py')
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
m = adapter.method


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--api', type=Path)
    p.add_argument('--tag', required=True, help='Fresh descriptive artifact prefix, e.g. p113-candidate01')
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--reuse-baseline-hosted', action='store_true')
    a = p.parse_args()
    if a.out.exists() or '/' in a.tag or not a.tag.startswith('p113-'):
        raise ValueError('Fresh plan path and p113- tag required')
    manifest = m.read(HERE/'manifest01.json')
    api = (a.api or Path(manifest['baseline']['api']['file'])).resolve()
    if api.is_dir():
        api /= 'api.mjs'
    api_receipt = api.parent/'report.json'
    checked = m.read(api_receipt)
    if not checked.get('complete') or not checked.get('checked') or 'p111_compile_source' not in checked['exports'] or m.verify(checked['api']) != api:
        raise ValueError('Complete checked compiler API required')
    if a.reuse_baseline_hosted and m.pin(api) != manifest['baseline']['api']:
        raise ValueError('Existing hosted products belong only to exact frozen facts API')
    reports = m.read(HERE/'baseline-hosted-existing01.json') if a.reuse_baseline_hosted else {}
    inputs = [m.pin(__file__), m.pin(HERE/'manifest01.json'), m.pin(api_receipt), checked['api'],
              m.pin(ROOT/'selfhost/tools/performance/phase111/emit.mjs'),
              m.pin(ROOT/'selfhost/tools/performance/phase111/build.py'), manifest['baseline']['runtime'],
              manifest['base'], manifest['carrier'], *checked['inputs']]
    jobs = []
    for case in manifest['cases']:
        inputs.append(case['source'])
        name = case['name']
        if name in reports:
            continue
        emit = ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-emit')
        build = ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-build')
        if emit.exists() or build.exists():
            raise ValueError('Planned artifact path already exists')
        jobs += [dict(name=name+'-emit', seconds=45, command=[checked['command'][0],
            str(ROOT/'selfhost/tools/performance/phase111/emit.mjs'),str(api),case['source']['file'],str(emit),'cache']),
            dict(name=name+'-build', seconds=45, command=[sys.executable,'-B',
            str(ROOT/'selfhost/tools/performance/phase111/build.py'),'--source',str(emit/'program.ssa'),
            '--runtime',manifest['baseline']['runtime']['file'],'--out',str(build),'--seconds','12'])]
        reports[name] = dict(emission=str(emit/'report.json'), build=str(build/'report.json'))
    for item in inputs:
        m.verify(item)
    a.out.parent.mkdir(parents=True,exist_ok=True)
    map_path = a.out.with_name(a.out.stem+'-reports.json')
    if map_path.exists():
        raise ValueError('Fresh reports map required')
    m.save(map_path,reports)
    m.save(a.out,dict(kind='phase113-hosted-acquisition-plan',targetsRun=False,inputs=inputs,
        api=m.pin(api),reportsMap=m.pin(map_path),jobs=jobs,
        scope='Compile/build only through unchanged checked Bend API emitter and QBE builder. Source algorithms remain Bend. Bind and execute separately; no requested products are claimed complete.'))
    print(str(a.out))


if __name__ == '__main__':
    main()
