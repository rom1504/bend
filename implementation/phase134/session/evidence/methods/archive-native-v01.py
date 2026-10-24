#!/usr/bin/env python3
"""Archive compact experimental-session evidence, never native binaries or IR."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import shutil

ROOT=Path(__file__).resolve().parents[5]


def pin(path):
    path=Path(path).resolve(); data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--result',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--guard',type=Path)
    ap.add_argument('--prior-result',type=Path)
    ap.add_argument('--prior-guard',type=Path)
    ap.add_argument('--extra-guard',type=Path,action='append',default=[])
    a=ap.parse_args(); out=a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'implementation/phase134'):
        raise ValueError('Fresh implementation/phase134 evidence directory required')
    result=json.loads(a.result.read_text()); plan=json.loads(Path(result['plan']['file']).read_text())
    out.mkdir(parents=True); records=[]
    def copy(source,dest):
        source=Path(source); dest=out/dest; dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(source,dest); records.append(dict(source=pin(source),archive=pin(dest)))
    copy(a.result,'native/report.json')
    copy(result['plan']['file'],'native/plan.json')
    for name in ['checkedApi','finite','bridge','sourceManifest','oracleQualification']:
        copy(plan[name]['file'],'checks/'+name+'.json')
    copy(plan['build'],'native/build.json')
    if plan['acquisition']!=plan['build']: copy(plan['acquisition'],'native/acquisition.json')
    build=json.loads(Path(plan['build']).read_text())
    if 'warningReview' in build: copy(build['warningReview']['file'],'native/warning-review.json')
    for role in ['acquisition','build']:
        for name in ['compiler.stderr','qbe.stderr','qbe.stdout','assemble.stdout','assemble.stderr','link.stdout','link.stderr']:
            path=Path(plan[role]).parent/name
            if path.is_file() and path.stat().st_size<65536: copy(path,'native/'+role+'-logs/'+name)
    if a.guard:
        for name in ['report.json','process.json','inputs.json','method.json','stdout','stderr','stdout.log','stderr.log']:
            path=a.guard/name
            if path.is_file() and path.stat().st_size<1048576: copy(path,'native/guard/'+name)
    if a.prior_result:
        prior=json.loads(a.prior_result.read_text());copy(a.prior_result,'prior-attempt/report.json')
        prior_plan=json.loads(Path(prior['plan']['file']).read_text())
        copy(prior['plan']['file'],'prior-attempt/plan.json')
        for name in ['tiny','invalid']:copy(prior_plan[name]['file'],'prior-attempt/'+name+'.bend')
        for path in sorted(a.prior_result.parent.rglob('*')):
            if path.is_file() and path.name in ['stdout','stderr'] and path.stat().st_size<65536:
                copy(path,'prior-attempt/logs/'+str(path.relative_to(a.prior_result.parent)))
    if a.prior_guard:
        for name in ['report.json','process.json','inputs.json','method.json','stdout','stderr','stdout.log','stderr.log']:
            path=a.prior_guard/name
            if path.is_file() and path.stat().st_size<1048576:copy(path,'prior-attempt/guard/'+name)
    for guard in a.extra_guard:
        for name in ['report.json','process.json','inputs.json','method.json','stdout.log','stderr.log']:
            path=guard/name
            if path.is_file() and path.stat().st_size<1048576:copy(path,'acquisition-guards/'+guard.name+'/'+name)
    for path in sorted(a.result.parent.rglob('*')):
        if path.is_file() and path.name in ['stdout','stderr'] and path.stat().st_size<65536:
            copy(path,'native/logs/'+str(path.relative_to(a.result.parent)))
    for case in plan['cases']:
        for side in ['a','b']: copy(case[side]['file'],'fixtures/'+case['name']+'-'+side+'.bend')
    for name in ['tiny','invalid']: copy(plan[name]['file'],'fixtures/'+name+'.bend')
    source=Path(plan['source']['file']); data=source.read_bytes()
    if pin(source)!=plan['source']: raise ValueError('Compiler source changed')
    target=out/'compiler-source04.bend.gz'; target.write_bytes(gzip.compress(data,compresslevel=9,mtime=0))
    if gzip.decompress(target.read_bytes())!=data: raise ValueError('Source archive failed byte round-trip')
    records.append(dict(source=plan['source'],archive=pin(target),encoding='gzip',roundTripExact=True))
    for name in ['native-run-v01.py','native-run-v02.py','native-run-v03.py','native-run-v04.py','native-experiment.md','archive-native-v01.py']:
        copy(Path(__file__).parent/name,'methods/'+name)
    manifest=dict(complete=True,experimental=True,nativeSessionComplete=result['complete'],records=records,
        totalArchiveBytes=sum(r['archive']['bytes'] for r in records),
        scope='Compact evidence and exact checked experimental source; excludes native binaries, generated APIs, QBE and assembly. No bootstrap qualification or installed selection change.')
    (out/'archive.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(complete=True,files=len(records),bytes=manifest['totalArchiveBytes'])))


if __name__=='__main__': main()
