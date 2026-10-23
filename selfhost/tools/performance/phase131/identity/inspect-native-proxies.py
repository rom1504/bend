"""Inspect frozen native proxy QBE and ELF; no target execution or builds."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

OWNERS={'index_find','index_find_absent','index_find_leaf','index_find_hash',
        'index_bucket','lookup','lookup_cached','lookup_named',
        'index_set','index_insert','index_insert_legacy','p131i_insert','p131i_branch'}


def pin(p):
    p=Path(p).resolve();h=hashlib.sha256();size=0
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1048576),b''):h.update(b);size+=len(b)
    return dict(file=str(p),bytes=size,sha256=h.hexdigest())


def verify(p):
    assert pin(p['file'])==p
    return Path(p['file'])


def decode(s):
    if '_FID_' not in s:return s
    p,c=s.split('_FID_',1)
    try:return p+':'+''.join(chr(int(x)) for x in c.split('_') if x)
    except ValueError:return s


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--config',type=Path,required=True);ap.add_argument('--out',type=Path,required=True)
    a=ap.parse_args();out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
    config=json.loads(a.config.read_text());assert config['complete']
    inputs=[pin(__file__),pin(a.config)];rows=[]
    for case in config['cases']:
        emission=Path(case['emission']);build=Path(case['build'])
        er=json.loads(emission.read_text());br=json.loads(build.read_text())
        assert er['complete'] and br['complete'] and br['outputExact']
        qbe,elf=verify(er['product']),verify(br['binary'])
        inputs += [pin(emission),pin(build),pin(qbe),pin(elf),case['source']]
        current=None;lines=[]
        for line in qbe.open():
            if line.startswith(('function ','export function ')):
                m=re.search(r'\$(\w+)\(',line);symbol=m[1] if m else '';name=decode(symbol)
                owner=name.split(':',1)[-1].removeprefix('$direct.')
                current=(symbol,name) if owner in OWNERS else None;lines=[]
            if current:lines.append(line)
            if current and line.startswith('}'):
                symbol,name=current;body=''.join(lines)
                slug=case['variant']+'-'+name.replace(':','-').replace('$','').replace('.','-')
                qp=out/(slug+'.ssa');qp.write_text(body)
                asm=subprocess.check_output(['objdump','-d','--disassemble='+symbol,str(elf)],text=True)
                mp=out/(slug+'.asm');mp.write_text(asm)
                instructions=[l for l in asm.splitlines() if re.match(r'^\s*[0-9a-f]+:\s+(?:[0-9a-f]{2}\s+)+([a-zA-Z][\w.]*)\b',l)]
                calls=re.findall(r'call \$(\w+)\(',body)
                rows.append(dict(variant=case['variant'],name=name,symbol=symbol,qbeLines=len(lines),
                    machineInstructions=len(instructions),calls={decode(c):calls.count(c) for c in sorted(set(calls))},
                    qbe=pin(qp),assembly=pin(mp)))
                current=None
    for p in inputs:verify(p)
    report=dict(complete=True,targetsRun=False,inputs=inputs,rows=rows,
        scope='Actual native proxy functions after ordinary output gates. Static callsites and instruction counts include cold paths and must not be read as dynamic per-operation costs.')
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps([dict(variant=r['variant'],name=r['name'],qbeLines=r['qbeLines'],machineInstructions=r['machineInstructions']) for r in rows]))


if __name__=='__main__':main()
