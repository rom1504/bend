"""Prepare one exact three-override successor and cheap root gates; no targets."""
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('compose',ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
GROUPS = ['p144o_controls:35:prefix','p144e_controls:10:prefix','p144pc_controls:27:suffix',
    'p144ap_controls:23:prefix','p125pc_controls:12:prefix','p127lb_controls:20:suffix',
    'p144ce_controls:27:suffix','p134v_controls:26:prefix','p114s_control_report:18:prefix']


def main():
    selection = ROOT/'implementation/phase144/candidate.json'
    selected = json.loads(selection.read_text()); assert selected['complete'] and selected['nativeQualified']
    before = Path(selected['source']['file']).read_text()
    assert C.pin(selected['source']['file'])==selected['source']
    assert selected['source']['sha256']=='31e1b13a8584130c6a6be67ef6e1f2a6a373433c9c5cac9e880fa3fe403e3ea2'
    pm = json.loads(Path(selected['sourceManifest']['file']).read_text())
    assert C.pin(selected['sourceManifest']['file'])==selected['sourceManifest']
    parent_path = ROOT/'implementation/phase143/candidate.json'
    parent = json.loads(parent_path.read_text()); assert parent['complete'] and parent['nativeQualified']
    assert C.pin(parent['source']['file'])==parent['source']
    assert parent['source']['sha256']=='a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e'
    old = C.blocks(before,combine=True)
    original = C.blocks(Path(parent['source']['file']).read_text(),combine=True)['p125p_admitted']
    assert C.norm(original)!=C.norm(old['p125p_admitted'])
    module_paths = [HERE.parent/'verifier/range-skip-v01.bend',
        HERE.parent/'existence/core-v01.bend',HERE.parent/'existence/disjoint-reference-v01.bend',
        HERE.parent/'existence/controls-v02.bend',HERE.parent/'existence/disjoint-override-v01.bend']
    expected = ['754dbfcc5bcd8a0ad1e9778e823803dd83d953474c1cc9182d99cb95b1422fb1',
        '56389d4130234f50686d45637702ee414e6c69e379b6041efe68eb9aefe11641',
        'c86757d599e0cf95f06d12af138a968a9fe7dd5b6334f5edb10be6d7b9430a9f',
        'fbe9f7b94bb116b508d65c5b44d25025f7998abd59c2e099e4160e023de8f8c0',
        '6f52c3e7eec51adaa4dea292a47d970ba6a0a0764fb5c061c2ecd341935849ac']
    assert [C.pin(p)['sha256'] for p in module_paths]==expected
    modules = [original,*[p.read_text() for p in module_paths]]
    reference = C.blocks(modules[3],combine=True)['p144ce_original_disjoint']
    assert C.norm(reference.replace('p144ce_original_disjoint','base_prefix_ctor_disjoint'))==C.norm(old['base_prefix_ctor_disjoint'])
    overrides = {'p125p_admitted','p114s_ranges','base_prefix_ctor_disjoint'}
    text,added,protected = C.compose(before,modules,overrides,set())
    new = C.blocks(text,combine=True)
    changed = sorted(n for n in old if C.norm(old[n])!=C.norm(new[n]))
    assert changed==sorted(overrides) and set(new)==set(old)|set(added)
    for name in set(pm['protectedDeclarations'])|set(pm['unchangedProofDeclarations']):
        assert C.norm(old[name])==C.norm(new[name]),name
    for name in ['constructor_exists','constructor_names','event_error','p144ap_controls']:
        assert C.norm(old[name])==C.norm(new[name]),name
    assert C.norm(new['p125p_admitted'])==C.norm(original)
    out = ROOT/'selfhost/build/phase144/final04-source01'; assert not out.exists()
    out.mkdir();source=out/'compiler.bend';source.write_text(text)
    for i,module in enumerate(modules): (out/f'module{i}.bend').write_text(module)
    (out/'prepare.py').write_bytes(Path(__file__).read_bytes())
    manifest = dict(kind='phase144-final04-three-override-composition',complete=True,checked=False,nativeQualified=False,
        selected=False,targetsRun=False,source=C.pin(source),parent=selected['source'],parentManifest=selected['sourceManifest'],
        parentQualification=selected['qualification'],restoredAdmissionSource=parent['source'],overrides=changed,added=added,
        protectedDeclarations=pm['protectedDeclarations'],unchangedProofDeclarations=pm['unchangedProofDeclarations'],
        allOtherOriginalDeclarationsNormalizedExact=True,independentDisjointOriginalTraversalExact=True,
        sourceLines=len(text.splitlines()),parentLines=len(before.splitlines()),runtime=selected['runtime'],
        controlGroups=GROUPS,controlCount=198,
        inputs=[C.pin(__file__),C.pin(C.__file__),C.pin(selection),C.pin(parent_path),selected['source'],selected['sourceManifest'],
            selected['qualification'],parent['source'],*[C.pin(p) for p in module_paths]],
        scope='Isolated proposed composition only. No API check, target execution, cost result, native qualification or default change. Wait for outstanding quality decisions before the native generation campaign.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    api=ROOT/'selfhost/build/phase111/p144-integrated-api04'
    finite=ROOT/'selfhost/build/phase144/final04-controls01'
    emitted=ROOT/'selfhost/build/phase144/final04-small-products01'
    assert not api.exists() and not finite.exists() and not emitted.exists()
    prior_api=json.loads(Path(selected['checkedApi']['file']).read_text())
    assert C.pin(selected['checkedApi']['file'])==selected['checkedApi'] and prior_api['complete'] and prior_api['checked']
    exports=list(prior_api['exports'])+['p144ce_controls','p114s_ranges','p134v_controls','p114s_control_report']
    assert len(exports)==len(set(exports))
    parent_cases=ROOT/'selfhost/tools/performance/phase144/emission/string-append/predicate-cases-v01.json'
    cases=json.loads(parent_cases.read_text())['cases'];assert len(cases)==3
    for case in cases:
        for key in ['source','expectedStdoutEvidence','stdoutEvidence']:assert C.pin(case[key]['file'])==case[key]
        assert Path(case['stdoutEvidence']['file']).read_text()==case['expectedStdout']
    catalog=out/'small-cases.json';catalog.write_text(json.dumps(dict(kind='phase144-final04-small-ordinary-cases',complete=True,
        source=C.pin(source),inputs=[C.pin(parent_cases),C.pin(out/'manifest.json')],cases=cases,
        scope='Same three frozen inputs and independent complete stdout; changed QBE allowed. Actual serial link is the machine-build authority.'),indent=2)+'\n')
    guard=ROOT/'selfhost/tools/performance/phase111/guard.py';checker=guard.with_name('check-api.py')
    bun=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun';runner=ROOT/'selfhost/tools/performance/phase143/controls-v01.mjs'
    emitter=HERE.parent/'emission/string-append/emit-v01.mjs';builder=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
    jobs=[]
    def job(name,command,seconds,report):
        inner=list(map(str,command));gp=out/(name+'-guard')
        jobs.append(dict(name=name,command=inner,report=str(report),guardReport=str(gp/'process.json'),
            guardedCommand=['/usr/bin/python3','-B',str(guard),'--out',str(gp),'--seconds',str(seconds),'--cpu','3',
                '--rss-mib','3072','--available-mib','16384','--file-mib','128','--',*inner]))
    job('checked-api',['/usr/bin/python3','-B',checker,'--source',source,'--out',api,*exports],120,api/'report.json')
    job('198-controls',[bun,runner,api/'report.json',finite,*GROUPS],100,finite/'report.json')
    job('three-small-products',[bun,emitter,api/'report.json',catalog,emitted],120,emitted/'report.json')
    for case in cases:
        target=ROOT/'selfhost/build/phase111'/('p144-final04-small-'+case['name'])
        assert not target.exists()
        job('ordinary-'+case['name'],['/usr/bin/python3','-B',builder,'--source',emitted/(case['name']+'.ssa'),
            '--runtime',selected['runtime']['file'],'--out',target,'--expected',case['stdoutEvidence']['file'],'--seconds','30'],90,target/'report.json')
    (out/'jobs.json').write_text(json.dumps(dict(kind='phase144-final04-cheap-root-gates',complete=True,targetsRun=False,
        nativeCampaignAuthorized=False,sourceManifest=C.pin(out/'manifest.json'),controlCount=198,jobs=jobs,
        inputs=[C.pin(x) for x in [__file__,guard,checker,bun,runner,emitter,builder,catalog]],
        scope='Root-only source check, unchanged finite expectations, three verified small products and serial-linked complete stdout. No native self-build jobs; final policy adoption remains pending.'),indent=2)+'\n')
    print(json.dumps(dict(source=C.pin(source),manifest=C.pin(out/'manifest.json'),jobs=C.pin(out/'jobs.json'),changes=changed,added=len(added))))


if __name__=='__main__':main()
