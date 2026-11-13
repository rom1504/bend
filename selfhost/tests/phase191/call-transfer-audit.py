#!/usr/bin/env python3
"""Offline typed-emission and linked-machine audit; never executes a target."""
import hashlib
import json
import pathlib
import re
import shutil
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[3]
OUTPUT = ROOT / 'implementation/phase191/call-transfer-audit.json'
RAW = ROOT / 'implementation/phase191/call-transfer-disassembly'
VARIANTS = [('before', 'extra-dev-emission01', 'extra-dev-build01'),
            ('after', 'call-dev-emission01', 'call-dev-build01')]
HELPERS = ['$p118borrow.read.Map.bit.go', '$direct.Map.bit.go']
ABI = ['rdi', 'rsi', 'rdx', 'rcx', 'r8', 'r9']


def pin(path):
    path = pathlib.Path(path).resolve()
    data = path.read_bytes()
    return {'file': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def verify(identity):
    got = pin(identity['file'])
    assert all(got[k] == identity[k] for k in ['bytes', 'sha256']), identity['file']
    return pathlib.Path(identity['file'])


def decoded(symbol):
    suffix = symbol.split('FID_')[-1].strip('_').split('_')
    return ''.join(chr(int(x)) for x in suffix) if all(x.isdigit() for x in suffix) else symbol


def snapshots(lines):
    hits, symbol = [], ''
    for index, line in enumerate(lines):
        if line.startswith('.type '):
            symbol = line.split()[1].rstrip(',')
        match = re.fullmatch(r'  movq (\d+)\(%rsp\), %rdi', line)
        if not match:
            continue
        base = int(match[1])
        count = base // 8
        if base % 8 or not 1 <= count <= 512:
            continue
        stores = []
        for previous in reversed(lines[max(0, index - 4 * count):index]):
            if not previous.startswith('  ') or re.match(r'  (call|j)', previous):
                break
            store = re.fullmatch(r'  movq %r10, (\d+)\(%rsp\)', previous)
            if store:
                stores.append(int(store[1]))
            if len(stores) == count:
                break
        if stores[::-1] != [base + 8 * i for i in range(count)]:
            continue
        expected = []
        for i in range(count):
            source = f'{base + 8 * i}(%rsp)'
            if i < 6:
                expected.append(f'  movq {source}, %{ABI[i]}')
            else:
                expected += [f'  movq {source}, %r10', f'  movq %r10, {8 * (i - 6)}(%rsp)']
        end = index + len(expected)
        if lines[index:end] != expected:
            continue
        if end < len(lines) and lines[end] == '  xorl %eax, %eax':
            end += 1
        if end == len(lines) or not lines[end].startswith('  call '):
            continue
        hits.append({'line': index + 1, 'function': symbol, 'decodedFunction': decoded(symbol),
                     'arguments': count, 'snapshotRspReferences': 2 * count,
                     'target': lines[end].split()[1]})
    return hits


def machine(binary, role, helper, objdump):
    symbol = 'p113d_FID_' + '_'.join(str(ord(c)) for c in helper) + '_'
    command = [objdump, '-d', '--no-show-raw-insn', '--disassemble=' + symbol, str(binary)]
    text = subprocess.check_output(command, text=True, timeout=30)
    path = RAW / (role + '-' + ('borrow' if 'borrow' in helper else 'direct') + '.asm')
    path.write_text(text)
    instructions = []
    for line in text.splitlines():
        match = re.match(r'\s*([0-9a-f]+):\s+(\S+)\s*(.*)', line)
        if match:
            instructions.append({'address': '0x' + match[1], 'opcode': match[2], 'operands': match[3]})
    assert instructions, symbol
    calls = []
    for i, ins in enumerate(instructions):
        if ins['opcode'].startswith('call'):
            target = re.search(r'<([^>]+)>', ins['operands'])
            calls.append({'instruction': ins, 'decodedTarget': decoded(target[1]) if target else None,
                          'precedingInstructions': instructions[max(0, i - 20):i]})
    return {'helper': helper, 'symbol': symbol, 'command': command, 'raw': pin(path),
            'instructionCount': len(instructions),
            'explicitRspInstructions': sum('(%rsp)' in x['operands'] for x in instructions),
            'calls': calls}


def main():
    assert not OUTPUT.exists(), 'Fresh output required'
    RAW.mkdir(exist_ok=False)
    tool = str(pathlib.Path(shutil.which('objdump')).resolve())
    result = {'kind': 'phase191-call-transfer-static-audit', 'version': 1,
              'targetsExecuted': False, 'complete': False,
              'scope': 'Static call-snapshot template and explicit RSP-reference counts, not dynamic traffic, cache misses or runtime attribution.',
              'method': pin(__file__), 'objdump': pin(tool), 'variants': {}, 'comparisons': []}
    for role, emission, build in VARIANTS:
        report_path = ROOT / 'selfhost/build/phase191' / emission / 'report.json'
        build_path = ROOT / 'selfhost/build/phase191' / build / 'programs.manifest.json'
        report = json.loads(report_path.read_text())
        manifest = json.loads(build_path.read_text())
        assert report['complete'] is True and len(report['rows']) == 8
        rows = []
        for row in report['rows']:
            assert row['complete'] and row['sameTypedSequence'] and row['verified']
            source = verify(row['source'])
            assembly = verify(row['assembly'])
            product = verify(row['product'])
            lines = assembly.read_text().splitlines()
            sites = snapshots(lines)
            rows.append({'id': row['id'], 'source': row['source'], 'assembly': row['assembly'],
                         'object': row['product'], 'snapshotSites': len(sites),
                         'snapshotRspReferences': sum(x['snapshotRspReferences'] for x in sites),
                         'explicitRspInstructions': sum('(%rsp)' in line and line.startswith('  ') for line in lines),
                         'staticCalls': sum(line.startswith('  call ') for line in lines), 'sites': sites})
        case = next(c for c in manifest['cases'] if c['id'] == 'coverage-map-churn-32')
        assert len(case['products']) == 1
        product = next(iter(case['products'].values()))
        binary = verify(product['artifact'])
        verify(product['generatedSource'])
        map_row = next(r for r in rows if r['id'] == case['id'])
        assert product['generatedSource'] == map_row['object']
        assert case['source']['sha256'] == map_row['source']['sha256']
        result['variants'][role] = {'emissionReport': pin(report_path), 'buildManifest': pin(build_path),
                                    'rows': rows, 'mapBinary': product['artifact'],
                                    'helpers': [machine(binary, role, h, tool) for h in HELPERS]}
    before = result['variants']['before']['rows']
    after = result['variants']['after']['rows']
    for old in before:
        new = next(r for r in after if r['id'] == old['id'])
        assert old['source'] == new['source']
        result['comparisons'].append({'id': old['id'], 'sameSource': True,
            'snapshotSites': [old['snapshotSites'], new['snapshotSites']],
            'snapshotRspReferences': [old['snapshotRspReferences'], new['snapshotRspReferences']],
            'explicitRspInstructions': [old['explicitRspInstructions'], new['explicitRspInstructions']],
            'staticCalls': [old['staticCalls'], new['staticCalls']]})
    for old, new in zip(result['variants']['before']['helpers'], result['variants']['after']['helpers']):
        assert [x['decodedTarget'] for x in old['calls']] == [x['decodedTarget'] for x in new['calls']]
    result['complete'] = True
    OUTPUT.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result['comparisons'], indent=2))
    for role in ['before', 'after']:
        for h in result['variants'][role]['helpers']:
            print(role, h['helper'], h['instructionCount'], h['explicitRspInstructions'], [c['decodedTarget'] for c in h['calls']])


if __name__ == '__main__':
    main()
