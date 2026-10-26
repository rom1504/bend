#!/usr/bin/env python3
"""Prepare final03 same-producer packaging gates; no target execution."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];HERE=Path(__file__).resolve().parent
OUT=ROOT/'selfhost/build/phase144/native-profile-plan02'
PROFILE=ROOT/'selfhost/build/phase144/native-profile-source03/compiler.bend'
API=ROOT/'selfhost/build/phase111/p144-native-profile-api02'
PRODUCER=ROOT/'selfhost/build/phase134/p144-final03-n2/program'
RUNTIME=ROOT/'selfhost/build/phase144/serial-rfc01/serial-rfc.o'
CARRIER=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'
Q3=ROOT/'selfhost/build/phase130/p144-final03-q3/report.json'
EMIT=ROOT/'selfhost/build/phase130/p144-native-profile03-emit01'
BUILD=ROOT/'selfhost/build/phase111/p144-native-profile03-n1'
FULLBUILD=ROOT/'selfhost/build/phase111/p144-native-profile03-full-q3-build01'
GUARD=ROOT/'selfhost/tools/performance/phase111/guard.py'
NATIVE=ROOT/'selfhost/tools/performance/phase130/native-request.py'
HOST=ROOT/'selfhost/tools/performance/phase144/hosted-request-v01.py'
ALIGNED=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 assert not OUT.exists();profile=json.loads(PROFILE.with_name('manifest.json').read_text());assert profile['source']==pin(PROFILE)
 assert profile['parent']['sha256']=='31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2'
 q3=json.loads(Q3.read_text());producer=json.loads(PRODUCER.with_name('report.json').read_text())
 assert q3['complete'] and q3['byteExact'] and q3['exitCode']==0 and q3['image']==pin(PRODUCER)
 assert q3['source']==profile['parent'] and producer['complete'] and producer['binary']==q3['image'] and producer['runtime']==pin(RUNTIME)
 assert pin(q3['product']['file'])==q3['product'];assert pin(q3['expectedQbe']['file'])==q3['expectedQbe']
 parentapi=ROOT/'selfhost/build/phase111/p144-integrated-api03/report.json';ar=json.loads(parentapi.read_text());assert ar['complete']and ar['checked']and profile['parent']in ar['inputs']
 oracle=ROOT/'selfhost/build/phase144/predicate-byte-candidate01/report.json';oracles=json.loads(oracle.read_text())
 assert oracles['complete'] and pin(parentapi)in oracles['inputs'] and ar['api']in oracles['inputs'] and profile['parent']in oracles['inputs']
 cases=[next(c for c in oracles['cases']if c['name']==n)for n in ['lexer','coverage-closures-256','coverage-map-churn-128']]
 for c in cases:assert c['verified'] and pin(c['source']['file'])==c['source'] and pin(c['qbe']['file'])==c['qbe']
 names={r['name']for r in json.loads(Path(profile['retainedDeclarations']['file']).read_text())}
 exports=['p88_cache_prepare','p86_plan','p134e_plan','p134e_begin','p134e_next']
 native_entries=['main','p111_native_args','p111_native_request','p140nb_start','p140n_args','p140n_start']
 assert set(exports+native_entries)<=names
 assert all(not p.exists()for p in [API,EMIT,BUILD,FULLBUILD])
 OUT.mkdir(parents=True)
 inputs=[pin(p)for p in [__file__,PROFILE,PROFILE.with_name('manifest.json'),parentapi,oracle,PRODUCER,PRODUCER.with_name('report.json'),RUNTIME,CARRIER,Q3,GUARD,NATIVE,HOST,ALIGNED]]
 inputs += [c[k]for c in cases for k in ('source','qbe')]
 def job(name,command,seconds):
  return dict(name=name,seconds=seconds+20,command=[sys.executable,'-B',str(GUARD),'--out',str(OUT/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','3072','--available-mib','16384','--file-mib','256','--cpu','3','--',*map(str,command)])
 def write(name,jobs,scope):
  (OUT/name).write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=inputs,jobs=jobs,scope=scope),indent=2)+'\n')
 checks=[job('source-api',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase111/check-api.py','--source',PROFILE,'--out',API,*exports],120)]
 for c in cases:
  checks.append(job('hosted-'+c['name'],[sys.executable,'-B',HOST,'--api-report',API/'report.json','--compiler-source',PROFILE,'--source',c['source']['file'],'--carrier-receipt',CARRIER,'--expected-qbe',c['qbe']['file'],'--out',ROOT/'selfhost/build/phase144'/('native-profile03-hosted-'+c['name']),'--seconds','70'],85))
 write('check-jobs.json',checks,'Source check and three complete current-final03-API product oracles. Run before the native experiment.')
 acquisition=[job('profile-emit',[sys.executable,'-B',NATIVE,'--image',PRODUCER,'--source',PROFILE,'--carrier-receipt',CARRIER,'--out',EMIT,'--seconds','600'],630),
  job('profile-machine',[sys.executable,'-B',ALIGNED,'--source',EMIT/'program.ssa','--runtime',RUNTIME,'--out',BUILD,'--seconds','90'],110)]
 write('acquire-jobs.json',acquisition,'Same final03 N2 executable as retained full-source Q3 emission. Sequential ordinary emission and aligned machine build, not a pipe wall-time comparison. Only after all small checks pass.')
 write('baseline-machine-job.json',[job('full-q3-machine',[sys.executable,'-B',ALIGNED,'--source',q3['product']['file'],'--runtime',RUNTIME,'--out',FULLBUILD,'--seconds','90'],110)],'Optional same-method Q3 machine cost. No full source request is repeated. Existing N2 piped QBE timing cannot supply isolated machine cost.')
 smokes=[]
 for c in cases:
  smokes.append(job('native-'+c['name'],[sys.executable,'-B',NATIVE,'--image',BUILD/'program','--source',c['source']['file'],'--carrier-receipt',CARRIER,'--expected-qbe',c['qbe']['file'],'--out',ROOT/'selfhost/build/phase130'/('p144-native-profile03-'+c['name']),'--seconds','60'],75))
 write('native-smoke-jobs.json',smokes,'Three complete ordinary native outputs against current final03 hosted API. All CLI entry definitions remain source-identical, but this is not execution coverage of incremental/provider modes or full language qualification.')
 report=dict(kind='phase144-final03-native-source-packaging-plan',complete=True,targetsRun=False,selected=False,inputs=inputs,
  profile=pin(PROFILE),parent=profile['parent'],producer=pin(PRODUCER),runtime=pin(RUNTIME),carrier=pin(CARRIER),
  baselineRequest=pin(Q3),baselineNativeSeconds=q3['nativeSeconds'],baselineProduct=q3['product'],baselineMachineFuture=str(FULLBUILD/'report.json'),
  profileRequestFuture=str(EMIT/'report.json'),profileMachineFuture=str(BUILD/'report.json'),profileApiFuture=str(API/'report.json'),
  nativeEntriesRetained=native_entries,ordinaryApiEntriesRetained=exports,cases=cases,
  methods='Same input features/native CLI, reduced compiler-source packaging; different source inputs. Same producer and serial runtime. Compiler/nativeSeconds and sequential machine buildSeconds separately, summed only as an explicitly assembled workflow estimate.',
  limitations=['One retained baseline plus one future profile request, not a randomized paired timing study. OS caches are not flushed.',
    'Full JS/C/test API source remains available separately; excluded APIs are not claimed supported by the native profile.',
    'No same-source algorithm gain, full conformance theorem, source-profile bootstrap fixed point or installed-selection change.'])
 (OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps(dict(complete=True,targetsRun=False,profile=pin(PROFILE),producer=pin(PRODUCER),baselineSeconds=q3['nativeSeconds'],plan=str(OUT))))
if __name__=='__main__':main()
