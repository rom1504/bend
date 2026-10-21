"""Authenticate products and retain comparable, read-only native disassembly."""
import argparse, hashlib, json, re, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]

def pin(file):
    file = Path(file).resolve()
    data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def decode(name):
    return re.sub(r'(?:\d+_){3,}', lambda m: ''.join(chr(int(x)) for x in m[0].strip('_').split('_')), name)

p = argparse.ArgumentParser()
p.add_argument('--screen', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--names', nargs='+', required=True)
p.add_argument('--functions', nargs='+', required=True)
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase121')
report = json.loads(a.screen.read_text())
assert report['complete']
out.mkdir()
result = dict(complete=False, inputs=[pin(__file__), pin(a.screen)], rows=[],
              scope='Static machine instructions, not execution counts. Unsized QBE functions end at the next text symbol. Whole-function counts do not measure hot-loop cost.')
for name in a.names:
    for role in ['baseline', 'candidate', 'upstream']:
        binary = next(x['binary'] for x in report['rows'] if x['name'] == name and x['role'] == role)
        assert pin(binary['file']) == binary
        result['inputs'].append(binary)
        symbols = []
        for line in subprocess.check_output(['nm', '-n', '--defined-only', binary['file']], text=True).splitlines():
            fields = line.split()
            if len(fields) == 3 and fields[1] in ['T', 't']:
                symbols.append((int(fields[0], 16), fields[2]))
        for i, (start, symbol) in enumerate(symbols[:-1]):
            decoded = decode(symbol)
            if not any(x in decoded for x in a.functions):
                continue
            end = symbols[i + 1][0]
            command = ['objdump', '-d', '--no-show-raw-insn', '--start-address=' + hex(start), '--stop-address=' + hex(end), binary['file']]
            asm = subprocess.check_output(command, text=True)
            file = out / f'{name}-{role}-{symbol}.asm'
            file.write_text(asm)
            instructions = re.findall(r'^\s*[0-9a-f]+:\s+([a-z][a-z0-9]*)\s*(.*?)$', asm, re.M)
            counts = dict(instructions=len(instructions), calls=sum(op.startswith('call') for op, _ in instructions),
                          conditionalBranches=sum(op.startswith('j') and op != 'jmp' for op, _ in instructions),
                          setcc=sum(op.startswith('set') for op, _ in instructions),
                          floatIntegerMoves=sum(op in ['movd', 'movq'] and '%xmm' in args for op, args in instructions),
                          stackReferences=sum(bool(re.search(r'\(%r(?:sp|bp)\)', args)) for _, args in instructions))
            result['rows'].append(dict(name=name, role=role, symbol=symbol, decoded=decoded, start=hex(start), end=hex(end), counts=counts, assembly=pin(file), command=command))
result['complete'] = True
(out / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps([dict(name=x['name'], role=x['role'], function=x['decoded'], **x['counts']) for x in result['rows']], indent=2))
