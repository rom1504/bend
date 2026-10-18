#!/usr/bin/env python3
"""Assemble the native experimental frontend without executing any compiler."""
import argparse
import hashlib
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
PHASE = HERE.parent.parent
ROOT = PHASE.parents[3]


def pin(file):
    p = Path(file).resolve(strict=True)
    raw = p.read_bytes()
    return dict(file=str(p),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def verify(record):
    assert pin(record['file']) == record, ('changed pinned input',record['file'])
    return Path(record['file'])


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args(); out=a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase107') and not out.exists()
    selection_path=ROOT/'selfhost/tools/native/selection.json'
    selected=json.loads(selection_path.read_text())
    admission_path=verify(selected['admission'])
    admission=json.loads(admission_path.read_text())
    assert admission['complete'] and admission['qualified']
    source_path=verify(admission['source'])
    assert admission['source']['sha256']=='63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'
    base=admission['assets']['base']; cache=admission['assets']['cache']
    verify(base); verify(cache['carrier'])
    assert admission['assets']['cacheBasePath']==base['file']
    source=source_path.read_text()
    old_main='@unsafe\ndef main() -> IO(U32):\n  do IO<U32>:\n    args : List<&1,String> <- IO.args()\n    p86_cli(args)'
    assert source.count(old_main)==1
    candidate=source.replace(old_main,old_main.replace('def main()','def p107_previous_main()'))
    starts=list(re.finditer(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',source,re.M))
    blocks={m.group(1):source[m.start():starts[i+1].start() if i+1<len(starts) else len(source)].strip()
            for i,m in enumerate(starts)}
    names=[name for name in blocks if name=='p86_plan' or name.startswith('p86_plan_')]
    assert len(names)==13, ('review selected plan chain',names)
    cloned='\n\n'.join(blocks[name] for name in names)
    cloned=re.sub(r'\bp86_plan\b','p107_plan',cloned)
    cloned=re.sub(r'\bp86_plan_','p107_plan_',cloned)
    cloned=re.sub(r'\bP86Plan','P107Plan',cloned)
    before='P107PlanReady{nr_prepare_annotated(context, annotated), verdict}'
    assert cloned.count(before)==1
    cloned=cloned.replace(before,'P107PlanReady{annotated, verdict}')
    assert 'nr_prepare_annotated' not in cloned
    common=PHASE.parent/'phase106'
    modules=[common/'ir'/f'{name}.bend' for name in ['model','optimize','verify','json','c']]
    modules += [PHASE/'frontend/lower.bend']
    modules += [PHASE/'inline'/f'{name}.bend' for name in ['model','admit','rename','expand','deep','tail','entry','reachable']]
    modules += [PHASE/'backends'/f'{name}.bend' for name in ['qbe','qbe-entry','units']]
    modules += [HERE/'entry.bend']
    config='\n'.join('def '+name+'() -> String:\n  '+json.dumps(value) for name,value in [
        ('p107_base_path',base['file']),('p107_cache_path',cache['carrier']['file']),
        ('p107_cache_stamp',cache['stamp'])])
    fast_expression='nx_reachable(nx_optimize(nx_inline_entry(nx_tail_optimize(program), 4096)))'
    assert fast_expression in (HERE/'entry.bend').read_text()
    final=candidate+'\n\n'+cloned+'\n\n'+'\n\n'.join(f.read_text() for f in modules)+'\n\n'+config+'\n'
    assert len(re.findall(r'^def main\(',final,re.M))==1
    out.mkdir(parents=True)
    (out/'plan-clone.bend').write_text(cloned+'\n')
    (out/'config.bend').write_text(config+'\n')
    (out/'compiler.bend').write_text(final)
    report=dict(kind='phase107-native-frontend-source',version=1,prepared=True,targetsRun=False,
                method=pin(__file__),selection=pin(selection_path),admission=pin(admission_path),
                selectedSource=admission['source'],modules=[pin(f) for f in modules],
                source=pin(out/'compiler.bend'),planClone=pin(out/'plan-clone.bend'),config=pin(out/'config.bend'),
                clonedDefinitions=names,assets=dict(base=base,cache=cache),
                fastPipeline=dict(expression=fast_expression,passes=[
                    dict(name='nx_tail_optimize'),dict(name='nx_inline_entry',budget=4096),
                    dict(name='nx_optimize'),dict(name='nx_reachable')]),
                qbeEntryFusion=dict(fast=True,raw=False,maxBodyNodes=512),
                unitsTransport='JSON strings escaped with selected-source sk_quote',
                sourceEdits=['rename old main, retain selected source otherwise',
                             'clone exact p86_plan chain under p107 names',
                             'return checked annotated definitions before native-C request planning'],
                invocation=['ABS_INPUT','ENTRY','json|qbe|units','raw|fast','cache|live'],
                scope='Experimental scalar native frontend. No installed compiler replacement, '
                      'new FFI provider, authenticated arbitrary cache, or QBE self-hosting claim.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(prepared=True,source=report['source'],manifest=str(out/'manifest.json'))))


if __name__=='__main__': main()
