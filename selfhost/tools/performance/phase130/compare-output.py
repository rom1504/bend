"""Compare frozen ordinary45 QBE and ELF sections, without executing programs."""
import argparse
import hashlib
import json
from pathlib import Path
import struct

def pin(path):
 path=Path(path).resolve();b=path.read_bytes();return dict(file=str(path),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(row):
 assert pin(row['file'])==row;return Path(row['file'])
def sections(path):
 data=Path(path).read_bytes();assert data[:6]==b'\x7fELF\x02\x01'
 h=struct.unpack_from('<16sHHIQQQIHHHHHH',data);off,esize,count,names=h[6],h[11],h[12],h[13]
 assert esize==64 and off+count*esize<=len(data) and names<count
 ss=[struct.unpack_from('<IIQQQQIIQQ',data,off+i*esize) for i in range(count)]
 ns=ss[names];strings=data[ns[4]:ns[4]+ns[5]];out={}
 for s in ss:
  name=strings[s[0]:].split(b'\0',1)[0].decode();assert name not in out
  if s[1]!=8:assert s[4]+s[5]<=len(data)
  out[name]=dict(bytes=s[5],address=s[3],flags=s[2],type=s[1],sha256=None if s[1]==8 else hashlib.sha256(data[s[4]:s[4]+s[5]]).hexdigest())
 return out

def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['before','after','out']:ap.add_argument('--'+n,type=Path,required=True)
 a=ap.parse_args();assert not a.out.exists()
 old,new=[json.loads(p.read_text()) for p in [a.before,a.after]]
 assert all(r['complete'] and r['passed'] and r['summary']['semanticPasses']==45 for r in [old,new])
 assert old['names']==new['names'] and len(old['rows'])==len(new['rows'])==45
 rows=[];inputs=[pin(__file__),pin(a.before),pin(a.after)]
 for x,y in zip(old['rows'],new['rows']):
  assert x['name']==y['name'] and x['expected']==y['expected']
  assert verify(x['product']).read_bytes()==verify(y['product']).read_bytes()
  aa,bb=[sections(verify(r['binary'])) for r in [x,y]]
  assert set(aa)==set(bb);diff=[n for n in aa if aa[n]!=bb[n]]
  assert aa['.text']==bb['.text']
  assert all(aa[n]==bb[n] for n in aa if aa[n]['flags']&2 or bb[n]['flags']&2)
  assert set(diff)<=set(['.strtab'])
  rows.append(dict(name=x['name'],oldQbe=x['product'],newQbe=y['product'],oldBinary=x['binary'],newBinary=y['binary'],qbeByteIdentical=True,textByteIdentical=True,allAllocatedSectionsEqual=True,differingElfSections=diff))
  inputs.extend([x['product'],y['product'],x['binary'],y['binary']])
 result=dict(complete=True,cases=45,qbeByteIdentical=True,textByteIdenticalCount=45,allAllocatedSectionsUnchanged=True,rows=rows,inputs=inputs,
             scope='Original ordinary45 correctness sources, not historical runtime wrappers. Exact QBE, .text, allocated data/metadata/addresses and BSS layout preserved. ELF differences are limited to nonallocated symbol strings. No runtime timings inferred.')
 a.out.write_text(json.dumps(result,indent=2)+'\n');print('45 exact QBE and machine-code/data comparisons passed')
if __name__=='__main__':main()
