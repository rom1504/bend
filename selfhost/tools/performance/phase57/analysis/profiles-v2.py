#!/usr/bin/env python3
"""Versioned data-only comparison; explicit bounded-time and sample-count CPU views."""
import argparse,bisect,hashlib,json,math,sys
from pathlib import Path
from urllib.parse import unquote,urlsplit
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--report',type=Path,action='append',required=True)
p.add_argument('--inventory',type=Path,default=HERE.parent/'static/code-shapes.json')
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert not out.exists()
assert out.is_relative_to(ROOT/'selfhost/build/phase57') or out.is_relative_to(HERE.parent/'evidence')
inputs={}
def pin(value):
    if isinstance(value,dict):file=Path(value.get('file',value.get('path'))).resolve(strict=True)
    else:file=Path(value).resolve(strict=True)
    data=file.read_bytes();row=dict(file=str(file),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
    if isinstance(value,dict):
        assert row['sha256']==value['sha256'],str(file)
        if 'bytes'in value:assert row['bytes']==value['bytes']
    if str(file)in inputs:assert inputs[str(file)]==row
    inputs[str(file)]=row;return row,data
def read(value):
    row,data=pin(value);return row,json.loads(data)
def urlpath(url):
    if not url:return None
    u=urlsplit(url)
    if u.scheme=='file':return str(Path(unquote(u.path)).resolve())
    if not u.scheme and url.startswith('/'):return str(Path(url).resolve())
    return None
def finite(value):return isinstance(value,(int,float))and math.isfinite(value)and value>=0
def approx(left,right):assert math.isclose(left,right,rel_tol=1e-10,abs_tol=0.001),(left,right)
predecessor,_=pin(HERE/'profiles.py');assert predecessor['sha256']=='55e0593934c49dfea579bda09a61558f50f71939038607fe6ab2a1f239d2b586'
inventoryId,inventory=read(a.inventory);assert inventory['complete'] and inventory['kind']=='phase57-static-compiler-code-shapes'
images={};roleNames={'raw':'rawChecked','source':'derivedB1','direct':'directB2'}
for row in inventory['roles']:
    imageId,data=pin(row['identity']);lines=data.splitlines(keepends=True);starts=[0]
    for line in lines:starts.append(starts[-1]+len(line))
    spans=[]
    for name,f in row['functions'].items():
        declaration=('function '+f['identifier']+'(').encode();line=f['line']-1
        column=lines[line].index(declaration);start=starts[line]+column;end=start+f['bytes']
        assert hashlib.sha256(data[start:end]).hexdigest()==f['sha256']
        spans.append(dict(name=name,start=start,end=end,identifier=f['identifier'],line=f['line'],bytes=f['bytes'],sha256=f['sha256']))
    spans.sort(key=lambda x:x['start']);assert all(x['end']<=y['start']for x,y in zip(spans,spans[1:]))
    images[row['role']]=dict(identity=imageId,lines=lines,starts=starts,spans=spans,index=[x['start']for x in spans])

def enrich(frame,role,image,config):
    f=dict(frame);loc=f['frame'];url=loc.get('url','');file=urlpath(url);name=loc.get('functionName','');mapping=None
    api=image['api']['file']if image else None
    if role in roleNames and file==api:
        inv=images[roleNames[role]];line=loc.get('lineNumber',-1);column=loc.get('columnNumber',-1)
        if 0<=line<len(inv['lines']) and column>=0:
            try:
                text=inv['lines'][line].decode();encoded=text.encode('utf-16-le')
                if column*2>len(encoded):raise IndexError('Profile column outside line')
                prefix=encoded[:column*2].decode('utf-16-le')
                offset=inv['starts'][line]+len(prefix.encode());at=bisect.bisect_right(inv['index'],offset)-1
                if at>=0 and offset<inv['spans'][at]['end']:mapping=inv['spans'][at]
            except (UnicodeError,IndexError):pass
    if f.get('category')=='unattributed':group='unattributed'
    elif name=='(garbage collector)':group='garbage-collector'
    elif name in ['(idle)','(program)','(root)']:group=name.strip('()')
    elif file==api and api:group='bend-compiler-definition'if mapping else 'bend-image-runtime-or-unmapped'
    elif role=='typescript' and file in [str(Path(config['upstream'])/'bend2/bend.ts'),str(Path(config['upstream'])/'bend2/comp.ts')]:group='typescript-compiler'
    elif image and file and file.startswith(str(Path(image['driver']['file']).parent)+str('/')):group='compiler-host-driver'
    elif file and '/selfhost/tools/performance/'in file:group='harness'
    elif url.startswith('node:') or url.startswith('node:internal') or url.startswith('internal/'):group='node'
    else:group='other'
    f['comparisonGroup']=group
    if mapping:f['containingBendDefinition']={k:mapping[k]for k in ['name','identifier','line','bytes','sha256']};f['sourceMapping']='exact image hash and containing top-level function byte span; nested closures retain their own frame identity'
    return f

def cpu_views(raw,summary,profile):
    assert len(raw['samples'])==len(raw['timeDeltas'])==summary['sampleCount']
    if profile.get('schemaVersion')!=2:
        assert all(finite(x)for x in raw['timeDeltas']);approx(sum(raw['timeDeltas']),summary['totalWeight'])
        return None,None
    assert all(isinstance(x,int)and not isinstance(x,bool)for x in raw['timeDeltas'])
    duration=raw['endTime']-raw['startTime'];assert finite(duration)and duration>0
    negatives=[dict(index=i,value=x)for i,x in enumerate(raw['timeDeltas'])if x<0]
    correction=-sum(x['value']for x in negatives);ppm=correction/duration*1e6
    reasons=[]
    if any(-x['value']>2 for x in negatives):reasons.append('Negative CPU delta exceeds 2us magnitude')
    if ppm>10:reasons.append('CPU correction exceeds 10ppm of raw profile duration')
    status='refused'if reasons else 'admitted';weighted=sum(max(x,0)for x in raw['timeDeltas']);signed=sum(raw['timeDeltas'])
    account=profile['weightedAccounting'];assert account['policy']==dict(maxNegativeMagnitudeUs=2,maxCorrectionPartsPerMillion=10)
    expected=dict(weightedStatus=status,reasons=reasons,negativeDeltas=negatives,negativeDeltaCount=len(negatives),signedRawTimeDeltaUs=signed,
        correctionUs=correction,admittedWeightedUs=weighted if not reasons else None,profileDurationUs=duration,profileMinusSignedRawUs=duration-signed,
        profileMinusWeightedUs=duration-weighted if not reasons else None,rawProfileUnmodified=True)
    for key,value in expected.items():assert account[key]==value,(key,account[key],value)
    approx(account['correctionPartsPerMillion'],ppm);assert profile['weightedStatus']==status
    countId,count=read(profile['sampleCountSummary']);assert count['unit']=='samples'and count['sampleCount']==len(raw['samples'])
    approx(count['totalWeight'],len(raw['samples']));approx(sum(f['selfWeight']for f in count['frames']),len(raw['samples']))
    assert count['accounting']==dict(weightSource='one per original CPU sample',sampleCount=len(raw['samples']),weightedStatus=status,signedTimeAccounting=account)
    for f in count['frames']+count['topSelf']+count['topInclusive']:assert 'selfUs'not in f and'inclusiveUs'not in f
    if status=='admitted':
        assert profile['summaryView']=='weighted-time'and summary['unit']=='sample-weighted-microseconds'and summary['accounting']==account
        approx(summary['totalWeight'],weighted)
    else:
        assert profile['summaryView']=='sample-count'and summary['unit']=='samples'
        assert {k:v for k,v in summary.items()if k!='warnings'}=={k:v for k,v in count.items()if k!='warnings'}
        assert any('Weighted timestamp view REFUSED'in w for w in summary['warnings'])
    return countId,count

profiles=[];failures=[];reports=[]
for source in a.report:
    reportId,report=read(source);reports.append(reportId)
    assert report['kind']=='phase57-four-image-library-latency' and report['mode']in ['cpu','allocation']
    configId,config=read(report['config']);assert config['mode']==report['mode']
    if not(report.get('complete')and report.get('pass')):failures.append(dict(report=reportId,error='Incomplete or failed input campaign; no success inferred'))
    expected={(c['id'],role,sample)for c in config['cases']for role in config['roles']for sample in range(config['rounds'])}
    actual=[(x.get('case'),x.get('role'),x.get('sample'))for x in report['rows']]
    if set(actual)!=expected or len(actual)!=len(expected):failures.append(dict(report=reportId,error='Missing/duplicate diagnostic request rows'))
    for entry in report['rows']:
      try:
        resultId,worker=read(entry['result']);assert worker==entry['observation']
        assert entry['execution']['complete'] and entry['execution']['returncode']==0 and worker['complete'] and worker['pass']
        assert worker['kind']=='phase57-four-image-library-worker' and worker['mode']==report['mode'] and not worker['cleanTiming']
        assert worker['config']==configId or worker['config']==report['config']
        role=worker['role'];assert role==entry['role'] and role in config['roles'];assert worker['sample']==entry['sample'];assert config['warmRequests']==3 and len(worker['warmRequests'])==3
        sourceCase=next(x for x in config['cases']if x['id']==entry['case']);assert worker['source']==sourceCase['source'];pin(worker['source'])
        prepId,prep=read(worker['preparation']);assert prep['complete']and prep['pass']and prep['role']==role
        oracle=next(x for x in prep['outputs']if x['id']==entry['case']);assert oracle['oracle']['pass'] and oracle['oracle']['point']==sourceCase['point']
        assert worker['expected']==oracle['output'];pin(worker['expected']);pin(worker['output']);assert worker['output']['sha256']==worker['expected']['sha256']
        assert oracle['source']==worker['source']
        for warm in worker['warmRequests']:assert warm['output']=={k:worker['expected'][k]for k in ['sha256','bytes']}
        image=worker.get('image')
        if role in roleNames:
            assert image==prep['image'];pin(image['api']);assert image['api']['sha256']==images[roleNames[role]]['identity']['sha256']
        else:
            for name in ['bend.ts','comp.ts']:
                file=str(Path(config['upstream'])/'bend2'/name);pin(next(x for x in config['inputs']if x['file']==file))
        inline=worker['profile'];profileId,profile=read(inline['receipt']);assert profile=={k:v for k,v in inline.items()if k!='receipt'}
        assert profile['complete']and profile['pass']and profile['mode']==report['mode']and profile['diagnosticOnly']
        assert profile['moduleUrl']==Path(image['api']['file']if image else Path(config['upstream'])/'bend2/comp.ts').resolve().as_uri()
        assert profile['calls']>0 and len(profile['requestMs'])==profile['calls'];assert profile['sampling']==({'intervalMicroseconds':1000}if report['mode']=='cpu'else {'intervalBytes':131072,'includeObjectsCollectedByMajorGC':True,'includeObjectsCollectedByMinorGC':True})
        assert profile['producer']['sha256']==next(x['sha256']for x in config['inputs']if x['file']==profile['producer']['file'])
        assert profile['producer']['sha256']in ['3372be2a9db0b85e7391e9ac0e79a5500e355a2f3fd2f8c061e5880d0566b8c5','f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6'];pin(profile['producer'])
        if profile.get('schemaVersion')==2:assert profile['predecessor']['sha256']=='3372be2a9db0b85e7391e9ac0e79a5500e355a2f3fd2f8c061e5880d0566b8c5';pin(profile['predecessor'])
        assert profile['summaryMethod']['sha256']==next(x['sha256']for x in config['inputs']if x['file'].endswith('/programs/profile.mjs'));assert profile['node']['sha256']==config['node']['sha256']
        rawId,raw=read(profile['raw']);summaryId,summary=read(profile['summary']);assert summary['sampleCount']==profile['totals']['sampleCount']
        countId=count=None
        if report['mode']=='cpu':countId,count=cpu_views(raw,summary,profile)
        else:
            assert len(raw['samples'])==summary['sampleCount'];assert all(finite(x['size'])for x in raw['samples']);approx(sum(x['size']for x in raw['samples']),summary['totalWeight'])
        approx(sum(x['selfWeight']for x in summary['frames']),summary['totalWeight'])
        frames=[enrich(f,role,image,config)for f in summary['frames']];groups={}
        for f in frames:groups[f['comparisonGroup']]=groups.get(f['comparisonGroup'],0)+f['selfWeight']
        approx(sum(groups.values()),summary['totalWeight'])
        groupRows=[dict(group=k,selfWeight=v,selfPercent=100*v/summary['totalWeight']if summary['totalWeight']else None)for k,v in sorted(groups.items(),key=lambda x:-x[1])]
        top=lambda key:sorted((x for x in frames if x[key]>0),key=lambda x:-x[key])[:20]
        profiles.append(dict(case=entry['case'],sample=entry['sample'],role=role,mode=report['mode'],worker=resultId,preparation=prepId,profile=profileId,raw=rawId,summary=summaryId,
            summaryView=profile.get('summaryView','allocation'if report['mode']=='allocation'else 'weighted-time'),weightedStatus=profile.get('weightedStatus'),sampleCountSummary=countId,
            calls=profile['calls'],workloadMs=profile['workloadMs'],targetReached=profile['targetReached'],requestCapReached=profile['requestCapReached'],unit=summary['unit'],totalWeight=summary['totalWeight'],sampleCount=summary['sampleCount'],
            sampledWeightPerRequest=summary['totalWeight']/profile['calls'],allocationBytesPerRequest=summary['totalWeight']/profile['calls']if report['mode']=='allocation'else None,
            selfGroups=groupRows,accounting=summary.get('accounting'),warnings=summary['warnings'],topSelf=top('selfWeight'),topInclusive=top('inclusiveWeight'),
            mappedSelfWeight=sum(x['selfWeight']for x in frames if 'containingBendDefinition'in x),unmappedImageScope='Embedded runtime frames or unavailable/out-of-span positions remain unassigned; no name-only source inference.'))
        if count is not None:
            countFrames=[enrich(f,role,image,config)for f in count['frames']];countGroups={}
            for f in countFrames:countGroups[f['comparisonGroup']]=countGroups.get(f['comparisonGroup'],0)+f['selfWeight']
            approx(sum(countGroups.values()),count['totalWeight'])
            profiles[-1]['sampleCountView']=dict(summary=countId,unit='samples',totalWeight=count['totalWeight'],
                selfGroups=[dict(group=k,selfWeight=v,selfPercent=100*v/count['totalWeight']if count['totalWeight']else None)for k,v in sorted(countGroups.items(),key=lambda x:-x[1])],
                topSelf=sorted(countFrames,key=lambda x:-x['selfWeight'])[:20],topInclusive=sorted(countFrames,key=lambda x:-x['inclusiveWeight'])[:20],accounting=count['accounting'],warnings=count['warnings'])
      except Exception as error:failures.append(dict(report=reportId,case=entry.get('case'),role=entry.get('role'),sample=entry.get('sample'),error=repr(error)))

producer,_=pin(__file__)
for item in list(inputs.values()):pin(item)
result=dict(kind='phase57-profile-comparison-v2',predecessor=predecessor,complete=not failures,**{'pass':not failures},dataOnly=True,targetExecuted=False,producer=producer,reports=reports,inventory=inventoryId,profiles=profiles,failures=failures,inputs=list(inputs.values()),inputsUnchanged=True,
 scope='Diagnostic samples, not speed ratios. Self groups partition the full sampled denominator; TS bend.ts and comp.ts are one compiler group. Inclusive top frames overlap and are never summed. Per-request allocations are sampled size estimates including collected objects. Exact generated source-span joins identify containing definitions, not dynamic causation.')
md=['# Phase57 diagnostic profiles','',result['scope'],'','| Case | Role | Mode | Unit | Requests | Samples | Total sampled weight | Weight/request | Target reached |','|---|---|---|---|---:|---:|---:|---:|---|']
for r in profiles:md.append(f"| {r['case']} | {r['role']} | {r['mode']} | {r['unit']} | {r['calls']} | {r['sampleCount']} | {r['totalWeight']:.3f} | {r['sampledWeightPerRequest']:.3f} | {r['targetReached']} |")
for r in profiles:
    md+=['',f"## {r['case']} / {r['role']} / {r['mode']} / sample {r['sample']}",'',f"Unit: `{r['unit']}`. Raw SHA-256: `{r['raw']['sha256']}`. These are profiled requests, not clean latency.",'','Self groups: '+', '.join(f"{x['group']} {x['selfPercent']:.2f}%"for x in r['selfGroups'] if x['selfPercent']is not None)+'.','','| Self % | Inclusive % | Frame | Containing Bend definition | URL / line |','|---:|---:|---|---|---|']
    for f in r['topSelf'][:12]:md.append(f"| {f['selfPercent']:.2f} | {f['inclusivePercent']:.2f} | `{f['functionName'].replace('|','/').replace('`','')}` | {f.get('containingBendDefinition',{}).get('name','—')} | `{f['url'].replace('|','%7C')}:{f['line']}` |")
    md+=['','Top inclusive frames are retained separately in JSON and must not be added together.']
    if r.get('sampleCountView'):
        c=r['sampleCountView'];md+=['',f"CPU weighted status: `{r['weightedStatus']}`. Independent count summary: {c['totalWeight']} samples; raw timestamps remain unchanged.",'', 'Count self groups: '+', '.join(f"{x['group']} {x['selfPercent']:.2f}%"for x in c['selfGroups']if x['selfPercent']is not None)+'.']
    if r['warnings']:md+=['']+['- '+x for x in r['warnings']]
if failures:md+=['','## Preserved failed/incomplete inputs','']+['- '+json.dumps(x)for x in failures]
out.mkdir(parents=True);(out/'report.json').write_text(json.dumps(result,indent=2)+'\n');(out/'report.md').write_text('\n'.join(md)+'\n')
print(json.dumps(dict(complete=result['complete'],profiles=len(profiles),failures=len(failures),out=str(out))))
raise SystemExit(0 if result['pass']else 1)
