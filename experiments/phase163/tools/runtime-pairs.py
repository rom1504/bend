#!/usr/bin/env python3
"""Counterbalanced fresh-process timing of already validated exact binaries."""
import argparse,json,statistics,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,run,write_json,fresh_output
p=argparse.ArgumentParser();p.add_argument('--builds',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();data=json.loads(a.builds.read_text());require(data['complete'],'Incomplete native controls');out=fresh_output(a.out,ROOT)
r=dict(complete=False,inputs=[pin(__file__),pin(a.builds)],rows=[],scope='Four reversed-order pairs per mode and real compiler workload. Single-process full-result traversal, same runtime/toolchain; these are compiler computation slices, not broad benchmark or upstream ratios.')
def save():write_json(out/'report.json',r)
try:
 for index,case in enumerate(data['rows']):
  row=dict(name=case['name'],samples=[],complete=False);r['rows'].append(row);save();expected=case['products']['baseline']['execution']['stdout'];verify(expected);r['inputs'].append(expected)
  for pair in range(4):
   for mode in (['baseline','direct'] if (index+pair)%2==0 else ['direct','baseline']):
    image=case['products'][mode]['binary'];verify(image);stem=f'{index}-{pair}-{mode}'
    job=run([image['file'],'--threads','1','--gpu','off'],cwd=ROOT,stdout=out/(stem+'.stdout'),stderr=out/(stem+'.stderr'),seconds=5)
    require(job['complete'] and job['stderr']['bytes']==0,'Runtime failed');require(job['stdout']['sha256']==expected['sha256'] and job['stdout']['bytes']==expected['bytes'],'Complete output differs')
    row['samples'].append(dict(mode=mode,pair=pair,image=image,**job));save()
  row['medians']={mode:statistics.median(x['seconds'] for x in row['samples'] if x['mode']==mode) for mode in ['baseline','direct']};row['ratio']=row['medians']['direct']/row['medians']['baseline'];row['complete']=True;save()
 r['complete']=True
except Exception as e:r['error']=str(e);raise
finally:save();print(json.dumps(dict(complete=r['complete'],rows=len(r['rows']),error=r.get('error'))))
