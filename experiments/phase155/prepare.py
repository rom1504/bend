#!/usr/bin/env python3
"""Extract a shared checked/native screen. Host code supplies no compiler semantics."""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source as assembly
from common import fresh_output, pin, require, write_json
spec = importlib.util.spec_from_file_location('extract155', ROOT / 'experiments/phase147/tools/prepare.py')
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)

HARNESS = '''
@unsafe
def p155h_count(id: String, mode: String, parsed: Maybe<&2,U32>) -> IO(U32):
  match parsed:
    case None{}: IO.die(U32,2,"invalid count")
    case Some{count}:
      do IO<U32>:
        Unit <- IO.print(p155h_text(id,mode,count))
        IO.pure(U32,0)

@unsafe
def p155h_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{sentinel,Con{id,Con{mode,Con{text,Nil{}}}}}:
      p155h_count(id,mode,U32.read(text))
    case _: IO.die(U32,2,"usage: screen ID old/new COUNT")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p155h_args(args)
'''


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--families', required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    canonical = assembly.maintained_assemble(ROOT/'selfhost/src/compiler.json', ROOT/'selfhost', 'qbe')
    qpath = ROOT/'implementation/phase152/qualification.json'
    q = json.loads(qpath.read_text())
    require(hashlib.sha256(canonical).hexdigest() == q['source']['sha256'], 'Qualified source changed')
    _, blocks = assembly.blocks(canonical)
    parts = [('canonical', b''.join(b['data'] for b in blocks if b['name'] != 'main'))]
    inputs = [pin(__file__), pin(E.__file__), pin(assembly.__file__), pin(qpath), pin(ROOT/'selfhost/src/compiler.json')]
    modules, cases, rejected, extra_checks = [], [], [], []
    for family in a.families.split(','):
        f = ROOT/'experiments/phase155'/family/'spec.json'
        value = json.loads(f.read_text())
        inputs.append(pin(f))
        for row in value.get('inputs', []):
            actual = pin(ROOT / row['file'])
            require(actual['sha256'] == row['sha256'] and actual['bytes'] == row['bytes'], 'Changed fixture pin')
            inputs.append(actual)
        additions = value.get('extraChecks', []) + value.get('supplementalControls', [])
        if value.get('literalControl'): additions.append(value['literalControl'])
        if value.get('controlFunction'): additions.append(dict(function=value['controlFunction'],arguments=[],expected=value['expectedControl']))
        for row in value['cases']:
            if row.get('independentControlFunction'):
                additions.append(dict(function=row['independentControlFunction'],n=row['independentControlArgument'],expected=row['independentControlExpected']))
        for check in additions:
            arguments = [[n] for n in check['controls']] if 'controls' in check else [check.get('arguments', [check['n']] if 'n' in check else [])]
            for args in arguments:
                extra_checks.append(dict(function=check.get('function', check.get('entry')),
                    arguments=args, expected=check['expected'], family=family))
        for module in value.get('dependencies', []) + [value['module']]:
            if not module.endswith('.bend'): continue  # Named dependencies are found by exact declaration closure.
            if module not in modules:
                modules.append(module)
        for row in value['cases']:
            row = dict(row, family=family)
            if row.get('status') == 'rejected-static': rejected.append(row)
            else:
                require(row['resultType'] == 'String', 'Common String return required')
                require(row['id'] not in [r['id'] for r in cases], 'Duplicate experiment ID')
                oracle = row.get('oracle', '')
                if isinstance(oracle,str) and oracle.endswith('.json'):
                    opath=ROOT/oracle
                    inputs.append(pin(opath))
                    orows=json.loads(opath.read_text())['rows']
                    row['expected']={str(r['n']):r['expected'] for r in orows if r['id']==row['id']}
                cases.append(row)
    for module in modules:
        f = ROOT/module
        parts.append((module, f.read_bytes()))
        inputs.append(pin(f))
    expression = '"unknown experiment"'
    for index,check in enumerate(extra_checks):
        check['argumentId']='extra'+str(index)
        args=','.join(str(x) for x in check['arguments'])
        call=f'{check["function"]}({args})'
        if isinstance(check['expected'],bool): call=f'U32.show(Bool.to_u32({call}))'
        expression=f'nt_choose(String,String.eq(id,"{check["argumentId"]}"),u => {call},u => {expression})'
    for row in reversed(cases):
        call = f'nt_choose(String,String.eq(mode,"new"),v => {row["new"]}(count),v => {row["old"]}(count))'
        expression = f'nt_choose(String,String.eq(id,"{row["id"]}"),u => {call},u => {expression})'
    harness = ('@unsafe\ndef p155h_text(+id: String, +mode: String, +count: U32) -> String:\n  ' + expression + '\n' + HARNESS).encode()
    parts.append(('harness', harness))
    exports = list(dict.fromkeys([r[role] for r in cases for role in ('old', 'new')] + [c['function'] for c in extra_checks]))
    body, declarations = E.extract(parts, ['main', *exports], 2_000_000)
    out = fresh_output(a.out, ROOT)
    (out/'compiler.bend').write_bytes(body)
    (out/'harness.bend').write_bytes(harness)
    write_json(out/'exports.json', dict(kind='bend-hosted-api-exports', version=1, exports=exports,
               protocol='hosted-api-v1', targets=['qbe'], preparationModes=['live'],
               scope='Private twenty-idea hypothesis screen; not a production compiler.'))
    checked, native = out/'checked-api', out/'native'
    jobs = [E.guard('phase155-source-check', checked,
        [ROOT/'selfhost/.assets/bin/bun', ROOT/'selfhost/tools/build/hosted.mjs', 'acquire',
         '--source', out/'compiler.bend', '--exports', out/'exports.json', '--upstream', ROOT/'selfhost/.bootstrap/upstream-phase66',
         '--engine', ROOT/'selfhost/.assets/bin/bun', '--out', checked], 150, 2048, 256),
        E.guard('phase155-native-screen', native,
        ['python3','-B',ROOT/'selfhost/tools/build/native.py','--assets',ROOT/'selfhost/manifests/assets-native.json',
         '--host','native','--stage','N2','--target','qbe','--mode','cache',
         '--image',ROOT/'selfhost/build/phase152/native-n2/program',
         '--image-receipt',ROOT/'selfhost/build/phase152/native-n2/report.json',
         '--source',out/'compiler.bend','--out',native,'--retain-ir','--seconds','240'], 260, 2048, 512)]
    report = dict(kind='phase155-screen-preparation', version=1, complete=True, targetsRun=False,
                  source=pin(out/'compiler.bend'), inputs=inputs, cases=cases, rejected=rejected, extraChecks=extra_checks,
                  declarations=declarations, exports=exports, apiReport=str(checked/'report.json'),
                  binary=str(native/'program'), buildReport=str(native/'report.json'), jobs=jobs)
    write_json(out/'manifest.json', report)
    write_json(out/'jobs.json', jobs)
    print(json.dumps(dict(source=report['source'], cases=len(cases), rejected=len(rejected), declarations=len(declarations))))


if __name__ == '__main__': main()
