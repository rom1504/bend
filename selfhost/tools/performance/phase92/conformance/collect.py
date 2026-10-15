#!/usr/bin/env python3
"""Offline native69/rejection result collector; no compiler or program execution."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from prepare import pin,read,write

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert not a.out.exists()
    plan=read(a.plan);root=a.plan.resolve().parent
    for x in plan['inputs']:assert pin(x['file'])==x
    rows=[];all_passed=True
    expected={x['id'] for x in plan['eligible']};reference=read(plan['reference']['file'])
    old={x['id']:x for x in reference['results'] if x['lane']=='native'}
    for role in ['b1','b2']:
        report_path=root/role/'report.json';r=read(report_path);guard_path=root/(role+'-guard')/'process.json';g=read(guard_path)
        assert r['finished'] and not r['changedInputs'] and not r['identity']['adapterChangedDuringRun'] and not r['identity']['changedArtifacts']
        assert r['identity']['artifacts']['plan']['sha256']==pin(a.plan)['sha256']
        assert r['identity']['adapter']=='phase92-native-host-'+role
        assert {x['id'] for x in r['results']}==expected and len(r['results'])==69
        assert not g.get('stoppedFor') and g.get('returncode') in (0,1)
        passed=r['selectedComplete'] and r['summary']['statuses']=={'pass':69} and g['returncode']==0
        observed=[]
        for x in r['results']:
            now=x.get('result',{});before=old[x['id']]['result']
            fields=['status','phase','checked','typeAccepted','exitCode','stdout','stderr','output']
            same=all(now.get(k)==before.get(k) for k in fields)
            observed.append(dict(id=x['id'],status=x['status'],sameHistoricalObservedFields=same,
                comparedFields=fields,generated=now.get('nativeHost',{}).get('output')))
            passed=passed and same
        rows.append(dict(role=role,passed=passed,report=pin(report_path),guard=pin(guard_path),
            statuses=r['summary']['statuses'],observations=observed));all_passed=all_passed and passed
    diagnostic_path=root/'diagnostics/report.json';d=read(diagnostic_path)
    diagnostic_guard=root/'diagnostics-guard/process.json';dg=read(diagnostic_guard)
    assert not dg.get('stoppedFor') and dg.get('returncode') in (0,1)
    diagnostic_pass=d['complete'] and d['passed'] and d['inputsUnchanged'] and len(d['rows'])==6 and dg['returncode']==0
    all_passed=all_passed and diagnostic_pass
    for x in plan['inputs']:assert pin(x['file'])==x
    a.out.parent.mkdir(parents=True,exist_ok=True)
    result=dict(kind='phase92-native-conformance-results',complete=True,passed=all_passed,dataOnly=True,
        targetExecuted=False,method=pin(__file__),plan=pin(a.plan),roles=rows,
        diagnostics=dict(passed=diagnostic_pass,report=pin(diagnostic_path),guard=pin(diagnostic_guard)),
        excluded=plan['excluded'],counts=dict(originalNative100=100,eligiblePerRole=69,excludedPerRole=31,
            executionObservations=138,rejectionObservations=6),inputsUnchanged=True,
        scope='Native-host B1/B2 only: original69 golden execution outputs and3rejections each.31 additional-import/provider fixtures remain untested. No full native100/frontend/JS-target or parallel/GPU conformance claim.')
    write(a.out,result);print(json.dumps(dict(complete=True,passed=all_passed,out=str(a.out))))
    if not all_passed:sys.exit(1)

if __name__=='__main__':main()
