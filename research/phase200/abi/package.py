"""Collect all completed cases and preserve failures without treating them as passes."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile
HERE=Path(__file__).resolve().parent
BUILD=HERE.parents[2]/'selfhost/build/phase199'
def read(p):return json.loads(p.read_text())
def pin(p):return dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
    src=BUILD/'p200-ownership-source02/compiler.bend'
    api_dir=BUILD/'p200-ownership-api01'
    api=read(api_dir/'report.json')
    assert api['complete'] and api['checked'] and pin(src)['sha256']==api['source']['sha256']
    first=BUILD/'p200-ownership-focus01';second=BUILD/'p200-ownership-focus02';third=BUILD/'p200-ownership-focus03'
    runs=[first,second]
    if third.exists() and third.with_name(third.name+'-guard').joinpath('retention.json').exists():runs.append(third)
    emission=read(first/'emission/report.json')
    assert emission['complete'] and emission['api']==api['api'] and emission['checkedSource']==api['source']
    assert len(emission['cases'])==3 and all(c['changed'] for c in emission['cases'])
    assert [c['id'] for c in emission['cases']]==['raytrace','coverage-map-churn-128','coverage-record-aggregation-256']
    rows=[];paths=[first/'emission/report.json'];statuses={}
    for run in [api_dir,*runs]:
        guard=run.with_name(run.name+'-guard')
        proc,ret=map(read,[guard/'process.json',guard/'retention.json'])
        assert ret['closed'] and proc['method']['cpu']=='3'
        statuses[run.name]={k:proc[k] for k in ('returncode','wallSeconds')}
        if proc.get('stoppedFor'):statuses[run.name]['stoppedFor']=proc['stoppedFor']
        paths.extend([run/'report.json',*[guard/x for x in ('process.json','retention.json','stdout.log','stderr.log')]])
        if run==api_dir:continue
        result=read(run/'report.json')
        if run in (first,second):
            method_bytes=gzip.decompress((HERE/('screen01.py.gz' if run==first else 'screen02.py.gz')).read_bytes())
            assert hashlib.sha256(method_bytes).hexdigest()==result['method']['sha256']
        else:
            assert result['method']['sha256']==pin(HERE/'screen.py')['sha256'] and result['complete']
        for case in result['cases']:
            if 'candidateOverBaseline' not in case:continue
            before,after=case['counts']['baseline'],case['counts']['candidate']
            assert not {k for k in after if int(k.split()[1])<2}
            assert all(before.get(k,0)==after.get(k,0) for k in before|after if int(k.split()[1])>=2)
            assert all(pin(Path(v['file']))['sha256']==v['sha256'] for v in case['objects'].values())
            assert all(len(samples)==3 and min(x['elapsedMs'] for x in samples)>=100 for samples in case['samples'].values())
            row={k:case[k] for k in ('id','objects','counts','skippedImmediateCalls','candidateOverBaseline','candidateOverC')}
            row['run']=run.name;rows.append(row)
    assert statuses[first.name]['stoppedFor']=='disk-budget' and statuses[second.name]['returncode']!=0
    archive=HERE/'evidence.tar.gz'
    with archive.open('wb') as stream,gzip.GzipFile(filename='',fileobj=stream,mode='wb',mtime=0) as z:
        with tarfile.open(fileobj=z,mode='w|') as t:
            for p in sorted(paths):
                h=t.gettarinfo(str(p),str(p.relative_to(BUILD)));h.mtime=h.uid=h.gid=0;h.uname=h.gname=''
                with p.open('rb') as f:t.addfile(h,f)
    summary=dict(complete=True,completeDistinctCases=len({r['id'] for r in rows}),source=api['source'],api=api['api'],emission=pin(first/'emission/report.json'),
                 guardOutcomes=statuses,archive=pin(archive),archived={str(p.relative_to(BUILD)):pin(p) for p in sorted(paths)},rows=rows)
    (HERE/'results.json').write_text(json.dumps(summary,indent=2)+'\n')
if __name__=='__main__':main()
