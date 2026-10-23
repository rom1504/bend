"""Prepare an identity proxy pair with its own exact independent timing oracle."""
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
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--prior-config',type=Path,required=True)
    p.add_argument('--identity-manifest',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    prior=json.loads(a.prior_config.read_text());identity=json.loads(a.identity_manifest.read_text())
    assert prior['complete'] and identity['complete'] and not identity['targetsRun']
    inputs=[*prior['inputs'],*identity['inputs'],pin(__file__),pin(a.prior_config),pin(a.identity_manifest),pin(HERE/'native-timing-v2.py')]
    for row in inputs:assert pin(row['file'])==row
    expected=Path(identity['cases'][0]['expected']['file']);oracle=json.loads(expected.read_text())
    assert oracle['status']==0 and oracle['stderr']==''
    inputs.append(pin(expected))
    timing_oracle=identity.get('identityOracle',prior['identityOracle'])
    assert pin(timing_oracle['file'])==timing_oracle
    inputs.append(timing_oracle)
    out.mkdir(parents=True);(out/'expected.stdout').write_text(oracle['stdout'])
    cases=[]
    for variant,source in zip(['original','candidate'],identity['cases']):
        assert pin(source['source']['file'])==source['source'];name='identity-'+variant
        emit=ROOT/'selfhost/build/phase130'/('p131-'+out.name+'-'+name+'-emit')
        build=ROOT/'selfhost/build/phase111'/('p131-'+out.name+'-'+name+'-build')
        assert not emit.exists() and not build.exists()
        cases.append(dict(name=name,group='identity',variant=variant,source=source['source'],emission=str(emit/'report.json'),
                          build=str(build/'report.json'),binary=str(build/'program'),expected=pin(out/'expected.stdout')))
    config={**prior,'inputs':inputs,'identityOracle':timing_oracle,'cases':cases,'resume':'Identity-only extraction repair; successful usage sources/products/builds are not regenerated.'}
    (out/'config.json').write_text(json.dumps(config,indent=2)+'\n')
    jobs=[]
    def job(name,command,seconds):
        jobs.append(dict(name=name,seconds=seconds+15,command=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
          '--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','2048','--available-mib','16384','--file-mib','64','--cpu','3','--',*map(str,command)]))
    for row in cases:
        emit=Path(row['emission']).parent;build=Path(row['build']).parent
        job(row['name']+'-emit',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase130/native-request.py',
            '--image',prior['image']['file'],'--source',row['source']['file'],'--carrier-receipt',prior['carrier']['file'],
            '--out',emit,'--seconds','45'],60)
        job(row['name']+'-build',[sys.executable,'-B',ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
            '--source',emit/'program.ssa','--runtime',prior['runtime']['file'],'--out',build,'--expected',row['expected']['file'],'--seconds','30'],60)
    job('timing',[sys.executable,'-B',HERE/'native-timing-v2.py','--config',out/'config.json','--out',out/'timing','--groups','identity'],120)
    plan=dict(complete=True,targetsRun=False,inputs=[pin(out/'config.json'),*inputs],jobs=jobs)
    (out/'jobs.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'jobs.json'),outerGuard=False)))


if __name__=='__main__':main()
