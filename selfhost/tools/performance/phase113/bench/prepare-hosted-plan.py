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
    p.add_argument('--pipeline', choices=['direct', 'static'], default='static',
                   help='direct uses staged Phase113 exports; static preserves the existing checked entry')
    p.add_argument('--runtime', type=Path,
                   help='Runtime object or directory containing runtime.o; defaults to frozen facts runtime')
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
    runtime = (a.runtime or Path(manifest['baseline']['runtime']['file'])).resolve()
    if runtime.is_dir():
        runtime /= 'runtime.o'
    runtime_pin = m.pin(runtime)
    required = (['p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission',
                 'p113d_lower_request', 'p113d_verify', 'p113d_chunks']
                if a.pipeline == 'direct' else ['p111_compile_source'])
    emitter = ROOT/'selfhost/tools/performance'/(
        'phase113/staged-emit.mjs' if a.pipeline == 'direct' else 'phase111/emit.mjs')
    api_receipt = api.parent/'report.json'
    checked = m.read(api_receipt)
    if (not checked.get('complete') or not checked.get('checked') or
            not set(required).issubset(checked.get('exports', [])) or m.verify(checked['api']) != api):
        raise ValueError('Complete checked compiler API with required exports needed: ' + ', '.join(required))
    if a.reuse_baseline_hosted and (a.pipeline != 'static' or
            m.pin(api) != manifest['baseline']['api'] or runtime_pin != manifest['baseline']['runtime']):
        raise ValueError('Existing hosted products require static pipeline, exact frozen facts API and runtime')
    reports = m.read(HERE/'baseline-hosted-existing01.json') if a.reuse_baseline_hosted else {}
    inputs = [m.pin(__file__), m.pin(HERE/'manifest01.json'), m.pin(api_receipt), checked['api'],
              m.pin(emitter),
              m.pin(ROOT/'selfhost/tools/performance/phase111/build.py'), runtime_pin,
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
        emit_command = [checked['command'][0], str(emitter), str(api), case['source']['file'], str(emit), 'cache']
        if a.pipeline == 'direct':
            emit_command.append('direct')
        jobs += [dict(name=name+'-emit', seconds=45, command=emit_command),
            dict(name=name+'-build', seconds=45, command=[sys.executable,'-B',
            str(ROOT/'selfhost/tools/performance/phase111/build.py'),'--source',str(emit/'program.ssa'),
            '--runtime',str(runtime),'--out',str(build),'--seconds','12'])]
        reports[name] = dict(emission=str(emit/'report.json'), build=str(build/'report.json'))
    for item in inputs:
        m.verify(item)
    a.out.parent.mkdir(parents=True,exist_ok=True)
    map_path = a.out.with_name(a.out.stem+'-reports.json')
    if map_path.exists():
        raise ValueError('Fresh reports map required')
    m.save(map_path,reports)
    m.save(a.out,dict(kind='phase113-hosted-acquisition-plan',methodVersion=2,targetsRun=False,inputs=inputs,
        pipeline=a.pipeline,requiredExports=required,api=m.pin(api),runtime=runtime_pin,
        reportsMap=m.pin(map_path),jobs=jobs,
        scope='Compile/build only through the selected checked Bend API transport and unchanged QBE builder. Source algorithms remain Bend. Static calls the existing p111_compile_source entry; direct calls staged Phase113 exports. Bind and execute separately; no requested products are claimed complete.'))
    print(str(a.out))


if __name__ == '__main__':
    main()
