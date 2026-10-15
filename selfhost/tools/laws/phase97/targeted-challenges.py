#!/usr/bin/env python3
"""Add frozen independent witnesses after recording Phase96 coverage gaps."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import shutil
import sys
sys.dont_write_bytecode=True
from common import ROOT,BUILD,pin,read,save,verify


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    out=p.parse_args().out.resolve();assert out.is_relative_to(BUILD);out.mkdir(parents=True,exist_ok=False)
    prior=read(BUILD/'challenge-check01/report.json');assert prior['complete']
    assert {r['id'] for r in prior['rows'] if r['classification']=='outside-extracted-closure'}=={'bad05-frame-pop-is-slots','bad08-historical-fid-collision'}
    base=BUILD/'challenge-base01';old=read(base/'manifest.json')
    for item in old['frozenInputs']:verify(item)
    sys.path.insert(0,str(ROOT/'selfhost/proofs/phase96/production'))
    spec=importlib.util.spec_from_file_location('p96prepare',ROOT/'selfhost/proofs/phase96/production/prepare.py')
    prepare=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepare)
    recipes={name:read(ROOT/'selfhost/tools/laws/phase97/challenge'/f'{name}.json') for name in
             ['bad05-frame-pop-is-slots','bad08-historical-fid-collision','bad04-empty-chunk-separator']}
    cases=copy.deepcopy(old['cases']);extra=[]
    for name,observer in [('bad05-frame-pop-is-slots','U32.show'),('bad08-historical-fid-collision','p96.strings')]:
        witness=recipes[name]['witness'];expected=witness['baselineExpected']
        wire=expected if isinstance(expected,int) else [[ord(c) for c in s] for s in expected]
        row=dict(id='p97-'+name,family='phase97-gap-witness',expression=observer+'('+witness['expression']+')',expectedWire=wire,exportName=f'p96_case_{len(cases):04}')
        cases.append(row);extra.append(row)
    serializer=(base/'methods/serialize.bend').read_text()
    wrappers=['@unsafe\ndef '+r['exportName']+'() -> String:\n'+'\n'.join('  '+line for line in r['expression'].splitlines())+'\n' for r in cases]
    harness=serializer+'\n'+'\n'.join(wrappers)
    sources={name:(base/'production-source'/name).read_text() for name in prepare.SOURCES}
    for role,recipe in [('baseline',None),*recipes.items()]:
        folder=out/role;shutil.copytree(base,folder);role_sources=copy.deepcopy(sources)
        mutation=None
        if recipe:
            key=str(Path(recipe['file']).relative_to('selfhost/src'))
            before,after=recipe['before'],recipe['after']
            repair=None
            if role=='bad04-empty-chunk-separator':
                assert 'case Con{h, t}:' in after
                after=after.replace('case Con{h, t}:','case Con{+h, t}:',1)
                repair='After frozen admission failure: explicitly share h; original recipe and first result unchanged.'
            assert role_sources[key].count(before)==1
            role_sources[key]=role_sources[key].replace(before,after,1)
            mutation=dict(id=role,function=recipe['function'],before=before,after=after,repair=repair,
                          case='text-assembly-002' if repair else 'p97-'+role,recipe=pin(ROOT/'selfhost/tools/laws/phase97/challenge'/f'{role}.json'))
        # Recompute dependency closure after mutation so the historical nt_clean
        # dependency is included rather than misclassified as a missing import.
        extracted,extraction=prepare.extract(role_sources,harness)
        library=extracted+'\n'+harness
        native_ids=old['nativeCaseIds']+[r['id'] for r in extra]
        native_cases=[next(r for r in cases if r['id']==key) for key in native_ids]
        native=library+'\n@unsafe\ndef main() -> IO(Unit):\n  do IO<Unit>:\n'
        native+=''.join('    Unit <- IO.print('+r['exportName']+'())\n' for r in native_cases[:-1])
        native+='    IO.print('+native_cases[-1]['exportName']+'())\n'
        for name,text in [('extracted.bend',extracted),('library.bend',library),('native.bend',native),
                          ('native.expected.txt',''.join(json.dumps(r['expectedWire'],separators=(',',':'))+'\n' for r in native_cases))]:
            (folder/name).write_text(text)
        (folder/'methods/targeted-challenges.py').write_bytes(Path(__file__).read_bytes())
        data=copy.deepcopy(old);data.update(cases=cases,nativeCaseIds=native_ids,extraction=extraction,mutation=mutation,
                                            scope='Phase96 unchanged226 +2 independently frozen gap witnesses; source dependency closure recomputed for each isolated mutation.',
                                            library=pin(folder/'library.bend'),native=pin(folder/'native.bend'),
                                            priorChallenge=pin(BUILD/'challenge-check01/report.json'))
        data['frozenInputs']=[pin(folder/Path(x['file']).relative_to(base)) for x in old['frozenInputs']]+[pin(folder/'methods/targeted-challenges.py')]
        save(folder/'manifest.json',data)
    save(out/'receipt.json',dict(complete=True,targetsRun=False,method=pin(__file__),prior=pin(BUILD/'challenge-check01/report.json'),
                                  roles={p.parent.name:pin(p) for p in out.glob('*/manifest.json')},oldCases=226,addedCases=2))


if __name__=='__main__':main()
