#!/usr/bin/env python3
"""Authenticate the experimental emitter against the qualified native baseline."""
from pathlib import Path
import importlib.util,json,sys,hashlib
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('source',ROOT/'selfhost/tools/build/source.py');s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
def read(p):return json.loads(Path(p).read_text())
def verify(p):
 path=Path(p['file']);h=hashlib.sha256()
 with path.open('rb') as f:
  for block in iter(lambda:f.read(1048576),b''):h.update(block)
 assert path.stat().st_size==p['bytes'] and h.hexdigest()==p['sha256'],p['file']
rootaudit=ROOT/'research/phase198/qualification/source-audit.json';audit=read(rootaudit)
assert audit['complete'] and audit['exactExecutableBodiesIdentical'] and not audit['normalizedDifferences']
for k in ('method','selectedSource','checkedApiSource','checkedApiReceipt','sourceAcceptanceReceipt'):verify(audit[k])
receipt=ROOT/'selfhost/build/phase198/heap-api03/report.json';api=read(receipt);assert api['complete'] and api['checked'] and not api.get('error')
for p in api['inputs']:verify(p)
manifest=ROOT/'selfhost/build/phase198/heap-api-source02/manifest.json';prep=read(manifest);assert prep['complete'] and prep['source']==api['source'] and prep['snapshot']==audit['selectedSource']
assert [r['name'] for r in prep['replacements']]==['x190_step']
roots=audit['sevenRoots']
def closure(p):
 rows=[((0,b['kind'],b['name']),b['data'],None) for b in s.blocks(Path(p).read_bytes())[1]]
 return {(key[1],key[2]):data for key,data,_ in s.declaration_closure(rows,roots)}
def framing(data):
 b=s.blocks(data)[1][0];return data[b['headerOffset']:].rstrip(b'\n')
base=closure(audit['checkedApiSource']['file']);candidate=closure(api['source']['file'])
added=sorted(set(candidate)-set(base));removed=sorted(set(base)-set(candidate));assert not removed
assert {name for kind,name in added}=={'x198h_public','x198h_finish','x198h_target','x198h_tail','x198h_selected'} and all(k=='def' for k,n in added)
changed=[key for key in base if framing(base[key])!=framing(candidate[key])]
assert changed==[('def','x190_step')],changed
report={'kind':'phase198-heap-native-baseline-mapping','complete':True,'targetsRun':False,'method':s.pin(Path(__file__)),'sourceMethod':s.pin(ROOT/'selfhost/tools/build/source.py'),'nativeBaselineSourceAudit':s.pin(rootaudit),'nativeBaselineSource':audit['selectedSource'],'checkedBaselineApiReceipt':audit['checkedApiReceipt'],'checkedCandidateApiReceipt':s.pin(receipt),'candidatePreparation':s.pin(manifest),'sameSevenRoots':roots,'baselineClosureDeclarations':len(base),'candidateClosureDeclarations':len(candidate),'addedDeclarations':added,'removedDeclarations':removed,'changedDeclarations':changed,'otherSharedDeclarationsByteIdentical':True,'claim':'Native198 N1 baseline is authenticated by existing exact seven-root source audit and native45 products. Candidate differs in precisely x190_step plus five reachable tail-transfer helpers; preparation closure is independently shared-plan matched. No redundant baseline emission required; actual paired objects and independent output oracles remain required.'}
s.dump(ROOT/'research/phase198/heap/source-mapping.json',report)
print(json.dumps({'complete':True,'changed':changed,'added':len(added)}))
