#!/usr/bin/env python3
"""Read completed Phase59 receipts; separate clean clocks from first-window profiles."""
import argparse,ast,hashlib,html,json,math,statistics,sys
from pathlib import Path
from urllib.parse import unquote,urlsplit
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
B2='a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081'
SOURCE='85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091'
UPSTREAM='018751270e800bc222a93dad7f257083ee53a5f7'
HELPER='58748e46cc15960e36b0ccd922a167bcb7bbf7f64dd5db09cc82a5237ca1c254'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--report',type=Path,action='append',required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase59')and not out.exists()
inputs={}
def pin(value,force=False):
    file=Path(value.get('file',value.get('path'))if isinstance(value,dict)else value).resolve(strict=True);key=str(file)
    if force or key not in inputs:
        h=hashlib.sha256()
        with file.open('rb')as f:
            for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
        inputs[key]=dict(file=key,sha256=h.hexdigest(),bytes=file.stat().st_size)
    row=inputs[key]
    if isinstance(value,dict):
        assert row['sha256']==value['sha256'],key
        if 'bytes'in value:assert row['bytes']==value['bytes'],key
    return row

def read(value):
    row=pin(value);return row,json.loads(Path(row['file']).read_text())
def finite(x):return isinstance(x,(int,float))and not isinstance(x,bool)and math.isfinite(x)and x>=0
def approx(x,y):assert math.isclose(x,y,rel_tol=1e-10,abs_tol=.001),(x,y)
def stats(xs):return dict(median=statistics.median(xs),min=min(xs),max=max(xs),samples=xs)
def urlpath(url):
    u=urlsplit(url)
    if u.scheme=='file':return str(Path(unquote(u.path)).resolve())
    return str(Path(url).resolve())if url.startswith('/')else None

# Reuse only the reviewed pure accounting function, never execute its CLI body.
accountMethod=pin(HERE.parent/'phase57/analysis/profiles-v2.py')
assert accountMethod['sha256']=='ab678fb32d51d497009d5e1ffbae3ffbba4fdae27973b47546d2b5859d7c0d19'
tree=ast.parse(Path(accountMethod['file']).read_text())
fn=next(x for x in tree.body if isinstance(x,ast.FunctionDef)and x.name=='cpu_views')
exec(compile(ast.Module(body=[fn],type_ignores=[]),accountMethod['file'],'exec'))

def grouped(summary,role,image,config):
    frames=[];groups={}
    for item in summary['frames']:
        f=dict(item);loc=f['frame'];url=loc.get('url','');file=urlpath(url);name=loc.get('functionName','')
        if f.get('category')=='unattributed':group='unattributed'
        elif name=='(garbage collector)':group='GC'
        elif name in ['(program)','(idle)','(root)']:group=name.strip('()')
        elif image and file==image['api']['file']:group='Bend image (including runtime)'
        elif role=='typescript'and file and file.startswith(str(Path(config['upstream']).resolve())+'/')and file.endswith('.ts'):group='TS compiler (all source URLs)'
        elif image and file and file.startswith(str(Path(image['driver']['file']).parent)+'/'):group='Bend host driver'
        elif url.startswith(('node:','internal/')):group='Node'
        elif file and ('/tools/performance/'in file or '/build/phase59/latency-method'in file):group='harness'
        else:group='other'
        f['comparisonGroup']=group;frames.append(f);groups[group]=groups.get(group,0)+f['selfWeight']
    approx(sum(groups.values()),summary['totalWeight'])
    return dict(unit=summary['unit'],totalWeight=summary['totalWeight'],sampleCount=summary['sampleCount'],
        selfGroups=[dict(group=k,weight=v,percent=100*v/summary['totalWeight']if summary['totalWeight']else 0)for k,v in sorted(groups.items(),key=lambda x:-x[1])],
        topSelf=sorted(frames,key=lambda f:-f['selfWeight'])[:20],topInclusive=sorted(frames,key=lambda f:-f['inclusiveWeight'])[:20])

reports=[];clean=[];profiles=[];failures=[]
for source in a.report:
    rid,r=read(source);reports.append(rid)
    try:
        assert r['kind']=='phase59-candidate-image-library-latency'and r['complete']and r['pass']
        cid,c=read(r['config']);mode=r['mode'];assert mode in ['clean','cpu','allocation']and c['mode']==mode
        assert c['comparison']=='fixed-source'and c['upstreamCommit']==UPSTREAM and c['backend']=='direct'
        assert c['roles']and set(c['roles'])<=set(['direct','typescript'])
        assert c['warmRequests']==(3 if mode=='clean'else 0)
        assert c['profile']==dict(targetMs=1,maxRequests=1,samplingIntervalUs=1000,samplingIntervalBytes=131072)
        for key,val in dict(cpu=3,heapMiB=1024,rssMiB=2048,availableMiB=4096).items():assert c['resources'][key]==val
        for x in c['inputs']:pin(x)
        pin(r['methodDerivation']);pin(c['imageBindings'])
        expected={(case['id'],role,i)for case in c['cases']for role in c['roles']for i in range(c['rounds'])}
        actual=[(e['case'],e['role'],e['sample'])for e in r['rows']];assert len(actual)==len(expected)and set(actual)==expected
        accepted=[]
        for e in r['rows']:
            wid,w=read(e['result']);assert w==e['observation']and w['complete']and w['pass']
            ex=e['execution'];assert ex['complete']and ex['returncode']==0
            assert ex['rssLimitBytes']==2048*1024**2 and ex['availableFloorBytes']==4096*1024**2
            assert ex['command'][:6]==['taskset','-c','3',c['node']['file'],'--stack-size=4096','--max-old-space-size=1024']
            assert ex['command'][-1]==wid['file'];pin(w['request'])
            assert w['kind']=='phase59-candidate-image-library-worker'and w['mode']==mode and w['stage']=='sample'
            assert w['config']['sha256']==cid['sha256']and w['role']==e['role']and w['sample']==e['sample']
            assert w['node']=='v24.18.0'and w['cleanTiming']==(mode=='clean')and len(w['warmRequests'])==c['warmRequests']
            case=next(x for x in c['cases']if x['id']==e['case']);assert w['source']==case['source'];pin(w['source'])
            pid,prep=read(w['preparation']);assert prep['complete']and prep['pass']and prep['stage']=='prepare'and prep['role']==w['role']
            oracle=next(x for x in prep['outputs']if x['id']==e['case']);assert oracle['source']==w['source']
            assert oracle['oracle']['pass']and oracle['oracle']['point']==case['point']and oracle['oracle']['value']==case['point']['expected']
            assert oracle['output']==w['expected'];pin(w['expected']);pin(w['output'])
            assert all(w['output'][k]==w['expected'][k]for k in ['sha256','bytes'])
            for warm in w['warmRequests']:
                assert finite(warm['requestMs'])and warm['output']=={k:w['expected'][k]for k in ['sha256','bytes']}
            image=w.get('image')
            if w['role']=='direct':
                assert image==prep['image']and image['api']['sha256']==B2 and image['source']['sha256']==SOURCE
                for value in image.values():
                    if isinstance(value,dict)and 'sha256'in value:pin(value)
                assert prep['verification']['inputsUnchanged']and prep['verification']['copiesUnchanged']
                for x in prep['verification']['cacheFiles']:pin(x)
                assert w['observation']['typeAccepted']and w['observation']['checked']and w['observation']['backend']=='direct'and w['observation']['status']=='ok'
            else:assert prep['upstreamCommit']==UPSTREAM
            clocks={k:w[k]for k in ['hostImportMs','apiLoadMs','firstRequestMs','importApiAndFirstMs']}
            assert all(finite(v)for v in clocks.values());approx(sum(clocks[k]for k in ['hostImportMs','apiLoadMs','firstRequestMs']),clocks['importApiAndFirstMs'])
            row=dict(campaign=rid,case=e['case'],role=e['role'],sample=e['sample'],worker=wid,preparation=pid,clocks=clocks,output=w['output'],peakTreeRssBytes=ex['peakTreeRssBytes'])
            if mode=='clean':
                row['laterRequestMs']=[x['requestMs']for x in w['warmRequests']];accepted.append(row);continue
            inline=w['profile'];qid,q=read(inline['receipt']);assert q=={k:v for k,v in inline.items()if k!='receipt'}
            assert q['complete']and q['pass']and q['diagnosticOnly']and q['mode']==mode and q['calls']==1 and len(q['requestMs'])==1
            assert q['targetMs']==1 and q['maxRequests']==1 and q['schemaVersion']==2
            assert w['profileWindow']=='Actual compiler import + API load + exactly one first compile; output validation after inspector stop'
            assert q['moduleUrl']==Path(image['api']['file']if image else Path(c['upstream'])/'bend2/comp.ts').resolve().as_uri()
            assert q['producer']['sha256']==HELPER;pin(q['producer']);pin(q['summaryMethod']);pin(q['predecessor'])
            assert q['node']['sha256']==c['node']['sha256']
            assert q['sampling']==({'intervalMicroseconds':1000}if mode=='cpu'else dict(intervalBytes=131072,includeObjectsCollectedByMajorGC=True,includeObjectsCollectedByMinorGC=True))
            rawid,raw=read(q['raw']);sid,summary=read(q['summary'])
            for key in ['unit','totalWeight','sampleCount','frameCount']:assert summary[key]==q['totals'][key]
            approx(sum(f['selfWeight']for f in summary['frames']),summary['totalWeight'])
            row.update(mode=mode,profile=qid,raw=rawid,summary=sid,workloadMs=q['workloadMs'],view=grouped(summary,e['role'],image,c),warnings=summary['warnings'])
            if mode=='cpu':
                countid,count=cpu_views(raw,summary,q)
                row.update(weightedStatus=q['weightedStatus'],weightedAccounting=q['weightedAccounting'],summaryView=q['summaryView'],sampleCountSummary=countid,countView=grouped(count,e['role'],image,c))
            else:
                assert len(raw['samples'])==summary['sampleCount']and all(finite(x['size'])for x in raw['samples']);approx(sum(x['size']for x in raw['samples']),summary['totalWeight'])
                row['sampledAllocationBytesPerRequest']=summary['totalWeight']
            profiles.append(row)
        if mode=='clean':
            groupedRows=[]
            for case in c['cases']:
                roles={}
                for role in c['roles']:
                    rows=[x for x in accepted if x['case']==case['id']and x['role']==role]
                    values={key:stats([x['clocks'][key]for x in rows])for key in rows[0]['clocks']}
                    values['warmRequestMedianMs']=stats([statistics.median(x['laterRequestMs'])for x in rows])
                    for key,v in values.items():assert v==r['statistics'][case['id']][role][key]
                    values['laterByPosition']=[stats([x['laterRequestMs'][j]for x in rows])for j in range(3)]
                    values['startupMs']=stats([x['clocks']['hostImportMs']+x['clocks']['apiLoadMs']for x in rows]);roles[role]=values
                ratios={k:roles['direct'][k]['median']/roles['typescript'][k]['median']for k in ['importApiAndFirstMs','firstRequestMs','warmRequestMedianMs','startupMs']}if len(roles)==2 else {}
                groupedRows.append(dict(case=case['id'],roles=roles,b2OverTs=ratios))
            clean.append(dict(report=rid,processes=len(accepted),requests=len(accepted)*4,rows=accepted,cases=groupedRows))
    except Exception as exc:failures.append(dict(report=rid,error=repr(exc)))

# Charts retain campaigns/units separately; no pooling of repeats or weighted/count units.
def svg(title,subtitle,rows,path,percent=False):
    width=1100;height=104+len(rows)*34;maxv=100 if percent else max((sum(v for _,v in xs)for _,xs,_ in rows),default=1)*1.1
    colors=['#176b99','#df8e22','#4b9661','#9c63ae','#cc5f65','#748694','#b2a052','#555555','#66a8aa','#aaaaaa']
    labels=[]
    for _,xs,_ in rows:
        for k,_ in xs:
            if k not in labels:labels.append(k)
    palette={k:colors[i%len(colors)]for i,k in enumerate(labels)}
    esc=html.escape;parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height+70}" viewBox="0 0 {width} {height+70}">', '<rect width="100%" height="100%" fill="white"/>',f'<text x="24" y="28" font-family="sans-serif" font-size="20">{esc(title)}</text>',f'<text x="24" y="52" font-family="sans-serif" font-size="12">{esc(subtitle)}</text>']
    for i,(label,xs,note)in enumerate(rows):
        y=82+i*34;parts.append(f'<text x="24" y="{y+15}" font-family="sans-serif" font-size="12">{esc(label)}</text>');x=265
        for k,v in xs:
            w=660*v/maxv;parts.append(f'<rect x="{x:.3f}" y="{y}" width="{w:.3f}" height="21" fill="{palette[k]}"><title>{esc(k)}: {v:.6g}</title></rect>');x+=w
        parts.append(f'<text x="{x+6:.3f}" y="{y+15}" font-family="sans-serif" font-size="11">{esc(note)}</text>')
    for i,k in enumerate(labels):
        x=24+(i%4)*265;y=height+14+(i//4)*19;parts.extend([f'<rect x="{x}" y="{y-10}" width="12" height="12" fill="{palette[k]}"/>',f'<text x="{x+18}" y="{y}" font-family="sans-serif" font-size="11">{esc(k)}</text>'])
    parts.append('</svg>');path.write_text('\n'.join(parts)+'\n')

producer=pin(__file__)
for x in list(inputs.values()):pin(x,force=True)
result=dict(kind='phase59-first-request-analysis',complete=not failures,**{'pass':not failures},dataOnly=True,targetExecuted=False,producer=producer,cpuAccountingMethod=accountMethod,reports=reports,clean=clean,profiles=profiles,failures=failures,inputs=list(inputs.values()),inputsUnchanged=True,
 scope='Clean ratios only compare same-campaign medians. CPU comparisons use sample counts for every capture; admitted timestamp weights remain separate. All TS source URLs are grouped together. Self groups partition the full denominator, inclusive frames overlap. Shared SCC frame names identify dispatchers, not one source member. Allocation totals estimate one first-window cumulative allocation including collected objects, not live heap or speed. Repeats remain separate.')
out.mkdir(parents=True)
(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
md=['# First-request measurements','',result['scope'],'','| Campaign | Case | Role | Combined first ms | First compile ms | Later median ms |','|---|---|---|---:|---:|---:|']
for campaign in clean:
    chart=[];clocks=[]
    for case in campaign['cases']:
        for role,v in case['roles'].items():
            md.append(f"| {Path(campaign['report']['file']).parent.name} | {case['case']} | {role} | {v['importApiAndFirstMs']['median']:.3f} | {v['firstRequestMs']['median']:.3f} | {v['warmRequestMedianMs']['median']:.3f} |")
            for key,label in [('importApiAndFirstMs','first incl. startup'),('warmRequestMedianMs','later')]:chart.append((case['case'].replace('test-evening-program','Evening')+' / '+('B2'if role=='direct'else 'TS')+' / '+label,[(label,v[key]['median'])],f"{v[key]['median']:.1f} ms"))
    for row in campaign['rows']:clocks.append((row['case'].replace('test-evening-program','Evening')+' / '+('B2'if row['role']=='direct'else 'TS')+' / '+str(row['sample']),[(k,row['clocks'][k])for k in ['hostImportMs','apiLoadMs','firstRequestMs']],f"{row['clocks']['importApiAndFirstMs']:.1f} ms"))
    slug=Path(campaign['report']['file']).parent.name
    svg('Clean first versus later requests','Median combined first window and median of each process’s three later requests (ms).',chart,out/(slug+'-first-later.svg'))
    svg('Clean clocks in each fresh process','Each bar sums that process’s measured clocks; medians of components are not stacked.',clocks,out/(slug+'-clocks.svg'))
for mode in ['cpu','allocation']:
    rows=[]
    for r in profiles:
        if r['mode']!=mode:continue
        v=r['countView']if mode=='cpu'else r['view'];slug=Path(r['campaign']['file']).parent.name
        rows.append((slug.replace('first-','').replace('evening-','')+' / '+r['case'].replace('test-evening-program','Evening')+' / '+('B2'if r['role']=='direct'else 'TS'),[(x['group'],x['percent'])for x in v['selfGroups']],str(v['sampleCount'])+' samples'))
        md+=['',f"## {slug} / {r['case']} / {r['role']}",'',f"Unit: {v['unit']}; total {v['totalWeight']}; samples {v['sampleCount']}. Raw `{r['raw']['sha256']}`.",'','| Self % | Inclusive % | Actual frame | URL / line |','|---:|---:|---|---|']
        for f in v['topSelf'][:12]:md.append(f"| {f['selfPercent']:.3f} | {f['inclusivePercent']:.3f} | `{f['functionName'].replace('|','/').replace('`','')}` | `{f['url']}:{f['line']}` |")
    if rows:svg('First-window '+mode+' self attribution','CPU uses a common sample-count view. Allocation shares estimate sampled bytes; profiles are not speed ratios.',rows,out/(mode+'-self-groups.svg'),True)
if failures:md+=['','Failed input checks:']+['- '+json.dumps(f)for f in failures]
(out/'report.md').write_text('\n'.join(md)+'\n')
print(json.dumps(dict(complete=result['complete'],cleanCampaigns=len(clean),profiles=len(profiles),failures=failures,out=str(out))))
raise SystemExit(0 if result['pass']else 1)
