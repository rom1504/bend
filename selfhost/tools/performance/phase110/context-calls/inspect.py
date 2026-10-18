#!/usr/bin/env python3
"""Inspect qualified context-call worker machine code; never execute a target."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[5]

def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def command(args):
    return subprocess.check_output(list(map(str, args)), text=True)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); build = a.build.resolve(); out = a.out.resolve()
    receipt = json.loads((build / 'report.json').read_text())
    if not receipt.get('complete') or receipt.get('kind') not in ['phase110-context-call-machine-ablation', 'phase110-context-wide-machine']:
        raise ValueError('complete qualified context-call machine receipt required')
    if out.exists() or not out.is_relative_to(ROOT / 'implementation/phase110/evidence'):
        raise ValueError('fresh implementation/phase110/evidence output required')
    out.mkdir(); tools = {name: Path(shutil.which(name)).resolve() for name in ['nm', 'objdump']}
    report = dict(kind='phase110-context-offline-machine', complete=False, targetsRun=False,
        inputs=[pin(Path(__file__)), pin(build / 'report.json')],
        tools={name: dict(pin=pin(path), version=command([path, '--version']).splitlines()[0]) for name, path in tools.items()},
        scope='Static instruction/call/stack-operand sites, not dynamic counts or cycle attribution.', workers=[])
    entries = receipt.get('semantics', receipt.get('observations', []))
    for row in entries:
        binary_pin = row.get('worker', row.get('binary')); binary = Path(binary_pin['file'])
        if pin(binary) != binary_pin: raise ValueError('worker binary differs')
        report['inputs'].append(binary_pin)
        name = row.get('name', 'wide') + '-' + row['mode'] + '-' + row['backend']
        symbols = []
        for line in command([tools['nm'], '-S', '--defined-only', binary]).splitlines():
            fields = line.split()
            if len(fields) != 4: continue
            symbol = fields[3]
            if not symbol.startswith('nx_') or symbol.startswith(('nx_rt_', 'nx_construct')): continue
            if symbol in ['nx_term', 'nx_env']: continue
            assembly = command([tools['objdump'], '-d', '--no-show-raw-insn', '--disassemble=' + symbol, binary])
            artifact = out / (name + '--' + symbol + '.asm'); artifact.write_text(assembly)
            instructions = []
            for instruction in assembly.splitlines():
                match = re.match(r'^\s*([0-9a-f]+):\s+(\S+)(?:\s+(.*))?$', instruction)
                if match: instructions.append(dict(address=int(match[1],16), mnemonic=match[2], operands=match[3] or ''))
            calls = []
            for instruction in instructions:
                if instruction['mnemonic'].startswith('call'):
                    target = re.search(r'<([^>]+)>', instruction['operands'])
                    calls.append(dict(address=instruction['address'], target=target[1] if target else instruction['operands']))
            stack = [i for i in instructions if re.search(r'\([^)]*%(?:rsp|rbp)[^)]*\)', i['operands']) and not i['mnemonic'].startswith(('lea', 'nop'))]
            symbols.append(dict(name=symbol, address=int(fields[0],16), bytes=int(fields[1],16), visibility=fields[2],
                instructionSites=len(instructions), calls=calls, stackMemorySites=stack,
                stackAdjustments=[i for i in instructions if i['mnemonic'] in ['push','pop','pushq','popq'] or (i['mnemonic'] in ['sub','add'] and i['operands'].endswith(',%rsp'))],
                mnemonics=dict(Counter(i['mnemonic'] for i in instructions)), assembly=pin(artifact)))
        report['workers'].append(dict(name=name, mode=row['mode'], backend=row['backend'], binary=binary_pin, symbols=symbols))
    for identity in report['inputs']:
        if pin(Path(identity['file'])) != identity: raise ValueError('input changed during inspection')
    report['complete'] = True
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, workers=len(report['workers']), report=str(out / 'report.json'))))

if __name__ == '__main__': main()
