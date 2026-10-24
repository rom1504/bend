#!/usr/bin/env python3
"""Disassemble selected existing ELF functions; no compiler or program execution."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from run import pin, verify
from owners import decoded_symbol


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--qbe-audit', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'implementation/phase137/audit')
    audit = json.loads(a.qbe_audit.read_text())
    assert audit['complete']
    out.mkdir()
    inputs = [pin(__file__), pin(a.qbe_audit), pin('/usr/bin/objdump'), pin(ROOT / 'selfhost/tools/profiler/owners.py')]
    results = []
    for case in audit['cases']:
        retained = case['producer'] == 'retain'
        assert case['producer'] in ('retain', 'wide-v02')
        stem = 'p137-retain-query-builds01' if retained else 'p137-query-v02-builds01'
        build = ROOT / 'selfhost/build/phase111' / (stem + '-wide-' + case['name'])
        receipt = json.loads((build / 'report.json').read_text())
        assert receipt['complete'] and case['qbe'] in receipt['inputs']
        binary = build / 'program'
        inputs += [pin(build / 'report.json'), pin(binary), case['qbe']]
        label = case['producer'] + '-' + case['name']
        folder = out / label
        folder.mkdir()
        wanted = {'$direct.p137q_repeat'}
        if case['name'].startswith('queries'):
            wanted |= {'$direct.lookup', '$direct.nc_ctor_owned'}
        if retained:
            names = ['p137q_record_query'] if case['name'].startswith('record') else ['p137q_name_eq', 'p137q_key_eq', 'p137q_is_adt', 'p137q_is_ctr', 'da', 'db']
            wanted |= {prefix + name for name in names for prefix in ('$direct.', '$p118borrow.read.', '$p128borrow.owned.')}
            if case['name'].startswith('queries'):
                wanted |= {'$direct.p137q_is_cache', '$direct.dc'}
        rows = []
        selected = [f for f in case['privateFunctions'] if f['decoded'] in wanted]
        assert {f['decoded'] for f in selected} == wanted
        for f in selected:
            cmd = ['/usr/bin/objdump', '-d', '--no-show-raw-insn', '--disassemble=' + f['symbol'], str(binary)]
            done = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            assert done.returncode == 0 and not done.stderr
            assert '<' + f['symbol'] + '>:' in done.stdout
            asm = folder / (f['decoded'].replace('$', '') + '.asm')
            asm.write_text(done.stdout)
            instructions = []
            calls = []
            for line in done.stdout.splitlines():
                m = re.match(r'^\s*([0-9a-f]+):\s+([a-z][\w.]*)\s*(.*)$', line)
                if not m:
                    continue
                instructions.append(m)
                if m[2] in ('call', 'callq'):
                    target = re.search(r'<([^>]+)>', m[3])
                    assert target, line
                    symbol = target[1]
                    calls.append(dict(address=m[1], symbol=symbol, decoded=decoded_symbol(symbol) or symbol))
            assert instructions
            rows.append(dict(decoded=f['decoded'], symbol=f['symbol'], qbeLine=f['qbeLine'],
                             qbeBodySha256=f['bodySha256'], assembly=pin(asm), instructionLines=len(instructions),
                             instructionsIncludePadding=True, calls=calls, command=cmd))
        results.append(dict(role=label, qbe=case['qbe'], buildReport=pin(build / 'report.json'), binary=pin(binary), functions=rows))
    for item in inputs:
        verify(item)
    report = dict(kind='phase137-focused-linked-machine-inspection', complete=True, targetsRun=False,
                  inspectionOnlyTools=['objdump'], inputs=inputs, cases=results,
                  scope='Existing linked ELF only. Instruction counts include alignment padding; static call targets establish branches/paths but not dynamic frequency or speed. No whole ELF copied.')
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, functions=sum(len(c['functions']) for c in results), report=pin(out / 'report.json'))))


if __name__ == '__main__':
    main()
