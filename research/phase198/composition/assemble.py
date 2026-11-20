"""Build a fresh x86-only experimental checkout from authenticated, checked Bend rules.

The maintained compiler, installed selection, other target manifests and verification
declarations are immutable. This file only assembles source, never selects instructions.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
RESEARCH = HERE.parent
BUILD = ROOT / 'selfhost/build/phase198'
spec = importlib.util.spec_from_file_location('assembly', ROOT / 'selfhost/tools/build/source.py')
src = importlib.util.module_from_spec(spec)
spec.loader.exec_module(src)

# A group can replace one existing def per output module. Dependencies are ordered
# by their checked Bend declarations. The verifier inventory is inherited unchanged.
GROUPS = {
    'fusion': ('fusion-api02', [('p121f_selected', ['fusion/recognize.bend','fusion/emit.bend'])]),
    'quotient': ('quotient-api01', [('p125i_previous_fallback',['quotient/rule.bend'])]),
    'numeric': ('numeric-api03', [('x181_direct',['numeric/evidence/numeric-v1.bend','numeric/hook.bend'])]),
    'orbit': ('numeric-api05', [('x181_direct',['numeric/numeric-orbit.bend','numeric/orbit.bend','numeric/hook.bend'])]),
    'absorb': ('absorb-api05', [('x185_function_copied',['absorbing/absorbing.bend','absorbing/hook.bend'])]),
    'permute': ('reuse-api02', [('x185_function_copied',['reuse/recognize.bend','reuse/select.bend','reuse/hook.bend'])]),
    'pairs': ('loops-api02', [('x190_j_graphed',['loops/paired-v3.bend','loops/hook-v3.bend'])]),
    'tree': ('reuse-fusion-api05', [('x192h_emit_checked',['reuse/pairwise/machine.bend','reuse/pairwise/proof.bend','reuse/pairwise/attach.bend','reuse/pairwise/hook.bend']),
                                   ('x181_request',['reuse/pairwise/entry.bend'])]),
    'register': ('allocation-api01', [('x191_function_saved',['allocation/frame-register.bend','allocation/hook.bend'])]),
}

def declarations(data):
    items = src.blocks(data)[1]
    result = {(i['kind'],i['name']):i for i in items}
    assert len(result)==len(items)
    return result

def body(item):
    return item['data'][item['headerOffset']-item['offset']:].rstrip()

def assemble(out, groups, api_names):
    parent = BUILD/'selected-source01'
    reference = parent/'maintained'
    cfg = Path('src/compiler.json')
    manifest = json.loads((reference/cfg).read_text())
    original = src.maintained_assemble(reference/cfg,reference,'x86')
    assert src.digest(original)=='e0b08475a80ee226d032e4554e88468e82df2559ae767ed2b7f4cea9f56e0b53'
    assert original==(parent/'compiler.bend').read_bytes()
    assert len(set(groups))==len(groups) and groups
    assert not {'orbit','numeric'} <= set(groups)
    out.mkdir(parents=True,exist_ok=False)
    stage = out/'maintained'
    shutil.copytree(reference,stage)
    # A separate checkout exposes only the selected x86 profile. Applying the
    # experimental hooks must never implicitly select them for QBE, C or JS.
    manifest['profiles']={'x86':manifest['profiles']['x86']}
    manifest['defaultProfile']='x86'
    src.dump(stage/cfg,manifest)
    locations = {}
    for name in manifest['modules']+manifest['profiles']['x86']['modules']:
        if name==manifest["preamble"]:
            continue
        file=stage/name
        for key in declarations(file.read_bytes()):
            assert key not in locations,key
            locations[key]=file
    expected={}
    edits={}
    inputs=[]
    checked=[]
    for group in groups:
        api,jobs=GROUPS[group]
        api=api_names.get(group,api)
        receipt=BUILD/api/'report.json'
        a=json.loads(receipt.read_text())
        assert a['complete'] and a['checked']
        assert src.pin(a['source']['file'])==a['source']
        selected=declarations(Path(a['source']['file']).read_bytes())
        checked.append(src.pin(receipt))
        for target,modules in jobs:
            key=('def',target)
            assert key in locations and target not in manifest['protectedDeclarations']
            for module in modules:
                file=RESEARCH/module
                inputs.append(src.pin(file))
                for k,d in declarations(file.read_bytes()).items():
                    assert k in selected and body(d)==body(selected[k]), (k,api)
                    if k not in locations and k not in expected:
                        edits.setdefault(target,[]).append(d['data'].strip())
                    elif k==key:
                        assert k not in expected or (target=='x185_function_copied' and 'permute'in groups and 'absorb'in groups),k
                    else:
                        raise ValueError('Unexpected existing declaration '+repr(k))
                    assert k[1] not in manifest['protectedDeclarations']
                    expected[k]=d
    joins=[]
    for target,parts in edits.items():
        key=('def',target)
        new=expected[key]['data'].strip()
        if target=='x185_function_copied' and 'permute'in groups and 'absorb'in groups:
            perm=declarations((RESEARCH/'reuse/hook.bend').read_bytes())[key]['data'].strip()
            helper=perm.replace(b'def x185_function_copied(',b'def x198p_after_absorb(')
            absbody=declarations((RESEARCH/'absorbing/hook.bend').read_bytes())[key]['data'].strip()
            new=absbody.replace(b'x186_float_function(symbol,params,setup,x198a_body',b'x198p_after_absorb(symbol,params,setup,x198a_body')
            assert helper!=perm and new!=absbody
            parts.append(helper)
            joins.append(dict(name=target,stages=['x198a_body','x198p_after_absorb'],helper='x198p_after_absorb'))
        parts.append(new)
        file=locations[key]
        old=file.read_bytes()
        entry=declarations(old)[key]
        file.write_bytes(old[:entry['offset']]+b'\n'+b'\n\n'.join(parts)+b'\n'+old[entry['offset']+len(entry['data']):])
    # Update only the inventory for new declarations in *shared* semantic owners.
    manifest=src.refresh_recipe(stage/cfg,stage)
    src.dump(stage/cfg,manifest)
    built=src.maintained_assemble(stage/cfg,stage,'x86')
    dest=out/'compiler.bend'
    dest.write_bytes(built)
    old,new=declarations(original),declarations(built)
    retired=sorted(old.keys()-new.keys())
    assert retired==([('def','p169n_compile'),('def','p169n_prepared')] if 'tree' in groups else [])
    for key in retired:
        filename=locations[key]
        assert body(declarations(filename.read_bytes())[key])==body(old[key])
        assert body(declarations((reference/filename.relative_to(stage)).read_bytes())[key])==body(old[key])
    observed={k for k in new if k not in old or body(new[k])!=body(old[k])}
    allowed=expected.keys() | {('def',j['helper']) for j in joins}
    missing=sorted(allowed-new.keys())
    assert all(k not in old and k!=('def','main') for k in missing)
    assert observed==(allowed&new.keys()),(observed-allowed,(allowed&new.keys())-observed)
    excepted={('def',j['name']) for j in joins}
    assert all(body(new[k])==body(d) for k,d in expected.items() if k not in excepted and k in new)
    assert not set(manifest['protectedDeclarations'])&{k[1] for k in observed}
    method_copy=out/'assemble.py'
    shutil.copyfile(__file__,method_copy)
    audit={'complete':True,'kind':'phase198-isolated-composition','selectedSource':src.pin(dest),
           'method':src.pin(method_copy),'methodPathInRepo':str(Path(__file__).resolve().relative_to(ROOT)),'parentSHA256':src.digest(original),'groups':groups,
           'checkedAPIs':checked,'inputs':inputs,'changedExisting':[list(k) for k in sorted(observed&old.keys())],
           'addedDeclarations':len(new.keys()-old.keys()),'unchangedBecameUnreachable':retired,'missingFromExecutable':missing,
           'individualBodiesCompared':len(expected.keys()&new.keys())-len(excepted),
           'explicitHookJoins':joins,'exactExecutableBodiesIdentical':not joins,
           'scope':'Unchanged parent declarations and all individual rules compared by executable body. Any listed composition glue needs an independent full-source check before acquisition.'}
    src.dump(out/'audit.json',audit)
    print(json.dumps({k:audit[k] for k in ('selectedSource','groups','changedExisting','addedDeclarations','explicitHookJoins')}))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--groups',required=True,nargs='+',choices=GROUPS)
    p.add_argument('--api',action='append',default=[],metavar='GROUP=CHECKED_FOLDER')
    args=p.parse_args()
    overrides=dict(x.split('=',1) for x in args.api)
    assert set(overrides)<=set(args.groups) and all(n.replace('-','').isalnum() for n in overrides.values())
    assemble(args.out,args.groups,overrides)
