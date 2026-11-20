"""Freeze a four-role portfolio recipe and verify each relink independently."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build/phase198'
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
import bench as B

def prepare(native,source,out):
    assert os.sched_getaffinity(0)=={3}
    out=out.resolve()
    out.mkdir(parents=True)
    assert not list(out.iterdir())
    held=B.read(HERE/'portfolio-pins.json')
    for pin in held.values(): B.verify(pin)
    proof=B.read(held['summary']['file'])
    assert proof['complete'] and proof['subsets']['all']['roles']['live']['overBaseline']['geomean']<1
    assert proof['liveRuntime']==held['live'] and proof['originalRuntime']==held['original']
    candidate=B.read(native)
    source=B.pin(source)
    role=candidate['roles']['candidate']
    assert role['compilerSource']==source and role['stage']=='N1' and role['target']=='x86'
    assert role['runtime']==held['original']
    for item in candidate['inputs']: B.verify(item)
    incumbent=B.read(held['phase197']['file'])
    assert incumbent['roles']['candidate']['compilerSource']!=source
    mature=B.read(held['matureC']['file'])
    refs={c['id']:c for c in mature['cases']}
    old={c['id']:c for c in incumbent['cases']}
    products={c['id']:c for c in candidate['cases']}
    assert len(refs)==len(old)==len(products)==45 and old.keys()==products.keys()==refs.keys()
    new_role=dict(role,runtime=held['live'],policy='ordinary-serial-split-live-descriptor',
        status='portfolio-N1-same-object-live-runtime',inputs=[*role['inputs'],B.pin(native),B.pin(__file__),B.pin(HERE/'portfolio-pins.json'),*held.values()])
    recipe=dict(kind='programs',cwd=str(ROOT),catalog=str(ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'),reference='c',
        roles=dict(c=mature['roles']['c'],phase197=incumbent['roles']['candidate'],candidate=role,live=new_role),cases=[])
    report=dict(complete=False,native=B.pin(native),source=source,inputs=held,method=B.pin(__file__),cases={})
    save=lambda:B.save(out/'report.json',report)
    save()
    for name,inc in old.items():
        case,ref=products[name],refs[name]
        assert case['point']==inc['point']==ref['point'] and case['source']==inc['source']==ref['source']
        point=case['point']
        archive=case['products']['candidate']
        production_pin=B.pin(Path(archive['artifact']['file']).with_name('report.json'))
        assert production_pin in archive['inputs']
        produced=B.read(production_pin['file'])
        obj=produced['object']
        assert produced['complete'] and not produced['changedInputs'] and produced['assemblerSkipped'] and produced['emit']=='object'
        assert produced['binary']==archive['artifact'] and obj==archive['generatedSource'] and produced['runtime']==held['original']
        for item in [obj,archive['artifact'],case['source'],case['expectedFile']]:B.verify(item)
        jobs=[j for j in produced['jobs'] if j['label']=='link']
        assert len(jobs)==1
        cmd=jobs[0]['command']
        assert all(cmd.count(path)==1 for path in [held['original']['file'],obj['file'],archive['artifact']['file']])
        folder=out/'cases'/name
        folder.mkdir(parents=True)
        for variant,runtime in [('baseline',held['original']),('live',held['live'])]:
            link=cmd.copy()
            link[link.index(held['original']['file'])]=runtime['file']
            link[link.index(archive['artifact']['file'])]=str(folder/variant)
            subprocess.run(link,check=True,timeout=20,capture_output=True)
        original=B.pin(folder/'baseline')
        assert original['sha256']==archive['artifact']['sha256'] and original['bytes']==archive['artifact']['bytes']
        live=dict(archive,artifact=B.pin(folder/'live'))
        arms=dict(c=ref['products']['c'],phase197=inc['products']['candidate'],candidate=archive,live=live)
        checks={}
        for alias,product in arms.items():
            B.verify(product['artifact'])
            obs=dict(point,repetitions=int(point['repetitions']>0),warmups=0)
            args=[product['artifact']['file'],*B.native_runtime_arguments(product),str(obs['repetitions']),'0',*map(str,point['runtimeArgs'])]
            child=B.child(args,folder/('oracle-'+alias),time.monotonic()+30,str(ROOT))
            assert not child['timedOut'] and child['stdout']['bytes']<=128+len(point['expectedStdout'].encode())
            elapsed=B.observation(Path(child['stdout']['file']).read_bytes(),Path(child['stderr']['file']).read_bytes(),child['exitCode'],obs,child['seconds'])
            checks[alias]=dict(repetitions=obs['repetitions'],elapsedMs=elapsed,process=child)
        recipe['cases'].append(dict(id=name,products=arms))
        report['cases'][name]=dict(object=obj,production=production_pin,base=archive['artifact'],originalRelink=original,
                                   live=live['artifact'],oracles=checks)
        save()
    B.save(out/'recipe.json',recipe)
    B.freeze(out/'recipe.json',out/'manifest.json')
    report.update(complete=True,manifest=B.pin(out/'manifest.json'))
    save()
    print(json.dumps(dict(roles=list(recipe['roles']),cases=len(recipe['cases']),independentObservations=4*len(recipe['cases']),manifest=report['manifest'])))

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--native',required=True,type=Path)
    p.add_argument('--source',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path)
    a=p.parse_args()
    prepare(a.native.resolve(),a.source.resolve(),a.out)
