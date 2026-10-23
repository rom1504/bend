"""Plan ordinary native gates for the three frozen compiler-request sources."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[5]

def pin(file):
    file=Path(file).resolve();data=file.read_bytes()
    return dict(file=str(file),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--request',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    request=json.loads(a.request.read_text());assert request['complete']
    selected_file=ROOT/'implementation/phase130/candidate.json';selected=json.loads(selected_file.read_text())
    assert selected['complete'] and selected['nativeQualified']
    corpus_file=ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
    corpus=json.loads(corpus_file.read_text());rows=[x for x in request['rows'] if x['label']=='candidate']
    assert sorted(x['name'] for x in rows)==['coverage-closures-256','coverage-map-churn-128','lexer']
    inputs=[pin(__file__),pin(a.request),*request['inputs'],pin(corpus_file),pin(selected_file),selected['runtime'],
            pin(ROOT/'selfhost/tools/performance/phase111/guard.py'),pin(ROOT/'selfhost/tools/performance/phase123/build-aligned.py')]
    jobs=[];cases=[];out.mkdir(parents=True)
    for row in rows:
        matches=[x for x in corpus['cases'] if x.get('source88')==row['source']];assert len(matches)==1
        matched=matches[0];expected=matched['expectedStdoutEvidence'];assert Path(expected['file']).read_text()==matched['expectedStdout']
        name=row['name'];build=ROOT/'selfhost/build/phase111'/('p131-'+out.name+'-'+name);assert not build.exists()
        cases.append(dict(name=name,source=row['source'],qbe=row['product'],expected=expected,buildReport=str(build/'report.json')))
        inputs.extend([row['source'],row['product'],expected])
        jobs.append(dict(name=name,seconds=75,command=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
            '--out',str(out/(name+'-guard')),'--seconds','60','--rss-mib','2048','--available-mib','16384','--file-mib','64','--cpu','3','--',
            sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),'--source',row['product']['file'],
            '--runtime',selected['runtime']['file'],'--out',str(build),'--expected',expected['file'],'--seconds','30']))
    for item in inputs:assert pin(item['file'])==item,item['file']
    report=dict(complete=True,targetsRun=False,source=request['source'],requestReport=pin(a.request),inputs=inputs,cases=cases,jobs=jobs,
        scope='Plans only. Exact source88 identities from frozen original45 corpus, independent ordinary expected stdout, selected cached runtime and unchanged aligned builder. A completed job requires complete/outputExact build receipt; no program-speed or native compiler qualification claim.')
    (out/'method.py').write_bytes(Path(__file__).read_bytes());(out/'jobs.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'jobs.json'),cases=len(cases),outerGuard=False)))

if __name__=='__main__':main()
