"""Analyze completed wide-record pairs and preserve selected actual QBE shapes."""
import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import statistics as S

ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('probe',HERE.parent/'reader-identity-probe.py')
probe=importlib.util.module_from_spec(spec);spec.loader.exec_module(probe);pin=probe.pin
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--report',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
r=json.loads(a.report.read_text());assert r['complete'] and r['passed'] and not r['changedInputs']
assert r['modes']==['clean'] and r['cleanRounds']==5 and len(r['rows'])==20
assert all(x['correct'] and not x['diagnosticRuntime'] for x in r['rows'])
result=dict(complete=True,targetsRun=False,inputs=[pin(Path(__file__)),pin(a.report)],cases=[],code=[],
    scope='Five paired clean observations of two extracted whole scalar queries, not whole compiler speed. '
          'Original and candidate retain identical source inputs/runtime and independent ordinary output oracles. '
          'Wider source is checked but not native-self-host-qualified or installed.')
for name in sorted({x['workload']for x in r['rows']}):
    groups={role:[x for x in r['rows'] if x['workload']==name and x['variant']==role] for role in ['baseline','candidate']}
    assert all(len(xs)==5 for xs in groups.values())
    samples={role:[x['wallSeconds']for x in xs]for role,xs in groups.items()}
    internal={role:[int(Path(x['stdout']['file']).read_text().splitlines()[-1])for x in xs]for role,xs in groups.items()}
    med={role:S.median(xs)for role,xs in samples.items()};ms={role:S.median(xs)for role,xs in internal.items()}
    paired=[next(x['wallSeconds']for x in groups['candidate']if x['round']==i)/next(x['wallSeconds']for x in groups['baseline']if x['round']==i)for i in range(1,6)]
    result['cases'].append(dict(name=name,medianSeconds=med,rawSeconds=samples,internalMilliseconds=internal,
        internalMedianMilliseconds=ms,candidateOverBaseline=med['candidate']/med['baseline'],
        percentTimeReduction=100*(1-med['candidate']/med['baseline']),pairedRatios=paired,
        internalCandidateOverBaseline=ms['candidate']/ms['baseline'],
        allPairsFaster=all(x<1 for x in paired),minimumInternalMilliseconds=min(min(x)for x in internal.values())))
for role in ['baseline','candidate']:
    path=ROOT/f'selfhost/build/phase118/p131-wide-{role}-emit01/compiler-kdef.ssa'
    code=dict(role=role,source=pin(path),functions=[]);result['inputs'].append(pin(path))
    for symbol,name,body in probe.functions(path):
        if symbol.startswith('p113d_') and any(name.endswith('.'+s)for s in ['p131w_query','p131w_query9','p131w_query16','p131w_once','p131w_repeat']):
            code['functions'].append(dict(name=name,lines=len(body.splitlines()),sha256=hashlib.sha256(body.encode()).hexdigest(),
                calls=dict(Counter(probe.decode(x)for x in re.findall(r'call \$(\w+)\(',body)))))
    result['code'].append(code)
out.mkdir();(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,cases=[dict(name=x['name'],ratio=x['candidateOverBaseline'],percentLess=x['percentTimeReduction'])for x in result['cases']])))
