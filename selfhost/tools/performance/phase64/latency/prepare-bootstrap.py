#!/usr/bin/env python3
"""Data-only candidate plan and final image pins; never runs a compiler."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shlex

ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT / 'selfhost/tools/performance/phase61/validation/prepare-candidate-v4.py'
PARENT_SHA = 'ccd302ef74f60696d9e9a474235d83b00e7363b983408847cf65a60a92dcb144'
BASE_ADDED_ROOTS = {'base_prefix_prepare','check_program_diagnostic_seed','f_fresh_prefix_prepare','f_graph_trace_from_prefix'}
TOOLS = ROOT / 'selfhost/tools/performance'
HISTORY = ROOT / 'selfhost/build/phase55/bootstrap-own-host02-plan01'
PARENTS = {
    'expose-stages.mjs': 'e8a5456f383035d4b88a79c6f0264beef0e3dd7e8766fe29c049964e386bbd31',
    'emit-split.mjs': 'e2b66ec96c55019fc64a7cbfe8e15dff156ec55a148d1695894e2246a2c3e561',
    'driver-probe.mjs': 'ca3cb77dc7ec6a3f107b7e2a13658df04845d736390f07132e34d0f99f05f079',
    'compare-driver.mjs': '338f378d28b4b7ef7cb85b1d9c5a84fa5097ca254c42fce49defea046eb150d4',
}

def identity(file):
    file = Path(file).resolve()
    return {'file': str(file), 'sha256': hashlib.sha256(file.read_bytes()).hexdigest()}

def read(file):
    return json.loads(Path(file).read_text())

def write(file, value):
    with Path(file).open('x') as out:
        out.write(json.dumps(value, indent=2) + '\n' if not isinstance(value, str) else value)

def fresh(file):
    file = Path(file).resolve()
    assert file.is_relative_to(ROOT / 'selfhost/build/phase64') and not file.exists()
    return file

def definition(text, name):
    lines = text.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if line.startswith('def ' + name + '(')]
    assert len(starts) == 1, name
    end = starts[0] + 1
    while end < len(lines) and (not lines[end].strip() or lines[end][0].isspace()):
        end += 1
    return ''.join(lines[starts[0]:end]).rstrip()

def plan(attempt_directory, output, admission_file):
    attempt_directory = Path(attempt_directory).resolve()
    attempt = read(attempt_directory / 'attempt.json')
    assert attempt['kind'] == 'bend-development-attempt' and attempt['checked'] is True
    boot = read(attempt['bootstrapReport']['file'])
    source = identity(boot['source'])
    assert source['sha256'] == boot['sourceSha256']
    before = read(HISTORY / 'full77.json')
    admission_id = identity(admission_file); admission = read(admission_file)
    assert admission['kind'] == 'phase61-bootstrap-export-admission' and admission['version'] == 1
    extra = admission['addedRoots']
    assert isinstance(extra,list) and all(isinstance(x,str) and x for x in extra) and len(extra)==len(set(extra))
    assert not (set(extra) & (set(before['roots']) | BASE_ADDED_ROOTS)), 'Duplicate supplementary exports'
    added_roots = BASE_ADDED_ROOTS | set(extra)
    selected_driver = identity(admission['driver']['file'])
    assert selected_driver['sha256'] == admission['driver']['sha256']
    if 'bytes' in admission['driver']: assert Path(selected_driver['file']).stat().st_size == admission['driver']['bytes']
    original_core = Path(before['core']['file']).read_text()
    core = identity(Path(attempt['snapshot']['root']) / 'src/back/js/direct/core.bend')
    current_core = Path(core['file']).read_text()
    reach = identity(Path(attempt['snapshot']['root']) / 'src/back/js/direct/reach.bend')
    current_reach = Path(reach['file']).read_text()
    # The split helper calls the actual candidate's exposed selectedContext.
    # Only this exact batch substitution is admitted; tiny unsplit equality is retained.
    batch_context = ('def jd_selected_context(+book: List<&2,KDef>, +defs: List<&2,KDef>) -> List<&2,KDef>:\n'
                     '  book_put_many(book, defs)')
    library_seams = []
    for name in ['jd_library_selected', 'jd_selected_context', 'jd_library_context']:
        previous = definition(original_core, name)
        current = definition(current_core, name)
        exact = previous == current
        batch = name == 'jd_selected_context' and current == batch_context
        assert exact or batch, name
        library_seams.append(dict(name=name, historicalBody=previous, selectedBody=current,
                                  unchanged=exact, exactBatchContext=batch and not exact))
    plan_seams = []
    expected_library = 'def jd_plan_library(+plan: JDPlan) -> String:\n  match plan:\n    case JDPlan{book, defs, texts, error}: kc(String, String.eq(error, ""),\n      u => "// Direct JavaScript prototype: native functions and live arguments.\\n" ++\n        jd_plan_definitions(defs, texts) ++ jd_exports(book, defs),\n      u => jd_fail(error))'
    actual_library = definition(current_reach, 'jd_plan_library')
    assert actual_library == expected_library, 'JDPlan library decomposition changed'
    plan_seams.append(dict(name='jd_plan_library', selectedBody=actual_library))
    out = fresh(output); out.mkdir(parents=True); (out / 'tools').mkdir()
    assert identity(PARENT)['sha256'] == PARENT_SHA
    inputs = [identity(__file__), identity(PARENT), identity(attempt_directory/'attempt.json'), identity(attempt['bootstrapReport']['file']),
              source, identity(HISTORY/'full77.json'), identity(HISTORY/'driver.json'), identity(before['core']['file']), core, reach]
    derivations = []
    for name, expected in PARENTS.items():
        parent = TOOLS / 'phase55/bootstrap' / name
        parent_id = identity(parent); assert parent_id['sha256'] == expected
        text = parent.read_text(); edits = []
        for old, destination in [('../../phase54/bootstrap/adapter.mjs', TOOLS/'phase54/bootstrap/adapter.mjs'),
                                 ('../../../development/workflow.mjs', ROOT/'selfhost/tools/development/workflow.mjs')]:
            token = "from '" + old + "'"
            if token in text:
                assert text.count(token) == 1
                replacement = 'from ' + json.dumps(destination.as_uri())
                text = text.replace(token, replacement); edits.append({'old': token, 'new': replacement})
        if name == 'expose-stages.mjs':
            old = "export const CORE_SHA='" + before['core']['sha256'] + "';"
            new = "export const CORE_SHA='" + core['sha256'] + "';"
            assert text.count(old) == 1; text = text.replace(old, new); edits.append({'old': old, 'new': new})
        if name == 'expose-stages.mjs':
            patches = [
              ("export function exposeStages(api,core,directory) {", "export const REACH_SHA="+repr(reach['sha256'])+";\nexport function exposeStages(api,core,reach,directory) {"),
              ("  verify(api);verify(core);assert.equal(core.sha256,CORE_SHA,'Library decomposition source changed');", "  verify(api);verify(core);verify(reach);assert.equal(core.sha256,CORE_SHA,'Library decomposition source changed');assert.equal(reach.sha256,REACH_SHA,'Plan decomposition source changed');"),
              ("  definitions:'jd_definitions',exports:'jd_exports',failure:'jd_fail'};", "  definitions:'jd_definitions',exports:'jd_exports',failure:'jd_fail',planDefinitions:'jd_plan_definitions'};"),
              ("  verify(api);verify(core);\n  const receipt=", "  verify(api);verify(core);verify(reach);\n  const receipt="),
              ("helpers,scope:'Original checked API bytes/default export unchanged;", "helpers,reach,scope:'Original checked API bytes/default export unchanged;"),
            ]
            for old,new in patches:
                assert text.count(old)==1,(name,old);text=text.replace(old,new);edits.append(dict(old=old,new=new))
        if name == 'emit-split.mjs':
            patches = [
              ("  const derived=exposeStages(report.generator.api,core,out);report.derivation=derived.receipt;", "  const reach=identity(path.join(generator.snapshot.root,'src/back/js/direct/reach.bend'));assert.equal(reach.sha256,config.reach.sha256);report.inputs.push(reach);\n  const derived=exposeStages(report.generator.api,core,reach,out);report.derivation=derived.receipt;"),
              ("  const reachable=step('emitted-reachability',()=>api.jd_reach_selected(context,selected,roots));\n  assert.equal(api.jd_reach_error(reachable),'');selected=api.jd_reach_defs(reachable);", "  const reachable=step('emitted-reachability',()=>api.jd_plan_selected(context,selected,roots));\n  assert.equal(api.jd_plan_error(reachable),'');selected=api.jd_plan_defs(reachable);"),
              ("  const overlaid=step('library-selected-context',()=>stages.selectedContext(context,selected),bookSize);\n  const calls=step('library-callgraph',()=>stages.callgraph(overlaid,selected),bookSize);\n  const valid=step('library-validity',()=>stages.valid(calls));", "  const calls=reachable.book;\n  const valid=step('library-validity',()=>stages.valid(calls));"),
              ("    const definitions=step('library-definitions',()=>stages.definitions(calls,selected),textSize);", "    const definitions=step('library-definitions',()=>stages.planDefinitions(selected,reachable.texts),textSize);"),
              ("    const original=step('tiny-unsplit-equivalence',()=>api.jd_library_selected(context,selected),textSize);\n    assert.equal(emitted,original,'Split pipeline changed emitted bytes');report.splitEqualsUnsplit=true;", "    const original=step('tiny-unsplit-equivalence',()=>api.jd_plan_library(reachable),textSize);\n    assert.equal(emitted,original,'Split plan pipeline changed emitted bytes');\n    const compatibility=step('tiny-compatibility-equivalence',()=>api.jd_library_selected(context,selected),textSize);\n    assert.equal(emitted,compatibility,'Plan versus ordinary selected library changed emitted bytes');report.splitEqualsUnsplit=true;report.planEqualsCompatibility=true;"),
              ("  const D=await import(pathToFileURL(driver.file)),api=await D.loadApi();", "  const graphHelper=identity(path.join(generator.snapshot.root,'tools/base-cache-graph.mjs'));report.inputs.push(graphHelper);\n  const D=await import(pathToFileURL(driver.file)),api=await D.loadApi();assert.equal(D.baseCacheGraphPath,graphHelper.file);"),
            ]
            for old,new in patches:
                assert text.count(old)==1,(name,old);text=text.replace(old,new);edits.append(dict(old=old,new=new))
        if name == 'driver-probe.mjs':
            patches = [
              ("  for(const name of ['typed-driver','assemble','compiler-abi','node-resource-args','native-build'])", "  for(const name of ['typed-driver','base-cache-graph','assemble','compiler-abi','node-resource-args','native-build'])"),
              ("  assert.equal(D.apiPath,apiFile);assert.equal(identity(D.runtimePath).sha256,attempt.runtime.sha256);", "  assert.equal(D.apiPath,apiFile);assert.equal(identity(D.runtimePath).sha256,attempt.runtime.sha256);assert.equal(D.baseCacheGraphPath,path.join(project,'tools/base-cache-graph.mjs'));"),
            ]
            for old,new in patches:
                assert text.count(old)==1,(name,old);text=text.replace(old,new);edits.append(dict(old=old,new=new))
        # identity(new URL(...)) must point at the same unchanged dependencies too.
        for old, destination in [('../../phase54/bootstrap/adapter.mjs', TOOLS/'phase54/bootstrap/adapter.mjs'),
                                 ('../../../development/workflow.mjs', ROOT/'selfhost/tools/development/workflow.mjs')]:
            old_text = "new URL('" + old + "',import.meta.url)"
            if old_text in text:
                new_text = 'new URL(' + json.dumps(destination.as_uri()) + ')'
                text = text.replace(old_text, new_text); edits.append({'old': old_text, 'new': new_text})
        target = out/'tools'/name; write(target, text)
        inputs.append(parent_id); derivations.append({'parent': parent_id, 'output': identity(target), 'edits': edits})
    roots = boot['exports']
    assert isinstance(roots, list) and len(roots) == len(set(roots)) and all(isinstance(x,str) for x in roots)
    assert set(roots) == set(before['roots']) | added_roots, 'Unexpected checked bootstrap export set'
    assert [x for x in roots if x not in added_roots] == before['roots'], 'Historical export order changed'
    inputs.extend([admission_id,selected_driver])
    roots_reference = {'kind':'phase61-checked-bootstrap-export-reference','roots':roots,
                       'bootstrap':identity(attempt['bootstrapReport']['file']), 'attempt':identity(attempt_directory/'attempt.json'),
                       'historical':identity(HISTORY/'full77.json'),'addedRoots':sorted(added_roots),
                       'admission':admission_id,'baseAddedRoots':sorted(BASE_ADDED_ROOTS)}
    write(out/'roots-reference.json', roots_reference)
    config = copy.deepcopy(before)
    config['roots'] = list(roots)
    config.update(subjectAttempt=str(attempt_directory), subjectSource=source, core=core, reach=reach,
                  driver=identity(Path(attempt['snapshot']['root'])/'tools/typed-driver.mjs'),
                  directRuntime=identity(Path(attempt['snapshot']['root'])/'src/runtime/js/direct.mjs'))
    assert config['driver']['sha256'] == selected_driver['sha256'], 'Not the reviewed combined driver'
    config['exactInputs'] = [identity(attempt_directory/'attempt.json'), identity(attempt['bootstrapReport']['file']),
                             source, identity(attempt['base']['file'])]
    config['scope'] = 'Phase64 candidate own-source generation using recorded Phase55 diagnostic-tool derivatives; inherited checking, not fresh self-check.'
    assert config['roots'] == boot['exports']
    write(out/'full-roots.json', config)
    tiny = copy.deepcopy(config); tiny.update(roots=config['qualificationRoots'], compareUnsplit=True)
    write(out/'tiny.json', tiny)
    driver = {**config, 'kind': 'phase55-compiler-driver-plan', 'tests': read(HISTORY/'driver.json')['tests']}
    write(out/'driver.json', driver)
    node = attempt['node']['file']; commands = []
    def job(name, script, args, seconds):
        command = ['python3', str(TOOLS/'phase32/bounded-run.py'), '--seconds', str(seconds), '--rss-mib', '2048',
                   '--available-mib', '4096', str(out/(name+'-supervisor')), '--', 'taskset', '-c', '3', node,
                   '--max-old-space-size=1024', '--stack-size=4096', str(out/'tools'/script), *map(str,args)]
        commands.append({'name': name, 'command': command})
    job('tiny', 'emit-split.mjs', [out/'tiny.json', attempt_directory, out/'tiny'], 90)
    job('full', 'emit-split.mjs', [out/'full-roots.json', attempt_directory, out/'full', out/'tiny/report.json'], 180)
    for role in ['source', 'direct']:
        job('driver-'+role, 'driver-probe.mjs', [out/'driver.json', out/'full/report.json', role, out/('driver-'+role)], 300)
    commands.append({'name': 'driver-join', 'command': ['taskset','-c','0',node,str(out/'tools/compare-driver.mjs'),
        str(out/'driver-source/report.json'),str(out/'driver-direct/report.json'),str(out/'driver-comparison.json')]})
    commands.append({'name': 'image-pins', 'command': ['taskset','-c','0','python3','-B',str(Path(__file__).resolve()),
        'pins',str(out/'plan.json'),str(out/'full/report.json'),str(out/'driver-comparison.json'),str(out/'image-pins.json')]})
    result = {'kind':'phase56-candidate-image-plan','cwd':str(ROOT),'inputs':inputs,'derivations':derivations,
              'attempt':identity(attempt_directory/'attempt.json'),'configs':[identity(out/n) for n in ['tiny.json','full-roots.json','driver.json']],
              'rootsReference':identity(out/'roots-reference.json'),'admission':admission_id,'commands':commands,'librarySeams':library_seams,'planSeams':plan_seams,
              'scope':'Actual selected JDPlan pipeline with exact source-backed core/reach decomposition. Append-only helper exposes existing plan definitions; tiny output equals both ordinary plan library and compatibility selected library. Genuine checked provenance and inherited-checking scope retained; fresh self-check is separate.'}
    for item in inputs: assert identity(item['file']) == item
    write(out/'plan.json',result)
    write(out/'run.sh','#!/usr/bin/env bash\nset -euo pipefail\ncd '+shlex.quote(str(ROOT))+'\n'+
          '\n'.join(shlex.join(c['command']) for c in commands)+'\n')
    print(json.dumps(identity(out/'plan.json')))

def pins(plan_file, emission_file, comparison_file, output):
    p,e,c = map(read,[plan_file,emission_file,comparison_file])
    assert p['kind']=='phase56-candidate-image-plan'
    assert e['pass'] is True and e['complete'] is True and c['pass'] is True and c['complete'] is True
    assert e['kind']=='phase55-split-compiler-emission' and c['kind']=='phase55-direct-compiler-driver-comparison'
    assert c['observations']==8 and e['subject']['attempt']==p['attempt']==e['generator']['attempt']
    assert e['config']==p['configs'][1]
    reference = read(p['rootsReference']['file']); assert reference['kind']=='phase61-checked-bootstrap-export-reference'
    assert reference['attempt']==p['attempt'] and e['roots']==reference['roots']
    assert reference['admission']==p['admission'] and identity(p['admission']['file'])==p['admission']
    admission=read(p['admission']['file']); assert admission['kind']=='phase61-bootstrap-export-admission' and admission['version']==1
    assert identity(admission['driver']['file'])['sha256']==admission['driver']['sha256']
    assert read(e['config']['file'])['driver']['sha256']==admission['driver']['sha256']
    assert read(reference['bootstrap']['file'])['exports']==reference['roots']
    assert identity(reference['bootstrap']['file'])==reference['bootstrap']
    for r in [read(c['source']['file']),read(c['direct']['file'])]:
        assert r['emission']==identity(emission_file) and r['subject']==e['subject'] and r['generator']==e['generator']
    for item in p['inputs']+p['configs']+[d['output'] for d in p['derivations']]: assert identity(item['file'])==item
    result={'kind':'phase56-direct-image-pins','producer':identity(__file__),'plan':identity(plan_file),
            'attempt':p['attempt'],'emission':identity(emission_file),'comparison':identity(comparison_file),
            'source':e['subject']['source'],'b1':e['generator']['api'],'b2':{k:e['module'][k] for k in ['file','sha256']},
            'runtime':e['directRuntime'],'roots':e['roots'],'rootsReference':p['rootsReference'],'admission':p['admission']}
    for key in ['attempt','emission','comparison','source','b1','b2','runtime','rootsReference','admission']:
        assert identity(result[key]['file'])==result[key]
    write(fresh(output),result); print(json.dumps(identity(output)))

parser=argparse.ArgumentParser(); sub=parser.add_subparsers(dest='mode',required=True)
a=sub.add_parser('plan');a.add_argument('attempt');a.add_argument('out');a.add_argument('--admission',required=True)
a=sub.add_parser('pins');a.add_argument('plan');a.add_argument('emission');a.add_argument('comparison');a.add_argument('out')
args=parser.parse_args()
if args.mode=='plan': plan(args.attempt,args.out,args.admission)
else: pins(args.plan,args.emission,args.comparison,args.out)
