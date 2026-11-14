#!/usr/bin/env python3
"""Disassemble pinned hot string workers and count explicitly assumed loop paths."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/profiler'))
from compare import Reader, pin

# Taken decisions for one direct/unshared SCon/SCon continuing iteration.
# These are inspectable static witnesses, not measured dynamic branch frequencies.
PATHS = {
 'qbe_n1-eq': ('40af70', {'40afed':False,'40b000':False,'40b023':True,'40b07d':True,
    '40b0c7':False,'40b0d1':False,'40b0da':True,'40b114':True,'40b187':False,'40b18c':False}),
 'x86_n2-eq': ('406d0a', {'406d33':True,'407051':False,'4070a7':False,'4070cc':True,
    '4071de':True,'407252':False,'4072dd':False,'40730c':True,'407451':True,
    '4074e7':False,'407501':False,'40751b':False}),
 'qbe_n1-order': ('40b840', {'40b8d8':False,'40b8ea':False,'40b90a':True,'40b964':True,
    '40b9ae':False,'40b9b8':False,'40b9c3':True,'40b9fd':False,'40ba4c':False}),
 'x86_n2-order': ('40825d', {'408278':True,'408547':False,'40859d':False,'4085c2':True,
    '4086a0':False,'4086c1':True,'40875f':False,'4087df':False,'40880e':True,
    '408905':False,'408926':False})}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--comparison', type=Path, required=True)
    p.add_argument('--roles', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    reader = Reader()
    comparison, roles = (reader.read(pin(x)) for x in (a.comparison, a.roles))
    a.out.mkdir()  # Fresh output required.
    result = dict(complete=True, targetsRun=False, rows={},
        assumption='One continuing SCon/SCon iteration; direct/unshared payloads; '
                   'prior equality True or ordering EQ. Static instructions exclude callees. '
                   'Path frequency is not measured; counts are not dynamic performance counters.',
        inputs=[pin(a.comparison), pin(a.roles), pin(__file__), pin('/usr/bin/objdump')])
    for role, value in comparison['workloads']['test-map-set-ops'].items():
        binary = reader.verify(roles['roles'][role]['image'])
        result['inputs'].append(pin(binary))
        for suffix, lowered in [('eq','p88_string_eq_go'), ('order','String.order.go')]:
            name = role+'-'+suffix
            leaf = next(r for r in value['profile']['functions'] if
                        r['decoded'] == 'p113d_FID_$p118borrow.read.'+lowered)
            command = ['/usr/bin/objdump', '-d', '--no-show-raw-insn',
                       '--disassemble='+leaf['name'], str(binary)]
            asm = subprocess.check_output(command, text=True)
            asm_path = a.out/(name+'.asm')
            asm_path.write_text(asm)
            lines = []
            for line in asm.splitlines():
                m = re.match(r'^\s*([0-9a-f]+):\s+(.+)$', line)
                if m:
                    lines.append((m[1], m[2]))
            lookup = {ip:i for i,(ip,ins) in enumerate(lines)}
            start, branches = PATHS[name]
            index, path = lookup[start], []
            while True:
                ip, ins = lines[index]
                path.append((ip, ins))
                branch = re.match(r'(j\w+)\s+([0-9a-f]+)', ins)
                if branch:
                    # Missing conditional decisions raise; never silently infer a path.
                    take = branch[1] in ('jmp','jmpq') or branches[ip]
                    index = lookup[branch[2]] if take else index+1
                else:
                    index += 1
                if lines[index][0] == start:
                    break
                if len(path) > 2000:
                    raise ValueError('Path does not return to selected loop header')
            path_file = a.out/(name+'-continuing-path.asm')
            path_file.write_text('\n'.join(ip+': '+ins for ip,ins in path)+'\n')
            result['rows'][name] = dict(symbol=leaf, disassembly=pin(asm_path),
                command=command, path=pin(path_file), branchDecisions=branches,
                instructions=len(path),
                frameOperandInstructions=sum('%rbp' in ins for ip,ins in path),
                frameMemoryInstructions=sum('%rbp' in ins and not ins.startswith('lea') for ip,ins in path),
                calls=[ins for ip,ins in path if ins.startswith('call')],
                conditionalBranches=sum(re.match(r'j(?!mp)\w* ',ins) is not None for ip,ins in path))
    (a.out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:{f:v[f] for f in ['instructions','frameMemoryInstructions','conditionalBranches']}
                      for k,v in result['rows'].items()}))


if __name__ == '__main__':
    main()
