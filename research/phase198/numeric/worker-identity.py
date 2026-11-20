"""Bind the inspected exact worker bytes, without asserting whole-object equality."""
from pathlib import Path
import hashlib,json,struct
from prepare import ROOT,HERE,pin,SYMBOL

def symbol_bytes(path,name):
 b=Path(path).read_bytes();assert b[:6]==b'\x7fELF\x02\x01'
 e=struct.unpack_from('<16sHHIQQQIHHHHHH',b);off,entsize,count=e[6],e[11],e[12]
 sections=[struct.unpack_from('<IIQQQQIIQQ',b,off+i*entsize) for i in range(count)]
 matches=[]
 for s in sections:
  if s[1]!=2:continue
  strings=sections[s[6]];tab=b[strings[4]:strings[4]+strings[5]]
  for at in range(s[4],s[4]+s[5],s[9]):
   n,info,other,section,value,size=struct.unpack_from('<IBBHQQ',b,at)
   nm=tab[n:tab.index(b'\0',n)].decode()
   if nm==name:
    x=sections[section];start=x[4]+value-x[3];matches.append(b[start:start+size])
 assert len(matches)==1 and matches[0]
 return matches[0]

rows=[]
for case in ['mandelbrot','variation-mandelbrot-grid-4-7','variation-mandelbrot-grid-5-31','scalar-region-8192']:
 old=ROOT/'selfhost/build/phase195/native45-01'/case/'machine/program.o';current=ROOT/'selfhost/build/phase198/native45-02'/case/'machine/program.o'
 a=symbol_bytes(old,SYMBOL);b=symbol_bytes(current,SYMBOL);assert a==b,case
 rows.append(dict(case=case,old=pin(old),current=pin(current),wholeObjectEqual=old.read_bytes()==current.read_bytes(),workerBytes=len(a),workerSha256=hashlib.sha256(a).hexdigest(),workerBytesExact=True))
(HERE/'worker-identity.json').write_text(json.dumps(dict(kind='exact-elf-worker-identity-v1',symbol=SYMBOL,rows=rows,method=pin(__file__),scope='Exact symbol byte slice, separately pinned objects. Whole objects may differ. No old timing is substituted for the current baseline.'),indent=2)+'\n')
print(json.dumps(rows))
