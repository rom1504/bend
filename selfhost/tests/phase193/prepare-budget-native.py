#!/usr/bin/env python3
"""Retarget frozen native qualification argv to budget roots; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex

ROOT=Path(__file__).resolve().parents[3]
PHASE=ROOT/'selfhost/build/phase193'
NAMES=['native-image01','native45-01','native-self01','native64-01',
       'runtime10-01','native-reproduction01','native45-02','native-generations-compare01']


def pin(path):
    path=Path(path).resolve(strict=True)
    data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,default=PHASE/'selected-source02/compiler.bend')
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    source=a.source.resolve()
    assert source==PHASE/'selected-source02/compiler.bend', 'Budget chain requires distinct selected-source02'
    assert not a.out.exists(), 'Fresh plan directory required'
    original_path=PHASE/'qualification-argv01.json'
    original=json.loads(original_path.read_text())
    known={s['name']:s for s in original['steps']}
    old_source=PHASE/'selected-source01/compiler.bend'
    assert pin(old_source)['sha256']==original['source_sha256'], 'Original frozen source changed'
    assert pin(PHASE/'assets.json')['sha256']==pin(ROOT/'selfhost/build/phase192/assets.json')['sha256'], 'Expected unchanged common assets'
    inputs=[pin(__file__),pin(original_path),pin(old_source),pin(PHASE/'assets.json'),
            pin(ROOT/'selfhost/tests/phase193/run-steps.py')]
    a.out.mkdir(parents=True)
    steps=[]
    for name in NAMES:
        argv_path=PHASE/(name+'-argv.json')
        command=json.loads(argv_path.read_text())
        assert command==known[name]['argv'], 'Frozen argv disagrees with parent plan: '+name
        inputs.append(pin(argv_path))
        new=[];edits=[]
        for i,word in enumerate(command):
            changed=word
            for old in NAMES:
                prefix='selfhost/build/phase193/'+old
                if changed==prefix or changed.startswith(prefix+'/'):
                    changed=changed.replace(prefix,'selfhost/build/phase193/budget-'+old,1)
                    break
            if changed=='selfhost/build/phase193/selected-source01/compiler.bend':
                changed='selfhost/build/phase193/selected-source02/compiler.bend'
            if changed==name:
                changed='budget-'+name  # Outer wrapper job name, not a tool option.
            if changed!=word:
                edits.append(dict(index=i,before=word,after=changed))
            new.append(changed)
        assert new[new.index('--out')+1]=='selfhost/build/phase193/budget-'+name
        for word in new:
            if word.startswith('selfhost/build/phase193/'):
                assert ('/budget-' in word or '/selected-source02/' in word or word.endswith('/assets.json')), word
        output=PHASE/('budget-'+name)
        for required_fresh in [output,PHASE/('budget-'+name+'-guard'),ROOT/'selfhost/build-retention/phase193'/('budget-'+name+'-close')]:
            assert not required_fresh.exists(), 'Budget execution destination already exists: '+str(required_fresh)
        file=a.out/('budget-'+name+'-argv.json')
        file.write_text(json.dumps(new,indent=2)+'\n')
        # Pin every existing method/seed/input named directly by the argv.
        for word in command:
            candidate=ROOT/word
            if candidate.is_file() and '/selfhost/build/phase193/' not in str(candidate):
                inputs.append(pin(candidate))
        steps.append(dict(name='budget-'+name,argv=pin(file),command=new,shell=shlex.join(new),
            substitutions=edits,originalArgv=pin(argv_path),
            dependsOn=[('selected-source02' if dep=='selected-source01' else 'budget-'+dep)
                       for dep in known[name].get('dependsOn',[])],
            guardSeconds=known[name]['guardSeconds'],diskMiB=known[name]['diskMiB'],
            rssMiB=known[name].get('rssMiB',2048),fileMiB=known[name].get('fileMiB',128),
            targetRuns=known[name]['targetRuns']))
    bound=pin(source) if source.exists() else None
    unique={r['file']:r for r in inputs}
    runner=None
    if bound:
        runner=['python3','-B','selfhost/tests/phase193/run-steps.py','--source',str(source),
            '--sha256',bound['sha256'],'--out',str(PHASE/'budget-qualification-execution01.json'),
            *[row['argv']['file'] for row in steps]]
    report=dict(kind='phase193-budget-native-argv-plan',complete=True,targetsRun=False,
        selectedSourceRequired=str(source),selectedSource=bound,readyToStart=bound is not None,
        parentSource=pin(old_source),inputs=list(unique.values()),steps=steps,runnerCommand=runner,
        scope='Only exact path/job-name substitutions from frozen parent argv. Same QBE seed, '
              'assets, tools, guard limits and output checks. This preparation grants no qualification.',
        prerequisites=['Freeze selected-source02 and its source map; independently check its exact source.',
            'If readyToStart is false, rerun preparation into a fresh plan directory after freezing; do not invent a source hash.',
            'Verify all plan input and argv pins before execution. Existing run-steps rechecks the source hash before every job.',
            'Root selects/adopts steps serially; apply the separate N1 and N2 cost admission decisions between generations.',
            'Each producer must be complete with no changed inputs. Native64/runtime10 require passed:true; retain independent outputs.',
            'Final reproduction requires expectedObject equal budget-native-self01/program.o; product comparison requires45 objects/135 sections.',
            'Old selected-source01 and images stay immutable. Preserve the disk reserve; no nested guards.'])
    (a.out/'plan.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(plan=str(a.out/'plan.json'),steps=len(steps),targetsRun=False,readyToStart=bound is not None)))


if __name__=='__main__':
    main()
