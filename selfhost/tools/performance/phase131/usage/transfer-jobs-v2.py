"""Plan builds for already checked selector/projection transfer emissions."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[5]
def pin(path):
    path=Path(path).resolve();b=path.read_bytes()
    return dict(file=str(path),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--emission',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    r=json.loads(a.emission.read_text());assert r['complete'];out.mkdir(parents=True)
    manifest_file=ROOT/'selfhost/tools/performance/phase131/usage/final-transfer-cases.json';m=json.loads(manifest_file.read_text())
    expected={x['name']:x for x in m['cases']};assert set(x['name'] for x in r['cases'])==set(expected)
    inputs=[pin(__file__),pin(a.emission),*r['inputs'],pin(manifest_file),r['runtime'],
        pin(ROOT/'selfhost/tools/performance/phase111/guard.py'),pin(ROOT/'selfhost/tools/performance/phase123/build-aligned.py')]
    jobs=[];cases=[]
    for x in r['cases']:
        name=x['name'];c=expected[name];assert x['source']==c['source'] and x['verified'] and x['parentVerified']
        oracle=c['expected'];stdout=oracle
        if Path(oracle['file']).suffix=='.json':
            o=json.loads(Path(oracle['file']).read_text());assert o['status']==0 and o['stderr']==''
            f=out/(name+'.stdout');f.write_text(o['stdout']);stdout=pin(f)
        build=ROOT/'selfhost/build/phase111'/('p131-'+out.name+'-'+name);assert not build.exists()
        cases.append(dict(name=name,source=x['source'],qbe=x['qbe'],oracle=oracle,expected=stdout,buildReport=str(build/'report.json')))
        inputs.extend([x['source'],x['qbe'],oracle,stdout])
        jobs.append(dict(name=name,seconds=75,command=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
            '--out',str(out/(name+'-guard')),'--seconds','60','--rss-mib','2048','--available-mib','16384','--file-mib','64','--cpu','3','--',
            sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),'--source',x['qbe']['file'],'--runtime',r['runtime']['file'],
            '--out',str(build),'--expected',stdout['file'],'--seconds','30']))
    for item in inputs:assert pin(item['file'])==item,item['file']
    result=dict(complete=True,targetsRun=False,source=r['source'],api=r['api'],emission=pin(a.emission),inputs=inputs,cases=cases,jobs=jobs,
        scope='Four exercised valid selector/projection/compiler-use computations with independent literal output oracles. JSON-to-stdout extraction only, no host compilation. Per-job CPU3 guards, no outer guard. Completed build receipts must independently pass exact outputs.')
    (out/'method.py').write_bytes(Path(__file__).read_bytes());(out/'jobs.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'jobs.json'),cases=len(cases),outerGuard=False)))
if __name__=='__main__':main()
