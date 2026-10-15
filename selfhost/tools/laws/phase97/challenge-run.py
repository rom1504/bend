#!/usr/bin/env python3
"""Evaluate independently frozen challenges against the unchanged Phase96 corpus."""
import argparse
import copy
import shutil
import sys
from pathlib import Path
sys.dont_write_bytecode=True
from common import ROOT,BUILD,pin,read,save,verify,run,passed


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(BUILD);out.mkdir(parents=True,exist_ok=False)
    challenge=ROOT/'selfhost/tools/laws/phase97/challenge/manifest.json'
    frozen=read(challenge);base=BUILD/'challenge-base01';manifest=read(base/'manifest.json')
    inputs=[pin(__file__),pin(Path(__file__).with_name('common.py')),pin(challenge),pin(base/'manifest.json')]
    for r in frozen['sourceInputs']+[e['recipe'] for e in frozen['entries']]:
        item=pin(ROOT/r['path']);assert all(item[k]==r[k] for k in ['bytes','sha256']);inputs.append(item)
    for item in manifest['frozenInputs']+list(manifest['b2'].values()):verify(item)
    report=dict(complete=False,inputs=inputs,selection=frozen['methodology'],rows=[])
    def write():save(out/'report.json',report)
    def execute(snapshot,label):
        row=run(out/(label+'-guard'),['node','--stack-size=4096','--max-old-space-size=1024',snapshot/'methods/run.mjs',snapshot/'manifest.json',out/(label+'-execution'),'js'],90)
        result=read(out/(label+'-execution')/'report.json')
        return row,result,pin(out/(label+'-execution')/'report.json')
    try:
        baseline,result,identity=execute(base,'baseline');report['baseline']=dict(guard=baseline,report=identity);write()
        assert passed(baseline) and result['complete'] and result['passed'] and result['inputsUnchanged']
        assert len(result['rows'])==226
        for entry in frozen['entries']:
            recipe=read(ROOT/entry['recipe']['path']);name=recipe['id']
            record=dict(id=name,kind=recipe['kind'],function=recipe['function'],recipe=pin(ROOT/entry['recipe']['path']),classification=None)
            report['rows'].append(record);write()
            original=(base/'extracted.bend').read_text()
            included=any(r['name']==recipe['function'] and r['kind']=='def' for r in manifest['extraction'])
            if not included:
                record['classification']='outside-extracted-closure';record['targetExecuted']=False;write();continue
            assert original.count(recipe['before'])==1,(name,'ambiguous mutation')
            snapshot=out/(name+'-source');shutil.copytree(base,snapshot)
            data=copy.deepcopy(manifest)
            for filename in ['extracted.bend','library.bend','native.bend']:
                file=snapshot/filename;text=file.read_text();assert text.count(recipe['before'])==1
                file.write_text(text.replace(recipe['before'],recipe['after'],1))
            data['mutation']=dict(id=name,function=recipe['function'],kind=recipe['kind'],recipe=record['recipe'])
            data['frozenInputs']=[pin(snapshot/Path(x['file']).relative_to(base)) for x in manifest['frozenInputs']]
            data['library']=pin(snapshot/'library.bend');data['native']=pin(snapshot/'native.bend')
            data['challengeBaseline']=pin(base/'manifest.json');save(snapshot/'manifest.json',data)
            execution,result,identity=execute(snapshot,name)
            failures=[r for r in result['rows'] if not r['passed']]
            mismatches=[r['id'] for r in failures if 'actual' in r and 'expected' in r and r['actual']!=r['expected']]
            record.update(targetExecuted=True,guard=execution,report=identity,caseFailures=[r['id'] for r in failures],semanticMismatches=mismatches)
            if execution['process'].get('stoppedFor'):classification='resource-stop-inconclusive'
            elif result.get('compile',{}).get('status')!='ok':classification='compilation-refusal'
            elif not result.get('complete') or not result.get('inputsUnchanged'):classification='execution-incomplete'
            elif mismatches:classification='semantic-detection' if recipe['kind']!='good' else 'valid-change-mismatch'
            elif failures:classification='observer-error'
            else:classification='escaped' if recipe['kind']!='good' else 'valid-change-accepted'
            record['classification']=classification;write();print(name,classification,flush=True)
        for item in inputs:verify(item)
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:report['error']=repr(error);raise
    finally:write()


if __name__=='__main__':main()
