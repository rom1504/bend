"""Count complete linked functions matching a frozen template, resolving its call."""
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import struct
import sys

def census(image, expectation):
    elf=gzip.decompress(image.read_bytes())
    sha=hashlib.sha256(elf).hexdigest()
    pin=json.loads((image.parent/'results.json').read_text())['runs'][0]['elfSha256']
    assert sha==pin and elf[:6]==b'\x7fELF\x02\x01' and struct.unpack_from('<H',elf,18)[0]==62
    header=struct.unpack_from('<16sHHIQQQIHHHHHH',elf)
    shoff,entsize,n=header[6],header[11],header[12]
    sections=[struct.unpack_from('<IIQQQQIIQQ',elf,shoff+i*entsize) for i in range(n)]
    sym,= [s for s in sections if s[1]==2]
    names=sections[sym[6]]
    strings=elf[names[4]:names[4]+names[5]]
    symbols=[]
    for off in range(sym[4],sym[4]+sym[5],sym[9]):
        key,info,_,section,addr,size=struct.unpack_from('<IBBHQQ',elf,off)
        if info&15!=2 or not section or not size:continue
        label=strings[key:strings.index(0,key)]
        symbols.append((label,section,addr,size))
    runtime,={addr for label,_,addr,_ in symbols if label==b'p111_rt_apply'}
    template=bytes.fromhex(expectation['nativeBytes'])
    p=expectation['localRelocations'][0][0]
    assert p==99 and template[p-1]==0xe8
    matched=0; sizeMatches=0; distinct=set();families=Counter()
    for label,section,addr,size in symbols:
        if not label.startswith(b'p111_FID_') or addr in distinct:continue
        distinct.add(addr)
        s=sections[section]
        start=s[4]+addr-s[3];raw=elf[start:start+size]
        assert len(raw)==size
        families[(size,hashlib.sha256(raw).hexdigest())]+=1
        if size!=len(template):continue
        sizeMatches+=1
        if raw[:p]!=template[:p] or raw[p+4:]!=template[p+4:]:continue
        disp,=struct.unpack_from('<i',raw,p)
        if addr+p+4+disp==runtime:matched+=1
    return dict(image=sha,publicAddresses=len(distinct),templateBytes=len(template),functionsOfThatSize=sizeMatches,
                exactWithResolvedApply=matched,otherCensus='Exact linked code bytes only, different call displacements count separately',
                mostFrequentLiteralBodies=[dict(bytes=k[0],sha256=k[1],functions=v) for k,v in families.most_common(10)])
if __name__=='__main__':
    result=census(Path(sys.argv[1]),json.loads(Path('research/phase202/continuations/evidence.json').read_text()))
    print(json.dumps(result,indent=2))
