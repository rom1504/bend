"""Consolidate completed Phase130 evidence; no targets or benchmark redefinition."""
import gzip
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
OUT=ROOT/'implementation/phase130'
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();data=p.read_bytes();return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def save(name,value):(OUT/name).write_text(json.dumps(value,indent=2)+'\n')
def main():
 qpath=ROOT/'selfhost/build/phase130/native-qualification01.json';q=read(qpath);assert q['complete'] and q['nativeQualified']
 source=Path(q['source']['file']);assert pin(source)==q['source']
 archive=OUT/'compiler-source01.bend.gz';assert gzip.decompress(archive.read_bytes())==source.read_bytes()
 save('native-qualification.json',q)
 (OUT/'output-preservation.json').write_bytes((ROOT/'selfhost/build/phase130/output-preservation01.json').read_bytes())
 old=read(OUT/'native-results.json');old['nativeQualified']=True;old['qualificationScope']='Hosted→N1→N2 exact QBE, focused19 on N1/N2 and ordinary45 on N2.';old['qualification']=pin(qpath)
 genpath=ROOT/'selfhost/build/phase112/p130-n1-n2-native01/report.json';gen=read(genpath);assert gen['complete'] and gen['passed']
 old['separateN1N2Block']=dict(rawReport=pin(genpath),scope='Do not pool with parent/candidate block.',ratios=gen['summary']['cache']['threeCaseGeometricRatios'])
 save('native-results.json',old)
 current=read(OUT/'source.json');current['nativeQualified']=True;current['qualification']=pin(qpath);current['scope']='Exact archived source of the separately qualified Phase130 native research compiler; installed selection unchanged.';save('source.json',current)
 carrier=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json';c=read(carrier)
 sm=ROOT/'selfhost/build/phase130/mode-source01/manifest.json';api=ROOT/'selfhost/build/phase111/p130-mode-api01/report.json';runtime=ROOT/'selfhost/build/phase128/runtime-borrow01/report.json'
 candidate=dict(complete=True,nativeQualified=True,source=q['source'],archive=pin(archive),sourceManifest=pin(sm),api=q['api'],checkedApi=pin(api),runtime=q['runtime'],runtimeReport=pin(runtime),n1=q['n1'],n2=q['n2'],qualification=pin(qpath),qualificationArchive=pin(OUT/'native-qualification.json'),admission=q['admission'],preferredCarrier=c['carrier'],preferredCarrierReceipt=pin(carrier),preferredStamp=c['stamp'],legacyCarrierReceipt=pin(ROOT/'selfhost/tools/performance/phase88/base/carrier01/receipt.json'),installed=False,productionSelectionChanged=False,scope='Qualified direct-QBE native research compiler. Explicit authenticated compact carrier selects faster preparation; legacy qualification runners retain decimal compatibility.')
 save('candidate.json',candidate)
 guards=[]
 for p in sorted((ROOT/'selfhost/build/phase130').glob('*guard/process.json')):
  r=read(p);guards.append(dict(receipt=pin(p),complete=r['complete'],seconds=r['wallSeconds'],peakRssBytes=r.get('peakTreeRssBytes',0),command=r['command']))
 cost=dict(complete=True,guardCount=len(guards),successfulGuards=sum(r['complete'] for r in guards),failedGuards=sum(not r['complete'] for r in guards),guardedSeconds=sum(r['seconds'] for r in guards),maximumTreeRssBytes=max(r['peakRssBytes'] for r in guards),guards=guards,scope='Sum of serial guarded envelopes, including targets, authentication and failures. Agents/source research/storage work and billing quota are not inferred from these clocks.')
 save('cost.json',cost)
 (OUT/'checks.json').write_text(json.dumps(dict(complete=True,nativeQualified=True,modePredicates=26,malformedInputChecks=32,completeQbeModeComparisons=9,focusedN1=dict(successes=16,refusals=3),focusedN2=dict(successes=16,refusals=3),ordinaryN2=45,unchangedQbeAndAllocatedMachineSections=45,fullSelfQbeBytes=q['hostedQbe']['bytes'],sameSourceN1N2TimingObservations=27,parentCandidateTimingObservations=27,installed=False),indent=2)+'\n')
 print(json.dumps(dict(complete=True,cost={k:v for k,v in cost.items() if k not in ['guards','scope']},candidate=pin(OUT/'candidate.json'))))
if __name__=='__main__':main()
