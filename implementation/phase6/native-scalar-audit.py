#!/usr/bin/env python3
"""Audit retained observations and source shape without running a compiler."""
import hashlib, json, pathlib, re

ROOT = pathlib.Path(__file__).resolve().parents[2]
HOME = ROOT / 'selfhost/build/phase6/campaign/native'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
prep = read(HOME / 'preparation-v1.json')
changed = [m['file'] for m in prep['modules'] if m['sha256'] != m['originalSha256']]
assert changed == ['src/back/native/bridge.bend'], changed
for m in prep['modules']:
    assert sha(HOME / 'project-v1' / m['file']) == m['sha256']
assert sha(ROOT / 'selfhost/src/back/native/bridge.bend') == prep['originalBridgeSha256']
build = read(HOME / 'attempt-v1/validation-001/report.json')
assert build['complete'] and build['pass']
check = read(HOME / 'check-v2/selected/paired.json')
assert check['selectedComplete'] and len(check['rows']) == 16
assert all(r['exactAgreement'] for r in check['rows'])
checks = {}
for name, count, passes in [('execution-v1',32,False),('native-v2',16,False),
                            ('native-v3',16,True),('failures-v1',2,True),('f32-v1',2,True)]:
    r = read(HOME / name / 'report.json')
    p = read(HOME / name / 'paired/paired.json')
    assert r['complete'] and r['pass'] == passes and len(p['rows']) == count
    assert not p['missing'] and all(x['exactAgreement'] for x in p['rows'])
    checks[name] = {'observationsPerCompiler':count,'pass':passes,'exactDifferences':0}
for name in ['boundary-v1','threads-v1']:
    r=read(HOME/name/'report.json');assert r['complete'] and r['pass'] and r['inputsVerified']
assert len(read(HOME/'threads-v1/report.json')['rows']) == 64
boundary = read(HOME/'boundary-v1/report.json')
assert len(boundary['rows']) == 3
for row in boundary['rows']:
    r = row['result'];x=r['result']
    assert (x['status'],x['phase'],x['checked'],x['exitCode']) == ('error','compile',True,1)
    assert not r['hasCode'] and not r['workFiles']
ladder=read(HOME/'emission-v1/report.json');assert ladder['complete'] and ladder['inputsVerified']
baseline={32:217752,64:396504,128:1075095,255:3716568}
sizes=[]
for row in ladder['rows']:
    r=row['result'];p=pathlib.Path(r['emitted']['file']);s=p.read_text()
    assert sha(p)==r['emitted']['sha256']
    assert (r['status'],r['phase'],r['checked']) == ('ok','compile',True)
    sig=re.search(r'^#define WL_SIG (.*)$',s,re.M)[1]
    literals=len(re.findall(r'r0 = 1ull;\s+WL_RETN\(1\);',s))
    assert literals==0
    sizes.append({'fields':row['n'],'baselineBytes':baseline[row['n']],
      'candidateBytes':p.stat().st_size,'reductionPercent':100*(1-p.stat().st_size/baseline[row['n']]),
      'wlCaseCount':s.count('WL_CASE('),'termRegisters':len(re.findall(r'\bTerm r\w*',sig)),
      'literalReturnContinuations':literals,'sha256':sha(p),'requestMs':r['requestMs']})
assert [x['fields'] for x in sizes]==[32,64,128,255]
assert all(x['wlCaseCount']==127 and x['termRegisters']==4 for x in sizes)
result={'kind':'phase6-native-scalar-file-audit','compilerExecuted':False,'pass':True,
  'productionBridgeUnchangedAtAudit':True,'changedModules':changed,'sizes':sizes,'gates':checks,
  'threadExecutions':64,'boundaryVariants':3,'knownFailedAttemptsRetained':['check-v1','execution-v1','native-v2'],
  'limits':['Selected gates only','No controlled timing','No injected allocation failure','No GPU execution'],
  'inputs':[{'file':str(p),'sha256':sha(p)} for p in [HOME/'preparation-v1.json',HOME/'candidate-v1.patch']]}
output=HOME/'audit-v1.json';assert not output.exists();output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
