#!/usr/bin/env python3
"""Authenticate two consecutive assembly generations; no correctness theorem."""
import argparse,hashlib,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,fresh_output,write_json
p=argparse.ArgumentParser();p.add_argument('--first',type=Path,required=True);p.add_argument('--second',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=fresh_output(a.out,ROOT);rows=[json.loads(f.read_text())for f in [a.first,a.second]]
inputs=[pin(__file__),pin(a.first),pin(a.second)]
report=dict(kind='phase181-native-assembly-reproduction',complete=False,inputs=inputs,scope='Consecutive native assembly generations on the same source, binding, runtime and machine toolchain. Byte equality is bootstrap consistency, not semantic equivalence to an independent implementation or proof.')
def sections(file):
 data=Path(file).read_bytes();require(data[:6]==b'\x7fELF\x02\x01','ELF64 little-endian required')
 offset=struct.unpack_from('<Q',data,40)[0];size,count,names_index=struct.unpack_from('<HHH',data,58)
 headers=[struct.unpack_from('<IIQQQQIIQQ',data,offset+i*size)for i in range(count)]
 names_header=headers[names_index];names=data[names_header[4]:names_header[4]+names_header[5]]
 return {names[h[0]:].split(b'\0',1)[0].decode():(h[2],data[h[4]:h[4]+h[5]])for h in headers if h[1]!=8}
try:
 for row in rows:
    require(row['complete']and row['kind']=='phase181-native-assembly-build'and not row['changedInputs'],'successful build required')
    inputs.extend(row[k]for k in ['source','image','binding','assembly','object','binary','runtime'])
 for item in inputs:verify(item)
 b,c=rows
 same=lambda x,y:x['bytes']==y['bytes']and x['sha256']==y['sha256']
 require(same(b['binary'],c['image']),'not consecutive generations')
 for key in ['source','binding','runtime']:require(same(b[key],c[key]),'changed '+key)
 require(b['toolchain']==c['toolchain'],'machine policy differs')
 report['identical']={key:same(b[key],c[key])for key in ['assembly','object','binary']}
 require(report['identical']['assembly'],'assembly differs')
 first,second=sections(b['binary']['file']),sections(c['binary']['file'])
 require(first.keys()==second.keys(),'ELF section inventory differs')
 report['sections']=[dict(name=k,allocated=bool(first[k][0]&2),equal=first[k]==second[k],bytes=len(first[k][1]),firstSha256=hashlib.sha256(first[k][1]).hexdigest(),secondSha256=hashlib.sha256(second[k][1]).hexdigest())for k in first]
 report['allocatedSectionsIdentical']=all(r['equal']for r in report['sections']if r['allocated'])
 if '.strtab' in first:
    x,y=(set(z['.strtab'][1].split(b'\0'))for z in [first,second])
    report['symbolStringsOnly']={'first':[v.decode()for v in sorted(x-y)],'second':[v.decode()for v in sorted(y-x)]}
 report['complete']=True
except Exception as e:report['error']=repr(e)
write_json(out/'report.json',report);print(json.dumps({k:report[k]for k in ['complete','identical','error']if k in report}))
if not report['complete']:raise SystemExit(1)
