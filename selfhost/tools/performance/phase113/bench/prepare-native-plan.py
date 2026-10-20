#!/usr/bin/env python3
"""Prepare/verify a pinned full-image qualification plan; execute no targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PHASE = ROOT/'selfhost/tools/performance/phase111'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


native = module('native_receipt_tools', PHASE/'native-emit.py')
contract_tool = module('staged_contract', HERE/'transport-v2.py')
pin, verify = native.pin, native.verify


def read(path):
    return json.loads(Path(path).read_text())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    modes = p.add_subparsers(dest='mode', required=True)
    prep = modes.add_parser('prepare')
    prep.add_argument('--api', type=Path, required=True)
    prep.add_argument('--source', type=Path, required=True)
    prep.add_argument('--runtime', type=Path, default=ROOT/'selfhost/build/phase113/runtime-products-build01/runtime.o')
    prep.add_argument('--tag', required=True)
    prep.add_argument('--out', type=Path, required=True)
    check = modes.add_parser('verify')
    check.add_argument('--plan', type=Path, required=True)
    a = p.parse_args()
    if a.mode == 'verify':
        plan = read(a.plan)
        if plan.get('kind') != 'phase113-native-qualification-plan':
            raise ValueError('Native qualification plan required')
        for row in plan['inputs']:
            verify(row)
        print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(a.plan))))
        return
    if a.out.exists() or not re.fullmatch(r'p113-[a-zA-Z0-9_-]+', a.tag):
        raise ValueError('Fresh plan and descriptive p113- tag required')
    api = native.member(a.api, 'api.mjs')
    source = native.member(a.source, 'compiler.bend')
    runtime = native.member(a.runtime, 'runtime.o')
    api_report, source_manifest, runtime_report = api.parent/'report.json', source.parent/'manifest.json', runtime.parent/'report.json'
    checked, composition, built_runtime = read(api_report), read(source_manifest), read(runtime_report)
    contract = contract_tool.select_exports(checked, 'array')
    if (not checked.get('complete') or not checked.get('checked') or checked['api'] != pin(api) or
            contract['rendererReverifies'] or 'p111_compile_source' not in checked['exports']):
        raise ValueError('Complete checked array API with admitted renderer and native entry export required')
    if composition['source'] != pin(source) or pin(source) not in checked['inputs']:
        raise ValueError('API must bind the exact composed full source')
    checked_sources = [str(Path(word).resolve()) for word in checked['command'] if word.endswith('.bend')]
    if checked_sources != [str(source)]:
        raise ValueError('Checked API compiler source mismatch')
    if not built_runtime.get('complete') or built_runtime.get('object') != pin(runtime):
        raise ValueError('Complete matching product runtime build required')
    text = source.read_text()
    if (len(re.findall(r'^def p111_emit_admitted\(', text, re.M)) != 1 or
            'p113a_emit_lowered(p113a_lower_request(request))' not in text or
            len(re.findall(r'^def main\(', text, re.M)) != 1 or 'p111_native_args(args)' not in text):
        raise ValueError('Expected actual array native hook and original native main required')
    artifacts = {name: ROOT/'selfhost/build/phase111'/(a.tag+'-'+suffix) for name, suffix in
                 [('hosted', 'full-emit'), ('n1', 'n1'), ('n1Focused', 'n1-focused'),
                  ('self', 'self'), ('n2Focused', 'n2-focused'), ('n2Full45', 'n2-full45')]}
    artifacts['comparison'] = ROOT/'selfhost/build/phase113'/(a.tag+'-qbe-comparison.json')
    artifacts['jobs'] = ROOT/'selfhost/build/phase113'/(a.tag+'-qualification')
    artifacts['guard'] = ROOT/'selfhost/build/phase113'/(a.tag+'-qualification-guard')
    if any(path.exists() for path in artifacts.values()):
        raise ValueError('One or more planned artifact destinations already exist')
    py = [sys.executable, '-B']
    staged = HERE.parent/'staged-emit-v2.mjs'
    build, emit, focused, full45 = PHASE/'build.py', PHASE/'native-emit.py', PHASE/'coverage/native-run.py', PHASE/'coverage/full45/native-run.py'
    jobs = [dict(name='authenticate-plan', seconds=15, command=py+[str(Path(__file__).resolve()), 'verify', '--plan', str(a.out.resolve())]),
            dict(name='full-hosted-array-emission', seconds=600, command=[checked['command'][0], str(staged), str(api), str(source), str(artifacts['hosted']), 'cache', 'array']),
            dict(name='n1-build', seconds=150, command=py+[str(build), '--source', str(artifacts['hosted']/'program.ssa'), '--runtime', str(runtime), '--out', str(artifacts['n1']), '--seconds', '120'])]
    def focus(label, image, out):
        return dict(name=label, seconds=180, command=py+[str(focused), '--image', str(image), '--runtime', str(runtime), '--suite', 'focused', '--seconds', '30', '--build-seconds', '30', '--out', str(out)])
    n1, n2 = artifacts['n1']/'program', artifacts['self']/'build/program'
    jobs += [focus('n1-focused19', n1, artifacts['n1Focused']),
             dict(name='native-self-emission-n2-build', seconds=1050, command=py+[str(emit), '--image', str(n1), '--source', str(source), '--out', str(artifacts['self']), '--mode', 'cache', '--runtime', str(runtime), '--seconds', '650', '--build-seconds', '120']),
             dict(name='exact-hosted-native-qbe', seconds=30, command=py+[str(HERE/'compare-native-qbe.py'), '--plan', str(a.out.resolve()), '--out', str(artifacts['comparison'])]),
             focus('n2-focused19', n2, artifacts['n2Focused']),
             dict(name='n2-original-full45', seconds=300, command=py+[str(full45), '--partition', 'all45', '--image', str(n2), '--runtime', str(runtime), '--seconds', '120', '--build-seconds', '10', '--out', str(artifacts['n2Full45'])])]
    tools = [Path(__file__), HERE/'transport-v2.py', HERE/'compare-native-qbe.py', staged, build, emit, focused, full45,
             PHASE/'guard.py', ROOT/'selfhost/tools/performance/programs/support.py', HERE.parent/'run-jobs.py',
             PHASE/'native-assets01.json', PHASE/'coverage/manifest.json', PHASE/'coverage/full45/manifest.json']
    inputs = [*[pin(path) for path in tools], pin(api_report), pin(source_manifest), pin(runtime_report),
              pin(api), pin(source), pin(runtime), *checked['inputs'], *built_runtime['inputs']]
    for snapshot in composition.get('moduleSnapshots', []):
        inputs.append(snapshot['snapshot'])
    inputs = list({row['file']: row for row in inputs}.values())
    for row in inputs:
        verify(row)
    guard_seconds = sum(job['seconds'] for job in jobs)+60
    guard = py+[str(PHASE/'guard.py'), '--out', str(artifacts['guard']), '--seconds', str(guard_seconds),
                '--rss-mib', '4096', '--available-mib', '16384', '--file-mib', '128', '--cpu', '3', '--',
                *py, str(HERE.parent/'run-jobs.py'), '--plan', str(a.out.resolve()), '--out', str(artifacts['jobs'])]
    plan = dict(kind='phase113-native-qualification-plan', targetsRun=False, inputs=inputs, source=pin(source),
                api=pin(api), runtime=pin(runtime), sourceManifest=pin(source_manifest), apiReport=pin(api_report),
                runtimeReport=pin(runtime_report), pipeline='array', transportContract=contract, jobs=jobs,
                artifacts={key:str(value) for key,value in artifacts.items()}, rootGuardCommand=guard,
                guard=dict(cpu=3,rssMiB=4096,availableMiB=16384,fileMiB=128,seconds=guard_seconds),
                scope='Root-only serial qualification using actual Bend compiler/native entry. No host lowering. Includes hosted→N1→N2 exact QBE reproduction and unchanged focused19/full45 semantics; no runtime speed measurement or N2 self-reemit claim.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(plan, indent=2)+'\n')
    print(json.dumps(dict(plan=pin(a.out), targetsRun=False, rootGuardCommand=guard)))


if __name__ == '__main__':
    main()
