"""Build only the safe-summary proxy; reuse the already qualified summary binary."""
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
    prior_file=ROOT/'selfhost/build/phase131/proxy-jobs01/config.json';prior=json.loads(prior_file.read_text())
    source_file=ROOT/'selfhost/build/phase131/usage-safe-proxy02/manifest.json';source=json.loads(source_file.read_text())
    api_file=ROOT/'selfhost/build/phase111/p131-usage-safe-proxy02-api/report.json';api=json.loads(api_file.read_text())
    assert source['complete'] and api['complete'] and api['checked'] and api['status']==0 and source['source'] in api['inputs']
    old=next(x for x in prior['cases'] if x['name']=='usage-candidate')
    old_build=json.loads(Path(old['build']).read_text());assert old_build['complete'] and old_build['outputExact']
    assert old['source']==source['parent']
    inputs=[pin(__file__),pin(prior_file),*prior['inputs'],pin(source_file),*source['inputs'],source['source'],source['expected'],
            pin(api_file),*api['inputs'],api['api'],pin(old['build']),old_build['binary'],pin(HERE/'native-timing-v2.py')]
    for row in inputs:assert pin(row['file'])==row
    out.mkdir(parents=True);(out/'expected.stdout').write_bytes(Path(source['expected']['file']).read_bytes())
    emit=ROOT/'selfhost/build/phase130'/('p131-'+out.name+'-safe-emit');build=ROOT/'selfhost/build/phase111'/('p131-'+out.name+'-safe-build')
    assert not emit.exists() and not build.exists()
    original={**old,'name':'usage-original','variant':'original'}
    candidate=dict(name='usage-candidate',group='usage',variant='candidate',source=source['source'],
                   emission=str(emit/'report.json'),build=str(build/'report.json'),binary=str(build/'program'),expected=pin(out/'expected.stdout'))
    config={**prior,'inputs':inputs,'cases':[original,candidate],
            'scope':'Current summary versus proof-connected safe summary on identical proxy. Baseline native binary is reused, not rebuilt. No original-walker comparison or full-compiler performance claim.'}
    (out/'config.json').write_text(json.dumps(config,indent=2)+'\n')
    # Paired hosted check uses exactly the same source identities and oracle.
    pair=dict(complete=True,targetsRun=False,inputs=inputs,expected=source['expected'],oracle=source['oracle'],
              variants={'original':{'source':old['source']},'summary':{'source':source['source']}},scope=config['scope'])
    (out/'pair.json').write_text(json.dumps(pair,indent=2)+'\n')
    jobs=[]
    def job(name,command,seconds):
        jobs.append(dict(name=name,seconds=seconds+15,command=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
          '--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','2048','--available-mib','16384','--file-mib','64','--cpu','3','--',*map(str,command)]))
    job('safe-emit',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase130/native-request.py','--image',prior['image']['file'],
        '--source',source['source']['file'],'--carrier-receipt',prior['carrier']['file'],'--out',emit,'--seconds','45'],60)
    job('safe-build',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase123/build-aligned.py','--source',emit/'program.ssa',
        '--runtime',prior['runtime']['file'],'--out',build,'--expected',source['expected']['file'],'--seconds','30'],60)
    job('timing',[sys.executable,'-B',HERE/'native-timing-v2.py','--config',out/'config.json','--out',out/'timing','--groups','usage'],120)
    (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,inputs=[pin(out/'config.json'),*inputs],jobs=jobs),indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'jobs.json'),reusedBinary=old_build['binary'],outerGuard=False)))


if __name__=='__main__':main()
