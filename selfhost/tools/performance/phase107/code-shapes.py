#!/usr/bin/env python3
"""Read existing x86-64 objects with objdump/readelf; never build or run targets."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

CASES = ['ir-many', 'source-recurrence', 'ir-shared', 'ir-shared_borrow']
BACKENDS = ['c', 'cl', 'qbe']


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def inspect(tool, *args):
    return subprocess.run([tool, *map(str, args)], check=True, capture_output=True,
                          text=True, timeout=30, env={'LC_ALL': 'C', 'PATH': '/usr/bin:/bin'}).stdout


def logical(name):
    for prefix in ['bend_ir_', 'nx_']:
        if name.startswith(prefix):
            return name[len(prefix):]
    return name


def object_shape(path, objdump, readelf):
    before = pin(path)
    symtext = inspect(readelf, '--wide', '--syms', path)
    symbols = {}
    for line in symtext.splitlines():
        parts = line.split()
        if len(parts) >= 8 and parts[3] == 'FUNC' and parts[6] != 'UND':
            symbols[parts[7]] = dict(address=int(parts[1], 16), bytes=int(parts[2]))
    assert 'phase106_entry' in symbols, path
    text = inspect(objdump, '-drw', '--no-show-raw-insn', '-Mintel', path)
    assert 'file format elf64-x86-64' in text, path
    decoded = {name: [] for name in symbols}
    current = None
    for line in text.splitlines():
        label = re.match(r'^([0-9a-f]+) <([^>]+)>:$', line)
        if label:
            current = label[2] if label[2] in symbols else None
            continue
        match = re.match(r'^\s*([0-9a-f]+):\s+([a-z][a-z0-9]*)\s*(.*)$', line)
        if current and match:
            address = int(match[1], 16)
            if address < symbols[current]['address'] + symbols[current]['bytes']:
                decoded[current].append((address, match[2], match[3]))
    metrics, graph = {}, {}
    for name, instructions in decoded.items():
        counts = Counter()
        calls, backedges, external, internal = [], [], Counter(), set()
        reserved = 0
        registers = {}
        for address, op, raw in instructions:
            if op == 'nop' or ' nop ' in ' '+op+' '+raw+' ' or (op == 'xchg' and raw == 'ax,ax'):
                continue
            operand = raw.split('\t')[0].split('#')[0].strip()
            relocation = re.search(r'R_X86_64_\w+\s+([^\s]+)', raw)
            relocname = re.sub(r'[+-]0x[0-9a-f]+$', '', relocation[1]) if relocation else None
            counts['instructions'] += 1
            if op == 'push':
                counts['pushInstructions'] += 1
            if op == 'mov' and operand == 'rbp,rsp':
                counts['framePointerSetups'] += 1
            reserve = re.fullmatch(r'rsp,0x([0-9a-f]+)', operand)
            if op == 'sub' and reserve:
                reserved = max(reserved, int(reserve[1], 16))
            if '[' in operand and op not in ['lea', 'nop']:
                key = 'stackMemoryInstructions' if re.search(r'\[(?:rsp|rbp)\b', operand) else 'otherMemoryInstructions'
                counts[key] += 1
                first = operand.split(',')[0]
                if '[' in first and op not in ['cmp', 'test', 'call', 'jmp']:
                    counts['memoryWriteInstructions'] += 1
            target_match = re.search(r'^([0-9a-f]+) <([^>]+)>', operand)
            target = relocname
            if target is None and target_match:
                target = target_match[2].split('+')[0]
            if op == 'call':
                if target is None:
                    target = registers.get(operand, '<indirect:'+operand+'>')
                calls.append(dict(at=address, target=target))
                counts['callSites'] += 1
                if target in symbols:
                    internal.add(target)
                else:
                    external[target] += 1
                registers.clear()
            elif op.startswith('j'):
                if target in symbols and target != name:
                    internal.add(target)
                if target_match and target == name and int(target_match[1], 16) < address:
                    backedges.append(dict(at=address, to=int(target_match[1], 16)))
            # Resolve the adjacent GOT loads used by Cranelift's external calls.
            if op == 'mov' and ',' in operand and '[' not in operand.split(',')[0]:
                register = operand.split(',')[0]
                registers.pop(register, None)
                if relocname:
                    registers[register] = relocname
        graph[name] = internal
        metrics[name] = dict(symbol=name, logical=logical(name), **symbols[name],
            counts={key: counts[key] for key in ['instructions', 'callSites', 'pushInstructions',
                'framePointerSetups', 'stackMemoryInstructions', 'otherMemoryInstructions', 'memoryWriteInstructions']},
            largestExplicitStackReservation=reserved, calls=calls, backwardBranches=backedges,
            externalCallSites=dict(external))
    reached, todo = set(), ['phase106_entry']
    while todo:
        name = todo.pop()
        if name not in reached:
            reached.add(name)
            todo.extend(graph[name])
    total = Counter()
    externals = Counter()
    for name in reached:
        total.update(metrics[name]['counts'])
        externals.update(metrics[name]['externalCallSites'])
    focus = {'phase106_entry', 'main', 'observe', 'helper0', 'helper127',
             'f_119_97_108_107', 'f_98_101_110_99_104'}
    assert pin(path) == before, path
    return dict(object=before, allFunctionCount=len(symbols),
        allFunctionBytes=sum(row['bytes'] for row in symbols.values()),
        entryReachableFunctionCount=len(reached), entryReachableFunctionBytes=sum(symbols[n]['bytes'] for n in reached),
        entryReachableCounts=dict(total), entryReachableExternalCalls=dict(externals),
        entryReachableBackwardBranches=sum(len(metrics[n]['backwardBranches']) for n in reached),
        recursiveCallSymbols=sorted(n for n in reached if n in graph[n]),
        matchedSymbols=[dict(row, entryReachable=name in reached) for name, row in metrics.items() if logical(name) in focus],
        inspectionSha256=dict(objdump=hashlib.sha256(text.encode()).hexdigest(),
                              readelf=hashlib.sha256(symtext.encode()).hexdigest()))


def ir_shape(path):
    program = json.loads(Path(path).read_text())
    summary = []
    def visit(value, counts):
        if isinstance(value, dict):
            if 'kind' in value:
                counts[value['kind']] += 1
            for child in value.values():
                visit(child, counts)
        elif isinstance(value, list):
            for child in value:
                visit(child, counts)
    for function in program['functions']:
        if function['name'] in [program['entry'], 'observe', 'f_119_97_108_107']:
            counts = Counter()
            visit(function['body'], counts)
            summary.append(dict(name=function['name'], kinds=dict(counts), locals=len(function['locals'])))
    return dict(entry=program['entry'], functions=len(program['functions']), selectedFunctions=summary)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--measure', type=Path, required=True)
    p.add_argument('--artifacts', type=Path, required=True)
    p.add_argument('--previous-measure', type=Path)
    p.add_argument('--previous-artifacts', type=Path)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    assert bool(a.previous_measure) == bool(a.previous_artifacts)
    objdump, readelf = [shutil.which(name) for name in ['objdump', 'readelf']]
    assert objdump and readelf
    stages = [(a.measure.name, a.measure, a.artifacts)]
    if a.previous_measure:
        stages.insert(0, (a.previous_measure.name, a.previous_measure, a.previous_artifacts))
    rows, records = [], []
    for label, measurement, artifacts in stages:
        report_pin, source_pin = pin(measurement/'report.json'), pin(artifacts/'report.json')
        report, source = [json.loads(Path(row['file']).read_text()) for row in [report_pin, source_pin]]
        assert report['complete'] and source['complete']
        assert any(row['sha256'] == source_pin['sha256'] for row in report['inputs'])
        assert pin(source['api']['file'])['sha256'] == source['api']['sha256']
        records.append(dict(stage=label, measurement=report_pin, artifacts=source_pin,
            emitterApi=source['api'], method=source.get('method', 'not-recorded'), pipeline=source.get('pipeline', 'not-recorded'),
            declaredSourceInputs=source['inputs']))
        for case in CASES:
            for budget in [0, 4096]:
                stem = artifacts/(case+'-'+str(budget))
                sources = [pin(str(stem)+ext) for ext in ['.json', '.c', '.ssa']]
                shape = ir_shape(str(stem)+'.json')
                for backend in BACKENDS:
                    obj = measurement/(case+'-'+str(budget)+'-'+backend+'.o')
                    build = next(x for x in report['builds'] if (x['name'], x['budget'], x['backend']) == (case,budget,backend))
                    runtime = [x for x in report['runtimes'] if (x['name'],x['budget'],x['backend']) == (case,budget,backend)]
                    result = object_shape(obj, objdump, readelf)
                    assert result['object']['bytes'] == build['objectBytes']
                    rows.append(dict(stage=label, case=case, budget=budget, backend=backend,
                        sources=sources, ir=shape, build=build, recordedRuntimes=runtime, **result))
    result = dict(kind='phase107-read-only-code-shape-audit', complete=True,
        targetExecuted=False, producer=pin(__file__), stages=records,
        tools=[dict(**pin(t), version=inspect(t, '--version').splitlines()[0]) for t in [objdump,readelf]],
        definitions='Static x86-64 instructions within ELF FUNC sizes, excluding alignment nops. Entry reachability follows direct calls/cross-symbol jumps only. Call sites are not dynamic call counts; backward branches are syntactic, not measured iterations. Stack counts/reservations are not peak stack/RSS. Other-memory counts include argument/heap/GOT operands; no alias or allocator-elimination proof. Historical timing is copied, never rerun. Only the single public entry ABI is claimed.',
        rows=rows)
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(a.out), objects=len(rows), targetExecuted=False)))


if __name__ == '__main__':
    main()
