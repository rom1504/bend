"""Inspect frozen verifier QBE/machine code; never execute generated targets."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[5]
OWNERS = {'index_hash','index_find','index_bucket','p131i_insert',
          'p144vt_find','p144vt_bucket','p144vt_insert',
          'p144vn_old_once','p144vn_new_once','p144vn_old_walk','p144vn_new_walk'}
for prefix in ['p111v_', 'p144v_']:
    OWNERS.update(prefix+x for x in ['get','put','value','assign','decl','intersection','intersection_bucket','body','stmt'])


def pin(p):
    p = Path(p).resolve()
    b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def decode(symbol):
    if '_FID_' not in symbol:
        return symbol
    prefix, codes = symbol.split('_FID_', 1)
    try:
        return prefix+':'+''.join(chr(int(c)) for c in codes.split('_') if c)
    except ValueError:
        return symbol


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--plan', type=Path, required=True)
p.add_argument('--timing', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
plan = json.loads(a.plan.read_text())
timing = json.loads(a.timing.read_text())
assert plan['complete'] and timing['complete']
inputs = [pin(__file__), pin(a.plan), pin(a.timing)]
out.mkdir(parents=True)
report = dict(kind='phase144-native-verifier-static-inspection', complete=False, targetsRun=False,
    inputs=inputs, variants={}, functions=[],
    scope='Actual emitted QBE and disassembled machine code after ordinary output gates. Counts include cold/alternative paths. No dynamic allocation frequency, attribution or per-call cost inferred from static counts.')
for mode, variant in plan['variants'].items():
    emission = json.loads(Path(variant['emission']).read_text())
    build = json.loads(Path(variant['build']).read_text())
    assert emission['complete'] and build['complete'] and build['outputExact']
    assert pin(variant['qbe']) == emission['product']
    assert pin(variant['binary']) == build['binary']
    inputs += [pin(variant['emission']), pin(variant['build']), emission['product'], build['binary'], build['object']]
    text = Path(variant['qbe']).read_text()
    functions = {}
    for match in re.finditer(r'^(?:export )?function [^\n]*\$(\w+)\([^\n]*\) \{\n.*?^\}', text, re.M|re.S):
        functions[match[1]] = match[0]+'\n'
    selected = set()
    for symbol in functions:
        owner = decode(symbol).split(':',1)[-1].removeprefix('$direct.').removeprefix('$p118borrow.read.')
        if owner in OWNERS:
            selected.add(symbol)
    # Record local SCC callees needed to interpret forwarding wrappers.
    for symbol in list(selected):
        selected.update(c for c in re.findall(r'call \$(\w+)\(', functions[symbol])
            if c in functions and '$p126scc.' in decode(c))
    report['variants'][mode] = dict(qbeBytes=emission['product']['bytes'], objectBytes=build['object']['bytes'],
        binaryBytes=build['binary']['bytes'], functions=len(functions), selectedFunctions=len(selected))
    for number, symbol in enumerate(sorted(selected)):
        body = functions[symbol]
        assembly = subprocess.check_output(['objdump','-d','--disassemble='+symbol,variant['binary']],text=True)
        calls = collections.Counter(decode(c) for c in re.findall(r'call \$(\w+)\(',body))
        instructions = [l for l in assembly.splitlines() if re.match(r'^\s*[0-9a-f]+:\s+(?:[0-9a-f]{2}\s+)+[a-zA-Z][\w.]*\b',l)]
        qbe, machine = out/f'{mode}-{number:03}.ssa',out/f'{mode}-{number:03}.asm'
        qbe.write_text(body)
        machine.write_text(assembly)
        report['functions'].append(dict(mode=mode,symbol=symbol,name=decode(symbol),qbeLines=len(body.splitlines()),
            machineInstructions=len(instructions),calls=dict(calls),qbe=pin(qbe),assembly=pin(machine)))
for x in inputs:
    assert pin(x['file']) == x
report['complete'] = True
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(variants=report['variants'],rows=len(report['functions']))))
