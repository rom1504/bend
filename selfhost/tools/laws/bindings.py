"""Validate exact production-declaration extraction; never infer whole-compiler proof."""
import hashlib
import json
from pathlib import Path
from prepare import BASE_SHA, declarations, unique, code

ROOT=Path(__file__).resolve().parents[3]
FIXTURES=ROOT/'selfhost/proofs/compiler-laws'


def pin(path):
    path=Path(path).resolve();digest=hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda:stream.read(1024*1024),b''):digest.update(block)
    return dict(file=str(path),bytes=path.stat().st_size,sha256=digest.hexdigest())


def verify(row):
    if pin(row['file'])!=row:raise ValueError('Changed bound input: '+row['file'])


def source_binding(path, entry):
    path=Path(path).resolve();document=json.loads(path.read_text())
    if document.get('kind')!='bend-current-source-frozen-law-preparation-v1':
        raise ValueError('Current exact-source preparation required; historical receipts are not rewritten')
    package=document['package']
    if package not in ['representation','held-simple','tag','scalars','permission']:
        raise ValueError('Unknown source-bound law package')
    if Path(document['entry']).resolve()!=Path(entry).resolve():
        raise ValueError('Checked entry is not the source-bound package entry')
    for row in [document['method'],document['baseline'],document['candidate'],*document['proofTemplates'],*document['outputs']]:verify(row)
    if Path(document['baseline']['file']).resolve()!=FIXTURES/'reference-declarations.bend':
        raise ValueError('Frozen reference declaration boundary changed')
    if document['baseline']['sha256']!=BASE_SHA:
        raise ValueError('Frozen reference bytes changed')
    source=Path(document['candidate']['file']).read_text();pieces=[];names=[]
    for row in document['candidateDefinitions']:
        original=row['original'];extracted=original.removeprefix('@unsafe\n')
        if source.count(original)!=1 or row['extracted']!=extracted or row['removedUnsafe']!=(original!=extracted) or '@unsafe' in extracted:
            raise ValueError('Actual source body was rewritten/substituted: '+row['name'])
        if row['name'] in names:raise ValueError('Duplicate selected declaration')
        names.append(row['name']);pieces.append(extracted)
    current=declarations(source)
    comparison=['p88_string_eq_go','p98_eq_finish','p88_string_eq']
    expected=dict(**{'held-simple':comparison},
        representation=['KTerm','tg','nm','ix','qt','ks','rm','kb','ke','k_with_children','k_with_span','core_literal','kl_number','kl_text','k_quantity_present','k_rebuild'],
        tag=['KTerm',*comparison,'tg',*(['p98_tag_eq_key_finish'] if 'p98_tag_eq_key_finish' in current else []),'p98_tag_eq_read','p98_tag_eq_finish','p98_tag_eq'],
        scalars=['KTerm','p98_term_scalar_finish','p98_ix_read','p98_qt_read','ix','qt'],
        permission=['p88_string_eq_go',*(['p98_eq_finish'] if 'p98_eq_finish' in current else []),'p88_string_eq','no_effect_provider_member','no_effect_foreign_allowed'])[package]
    if names!=expected or any(unique(current,row['name'])!=row['original'] for row in document['candidateDefinitions']):
        raise ValueError('Wrong or partial actual declaration selection')
    reference=Path(document['baseline']['file']).read_text()
    baseline=declarations(reference)
    for name in ['KTerm','tg']:
        if package!='representation' and name in names and code(unique(current,name))!=code(unique(baseline,name)):
            raise ValueError('Reference representation changed: '+name)
    if package=='permission' and source.count('no_effect_foreign_allowed(')<2:
        raise ValueError('Permission predicate is not used by actual candidate')
    for row in document['referenceDefinitions']:
        name=row['name'];original=row['original']
        if package!='scalars' or name not in ['ix','qt'] or reference.count(original)!=1:
            raise ValueError('Unrecognized scalar reference declaration')
        renamed=original.removeprefix('@unsafe\n').replace('def '+name+'(','def p98_original_'+name+'(',1)
        if renamed!=row['extracted']:raise ValueError('Reference rewrite differs')
        pieces.append(renamed)
    if [r['name'] for r in document['referenceDefinitions']] != (['ix','qt'] if package=='scalars' else []):
        raise ValueError('Unexpected reference declaration set')
    generated=path.parent/('production.bend' if package=='representation' else 'candidate.bend')
    if generated.read_text()!='import Base\n\n'+''.join(pieces):
        raise ValueError('Extracted source is not the exact selected declaration sequence')
    template_paths={
        'representation':['representation/laws.bend'],
        'held-simple':['comparison/reference.bend','comparison/baseline.bend','comparison/held-simple.bend'],
        'tag':['comparison/reference.bend','comparison/baseline.bend','comparison/held-simple.bend','comparison/tag.bend'],
        'scalars':['comparison/scalars.bend'],
        'permission':['permission/reference.bend','permission/laws.bend']}[package]
    if [Path(row['file']).resolve() for row in document['proofTemplates']] != [FIXTURES/name for name in template_paths]:
        raise ValueError('Frozen public contract template set changed')
    for row in document['proofTemplates']:
        template=Path(row['file']).resolve()
        if not template.is_relative_to(FIXTURES):raise ValueError('Proof template outside the maintained frozen contract')
        destination=path.parent/template.name
        if destination.read_bytes()!=template.read_bytes():raise ValueError('Frozen proof/template changed')
    if package=='permission':
        expected_baseline=(FIXTURES/'comparison/baseline.bend').read_text().replace('import ./production.bend as P','import ./candidate.bend as P')
        if (path.parent/'baseline.bend').read_text()!=expected_baseline:raise ValueError('Permission comparator proof bridge changed')
    elif package in ['tag','held-simple']:
        original='import Base\n\n'+unique(baseline,'p88_string_eq_go')+unique(baseline,'p88_string_eq')
        if (path.parent/'production.bend').read_text()!=original:raise ValueError('Frozen comparison baseline changed')
    return dict(schema='bend-law-source-binding-v1',manifest=pin(path),candidate=document['candidate'],
                package=package,declarations=names,removedUnsafe=[r['name'] for r in document['candidateDefinitions'] if r['removedUnsafe']],
                wholeCompilerProved=False,nativeOwnershipProved=False,
                scope='Only these actual safe-extracted value declarations under the frozen law contracts; caller, backend, runtime and unrelated compiler bodies remain outside the proof.')
