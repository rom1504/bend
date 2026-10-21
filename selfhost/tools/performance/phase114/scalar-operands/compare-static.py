#!/usr/bin/env python3
"""Read existing Phase114 products and receipts; never execute a target."""
import argparse
import collections
import hashlib
import json
import math
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
WORKER = '$direct.isect5'
SYMBOL = 'p113d_FID_' + ''.join(str(ord(c)) + '_' for c in WORKER)


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(row):
    actual = pin(row['file'])
    if actual != row:
        raise ValueError('changed input: ' + row['file'])


def read_json(path):
    return json.loads(Path(path).read_text())


def extract(text, start, end):
    matches = list(re.finditer(start, text, re.M))
    if len(matches) != 1:
        raise ValueError('expected one named function')
    begin = matches[0].start()
    stop = re.search(end, text[begin:], re.M)
    if not stop:
        raise ValueError('function terminator absent')
    body = text[begin:begin+stop.end()]
    return dict(line=text[:begin].count('\n')+1, bytes=len(body.encode()),
                sha256=hashlib.sha256(body.encode()).hexdigest(), text=body)


def inspect(prefix, role, measured_records):
    emit = ROOT / 'selfhost/build/phase111' / (prefix+'-variation-ray-active-256-2240-emit')
    build = ROOT / 'selfhost/build/phase111' / (prefix+'-variation-ray-active-256-2240-build')
    er = read_json(emit/'report.json')
    br = read_json(build/'report.json')
    if not er.get('complete') or not br.get('complete'):
        raise ValueError('incomplete production receipts')
    verify(er['product'])
    binary_rows = [r['binary'] for r in measured_records
                   if r['role'] == role and r['case'] == 'variation-ray-active-256-2240']
    if len(binary_rows) != 3 or any(x != pin(build/'program') for x in binary_rows):
        raise ValueError('static product not the measured binary')
    for row in binary_rows:
        verify(row)
    qbe = extract((emit/'program.ssa').read_text(),
                  r'^function l \$'+re.escape(SYMBOL)+r'\(', r'^\}')
    asm = extract((build/'program.s').read_text(),
                  r'^'+re.escape(SYMBOL)+r':$', r'^\.size '+re.escape(SYMBOL)+r',.*$')
    instructions = [line.strip() for line in asm['text'].splitlines()
                    if re.match(r'^\t[a-z][a-z0-9]*\s*', line)]
    counts = collections.Counter(line.split()[0] for line in instructions)
    first_branch = next(i for i, line in enumerate(instructions)
                        if re.match(r'^j(?!mp\b)[a-z]+\b', line))
    stack_stores = lambda seq: [s for s in seq
                               if re.match(r'^movq\s+[^,]+, -\d+\(%rbp\)$', s)]
    crosses = []
    for line in instructions:
        match = re.fullmatch(r'mov[qd]\s+(%\w+), (%\w+)', line)
        if match and (match[1].startswith('%xmm') != match[2].startswith('%xmm')):
            crosses.append(line)
    qbe_first_branch = qbe['text'].split('\njnz ', 1)[0]
    return dict(role=role, compilerInputs=[x for x in er['inputs'] if x['file'].endswith('api.mjs')],
                sourceInputs=[x for x in er['inputs'] if x['file'].endswith('.bend')],
                emitReceipt=pin(emit/'report.json'), buildReceipt=pin(build/'report.json'),
                qbe=pin(emit/'program.ssa'), assembly=pin(build/'program.s'), binary=binary_rows[0],
                workerQbe=qbe, workerAssembly=asm,
                counts=dict(machineInstructions=len(instructions),
                            qwordFrameStoresBeforeFirstConditional=len(stack_stores(instructions[:first_branch])),
                            qwordFrameStoresTotal=len(stack_stores(instructions)),
                            gprXmmMoves=len(crosses),
                            scalarArithmetic={op:counts[op] for op in ['addss','subss','mulss','divss','sqrtss']},
                            scalarComparisons=counts['ucomiss']+counts['comiss'],
                            stackReservationBytes=int(re.search(r'\bsubq \$(\d+), %rsp',asm['text'])[1]),
                            qbeStorelTotal=len(re.findall(r'^storel ',qbe['text'],re.M)),
                            qbeStorelBeforeFirstConditional=len(re.findall(r'^storel ',qbe_first_branch,re.M)),
                            qbeLoadlTotal=len(re.findall(r' =l loadl ',qbe['text'])),
                            calls=[line.split(None,1)[1] for line in instructions if line.startswith('callq ')]),
                gprXmmInstructions=crosses)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args()
    if args.out.exists():
        raise ValueError('fresh output required')
    measurement_file=ROOT/'selfhost/build/phase112/p114-scalar-operands-screen01-measure/report.json'
    measured=read_json(measurement_file)
    if not measured.get('complete') or not measured.get('fullCorpusOutputQualified'):
        raise ValueError('incomplete matched measurement')
    records=measured['records']
    if len(records)!=24 or not all(r['correct'] and r['qualified'] for r in records):
        raise ValueError('expected 24 complete qualified observations')
    for row in records:
        for field in ['binary','stdout','stderr']:
            verify(row[field])
    parent=inspect('p114-final-screen01','p114-final-hosted45',records)
    candidate=inspect('p114-scalar-operands-screen01','p114-scalar-operands-screen01',records)
    if parent['sourceInputs']!=candidate['sourceInputs']:
        raise ValueError('source mismatch')
    per_program=[]
    for name,item in measured['perProgram'].items():
        old=item['mediansMs'][parent['role']]
        new=item['mediansMs'][candidate['role']]
        per_program.append(dict(name=name,parentMs=old,candidateMs=new,
                                candidateOverParent=new/old,runtimeReduction=1-new/old,
                                samplesMs=item['samplesMs']))
    result=dict(kind='phase114-scalar-operands-static-comparison',complete=True,targetsExecuted=False,
                worker=WORKER,symbol=SYMBOL,method=pin(__file__),measurement=pin(measurement_file),
                measurementWallSeconds=measured['wallSeconds'],observations=len(records),
                cpuAffinity=measured['cpuAffinity'],perProgram=per_program,
                subsetCandidateOverParent=math.prod(x['candidateOverParent'] for x in per_program)**(1/len(per_program)),
                parent=parent,candidate=candidate,
                countDefinitions='Exact named function. Instruction lines begin with a tab and mnemonic; GPR/XMM moves are movq/movd with exactly one XMM register operand. Frame stores are movq to negative rbp offsets. Prefix ends at first conditional jump. QBE prefix ends at first jnz. These are static counts, not dynamic samples or cost shares.',
                scope='Same actual measured binaries and unchanged ray source. Twenty-four observations cover two programs/four roles/three rounds; the optional candidate has six observations. This read-only comparison makes no broad performance or default-promotion claim.')
    args.out.parent.mkdir(parents=True,exist_ok=True)
    args.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(parent=parent['counts'],candidate=candidate['counts'],subsetCandidateOverParent=result['subsetCandidateOverParent'])))


if __name__=='__main__':
    main()
