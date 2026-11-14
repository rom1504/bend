#!/usr/bin/env python3
"""Offline objdump comparison of already-built products; never runs targets."""
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / 'selfhost/build/phase194/native45-02'
CASES = ['local-pair', 'editdist', 'coverage-numeric-recurrence-256',
         'variation-ray-active-64-2440', 'tree-bitonic', 'lexer']
variants = {'hybrid': ROOT / 'selfhost/build/phase195/hybrid-dev-build01'}
for argument in sys.argv[1:]:
    label, directory = argument.split('=', 1)
    assert label not in variants and label != 'baseline'
    variants[label] = Path(directory).resolve()


def pin(path):
    data = Path(path).read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(record):
    assert pin(record['file']) == {k: record[k] for k in ('file', 'bytes', 'sha256')}, record['file']


def load(directory):
    report = json.loads((directory / 'report.json').read_text())
    assert report['complete'] and not report.get('error') and not report.get('changedInputs')
    rows = {r['id']: r for r in report['rows']}
    sources = rows
    if 'emission' in report:
        verify(report['emission'])
        emission = json.loads(Path(report['emission']['file']).read_text())
        assert emission['complete'] and not emission.get('error')
        sources = {r['id']: r for r in emission['rows']}
    for case in CASES:
        row = rows[case]
        assert row['complete']
        for key in ('artifact', 'buildReceipt', 'oracleReceipt'):
            verify(row[key])
    return report, rows, sources


def symbol_name(symbol):
    if '_FID_' not in symbol:
        return symbol
    prefix, numbers = symbol.split('_FID_', 1)
    if not re.fullmatch(r'[0-9_]+', numbers):
        return symbol
    return prefix + ':' + ''.join(chr(int(x)) for x in numbers.split('_') if x)


def components(rows):
    # Tarjan on instruction-level intra-function control flow. Calls fall
    # through; terminal returns/indirect jumps have no modeled successor.
    addresses = {r[0] for r in rows}
    edges = {}
    for index, (address, mnemonic, operands) in enumerate(rows):
        next_address = rows[index+1][0] if index+1 < len(rows) else None
        target = re.match(r'^([0-9a-f]+)\s+<', operands)
        target = int(target[1], 16) if target else None
        destinations = []
        if mnemonic.startswith('j'):
            if target in addresses:
                destinations.append(target)
            if mnemonic != 'jmp' and next_address is not None:
                destinations.append(next_address)
        elif mnemonic not in ('ret', 'retq', 'ud2') and next_address is not None:
            destinations.append(next_address)
        edges[address] = destinations
    sys.setrecursionlimit(max(10000, len(rows)*3))
    number, low, stack, active, result = {}, {}, [], set(), []
    def visit(v):
        number[v] = low[v] = len(number)
        stack.append(v); active.add(v)
        for w in edges[v]:
            if w not in number:
                visit(w); low[v] = min(low[v], low[w])
            elif w in active:
                low[v] = min(low[v], number[w])
        if low[v] == number[v]:
            group = []
            while True:
                w = stack.pop(); active.remove(w); group.append(w)
                if w == v:
                    break
            if len(group) > 1 or v in edges[v]:
                result.append(set(group))
    for v in edges:
        if v not in number:
            visit(v)
    return result


def stats(rows):
    loops = components(rows)
    largest = max(loops, key=len) if loops else set()
    stack = lambda r: bool(re.search(r'\[(?:r|e)(?:bp|sp)(?:[+\-\]])', r[2]))
    return dict(instructions=len(rows), stackReferences=sum(map(stack, rows)),
                largestLoopInstructions=len(largest),
                largestLoopStackReferences=sum(stack(r) for r in rows if r[0] in largest),
                largestLoopAddresses=[hex(a) for a in sorted(largest)])


def disassemble(binary):
    output = subprocess.check_output(['objdump', '-d', '--no-show-raw-insn', '-M', 'intel', binary], text=True)
    functions, current = {}, None
    for line in output.splitlines():
        header = re.match(r'^[0-9a-f]+ <(.+)>:$', line)
        if header:
            current = header[1]; functions[current] = []
        elif current:
            instruction = re.match(r'^\s*([0-9a-f]+):\s+(\S+)(?:\s+(.*))?$', line)
            if instruction:
                functions[current].append((int(instruction[1], 16), instruction[2], instruction[3] or ''))
    return {name: stats(rows) for name, rows in functions.items() if '_FID_' in name}


baseline, baseline_rows, baseline_sources = load(BASE)
result = dict(kind='phase195-static-machine-comparison', method=pin(Path(__file__).resolve()),
              scope='Static instructions and explicit frame-reference instructions; largest cyclic CFG component is not a dynamic path or time measurement. No target executed.',
              baselineReport=pin(BASE/'report.json'), variants={}, cases={})
baseline_functions = {case: disassemble(baseline_rows[case]['artifact']['file']) for case in CASES}
for label, directory in variants.items():
    report, rows, sources = load(directory)
    result['variants'][label] = dict(report=pin(directory/'report.json'))
    for case in CASES:
        for key in ('source', 'expectedFile'):
            assert sources[case][key] == baseline_sources[case][key], (case, key)
        functions = disassemble(rows[case]['artifact']['file'])
        entry = result['cases'].setdefault(case, dict(baseline=baseline_rows[case]['artifact'], variants={}, functions={}))
        entry['variants'][label] = rows[case]['artifact']
        for name, base in baseline_functions[case].items():
            assert name in functions, (case, name)
            row = entry['functions'].setdefault(name, dict(name=symbol_name(name), baseline=base))
            row[label] = functions[name]
print(json.dumps(result, indent=2))
