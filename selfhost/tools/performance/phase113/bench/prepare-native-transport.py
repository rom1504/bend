#!/usr/bin/env python3
"""Bind qualified Phase113 N1/N2 to the unchanged three-source transport method."""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
TRANSPORT=ROOT/'selfhost/tools/performance/phase112/transport'
spec=importlib.util.spec_from_file_location('original_generation_checks',TRANSPORT/'prepare-word-generations.py')
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
m,read=old.method,old.read


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--qualification-plan',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--tag',default='p113-final31-transport01')
    a=p.parse_args()
    if a.out.exists() or not re.fullmatch(r'p113-[a-z0-9_-]+',a.tag):raise ValueError('Fresh transport manifest and lowercase p113- tag required')
    out=ROOT/'selfhost/build/phase112'/a.tag
    guard_out=ROOT/'selfhost/build/phase113'/(a.tag+'-guard')
    if out.exists() or guard_out.exists():raise ValueError('Fresh transport and guard destinations required')
    plan=read(a.qualification_plan)
    if plan.get('kind')!='phase113-native-qualification-plan':raise ValueError('Native qualification plan required')
    for item in plan['inputs']:m.verify(item)
    paths=plan['artifacts'];comparison=read(paths['comparison'])
    if not comparison.get('complete') or not comparison.get('byteExact') or m.pin(a.qualification_plan) not in comparison['inputs']:
        raise ValueError('Completed exact full-source reproduction for this plan required')
    for item in comparison['inputs']:m.verify(item)
    report_paths={name:Path(paths[name])/'report.json' for name in ['hosted','n1','self']}
    report_paths['n2']=Path(paths['self'])/'build/report.json'
    receipts={name:read(path) for name,path in report_paths.items()}
    if not all(row.get('complete') for row in receipts.values()):raise ValueError('Complete actual image acquisition receipts required')
    e1,b1,self_request,b2=[receipts[key] for key in ['hosted','n1','self','n2']]
    source=plan['source'];image1,image2=b1['binary'],b2['binary']
    if (comparison['n1']!=image1 or comparison['n2']!=image2 or comparison['hostedQbe']!=e1['product'] or
        comparison['nativeQbe']!=self_request['product'] or source not in comparison['inputs'] or
        self_request.get('imageReceipt')!=m.pin(report_paths['n1']) or self_request.get('buildReport')!=m.pin(report_paths['n2']) or
        self_request.get('image')!=image1 or self_request.get('mode')!='cache'):
        raise ValueError('Actual source/image/build/QBE lineage differs')
    for row in receipts.values():
        for item in row['inputs']:m.verify(item)
    previous_path=TRANSPORT/'manifest04.json';previous=read(previous_path)
    fixed=['kind','upstreamRevision','cases','nativeAssets','tools','scope','timer','buildPolicy','limits']
    manifest={key:copy.deepcopy(previous[key]) for key in fixed}
    manifest.update(preparedOnly=True,targetsRun=False,frozenUtc=datetime.now(timezone.utc).isoformat(),runtime=plan['runtime'])
    assets=manifest['nativeAssets']
    command=[image1['file'],'--threads','1','--gpu','off','--','phase111',source['file'],assets['base']['file'],
             'cache',assets['cache']['carrier']['file'],assets['cache']['stamp']]
    requests=[job for job in self_request['jobs'] if job['label']=='native-request']
    if len(requests)!=1 or requests[0]['command']!=command or requests[0].get('status')!='complete':
        raise ValueError('Exact original native command and assets required')
    old.checked_build(m.pin(report_paths['n1']),image1,e1['product'],manifest)
    old.checked_build(m.pin(report_paths['n2']),image2,self_request['product'],manifest)
    if any(e1['product'][key]!=self_request['product'][key] for key in ['bytes','sha256']):
        raise ValueError('Actual full-source QBE hashes differ')
    manifest['roles']=dict(phase111=dict(binary=image1,source=source,generation='Selected Phase113 N1; legacy phase111 key.'),
                           phase112=dict(binary=image2,source=source,generation='Selected Phase113 N2; legacy phase112 key.'),
                           upstream=copy.deepcopy(previous['roles']['upstream']))
    manifest['lineage']=dict(comparison='Same selected Phase113 source, N1 versus N2 versus pinned upstream.',
          roleKeys=dict(phase111='Phase113 N1',phase112='Phase113 N2',upstream='pinned TypeScript/Bun C compiler'),
          sameCompilerSource=source,n1Qbe=e1['product'],n2Qbe=self_request['product'],qbeByteExact=True,
          ratioKeys={'phase112/phase111':'N2 time / N1 time','phase112/upstream':'N2 time / upstream time','phase111/upstream':'N1 time / upstream time'},
          limits='Three reused one-shot sources; native QBE versus upstream C requests. Normal cached-runtime QBE build versus full Clang O2 build. No same-format throughput or program-speed claim.')
    manifest['roleAcquisition']=dict(phase111=dict(emission=m.pin(report_paths['hosted']),build=m.pin(report_paths['n1']),apiReport=plan['apiReport']),
          phase112=dict(selfRequest=m.pin(report_paths['self']),build=m.pin(report_paths['n2'])),comparison=m.pin(paths['comparison']))
    manifest['inputs']=[m.pin(__file__),m.pin(TRANSPORT/'run.py'),m.pin(TRANSPORT/'prepare-word-generations.py'),
                        m.pin(a.qualification_plan),plan['sourceManifest'],plan['runtimeReport']]
    manifest['derivation']=dict(previous=m.pin(previous_path),preparer=m.pin(__file__),runner=m.pin(TRANSPORT/'run.py'),
          change='Replace native roles with actual selected Phase113 N1/N2 and their product runtime. Preserve all three sources/output oracles, assets, upstream, timer, schedule, build commands and limits. External comparison receipt authenticates the actual staged-v2/native chain; no old receipt is rewritten.')
    for item in m.pins(manifest):m.verify(item)
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(manifest,indent=2)+'\n')
    py=[sys.executable,'-B']
    guard=py+[str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(guard_out),
          '--seconds','90','--rss-mib','4096','--available-mib','16384','--file-mib','128','--cpu','3','--',*py,
          str(TRANSPORT/'run.py'),'--manifest',str(a.out.resolve()),'--out',str(out),'--rounds','3','--modes','cache']
    print(json.dumps(dict(complete=True,targetsRun=False,manifest=m.pin(a.out),rootGuardCommand=guard)))


if __name__=='__main__':main()
