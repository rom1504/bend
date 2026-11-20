"""Offline structural census; recognize a narrow family of frozen machine witnesses."""
from pathlib import Path
import re
from projection import HERE, ROOT, BUILD, digest, read, save
from regions import disassembly, pretty


def canon(ins):
    fields=ins.split()
    op=fields[0]
    if op in ['jmpq','retq','callq']:
        op=op[:-1]
    return op, fields[1] if len(fields)>1 else ''


def witnesses(listing):
    found=[]
    for sym,records in listing.items():
        if not sym.startswith('p113d_'):
            continue
        addrs={addr:i for i,(addr,_) in enumerate(records)}
        ops=[canon(s) for _,s in records]
        names=[n for n,_ in ops]
        for i in range(len(records)-7):
            if names[i:i+7]!=['shr','and','movabs','cmp','jne','movabs','jmp']:
                continue
            sh,mask,tag=[re.fullmatch(r'\$(0x[0-9a-f]+),(%\w+)',ops[j][1]) for j in (i,i+1,i+2)]
            pick=re.fullmatch(r'\$(0x[0-9a-f]+),(%\w+)',ops[i+5][1])
            if not all((sh,mask,tag,pick)) or mask[2]!=sh[2] or ops[i+3][1]!=tag[2]+','+sh[2]:
                continue
            if int(tag[1],16)!=(int(pick[1],16)>>int(sh[1],16))&int(mask[1],16):
                continue
            join=addrs.get(int(ops[i+6][1],16))
            if join is None:continue
            end=join
            while end<len(names) and end-join<12 and names[end]=='mov':
                end+=1
            if end==len(names) or names[end]!='jmp':
                continue
            loop=addrs.get(int(ops[end][1],16))
            if loop is None or not loop<i or not (ops[loop][0]=='cmp' and ops[loop][1].startswith('$0x0,') and names[loop+1]=='jne'):
                continue
            entry=addrs.get(int(ops[loop+1][1],16))
            if entry is None or not 0<i-entry<=12 or not any(n=='sub' and a.startswith('$0x1,') for n,a in ops[entry:i]):
                continue
            found.append(dict(symbol=pretty(sym),guard=hex(records[i][0]),tag=tag[1],nextConstant=pick[1],tailCopies=end-join))
    return found


if __name__=='__main__':
    cases={}
    for r in read(BUILD/'phase195/native45-01/report.json')['rows']:
        path=Path(r['artifact']['file'])
        assert digest(path)==r['artifact']['sha256']
        cases[r['id']]=dict(elf=r['artifact']['sha256'],hits=witnesses(disassembly(path)))
    save(HERE/'census.json',dict(complete=True,method=digest(__file__),cases=cases))
