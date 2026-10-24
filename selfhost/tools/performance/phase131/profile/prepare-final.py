#!/usr/bin/env python3
"""Metadata-only final-N2 profiling plan; reuse old oracles and diagnostic runtime.

Prepare after final parent-N2 timing lineage exists. The seal action follows the
root-controlled diagnostic relink. Neither action executes a compiler or target.
"""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[5]
PROF = ROOT / 'selfhost/tools/profiler'
sys.dont_write_bytecode = True
sys.path.insert(0, str(PROF))
from run import all_pins, pin, save, verify


def read(path):
    return json.loads(Path(path).read_text())


def require(ok, message):
    if not ok:
        raise ValueError(message)


def load_module(name, path, sha):
    require(pin(path)['sha256'] == sha, 'Frozen method changed: ' + str(path))
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    return module


T = load_module('p131_final_timing', Path(__file__).parents[1] / 'native/timing-codegen-plan.py',
                '427c475107e6e9667c86297d0a3843b30460e39e9c31aa6625e2087fadbadbeb')
P = load_module('p131_old_profile', Path(__file__).with_name('prepare.py'),
                '69bcf042d25a7a8b211307d67999859cb6d00e176c470dec65c0bf7d16b7e658')
OLD_PHYSICAL = ROOT / 'selfhost/build/phase131/profile01/manifest.json'
OLD_CONTEXT = ROOT / 'selfhost/build/phase131/context01'


def final_lineage(path):
    manifest = read(path)
    require(manifest.get('derivation', {}).get('kind') == 'phase131-final-codegen-experimental-native-request-comparison'
            and manifest.get('researchOnly') and manifest.get('unqualified')
            and manifest.get('nativeQualified') is False, 'Experimental final timing lineage required')
    require(pin(T.__file__) in manifest['inputs'], 'Final timing planner provenance missing')
    for item in all_pins(manifest): verify(item)
    inputs = [read(item['file']) for item in manifest['inputs'] if item['file'].endswith('.json')]
    admissions = [r for r in inputs if r.get('kind') == 'phase131-native-acquisition-admission']
    require(len(admissions) == 1, 'Unique final source admission required')
    ad = admissions[0]; T.codegen_contract(ad, pin(T.FINAL_METHOD))
    for item in all_pins(ad): verify(item)
    right = manifest['roles']['phase112']; image = right['binary']
    require(right['source'] == ad['source'] and not right['nativeQualified'], 'Final-N2 role/source differs')
    qbe = manifest['lineage']['secondQbe']
    builds = [r for r in inputs if r.get('kind') == 'phase123-branch-aligned-qbe-build' and r.get('binary') == image]
    require(len(builds) == 1, 'Unique actual final-N2 build required')
    built = builds[0]
    require(T.T.Q.build(built, qbe, ad['runtime'], manifest['tools']) == image, 'N2 build differs')
    focused = [item for item in manifest['inputs'] if item['file'].endswith('.json')
        and read(item['file']).get('kind') == 'phase125-aligned-native-source-semantic-coverage'
        and image in read(item['file']).get('inputs', [])]
    require(len(focused) == 1, 'Final N2 focused19 receipt required')
    T.T.focused(focused[0]['file'], image, ad['runtime'])
    parent_file = ROOT / 'implementation/phase130/candidate.json'; parent = read(parent_file)
    require(ad['producerSelection'] == pin(parent_file) and ad['runtime'] == parent['runtime'], 'Runtime/parent identity differs')
    require(right['carrierReceipt'] == parent['preferredCarrierReceipt'], 'Compact carrier differs')
    return manifest, ad, image, qbe, built, parent


def cached_runtime(parent):
    plan_path = OLD_CONTEXT / 'runtime/plan.json'; build_path = OLD_CONTEXT / 'build/report.json'
    plan, built = read(plan_path), read(build_path)
    require(plan['schema'] == 'bend-native-profile-runtime-plan-v1' and plan['complete']
            and plan['reverseExact'] and built['complete'] and built['plan'] == pin(plan_path), 'Cached diagnostic build incomplete')
    for item in [*all_pins(plan), *all_pins(built)]: verify(item)
    old_input = read(OLD_CONTEXT / 'runtime-input.json')
    clean = read(verify(parent['runtimeReport']))
    require(clean['complete'] and clean['object'] == parent['runtime']
            and old_input['runtime'] == clean['source'], 'Diagnostic/clean runtime source mismatch')
    for header in old_input['headers']:
        matches = [item for item in clean['inputs'] if Path(item['file']).name == Path(header['file']).name]
        require(matches and all((item['bytes'], item['sha256']) == (header['bytes'], header['sha256'])
                                for item in matches), 'Runtime header content mismatch')
        verify(header)
    require([j['label'] for j in plan['jobs']] == ['compile-runtime', 'link-diagnostic']
            and [j['command'] for j in built['jobs']] == [j['command'] for j in plan['jobs']]
            and all(j['returncode'] == 0 and not j['timedOut'] for j in built['jobs']), 'Diagnostic build commands differ')
    obj = built['jobs'][0]['product']
    require(obj in built['products'] and obj['file'] == plan['jobs'][0]['command'][-1], 'Diagnostic runtime product mismatch')
    return plan, built, obj, [pin(plan_path), pin(build_path), pin(OLD_CONTEXT / 'runtime-input.json'), parent['runtimeReport'], obj]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('action', choices=['prepare', 'seal'])
    for name in ['timing-manifest', 'physical', 'context']:
        ap.add_argument('--' + name, type=Path, required=True)
    a = ap.parse_args(); physical, context = a.physical.resolve(), a.context.resolve()
    require(all(p.is_relative_to(ROOT / 'selfhost/build/phase131') for p in [physical, context])
            and physical != context, 'Distinct Phase131 output directories required')
    timing, ad, image, qbe, built, parent = final_lineage(a.timing_manifest)
    old_plan, old_build, runtime, reuse_evidence = cached_runtime(parent)
    evidence = [pin(__file__), pin(T.__file__), pin(P.__file__), pin(a.timing_manifest),
                ad['source'], image, qbe, built['object'], ad['runtime'], *reuse_evidence]
    if a.action == 'prepare':
        require(not physical.exists() and not context.exists(), 'Fresh profile/context directories required')
        manifest = copy.deepcopy(read(OLD_PHYSICAL))
        for item in all_pins(manifest): verify(item)
        manifest['inputs'] += [pin(OLD_PHYSICAL), *evidence]
        manifest['scope'] = ('Experimental final Phase131 N2, actual admitted native lineage and focused19 only. '
            'Frozen three request sources, compact Base and whole-QBE oracles. N3 qualification separate; no installed change.')
        manifest['lineage'] = dict(nativeQualified=False, experimental=True, timingManifest=pin(a.timing_manifest),
            source=ad['source'], image=image, qbe=qbe, requiredReproduction=ad['requiredReproduction'])
        for work in manifest['workloads']:
            require(len(work['variants']) == 1, 'Frozen one-variant requests required')
            variant = work['variants'][0]; cmd = variant['command']
            require(cmd[0] == parent['n1']['file'] and cmd[1:7] == ['--threads','1','--gpu','off','--','phase111']
                    and len(cmd) == 12 and cmd[9] == 'cache'
                    and cmd[10] == parent['preferredCarrier']['file'] and cmd[11] == parent['preferredStamp'], 'Frozen compact request differs')
            variant['name'] = 'phase131-final-n2'; variant['binary'] = image; cmd[0] = image['file']
            variant['inputs'] = [pin(x) for x in cmd if Path(x).is_file()]
        physical.mkdir(parents=True); context.mkdir(parents=True); (context / 'runtime').mkdir()
        save(physical / 'manifest.json', manifest); save(physical / 'jobs.json', P.jobs(physical, manifest))
        link = copy.deepcopy(old_plan['jobs'][1]); link['command'][2] = built['object']['file']
        link['command'][-1] = str(context / 'runtime/program')
        require(link['command'][3] == runtime['file'], 'Cached diagnostic runtime argument differs')
        relink = copy.deepcopy(old_plan)
        relink.update(compiled=False, executed=False, jobs=[link], outputs=[],
            inputs=[pin(OLD_CONTEXT / 'runtime/plan.json'), *old_plan['inputs'], *old_plan['outputs'], *evidence, pin(physical / 'manifest.json')],
            reusedRuntimeObject=runtime, runtimeBuild=pin(OLD_CONTEXT / 'build/report.json'),
            scope='Relink only: exact final N2 program.o plus authenticated existing context01 diagnostic runtime.o. No runtime recompilation or compiler execution.')
        save(context / 'runtime/plan.json', relink)
        subprocess.run([sys.executable, '-B', str(PROF / 'owners.py'), '--qbe', qbe['file'],
                        '--output', str(context / 'owners.json')], check=True, stdout=subprocess.DEVNULL)
        save(context / 'lineage.json', dict(complete=True, targetsRun=False, nativeQualified=False,
            inputs=evidence + [pin(context / 'owners.json'), pin(PROF / 'owners.py')],
            qbe=qbe, object=built['object'], runtimeObject=runtime,
            ownerScope='Exact linked FID matching is checked by attribution. Lexical lowered-owner grouping remains conditional on the existing emitter contract; not original/inclusive source ancestry.'))
    else:
        manifest = read(physical / 'manifest.json'); report_path = context / 'build/report.json'
        report, plan = read(report_path), read(context / 'runtime/plan.json')
        require(report['complete'] and report['plan'] == pin(context / 'runtime/plan.json')
                and len(report['jobs']) == 1 and report['jobs'][0]['command'] == plan['jobs'][0]['command']
                and report['jobs'][0]['returncode'] == 0 and not report['jobs'][0]['timedOut'], 'Actual diagnostic relink required')
        for item in [*all_pins(manifest), *all_pins(report), *all_pins(plan)]: verify(item)
        require(plan['reusedRuntimeObject'] == runtime and plan['jobs'][0]['command'][2] == built['object']['file'], 'Relink target/runtime differs')
        diagnostic = report['jobs'][0]['product']; require(diagnostic in report['products'], 'Missing diagnostic product')
        manifest['inputs'] += [pin(physical / 'manifest.json'), pin(report_path), pin(context / 'runtime/plan.json'), pin(context / 'lineage.json')]
        manifest['scope'] = 'Diagnostic relink of experimental final N2 with unchanged context01 runtime object. Context-only and event modes require separate overhead. Not a clean baseline.'
        for work in manifest['workloads']:
            variant = work['variants'][0]
            require(variant['binary'] == image, 'Physical N2 identity differs')
            variant['name'] = 'phase131-final-n2-context'; variant['binary'] = diagnostic
            variant['command'][0] = diagnostic['file']; variant['dispatchInstrumentation'] = True
            variant['inputs'] = [pin(x) for x in variant['command'] if Path(x).is_file()]
        require(not (context / 'manifest.json').exists(), 'Fresh context manifest required')
        save(context / 'manifest.json', manifest); save(context / 'jobs.json', P.jobs(context, manifest, True))
    print(json.dumps(dict(complete=True, targetsRun=False, action=a.action, physical=str(physical), context=str(context))))


if __name__ == '__main__':
    main()
