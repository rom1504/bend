"""Build selector-emitted unchanged safe source, reusing its old native baseline."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent


def pin(file):
    file=Path(file).resolve();data=file.read_bytes()
    return dict(file=str(file),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    prior_file=ROOT/'selfhost/build/phase131/usage-safe-jobs01/config.json';prior=json.loads(prior_file.read_text())
    emission_file=ROOT/'selfhost/build/phase118/p131-selector-proxy02/report.json';emission=json.loads(emission_file.read_text())
    assert emission['complete'];case=next(x for x in emission['cases'] if x['name']=='usage-safe')
    assert case['verified'] and case['parentVerified']
    old=next(x for x in prior['cases'] if x['name']=='usage-candidate')
    assert old['source']==case['source']
    old_build=json.loads(Path(old['build']).read_text());assert old_build['complete'] and old_build['outputExact']
    finite_file=ROOT/'selfhost/build/phase131/selector-finite02/report.json';finite=json.loads(finite_file.read_text());assert finite['complete']
    inputs=[pin(__file__),pin(prior_file),*prior['inputs'],pin(emission_file),*emission['inputs'],case['source'],case['qbe'],
            pin(old['build']),old_build['binary'],pin(finite_file),*finite['inputs'],pin(HERE/'native-timing-v3.py')]
    for row in inputs:
        got=pin(row['file']);assert got['bytes']==row['bytes'] and got['sha256']==row['sha256']
    out.mkdir(parents=True)
    build=ROOT/'selfhost/build/phase111'/('p131-'+out.name+'-selector-build');assert not build.exists()
    original={**old,'name':'usage-original','variant':'original'}
    candidate=dict(name='usage-candidate',group='usage',variant='candidate',source=case['source'],
                   emission=str(emission_file),emissionCase='usage-safe',emitterSource=emission['source'],emitterAPI=emission['api'],
                   build=str(build/'report.json'),binary=str(build/'program'),expected=old['expected'])
    config={**prior,'inputs':inputs,'cases':[original,candidate],
            'scope':'Same safe Bend source, old qualified native producer versus checked selector compiler API. Candidate removes literal-selector closure boundary; proof source is unchanged. Baseline binary reused. No whole-compiler speed or native compiler qualification claim.'}
    (out/'config.json').write_text(json.dumps(config,indent=2)+'\n');jobs=[]
    def job(name,command,seconds):
        jobs.append(dict(name=name,seconds=seconds+15,command=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
          '--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','2048','--available-mib','16384','--file-mib','64','--cpu','3','--',*map(str,command)]))
    job('selector-build',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase123/build-aligned.py','--source',case['qbe']['file'],
        '--runtime',prior['runtime']['file'],'--out',build,'--expected',old['expected']['file'],'--seconds','30'],60)
    job('timing',[sys.executable,'-B',HERE/'native-timing-v3.py','--config',out/'config.json','--out',out/'timing','--groups','usage'],120)
    (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(out/'config.json'),*inputs],jobs=jobs),indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'jobs.json'),reusedBinary=old_build['binary'],outerGuard=False)))


if __name__=='__main__':main()
