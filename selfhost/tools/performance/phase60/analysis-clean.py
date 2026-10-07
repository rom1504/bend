#!/usr/bin/env python3
"""Data-only Phase60 clean population: one weight per compilation input, no profile times."""
import argparse,ast,hashlib,html,json,math,statistics,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--report',type=Path,required=True)
p.add_argument('--catalog',type=Path,default=HERE/'catalog.json')
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase60')and not out.exists()
inputs={}
parent=HERE.parent/'phase59/summarize.py';parentBytes=parent.read_bytes()
assert hashlib.sha256(parentBytes).hexdigest()=='421619b7c26e7db8c4bc4e2b9a104deadc24dc41b77af81453cad6bda5a1ac8b'
# Extract only reviewed utility function bodies; importing the parent's CLI would execute it.
tree=ast.parse(parentBytes);names={'pin','read','finite','approx','stats','svg'}
functions=[n for n in tree.body if isinstance(n,ast.FunctionDef)and n.name in names]
assert {n.name for n in functions}==names
exec(compile(ast.Module(body=functions,type_ignores=[]),str(parent),'exec'))
parentId=pin(parent)

def quantiles(values):
    xs=sorted(values)
    def q(p):
        at=(len(xs)-1)*p;i=math.floor(at);j=math.ceil(at)
        return xs[i]+(xs[j]-xs[i])*(at-i)
    return dict(min=xs[0],p10=q(.1),p25=q(.25),median=q(.5),p75=q(.75),p90=q(.9),p95=q(.95),max=xs[-1],method='Linear interpolation at (n-1)*p, one value per source')

def population(rows,metric):
    b=[x['roles']['direct'][metric]['median']for x in rows];t=[x['roles']['typescript'][metric]['median']for x in rows]
    assert all(x>0 for x in b+t);ratios=[x/y for x,y in zip(b,t)];sb=sum(b);st=sum(t)
    weighted=sum((y/st)*r for y,r in zip(t,ratios));approx(weighted,sb/st)
    return dict(sources=len(rows),metric=metric,equalSourceGeometricMeanRatio=math.exp(sum(math.log(x)for x in ratios)/len(ratios)),
        ratioOfSumMedians=sb/st,ratioOfSumMediansMeaning='TS-time-weighted arithmetic mean of B2/TS source ratios; weight=TS median/sum(TS medians)',
        typescriptTimeWeightedArithmeticRatio=weighted,sumB2MediansMs=sb,sumTsMediansMs=st,sumMedianGapsMs=sb-st,
        ratios=quantiles(ratios),b2Ms=quantiles(b),typescriptMs=quantiles(t),gapMs=quantiles([x-y for x,y in zip(b,t)]),
        b2FasterCount=sum(x<1 for x in ratios),within10PercentCount=sum(.9<=x<=1.1 for x in ratios),within20PercentCount=sum(.8<=x<=1.2 for x in ratios))

catalogId,catalog=read(a.catalog)
assert catalog['kind']=='phase60-compiler-corpus-catalog'and catalog['complete']and catalog['pass']and catalog['inputsUnchanged']
assert catalog['counts']==dict(points=45,compileInputs=23,uniqueRuntimeModulesPerRole=24,observerModulesPerRole=1)
assert catalog['selected']['directB2']['sha256']=='a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081'
assert catalog['selected']['source']['sha256']=='85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091'
assert catalog['upstreamCommit']=='018751270e800bc222a93dad7f257083ee53a5f7'
pin(catalog['producer']);pin(catalog['qualification']['index'])
byId={x['id']:x for x in catalog['compileInputs']};assert len(byId)==23
assert len({(x['source']['file'],x['source']['sha256'])for x in byId.values()})==23
pointIds=[p for x in byId.values()for p in x['pointIds']];assert len(pointIds)==len(set(pointIds))==45 and set(pointIds)=={x['id']for x in catalog['points']}
for c in byId.values():
    assert c['options']==dict(mode='library',backend='direct')and c['roots']=='ordinary-library-exports';pin(c['source'])
    for role in ['direct','typescript']:pin(c['references'][role])

rid,r=read(a.report);cid,c=read(r['config'])
assert r['kind']=='phase60-candidate-image-library-latency'and r['mode']==c['mode']=='clean'
assert c['roles']==['direct','typescript']and c['rounds']==3 and c['warmRequests']==3 and c['comparison']=='fixed-source'
assert c['upstreamCommit']==catalog['upstreamCommit']and c['node']['sha256']==catalog['node']['sha256']
assert len(c['cases'])==23 and {x['id']for x in c['cases']}==set(byId)
for case in c['cases']:assert case==byId[case['id']]
assert c['catalog']['sha256']==catalogId['sha256']
assert r['coverage']['freshRuntimeExecutions']==0 and r['coverage']['oracleFreshness']=='inherited-qualified'
assert set(r['coverage']['compileInputIds'])==set(byId)and set(r['coverage']['pointIds'])==set(pointIds)
assert any(x['sha256']==catalogId['sha256']and Path(x['file']).resolve()==Path(catalogId['file'])for x in c['inputs'])
for key,val in dict(cpu=3,heapMiB=1024,rssMiB=2048,availableMiB=4096).items():assert c['resources'][key]==val
for x in c['inputs']:pin(x)
methodId,method=read(r['methodDerivation']);assert method['kind']in ['phase60-survey-method-derivation','phase60-survey-method-preflight-successor']and method['complete']and method['dataOnly']and not method['targetExecuted']
if 'parentDerivation'in method:pin(method['parentDerivation'])
for derivation in method['derivations']:
    pin(derivation['parent']);pin(derivation['output'])
assert any(d['output']['file'].endswith('/run.py')and any(x['file']==d['output']['file']and x['sha256']==d['output']['sha256']for x in c['inputs'])for d in method['derivations'])
pin(c['imageBindings'])
expected={(source,role,i)for source in byId for role in c['roles']for i in range(3)}
seen=[];good={};failures=[]
expectedOrder=[(case['id'],role,i)for case in c['cases']for i in range(3)for role in c['roles'][i%2:]+c['roles'][:i%2]]
if [(x.get('case'),x.get('role'),x.get('sample'))for x in r['rows']]!=expectedOrder:failures.append(dict(scope='campaign',error='Incomplete or noncanonical cyclic row order'))
if not(r.get('complete')and r.get('pass')):failures.append(dict(scope='campaign',error=r.get('error','Campaign did not complete successfully')))
for entry in r['rows']:
    key=(entry.get('case'),entry.get('role'),entry.get('sample'));seen.append(key)
    try:
        assert key in expected and seen.count(key)==1,'Unexpected or duplicate row'
        wid,w=read(entry['result']);assert w==entry['observation']and w['complete']and w['pass']
        ex=entry['execution'];assert ex['complete']and ex['returncode']==0
        assert ex['rssLimitBytes']==2048*1024**2 and ex['availableFloorBytes']==4096*1024**2
        assert any(d['output']['file']==ex['command'][-3]and d['output']['sha256']==next(x['sha256']for x in c['inputs']if x['file']==ex['command'][-3])for d in method['derivations'])
        assert ex['command'][:6]==['taskset','-c','3',c['node']['file'],'--stack-size=4096','--max-old-space-size=1024']and ex['command'][-1]==wid['file']
        assert w['kind']=='phase60-candidate-image-library-worker'and w['mode']=='clean'and w['cleanTiming']and w['stage']=='sample'
        assert w['role']==key[1]and w['sample']==key[2]and w['config']['sha256']==cid['sha256']and w['node']=='v24.18.0';pin(w['request'])
        source=byId[key[0]];assert w['source']['sha256']==source['source']['sha256']and w['source']['file']==source['source']['file']
        prepId,prep=read(w['preparation']);assert prep['complete']and prep['pass']and prep['role']==key[1]and prep['stage']=='prepare'
        prepared=next(x for x in prep['outputs']if x['id']==key[0]);assert prepared['source']['sha256']==source['source']['sha256']
        assert prepared['output']==w['expected'];pin(w['expected']);pin(w['output'])
        inherited=prepared['oracle'];assert inherited['kind']=='inherited-qualified-raw-module'and inherited['pass']and inherited['freshlyExecuted']is False
        assert inherited['catalog']['sha256']==catalogId['sha256']and inherited['pointIds']==source['pointIds']and inherited['points']==source['oracles']
        assert prepared['observation']==dict(freshCompilation=False,freshRuntimeExecution=False)
        for field in ['sha256','bytes']:assert w['output'][field]==w['expected'][field]==source['references'][key[1]][field]
        assert len(w['warmRequests'])==3
        for i,later in enumerate(w['warmRequests']):
            assert later['index']==i and finite(later['requestMs'])and later['output']=={k:w['expected'][k]for k in ['sha256','bytes']}
        if key[1]=='direct':
            assert w['image']==prep['image']and w['image']['api']['sha256']==catalog['selected']['directB2']['sha256']and w['image']['source']['sha256']==catalog['selected']['source']['sha256']
            for value in w['image'].values():
                if isinstance(value,dict)and 'sha256'in value:pin(value)
            assert prep['verification']['inputsUnchanged']and prep['verification']['copiesUnchanged']
            for x in prep['verification']['cacheFiles']:pin(x)
            assert w['observation']['typeAccepted']and w['observation']['checked']and w['observation']['status']=='ok'and w['observation']['backend']=='direct'
        else:assert prep['upstreamCommit']==catalog['upstreamCommit']
        clocks={k:w[k]for k in ['hostImportMs','apiLoadMs','firstRequestMs','importApiAndFirstMs']};assert all(finite(x)for x in clocks.values())
        approx(clocks['hostImportMs']+clocks['apiLoadMs']+clocks['firstRequestMs'],clocks['importApiAndFirstMs'])
        good[key]=dict(source=key[0],role=key[1],sample=key[2],worker=wid,preparation=prepId,clocks=clocks,
            laterRequestMs=[x['requestMs']for x in w['warmRequests']],workerWallMs=ex['wallSeconds']*1000,peakTreeRssBytes=ex['peakTreeRssBytes'],output=w['output'])
    except Exception as error:failures.append(dict(source=key[0],role=key[1],sample=key[2],error=repr(error)))
missing=sorted(expected-set(seen));rejected=sorted(expected-set(good));completePairs=[];sources=[]
for id,source in byId.items():
    row=dict(id=id,source=source['source'],sourceBytes=source['source']['bytes'],pointIds=source['pointIds'],roles={},complete=False)
    for role in c['roles']:
        rows=[good[(id,role,i)]for i in range(3)if(id,role,i)in good]
        if len(rows)!=3:row['roles'][role]=dict(complete=False,successfulRows=len(rows));continue
        values={k:stats([x['clocks'][k]for x in rows])for k in rows[0]['clocks']}
        values['warmRequestMedianMs']=stats([statistics.median(x['laterRequestMs'])for x in rows])
        for key,value in values.items():assert value==r['statistics'][id][role][key],(id,role,key)
        values.update(complete=True,successfulRows=3,laterByPosition=[stats([x['laterRequestMs'][j]for x in rows])for j in range(3)],
            startupMs=stats([x['clocks']['hostImportMs']+x['clocks']['apiLoadMs']for x in rows]),workerWallMs=stats([x['workerWallMs']for x in rows]),
            peakTreeRssBytes=max(x['peakTreeRssBytes']for x in rows),outputBytes=rows[0]['output']['bytes'])
        row['roles'][role]=values
    if all(x['complete']for x in row['roles'].values()):
        row['complete']=True;row['b2OverTs']={k:row['roles']['direct'][k]['median']/row['roles']['typescript'][k]['median']for k in ['importApiAndFirstMs','firstRequestMs','startupMs','warmRequestMedianMs']}
        row['combinedGapMs']=row['roles']['direct']['importApiAndFirstMs']['median']-row['roles']['typescript']['importApiAndFirstMs']['median'];completePairs.append(row)
    sources.append(row)
passed=not failures and not rejected and len(completePairs)==23
metrics={k:population(completePairs,k)for k in ['importApiAndFirstMs','firstRequestMs','warmRequestMedianMs']}if passed else None
rankings=dict(byAbsoluteGap=[x['id']for x in sorted(completePairs,key=lambda x:(-x['combinedGapMs'],x['id']))],byRatio=[x['id']for x in sorted(completePairs,key=lambda x:(-x['b2OverTs']['importApiAndFirstMs'],x['id']))],byB2Cost=[x['id']for x in sorted(completePairs,key=lambda x:(-x['roles']['direct']['importApiAndFirstMs']['median'],x['id']))])
producer=pin(__file__)
for x in list(inputs.values()):pin(x,force=True)
result=dict(kind='phase60-clean-population-analysis',complete=passed,**{'pass':passed},dataOnly=True,targetExecuted=False,producer=producer,parentUtilityMethod=parentId,report=rid,catalog=catalogId,method=methodId,
 coverage=dict(expectedSources=23,runtimePoints=45,expectedWorkers=138,expectedRequests=552,observedRows=len(seen),successfulWorkers=len(good),successfulRequests=4*len(good),completeSourcePairs=len(completePairs),missingRows=missing,rejectedOrMissingRows=rejected,failures=failures),
 population=metrics,sources=sources,rankings=rankings,rows=list(good.values()),anchors=[x for x in sources if x['id']in ['lexer','test-evening-program']],
 costs=dict(preparationCampaign=r.get('preparationsReusedFrom'),preparationWorkers=[dict(role=(x.get('observation')or{}).get('role'),wallSeconds=(x.get('execution')or{}).get('wallSeconds'),success=x.get('success'),result=x.get('result'))for x in r.get('preparations',[])],preparationCostScope='Retained original preparation-worker costs, not allocated among sources or part of clean clocks',campaignWallSeconds=r.get('wallSeconds'),preparationSeconds=r.get('preparationSeconds'),measurementStageSeconds=r.get('measurementStageSeconds'),successfulWorkerWallSeconds=sum(x['workerWallMs']for x in good.values())/1000,maxSuccessfulTreeRssBytes=max((x['peakTreeRssBytes']for x in good.values()),default=0)),
 inputs=list(inputs.values()),inputsUnchanged=True,
 scope='Compilation of 23 sources, mapped to 45 retained runtime points; no new runtime execution. Full population statistics require all 138 workers. Each source has one GM weight. Ratio of sums is TS-time-weighted arithmetic, not the equal-source GM. Later calls remain still warming. Fresh process and primed disk cache, not cold filesystem. No diagnostic profile times or cross-campaign pooling.')
out.mkdir(parents=True);(out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
md=['# Phase60 clean compilation population','',result['scope'],'',f"Coverage: {len(good)}/138 successful workers; {len(completePairs)}/23 complete source pairs; 45 inherited runtime points.",'','| Source | Bytes | Points | B2 first+startup ms | TS first+startup ms | B2/TS | Gap ms | B2 later median ms | TS later median ms |','|---|---:|---:|---:|---:|---:|---:|---:|---:|']
for x in sources:
    if not x['complete']:md.append(f"| {x['id']} | {x['sourceBytes']} | {len(x['pointIds'])} | Incomplete | Incomplete | — | — | — | — |");continue
    b=x['roles']['direct'];t=x['roles']['typescript'];md.append(f"| {x['id']} | {x['sourceBytes']} | {len(x['pointIds'])} | {b['importApiAndFirstMs']['median']:.3f} | {t['importApiAndFirstMs']['median']:.3f} | {x['b2OverTs']['importApiAndFirstMs']:.4f} | {x['combinedGapMs']:.3f} | {b['warmRequestMedianMs']['median']:.3f} | {t['warmRequestMedianMs']['median']:.3f} |")
if metrics:
    md+=['','Population metrics (same campaign, one value per source):','']
    for key,value in metrics.items():md.append(f"- {key}: equal-source GM {value['equalSourceGeometricMeanRatio']:.6f}; ratio of summed medians {value['ratioOfSumMedians']:.6f}; min/median/max ratios {value['ratios']['min']:.6f}/{value['ratios']['median']:.6f}/{value['ratios']['max']:.6f}.")
    rows=[]
    for id in rankings['byAbsoluteGap']:
        x=next(x for x in sources if x['id']==id)
        for role in c['roles']:
            v=x['roles'][role]['importApiAndFirstMs']['median'];rows.append((id+' / '+('B2'if role=='direct'else 'TS'),[(role,v)],f'{v:.1f} ms'))
    svg('Clean first-request compilation cost','23 sources, sorted by absolute B2-minus-TS gap; median import + API load + first compile.',rows,out/'clean-costs.svg')
    # Log-ratio diagram keeps every source; ratios below1 favour B2.
    ordered=sorted(sources,key=lambda x:-x['b2OverTs']['importApiAndFirstMs']);logs=[math.log2(x['b2OverTs']['importApiAndFirstMs'])for x in ordered]
    lo=min(0,math.floor(min(logs)));hi=max(1,math.ceil(max(logs)));width=1100;height=110+len(ordered)*28
    sx=lambda v:340+(v-lo)/(hi-lo)*600
    parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}"><rect width="100%" height="100%" fill="white"/>','<g font-family="sans-serif" font-size="12">','<text x="20" y="28" font-size="20">B2 / TypeScript clean first-window ratios</text>','<text x="20" y="50">Same-campaign medians; logarithmic axis; one row per compilation source.</text>']
    for tick in range(lo,hi+1):parts+=[f'<line x1="{sx(tick)}" x2="{sx(tick)}" y1="70" y2="{height-20}" stroke="#dddddd"/>',f'<text x="{sx(tick)-12}" y="66">{2**tick:g}×</text>']
    for i,x in enumerate(ordered):
        y=92+i*28;ratio=x['b2OverTs']['importApiAndFirstMs'];at=sx(math.log2(ratio));parts+=[f'<text x="20" y="{y+4}">{html.escape(x["id"])}</text>',f'<line x1="{sx(0)}" x2="{at}" y1="{y}" y2="{y}" stroke="#176b99"/>',f'<circle cx="{at}" cy="{y}" r="4" fill="#176b99"/>',f'<text x="{at+8}" y="{y+4}">{ratio:.3f}×</text>']
    parts.append('</g></svg>');(out/'clean-ratios.svg').write_text('\n'.join(parts)+'\n')
if failures:md+=['','Failed/missing coverage is preserved; no full-population statistics are emitted.']+['- '+json.dumps(x)for x in failures]
(out/'report.md').write_text('\n'.join(md)+'\n')
print(json.dumps(dict(complete=passed,coverage=result['coverage'],population=metrics,out=str(out))))
raise SystemExit(0 if passed else 1)
