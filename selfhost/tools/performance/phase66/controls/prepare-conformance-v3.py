#!/usr/bin/env python3
"""Stage existing conformance tools privately and print guarded observation commands; no targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase66'
OLD='018751270e800bc222a93dad7f257083ee53a5f7'
NEW='059266225b77c8ca256ac6b25ee5c21449bab151'

def pin(p):
    p=p.resolve(strict=True); b=p.read_bytes()
    return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--attempt',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--roles',default='typescript-old,typescript-new,bend-unchanged-new-base')
    ap.add_argument('--scope',choices=['screen25','delta','full-frontend','full-js','selected'],default='screen25')
    ap.add_argument('--selection',type=Path)
    ap.add_argument('--js-backend',choices=['direct','legacy'],default='direct')
    ap.add_argument('--node',type=Path,default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
    a=ap.parse_args(); a.out=a.out.resolve()
    assert (a.scope=='selected') == bool(a.selection)
    custom_selection=json.loads(a.selection.read_text()) if a.selection else None
    assert a.out.is_relative_to(RAW) and not a.out.exists()
    f=a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt
    at=json.loads(f.read_text()); assert at['checked']
    snapshot=Path(at['snapshot']['root'])
    for key in ['api','runtime','base','node']:
        assert pin(Path(at[key]['file']))['sha256']==at[key]['sha256']
    assert pin(a.node)['sha256']==at['node']['sha256']
    expected_snapshot={}
    for row in at['snapshot']['sources']:
        item=row['frozen']; src=Path(item['file']); actual=pin(src)
        assert actual['sha256']==item['sha256']
        rel=src.relative_to(snapshot); assert str(rel) not in expected_snapshot
        expected_snapshot[str(rel)]=actual
    roles=a.roles.split(','); assert len(roles)==len(set(roles))
    allowed={'typescript-old','typescript-new','bend-unchanged-old-base','bend-unchanged-new-base','bend-candidate-new-base'}
    assert roles and set(roles)<=allowed
    if a.scope=='full-js':
        assert not set(roles)&{'typescript-old','bend-unchanged-old-base'}, 'The full JS selector belongs to the new inventory only'
    a.out.mkdir(parents=True); commands=[]; images=[]
    inv=ROOT/'selfhost/tools/performance/phase66/controls/inventory01'
    for role in roles:
        old=role in {'typescript-old','bend-unchanged-old-base'}
        # External newdelta fixtures permit old TS/old Base to observe the same new source.
        tree=ROOT/'selfhost/.bootstrap'/('upstream-phase23' if old else 'upstream-phase66')
        revision=OLD if old else NEW
        project=a.out/role/'project'; project.mkdir(parents=True)
        copies=[]
        for rel,identity in expected_snapshot.items():
            src=Path(identity['file']); dest=project/rel; dest.parent.mkdir(parents=True,exist_ok=True)
            dest.write_bytes(src.read_bytes()); assert pin(dest)['sha256']==identity['sha256']
            copies.append(dict(source=identity,copy=pin(dest)))
        # This is an isolated harness inventory pin, never a compiler-image lineage claim.
        manifest=project/'src/compiler.json'; before=pin(manifest)
        config=json.loads(manifest.read_text()); config['upstream']=revision
        manifest.write_text(json.dumps(config,indent=2)+'\n')
        api=project/'dist/conformance-api.mjs'; api.parent.mkdir(parents=True,exist_ok=True)
        api.write_bytes(Path(at['api']['file']).read_bytes()); assert pin(api)['sha256']==at['api']['sha256']
        # Publish both conventional and explicit API names with identical bytes.
        default_api=project/'dist/typed-api.mjs'; default_api.write_bytes(api.read_bytes())
        assert pin(default_api)['sha256']==at['api']['sha256']
        base=tree/'bend2/base.bend'
        bundled_base=project/'dist/base.bend'; bundled_base.write_bytes(base.read_bytes())
        assert pin(bundled_base)['sha256']==pin(base)['sha256']
        is_ts=role.startswith('typescript')
        adapter=project/'tools/conformance/adapters'/('upstream.mjs' if is_ts else 'typed.mjs')
        # Upstream changed only display spelling here; preserve raw graph/trust propagation.
        adapter_change=None
        if is_ts and not old:
            old_adapter=pin(adapter); text=adapter.read_text(); edits=[]
            for old_text,new_text in [("list.map(key=>'- '+key+'\\n').join('')","list.map(key=>'- '+B.name_key(key)+'\\n').join('')"),
                ("term.$==='ADT'?term.c:[term]","term.$==='ADT'?[term,...term.c]:[term]")]:
                if old_text in text:
                    assert text.count(old_text)==1; text=text.replace(old_text,new_text); edits.append(dict(before=old_text,after=new_text))
                else: assert text.count(new_text)==1
            adapter.write_text(text)
            adapter_change=dict(before=old_adapter,after=pin(adapter),edits=edits,reason='0592662 main.ts: displayed name_key plus ADT own kind dependencies; raw graph keys unchanged')
        backend_change=None
        if not is_ts and a.js_backend=='direct' and a.scope in ['screen25','full-js','selected']:
            old_adapter=pin(adapter); text=adapter.read_text(); needle='backend:lane,combinedOutput:true'
            assert text.count(needle)==1
            text=text.replace(needle,"backend:lane==='js'?'direct':lane,combinedOutput:true")
            adapter.write_text(text)
            backend_change=dict(before=old_adapter,after=pin(adapter),reason='Explicit primary direct JS lane; ordinary owned driver, unchanged output oracle')
        environment={'BEND_UPSTREAM':str(tree),'BEND_BASE':str(base),'BEND_TYPED_API':str(api),
            'BEND_TYPED_RUNTIME':str(project/'src/runtime.mjs'),'BEND_TYPED_TRACE':'','NODE_OPTIONS':'','NODE_PATH':''}
        lanes=['frontend','js'] if a.scope=='screen25' else ['js'] if a.scope=='full-js' else ['frontend']
        if custom_selection is not None:
            wanted={x for row in custom_selection['cases'] for x in row['lanes']}
            assert wanted and wanted <= {'parse','check','js'}
            lanes=(["frontend"] if wanted & {'parse','check'} else [])+(["js"] if 'js' in wanted else [])
        for lane in lanes:
            dest=a.out/role/lane; dest.mkdir()
            command=[str(a.node),'--stack-size=4096','--max-old-space-size=1024',str(project/'tools/conformance/run.mjs'),
                '--upstream',str(tree),'--adapter',str(adapter),'--output',str(dest/'report.json'),
                '--jobs','1','--timeout','10000','--worker-mode','persistent' if lane=='frontend' else 'isolated',
                '--recycle-after','64','--rss-limit-mb','1536','--stack-kb','4096','--heap-mb','1024',
                '--lanes','parse,check' if lane=='frontend' else 'js','--retain','all','--selected-exit','1']
            expected=None
            if a.scope in {'screen25','delta','full-js','selected'}:
                if custom_selection is not None: selection=custom_selection
                else:
                    name={'screen25':'screen25.json','delta':'delta-frontend.json','full-js':'full-js-applicable.json'}[a.scope]
                    selection=json.loads((inv/name).read_text())
                cases=[]
                for row in selection['cases']:
                    ls=[x for x in row['lanes'] if (x in ['parse','check'])==(lane=='frontend')]
                    if ls: cases.append(dict(row,lanes=ls))
                assert cases
                selected=dest/'selection.json';selected.write_text(json.dumps(dict(cases=cases),indent=2)+'\n')
                expected=sum(len(x['lanes']) for x in cases);command+=['--selection',str(selected)]
            else: expected=(1513 if old else 1587)*2
            seconds=180 if a.scope in ['screen25','selected'] else 600 if a.scope=='delta' else 1800
            guard=['python3','-B',str(ROOT/'selfhost/tools/performance/phase32/bounded-run.py'),'--seconds',str(seconds),
                '--rss-mib','2048','--available-mib','4096',str(dest/'supervisor'),'--','taskset','-c','3',
                'env',*[key+'='+value for key,value in environment.items()],*command]
            commands.append(dict(name=role+'-'+lane,command=guard,environment=environment,expectedObservations=expected,
                report=str(dest/'report.json'),expectedExitCodes=[0,1],
                interpretation='Exit1 may mean completed observed conformance failures. Never convert it into passing conformance; require finished/stable inputs and inspect every row. Crashes/timeouts are separate.'))
        images.append(dict(role=role,attempt=pin(f),compilerImage=pin(api),defaultCompilerImage=pin(default_api),upstream=revision,base=pin(base),bundledBase=pin(bundled_base),
            harnessManifestBefore=before,harnessManifestAfter=pin(manifest),adapterDisplayChange=adapter_change,adapterBackendChange=backend_change,copies=copies,
            scope='Private tool/project copy; original compiler image preserved. New Base and reference/harness pin are explicit independent axes.'))
    result=dict(kind='phase66-conformance-observation-recipe',executed=False,producer=pin(Path(__file__)),node=pin(a.node),
        scope=a.scope,roles=roles,jsBackend=a.js_backend,selection=pin(a.selection) if a.selection else None,images=images,commands=commands,
        policy='Root executes serial CPU3 guarded jobs individually. Do not feed expected failures to a stop-on-nonzero launcher without preserving and interpreting their reports. Frontend uses one persistent worker; JS execution is isolated. No Lean kernel/GPU targets or new performance claim.')
    out=a.out/'recipe.json';out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(recipe=pin(out),commands=len(commands),targetExecuted=False)))

if __name__=='__main__':main()
