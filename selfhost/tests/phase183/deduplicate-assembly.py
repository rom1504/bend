#!/usr/bin/env python3
"""Deduplicate only explicit immutable equal Phase183 assembly generation products."""
from pathlib import Path
import hashlib, importlib.util, json, os, shutil, stat
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('retention',ROOT/'selfhost/tools/build-retention/archive-v02.py')
A=importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
out=ROOT/'selfhost/build-retention/phase183/equal-assembly-products'
def same(a,b):
 with a.open('rb') as x,b.open('rb') as y:
  while True:
   p,q=x.read(1024**2),y.read(1024**2)
   if p!=q:return False
   if not p:return True
base=ROOT/'selfhost/build/phase183/native-chain01'
pairs=[(base/'n2/program.s',base/'n1/program.s'),
       (base/'n2/program.o',base/'n1/program.o'),
       (base/'n2/program.s',base/'s3/program.s')]
with A.exclusive():
 A.need(not out.exists(),'Fresh output required');out.mkdir(parents=True)
 r={'kind':'phase183-explicit-equal-product-deduplication','complete':False,'method':A.pin(__file__),
    'freeBefore':shutil.disk_usage(ROOT).free,'scope':'Only three explicit immutable same-generation assembly product pairs. All paths/bytes/modes retained; no compiler, runtime, receipt or source deleted. Future builds must use fresh paths, never mutate linked products.','rows':[]}
 def save():
  tmp=out/'report.tmp';tmp.write_text(json.dumps(r,indent=2)+'\n');tmp.replace(out/'report.json')
 for canonical,duplicate in pairs:
  A.need(canonical.resolve()==canonical and duplicate.resolve()==duplicate,'No symlinks')
  x,y=canonical.stat(),duplicate.stat()
  A.need(stat.S_ISREG(x.st_mode) and stat.S_ISREG(y.st_mode) and x.st_dev==y.st_dev,'Regular same-filesystem files')
  A.need((x.st_mode,x.st_uid,x.st_gid)==(y.st_mode,y.st_uid,y.st_gid) and not os.listxattr(canonical) and not os.listxattr(duplicate),'Metadata differs')
  A.need(y.st_nlink==1 and x.st_ino!=y.st_ino,'Already shared recipient')
  xp,yp=A.pin(canonical),A.pin(duplicate)
  A.need(xp['bytes']==yp['bytes'] and xp['sha256']==yp['sha256'] and same(canonical,duplicate),'Products differ')
  r['rows'].append({'canonical':xp,'duplicate':yp,'allocatedRecipient':y.st_blocks*512,'complete':False});save()
  temp=duplicate.with_name(duplicate.name+'.phase183-link')
  A.need(not temp.exists(),'Fresh link path required')
  os.link(canonical,temp);os.replace(temp,duplicate)
  A.need(canonical.stat().st_ino==duplicate.stat().st_ino and A.pin(duplicate)==yp and same(canonical,duplicate),'Post-link check failed')
  r['rows'][-1]['complete']=True;save()
 r.update(complete=True,freeAfter=shutil.disk_usage(ROOT).free);save()
 print(json.dumps({'complete':True,'pairs':len(pairs),'observedFreeIncrease':r['freeAfter']-r['freeBefore']}))
