"""Read ELF64 symbol ranges and compare the native product to the checked host."""
from hashlib import sha256
from pathlib import Path
from struct import unpack_from
import argparse
import json

root=Path(__file__).resolve().parents[4]
marker='p198w_original_'

def sha(data):return sha256(data).hexdigest()
def symbols(path):
    data=path.read_bytes();assert data[:6]==b'\x7fELF\x02\x01' and unpack_from('<H',data,16)[0]==1
    start=unpack_from('<Q',data,40)[0];size,count,strings=unpack_from('<HHH',data,58)
    sections=[unpack_from('<IIQQQQIIQQ',data,start+i*size) for i in range(count)]
    section=lambda sh:data[sh[4]:sh[4]+sh[5]]
    name=lambda pool,i:pool[i:pool.index(b'\x00',i)].decode()
    sn=section(sections[strings]);syms=next(h for h in sections if name(sn,h[0])=='.symtab');names=section(sections[syms[6]])
    result={}
    for i in range(syms[5]//syms[9]):
        ident,info,_,which,pos,length=unpack_from('<IBBHQQ',data,syms[4]+i*syms[9]);label=name(names,ident)
        if info&15!=2 or not which or not (label.startswith('p114r_FID_') or label.startswith(marker)):continue
        target=sections[which];assert name(sn,target[0])=='.text' and pos+length<=target[5]
        result[label]=dict(bytes=length,sha256=sha(data[target[4]+pos:target[4]+pos+length]))
    return {n[len(marker):]:dict(wrapper=result[n[len(marker):]],fallback=v) for n,v in result.items() if n.startswith(marker)}

def main():
    p=argparse.ArgumentParser();p.add_argument('--native',type=Path,required=True);p.add_argument('--hosted',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();hosted=a.hosted.resolve();native=a.native.resolve()
    representative=symbols(hosted);assert len(representative)==1
    programs=[]
    for obj in sorted(native.glob('*/machine/program.o')):
        cert=json.loads((obj.parent/'report.json').read_text());assert cert['complete'] and cert['object']['sha256']==sha(obj.read_bytes());sym=symbols(obj)
        owner={k:{**v,'sameFastBodyAsHosted':k in representative and v['wrapper']==representative[k]['wrapper']} for k,v in sym.items()}
        programs.append(dict(program=obj.parents[1].name,object=cert['object']['sha256'],pairwise=owner))
    assert len(programs)==45
    a.out.write_text(json.dumps(dict(native=str(native.relative_to(root)),checkedHost=str(hosted.relative_to(root)),checkedHostObject=sha(hosted.read_bytes()),checkedHostBody=representative,programs=programs),indent=2)+'\n')
if __name__=='__main__':main()
