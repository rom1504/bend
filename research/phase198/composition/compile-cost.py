"""Separate N1 program-object compilation cost from generated-program execution."""
import argparse
import hashlib
import json
from pathlib import Path
from statistics import geometric_mean,median

def read(p):return json.loads(p.read_bytes())
def pin(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size}
def collect(path):
    source=path/'programs.manifest.json';catalog=read(source);main=read(path/'report.json')
    assert main['complete'] and not main['changedInputs'] and len(catalog['cases'])==45
    rows={}
    for case in catalog['cases']:
        r=read(path/case['id']/'machine/report.json');request=r['request']
        assert r['complete'] and r['host']=='native' and r['target']=='x86' and r['emit']=='object'
        assert r['stage']=='N1' and request['source']==case['source'] and r['runtimeABI']==11102
        j={a['label']:a for a in r['jobs']}
        assert all(x['complete'] and x['exitCode']==0 for x in j.values())
        obj=case['products']['candidate']['generatedSource']
        rows[case['id']]={'source':case['source']['sha256'],'casePoint':case['point'],'runtime':r['runtime']['sha256'],
            'toolchain':r['toolchain'],'base':request['base'],'carrier':request['carrier'],'compiler':request['image']['sha256'],
            'outputBytes':obj['bytes'],'compileSeconds':j['compiler']['seconds'],'compileCpu':j['compiler']['systemSeconds']+j['compiler']['userSeconds'],
            'linkSeconds':j['link']['seconds'],'maxRssKiB':j['compiler']['peakRssKiB']}
    assert len({x['compiler'] for x in rows.values()})==1
    return rows,{'manifest':pin(source),'main':pin(path/'report.json'),'wholeCatalogSeconds':main['seconds']}
def run(a,b,out):
    before,pa=collect(a);after,pb=collect(b);assert before.keys()==after.keys()
    for k in before: assert all(before[k][f]==after[k][f] for f in ('source','runtime','toolchain','base','carrier','casePoint'))
    def sumup(rows):
        return {**{k:sum(row[k] for row in rows.values()) for k in ('outputBytes','compileSeconds','compileCpu','linkSeconds')},
            'maximumCompilerRssKiB':max(v['maxRssKiB'] for v in rows.values()),
            'medianCompilerRssKiB':median(v['maxRssKiB'] for v in rows.values())}
    x,y=sumup(before),sumup(after)
    obj={'reference':pa,'candidate':pb,'referenceTotals':x,'candidateTotals':y,
         'candidateOverReference':{k:y[k]/x[k] for k in x},'geometricEmitWallRatio':geometric_mean(after[k]['compileSeconds']/v['compileSeconds'] for k,v in before.items()),
         'scope':'45 complete identical sources with prepared Base, one fresh native N1 compiler process per source. Wall and process CPU pertain only to compiler-to-object. Link and total catalog have their own intervals. One pass per image, separate clock times. No randomized repeated compiler-time significance claim.',
         'method':pin(Path(__file__)),'perCase':{k:{role:{f:r[k][f] for f in ['compileSeconds','compileCpu','linkSeconds','maxRssKiB','outputBytes','source','compiler']} for role,r in [('before',before),('after',after)]} for k in before}}
    out.write_text(json.dumps(obj,indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline','candidate','out']:p.add_argument(name,type=Path)
    a=p.parse_args();run(a.baseline,a.candidate,a.out)
