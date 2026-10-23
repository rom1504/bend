#!/usr/bin/env python3
"""Prepare/verify serial broad45 command lists; never execute a target.

prepare --api-report REPORT --source-manifest MANIFEST --runtime-report REPORT
        --label FRESH_LABEL --out selfhost/build/phase126/FRESH-plan.json
Run the emitted jobs in order, stopping on any nonzero exit. Each target job
already contains the unchanged root CPU3 guard; do not nest guards or parallelize.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
BROAD = ROOT/'selfhost/tools/performance/phase112/benchmark45'


def read(path): return json.loads(Path(path).read_text())


def pin(path):
    path = Path(path).resolve(); digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024*1024), b''): digest.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def verify(row):
    if pin(row['file']) != row: raise ValueError('Changed pinned input: '+row['file'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    modes = p.add_subparsers(dest='mode', required=True)
    prep = modes.add_parser('prepare')
    for name in ['api-report','source-manifest','runtime-report','out']: prep.add_argument('--'+name,type=Path,required=True)
    prep.add_argument('--label',required=True)
    prep.add_argument('--batch-size',type=int,default=8,choices=range(1,9))
    for name in ['verify','verify-merged']:
        check=modes.add_parser(name); check.add_argument('--plan',type=Path,required=True)
    a=p.parse_args()
    if a.mode != 'prepare':
        plan=read(a.plan)
        assert plan['kind']=='phase126-frozen-broad45-command-plan'
        for row in plan['inputs']: verify(row)
        if a.mode=='verify-merged':
            merged=read(plan['artifacts']['merged'])
            assert merged['complete'] and [c['name'] for c in merged['cases']]==plan['names']
            assert all(merged[k]==plan[k] for k in ['source','api','runtime'])
            assert merged['mergedFrom']==[pin(path) for path in plan['batchReports']]
            for row in merged['inputs']: verify(row)
            for case in merged['cases']: assert case['verified']; verify(case['qbe'])
        print(json.dumps(dict(complete=True,targetsRun=False,check=a.mode,plan=pin(a.plan)))); return
    out=a.out.resolve(); assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126')
    assert re.fullmatch(r'[a-z0-9][a-z0-9_-]*',a.label)
    api,source,runtime=[read(path) for path in [a.api_report,a.source_manifest,a.runtime_report]]
    assert api['complete'] and api['checked'] and source['complete'] and runtime['complete']
    assert source['source'] in api['inputs']
    assert {'p88_cache_prepare','p86_plan','p111_runtime_admission','p111_emit_admitted'} <= set(api['exports'])
    for row in [source['source'],api['api'],runtime['source'],runtime['object']]: verify(row)
    manifest=BROAD/'manifest01.json'; profile=BROAD/'upstream-50ms-profile01.json'; freeze=BROAD/'freeze01.json'
    frozen=read(freeze); inventory={r['file']:r for r in frozen['inputs']}
    for path in [manifest,profile,BROAD/'run.py']: verify(inventory[str(path)])
    corpus=read(manifest); names=corpus['partitions']['all45']
    assert len(names)==len(set(names))==45 and names==[c['name'] for c in corpus['cases']]
    assert corpus['partitions']['measurable44']==[n for n in names if n!='scalar-region-0']
    tools=ROOT/'selfhost/tools/performance'; guard=tools/'phase111/guard.py'
    emitter=tools/'phase118/emit-integrated.mjs'; merger=tools/'phase125/merge-emissions.py'
    py=[sys.executable,'-B']; base=ROOT/'selfhost/build/phase126'
    artifacts=dict(merged=str(base/(a.label+'-emission.json')),screen=str(base/(a.label+'-screen')),
                   summary=str(base/(a.label+'-summary.json')))
    paths=[*map(Path,artifacts.values()),base/(a.label+'-screen-guard')]
    paths += [ROOT/'selfhost/build/phase111'/('p126-'+a.label+'-'+name+'-build') for name in names]
    jobs=[dict(name='authenticate-plan',command=py+[str(Path(__file__).resolve()),'verify','--plan',str(out)])]
    def guarded(name,seconds,command):
        dest=base/(a.label+'-'+name+'-guard'); paths.append(dest)
        return dict(name=name,command=py+[str(guard),'--out',str(dest),'--seconds',str(seconds),
            '--rss-mib','2048','--available-mib','16384','--file-mib','64','--cpu','3','--',*command])
    batches=[]; reports=[]
    for start in range(0,45,a.batch_size):
        number=len(batches)+1; tag=f'emit-batch{number:02d}'
        dest=ROOT/'selfhost/build/phase118'/('p126-'+a.label+'-'+tag); paths.append(dest)
        batch=names[start:start+a.batch_size]; batches.append(batch); reports.append(str(dest/'report.json'))
        jobs.append(guarded(tag,300,['env','P118_RUNTIME_REPORT='+str(a.runtime_report.resolve()),
            'P118_CASE_MANIFEST='+str(manifest),api['command'][0],str(emitter),str(a.api_report.resolve()),
            str(a.source_manifest.resolve()),str(dest),*batch]))
    jobs += [dict(name='merge-identical-producer-batches',command=py+[str(merger),'--out',artifacts['merged'],*reports]),
        dict(name='assert-exact-original45',command=py+[str(Path(__file__).resolve()),'verify-merged','--plan',str(out)]),
        guarded('screen',1200,py+[str(HERE/'screen.py'),'--emission',artifacts['merged'],'--out',artifacts['screen'],
            '--label',a.label,'--rounds','3','--scale','4']),
        dict(name='summarize-matched-population',command=py+[str(HERE/'summarize.py'),'--screen',str(Path(artifacts['screen'])/'report.json'),'--out',artifacts['summary']])]
    assert all(not path.exists() for path in paths),'Fresh outputs required (including all candidate builds)'
    input_paths=[Path(__file__),HERE/'validation-recipes.md',a.api_report,a.source_manifest,a.runtime_report,
        manifest,profile,freeze,BROAD/'run.py',guard,tools/'programs/support.py',emitter,merger,HERE/'screen.py',
        HERE/'summarize.py',tools/'phase123/build-aligned.py',ROOT/'implementation/phase125/candidate.json',
        ROOT/'selfhost/build/phase125/broad-screen06/report.json',ROOT/'implementation/phase114/selection.json',
        ROOT/'implementation/phase117/selection.json',ROOT/'selfhost/tools/native/selection.json',Path(api['command'][0])]
    inputs=[pin(path) for path in input_paths]+[source['source'],api['api'],runtime['source'],runtime['object']]
    inputs += [row[key] for row in corpus['cases'] for key in ['source','expectedStdoutEvidence']]
    inputs=list({r['file']:r for r in inputs}.values())
    for row in inputs: verify(row)
    plan=dict(kind='phase126-frozen-broad45-command-plan',targetsRun=False,inputs=inputs,
        source=source['source'],api=api['api'],runtime=runtime['object'],names=names,batches=batches,
        batchReports=reports,artifacts=artifacts,jobs=jobs,rounds=3,scale=4,
        disk=dict(observedFreeBytes=shutil.disk_usage(ROOT).free,guardStartupRequiresMoreThanBytes=288*1024**2,
            policy='Existing guard checks disk at every guarded start; this plan only records current free space. No cleanup, relaxed cap, new quota or target execution.'),
        scope='Execute commands serially, stop on failure. Unchanged original45 sources/oracles and Phase126 matched screen against selected Phase125 plus upstream;44 ratios and scalar-region-0 correctness-only. Hosted emission, not native-image qualification. No compiler transformations or accounting of unfinished guards.')
    out.parent.mkdir(parents=True,exist_ok=True)
    with out.open('x') as stream: json.dump(plan,stream,indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True,targetsRun=False,plan=pin(out),batches=list(map(len,batches)),jobs=len(jobs))))


if __name__=='__main__': main()
