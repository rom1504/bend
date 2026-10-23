"""Prepare four serial native proxy acquisitions and one bounded timing screen."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def pin(file):
    file = Path(file).resolve(); data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(row):
    assert pin(row['file']) == row, row['file']
    return row


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    selected_file = ROOT/'implementation/phase130/candidate.json'
    selected = json.loads(selected_file.read_text()); assert selected['complete'] and selected['nativeQualified']
    for key in ['source','n1','runtime','preferredCarrierReceipt','preferredCarrier']: verify(selected[key])
    usage_file = ROOT/'selfhost/build/phase131/usage-proxy02/manifest.json'
    usage = json.loads(usage_file.read_text()); assert usage['complete'] and not usage['targetsRun']
    identity_file = ROOT/'selfhost/tools/performance/phase131/identity/proxy-manifest.json'
    identity = json.loads(identity_file.read_text()); assert identity['complete'] and not identity['targetsRun']
    for row in usage['inputs']+identity['inputs']: verify(row)
    identity_expected = Path(identity['cases'][0]['expected']['file'])
    expected_identity = json.loads(identity_expected.read_text())
    assert expected_identity['status'] == 0 and expected_identity['stderr'] == ''
    expected_usage = Path(usage['expected']['file']); verify(usage['expected'])
    assert expected_usage.read_text().splitlines() == usage['oracle']
    tools = dict(guard=ROOT/'selfhost/tools/performance/phase111/guard.py',
                 emit=ROOT/'selfhost/tools/performance/phase130/native-request.py',
                 build=ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
                 runner=ROOT/'selfhost/tools/performance/phase113/run-jobs.py',
                 timing=HERE/'native-timing.py',
                 identityOracle=ROOT/'selfhost/tools/performance/phase131/identity/timing-oracle.py')
    inputs = [pin(__file__),pin(selected_file),pin(usage_file),pin(identity_file),pin(identity_expected),
              usage['expected'],*[selected[k] for k in ['source','n1','runtime','preferredCarrierReceipt','preferredCarrier']],
              *usage['inputs'],*identity['inputs'],*[pin(x) for x in tools.values()]]
    out.mkdir(parents=True)
    (out/'usage.expected.stdout').write_bytes(expected_usage.read_bytes())
    (out/'identity.expected.stdout').write_text(expected_identity['stdout'])
    cases=[]
    for group, rows in [('usage', [('original',usage['variants']['original']['source']),('candidate',usage['variants']['summary']['source'])]),
                        ('identity',[('original',identity['cases'][0]['source']),('candidate',identity['cases'][1]['source'])])]:
        for variant, source in rows:
            verify(source); name=group+'-'+variant
            emit=ROOT/'selfhost/build/phase130'/('p131-'+out.name+'-'+name+'-emit')
            build=ROOT/'selfhost/build/phase111'/('p131-'+out.name+'-'+name+'-build')
            assert not emit.exists() and not build.exists()
            cases.append(dict(name=name,group=group,variant=variant,source=source,emission=str(emit/'report.json'),
                              build=str(build/'report.json'),binary=str(build/'program'),expected=pin(out/(group+'.expected.stdout'))))
    config=dict(complete=True,targetsRun=False,inputs=inputs,cases=cases,identityOracle=pin(tools['identityOracle']),
                image=selected['n1'],runtime=selected['runtime'],carrier=selected['preferredCarrierReceipt'],
                scope='Qualified Phase130 N1 produces four checked proxy programs; original runtime and aligned machine builder. Ordinary independent oracle required before timing. No native compiler qualification or promotion.')
    (out/'config.json').write_text(json.dumps(config,indent=2)+'\n')
    jobs=[]
    def job(name, command, seconds):
        jobs.append(dict(name=name,seconds=seconds+15,command=[sys.executable,'-B',str(tools['guard']),
          '--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','2048',
          '--available-mib','16384','--file-mib','64','--cpu','3','--',*map(str,command)]))
    for row in cases:
        emit=Path(row['emission']).parent; build=Path(row['build']).parent
        job(row['name']+'-emit',[sys.executable,'-B',tools['emit'],'--image',selected['n1']['file'],
            '--source',row['source']['file'],'--carrier-receipt',selected['preferredCarrierReceipt']['file'],
            '--out',emit,'--seconds','45'],60)
        job(row['name']+'-build',[sys.executable,'-B',tools['build'],'--source',emit/'program.ssa',
            '--runtime',selected['runtime']['file'],'--out',build,'--expected',row['expected']['file'],'--seconds','30'],60)
    job('timing',[sys.executable,'-B',tools['timing'],'--config',out/'config.json','--out',out/'timing'],120)
    plan=dict(complete=True,targetsRun=False,inputs=[pin(out/'config.json'),*inputs],jobs=jobs)
    (out/'jobs.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'jobs.json'),command=['taskset','-c','3',sys.executable,'-B',str(tools['runner']),
          '--plan',str(out/'jobs.json'),'--out',str(ROOT/'selfhost/build/phase113'/('p131-'+out.name))],outerGuard=False)))


if __name__=='__main__': main()
