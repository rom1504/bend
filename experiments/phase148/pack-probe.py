#!/usr/bin/env python3
"""Prepare a dependency-closed, ordinary valid one-function unit control."""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).with_name('tools')))
import shared as S

PROBE = '''@unsafe
def p148t_build(build: P148Build) -> String:
  match build:
    case P148Build{tape,index,wc,vc,nc,error}: p148t_tape(tape)

@unsafe
def p148t_body() -> P113DFunction:
  P113DFunction{"f",[],1,False{},[P113DResult{[N111Const{7,0}]}]}

@unsafe
def p148t_tape(tape: P148Tape) -> String:
  match tape:
    case P148Tape{words,values,names,used,valueUsed,nameUsed}: U32.show(used) ++ ":" ++ U32.show(valueUsed) ++ ":" ++ U32.show(nameUsed)

@unsafe
def p148t_show(unit: P148Unit) -> String:
  match unit:
    case P148Good{name,params,result,public,tape}: "Good:" ++ name ++ ":" ++ p148t_tape(tape)
    case P148Bad{error}: "Bad:" ++ error
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mode', choices=['storage', 'intern', 'seed', 'pack', 'scalar', 'roundtrip', 'verify'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    expressions = dict(intern='p148t_build(p148c_step1(p148c_intern("state",P148Build{P148Tape{p148w_new(9),p148w_new(32),Array.new(String,2n,""),0,0,0},P147VEmpty{},9,32,3,""})))', seed='p148t_build(p148c_seed(P148Build{P148Tape{p148w_new(9),p148w_new(32),Array.new(String,2n,""),0,0,0},P147VEmpty{},9,32,3,""}))', storage='p148t_show(P148Good{"f",[],1,False{},P148Tape{p148w_new(9),p148w_new(32),Array.new(String,2n,""),9,3,3}})', pack='p148t_show(p148_pack(p148t_body()))',
                       scalar='p148t_show(p148o_function(p148_pack(p148t_body())))',
                       roundtrip='p148t_show(p148_pack(p148_unpack(p148_pack(p148t_body()))))',
                       verify='p148v_function(p148_pack(p148t_body()),N111Ids{missing(),missing()},missing())')
    source = PROBE + '\n@unsafe\ndef p148t_result() -> String:\n  ' + expressions[args.mode] + '\n\n@unsafe\ndef main() -> IO(Unit):\n  IO.print(p148t_result())\n'
    modules = [S.ROOT / ('selfhost/tests/phase148/' + name + '.bend') for name in ['core', 'scalar', 'verify']]
    parts, inputs, identity = S.sources(modules)
    _, blocks = S.assembly.blocks(parts[0][1])
    parts[0] = ('canonical', b''.join(r['data'] for r in blocks if r['name'] != 'main'))
    body, declarations = S.extract(parts + [('probe', source.encode())], ['main'])
    out = S.fresh_output(args.out, S.ROOT)
    (out / 'program.bend').write_bytes(body)
    S.write_json(out / 'exports.json', dict(kind='bend-hosted-api-exports', version=1, exports=['p148t_result'],
        protocol='hosted-api-v1', targets=['qbe'], preparationModes=['live']))
    jobs = [S.guard('unit-probe-source', out / 'checked', [S.ROOT / 'selfhost/.assets/bin/bun',
        S.ROOT / 'selfhost/tools/build/hosted.mjs', 'acquire', '--source', out / 'program.bend',
        '--exports', out / 'exports.json', '--upstream', S.ROOT / 'selfhost/.bootstrap/upstream-phase66',
        '--engine', S.ROOT / 'selfhost/.assets/bin/bun', '--out', out / 'checked'], 90, 2048, 128),
        S.guard('unit-probe-native', out / 'native', ['python3', '-B', S.ROOT / 'selfhost/tools/build/native.py',
        '--assets', S.ROOT / 'selfhost/manifests/assets-native.json', '--host', 'native', '--stage', 'N2',
        '--target', 'qbe', '--mode', 'cache', '--image', S.ROOT / 'selfhost/build/phase147/integrated-sequel02/n2/program',
        '--image-receipt', S.ROOT / 'implementation/phase147/candidate.json', '--source', out / 'program.bend',
        '--retain-ir', '--seconds', '90', '--out', out / 'native'], 120, 2048, 128)]
    S.write_json(out / 'jobs.json', jobs)
    S.write_json(out / 'manifest.json', dict(kind='phase148-valid-unit-control', mode=args.mode,
        inputs=[S.pin(__file__), *inputs], source=S.pin(out / 'program.bend'),
        expected={'verify':'\n','seed':'0:0:3\n','intern':'0:0:1\n'}.get(args.mode,'Good:f:9:3:3\n'),
        scope='Ordinary valid constant-return function; no malformed code or runtime modifications.'))
    print(json.dumps(dict(mode=args.mode, source=S.pin(out / 'program.bend'), jobs=str(out / 'jobs.json'))))


if __name__ == '__main__':
    main()
