#!/usr/bin/env python3
"""Data-only own-source CPU attribution; no library warmup/output assumptions."""
import argparse,ast,hashlib,json,math,re,sys
from pathlib import Path
from urllib.parse import unquote,urlsplit
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--report',type=Path,action='append',required=True)
p.add_argument('--inventory',type=Path,default=HERE.parent/'static/code-shapes.json');p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase57')and not out.exists()
inputs={}
def pin(item):
    file=Path(item.get('file',item.get('path'))if isinstance(item,dict)else item).resolve(strict=True);data=file.read_bytes()
    row=dict(file=str(file),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
    if isinstance(item,dict):assert row['sha256']==item['sha256']and('bytes'not in item or row['bytes']==item['bytes'])
    if str(file)in inputs:assert inputs[str(file)]==row
    inputs[str(file)]=row;return row,data
def read(item):
    row,data=pin(item);return row,json.loads(data)
def finite(x):return isinstance(x,(float,int))and math.isfinite(x)and x>=0
def approx(x,y):assert math.isclose(x,y,rel_tol=1e-10,abs_tol=.001),(x,y)
method,code=pin(HERE/'profiles-v2.py');assert method['sha256']=='ab678fb32d51d497009d5e1ffbae3ffbba4fdae27973b47546d2b5859d7c0d19'
# Reuse only the frozen pure validation function; the parent's CLI never runs.
node=next(n for n in ast.parse(code).body if isinstance(n,ast.FunctionDef)and n.name=='cpu_views')
exec(compile(ast.Module(body=[node],type_ignores=[]),method['file'],'exec'))
inventoryId,inventory=read(a.inventory);assert inventory['complete']and inventory['kind']=='phase57-static-compiler-code-shapes'
roleNames=dict(raw='rawChecked',source='derivedB1',direct='directB2');rows=[];failures=[];reportIds=[]
for file in a.report:
    reportId,r=read(file);reportIds.append(reportId)
    try:
        assert r['kind']=='phase57-one-own-source-cpu-check'and r['complete']and r['pass']and r['executed']and not r['cleanTiming']
        assert r['freshOwnSourceRequest']and r['expectedProofTrustFailure']and r['freshBaseCheck']is False and r['warmRequests']==[]
        assert r['producer']['sha256']=='ab110ccb2a176cc0d5a08451226702e2b920e01ca4fa6292020ddbec714575d2';pin(r['producer'])
        assert r['sourceTrustMethod']['sha256']=='fb7c322231cda3f5c59ee99be4c6d43b37387c07785ca165cbee59dad11b609e';pin(r['sourceTrustMethod'])
        for item in r['inputs']:pin(item)
        bindingId,binding=read(r['imagePins']);assert binding['kind']=='phase56-direct-image-pins'
        assert binding['source']==r['source']==r['image']['source']==r['subject']['source']
        assert binding['attempt']==r['image']['checkedSubject']==r['subject']['attempt'];read(binding['attempt'])
        assert r['image']['role']==r['role'];assert r['image']['pins']==r['imagePins'];assert r['cacheAfter']==r['cacheBefore']
        for key in ['api','driver','runtime','directRuntime','base']:pin(r['image'][key])
        for item in r['cacheBefore']:pin(item)
        sourceId,source=pin(r['source']);text=source.decode();defs=re.findall(r'^def\s+([^\s(:]+)',text,re.M);unsafe=re.findall(r'^@unsafe\s*\ndef\s+([^\s(:]+)',text,re.M)
        assert len(defs)==len(set(defs))==3012 and sorted(defs)==sorted(unsafe)
        observed=r['observation'];assert all(observed[k]==v for k,v in dict(checked=True,typeAccepted=True,kernelChecked=False,status='error',exitCode=1,phase='verdict',proofTrust='failed').items())
        names=observed['unsafeDefinitions'];assert len(names)==len(set(names))and set(unsafe).issubset(names)
        assert observed['diagnostic']=='SOME PROOFS FAIL\nError: '+str(len(names))+' defs rely on unsafe or foreign code:\n'+''.join('- '+n+'\n'for n in names)
        inv=next(x for x in inventory['roles']if x['role']==roleNames[r['role']]);assert r['image']['api']['sha256']==inv['identity']['sha256'];pin(inv['identity'])
        identifiers={v['identifier']:{'name':k,'line':v['line'],'bytes':v['bytes'],'sha256':v['sha256']}for k,v in inv['functions'].items()}
        api=Path(r['image']['api']['file']).resolve();inline=r['profile'];profileId,profile=read(inline['receipt']);assert profile=={k:v for k,v in inline.items()if k!='receipt'}
        assert profile['complete']and profile['pass']and profile['mode']=='cpu'and profile['diagnosticOnly']and profile['calls']==1
        assert profile['moduleUrl']==api.as_uri()and profile['sampling']==dict(intervalMicroseconds=1000)
        assert profile['producer']['sha256']=='f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6';pin(profile['producer']);pin(profile['predecessor']);pin(profile['summaryMethod'])
        assert profile['node']['sha256']==r['node']['sha256'];rawId,raw=read(profile['raw']);summaryId,summary=read(profile['summary']);countId,count=cpu_views(raw,summary,profile)
        views=[]
        for name,sid,s in [('primary',summaryId,summary),('sample-count',countId,count)]:
            assert s is not None;approx(sum(f['selfWeight']for f in s['frames']),s['totalWeight']);frames=[];groups={}
            for f in s['frames']:
                f=dict(f);loc=f['frame'];url=loc.get('url','');u=urlsplit(url);framePath=Path(unquote(u.path)).resolve()if u.scheme=='file'else None
                if framePath==api and loc.get('functionName')in identifiers:f['namedBendDefinition']=identifiers[loc['functionName']]
                group=('unattributed'if f.get('category')=='unattributed'else 'garbage-collector'if loc.get('functionName')=='(garbage collector)'else loc.get('functionName').strip('()')if loc.get('functionName')in ['(root)','(idle)','(program)']else 'bend-named-definition'if 'namedBendDefinition'in f else 'bend-runtime-or-anonymous'if framePath==api else 'compiler-host-driver'if framePath and framePath.parent==Path(r['image']['driver']['file']).parent else 'harness'if '/selfhost/tools/performance/'in url else 'node'if url.startswith('node:')else 'other')
                f['comparisonGroup']=group;groups[group]=groups.get(group,0)+f['selfWeight'];frames.append(f)
            approx(sum(groups.values()),s['totalWeight']);views.append(dict(view=name,summary=sid,unit=s['unit'],totalWeight=s['totalWeight'],sampleCount=s['sampleCount'],accounting=s.get('accounting'),warnings=s['warnings'],selfGroups=groups,topSelf=sorted(frames,key=lambda x:-x['selfWeight'])[:20],topInclusive=sorted(frames,key=lambda x:-x['inclusiveWeight'])[:20]))
        rows.append(dict(report=reportId,role=r['role'],image=r['image']['api'],source=sourceId,profile=profileId,raw=rawId,weightedStatus=profile['weightedStatus'],calls=1,workloadMs=profile['workloadMs'],sourceTypeAccepted=True,mathematicalProof=False,unsafeDefinitions=len(names),views=views))
    except Exception as error:failures.append(dict(report=reportId,error=repr(error)))
producer,_=pin(__file__)
for item in list(inputs.values()):pin(item)
result=dict(kind='phase57-own-source-profile-analysis',complete=not failures,**{'pass':not failures},dataOnly=True,targetExecuted=False,producer=producer,viewValidator=method,inventory=inventoryId,reports=reportIds,rows=rows,failures=failures,inputs=list(inputs.values()),inputsUnchanged=True,scope='One profiled complete own-source check per role, with existing Base cache and no warm request. Expected unsafe trust failure is preserved, not mathematical proof. Named frame identifiers join exact image inventory; anonymous/runtime frames stay unmapped. Inclusive samples overlap; timings are diagnostics, not latency ratios.')
md=['# Own-source CPU profiles','',result['scope']]
for r in rows:
    md+=['',f"## {r['role']}",'',f"One request; {r['workloadMs']/1000:.3f}s under the inspector. Weighted view: {r['weightedStatus']}."]
    for v in r['views']:
        md+=['',f"### {v['view']} ({v['unit']})",'','| Self % | Inclusive % | Frame | Named Bend definition |','|---:|---:|---|---|']
        for f in v['topSelf'][:12]:md.append(f"| {f['selfPercent']:.2f} | {f['inclusivePercent']:.2f} | `{f['functionName'].replace('|','/').replace('`','')}` | {f.get('namedBendDefinition',{}).get('name','—')} |")
        md+=['']+['- '+w for w in v['warnings']]
if failures:md+=['','## Preserved failures','']+['- '+json.dumps(f)for f in failures]
out.mkdir(parents=True);(out/'report.json').write_text(json.dumps(result,indent=2)+'\n');(out/'report.md').write_text('\n'.join(md)+'\n')
print(json.dumps(dict(complete=result['complete'],rows=len(rows),failures=len(failures),out=str(out))))
raise SystemExit(0 if result['pass']else 1)
