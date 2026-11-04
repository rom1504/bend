#!/usr/bin/env python3
"""Preserve quality refusals; attribute only the accepted full-source capture."""
import json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,write_json
B=ROOT/'selfhost/build/phase160';O=ROOT/'implementation/phase160'
clean=json.loads((B/'full-c01/report.json').read_text())['rows'][0]['process']
records=[]
for name in ['full-profile01','full-profile02']:
 p=B/name/'report.json';r=json.loads(p.read_text());require(r['complete'] and r['passed'],'Bad profile output')
 row=r['rows'][0];a=json.loads(verify(row['analysis']).read_text());verify(row['profile'])
 require(a['identities']['capture']['sha256']==row['profile']['sha256'],'Wrong capture')
 require(a['identities']['binary']['sha256']=='d202c5c3e3973d4f08c10315a04058d43e8efff2b7b4e8ded814918f671da95f','Wrong image')
 groups={}
 for label,pattern in [('tracing_collection',r'^gc_(mark|collect|rescan|sweep|scan)'),('refill',r'^gc_refill'),('all_named_gc',r'^gc_'),('apply',r'^apply$')]:
  count=sum(f['samples'] for f in a['top_functions'] if re.search(pattern,f['name']))
  groups[label]=dict(samples=count,fraction=count/a['header']['samples'])
  if a['usable']:groups[label]['estimatedCleanCpuSeconds']=groups[label]['fraction']*clean['cpuSeconds']
 records.append(dict(run=name,report=pin(p),capture=row['profile'],analysis=row['analysis'],
  usable=a['usable'],quality=a['quality'],header=a['header'],groups=groups,topFunctions=a['top_functions'][:25],
  diagnosticSeconds=row['wallSeconds']))
require(not records[0]['usable'] and records[1]['usable'],'Expected explicit rejected/accepted pair')
write_json(O/'profiles.json',dict(kind='phase160-full-compiler-profile',complete=True,
 method=pin(__file__),cleanCpuSeconds=clean['cpuSeconds'],captures=records,
 limitations=['Only the zero-loss100ms capture supports numerical attribution;8ms capture remains rejected.',
 'Physical leaves, not inclusive stages/callers or allocation counts. Inlined GC/allocation work can appear under generated functions.',
 'One accepted fixed period may alias. Percentages are approximate; absolute times scale separate clean CPU.',
 'QBE Phase153 source-stage profile is historical, not a matched physical capture of the Phase156 request image.']))
print(json.dumps(records[1]['groups']))
