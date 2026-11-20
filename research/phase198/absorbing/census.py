"""Offline comparison of current N1 zero-tested direct-worker backedges."""
from pathlib import Path
from collections import Counter
import re
import sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from regions import BUILD, disassembly, pretty, digest, read
import json

def opcode(s):
    fields=s.split()
    op=fields[0]
    if op in ('callq','jmpq','retq'):op=op[:-1]
    return op,fields[1] if len(fields)>1 else ''

def census(symbol,lines):
    if not symbol.startswith('p113d_'):return []
    addr={v:i for i,(v,_) in enumerate(lines)}
    ops=[opcode(t) for _,t in lines]
    hits=[]
    for h,(mn,a) in enumerate(ops[:-1]):
        # Match a local positive/nonzero branch from an unsigned-zero compare,
        # requiring an actual backward JMP to this very header.
        if mn!='cmp' or not a.startswith('$0x0,') or ops[h+1][0]!='jne':continue
        back=[i for i in range(h+2,len(ops)) if ops[i][0]=='jmp' and re.fullmatch('[0-9a-f]+',ops[i][1]) and int(ops[i][1],16)==lines[h][0]]
        if not back:continue
        positive=addr.get(int(ops[h+1][1],16))
        if positive is None:continue
        stop=next((i for i in range(positive,min(len(ops),positive+32)) if ops[i][0].startswith('j') or ops[i][0] in ('ret','call')),None)
        if stop is None:continue
        window=ops[positive:stop]
        if not any(op=='sub' and arg.startswith('$0x1,') for op,arg in window):continue
        if not (ops[stop][0].startswith('j') and ops[stop][0]!='jmp'):continue
        # A plausible selected arm either falls through from the guard or is
        # the branch target. Only MOVs and unconditional jumps may reach a
        # loop latch. This deliberately filters out arithmetic/ownership work.
        simple=[]
        for side,enter in [('fallthrough',stop+1),('target',addr.get(int(ops[stop][1],16)))]:
            if enter is None:continue
            pc=enter;visited=set();sequence=[]
            while 0<=pc<len(ops) and len(visited)<32 and pc not in visited and pc!=h:
                visited.add(pc);op,arg=ops[pc];sequence.append((op,arg))
                if op in ('mov','movabs'):pc+=1
                elif op=='jmp':
                    pc=addr.get(int(arg,16),-1)
                else:break
            if pc==h:simple.append(dict(side=side,length=len(sequence),literalMoves=sum(op.startswith('mov') and arg.startswith('$') for op,arg in sequence)))
        hits.append(dict(symbol=pretty(symbol),address=hex(lines[h][0]),guard=ops[stop][0],unconditionalTailMoves=simple))
    return hits

def main():
    docs=read(BUILD/'phase195/native45-01/report.json')
    result={}
    for case in docs['rows']:
        pin=case['artifact'];p=Path(pin['file'])
        assert digest(p)==pin['sha256']
        hits=[]
        for symbol,listing in disassembly(p).items():hits+=census(symbol,listing)
        result[case['id']]=dict(elf=pin['sha256'],headers=hits)
    (HERE/'evidence/machine-census.json').write_text(json.dumps(dict(method=digest(__file__),cases=result),indent=2)+'\n')
    events=Counter(h['symbol'] for r in result.values() for h in r['headers'] if h['unconditionalTailMoves'])
    print(len(result),'cases;',sum(len(v['headers']) for v in result.values()),'countdown headers;',sum(events.values()),'simple positive paths;',len(events),'distinct symbols')
    print(events.most_common(30))

if __name__=='__main__':main()
