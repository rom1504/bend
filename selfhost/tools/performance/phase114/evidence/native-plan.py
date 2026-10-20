#!/usr/bin/env python3
"""Derive only Phase114 paths/time limits from the unchanged Phase113 gate."""
import argparse
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import re
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
BINDING=HERE/'native-binding01.json'


def load(name,path,expected):
    raw=path.read_bytes()
    if len(raw)!=expected['bytes'] or hashlib.sha256(raw).hexdigest()!=expected['sha256']:
        raise ValueError('Frozen base method changed: '+str(path))
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result)
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--api',type=Path,required=True);p.add_argument('--source',type=Path,required=True)
    p.add_argument('--runtime',type=Path,default=ROOT/'selfhost/build/phase113/runtime-products-build01/runtime.o')
    p.add_argument('--tag',required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--hosted-seconds',type=int,default=900);p.add_argument('--native-seconds',type=int,default=900)
    a=p.parse_args();out=a.out.resolve()
    if (out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase114') or
        not re.fullmatch(r'p114-[a-z0-9_-]+',a.tag) or min(a.hosted_seconds,a.native_seconds)<=0):
        raise ValueError('Fresh Phase114 plan, lowercase p114- tag and positive limits required')
    binding=json.loads(BINDING.read_text())
    for row in binding['methods']:
        raw=(ROOT/row['file']).read_bytes()
        if len(raw)!=row['bytes'] or hashlib.sha256(raw).hexdigest()!=row['sha256']:
            raise ValueError('Frozen qualification dependency changed: '+row['file'])
    expected=binding['methods'][0];base=load('phase114_exact_native_gate',ROOT/expected['file'],expected)
    base_path=out.with_name(out.stem+'-base.json')
    if base_path.exists():raise ValueError('Fresh base-plan evidence required')
    # The original preparer enforces p113- tags. Its never-executed base output
    # graph is retained, then an explicit output-path map derives this plan.
    base_tag='p113-adapter-'+a.tag
    saved=sys.argv
    try:
        sys.argv=[str(ROOT/expected['file']),'prepare','--api',str(a.api.resolve()),'--source',str(a.source.resolve()),
                  '--runtime',str(a.runtime.resolve()),'--tag',base_tag,'--out',str(base_path)]
        with contextlib.redirect_stdout(io.StringIO()):base.main()
    finally:sys.argv=saved
    original=base.read(base_path)
    artifacts={name:str(Path(path).with_name(Path(path).name.replace(base_tag,a.tag,1)))
               for name,path in original['artifacts'].items()}
    artifacts['comparison']=str(ROOT/'selfhost/build/phase113'/(a.tag+'-qbe-comparison')/'report.json')
    if any(Path(path).exists() for path in artifacts.values()) or Path(artifacts['comparison']).parent.exists():
        raise ValueError('Derived artifact destination already exists')
    mapping={**{path:artifacts[name] for name,path in original['artifacts'].items()},str(base_path):str(out)}
    def replace(value):
        if isinstance(value,str):
            for before,after in sorted(mapping.items(),key=lambda item:len(item[0]),reverse=True):
                if value==before or value.startswith(before+'/'):return after+value[len(before):]
            return value
        if isinstance(value,list):return [replace(item) for item in value]
        if isinstance(value,dict):return {key:replace(item) for key,item in value.items()}
        return value
    plan=replace(copy.deepcopy(original));changes=[]
    for job in plan['jobs']:
        if job['name']=='full-hosted-array-emission':
            changes.append(dict(job=job['name'],field='seconds',before=job['seconds'],after=a.hosted_seconds));job['seconds']=a.hosted_seconds
        elif job['name']=='native-self-emission-n2-build':
            index=job['command'].index('--seconds')+1;prior=int(job['command'][index])
            changes.append(dict(job=job['name'],field='native request --seconds',before=prior,after=a.native_seconds))
            job['command'][index]=str(a.native_seconds)
            cap=job['seconds']+a.native_seconds-prior
            changes.append(dict(job=job['name'],field='seconds',before=job['seconds'],after=cap));job['seconds']=cap
    total=sum(job['seconds'] for job in plan['jobs'])+60
    plan['rootGuardCommand'][plan['rootGuardCommand'].index('--seconds')+1]=str(total)
    plan['guard']['seconds']=total
    plan['inputs'] += [base.pin(base_path),base.pin(Path(__file__).resolve()),base.pin(BINDING)]
    plan['derivation']=dict(kind='phase114-native-path-time-adapter',targetsRun=False,
        method=base.pin(Path(__file__).resolve()),binding=base.pin(BINDING),baseMethod=base.pin(ROOT/expected['file']),basePlan=base.pin(base_path),
        outputPathMap=[dict(before=before,after=after) for before,after in mapping.items()],timeLimitChanges=changes,
        unchanged='Exact source/API/runtime admission, array pipeline, admitted renderer, native entry, methods, flags, Base/cache, ownership/IR gates, N1/N2 raw QBE comparison, focused19/full45 and their oracles remain unchanged. Original phase113 plan kind is retained for its existing verifier/comparer. Base plan is provenance only; execute derived plan jobs.')
    for row in plan['inputs']:base.verify(row)
    out.write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,plan=base.pin(out),basePlan=base.pin(base_path),rootGuardCommand=plan['rootGuardCommand'])))


if __name__=='__main__':main()
