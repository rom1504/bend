"""Retain the complete raw observations and a checked small decision record."""
import gzip
import json
from pathlib import Path
import statistics
from project import BUILD, HERE, sha

RUNS={'first-session':'allocation-screen01','replication':'allocation-replication01','ray':'allocation-ray01'}

def save(name,run):
    d=BUILD/'phase198'/run
    f=d/'report.json'
    r=json.loads(f.read_text())
    capture=HERE/(name+'.json.gz')
    capture.write_bytes(gzip.compress(f.read_bytes(),compresslevel=9,mtime=0))
    assert gzip.decompress(capture.read_bytes())==f.read_bytes()
    retained=d.with_name(run+'-guard')/'retention.json'
    guard=json.loads(retained.read_text())
    assert r['complete'] and guard['closed'] and guard['outcome']=='succeeded'
    assert guard['classification']=='completed'
    summary={}
    for case,row in r['cases'].items():
        times=row.get('timing',row.get('timings'))
        assert len(times)==len({(t['layout'],t['round'],t['role']) for t in times})
        cases={}
        groups={(t['layout'],t['role']) for t in times}
        def sample(layout,role):
            ls=sorted((t for t in times if (t['layout'],t['role'])==(layout,role)),key=lambda t:t['round'])
            assert len(ls)==4
            return [t['elapsedMs'] for t in ls]
        for layout,role in sorted(groups):
            if role=='baseline':continue
            pair=[b/a for a,b in zip(sample(layout,'baseline'),sample(layout,role))]
            key=layout+':'+role+'/baseline'
            result=row['comparisons'].get(key)
            if result is None:result=row['comparisons'][layout][role]
            assert result['ratios']==pair
            cases[key]={'median':statistics.median(pair),'faster':sum(x<1 for x in pair)}
        summary[case]=cases
    return dict(raw=sha(f),compressed=sha(capture),guard=sha(retained),seconds=r['wall'],cases=summary)
rows={}
for name,run in RUNS.items():
    r=BUILD/'phase198'/run/'report.json'
    if r.is_file() and json.loads(r.read_text()).get('complete'):
        rows[name]=save(name,run)
(HERE/'decisions.json').write_text(json.dumps(dict(method=sha(Path(__file__)),runs=rows),indent=2)+'\n')
