"""Analyze completed matched-source wide+scalar-selector composition."""
import argparse,hashlib,importlib.util,json,re,statistics as S
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
spec=importlib.util.spec_from_file_location('probe',Path(__file__).resolve().parent.parent/'reader-identity-probe.py')
probe=importlib.util.module_from_spec(spec);spec.loader.exec_module(probe)
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--report',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
r=json.loads(a.report.read_text());assert r['complete']and r['passed']and not r['changedInputs']and r['cleanRounds']==3 and len(r['rows'])==12
assert all(x['correct']and x['mode']=='clean'for x in r['rows'])
out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase131')
result=dict(complete=True,inputs=[pin(__file__),pin(a.report)],cases=[],code=[],scope='Same exact fused selector source under frozen-final vs wider checked producer; one-entry leaf and forced64collision stress kept separate. No whole compiler, upstream or new native qualification claim.')
for name in sorted({x['workload']for x in r['rows']}):
 groups={role:[x for x in r['rows']if x['workload']==name and x['variant']==role]for role in ['baseline','candidate']}
 raw={role:[x['wallSeconds']for x in xs]for role,xs in groups.items()};med={role:S.median(xs)for role,xs in raw.items()}
 inner={role:[int(Path(x['stdout']['file']).read_text().splitlines()[-1])for x in xs]for role,xs in groups.items()}
 pairs=[next(x['wallSeconds']for x in groups['candidate']if x['round']==i)/next(x['wallSeconds']for x in groups['baseline']if x['round']==i)for i in range(1,4)]
 result['cases'].append(dict(name=name,medianSeconds=med,rawSeconds=raw,internalMilliseconds=inner,pairedRatios=pairs,candidateOverBaseline=med['candidate']/med['baseline'],percentTimeReduction=100*(1-med['candidate']/med['baseline'])))
for role,pth in [('baseline','selfhost/build/phase118/p131-selector-ceiling03/selector-fused.ssa'),('candidate','selfhost/build/phase118/p131-wide-selector-emit01/selector-fused.ssa')]:
 path=ROOT/pth;result['inputs'].append(pin(path));functions=[];callers=[]
 for symbol,name,body in probe.functions(path):
  calls=[probe.decode(x)for x in re.findall(r'call \$(\w+)\(',body)]
  if '$direct.p131sc_bucket'in calls:callers.append(dict(name=name,symbol=symbol,sites=calls.count('$direct.p131sc_bucket')))
  if symbol.startswith('p113d_')and name.endswith('.p131sc_bucket'):
   functions.append(dict(name=name,lines=len(body.splitlines()),sha256=hashlib.sha256(body.encode()).hexdigest(),takes=body.count('call $p111_rt_take('),sinks=body.count('call $p111_rt_sink('),borrowReads=body.count('call $p118_rt_borrow_fields(')))
 result['code'].append(dict(role=role,source=pin(path),functions=functions,publicBucketCallers=callers))
out.mkdir();(out/'report.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,cases=result['cases'])))
