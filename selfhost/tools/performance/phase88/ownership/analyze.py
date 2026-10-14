#!/usr/bin/env python3
"""Offline phase/caller analysis of Phase88's exact-image ownership samples."""
import argparse, collections, importlib.util, json, re, sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('phase68_samples',ROOT/'selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py')
A=importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
OWNERSHIP={'term_drop','span_fade','rfc_wrap'}

def read_samples(path):
    lines=path.read_text().splitlines()
    assert lines[0]=='BEND_OWNERSHIP_CPU_SAMPLES_V1' and lines[-1]=='END','incomplete sample file'
    mi,si,ki=(lines.index(x) for x in ('MAPS','SAMPLES','MARKS'))
    header=dict(line.split('\t',1) for line in lines[1:mi])
    for k,v in list(header.items()):
        if v.isdigit(): header[k]=int(v)
    maps=[]
    for line in lines[mi+1:si]:
        f=line.split(maxsplit=5);lo,hi=(int(x,16) for x in f[0].split('-'))
        maps.append(dict(start=lo,end=hi,permissions=f[1],offset=int(f[2],16),path=f[5] if len(f)>5 else ''))
    samples=[]
    for line in lines[si+1:ki]:
        f=line.split('\t');assert len(f)==6
        samples.append(dict(tid=int(f[0]),mono=int(f[1]),pc=int(f[2],16),callers=[int(x,16) for x in f[3:] if int(x,16)]))
    marks=[]
    for line in lines[ki+1:-1]:
        f=list(map(int,line.split('\t')));assert len(f)==4
        marks.append(dict(index=f[0],tid=f[1],mono=f[2],cpu=f[3]))
    assert len(samples)==header['samples'] and samples
    assert header['tid']==header['final_tid']==header['pid']
    assert header['handler_intact']==1 and header['dropped']==0
    assert all(s['mono']>0 for s in samples)
    assert all(m['index']==i and m['tid']==header['tid'] and m['cpu']>0 for i,m in enumerate(marks))
    assert all(x['mono']<y['mono'] and x['cpu']<=y['cpu'] for x,y in zip(marks,marks[1:]))
    return header,maps,samples,marks

def make_phases(marks,stderr):
    base=re.findall(r'^base_prepare_ms=(\d+)$',stderr,re.M)
    runtime=re.findall(r'^runtime_prepare_ms=(\d+)$',stderr,re.M)
    req=re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$',stderr,re.M)
    assert len(base)==len(runtime)==1 and req,'missing complete host markers'
    assert [int(r[0]) for r in req]==list(range(1,len(req)+1))
    assert len(req) in (1,5) and len(marks)==4+2*len(req),(len(req),len(marks))
    jobs=[('base',int(base[0])),('runtime',int(runtime[0]))]+[(f'request-{n}',int(ms)) for n,ms,_ in req]
    phases=[]
    for i,(name,expected) in enumerate(jobs):
        before,after=marks[2*i:2*i+2]
        observed=after['mono']//1000000-before['mono']//1000000
        assert observed==expected,(name,observed,expected,'IO.now and stderr disagree')
        phases.append(dict(name=name,start_ns=before['mono'],end_ns=after['mono'],
            wall_ms=(after['mono']-before['mono'])/1e6,process_cpu_ms=(after['cpu']-before['cpu'])/1e6,reported_ms=expected))
    return phases

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--samples',type=Path,required=True);p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--table',type=Path,required=True);p.add_argument('--stderr',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    assert not a.out.exists(),'output must be fresh'
    header,maps,samples,marks=read_samples(a.samples)
    table=json.loads(a.table.read_text());binary=a.binary.resolve();binary_sha=A.sha(binary)
    assert header['target_sha256']==table['binary_sha256']==binary_sha,'CFI table bound to different executable'
    assert Path(header['exe']).resolve()==binary,'sampled executable path mismatch'
    phases=make_phases(marks,a.stderr.read_text())
    coverage=A.coverage_summary(header)
    assert coverage['usable_for_process_cpu_attribution'],coverage
    segments=A.load_segments(binary)
    main_maps=[m for m in maps if m['path'] and Path(m['path']).resolve()==binary]
    def address(pc):
        for m in main_maps:
            if m['start']<=pc<m['end']: return A.virtual_address(pc,m,segments)
        return None
    addresses={v for s in samples for pc in [s['pc'],*(r-1 for r in s['callers'])] if (v:=address(pc)) is not None}
    symbols=A.symbolize(binary,addresses)
    def describe(pc):
        v=address(pc)
        if v is not None:
            frames=symbols[v];return dict(function=frames[0]['function'],address=hex(v),frames=frames)
        for m in maps:
            if m['start']<=pc<m['end']: return dict(function='[outside] '+m['path'],address=hex(pc))
        return dict(function='[unmapped]',address=hex(pc))
    counters={x['name']:dict(leaf=collections.Counter(),owner=collections.Counter(),sites=collections.Counter(),total=0,ownership=0,recovered=0) for x in phases}
    counters['outside']=dict(leaf=collections.Counter(),owner=collections.Counter(),sites=collections.Counter(),total=0,ownership=0,recovered=0)
    for s in samples:
        name=next((x['name'] for x in phases if x['start_ns']<=s['mono']<x['end_ns']),'outside')
        c=counters[name];leaf=describe(s['pc']);c['total']+=1;c['leaf'][leaf['function']]+=1
        if leaf['function'] in OWNERSHIP:
            c['ownership']+=1
            chain=[describe(pc-1) for pc in s['callers']]
            resolved=bool(chain and chain[-1]['function'] not in OWNERSHIP and not chain[-1]['function'].startswith('['))
            owner=chain[-1]['function'] if resolved else '[unresolved physical owner]'
            c['recovered']+=resolved
            c['owner'][(leaf['function'],owner)]+=1
            c['sites'][(leaf['function'],tuple((x['function'],x['address']) for x in chain))]+=1
    result=[]
    for name,c in counters.items():
        desc=next((dict(x) for x in phases if x['name']==name),dict(name=name))
        desc.update(samples=c['total'],ownership_samples=c['ownership'],ownership_physical_owner_recovered=c['recovered'])
        desc['leaf_functions']=[dict(function=f,samples=n,percent=100*n/c['total']) for f,n in c['leaf'].most_common()]
        desc['ownership_callers']=[dict(leaf=k[0],physical_owner=k[1],samples=n,percent_phase=100*n/c['total']) for k,n in c['owner'].most_common()]
        desc['ownership_return_sites']=[dict(leaf=k[0],chain=[dict(function=f,address=addr) for f,addr in k[1]],samples=n) for k,n in c['sites'].most_common()]
        desc['precision']='low sample count' if c['total']<200 else 'sampling estimate; not an instrumented invocation count'
        result.append(desc)
    report=dict(schema='phase88-ownership-analysis-v1',header=header,coverage=coverage,marks=marks,phases=result,
        identities=dict(binary_sha256=binary_sha,samples_sha256=A.sha(a.samples),table_sha256=A.sha(a.table),stderr_sha256=A.sha(a.stderr),analyzer_sha256=A.sha(__file__)),
        limitations=['Caller chains are physical return addresses recovered only through the three bounded ownership helpers.',
            'Musttail-eliminated Bend frames and inline ownership operations are not reconstructed.',
            'Phase boundaries come from existing IO.now calls, validated exactly against printed millisecond differences.',
            'Samples include profiler overhead; these times are not optimization speed results.',
            'No instruction/cache counters establish the cumulative slowdown cause.'])
    a.out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps([dict(name=x['name'],samples=x['samples'],ownership=x['ownership_samples'],recovered=x['ownership_physical_owner_recovered']) for x in result]))
if __name__=='__main__':main()
