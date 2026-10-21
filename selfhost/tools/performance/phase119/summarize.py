"""Replay independent outputs and summarize unchanged-binary physical-PC evidence."""
import collections, importlib.util, math, statistics, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]; BASE=ROOT/'selfhost/build/phase119'
spec=importlib.util.spec_from_file_location('refresh119',Path(__file__).with_name('refresh.py'))
R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R);S=R.S;O=R.O
OUT=ROOT/'implementation/phase119';OUT.mkdir(exist_ok=True)
def gm(xs):return math.exp(statistics.mean(math.log(x) for x in xs))
manifest=S.read(BASE/'manifest01.json')
clean=S.read(BASE/'clean01/report.json');native=S.read(BASE/'native01/report.json');compiler=S.read(BASE/'compiler01/report.json')
assert all(x['complete'] for x in [manifest,clean,native,compiler])
assert len(clean['rows'])==54 and len(native['rows'])==36 and len(compiler['rows'])==12
for pin in manifest['inputs']:S.verify(pin)
libc=Path('/usr/lib/x86_64-linux-gnu/libc-2.31.so');libc_pin=S.pin(libc)
assert libc_pin['sha256']=='d13f170ab30a0f91d9713e0c2196efa5fe0bc42f0f2737cf0e56380df8051159'
libc_segments=S.A.load_segments(libc)
assembly=OUT/'libc-copy-fill.asm'
assembly.write_text(subprocess.check_output(['objdump','-d','-M','intel','--start-address=0xa3930','--stop-address=0xa3de3',str(libc)],text=True))
inputs=[S.pin(__file__),S.pin(BASE/'manifest01.json'),S.pin(BASE/'clean01/report.json'),S.pin(BASE/'native01/report.json'),S.pin(BASE/'compiler01/report.json'),libc_pin,S.pin(assembly)]
def replay(rows, compiling=False):
    for row in rows:
        S.verify(row['stdout']);S.verify(row['stderr']);S.verify(row['product'])
        stdout=Path(row['stdout']['file']).read_bytes();stderr=Path(row['stderr']['file']).read_bytes()
        if compiling:
            c=next(x for x in manifest['compilers'] if x['role']==row['role']);S.verify(c['oracle'])
            assert row['status']==0 and not stderr and stdout==Path(c['oracle']['file']).read_bytes()
        else:
            c=next(x for x in manifest['cases'] if x['name']==row['case'])
            one=dict(c['oracle'],repetitions=row['repetitions'],warmups=row['warmups'])
            assert O.observation(stdout,stderr,row['status'],one,row['wallSeconds'])==row['elapsedMs']
        if 'profile' in row:
            S.verify(row['profile']);S.verify(row['analysis'])
            recomputed=S.analyze(row['profile']['file'],row['product']['file'])
            assert recomputed==S.read(row['analysis']['file'])
replay(clean['rows']);replay(native['rows']);replay(compiler['rows'],True)

def pool(rows):
    counts=collections.Counter();library=collections.Counter();caps=[];pc_counts=collections.Counter()
    for row in rows:
        a=S.read(row['analysis']['file']);assert a['usable'] and a['zeroLoss']
        caps.append(dict(samples=a['header']['samples'],periodUs=a['header']['period_us'],overruns=a['header']['overruns'],dropped=a['header']['dropped'],coverage=a['coverage']['sampled_thread_cpu_fraction'],analysis=row['analysis']))
        for s in a['symbols']:counts[(s['name'],s['decoded'])]+=s['samples']
        header,maps,pcs=S.A.parse(row['profile']['file'])
        for pc,n in pcs.items():
            mapping=next((m for m in maps if m['start']<=pc<m['end']),None)
            if mapping and mapping['path']==str(libc):
                va=S.A.virtual_address(pc,mapping,libc_segments)
                kind='copy' if va is not None and 0xa3930<=va<0xa3c24 else 'fill' if va is not None and 0xa3c30<=va<0xa3de3 else 'other'
                library[kind]+=n;pc_counts[(kind,va)]+=n
    total=sum(counts.values());assert total>=500
    return dict(samples=total,captures=caps,libc={k:dict(samples=v,fraction=v/total) for k,v in library.items()},
                libcPCs=[dict(kind=k[0],address=hex(k[1]) if k[1] is not None else None,samples=v) for k,v in pc_counts.most_common()],
                symbols=[dict(name=k[0],decoded=k[1],samples=v,fraction=v/total) for k,v in counts.most_common()])

result=dict(complete=True,inputs=inputs,outputReplayCount=102,cases=[],programProfiles=[],compilerProfiles=[],
            scope='Six selected diagnostic programs, not a new broad45 score. Three clean rounds; two physical-PC periods. Shared kernels may have different inlining boundaries. Library leaves are not caller attribution or allocation counts.')
for c in manifest['cases']:
    med={role:statistics.median(x['elapsedMs'] for x in clean['rows'] if x['case']==c['name'] and x['role']==role) for role in c['products']}
    result['cases'].append(dict(name=c['name'],mediansMs=med,ratiosToUpstreamC={k:v/med['upstream_c'] for k,v in med.items()}))
    for role in c['products']:
        rows=[x for x in native['rows'] if x['case']==c['name'] and x['role']==role]
        result['programProfiles'].append(dict(case=c['name'],role=role,**pool(rows)))
for c in manifest['compilers']:
    rows=[x for x in compiler['rows'] if x['role']==c['role']]
    result['compilerProfiles'].append(dict(role=c['role'],cleanSeconds=[x['seconds'] for x in rows if not x['periodUs']],**pool([x for x in rows if x['periodUs']])))
result['diagnosticSubsetGeomeanRatiosToUpstreamC']={role:gm(c['ratiosToUpstreamC'][role] for c in result['cases']) for role in ['upstream_c','selfhost_c','qbe']}
result['totalSamples']=sum(x['samples'] for x in result['programProfiles']+result['compilerProfiles'])
result['zeroLossCaptures']=sum(len(x['captures']) for x in result['programProfiles']+result['compilerProfiles'])
S.save(OUT/'results.json',result)
S.save(BASE/'independent-replay01.json',dict(complete=True,observations=102,analysisRecomputed=44,inputs=inputs))
print('ratios',result['diagnosticSubsetGeomeanRatiosToUpstreamC'],'samples',result['totalSamples'])
for p in result['programProfiles']+result['compilerProfiles']:
    if p['role'] in ['qbe','phase114','phase118']:
        print(p.get('case','compiler'),p['role'],p['samples'],p.get('cleanSeconds'),[(x['decoded'],round(x['fraction']*100,2)) for x in p['symbols'][:12]],'libc',p['libc'])
