"""Read constructor rows and owning code immediates from a native x86 object, without running it."""
import argparse
from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path
import json,re,struct,subprocess

@dataclass
class Section:
    name:str
    kind:int
    at:int
    size:int
    link:int
    info:int
    stride:int


def cstring(buf,off):
    return buf[off:buf.index(b'\0',off)].decode()

def analyze(path,tags):
    raw=path.read_bytes();assert raw[:6]==b'\x7fELF\x02\x01'
    start=struct.unpack_from('<Q',raw,40)[0];stride,nb,shstr=struct.unpack_from('<HHH',raw,58)
    sh=[struct.unpack_from('<IIQQQQIIQQ',raw,start+i*stride) for i in range(nb)]
    labels=raw[sh[shstr][4]:sh[shstr][4]+sh[shstr][5]]
    sections=[Section(cstring(labels,s[0]),s[1],s[4],s[5],s[6],s[7],s[9]) for s in sh]
    table=next(s for s in sections if s.kind==2)
    strings=sections[table.link];ss=raw[strings.at:strings.at+strings.size]
    symbols=[struct.unpack_from('<IBBHQQ',raw,at) for at in range(table.at,table.at+table.size,table.stride)]
    sym={cstring(ss,s[0]):s for s in symbols if s[0]}
    def get(s):return sections[s[3]].at+s[4]
    names,arity,hot=[sym[n] for n in ['p111_cid_names','p111_cid_arity','p111_cid_hot']]
    reloc=next(s for s in sections if s.kind==4 and s.info==names[3])
    n=struct.unpack_from('<Q',raw,get(sym['p111_program'])+24)[0]
    row={}
    for addr in range(reloc.at,reloc.at+reloc.size,reloc.stride):
        where,info,add=struct.unpack_from('<QQq',raw,addr)
        if names[4]<=where<names[4]+n*8:
            assert (where-names[4])%8==0 and (info&0xffffffff)==1
            ix=(where-names[4])//8;name=cstring(raw,get(symbols[info>>32])+add)
            if name in tags:row[name]={'cid':ix,'arity':raw[get(arity)+ix],'hot':raw[get(hot)+ix]}
    listing=subprocess.check_output(['objdump','-dr',path],text=True)
    sites={};func=None
    for line in listing.splitlines():
        match=re.match(r'^[\da-f]+ <([^>]+)>:$',line)
        if match:
            name=match[1];func=None
            m=re.fullmatch(r'(p113d|p111)_FID_((?:\d+_)+)',name)
            if m:
                text=bytes(int(s) for s in m[2][:-1].split('_')).decode()
                func=m[1]+':'+text
            continue
        if func is None:continue
        for v in re.findall(r'\$0x([\da-f]+)\b',line):
            word=int(v,16)
            for name,meta in row.items():
                if word==meta['cid'] or (word>>56 in (1,2) and (word>>40)&0xffff==meta['cid']):
                    sites.setdefault(func,{}).setdefault(name,[]).append(line.strip())
    return {'object':str(path),'sha256':sha256(raw).hexdigest(),'constructorCount':n,'constructors':row,'functionsWithImmediate':sites}

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('object',type=Path);ap.add_argument('--out',required=True,type=Path)
    ap.add_argument('--tags',nargs=2,default=['$private.p205.spine.left','$private.p205.spine.right'])
    a=ap.parse_args();a.out.write_text(json.dumps(analyze(a.object,a.tags),indent=2)+'\n')
