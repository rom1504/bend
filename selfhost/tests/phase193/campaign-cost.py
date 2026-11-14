#!/usr/bin/env python3
"""Sum completed outer guard costs once; preserve failures and resource maxima."""
import argparse,hashlib,json
from pathlib import Path
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[3]
BUILD=ROOT/'selfhost/build/phase193'
def pin(p):
 b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def category(n):
 if n.startswith('budget-'):n=n[len('budget-'):]
 if n.startswith(('native-image','native-self','native-reproduction')):return 'compiler-image-builds'
 if n.startswith(('native45','native4-','native64','runtime10')):return 'native-oracle-and-qualification'
 if n.startswith('compiler-cost'):return 'compiler-request-timing'
 if n.startswith(('runtime0','dev-runtime')):return 'program-runtime'
 if 'api' in n:return 'checked-api-acquisition'
 if 'controls' in n:return 'adversarial-controls'
 if 'profile' in n:return 'compiler-profiling'
 if n.startswith(('compiler-hot','ablation','timing')):return 'compiler-kernel-experiment'
 if n.startswith('dev-'):return 'development-products'
 if 'check' in n:return 'source-checking'
 return 'offline-or-other'
def total(rows):
 return dict(jobs=len(rows),failed=sum(x['returncode']!=0 for x in rows),
  wallSeconds=sum(x['wallSeconds'] for x in rows),
  peakRssBytes=max((x['peakTreeRssBytes'] for x in rows),default=0),
  peakRunAllocatedBytes=max((x['peakRunAllocatedBytes'] for x in rows),default=0))
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert not a.out.exists()
rows=[]
for f in sorted(BUILD.glob('*-guard/process.json')):
 d=json.loads(f.read_text());assert d.get('finished') and d.get('returncode') is not None,str(f)
 n=f.parent.name[:-6]
 rows.append(dict(job=n,category=category(n),receipt=pin(f),
  **{k:d[k] for k in ['complete','returncode','wallSeconds','peakTreeRssBytes','peakRunAllocatedBytes','minimumDiskFreeBytes']}))
r=dict(kind='phase193-outer-guard-cost',complete=True,programsExecuted=False,
 capturedUTC=datetime.now(timezone.utc).isoformat(),method=pin(Path(__file__)),
 total=total(rows),byCategory={c:total([r for r in rows if r['category']==c]) for c in sorted({x['category'] for x in rows})},
 jobs=rows,scope='Outer guards only, no nested double counting. Failed jobs included. Guard wall is not total research time, agent compute or billed quota. Metadata analysis, retention and orchestration outside guards are excluded. Resource fields are maxima, not cumulative storage.')
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r['total']))
