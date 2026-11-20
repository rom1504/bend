#!/usr/bin/env python3
"""Freeze six new current-ray assembly hypotheses; metadata only."""
import hashlib
import json
from pathlib import Path
import re
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'research/phase196/screen'))
from regions import disassembly, canonical_op

CASE = 'variation-ray-active-64-2440'
SYMBOL = 'p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_'


def read(p): return json.loads(Path(p).read_text())
def pin(p):
    p = Path(p); b = p.read_bytes()
    return dict(file=str(p.resolve()), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def verify(row):
    actual = pin(row['file'])
    assert all(actual[k] == row[k] for k in ('bytes', 'sha256'))
    return Path(row['file'])


def main():
    path = HERE/'frozen.json'
    assert not path.exists()
    emitted_path = ROOT/'selfhost/build/phase195/prepared-combined01/combined/report.json'
    native_path = ROOT/'selfhost/build/phase195/native45-01/report.json'
    emitted = next(r for r in read(emitted_path)['rows'] if r['id'] == CASE)
    native = next(r for r in read(native_path)['rows'] if r['id'] == CASE)
    assert emitted['product']['sha256'] == native['object']['sha256']
    source, binary = verify(emitted['assembly']), verify(native['artifact'])
    verify(native['object']); verify(emitted['product'])
    lines = source.read_text().splitlines()
    assert not any('%xmm8' in line or '%ymm' in line for line in lines)
    records = [(n, line.strip()) for n, line in enumerate(lines)
               if lines.index(SYMBOL+':') < n < lines.index('.size '+SYMBOL+', .-'+SYMBOL) and line.startswith('  ')]
    machine = disassembly(binary)[SYMBOL]
    assert len(machine) >= len(records)
    assert all(canonical_op(a) == canonical_op(b) for (_, a), (_, b) in zip(records, machine))
    addresses = {n:addr for (n,_),(addr,_) in zip(records,machine)}
    contexts = {line:[s.strip() for s in lines[line-1:end-1]] for line,end in
                [(5120,5194),(5425,5499),(5243,5284),(5548,5589)]}
    assert [len(contexts[n]) for n in contexts] == [74,74,41,41]
    profiles = sorted((ROOT/'selfhost/build/phase195/profile-priority02').glob('*sample-*-'+CASE+'-candidate-candidate/analysis.json'))
    assert len(profiles)==2
    numerator=denominator=0
    historical=[]
    for p in profiles:
        a=read(p); old=verify(a['identities']['binary']); period=a['header']['period_us']
        for pc in a['pcs']:
            weight=pc['samples']*period; denominator += weight
            if pc.get('symbol')==SYMBOL: numerator += weight
        historical.append(dict(analysis=pin(p),binary=pin(old)))
    def patch(line, after):
        before=contexts[line]
        assert before != after
        return dict(line=line,before=before,after=after,address=hex(addresses[line-1]),
                    addresses=[hex(addresses[n]) for n in range(line-1,line-1+len(before))])
    rows=[]
    def add(name,sites,fn,legality,expectation,scope):
        patches=[patch(line,fn(contexts[line].copy())) for line in sites]
        rows.append(dict(name=name,case=CASE,rawSymbol=SYMBOL,patches=patches,
                         modelPatch=0,legality=legality,expectedEffect=expectation,scope=scope,
                         historicalOwnerHotness=numerator/denominator,
                         hotnessKind='Historical Phase194 nearest-owner proxy; NOT current or block weight'))
    def vex(b):
        result=[];i=0;fusions=0
        while i<len(b):
            move=re.fullmatch(r'movaps (%xmm\d+), (%xmm\d+)',b[i])
            op=re.fullmatch(r'(addss|subss|mulss|divss) (%xmm\d+), (%xmm\d+)',b[i+1]) if i+1<len(b) else None
            if move and op and move[2]==op[3]:
                result.append('v'+op[1]+' '+op[2]+', '+move[1]+', '+move[2]);i+=2;fusions+=1
            else: result.append(b[i]);i+=1
        assert fusions==13, fusions
        return result
    add('ray-vex-threeoperand',[5120,5425],vex,
        'Each VEX scalar operation has the original arithmetic operand order and inherits the same upper128 bits from the original MOVAPS source. Upper YMM bits become zero; the complete generated assembly has no YMM uses. Requires observed AVX+OSXSAVE support and dead upper lanes. No reassociation.',
        'Fusing necessary two-address copies may reduce backend work; mixed AVX/SSE transition costs may erase benefit.',
        'Host-specific generated-code diagnostic, not portable compiler equivalence; ISA fallback required.')
    def ordered(b):
        n=b.index('ucomiss %xmm1, %xmm0')
        assert b[n:n+5]==['ucomiss %xmm1, %xmm0','setb %r10b','setnp %r11b','andb %r11b, %r10b','movzbl %r10b, %r10d']
        b[n:n+5]=['ucomiss %xmm0, %xmm1','seta %r10b','setnp %r11b','movzbl %r10b, %r10d']
        return b
    add('ray-ordered-compare',[5120,5425,5243,5548],ordered,
        'Ordered a<b equals ordered b>a, including signed-zero equality and unordered NaNs. SETA rejects unordered because CF/ZF are set. SETNP is retained to preserve r11b. The following CMP and final TEST overwrite flags before control use. UCOMISS invalid-exception conditions are symmetric.',
        'Remove the Boolean AND dependency while retaining result stores and subsequent normalization.',
        'Exact local low128/register/flag-live equivalence, including unordered outcomes.')
    def boolean(b):
        n=b.index('cmpq $1, %r10')
        assert b[n:n+3]==['cmpq $1, %r10','sete %r10b','movzbl %r10b, %r10d']
        assert b[n-2]=='movzbl %r10b, %r10d' and b[-1]=='testl %r10d, %r10d'
        del b[n:n+3]
        return b
    add('ray-boolean-chain',[5120,5425,5243,5548],boolean,
        'SETB/SETNP/AND/MOVZX establishes full r10 in {0,1}; comparing this Boolean to1 is identity. Both original stores remain. Final TEST overwrites flags before the original JZ.',
        'Remove three serial integer operations following the floating predicate; amount may be small relative to FP latency.',
        'Exact local Boolean identity; no integer-minimum or decrement changes.')
    def constants(b):
        assert b[11]=='movabsq $1, %r10' and b[19]=='movabsq $1000, %r10'
        assert b[26:28]==['movaps %xmm3, %xmm4','divss %xmm2, %xmm4']
        b[11:26]=['movl $1065353216, %r10d','movd %r10d, %xmm3',
                   'movl $1148846080, %r10d','movd %r10d, %xmm0','movaps %xmm0, %xmm2']
        return b
    add('ray-exact-threshold-inputs',[5243,5548],constants,
        '1 and1000 are exactly representable binary32 under every rounding mode. Replace only integer conversions with their exact bit patterns; final r10/xmm0/xmm2/xmm3 and zero upper128 lanes match. DIVSS remains, preserving rounding, inexact and exception behavior of1/1000.',
        'Remove exact conversion chains before a long-latency DIVSS; threshold arithmetic, not the previously tested zero conversion.',
        'Exact input conversion; no reciprocal constant folding or fast math.')
    def schedule(b):
        radius=b[45].split(' ',1)[1].split(',')[0]
        assert b[45:48]==[f'movd {radius}, %xmm1',f'movd {radius}, %xmm3','mulss %xmm1, %xmm3']
        b[45:48]=[f'movd {radius}, %xmm1','movaps %xmm8, %xmm3']
        return [f'movd {radius}, %xmm8','mulss %xmm8, %xmm8']+b
    add('ray-early-radius-square',[5120,5425],schedule,
        'Move the independent radius square earlier using dead xmm8; original xmm1 and xmm3 values are restored at their use point. No operand association changes. Requires masked FP exceptions and ordinary input scope; possible unmasked trap ordering is NOT generally equivalent. Extra memory read is the same valid immutable private slot.',
        'Overlap radius multiply with dot/distance computation despite one extra instruction; may rank below count-only edits.',
        'Speculative schedule diagnostic only under masked exceptions; not general equivalence.')
    def keep(b):
        assert b[52]=='movd %xmm0, %r10d'
        slot=b[53].split(', ')[1]
        assert b[61]==f'movd {slot}, %xmm0'
        b[61]='movaps %xmm8, %xmm0'
        b.insert(52,'movaps %xmm0, %xmm8')
        return b
    add('ray-discriminant-register',[5120,5425],keep,
        'Keep discriminant in dead xmm8 across its retained frame store and zero-constant sequence, replacing only the reload. All upper128 lanes of this arithmetic chain are zero from MOVD origins, so MOVAPS equals the old zero-extending MOVD. No call, unknown alias or write to xmm8 intervenes.',
        'Avoid one store/reload dependency with an added copy; MCA lacks store-forwarding realism and may misrank it.',
        'Exact local full128 equivalence from zero-upper provenance; original memory side effect retained.')
    truth=[]
    for relation,cf,zf,pf,newcf,newzf in [('lt',1,0,0,0,0),('gt',0,0,0,1,0),('eq',0,1,0,0,1),('unordered',1,1,1,1,1)]:
        before=cf and not pf;after=not newcf and not newzf;assert before==after
        truth.append(dict(relation=relation,before=bool(before),after=bool(after)))
    output=dict(kind='phase197-discovery-a-frozen-v1',createdUtc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),
        targetsRun=False,modelsRun=False,source=emitted['assembly'],object=native['object'],binary=native['artifact'],
        inputs=[pin(emitted_path),pin(native_path),pin(__file__),pin(ROOT/'research/phase196/screen/regions.py')],
        historicalProfiles=historical,historicalOwnerWeight=numerator/denominator,candidates=rows,
        orderedCompareTruthTable=truth,
        exclusion='No Phase196 minimum, decrement, zero-conversion, memory-operand folding or redundant-copy edit is repeated.',
        benchmarkPlan='All six isolated alternatives, baseline and actual N1; project and default assembler layouts; original and3 independent alternate C outputs.8 rotated rounds per layout at>=100ms; all candidates retained, including lowest model rank. No target execution before root lane handoff.')
    path.write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(dict(candidates=[r['name'] for r in rows],historicalOwnerWeight=numerator/denominator,currentBlockWeight=None)))


if __name__=='__main__': main()
