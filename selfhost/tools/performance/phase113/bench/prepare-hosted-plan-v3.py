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
spec = importlib.util.spec_from_file_location('phase113_transport_v2', HERE/'transport-v2.py')
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--api', type=Path)
    p.add_argument('--pipeline', choices=['direct', 'array'], default='direct',
                   help='Version2 staged pipeline; admitted renderer is used when checked-exported')
    p.add_argument('--runtime', type=Path,
                   help='Runtime object or directory containing runtime.o; defaults to frozen facts runtime')
    p.add_argument('--tag', required=True, help='Fresh descriptive artifact prefix, e.g. p113-candidate01')
    p.add_argument('--out', type=Path, required=True)
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
    emitter = ROOT/'selfhost/tools/performance/phase113/staged-emit-v2.mjs'
    api_receipt = api.parent/'report.json'
    checked = m.read(api_receipt)
    contract = transport.select_exports(checked, a.pipeline)
    required = contract['requiredExports']
    if (not checked.get('complete') or not checked.get('checked') or
            not set(required).issubset(checked.get('exports', [])) or m.verify(checked['api']) != api):
        raise ValueError('Complete checked compiler API with required exports needed: ' + ', '.join(required))
    reports = {}
    inputs = [m.pin(__file__), m.pin(HERE/'manifest01.json'), m.pin(api_receipt), checked['api'],
              m.pin(emitter), m.pin(HERE/'transport-v2.py'),
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
        emit_command.append(a.pipeline)
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
    m.save(a.out,dict(kind='phase113-hosted-acquisition-plan',methodVersion=3,targetsRun=False,inputs=inputs,
        pipeline=a.pipeline,transportVersion=2,transportContract=contract,requiredExports=required,api=m.pin(api),runtime=runtime_pin,
        manifest=m.pin(HERE/'manifest01.json'),emitter=m.pin(emitter),reportsMap=m.pin(map_path),jobs=jobs,
        scope='Compile/build only through the selected checked Bend API transport and unchanged QBE builder. Source algorithms remain Bend. Version2 staged direct/array exports and exact selected renderer are recorded. Bind and execute separately; no requested products are claimed complete.'))
    print(str(a.out))


if __name__ == '__main__':
    main()
