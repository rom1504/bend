#!/usr/bin/env python3
"""Inspect retained native products without executing either generated program.

Counts describe static instruction/call sites, never execution frequency,
allocations, elapsed-time benefit, or a correctness/admission proof.
"""
import argparse
from collections import Counter
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, require, verify, write_json

NAMES = ('app', 'kid', 'ks', 'p177s_loop', 'env_subst_term', 'k_apply_span')
FUNCTION = re.compile(r'^(?:export\s+)?function\s+\w+\s+\$([^\s(]+)\(')
ENCODED = re.compile(r'^(.*?)FID_((?:[0-9]+_)+)$')
CALL = re.compile(r'\bcall\s+([\$%])([^\s(]+)\(')
MACHINE_LINE = re.compile(r'^\s*[0-9a-f]+:\s+\S', re.I)


def decode(symbol):
    match = ENCODED.fullmatch(symbol)
    if not match:
        return None
    try:
        return ''.join(chr(int(n)) for n in match[2].rstrip('_').split('_'))
    except (ValueError, OverflowError):
        return None


def owner(symbol):
    name = decode(symbol)
    if name and name.startswith('$direct.'):
        name = name[len('$direct.'):]
    return name if name in NAMES else None


def private_worker(symbol):
    # p112w wrappers alone do not establish the actual direct body exists.
    return symbol.startswith('p113d_FID_')


def extract_ssa(path):
    found, current = {}, None
    with path.open() as stream:
        for number, line in enumerate(stream, 1):
            match = FUNCTION.match(line)
            if match:
                require(current is None, 'Unterminated selected SSA function')
                symbol = match[1]
                if owner(symbol):
                    require(symbol not in found, 'Repeated SSA symbol: ' + symbol)
                    current = dict(symbol=symbol, sourceLine=number, lines=[])
            if current is not None:
                current['lines'].append(line)
                if line.strip() == '}':
                    current['endLine'] = number
                    found[current['symbol']] = current
                    current = None
    require(current is None, 'Truncated selected SSA function')
    return found


def extract_assembly(path, symbols):
    found, current = {}, None
    with path.open() as stream:
        for number, line in enumerate(stream, 1):
            label = line.strip()
            if label.endswith(':') and label[:-1] in symbols:
                require(current is None, 'Unterminated selected assembly function')
                symbol = label[:-1]
                require(symbol not in found, 'Repeated assembly symbol: ' + symbol)
                current = dict(symbol=symbol, sourceLine=number, lines=[])
            if current is not None:
                current['lines'].append(line)
                if re.match(r'\s*\.size\s+' + re.escape(current['symbol']) + r'\s*,', line):
                    current['endLine'] = number
                    found[current['symbol']] = current
                    current = None
    require(current is None, 'Truncated selected assembly function')
    require(set(found) == set(symbols), 'Selected SSA/assembly symbol sets differ')
    return found


def categories(calls):
    return {
        'ctor2': sum(n for s, n in calls.items() if s == 'p125_rt_ctor2'),
        'ctor': sum(n for s, n in calls.items() if re.search(r'_rt_(?:special_)?ctor(?:[0-9]+)?$', s)),
        'take': sum(n for s, n in calls.items() if re.search(r'_rt_(?:special_)?take(?:[0-9]+)?$', s)),
        'keepOrDup': sum(n for s, n in calls.items() if re.search(r'(?:^|_)(?:keep|dup)(?:[0-9]+)?$', s)),
        'sink': sum(n for s, n in calls.items() if s.endswith('_rt_sink')),
        'apply': sum(n for s, n in calls.items() if s.endswith('_rt_apply')),
        'frame': sum(n for s, n in calls.items() if s.endswith('_rt_frame')),
        'jump': sum(n for s, n in calls.items() if s.endswith('_rt_jump')),
    }


def ssa_stats(row):
    direct, indirect, sites = Counter(), Counter(), []
    for offset, line in enumerate(row['lines']):
        for match in CALL.finditer(line):
            target = match[2]
            (direct if match[1] == '$' else indirect)[target] += 1
            sites.append(dict(line=row['sourceLine'] + offset, target=target,
                              decoded=decode(target), direct=match[1] == '$', text=line.strip()))
    return dict(lines=len(row['lines']), blocks=sum(line.startswith('@') for line in row['lines']),
                directCallSites=sum(direct.values()), indirectCallSites=sum(indirect.values()),
                calls=[dict(symbol=s, decoded=decode(s), sites=n) for s, n in sorted(direct.items())],
                indirectCalls=dict(sorted(indirect.items())), runtimeCallSites=categories(direct),
                callSites=sites)


def disassemble(tool, binary, symbol, destination):
    command = [str(tool), '-d', '--no-show-raw-insn', '--disassemble=' + symbol, str(binary)]
    env = {k: v for k, v in os.environ.items() if k not in ('LD_PRELOAD', 'LD_AUDIT')}
    env['LC_ALL'] = 'C'
    result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, text=True, timeout=30)
    require(result.returncode == 0 and not result.stderr,
            'objdump failed: ' + symbol + ': ' + result.stderr)
    # Keep the exact symbol body, excluding unrelated section headings.
    header = re.compile(r'^[0-9a-f]+ <' + re.escape(symbol) + r'>:$', re.I)
    lines, body, started = result.stdout.splitlines(keepends=True), [], False
    for line in lines:
        if header.match(line.rstrip('\n')):
            require(not started, 'Repeated objdump symbol: ' + symbol)
            started = True
        elif started and (line.startswith('Disassembly of section ') or
                          re.match(r'^[0-9a-f]+ <[^>]+>:', line, re.I)):
            break
        if started:
            body.append(line)
    require(started, 'Linked binary lacks selected symbol: ' + symbol)
    destination.write_text(''.join(body))
    instructions = [line for line in body if MACHINE_LINE.match(line)]
    return dict(command=command, artifact=pin(destination), instructions=len(instructions),
                callInstructions=sum(bool(re.search(r':\s+call\w*\s', line)) for line in instructions),
                branchInstructions=sum(bool(re.search(r':\s+j\w+\s', line)) for line in instructions))


def inspect_build(role, directory, out, objdump, inputs):
    report_path = directory / 'report.json'
    report_pin = pin(report_path)
    report = json.loads(report_path.read_text())
    require(report.get('kind') == 'bend-native-build' and report.get('complete') and
            report.get('changedInputs') == [], 'Successful unchanged native build required: ' + role)
    products = {}
    for key, name in (('retainedIR', 'program.ssa'), ('assembly', 'program.s'),
                      ('object', 'program.o'), ('binary', 'program')):
        require(key in report, 'Required retained product missing: ' + key)
        path = verify(report[key])
        require(path.resolve() == directory / name, 'Product is outside selected build: ' + key)
        products[key] = path
        inputs.append(report[key])
    inputs.append(report_pin)
    for key in ('runtime',):
        if isinstance(report.get(key), dict) and 'file' in report[key]:
            verify(report[key])
            inputs.append(report[key])
    source = report.get('request', {}).get('source')
    if isinstance(source, dict) and 'file' in source:
        verify(source)
        inputs.append(source)
    ssa = extract_ssa(products['retainedIR'])
    assembly = extract_assembly(products['assembly'], ssa)
    role_out = out / role
    role_out.mkdir()
    targets = {}
    for name in NAMES:
        selected = sorted(s for s in ssa if owner(s) == name)
        functions = []
        for index, symbol in enumerate(selected):
            row, asm = ssa[symbol], assembly[symbol]
            stem = '{}-{:02d}-{}'.format(name, index, symbol.split('FID_', 1)[0].rstrip('_'))
            ssa_path, asm_path = role_out / (stem + '.ssa'), role_out / (stem + '.s')
            ssa_path.write_text(''.join(row['lines']))
            asm_path.write_text(''.join(asm['lines']))
            functions.append(dict(symbol=symbol, decoded=decode(symbol), privateWorker=private_worker(symbol),
                ssa=dict(artifact=pin(ssa_path), sourceLine=row['sourceLine'], endLine=row['endLine'], **ssa_stats(row)),
                assembly=dict(artifact=pin(asm_path), sourceLine=asm['sourceLine'], endLine=asm['endLine'],
                              lines=len(asm['lines']), localLabels=sum(bool(re.match(r'\.L[^:]+:', l)) for l in asm['lines'])),
                machine=disassemble(objdump, products['binary'], symbol, role_out / (stem + '.objdump'))))
        targets[name] = dict(present=bool(selected), privateWorkerPresent=any(private_worker(s) for s in selected),
                             functions=functions)
    return dict(build=report_pin, source=source, runtime=report.get('runtime'), toolchain=report.get('toolchain'),
                products={k: report[k] for k in products}, targets=targets)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    baseline, candidate = args.baseline.resolve(strict=True), args.candidate.resolve(strict=True)
    require(baseline != candidate, 'Distinct builds required')
    tool = shutil.which('objdump')
    require(tool is not None, 'objdump required')
    objdump = Path(tool).resolve(strict=True)
    out = fresh_output(args.out, ROOT)
    inputs = [pin(__file__), pin(ROOT / 'selfhost/tools/build/common.py'), pin(objdump)]
    report = dict(kind='phase180-native-static-inspection', version=1, complete=False, targetsRun=False,
                  inputs=inputs, builds={},
                  scope='Exact retained SSA/assembly and linked-machine bodies for six named functions. '
                        'Static sites only, not runtime counters, allocation counts, performance, or correctness. '
                        'ctor includes ctor2; keepOrDup counts named runtime keep/dup calls. '
                        'Private worker means an exact p113d_FID definition; wrappers alone do not qualify. '
                        'Missing named workers may have other lowering or inlined code; absence is not a runtime result.')
    try:
        for role, directory in (('baseline', baseline), ('candidate', candidate)):
            report['builds'][role] = inspect_build(role, directory, out, objdump, inputs)
            write_json(out / 'report.json', report)
        a, b = report['builds']['baseline'], report['builds']['candidate']
        report['sameRuntime'] = a['runtime'] == b['runtime']
        report['sameToolchain'] = a['toolchain'] == b['toolchain']
        for item in inputs:
            verify(item)
        report['complete'] = True
    except Exception as error:
        report['error'] = repr(error)
        raise
    finally:
        write_json(out / 'report.json', report)
    print(json.dumps(dict(complete=True, report=pin(out / 'report.json'),
                         privateWorkers={role: {n: t['privateWorkerPresent'] for n, t in build['targets'].items()}
                                         for role, build in report['builds'].items()})))


if __name__ == '__main__':
    main()
