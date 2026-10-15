#!/usr/bin/env python3
"""Prepare (never apply) host large-table lookup + O0 compatibility runtime patch."""
import argparse, difflib, importlib.util, json, sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p90_o0', HERE/'prepare-runtime-o0.py')
H=importlib.util.module_from_spec(spec); spec.loader.exec_module(H)
BEFORE='static const WlFn wl_tab[] = { WL_TABLE };\n#undef WL_X\n#endif'
AFTER="static const WlFn wl_tab[] = { WL_TABLE };\n#undef WL_X\n#if FID_ENTER >= 4096\n// Keep the shared dispatch table out of each segment's LLVM reference graph.\nFAR PRESERVE(preserve_most) WlFn wl_target(Fid id) { return wl_tab[id]; }\n#undef WL_DYN\n#define WL_DYN(F) __attribute__((musttail)) return wl_target(F)(WL_ALL)\n#endif\n#endif"
EDITS=[(H.BEFORE,H.AFTER),(BEFORE,AFTER)]

def patch(a,b,name):
    return ''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='a/'+name,tofile='b/'+name))

def transform(text):
    for before,after in EDITS:
        assert text.count(before)==1; text=text.replace(before,after,1)
    return text

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode',choices=['prepare','finish']);p.add_argument('out',type=Path);p.add_argument('attempt',type=Path,nargs='?')
    a=p.parse_args();out=a.out.resolve()
    if a.mode=='prepare':
        assert a.attempt;out.mkdir(parents=True,exist_ok=False)
        attempt=H.pin(a.attempt);checked=json.loads(Path(attempt['file']).read_text())
        assert checked['checked'];api=H.verify(checked['api'])
        old=[H.pin(H.ROOT/f) for f in H.FILES]
        assert old[0]['sha256']==H.RUNTIME_SHA and old[1]['sha256']==H.TEMPLATE_SHA
        runtime=Path(old[0]['file']).read_text();candidate=transform(runtime)
        inverse=candidate
        for before,after in reversed(EDITS):inverse=inverse.replace(after,before,1)
        assert inverse==runtime
        upstream=H.ROOT/'bend2/comp.ts';assert H.AFTER in upstream.read_text()
        # Definitions are injected at Tables; the conditional lives in Work.
        assert runtime.index('// Tables') < runtime.index(BEFORE)
        assert runtime.rfind('#if !DEVICE',0,runtime.index(BEFORE))>runtime.index('// Tables')
        H.write(out/'runtime.c',candidate)
        H.write(out/'runtime-only.patch',patch(runtime,candidate,H.FILES[0]))
        generator=H.ROOT/'selfhost/tools/development/native-template.mjs'
        source_audit=[H.pin(H.ROOT/f) for f in ['selfhost/src/back/native/tables.bend','selfhost/src/back/native/emit.bend']]
        plan=dict(kind='phase90-runtime-large-table-accessor-plan',complete=True,targetExecuted=False,
          method=H.pin(__file__),helper=H.pin(HERE/'prepare-runtime-o0.py'),canonicalInputs=old,
          upstream=H.pin(upstream),attempt=attempt,api=api,generator=H.pin(generator),source=H.pin(out/'runtime.c'),
          sourceAudit=source_audit,edits=[dict(before=b,after=c) for b,c in EDITS],threshold=4096,
          templateCommand=['/home/ai/.nvm/versions/node/v24.18.0/bin/node',str(generator),attempt['file'],str(out/'runtime.c'),str(out/'runtime-template.json'),str(out/'template-receipt.json')],
          followup=[sys.executable,'-B',str(Path(__file__).resolve()),'finish',str(out)],
          scope='Prepared only. Late host-only conditional sees emitted FID_ENTER define; small optimized bodies use direct table dispatch. O0 guard intentionally fixes attributes at every size. GPU branch unchanged.')
        H.save(out/'plan.json',plan);print(json.dumps(dict(plan=str(out/'plan.json'),source=plan['source'])));return
    assert a.attempt is None
    plan_pin=H.pin(out/'plan.json');plan=json.loads(Path(plan_pin['file']).read_text())
    assert plan['kind']=='phase90-runtime-large-table-accessor-plan'
    for r in plan['canonicalInputs']+plan['sourceAudit']+[plan[k] for k in ['method','helper','upstream','attempt','api','generator','source']]:H.verify(r)
    receipt_pin=H.pin(out/'template-receipt.json');receipt=json.loads(Path(receipt_pin['file']).read_text())
    assert receipt['kind']=='bend-native-template' and receipt['chunks']==5 and receipt['exactRoundTrip']
    for k,parent in [('producer','api'),('attempt','attempt'),('generator','generator'),('runtime','source')]:assert H.verify(receipt[k])==plan[parent]
    artifact=H.verify(receipt['artifact']);assert artifact['file']==str(out/'runtime-template.json')
    data=json.loads(Path(artifact['file']).read_text());old_template=json.loads(Path(plan['canonicalInputs'][1]['file']).read_text())
    assert data['version']==1 and data['runtimeSha256']==plan['source']['sha256'] and len(data['parts'])==5
    assert ''.join(data['parts'])==(out/'runtime.c').read_text()
    expected=[]
    for part in old_template['parts']:
        for before,after in EDITS:part=part.replace(before,after)
        expected.append(part)
    assert data['parts']==expected
    assert all(data['parts'][i]==old_template['parts'][i] for i in [1,3,4])
    driver=Path(plan['canonicalInputs'][2]['file']).read_text()
    marker="const nativeTemplateSha256='"+H.TEMPLATE_SHA+"';";assert driver.count(marker)==1
    H.write(out/'typed-driver.mjs',driver.replace(marker,"const nativeTemplateSha256='"+artifact['sha256']+"';",1))
    outputs=[H.pin(out/'runtime.c'),artifact,H.pin(out/'typed-driver.mjs')]
    chunks=[patch(Path(old['file']).read_text(),Path(new['file']).read_text(),name) for name,old,new in zip(H.FILES,plan['canonicalInputs'],outputs)]
    H.write(out/'canonical.patch',''.join(chunks))
    H.save(out/'ready.json',dict(kind='phase90-runtime-large-table-accessor-prepared',complete=True,canonicalMutated=False,plan=plan_pin,templateReceipt=receipt_pin,inputs=plan['canonicalInputs'],outputs=outputs,patch=H.pin(out/'canonical.patch'),qualificationPending=True))
    print(json.dumps(dict(patch=H.pin(out/'canonical.patch'),canonicalMutated=False)))

if __name__=='__main__':main()
