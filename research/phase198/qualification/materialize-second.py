#!/usr/bin/env python3
"""Authenticate source/check receipts, then bind existing argv; run no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[3];BUILD=ROOT/'selfhost/build/phase198'
def pin(path):
    p=Path(path).resolve();data=p.read_bytes()
    return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def verify(item):
    actual=pin(item['file'])
    assert actual==item,item['file']
    return Path(item['file'])
def read(path):return json.loads(Path(path).read_text())
def full_check(path,source):
    check=read(path)
    assert check.get('kind')=='bend-independent-source-check'
    assert all(check.get(k) is True for k in ['complete','checked','typeAccepted'])
    assert check.get('unresolvedHoles')==0 and not check.get('changedInputs')
    assert check['source']==source and source in check['loadedSources']
    for item in check['inputs']:verify(item)
    return pin(path)
def composition_gate(audit,source,manifest):
    spec=importlib.util.spec_from_file_location('source',ROOT/'selfhost/tools/build/source.py')
    S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
    def declarations(data):
        records=S.blocks(data)[1];result={(r['kind'],r['name']):r for r in records}
        assert len(result)==len(records)
        return result
    def body(r):return r['data'][r['headerOffset']-r['offset']:].rstrip()
    parent=BUILD/'selected-source01/compiler.bend';parent_pin=pin(parent)
    assert parent_pin['sha256']==audit['parentSHA256']=='e0b08475a80ee226d032e4554e88468e82df2559ae767ed2b7f4cea9f56e0b53'
    assert S.maintained_assemble(manifest,manifest.parent.parent,'x86')==Path(source['file']).read_bytes()
    original=declarations(parent.read_bytes());actual=declarations(Path(source['file']).read_bytes())
    removed=set(original)-set(actual)
    permitted_prune={('def','p169n_compile'),('def','p169n_prepared')}
    assert removed=={tuple(k) for k in audit.get('unchangedBecameUnreachable',[])}
    assert not removed or ('tree' in audit['groups'] and removed==permitted_prune)
    pruned_members=[]
    if removed:
        config=read(manifest);profile=config['profiles']['x86']
        names=set(config['modules']+profile.get('modules',[]))
        if profile.get('entryModule'):names.add(profile['entryModule'])
        hits={key:[] for key in removed}
        for name in sorted(names):
            if name==config['preamble']:continue
            file=manifest.parent.parent/name
            for key,row in declarations(file.read_bytes()).items():
                if key in hits:
                    assert body(row)==body(original[key]),key
                    hits[key].append(pin(file))
        assert all(len(values)==1 for values in hits.values())
        pruned_members=[dict(declaration=list(key),unchangedModule=values[0]) for key,values in sorted(hits.items())]
    verify(audit['method'])
    api_books=[]
    for receipt in audit['checkedAPIs']:
        checked=read(verify(receipt))
        assert checked.get('kind')=='bend-checked-hosted-api'
        assert checked.get('complete') is True and checked.get('checked') is True
        assert not checked.get('error') and not checked.get('changedInputs')
        for item in checked['inputs']:verify(item)
        verify(checked['api'])
        api_books.append(declarations(verify(checked['source']).read_bytes()))
    assert api_books
    variants={};modules={}
    for item in audit['inputs']:
        file=verify(item);book=declarations(file.read_bytes());modules[file.resolve()]=book
        for key,row in book.items():
            value=body(row)
            assert any(key in b and body(b[key])==value for b in api_books),(file,key)
            variants.setdefault(key,set()).add(value)
    joins=audit.get('explicitHookJoins',[])
    permitted=[dict(name='x185_function_copied',stages=['x198a_body','x198p_after_absorb'],helper='x198p_after_absorb')]
    exceptions=set();helper_keys=set()
    if joins:
        assert audit.get('exactExecutableBodiesIdentical') is False and joins==permitted
        assert {'absorb','permute'}<=set(audit['groups'])
        target=('def','x185_function_copied');helper=('def','x198p_after_absorb')
        absorb=body(modules[(ROOT/'research/phase198/absorbing/hook.bend').resolve()][target])
        permute=body(modules[(ROOT/'research/phase198/reuse/hook.bend').resolve()][target])
        old_call=b'x186_float_function(symbol,params,setup,x198a_body'
        new_call=b'x198p_after_absorb(symbol,params,setup,x198a_body'
        old_name=b'def x185_function_copied(';new_name=b'def x198p_after_absorb('
        assert absorb.count(old_call)==1 and permute.count(old_name)==1
        assert body(actual[target])==absorb.replace(old_call,new_call)
        assert body(actual[helper])==permute.replace(old_name,new_name)
        assert all(('def',name) in actual for name in permitted[0]['stages'])
        exceptions={target};helper_keys={helper}
    else:
        assert audit.get('exactExecutableBodiesIdentical') is True
    expected=set(variants)|helper_keys
    missing=expected-actual.keys()
    assert sorted(missing)==[tuple(k) for k in audit.get('missingFromExecutable',[])]
    assert not missing&original.keys() and ('def','main') not in missing
    assert not missing&helper_keys
    changed={k for k in actual if k not in original or body(actual[k])!=body(original[k])}
    assert changed==expected&actual.keys()
    assert audit['changedExisting']==[list(k) for k in sorted(changed&original.keys())]
    assert audit['addedDeclarations']==len(actual.keys()-original.keys())
    for key,choices in variants.items():
        if key not in exceptions and key in actual:
            assert len(choices)==1 and body(actual[key]) in choices,key
    assert audit['individualBodiesCompared']==len(set(variants)&actual.keys())-len(exceptions)
    protected=read(manifest)['protectedDeclarations']
    prior=read(BUILD/'selected-source01/maintained/src/compiler.json')['protectedDeclarations']
    assert protected==prior and not set(protected)&{k[1] for k in changed}
    return dict(kind='authenticated-individual-bodies-and-explicit-hook-join' if joins else 'authenticated-individual-bodies',parent=parent_pin,checkedAPIs=audit['checkedAPIs'],inputs=audit['inputs'],explicitHookJoins=joins,exactExecutableBodiesIdentical=not joins,joinedDeclarations=[list(k) for k in sorted(exceptions|helper_keys)],missingFromExecutable=[list(k) for k in sorted(missing)],allOtherBodiesExact=True,unchangedBecameUnreachable=pruned_members,sourceAssembler=pin(S.__file__))
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,required=True);p.add_argument('--manifest',type=Path,required=True);p.add_argument('--audit',type=Path,required=True)
    p.add_argument('--source-check',type=Path,required=True,help='Complete independent zero-hole check of this exact full source, before machine argv exist')
    p.add_argument('--prefix',default='composed');p.add_argument('--label',required=True)
    a=p.parse_args();assert re.fullmatch('[a-z][a-z0-9-]*',a.prefix)
    source=pin(a.source);audit=read(a.audit)
    assert audit.get('complete') is True and audit['selectedSource']==source
    manifest=pin(a.manifest);checked=full_check(a.source_check,source)
    if audit.get('kind')=='phase198-isolated-composition':
        evidence=composition_gate(audit,source,Path(manifest['file']))
    else:
        assert audit.get('exactExecutableBodiesIdentical') is True and not audit.get('explicitHookJoins')
        for key in ['checkedApiSource','checkedApiReceipt','method']:verify(audit[key])
        evidence=dict(kind='exact-checked-executable-bodies',exactExecutableBodiesIdentical=True)
    template=Path(__file__).with_name('second-chain-templates.json');doc=read(template)
    folder=BUILD/(a.prefix+'-argv01');assert not folder.exists();folder.mkdir()
    values={'source':source['file'],'manifest':manifest['file'],'prefix':a.prefix}
    outputs=[]
    for name,argv in doc['commands'].items():
        result=[]
        for word in argv:
            for k,v in values.items():word=word.replace('{{'+k+'}}',v)
            assert '{{' not in word
            result.append(word)
        if '--out' in result and name!='source-check01':assert not Path(result[result.index('--out')+1]).exists()
        path=folder/(name+'-argv.json');path.write_text(json.dumps(result,indent=2)+'\n');outputs.append(pin(path))
    record=dict(kind='phase198-second-native-chain-materialized',complete=True,targetsRun=False,label=a.label,prefix=a.prefix,method=pin(__file__),templates=pin(template),selectedSource=source,manifest=manifest,audit=pin(a.audit),sourceCheck=checked,sourceEvidence=evidence,argv=outputs,order=[x for x in doc['order'] if x!='source-check01'],defaultReference=doc['defaultReference'],scope=doc['sourcePolicy'])
    out=folder/'plan.json';out.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(pin(out)))

if __name__=="__main__":
    main()
