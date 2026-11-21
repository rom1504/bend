"""Count equal continuation machine templates in the frozen direct x86 compiler object."""
import bisect
import collections
import hashlib
import json
import struct

from replay import P198, REF

def census():
    data=(P198/"progress-native-self01/program.o").read_bytes()
    assert hashlib.sha256(data).hexdigest()==REF["object"]["sha256"]
    u=lambda fmt,off:struct.unpack_from("<"+fmt,data,off)
    start=u("Q",40)[0]; width,count,names=u("HHH",58)
    sections=[u("IIQQQQIIQQ",start+i*width) for i in range(count)]
    def name(offset,base):
        pos=base+offset
        return data[pos:data.index(0,pos)].decode()
    by_name={name(row[0],sections[names][4]):row for row in sections}
    text=by_name[".text"]; syms=by_name[".symtab"];strbase=sections[syms[6]][4]
    funcs=[]
    for p in range(syms[4],syms[4]+syms[5],syms[9]):
        n,info,other,section,addr,size=u("IBBHQQ",p)
        if info&15==2 and section==sections.index(text) and size:
            funcs.append((addr,size,name(n,strbase)))
    funcs.sort()
    rel=by_name[".rela.text"]
    reloc=sorted(u("QQq",p) for p in range(rel[4],rel[4]+rel[5],rel[9]))
    offsets=[r[0] for r in reloc]
    prefix="p111_FID_"+''.join(str(ord(c))+'_' for c in '$p111.k.')
    full=collections.Counter(); param=collections.Counter()
    lengths={}
    first={}
    total=0
    for addr,size,n in funcs:
        if not n.startswith(prefix):continue
        total+=size
        body=data[text[4]+addr:text[4]+addr+size]
        rows=reloc[bisect.bisect_left(offsets,addr):bisect.bisect_left(offsets,addr+size)]
        for counter,mask in ((full,False),(param,True)):
            h=hashlib.sha256(body)
            for off,info,addend in rows:
                h.update(struct.pack('<QQq',off-addr, info&0xffffffff if mask else info, addend))
            key=h.digest()
            counter[key]+=1
            lengths[key]=size
            if not mask and key not in first:
                first[key]=(addr,"".join(chr(int(c)) for c in n.split("_FID_")[1][:-1].split("_")))
    return dict(objectSha256=REF["object"]["sha256"],textBytes=text[5],functionCount=len(funcs),
                continuationCount=sum(full.values()),continuationBytes=total,
                exactIncludingRelocationTargets=dict(unique=len(full),duplicateBytes=sum((c-1)*lengths[k] for k,c in full.items()),
                    largestRepeatedFamilies=[dict(instances=full[k],bodyBytes=lengths[k],repeatedBytes=(full[k]-1)*lengths[k],
                        example=first[k][1],sectionOffset=first[k][0]) for k in sorted(full,key=lambda k:(full[k]-1)*lengths[k],reverse=True)[:5]]),
                templatesWithRelocationTargetsAsParameters=dict(unique=len(param),duplicateBytes=sum((c-1)*lengths[k] for k,c in param.items())))
if __name__=="__main__":print(json.dumps(census(),indent=2))
