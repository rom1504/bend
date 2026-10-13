#!/usr/bin/env python3
"""Prepare self-check/reproduction and deferred release commands; no targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path('/home/ai/bend2/build/publish/bend')
RAW = ROOT/'selfhost/build/phase82'
OLD = ROOT/'selfhost/build/phase67'
TOOLS = ROOT/'selfhost/tools/performance'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'


def pin(p):
    p = Path(p).resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open('x') as f:
        f.write(value if isinstance(value,str) else json.dumps(value, indent=2)+'\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for key in ['attempt','b2','native-recipe','out','qualification-out','release-out']:
        p.add_argument('--'+key, type=Path, required=True)
    a = p.parse_args()
    out, qualification, release = a.out.resolve(), a.qualification_out.resolve(), a.release_out.resolve()
    for path in (out,qualification,release):
        assert path.parent == RAW and not path.exists(), path
    attempt_dir = a.attempt.resolve(strict=True)
    attempt = json.loads((attempt_dir/'attempt.json').read_text())
    assert attempt['checked'] and attempt['config']['strictExact']
    assert attempt['node']['file'] == NODE
    validation = json.loads((attempt_dir/'validation-001/report.json').read_text())
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    snapshot = Path(attempt['snapshot']['root'])
    for row in attempt['snapshot']['sources']:
        assert pin(row['frozen']['file'])['sha256'] == row['frozen']['sha256']
    bootstrap = json.loads(Path(attempt['bootstrapReport']['file']).read_text())
    assert bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
    api = pin(attempt['api']['file'])
    assert api['sha256'] == attempt['api']['sha256']
    source = pin(bootstrap['source'])
    assert source['sha256'] == bootstrap['sourceSha256']
    direct_runtime = pin(snapshot/'src/runtime/js/direct.mjs')
    recipe = json.loads(a.native_recipe.read_text())
    assert recipe['api'] == api['file']
    # These installed-smoke commands use the candidate's qualified C toolchain.
    # Artifact checks remain those of the original release controllers.
    environment = dict(CC=recipe['clang'], CPATH=recipe['clangArgs'][1], NODE_OPTIONS='', NODE_PATH='')
    parent_manifest = OLD/'qualification-method01/methods.json'
    parent_index = json.loads(parent_manifest.read_text())
    parents = {r['output']['file']:r['output'] for r in parent_index['methods']}
    out.mkdir()
    methods = []
    for relative in ['bootstrap/setup.mjs','bootstrap/reproduce.mjs',
                     'qualification/self-check.mjs','qualification/benchmark-equality.mjs']:
        parent = OLD/'qualification-method01'/relative
        assert pin(parent)['sha256'] == parents[str(parent)]['sha256']
        text = parent.read_text()
        edits = []
        for old,new in [('selfhost/build/phase67','selfhost/build/phase82'),('inside Phase67','inside Phase70')]:
            count = text.count(old)
            text = text.replace(old,new)
            edits.append(dict(before=old,after=new,count=count))
        output = out/relative
        write(output,text)
        methods.append(dict(parent=pin(parent),output=pin(output),edits=edits))
    pins_file = a.b2.resolve()/'image-pins.json'
    # The B2 plan may be prepared before its targets finish. Keep the future
    # pin path explicit; do not manufacture an image identity or passing gate.
    b2_state = dict(path=str(pins_file), exists=pins_file.exists())
    if pins_file.exists():
        image = json.loads(pins_file.read_text())
        assert image['attempt']['sha256'] == pin(attempt_dir/'attempt.json')['sha256']
        assert image['b1']['sha256'] == api['sha256']
        b2_state['identity'] = pin(pins_file)
    def guarded(name, script, arguments, destination=qualification, seconds=300, env=None):
        command=['python3',str(TOOLS/'phase46/job.py'),'--out',str(destination/('job-'+name)),
                 '--seconds',str(seconds),'--']
        if env:
            command += ['env',*[k+'='+v for k,v in env.items()]]
        command += [NODE,'--stack-size=4096','--max-old-space-size=1024',str(script),*map(str,arguments)]
        return dict(name=name,command=command,requiresEscalatedExecution=True,
                    reason='Managed sandbox Node PIPE creation currently reports EPERM; retain the same resource guard outside that sandbox.')
    qualification_commands = [
        guarded('self-check',out/'qualification/self-check.mjs',[pins_file,qualification/'self-check']),
        guarded('fixed-point',out/'bootstrap/reproduce.mjs',[pins_file,qualification/'fixed-point'])]
    project=ROOT/'selfhost'
    packaging=project/'tools/development/release.mjs'
    release_commands=[
        guarded('install',packaging,['--install-attempt',attempt_dir],release,180,environment),
        guarded('verify-before',packaging,['--verify'],release,180,environment),
        guarded('legacy42',TOOLS/'phase66/release/legacy-release-smoke-launch-v1.mjs',
                [project,release/'legacy42',api['sha256']],release,180,environment),
        guarded('default24',TOOLS/'phase66/release/default-release-smoke-v1.mjs',
                [project,release/'default24',api['sha256'],source['sha256'],direct_runtime['sha256']],release,180,environment),
        guarded('helper5',TOOLS/'phase66/release/helper-integrity-v1.mjs',
                [project,attempt_dir/'attempt.json',release/'helper5'],release,90,environment),
        guarded('verify-after',packaging,['--verify'],release,180,environment)]
    prior=project/'dist/release.json'
    old_release=json.loads(prior.read_text())
    installed_before=[pin(prior)]
    for row in old_release['files']:
        item=pin(project/row['path'])
        assert item['sha256']==row['sha256'] and item['bytes']==row['bytes']
        installed_before.append(item)
    historical=[]
    historical_names=[('self-check',OLD/'scalars-build01-qualification/job-self-check/process.json'),
                      ('fixed-point',OLD/'scalars-build01-qualification/job-fixed-point/process.json')]
    historical_names += [(name,OLD/'release-final01'/('job-'+name)/'process.json')
                         for name in ['install','verify-before','legacy42','default24','verify-after']]
    historical_names += [('helper5',OLD/'release-final01/helper5-supervisor/run.json')]
    for name,path in historical_names:
        r=json.loads(path.read_text())
        assert r['complete'] and r['returncode']==0
        historical.append(dict(name=name,receipt=pin(path),wallSeconds=r['wallSeconds'],peakTreeRssBytes=r['peakTreeRssBytes']))
    input_paths=[Path(__file__),parent_manifest,attempt_dir/'attempt.json',attempt_dir/'validation-001/report.json',
                 a.native_recipe,TOOLS/'phase46/job.py',TOOLS/'programs/support.py',packaging]
    input_paths += [TOOLS/'phase66/release'/name for name in
                   ['legacy-release-smoke-launch-v1.mjs','legacy-release-smoke-v1.mjs','default-release-smoke-v1.mjs','helper-integrity-v1.mjs']]
    result=dict(kind='phase69-selfhosting-and-deferred-release-plan',dataOnly=True,targetsExecuted=False,
        producer=pin(__file__),attempt=pin(attempt_dir/'attempt.json'),api=api,source=source,
        directRuntime=direct_runtime,b2Pins=b2_state,methods=methods,qualification=str(qualification),release=str(release),
        qualificationCommands=qualification_commands,deferredReleaseCommands=release_commands,
        releaseRequires=['complete/pass genuine B2 image pins and driver comparison',
                        'fresh B2 own-source type acceptance with explicitly expected unsafe proof-trust refusal',
                        'complete B2/B3 byte equality',
                        'root-selected native/custom/raw/boundary/oracle gates complete and correct',
                        'JS/frontend continuity evidence reviewed; no unqualified source changes',
                        'live source/host/runtime still equal the selected checked attempt',
                        'root concrete final selection and recorded promotion decision'],
        installedBefore=installed_before,historicalTiming=historical,
        historicalTotalGuardSeconds=sum(x['wallSeconds'] for x in historical),
        inputs=[pin(x) for x in input_paths],
        scope='Two unchanged selfhosting gates after genuine B2; six explicit deferred release jobs reuse original controllers. Preparation neither executes nor authorizes promotion. The installer preserves old seven-file lineage in release-history; installedBefore records exact artifacts for an independent preservation join. Node targets need the already diagnosed sandbox escalation, with CPU3/1GiB heap/4MiB stack/2GiB tree/4GiB floor unchanged. B2 is qualified evidence; installation selects the checked equality-derived B1, not an invented checked B2.')
    write(out/'plan.json',result)
    print(json.dumps(dict(plan=pin(out/'plan.json'),qualificationJobs=2,deferredReleaseJobs=6,historicalSeconds=result['historicalTotalGuardSeconds'],targetsExecuted=False)))


if __name__=='__main__':
    main()
