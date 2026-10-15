#!/usr/bin/env python3
"""Offline aggregation of qualified native generated-program samples."""
import argparse, csv, json, math, statistics
from pathlib import Path
from run import ROOT, collect_products, pin, read, verify

def gm(values):return math.exp(statistics.mean(math.log(x) for x in values))

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--acquired',type=Path,nargs='+',required=True)
    p.add_argument('--timing',type=Path,nargs='+',required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    cases=collect_products(a.acquired);assert len(cases)==45
    samples=[]
    for path in a.timing:
        report=read(path);assert report['complete'] and report['kind']=='phase93-native-runtime-measure'
        assert all(r['correct'] and r['qualified'] and r['elapsedMs']>=100 for r in report['records'])
        samples.extend(report['records'])
    rows=[]
    for name,case in cases.items():
        roles={}
        for role in ['own','upstream']:
            selected=[r for r in samples if r['case']==name and r['role']==role]
            assert len(selected)==3 and {r['round'] for r in selected}=={1,2,3}
            assert len({r['repetitions'] for r in selected})==1
            for r in selected:
                child=read(verify(r['child'])['file'])
                assert child['returncode']==0 and not child['stderr']
                expected=case['expected']+'\n'+str(r['warmups'])+'\n'+str(r['repetitions'])+'\n'+str(r['elapsedMs'])+'\n'
                assert child['stdout']==expected and child['processSeconds']==r['processSeconds']
            values=[1000*r['elapsedMs']/r['repetitions'] for r in selected]
            roles[role]=dict(medianUs=statistics.median(values),samplesUs=values,minUs=min(values),maxUs=max(values),
                relativeRange=(max(values)-min(values))/statistics.median(values),repetitions=selected[0]['repetitions'])
        assert roles['own']['repetitions']==roles['upstream']['repetitions']
        rows.append(dict(id=name,family=case['family'],original=case['original'],point=case['point'],
                         roles=roles,ratio=roles['own']['medianUs']/roles['upstream']['medianUs']))
    catalog=read(ROOT/'selfhost/tools/performance/phase37/catalog.json')
    order={c['id']:i for i,c in enumerate(catalog['cases'])};rows.sort(key=lambda r:order[r['id']])
    groups={}
    for row in rows:groups.setdefault(row['original']['sha256'],[]).append(row)
    assert len(groups)==23
    grouped=[dict(source=g[0]['original'],points=[r['id'] for r in g],ratio=gm(r['ratio'] for r in g)) for g in groups.values()]
    summary=dict(complete=True,method=pin(__file__),inputs=[pin(p) for p in a.acquired+a.timing],points=45,originalSources=23,
        samples=len(samples),nativeB1B2ExactProducts=45,equalPointGeomean=gm(r['ratio'] for r in rows),
        equalSourceGeomean=gm(r['ratio'] for r in grouped),medianPointRatio=statistics.median(r['ratio'] for r in rows),
        ownFaster=sum(r['ratio']<1 for r in rows),ownSlower=sum(r['ratio']>1 for r in rows),exactMedianTie=sum(r['ratio']==1 for r in rows),
        minimumTimedMs=min(r['elapsedMs'] for r in samples),rows=rows,sourceGroups=grouped,
        scope='Fresh original45 fixed-input native batches; own/upstream C11-O3, CPU3, one thread, GPU off. Three fresh processes per role/point. Inner milliseconds include result validation/loop/final counter print, exclude compilation/startup/warmup. Own products are byte-identical between actual native B1 and B2. No JS-versus-C ratio or universal speed claim.')
    a.out.mkdir(parents=True,exist_ok=True)
    for name in ['summary.json','timings.csv']:assert not (a.out/name).exists()
    (a.out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    with (a.out/'timings.csv').open('w') as stream:
        writer=csv.writer(stream);writer.writerow(['point','own_us','upstream_us','own_over_upstream','own_range_fraction','upstream_range_fraction'])
        for row in rows:writer.writerow([row['id'],row['roles']['own']['medianUs'],row['roles']['upstream']['medianUs'],row['ratio'],row['roles']['own']['relativeRange'],row['roles']['upstream']['relativeRange']])
    print(json.dumps({k:v for k,v in summary.items() if k not in ['rows','sourceGroups','inputs','scope','method']}))

if __name__=='__main__':main()
