"""Retain exact field-ceiling reader machine code; no target execution."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[5]
OUT = ROOT / 'selfhost/build/phase131/field-ceiling-inspection01'
FUNCTION = re.compile(r'(?m)^((?:export )?function[^\n]*\$([^ (]+)[^\n]*\{\n[\s\S]*?^\})')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def decode(name):
    return ''.join(chr(int(n)) for n in name.split('_FID_', 1)[1].split('_') if n)


assert not OUT.exists(); OUT.mkdir()
inputs = [pin(__file__)]; rows = []
for family, owner, parent in [('uses', 'p98_tag_eq', 'p131-regions-uses01-candidate-build'),
                              ('packet', 'p131_packet_query', 'p131-regions-late02-run-record-transfer-build')]:
    for role, directory in [('baseline', parent), ('dead-fields', f'p131-field-ceiling-{family}-mask01'),
                            ('nullary-pointer', f'p131-field-ceiling-{family}-null01')]:
        path = ROOT / 'selfhost/build/phase111' / directory / 'report.json'
        build = json.loads(path.read_text()); assert build['complete'] and build['outputExact']
        qbe = next(row for row in build['inputs'] if row['file'].endswith('.ssa'))
        for item in [qbe, build['binary']]:
            assert pin(item['file']) == item
            inputs.append(item)
        inputs.append(pin(path))
        selected = [m for m in FUNCTION.finditer(Path(qbe['file']).read_text())
                    if m[2].startswith('p113d_FID_') and decode(m[2]) == '$p118borrow.read.' + owner]
        assert len(selected) == 1
        m = selected[0]
        machine = subprocess.check_output(['objdump', '-d', '--no-show-raw-insn',
            '--disassemble=' + m[2], build['binary']['file']], text=True)
        instructions = [line for line in machine.splitlines() if re.match(r'^\s*[0-9a-f]+:\s+\S', line)]
        stem = family + '-' + role
        (OUT / (stem + '.ssa')).write_text(m[1] + '\n')
        (OUT / (stem + '.asm')).write_text(machine)
        rows.append(dict(family=family, role=role, symbol=m[2], qbeLines=len(m[1].splitlines()),
            qbeLoadl=sum(' =l loadl ' in line for line in m[1].splitlines()),
            qbeStorel=sum(line.startswith('storel ') for line in m[1].splitlines()),
            instructions=len(instructions),
            machineMoveInstructions=sum(bool(re.search(r':\s+mov\w*\s', line)) for line in instructions),
            machineCalls=sum(bool(re.search(r':\s+call\s', line)) for line in instructions),
            qbe=pin(OUT / (stem + '.ssa')), machine=pin(OUT / (stem + '.asm'))))
report = dict(complete=True, targetsRun=False, inputs=inputs, rows=rows,
    scope='Static instructions include mutually exclusive branches, alignment nops and cold paths; not dynamic work or performance estimates.')
(OUT / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(rows))
