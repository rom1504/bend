#!/usr/bin/env python3
"""Count selected paths in frozen disassembly; no native or compiler execution.

The branch choices are an explicit source-derived scenario, not sampled traces:
nonterminal list reverse, count1 dynamic parent, sealed retained child, raw CTR
accumulator, and (where used) hot allocation with no handoff. The initial/final
iterations, shared/static paths, allocator misses and handoffs are excluded.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
EVIDENCE = ROOT / 'implementation/phase110/evidence'
SCENARIOS = [
    ('delayed-qbe', 'machine06', 'qbe', 0x401e50, '%r12', '%rbp', {
        0x401e61: False, 0x401e6b: False, 0x401e9f: True,
        0x401efe: True, 0x401f41: True, 0x401f52: True, 0x401fea: False}),
    ('combined-qbe', 'machine07', 'qbe', 0x401e50, '%r12', '%rbp', {
        0x401e61: False, 0x401e6b: False, 0x401e9c: True,
        0x401ef8: True, 0x401f54: True, 0x401f62: True, 0x402023: False}),
    ('delayed-clang', 'machine06', 'clang', 0x401e5b, '%r12', '%rsp', {
        0x401e66: False, 0x401e7f: True, 0x401eee: False,
        0x401f01: False, 0x401f28: False, 0x401f2d: False}),
    ('combined-clang', 'machine07', 'clang', 0x401e6f, '%rdi', '%rsp', {
        0x401e7a: False, 0x401e89: True, 0x401eff: False,
        0x401f12: False, 0x401f4e: False, 0x401f57: False}),
]


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(raw),
                sha256=hashlib.sha256(raw).hexdigest())


def operands(text):
    depth, parts, start = 0, [], 0
    for index, char in enumerate(text):
        depth += (char == '(') - (char == ')')
        if char == ',' and depth == 0:
            parts.append(text[start:index]); start = index + 1
    parts.append(text[start:])
    return parts


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(EVIDENCE):
        raise ValueError('fresh evidence output required')
    report = dict(kind='phase110-offline-selected-machine-paths', version=1,
        complete=False, targetsRun=False, inputs=[pin(Path(__file__))], paths=[],
        scenario=__doc__, limitation='Source-selected instruction paths, not hardware traces or cycle attribution. Memory counts are architectural read/write operands; read-modify-write counts once in each direction.')
    for name, folder, backend, entry, allocator, stack in [s[:6] for s in SCENARIOS]:
        decisions = next(s[6] for s in SCENARIOS if s[0] == name)
        path = EVIDENCE / folder / f'runtime-ir-single-{backend}--nx_list_reverse.asm'
        receipt = json.loads((EVIDENCE / folder / 'report.json').read_text())
        profile = next(row for row in receipt['profiles'] if row['name'] == f'runtime-ir-single-{backend}')
        symbol = next(row for row in profile['symbols'] if row['name'] == 'nx_list_reverse')
        if pin(path) != symbol['assembly']:
            raise ValueError('changed disassembly')
        report['inputs'] += [pin(path), pin(EVIDENCE / folder / 'report.json')]
        ins = []
        for line in path.read_text().splitlines():
            m = re.match(r'^\s*([0-9a-f]+):\s+(\S+)(?:\s+(.*))?$', line)
            if m:
                ins.append(dict(address=int(m[1], 16), mnemonic=m[2], operands=m[3] or ''))
        positions = {row['address']: index for index, row in enumerate(ins)}
        pc, trace, branches = entry, [], []
        while not trace or pc != entry:
            row = ins[positions[pc]]
            trace.append(row)
            if len(trace) > 500 or row['mnemonic'].startswith(('call', 'ret')):
                raise ValueError('selected path leaves expected call-free loop')
            if row['mnemonic'].startswith('j'):
                target = int(row['operands'].split()[0], 16)
                taken = True if row['mnemonic'].startswith('jmp') else decisions[pc]
                branches.append(dict(address=hex(pc), taken=taken, target=hex(target)))
                pc = target if taken else ins[positions[pc] + 1]['address']
            else:
                pc = ins[positions[pc] + 1]['address']
        memory, accesses = Counter(), []
        for row in trace:
            op = row['mnemonic']
            if op.startswith(('lea', 'nop')):
                continue
            args = operands(row['operands'])
            for index, arg in enumerate(args):
                if '(' not in arg:
                    continue
                kind = 'stack' if stack in arg else 'allocator' if allocator in arg else 'heap'
                if op.startswith('mov'):
                    directions = ['write' if index == len(args) - 1 else 'read']
                elif op.startswith(('inc', 'dec', 'add', 'sub', 'or', 'and', 'xor')) and index == len(args) - 1:
                    directions = ['read', 'write']
                else:
                    directions = ['read']
                for direction in directions:
                    memory[kind + '-' + direction] += 1
                accesses.append(dict(address=hex(row['address']), kind=kind,
                                     directions=directions, instruction=op + ' ' + row['operands']))
        report['paths'].append(dict(name=name, functionBytes=symbol['bytes'],
            instructionCount=len(trace), conditionalBranches=sum(not row['mnemonic'].startswith('jmp') and row['mnemonic'].startswith('j') for row in trace),
            unconditionalBranches=sum(row['mnemonic'].startswith('jmp') for row in trace),
            calls=0, memory=dict(memory), branches=branches, memoryInstructions=accesses,
            instructions=[dict(address=hex(row['address']), mnemonic=row['mnemonic'], operands=row['operands']) for row in trace]))
    report['complete'] = True
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps([dict(name=row['name'], instructions=row['instructionCount'],
                          branches=row['conditionalBranches'], memory=row['memory']) for row in report['paths']]))


if __name__ == '__main__':
    main()
