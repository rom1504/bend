#!/usr/bin/env python3
"""Reuse the three retained full profiles; no capture or target execution."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def verify(x):assert pin(x['file'])==x
source=ROOT/'research/phase144/final-profile.json';d=json.loads(source.read_text());assert d['complete']
inputs=[pin(__file__),pin(source)];engines=[]
for key in ['phase143','source01Atomic','final03Serial']:
 x=d[key]
 for field in ['stageReport','run','spec']:verify(x[field]);inputs.append(x[field])
 assert x['quality']['usable_for_process_cpu_attribution'] and x['quality']['zero_loss']
 engines.append(dict(key=key,samples=x['header']['samples'],diagnosticWallSeconds=x['row']['wallSeconds'],periodUs=x['header']['period_us'],mainThreadCpuFraction=x['quality']['main_thread_cpu_fraction'],stageReport=x['stageReport'],capture=x['run'],topActiveOwners=x['active'][:20],topPhysical=x['physical'][:20]))
summary=dict(kind='phase145-retained-profile-inventory',complete=True,targetsRun=False,inputs=inputs,engines=engines,stageGroups=d['groups'],physicalFamilies=d['physicalFamilies'],final03RegisterTransport=d['registerBank'],final03Append=d['stringAppendPhysical'],final03Concat=d['concatPhysical'],limits=d['limits']+['No final04 full profile exists in this comparison.','Stage clocks and active/physical sample views overlap; do not sum them as independent opportunities.','Counters count different events than samples; no direct conversion to elapsed time or exact allocation origins.'])
out=ROOT/'research/phase145/native-history.json';assert not out.exists();out.write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(dict(complete=True,summary=pin(out),engines=[{k:x[k] for k in ['key','samples','diagnosticWallSeconds']} for x in engines])))
