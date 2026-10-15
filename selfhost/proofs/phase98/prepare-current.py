#!/usr/bin/env python3
"""Check a future compiler edit against frozen laws: prepare actual source only."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BASE=ROOT/'selfhost/build/phase92/upstream-checked01/compiler.bend'
BASE_SHA='d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def declarations(text):
    matches=list(re.finditer(r'(?m)^(?:@unsafe\n)?(?:type|def|law) ([\w.]+)\b',text));result={}
    for i,m in enumerate(matches):
        name=m.group(1)
        end=matches[i+1].start()if i+1<len(matches)else len(text)
        result.setdefault(name,[]).append(text[m.start():end])
    return result


def unique(table,name):
    rows=table.get(name,[]);assert len(rows)==1,('Missing or ambiguous selected helper',name,len(rows))
    return rows[0]


def code(text):return '\n'.join(line.rstrip()for line in text.splitlines()if line.strip()and not line.lstrip().startswith('#'))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--candidate',type=Path,required=True)
    p.add_argument('--kind',choices=['held-simple','tag','scalars','permission'],required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();candidate=a.candidate.resolve()
    assert candidate.is_relative_to(ROOT)and out.is_relative_to(ROOT)and not out.exists()
    assert pin(BASE)['sha256']==BASE_SHA
    baseline=declarations(BASE.read_text());current=declarations(candidate.read_text())
    comparison=['p88_string_eq_go','p98_eq_finish','p88_string_eq']
    names=dict(**{'held-simple':comparison},
        tag=['KTerm',*comparison,'tg',*(['p98_tag_eq_key_finish']if 'p98_tag_eq_key_finish'in current else []),'p98_tag_eq_read','p98_tag_eq_finish','p98_tag_eq'],
        scalars=['KTerm','p98_term_scalar_finish','p98_ix_read','p98_qt_read','ix','qt'],
        permission=['p88_string_eq_go',*(['p98_eq_finish']if 'p98_eq_finish'in current else []),'p88_string_eq','no_effect_provider_member','no_effect_foreign_allowed'])[a.kind]
    # These referenced representation declarations are deliberately frozen.
    # A change requires an explicit new bridge/specification review.
    for name in ['KTerm','tg']:
        if name in names:assert code(unique(current,name))==code(unique(baseline,name)),('Reference boundary changed',name)
    selected=[]
    for name in names:
        original=unique(current,name);extracted=original.removeprefix('@unsafe\n')
        assert '@unsafe'not in extracted
        selected.append(dict(name=name,original=original,extracted=extracted,removedUnsafe=original!=extracted))
    out.mkdir(parents=True)
    candidate_text='import Base\n\n'+''.join(row['extracted']for row in selected)
    references=[]
    if a.kind=='scalars':
        for name in ['ix','qt']:
            original=unique(baseline,name);body=original.removeprefix('@unsafe\n')
            renamed=body.replace('def '+name+'(','def p98_original_'+name+'(',1)
            assert renamed.replace('def p98_original_'+name+'(','def '+name+'(',1)==body
            references.append(dict(name=name,original=original,extracted=renamed))
            candidate_text+=renamed
        entry='scalars.bend';copies=[('comparison/scalars.bend',entry)]
    elif a.kind=='permission':
        assert candidate.read_text().count('no_effect_foreign_allowed(')>=2,'Helper must be used by actual classifier'
        entry='laws.bend';copies=[('permission/reference.bend','reference.bend'),('permission/laws.bend',entry)]
        text=(HERE/'comparison/baseline.bend').read_text().replace('import ./production.bend as P','import ./candidate.bend as P')
        (out/'baseline.bend').write_text(text)
    else:
        entry='tag.bend'if a.kind=='tag'else'held-simple.bend'
        copies=[('comparison/reference.bend','reference.bend'),('comparison/baseline.bend','baseline.bend'),('comparison/held-simple.bend','held-simple.bend')]
        if a.kind=='tag':copies.append(('comparison/tag.bend','tag.bend'))
        (out/'production.bend').write_text('import Base\n\n'+unique(baseline,'p88_string_eq_go')+unique(baseline,'p88_string_eq'))
    (out/'candidate.bend').write_text(candidate_text)
    for source,dest in copies:(out/dest).write_bytes((HERE/source).read_bytes())
    (out/'prepare-current.py').write_bytes(Path(__file__).read_bytes())
    manifest=dict(kind='phase98-current-source-frozen-law-preparation',targetsRun=False,method=pin(__file__),
        baseline=pin(BASE),candidate=pin(candidate),package=a.kind,candidateDefinitions=selected,referenceDefinitions=references,
        proofTemplates=[pin(HERE/source)for source,_ in copies],outputs=[pin(path)for path in sorted(out.iterdir())],entry=str(out/entry),
        transformation='Actual requested compiler helper bodies only; no fallback to historical candidate. Leading unsafe annotations removed for checking; scalar reference declaration names reversibly changed. Contracts remain frozen.',
        interpretation=['This prepares a source proof target; it does not run any compiler, proof checker or benchmark.',
                        'Missing helpers or changed reference representation fail instead of silently substituting old code.',
                        'A source-check failure can mean a wrong implementation, unsupported proof maintenance, or unsafe/nonterminating helper; inspect the diagnostic before classifying.',
                        'Passing verifies these safe value contracts, not arbitrary callers, C ownership, host authentication or performance.'])
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(dict(entry=manifest['entry'],targetsRun=False)))


if __name__=='__main__':main()
