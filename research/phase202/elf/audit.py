"""Recompute segmented output layout and full self-object digest from retained section payloads."""
import hashlib,json,struct,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'research/phase201/elf'))
from audit import sections as read_sections

SPECS=[(1,1,6,16,0,0,0),(7,1,2,8,0,0,0),(15,1,3,8,0,0,0),(21,4,0,8,24,7,1),(32,4,0,8,24,7,2),(45,4,0,8,24,7,3),(56,2,0,8,24,8,None),(64,3,0,1,0,0,0),(72,3,0,1,0,0,0),(82,1,0,1,0,0,0)]

def checked(p):
    b=p.read_bytes();table=read_sections(b);assert len(table)==11 and table[0][0]=='';plain={name:b[r[4]:r[4]+r[5]] for name,r in table[1:]};symbols=plain['.symtab'];n=len(symbols)//24;first=next((i for i in range(n) if symbols[24*i+4]>>4!=0),n);assert len(symbols)==24*n
    lens=[len(plain[s])for s in ('.text','.rodata','.data')]+[24*sum(1 for _ in struct.iter_unpack('<QQq',plain[s]))for s in ('.rela.text','.rela.rodata','.rela.data')]+[24*n,len(plain['.strtab']),len(plain['.shstrtab']),0]
    h=bytes(64);pos=64;segments=[]
    for (name,r),desc,length in zip(table[1:],SPECS,lens):
        si,kind,flags,align,entry,link,info=desc;start=(pos+align-1)&-align
        assert start==r[4] and length==r[5];segments.extend([bytes(start-pos),plain[name]]);pos=start+length
        h+=struct.pack('<IIQQQQIIQQ',si,kind,flags,0,start,length,link,first if info is None else info,align,entry)
    shoff=(pos+7)&-8;hdr=struct.pack('<16sHHIQQQIHHHHHH',b'\x7fELF\x02\x01\x01'+bytes(9),1,62,1,0,0,shoff,0,64,0,0,64,11,9);segments=[hdr,*segments,bytes(shoff-pos),h]
    actual=hashlib.sha256(b''.join(segments)).hexdigest();assert actual==hashlib.sha256(b).hexdigest()
    return dict(file=str(p.relative_to(ROOT)),rawBytes=len(b),sha256=actual,nonemptySegments=sum(bool(x)for x in segments),largestSegment=max(map(len,segments)),payloadBytes=sum(lens),avoidedLargeReverseAndRebuildCons=2*sum(lens),relaCount=sum(lens[3:6])//24)
if __name__=='__main__':
 ps=[ROOT/'selfhost/build/phase198/progress-native-self01/program.o',ROOT/'selfhost/build/phase201/elfscreen01/oracle.o'];print(json.dumps(dict(kind='phase202-offline-segmented-layout-audit',scope='Independent section layout replay from existing ELF payloads. No candidate execution.',rows=[checked(p)for p in ps]),indent=2))
