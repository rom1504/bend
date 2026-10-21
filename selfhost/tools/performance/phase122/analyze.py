"""Replay complete outputs and physical-PC profiles; quantify the frozen remaining gap."""
import collections, importlib.util, math, statistics
from pathlib import Path

ROOT=Path(__file__).resolve().parents[4]; BASE=ROOT/'selfhost/build/phase122'
spec=importlib.util.spec_from_file_location('survey122',Path(__file__).with_name('survey.py'))
R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R);S=R.S;O=R.O
out=ROOT/'implementation/phase122/results.json'; assert not out.exists()
m=S.read(BASE/'manifest01.json'); clean=S.read(BASE/'clean01/report.json'); prof=S.read(BASE/'profile01/report.json')
assert m['complete'] and clean['complete'] and prof['complete']
assert len(clean['rows'])==90 and len(prof['rows'])==60
for item in m['inputs']:S.verify(item)
libc=Path('/usr/lib/x86_64-linux-gnu/libc-2.31.so'); libcpin=S.pin(libc)
assert libcpin['sha256']=='d13f170ab30a0f91d9713e0c2196efa5fe0bc42f0f2737cf0e56380df8051159'
libsegments=S.A.load_segments(libc)
for row in clean['rows']+prof['rows']:
    for key in ['product','stdout','stderr']:S.verify(row[key])
    c=next(x for x in m['cases'] if x['name']==row['case'])
    assert O.observation(Path(row['stdout']['file']).read_bytes(),Path(row['stderr']['file']).read_bytes(),
      row['status'],dict(c['oracle'],repetitions=row['repetitions'],warmups=row['warmups']),row['wallSeconds'])==row['elapsedMs']
    if 'analysis' in row:
        S.verify(row['analysis']);S.verify(row['profile'])
        assert S.analyze(row['profile']['file'],row['product']['file'])==S.read(row['analysis']['file'])

def category(name):
    if name.startswith('p113d_FID_') or name.startswith('p114r_FID_'):return 'private_workers'
    if name.startswith(('p111_FID_', 'p111_seg_', 'seg_')):return 'generic_segments'
    if name in ['term_drop','span_fade','rfc_wrap','rfc_incr','rfc_decr']:return 'ownership'
    if 'p111_rt_ctor' in name or name in ['p118_destination_fill','p118_rt_extend1']:return 'construction'
    if 'p111_rt_take' in name or name in ['p118_rt_borrow_fields','p111_rt_special_take']:return 'destructure'
    if name in ['work_loop','p111_rt_jump','p111_rt_return','p111_set_regs','p111_rt_push','p111_rt_pop','p111_rt_apply','p111_rt_call']:return 'control_transport'
    if name=='p111_rt_op':return 'generic_primitive_dispatch'
    if name.startswith('<mapping:'):return 'library'
    return 'other'

def pool(rows):
    counts=collections.Counter();library=collections.Counter();caps=[]
    for row in rows:
        a=S.read(row['analysis']['file'])
        assert a['usable'] and a['zeroLoss'], row['analysis']['file']
        caps.append(dict(analysis=row['analysis'],samples=a['header']['samples'],periodUs=a['header']['period_us'],coverage=a['coverage'],
                         overruns=a['header']['overruns'],dropped=a['header']['dropped']))
        for x in a['symbols']:counts[(x['name'],x['decoded'])]+=x['samples']
        _,maps,pcs=S.A.parse(row['profile']['file'])
        for pc,n in pcs.items():
            mapping=next((v for v in maps if v['start']<=pc<v['end']),None)
            if mapping and mapping['path']==str(libc):
                va=S.A.virtual_address(pc,mapping,libsegments)
                kind='copy' if va is not None and 0xa3930<=va<0xa3c24 else 'fill' if va is not None and 0xa3c30<=va<0xa3de3 else 'other'
                library[kind]+=n
    total=sum(counts.values());assert total>=500
    cats=collections.Counter()
    for (name,decoded),n in counts.items():cats[category(name)]+=n
    return dict(samples=total,captures=caps,categories={k:dict(samples=n,fraction=n/total) for k,n in cats.items()},
                libc={k:dict(samples=n,fraction=n/total) for k,n in library.items()},
                symbols=[dict(name=k[0],decoded=k[1],samples=n,fraction=n/total) for k,n in counts.most_common()])

def gm(xs):return math.exp(statistics.mean(math.log(x) for x in xs))
result=dict(complete=True,inputs=[S.pin(__file__),S.pin(BASE/'manifest01.json'),S.pin(BASE/'clean01/report.json'),S.pin(BASE/'profile01/report.json'),libcpin],
            outputChecks=150,analysesRecomputed=60,cases=[],profiles=[],
            scope='Ten selected families; no new full45 performance score or optimizer change. Physical leaves have different inlining boundaries across backends. Categories are explicit convenience labels, not complete causal attribution.')
for c in m['cases']:
    samples={role:[x['elapsedMs'] for x in clean['rows'] if x['case']==c['name'] and x['role']==role] for role in c['products']}
    med={k:statistics.median(v) for k,v in samples.items()}
    result['cases'].append(dict(name=c['name'],family=c['family'],samplesMs=samples,mediansMs=med,
       qbeOverUpstream=med['qbe']/med['upstream_c'],cOverUpstream=med['selfhost_c']/med['upstream_c'],qbeOverC=med['qbe']/med['selfhost_c']))
    for role in c['products']:
        result['profiles'].append(dict(case=c['name'],role=role,**pool([x for x in prof['rows'] if x['case']==c['name'] and x['role']==role])))
result['totalSamples']=sum(x['samples'] for x in result['profiles'])
result['diagnosticSubsetRatios']={k:gm(x[k] for x in result['cases']) for k in ['qbeOverUpstream','cOverUpstream','qbeOverC']}

priorfile=ROOT/'implementation/phase121/results.json';prior=S.read(priorfile)
manifest=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json';original=S.read(manifest)
result['inputs'] += [S.pin(priorfile),S.pin(manifest)]
families={x['name']:x['family'] for x in original['cases']}
points=[x for x in prior['broad']['equalPoint']['cases'] if x['ratioEligible']]
excess={x['name']:max(0,x['mediansMs']['candidate']-x['mediansMs']['upstream']) for x in points}
groups=collections.defaultdict(list)
for x in points:groups[families[x['name']]].append(x)
total=sum(excess.values())
result['frozenCorpus']=dict(source=S.pin(priorfile),timedPoints=44,families=[],sumMedianMs={k:sum(x['mediansMs'][k] for x in points) for k in ['candidate','upstream']},
                           positiveExcessMs=total,geometricRatio=gm(x['candidateOverUpstream'] for x in points))
for f,rs in groups.items():
    e=sum(excess[x['name']] for x in rs)
    result['frozenCorpus']['families'].append(dict(family=f,cases=[x['name'] for x in rs],positiveExcessMs=e,positiveExcessShare=e/total,
       geometricRatio=gm(x['candidateOverUpstream'] for x in rs)))
result['frozenCorpus']['families'].sort(key=lambda x:-x['positiveExcessShare'])
result['frozenCorpus']['uniformRemainingSpeedupForGeometricParity']=result['frozenCorpus']['geometricRatio']**(44/40)
result['frozenCorpus']['counterfactuals']=[]
for label,factor in [('all40_slow_points_2x',2),('all40_slow_points_2_32x',2.32)]:
    ratios=[x['candidateOverUpstream']/(factor if x['candidateOverUpstream']>1.1 else 1) for x in points]
    result['frozenCorpus']['counterfactuals'].append(dict(label=label,geometricRatio=gm(ratios),assumption='Uniform hypothetical speedup of all40 points above1.1x; not a forecast.'))
S.save(out,result)
print('cases',result['diagnosticSubsetRatios'],'samples',result['totalSamples'])
for x in result['profiles']:
    if x['role']=='qbe':print(x['case'],[(y['decoded'],round(100*y['fraction'],1)) for y in x['symbols'][:8]],x['categories'])
