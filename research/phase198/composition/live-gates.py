"""Run the exact selected N2 program objects at the composed live-runtime boundary."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

def read(p):return json.loads(Path(p).read_bytes())
def pin(p):
    p=Path(p).resolve();d=p.read_bytes()
    return {'file':str(p),'bytes':len(d),'sha256':hashlib.sha256(d).hexdigest()}
def verify(ref):
    assert pin(ref['file'])==ref,ref['file']
    return ref['file']
def run(a):
    assert os.sched_getaffinity(0)=={3}
    b=a.build.resolve();out=a.out.resolve();out.mkdir(parents=True)
    conf=b/(a.prefix+'-native64-01')/'report.json';ctrl=b/(a.prefix+'-runtime10-01')/'report.json'
    c,r=read(conf),read(ctrl);assert all(x['passed'] and x['complete'] and x['stage']=='N2' for x in [c,r])
    assert c['image']==r['image'] and c['counts']=={'pass':64,'fail':0,'unsupported':0} and len(r['rows'])==10
    asset=b/'runtime-split-controls01/report.json';live=read(asset);assert live['complete']
    livefile=verify(live['liveRuntime'])
    res={'complete':False,'image':c['image'],'conformance':pin(conf),'runtimeControl':pin(ctrl),'live':live['liveRuntime'],
         'approvedRuntime':pin(asset),'scope':'Relink and execute every executable N2 conformance/control object with live constructor metadata. Source and backend refusals use authenticated N2 compiler-stage receipts; they have no object to relink. All objects and normative output contracts are held fixed.',
         'method':pin(__file__),'rows':[],'refusals':[]}
    save=lambda:(out/'report.json').write_text(json.dumps(res,indent=2)+'\n')
    save();start=time.monotonic()
    def test(name,record,want,source,arguments):
        rec=read(verify(record));assert rec['complete'] and rec['runtimeABI']==11102
        runtime=verify(rec['runtime']);obj=verify(rec['object']);binary=verify(rec['binary']);verify(source)
        j=next(j for j in rec['jobs'] if j['label']=='link');args=j['command'][:]
        assert obj in args and args.count(runtime)==args.count(binary)==1
        directory=out/name;directory.mkdir(parents=True);exe=directory/'live'
        args[args.index(runtime)]=livefile;args[args.index(binary)]=str(exe)
        subprocess.run(args,check=True,capture_output=True,timeout=8)
        child=subprocess.run([exe,*arguments],cwd=directory,capture_output=True,timeout=12)
        got={'stdout':child.stdout.decode(),'stderr':child.stderr.decode(),'exitCode':child.returncode}
        assert got=={k:want[k] for k in got},(name,got,want)
        res['rows'].append({'case':name,'source':source,'object':rec['object'],'reference':record,'argv':args,'exe':pin(exe),'observed':got})
    for x in c['rows']:
        assert x['status']=='pass'
        if x['expected']['stage']!='execute':
            verify(x['source']);refusal=x.get('emission')
            if refusal:verify(refusal)
            res['refusals'].append({'case':x['id'],'expected':x['expected'],'receipt':refusal});continue
        m=read(verify(x['build']))
        j=next(j for j in m['jobs'] if j['label']=='execute')
        assert j['command'][0]==m['binary']['file']
        test('conformance/'+x['id'],x['build'],x['expected'],x['source'],j['command'][1:])
    for x in r['rows']:
        assert x['complete']
        test('runtime/'+x['name'],x['receipt'],x['expected'],x['source'],r['runtimeArguments'])
    assert len(res['rows'])==71 and len(res['refusals'])==3
    res['complete']=True;res['wall']=time.monotonic()-start;save()
    print('71 exact executions, 3 original N2 admission receipts;',round(res['wall'],3),'s')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--build',type=Path,default=Path('selfhost/build/phase198'))
    p.add_argument('--prefix',required=True);p.add_argument('--out',type=Path,required=True);run(p.parse_args())
