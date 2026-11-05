#!/usr/bin/env python3
"""Paired native frontend stage spans and complete canonical result equality."""
import argparse,json,re,statistics,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,run,write_json,fresh_output
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--source',type=Path,action='append',required=True);p.add_argument('--rounds',type=int,default=2);p.add_argument('--seconds',type=int,default=100);a=p.parse_args();require(1<=a.rounds<=3,'Bounded rounds');out=fresh_output(a.out,ROOT)
base=pin(ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend');images={}
r=dict(complete=False,inputs=[pin(__file__),base],rows=[],scope='Native QBE cold Base + actual parser/checker; stage wall spans exclude canonical output serialization, but include tiny marker-print costs. Complete result equality and successful exit required. Not whole-compiler speed or formal equivalence.')
for mode in ['baseline','compact']:
 receipt=ROOT/f'selfhost/build/phase163/frontend-native-{mode}01/report.json';b=json.loads(receipt.read_text());require(b['complete'],'Unbuilt frontend');verify(b['binary']);images[mode]=b['binary'];r['inputs'] += [pin(receipt),b['binary']]
def save():write_json(out/'report.json',r)
try:
 for index,source in enumerate(a.source):
  source=pin(source);r['inputs'].append(source);row=dict(source=source,samples=[],complete=False);r['rows'].append(row);save();expected=None
  for turn in range(a.rounds):
   for mode in (['baseline','compact'] if turn%2==0 else ['compact','baseline']):
    stem=f'{index}-{turn}-{mode}';output=out/(stem+'.observation');cmd=[images[mode]['file'],'--threads','1','--gpu','off','--','phase163-frontend','check',source['file'],base['file'],str(output)]
    job=run(cmd,cwd=ROOT,stdout=out/(stem+'.stdout'),stderr=out/(stem+'.stderr'),seconds=a.seconds)
    require(job['complete'] and job['stdout']['bytes']==0,'Native frontend failure '+stem)
    markers=Path(job['stderr']['file']).read_text().splitlines();stages={}
    for marker in markers:
     match=re.fullmatch(r'(read|base_prepare|parse_load|check|observe_write)_ms=(\d+)',marker);require(match,'Unexpected diagnostic '+marker);require(match[1] not in stages,'Duplicate stage');stages[match[1]]=int(match[2])/1000
    require(set(stages)=={'read','base_prepare','parse_load','check','observe_write'},'Missing stage')
    observed=pin(output);identity=(observed['bytes'],observed['sha256']);expected=identity if expected is None else expected;require(identity==expected,'Complete frontend result differs')
    row['samples'].append(dict(mode=mode,round=turn,stagesSeconds=stages,observation=observed,process=job));save()
  row['medianSeconds']={mode:{stage:statistics.median(x['stagesSeconds'][stage] for x in row['samples'] if x['mode']==mode) for stage in row['samples'][0]['stagesSeconds']} for mode in images};row['complete']=True;save()
 r['complete']=True
except Exception as e:r['error']=str(e);raise
finally:save();print(json.dumps(dict(complete=r['complete'],sources=len(r['rows']),error=r.get('error'))))
