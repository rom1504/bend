#!/usr/bin/env python3
"""Data-only candidate plan and final image pins; never runs a compiler."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import shlex

ROOT = Path(__file__).resolve().parents[5]
PARENT = Path(__file__).with_name('prepare-candidate-v3.py')
PARENT_SHA = 'de4f2632bb5a5614c4e2d5649b7970f017ca13555d3a4a7097accd8892b06cb3'
SELECTED_DRIVER = ROOT / 'selfhost/tools/performance/phase61/cache/typed-driver-combined03.mjs'
SELECTED_DRIVER_SHA = '30ec69e6677a6696ca6dd4f4779560968c48d93e583b8ebf5c2d6308f75e989b'
ADDED_ROOTS = {'base_prefix_prepare','check_program_diagnostic_seed','f_fresh_prefix_prepare','f_graph_trace_from_prefix'}
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
    assert file.is_relative_to(ROOT / 'selfhost/build/phase61') and not file.exists()
    return file

def definition(text, name):
    lines = text.splitlines(keepends=True)
    starts = [i for i, line in enumerate(lines) if line.startswith('def ' + name + '(')]
    assert len(starts) == 1, name
    end = starts[0] + 1
    while end < len(lines) and (not lines[end].strip() or lines[end][0].isspace()):
        end += 1
    return ''.join(lines[starts[0]:end]).rstrip()

def plan(attempt_directory, output):
    attempt_directory = Path(attempt_directory).resolve()
    attempt = read(attempt_directory / 'attempt.json')
    assert attempt['kind'] == 'bend-development-attempt' and attempt['checked'] is True
    boot = read(attempt['bootstrapReport']['file'])
    source = identity(boot['source'])
    assert source['sha256'] == boot['sourceSha256']
    before = read(HISTORY / 'full77.json')
    original_core = Path(before['core']['file']).read_text()
    core = identity(Path(attempt['snapshot']['root']) / 'src/back/js/direct/core.bend')
    current_core = Path(core['file']).read_text()
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
    out = fresh(output); out.mkdir(parents=True); (out / 'tools').mkdir()
    assert identity(PARENT)['sha256'] == PARENT_SHA
    inputs = [identity(__file__), identity(PARENT), identity(attempt_directory/'attempt.json'), identity(attempt['bootstrapReport']['file']),
              source, identity(HISTORY/'full77.json'), identity(HISTORY/'driver.json'), identity(before['core']['file']), core]
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
        # identity(new URL(...)) must point at the same unchanged dependencies too.
        for old, destination in [('../../phase54/bootstrap/adapter.mjs', TOOLS/'phase54/bootstrap/adapter.mjs'),
                                 ('../../../development/workflow.mjs', ROOT/'selfhost/tools/development/workflow.mjs')]:
            old_text = "new URL('" + old + "',import.meta.url)"
            if old_text in text:
                new_text = 'new URL(' + json.dumps(destination.as_uri()) + ')'
                text = text.replace(old_text, new_text); edits.append({'old': old_text, 'new': new_text})
        target = out/'tools'/name; write(target, text)
        inputs.append(parent_id); derivations.append({'parent': parent_id, 'output': identity(target), 'edits': edits})
    selected_driver = identity(SELECTED_DRIVER)
    assert selected_driver['sha256'] == SELECTED_DRIVER_SHA
    roots = boot['exports']
    assert isinstance(roots, list) and len(roots) == len(set(roots)) and all(isinstance(x,str) for x in roots)
    assert set(roots) == set(before['roots']) | ADDED_ROOTS, 'Unexpected checked bootstrap export set'
    assert [x for x in roots if x not in ADDED_ROOTS] == before['roots'], 'Historical export order changed'
    inputs.append(selected_driver)
    roots_reference = {'kind':'phase61-checked-bootstrap-export-reference','roots':roots,
                       'bootstrap':identity(attempt['bootstrapReport']['file']), 'attempt':identity(attempt_directory/'attempt.json'),
                       'historical':identity(HISTORY/'full77.json'),'addedRoots':sorted(ADDED_ROOTS)}
    write(out/'roots-reference.json', roots_reference)
    config = copy.deepcopy(before)
    config['roots'] = list(roots)
    config.update(subjectAttempt=str(attempt_directory), subjectSource=source, core=core,
                  driver=identity(Path(attempt['snapshot']['root'])/'tools/typed-driver.mjs'),
                  directRuntime=identity(Path(attempt['snapshot']['root'])/'src/runtime/js/direct.mjs'))
    assert config['driver']['sha256'] == selected_driver['sha256'], 'Not the reviewed combined driver'
    config['exactInputs'] = [identity(attempt_directory/'attempt.json'), identity(attempt['bootstrapReport']['file']),
                             source, identity(attempt['base']['file'])]
    config['scope'] = 'Phase61 candidate own-source generation using recorded Phase55 diagnostic-tool derivatives; inherited checking, not fresh self-check.'
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
              'rootsReference':identity(out/'roots-reference.json'),'commands':commands,'librarySeams':library_seams,
              'scope':'Same split/driver algorithms. The two library decomposition bodies remain exact; selected context is either historical or the exact reviewed book_put_many call. The helper calls that actual selected function. Tiny split/unsplit byte equality remains mandatory; inherited checking is not a fresh self-check.'}
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
    assert read(reference['bootstrap']['file'])['exports']==reference['roots']
    assert identity(reference['bootstrap']['file'])==reference['bootstrap']
    for r in [read(c['source']['file']),read(c['direct']['file'])]:
        assert r['emission']==identity(emission_file) and r['subject']==e['subject'] and r['generator']==e['generator']
    for item in p['inputs']+p['configs']+[d['output'] for d in p['derivations']]: assert identity(item['file'])==item
    result={'kind':'phase56-direct-image-pins','producer':identity(__file__),'plan':identity(plan_file),
            'attempt':p['attempt'],'emission':identity(emission_file),'comparison':identity(comparison_file),
            'source':e['subject']['source'],'b1':e['generator']['api'],'b2':{k:e['module'][k] for k in ['file','sha256']},
            'runtime':e['directRuntime'],'roots':e['roots'],'rootsReference':p['rootsReference']}
    for key in ['attempt','emission','comparison','source','b1','b2','runtime','rootsReference']:
        assert identity(result[key]['file'])==result[key]
    write(fresh(output),result); print(json.dumps(identity(output)))

parser=argparse.ArgumentParser(); sub=parser.add_subparsers(dest='mode',required=True)
a=sub.add_parser('plan');a.add_argument('attempt');a.add_argument('out')
a=sub.add_parser('pins');a.add_argument('plan');a.add_argument('emission');a.add_argument('comparison');a.add_argument('out')
args=parser.parse_args()
if args.mode=='plan': plan(args.attempt,args.out)
else: pins(args.plan,args.emission,args.comparison,args.out)
