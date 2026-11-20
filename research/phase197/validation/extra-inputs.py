"""Check actual candidate binaries against the independent C backend on new inputs."""
import argparse
import json
from pathlib import Path
import sys
import time

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'research/phase196/screen'))
from regions import digest,read
from measure import execute,checked_tool

POINTS={
    'editdist': [(0,1),(1,4294967295),(3,5),(2,16)],
    'local-pair': [(0,1),(1,4294967295),(3,5),(2,16)],
    'bst': [(0,0),(1,17),(17,4294967295),(59,22)],
    'mandelbrot': [(0,5),(1,17),(3,123),(2,29)],
    'local-fold': [(0,1),(1,17),(64,123),(129,29)],
}


def main(args):
    refs={c['id']:c for c in read(args.references)['cases']}
    args.out.mkdir(parents=True,exist_ok=False)
    roles={}
    for label,path,role in args.manifest:
        manifest=read(path)
        assert label not in roles and role in manifest['roles']
        roles[label]=(path,role,{c['id']:c for c in manifest['cases']})
    common=set.intersection(*(set(cases) for _,_,cases in roles.values()))
    assert common and all(common==set(cases) for _,_,cases in roles.values())
    report=dict(complete=False,methods={str(p):digest(p) for p in [Path(__file__),ROOT/'research/phase196/screen/measure.py']},
                references=digest(args.references),manifests={k:digest(v[0]) for k,v in roles.items()},rows=[])
    started=time.monotonic()
    for case in sorted(common):
        ref=refs[case]; expected_point=ref['point']['runtimeArgs']; c=ref['products']['c']
        points=[expected_point,*POINTS[ref['family']]]
        assert len(points)==len(set(map(tuple,points)))
        for i,inputs in enumerate(points):
            reps=int(i==0)
            oracle,expected=execute(checked_tool(c['artifact']),inputs,reps,0,
                    ref['point']['expectedStdout'] if i==0 else None,c['runtimeArgumentConvention'])
            obs={}
            for label,(_,role,cases) in roles.items():
                record=cases[case]
                assert record['source']==ref['source'] and record['expectedFile']==ref['expectedFile']
                product=record['products'][role]
                observed,_=execute(checked_tool(product['artifact']),inputs,reps,0,expected,product['runtimeArgumentConvention'])
                obs[label]=dict(binary=product['artifact'],output=observed['stdout'])
            report['rows'].append(dict(case=case,inputs=inputs,cBinary=c['artifact'],cOutput=oracle['stdout'],observations=obs))
            (args.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    report.update(complete=True,seconds=time.monotonic()-started,points=len(report['rows']),checks=len(report['rows'])*len(roles))
    (args.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('Complete output comparisons:',report['checks'])


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--references',type=Path,default=ROOT/'selfhost/build/phase195/references01/manifest.json')
    p.add_argument('--manifest',nargs=3,action='append',required=True,metavar=('LABEL','PATH','ROLE'))
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    a.manifest=[(label,Path(path),role) for label,path,role in a.manifest]
    main(a)
