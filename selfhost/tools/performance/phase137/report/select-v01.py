"""Bind a qualified research checkpoint and exact45 code-identity evidence."""
import argparse,hashlib,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[5]
def pin(p):
 p=pathlib.Path(p).resolve();h=hashlib.sha256()
 with p.open('rb')as f:
  for b in iter(lambda:f.read(262144),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def verify(p):assert pin(p['file'])==p
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();assert not a.out.exists()
qp=ROOT/'implementation/phase137/native-qualification.json';q=json.loads(qp.read_text());assert q['complete']and q['nativeQualified'];verify(q['source']);verify(q['finalImage'])
parentp=ROOT/'implementation/phase134/final/candidate.json';parent=json.loads(parentp.read_text());assert q['runtime']==parent['runtime'];verify(parent['runtime'])
rp=ROOT/'selfhost/build/phase137/n3-wrappers01/report.json';r=json.loads(rp.read_text());refp=ROOT/'selfhost/build/phase134/reference03.json';ref=json.loads(refp.read_text());assert r['complete']and len(r['rows'])==45
cases={c['name']:c for c in ref['wrappers']};assert len(cases)==45
for row in r['rows']:
 c=cases.pop(row['workload']);expected=c['expectedQbe'];verify(expected);verify(row['stdout'])
 assert row['correct']and row['mode']=='clean'and row['round']==1 and row['returncode']==0 and not row['stderr']['bytes'] and row['command'][0]==q['finalImage']['file']
 assert row['stdout']['sha256']==expected['sha256'] and row['stdout']['bytes']==expected['bytes']
assert not cases
metricp=ROOT/'implementation/phase137/metrics.json';metrics=json.loads(metricp.read_text());assert metrics['complete'] and metrics['source']==q['source'] and metrics['coldPipeline']['ratio']<1
bridge=dict(report=pin(rp),reference=pin(refp),all45ByteExact=True,producingImage=q['finalImage'],runtime=q['runtime'],measuredProgramScreen=ref['measuredProgramScreen'],freshRuntimeTiming=False)
result=dict(kind='phase137-qualified-cold-compiler-research-checkpoint',complete=True,nativeQualified=True,selected=True,installed=False,
 source=q['source'],sourceManifest=q['sourceContract']['sourceManifest'],checkedApi=q['sourceContract']['checkedApi'],api=q['api'],runtime=q['runtime'],runtimeReport=parent['runtimeReport'],
 n1=q['n1'],n2=q['n2'],n3=q['n3'],preferredNative=q['finalImage'],preferredGeneration='N3',qualification=pin(qp),qualificationArchive=pin(qp),
 preferredCarrierReceipt=parent['preferredCarrierReceipt'],preferredCarrier=parent['preferredCarrier'],preferredStamp=parent['preferredStamp'],
 proofScope=dict(exactDeclarations=q['sourceContract']['unchangedProofDeclarations'],scope='Prior proof-source bridges unchanged; no new compiler-correctness theorem.'),
 parentSelection=pin(parentp),parentFallback=parent['n2'],performance=pin(metricp),programRuntimeBridge=bridge,
 evidence=[pin(ROOT/'implementation/phase137/evidence01/receipt.json'),pin(ROOT/'implementation/phase137/evidence02/receipt.json')],
 inputs=[pin(__file__),pin(qp),pin(parentp),pin(metricp),pin(rp),pin(refp)],
 scope='Qualified research compiler for cold builds, with approximately neutral small request latency and exact historical45 generated code. Installed CLI remains unchanged. Prefer actual N3; N2 is a distinct generation, not an alias. Previous qualified source/image retained.')
a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,nativeQualified=True,programs=45,preferredGeneration='N3',installed=False)))
