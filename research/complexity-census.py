#!/usr/bin/env python3
"""Immutable Git census for PR1207. Writes JSON only; no compiler/test execution.
python3 SCRIPT REPO OUTPUT_JSON [HEAD=5350b2fec8f6f8484c7a689e915b359d7ce86847]
"""
import subprocess,json,hashlib,re,sys
from pathlib import Path
ROOT=Path(sys.argv[1]); OUT=Path(sys.argv[2]); HEAD=sys.argv[3] if len(sys.argv)>3 else '5350b2fec8f6f8484c7a689e915b359d7ce86847'
def git(*args,inp=None):return subprocess.check_output(['git','-C',str(ROOT),*args],input=inp)
def batch(specs):
 raw=git('cat-file','--batch',inp=''.join(s+'\n' for s in specs).encode());off=0;out={}
 for s in specs:
  end=raw.index(b'\n',off);h=raw[off:end].split();off=end+1
  if h[-1]==b'missing':out[s]=None;continue
  assert h[1]==b'blob',(s,h);n=int(h[2]);out[s]=raw[off:off+n];off+=n+1
 assert off==len(raw)
 return out
selected=[('d238fc9','Initial snapshot'),('fdbe852','Phase1'),('f92d922','Phase2'),('89e2c83','Phase3'),('7d69850','Phase4'),('a6459af','Phase5 / simplification baseline'),('af3c639','S1 obsolete paths'),('7474b0b','S2 shared provenance'),('8cc51c1','S3 authoritative checking'),('22f6e8e','S4 frontend consolidation'),('bc322d9','Phase8 upstream2.0.32'),('f21e9f0','Phase9 compact literals'),('5f561c4','Phase10'),('1101206','Phase11'),('9a4e109','Phase12'),('d0d5878','Phase13 rejected experiments'),('abb200f','Phase14'),('a383163','Phase15'),('0b51d96','Phase16 compact release'),('fddfc84','Phase17'),('041dd38','Phase18'),('fd9e8b2','Phase19 shared live checker'),('c385d39','Phase20 declaration grammar'),('df94915','Phase21 source origins'),('1e64079','Phase22 contextual frontend'),('8eb2cc0','Phase23 upstream2.0.34'),('5350b2f','Phase24')]
sel={git('rev-parse',h).decode().strip():label for h,label in selected}
changed=git('log','--first-parent','--reverse','--format=%H','d238fc9^..'+HEAD,'--','selfhost/src').decode().splitlines()
commits=list(dict.fromkeys(changed+list(sel)));meta={}
for line in git('log','--first-parent','--format=%H\t%cs\t%s','d238fc9^..'+HEAD).decode().splitlines():
 h,date,subject=line.split('\t',2);meta[h]=(date,subject)
manifest=batch([h+':selfhost/src/compiler.json' for h in commits]);specs=[];mods={}
for h in commits:
 m=json.loads(manifest[h+':selfhost/src/compiler.json']);mods[h]=m
 assert len(m['modules'])==len(set(m['modules']))
 specs.extend(h+':selfhost/'+p for p in m['modules'])
data=batch(specs);rows=[]
for h in commits:
 files=[]
 for p in mods[h]['modules']:
  raw=data[h+':selfhost/'+p];s=raw.decode();ls=s.splitlines()
  files.append(dict(path='selfhost/'+p,sha256=hashlib.sha256(raw).hexdigest(),physicalLines=len(ls),nonblankLines=sum(bool(x.strip()) for x in ls),bytes=len(raw),defs=len(re.findall(r'^def\s+',s,re.M)),laws=len(re.findall(r'^law\s+',s,re.M)),types=len(re.findall(r'^type\s+',s,re.M))))
 row=dict(commit=h,shortCommit=h[:7],date=meta[h][0],subject=meta[h][1],label=sel.get(h),upstream=mods[h].get('upstream'),modules=len(files),files=files,sourceLink=f'https://github.com/rom1504/bend/blob/{h}/selfhost/src/compiler.json')
 for key in ['physicalLines','nonblankLines','bytes','defs','laws','types']:row[key]=sum(f[key] for f in files)
 rows.append(row)
order={h:i for i,h in enumerate(reversed(list(meta)))};rows.sort(key=lambda r:order[r['commit']])
report=dict(kind='unposted-pr1207-historical-source-census',head=git('rev-parse',HEAD).decode().strip(),method={'membership':'Exactly each historical revision selfhost/src/compiler.json modules, counted once. Excludes host/runtime, generated code, tools, tests, documentation. Dynamic historical membership intentionally includes new implemented compiler responsibilities.','physicalLines':'len(decoded UTF-8 text.splitlines()), includes comments and blank lines','nonblankLines':'Nonempty str.strip() lines','declarations':'Anchored ^def, ^law, ^type heads, not concept counts','historyScope':'Every first-parent commit touching selfhost/src plus selected phase checkpoints; measurements are immutable Git blobs, ignoring working-tree edits.','dates':'Commit committer dates; many phases share one day; use phases/commit order for chart.','scriptSha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},milestones=[r for r in rows if r['label']],allSourceCheckpoints=rows)
OUT.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'output':str(OUT),'milestones':len(report['milestones']),'checkpoints':len(rows),'head':report['head']}))
