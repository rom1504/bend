"""Inspect selected Phase130 QBE/ELF read paths; no target execution/build."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
SSA=ROOT/'selfhost/build/phase111/p130-full-emit01/program.ssa'
ELF=ROOT/'selfhost/build/phase111/p130-native01-n1/program'
WANTED={'$direct.index_find','$direct.index_bucket','$direct.index_hash',
        '$p118borrow.read.index_hash','$direct.p111v_get',
        '$direct.index_find_absent','$direct.index_find_leaf','$direct.index_find_hash'}


def pin(p):
    p=p.resolve();h=hashlib.sha256();size=0
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1048576),b''):h.update(b);size+=len(b)
    return dict(file=str(p),bytes=size,sha256=h.hexdigest())


def decode(s):
    if '_FID_' not in s:return s
    p,c=s.split('_FID_',1)
    try:return p+':'+''.join(chr(int(x)) for x in c.split('_') if x)
    except ValueError:return s


def write(p,text):
    if p.exists() and p.read_text()!=text:raise ValueError('Changed frozen inspection '+str(p))
    if not p.exists():p.write_text(text)


def main():
    out=HERE/'read-inspection';out.mkdir(exist_ok=True)
    selected=json.loads((ROOT/'implementation/phase130/candidate.json').read_text())
    assert pin(ELF)==selected['n1']
    rows=[];current=None;lines=[]
    with SSA.open() as stream:
        for line in stream:
            if line.startswith(('function ','export function ')):
                m=re.search(r'\$(\w+)\(',line);sym=m[1] if m else '';name=decode(sym)
                current=(sym,name) if name.split(':',1)[-1] in WANTED else None;lines=[]
            if current:lines.append(line)
            if current and line.startswith('}'):
                sym,name=current;body=''.join(lines);slug=name.replace(':','-').replace('$','').replace('.','-')
                qbe=out/(slug+'.ssa');write(qbe,body)
                asm=subprocess.check_output(['objdump','-d','--disassemble='+sym,str(ELF)],text=True)
                assembly=out/(slug+'.asm');write(assembly,asm)
                calls=re.findall(r'call \$(\w+)\(',body)
                instructions=[l for l in asm.splitlines() if re.match(r'^\s*[0-9a-f]+:\s+(?:[0-9a-f]{2}\s+)+([a-zA-Z][\w.]*)\b',l)]
                rows.append(dict(name=name,symbol=sym,qbeLines=len(lines),machineInstructions=len(instructions),
                    calls={decode(c):calls.count(c) for c in sorted(set(calls))},qbe=pin(qbe),assembly=pin(assembly)))
                current=None
    report=dict(complete=True,targetsRun=False,inputs=[pin(Path(__file__)),pin(SSA),pin(ELF),pin(ROOT/'implementation/phase130/candidate.json')],
        rows=rows,scope='Static callsites/instructions, not dynamic frequencies. All selected definitions include generic/owning fallbacks. Runtime callsite counts cannot be treated as per-lookup costs.')
    write(out/'report.json',json.dumps(report,indent=2)+'\n')
    print(json.dumps([dict(name=r['name'],qbeLines=r['qbeLines'],machineInstructions=r['machineInstructions']) for r in rows]))


if __name__=='__main__':main()
