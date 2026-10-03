#!/usr/bin/env python3
"""Close mandatory inherited Phase41 actual tree and wrapper fixture controls."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
def ident(p):
 p=Path(p).resolve();return dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(row):
 p=row.get('path',row.get('file'));assert p and ident(p)['sha256']==row['sha256'];return Path(p)
def verify_all(value):
 if isinstance(value,dict):
  if 'sha256' in value and ('path' in value or 'file' in value):verify(value)
  for child in value.values():verify_all(child)
 elif isinstance(value,list):
  for child in value:verify_all(child)
def read(p):return json.loads(Path(p).read_text())
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('attempt',type=Path);p.add_argument('campaign',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
 attempt=ident(a.attempt/'attempt.json');base=a.campaign.resolve();assert not a.out.exists()
 inputs=[attempt,ident(__file__)];groups=[]
 for name,kind,oracles,boundaries,producer in [
  ('phase41-tree','phase41-tree-actual-wrapper-controls',124,17,'selfhost/tools/performance/phase42/frames/phase41-actual-controls-v2.mjs'),
  ('phase41-wrapper','phase41-wrapper-fixture-controls',84,2,'selfhost/tools/performance/phase42/fusion/phase41-wrapper-controls-v4.mjs')]:
  report_path=base/('phase41-wrapper-controls-v4/report.json' if name=='phase41-wrapper' else name+'-controls/report.json');r=read(report_path);assert r['kind']==kind and r['complete'] and r['checked']
  assert r['oracles']==oracles and r['boundaries']==boundaries
  assert verify(r['producer']).resolve()==ROOT/producer;verify_all(r)
  if name=='phase41-tree':
   d=read(verify(r['derivation']));verify_all(d);assert d['attempt']==attempt and d['complete'] and d['checked']
   assert verify(d['producer']).resolve()==ROOT/'selfhost/tools/performance/phase42/frames/phase41-actual-derive-v3.mjs'
   assert r['deep']==dict(nodes=60002,leaves=60003,sum='420021') and r['counts']>0
   counts=r['entryKinds'];assert set(counts)=={'global','lexical','total'}
   assert all(type(v)==int for v in counts.values()) and counts['global']>0 and counts['lexical']>0
   assert counts['total']==counts['global']+counts['lexical']==r['counts']
   before,after=r['ordinaryEntryKinds']['before'],r['ordinaryEntryKinds']['after']
   for row in [before,after]:
    assert set(row)=={'global','lexical','total'} and all(type(v)==int and v>=0 for v in row.values())
    assert row['total']==row['global']+row['lexical']
   assert after['lexical']>before['lexical'] and after['total']>before['total']
   assert d['dependencies']==['warp_leaf.go','Bool.xor','warp_leaf','warp_zip','warp','warp_node']
  else:
   assert r['attempt']==attempt and r['admitted']==['wrap.turn','wrap.forward']
   assert r['refused']==['wrap.empty','wrap.scalar','wrap.nat','wrap.reference','wrap.improper','wrap.bad_first','wrap.back','wrap.bridge','wrap.back_worker']
   expected={'global:wrap.turn':60,'global:wrap.forward':0,'lexical-tree:wrap.turn':12,'lexical-tree:wrap.forward':0,'lexical-outer:wrap.forward':0,'lexical-flat:wrap.forward':12}
   assert r['scopeEntries']=={'original':{},'wrapper':expected}
   inventory=r['activationInventory'];assert inventory['original']==[] and len(inventory['wrapper'])==6
   assert {row['key'] for row in inventory['wrapper']}==set(expected)
  execution_path=base/('run-phase41-wrapper-control-v4/run.json' if name=='phase41-wrapper' else 'run-'+name+'-control/run.json');e=read(execution_path)
  assert e['complete'] and e['returncode']==0 and not e.get('stoppedFor')
  assert e['secondsLimit']==120 and e['rssLimitBytes']==2048*1024**2 and e['availableFloorBytes']==2048*1024**2
  assert e['peakTreeRssBytes']<=e['rssLimitBytes'] and e['minimumAvailableBytes']>=e['availableFloorBytes']
  verify(e['producer']);assert e['producer']['sha256']==ident(ROOT/'selfhost/tools/performance/phase32/bounded-run.py')['sha256']
  assert any((Path(arg) if Path(arg).is_absolute() else ROOT/arg).resolve()==(ROOT/producer).resolve() for arg in e['command']); inputs.extend([ident(report_path),ident(execution_path)])
  groups.append(dict(name=name,complete=True,oracles=oracles,boundaries=boundaries))
 verify(attempt);a.out.parent.mkdir(parents=True,exist_ok=True)
 result=dict(kind='phase42-inherited-phase41-owner-close',complete=True,checked=True,attempt=attempt,inputs=inputs,groups=groups,scope='Only inherited Phase41 actual tree and wrapper fixture; new Phase42 and broad owners require separate closure.')
 result['pass']=True
 a.out.write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps({'complete':True,'pass':True,'groups':len(groups)}))
if __name__=='__main__':main()
