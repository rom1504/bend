#!/usr/bin/env python3
"""Run the maintained 26-row JS census through an explicit checked direct backend."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
sys.path.insert(0,str(HERE.parent/'programs'))
from support import ExecutionGuard, save


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('attempt',type=Path)
    parser.add_argument('out',type=Path)
    parser.add_argument('--plan-only',action='store_true')
    parser.add_argument('--node',type=Path,default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
    args=parser.parse_args()
    attempt=args.attempt.resolve(strict=True);out=args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase54')
    inputs={}
    def pin(file,want=None):
        file=Path(file).resolve(strict=True)
        row=dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest(),bytes=file.stat().st_size)
        if want:
            assert row['sha256']==want['sha256'],str(file)
            if 'bytes' in want:assert row['bytes']==want['bytes'],str(file)
        if str(file) in inputs:assert row==inputs[str(file)]
        inputs[str(file)]=row;return row
    def read(file):pin(file);return json.loads(Path(file).read_text())
    def audit(value):
        if isinstance(value,list):
            for item in value:audit(item)
        elif isinstance(value,dict):
            file=value.get('file',value.get('canonicalPath',value.get('path')))
            if isinstance(file,str) and 'sha256' in value:pin(file,value)
            # Snapshot original paths document acquisition provenance. They are
            # live development files, not inputs consumed by this checked run.
            for key,child in value.items():
                if key!='original':audit(child)
    pin(__file__);pin(HERE.parent/'phase52/direct-conformance.py');pin(HERE.parent/'phase52/direct-conformance-adapter.mjs')
    pin(HERE.parent/'programs/support.py');pin(args.node)
    selected=read(attempt/'attempt.json')
    assert selected['checked'] and selected['config']['strictExact']
    assert selected['node']['version']=='v24.18.0';pin(args.node,selected['node'])
    for row in selected['snapshot']['sources']:
        assert row['original']['sha256']==row['frozen']['sha256']
    audit(selected)
    host=Path(selected['snapshot']['root']).resolve(strict=True)
    target=host/'tools/conformance/target.mjs';pin(target)
    direct=host/'src/runtime/js/direct.mjs';pin(direct)
    upstream=ROOT/'selfhost/.bootstrap/upstream-phase23'
    compiler=read(host/'src/compiler.json')
    assert compiler['upstream']=='018751270e800bc222a93dad7f257083ee53a5f7'
    parent=read(ROOT/'selfhost/build/phase45/qualification23/backend/pilot.json')
    assert parent['expectedRows']==81 and parent['expectedCounts']=={'pass':69,'not-applicable':8,'fail':4}
    historical=read(parent['historicalRows']['file'])
    pin(parent['historicalRows']['file'],parent['historicalRows'])
    batches=[b for b in parent['batches'] if b['name'] in ['boundary-js','pilot-js']]
    cases=[case for batch in batches for case in batch['cases']]
    assert len(cases)==26 and len({case['id'] for case in cases})==26
    assert all(case['lanes']==['js'] for case in cases)
    for case in cases:pin(upstream/'tests'/case['id'])
    out.mkdir(parents=True)
    adapter=out/'direct-conformance-adapter.mjs'
    template=(HERE.parent/'phase52/direct-conformance-adapter.mjs').read_text()
    needle='fs.realpathSync(process.env.BEND_DIRECT_ATTEMPT)'
    assert template.count(needle)==1
    adapter.write_text(template.replace(needle,'fs.realpathSync('+json.dumps(str(attempt))+')'))
    pin(adapter)
    config=dict(upstream=str(upstream),candidateAdapter=str(adapter),cases=cases,
        jobs=1,workerMode='isolated',timeoutMs=30000,heapMb=1024,stackKb=4096,
        rssLimitMb=1024,retain='all',cpu=3)
    save(out/'config.json',config);pin(out/'config.json')
    command=['taskset','-c','3',str(args.node.resolve()),'--stack-size=4096',
        '--max-old-space-size=1024',str(target),str(out/'config.json'),str(out/'selected')]
    report=dict(kind='phase54-direct-js-census',complete=False,executed=False,
        attempt=pin(attempt/'attempt.json'),api=pin(selected['api']['file']),
        directRuntime=pin(direct),command=command,expectedRows=26,
        selection=dict(boundaries=4,namespaceRepresentatives=22),historicalJsRows=[
            r for r in historical if r['lane']=='js'],inputs=list(inputs.values()),
        scope='The unchanged maintained JS selection and fixture oracles, on a new explicitly selected backend. Not the 81-row native/interpreter census, full frontend conformance, or a speed sample.',**{'pass':False})
    save(out/'report.json',report)
    if args.plan_only:
        report['complete']=True;report['plannedOnly']=True
    else:
        environment={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['NODE_OPTIONS','NODE_PATH']}
        with ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            process=guard.run(command,out/'process',time.monotonic()+900,env=environment)
        report['executed']=True;report['process']=process
        paired=read(out/'selected/paired.json')
        report['paired']=pin(out/'selected/paired.json')
        rows=paired.get('rows',[])
        report['rows']=rows
        report['complete']=bool(process.get('returncode') in [0,1] and not process.get('stoppedFor') and
            not process.get('error') and len(rows)==26 and not paired.get('missing') and not paired.get('error'))
        report['exactAgreement']=sum(bool(r['exactAgreement']) for r in rows)
        report['semanticAgreement']=sum(bool(r['semanticAgreement']) for r in rows)
        report['candidateVerdicts']={status:sum(r['candidateVerdict']==status for r in rows)
            for status in sorted({r['candidateVerdict'] for r in rows})}
        report['referenceVerdicts']={status:sum(r['referenceVerdict']==status for r in rows)
            for status in sorted({r['referenceVerdict'] for r in rows})}
        report['oraclePass']=bool(paired.get('candidateSelectedComplete'))
        report['referenceOraclePass']=bool(paired.get('referenceSelectedComplete'))
        report['pass']=report['complete'] and report['semanticAgreement']==26 and report['oraclePass'] and report['referenceOraclePass']
        report['meaning']='pass requires all 26 semantic observations to agree and both sides to satisfy unchanged fixture judging; N/A remains N/A. Exact diagnostic agreement is reported separately.'
    for row in list(inputs.values()):pin(row['file'],row)
    report['inputs']=list(inputs.values());report['inputsUnchanged']=True
    save(out/'report.json',report)
    print(json.dumps({key:report.get(key) for key in ['complete','pass','plannedOnly','executed','expectedRows','exactAgreement','semanticAgreement','oraclePass']}))
    return 0 if args.plan_only or report['pass'] else 1


if __name__=='__main__':
    raise SystemExit(main())
