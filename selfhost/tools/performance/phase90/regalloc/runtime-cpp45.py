#!/usr/bin/env python3
"""Root-run CPU preprocessing equality of45 retained C outputs plus2 exact runtime edits."""
import argparse, hashlib, json, os, re, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);p.add_argument('--check-only',action='store_true');a=p.parse_args()
out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);start=time.monotonic();inputs={}
report=dict(kind='phase90-runtime-cpp45-text-derivative',complete=False,pass_=False,checkOnly=a.check_only,executionPerformed=False,rows=[],inputs=[],scope='Exact retained generated-C derivatives, not fresh Bend compiler emissions. Default host CPU at O2 only; no GPU or runtime timing claim.')
def pin(p):
    p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def bind(r):
    if isinstance(r,(str,Path)):r=pin(r)
    actual=pin(r['file']);assert actual['sha256']==r['sha256'],r['file']
    if 'bytes' in r:assert actual['bytes']==r['bytes'],r['file']
    inputs[actual['file']]=actual;return actual

def save():
    report['inputs']=list(inputs.values());report['elapsedSeconds']=time.monotonic()-start
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')

try:
    bind(__file__)
    planPin=bind(ROOT/'selfhost/tools/performance/phase90/regalloc/runtime-accessor-01/plan.json')
    assert planPin['sha256']=='1d6824d4be2a0a3e763336fe7ee19f67482190b2d8f7701df788d4ffcacdf566'
    plan=json.loads(Path(planPin['file']).read_text());candidate=bind(plan['source'])
    corpusPin=bind(ROOT/'selfhost/build/phase90/broad-token45/report.json');corpus=json.loads(Path(corpusPin['file']).read_text())
    assert corpus['complete'] and corpus['pass'] and corpus['all45'] and corpus['inputBindingsUnchanged']
    assert len(corpus['rows'])==45 and len({r['name'] for r in corpus['rows']})==45
    cc=bind(corpus['clang']);assert cc['sha256']=='9fcd5fc4baeea9c449bcc9ca4b9db7714465107669498b0056a853f22f5f4def'
    assert corpus['macros']['cwd']==str(ROOT) and corpus['macros']['sameStdinFilename']=='<stdin>'
    assert corpus['macros']['definitions']==[]
    includes=corpus['macros']['includeDirectories'];assert len(includes)==1
    command=[cc['file'],'-O2','-isystem',includes[0],'-x','c','-E','-P','-fminimize-whitespace','-H','-']
    headers={};cases=[];oldRuntime=None
    for row in corpus['rows']:
        assert row['passed'] and row['exactPreprocessed'] and row['observation']['checked'] and row['observation']['status']=='ok'
        source=bind(row['current']);text=Path(source['file']).read_text();assert source['bytes']<8*1024**2
        ids=re.findall(r'^#define FID_ENTER (\d+)$',text,re.M);assert len(ids)==1 and int(ids[0])<4096
        changed=text
        for e in plan['edits']:
            assert changed.count(e['before'])==1;changed=changed.replace(e['before'],e['after'],1)
        inverse=changed
        for e in reversed(plan['edits']):inverse=inverse.replace(e['after'],e['before'],1)
        assert inverse==text
        for h in row['preprocess']['current']['headers']:headers[h['file']]=bind(h)
        for r in row['requestInputs']:
            if r['sha256']==plan['canonicalInputs'][0]['sha256']:oldRuntime=bind(r)
        cases.append((row['name'],source,changed,int(ids[0])))
    assert oldRuntime and len(plan['edits'])==2
    text=Path(oldRuntime['file']).read_text()
    for e in plan['edits']:assert text.count(e['before'])==1;text=text.replace(e['before'],e['after'],1)
    assert text==Path(candidate['file']).read_text()
    report.update(plan=planPin,corpus=corpusPin,clang=cc,oldRuntime=oldRuntime,newRuntime=candidate,command=command,cwd=str(ROOT),stdinTransport='read-only regular FD at offset0',fidEnterRange=[min(c[3] for c in cases),max(c[3] for c in cases)],knownHeaders=len(headers))
    save()
    if not a.check_only:
        env=os.environ.copy()
        for k in ['CPATH','C_INCLUDE_PATH','CPLUS_INCLUDE_PATH','OBJC_INCLUDE_PATH','DEPENDENCIES_OUTPUT','SUNPRO_DEPENDENCIES']:env.pop(k,None)
        env['SOURCE_DATE_EPOCH']='0';report['sourceDateEpoch']='0';report['executionPerformed']=True
        for name,source,changed,fid in cases:
            derived=out/(name+'.derived.c');derived.write_text(changed);new=pin(derived);runs=[]
            for role,inputPin in [('old',source),('new',new)]:
                cpp=out/(name+'.'+role+'.i');err=out/(name+'.'+role+'.stderr')
                for h in headers.values():bind(h)
                t=time.monotonic()
                with open(inputPin['file'],'rb') as stdin,cpp.open('wb') as stdout,err.open('wb') as stderr:
                    assert stdin.tell()==0
                    proc=subprocess.run(command,stdin=stdin,stdout=stdout,stderr=stderr,cwd=ROOT,env=env,timeout=20)
                assert proc.returncode==0,(name,role,err.read_text()[-3000:])
                actualHeaders=sorted(set(re.findall(r'^\.+ (.+)$',err.read_text(),re.M)))
                assert actualHeaders and all(h in headers for h in actualHeaders),(name,'unbound header',set(actualHeaders)-set(headers))
                for h in actualHeaders:bind(headers[h])
                runs.append(dict(role=role,input=inputPin,output=pin(cpp),stderr=pin(err),headers=actualHeaders,seconds=time.monotonic()-t))
            assert runs[0]['headers']==runs[1]['headers'],name
            assert Path(runs[0]['output']['file']).read_bytes()==Path(runs[1]['output']['file']).read_bytes(),name
            report['rows'].append(dict(name=name,fidEnter=fid,parent=source,derived=new,exactInverse=True,exactPreprocessed=True,runs=runs,cppRemovedAfterExactComparison=True))
            for run in runs:Path(run['output']['file']).unlink()
            save()
    for r in list(inputs.values()):bind(r)
    report.update(complete=True,pass_=True,inputsUnchanged=True,cases=45)
except Exception as e:
    report['error']=repr(e);sys.exitcode=1
finally:save()
print(json.dumps(dict(complete=report['complete'],passed=report['pass_'],checkOnly=a.check_only,rows=len(report['rows']),error=report.get('error'))))
sys.exit(0 if report['complete'] else 1)
