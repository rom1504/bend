#!/usr/bin/env python3
"""Revalidate both paired compiler-cost screens and write reproducible JSON/findings."""
import argparse
import importlib.util
import json
import math
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('phase195_cost_plan', Path(__file__).with_name('compiler-cost-plan.py'))
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
B, C, A = M.B, M.C, M.A
ROLES = ['baseline', 'candidate']
SCOPE = ('Four development source-to-object requests, two reversed rounds per stage, fresh compiler processes '
         'and cached Base. Includes startup, checking, lowering/optimization and object emission. '
         'Excludes linking and generated-program execution. All samples retained.')
INTERPRETATION = ('N1 compares compiler implementations produced by the same frozen QBE seed/toolchain. '
                  'N2 measures the net compiler implementation and generated x86 change. '
                  'The screens are separate; two rounds provide a bounded guardrail, not statistical '
                  'significance or broad compiler/research-throughput evidence.')


def screen(path, stage, evidence):
    receipt = C.pin(path)
    report = evidence.read(receipt)
    A.P.completed(report, stage+' compiler measurement')
    C.require(report.get('schema') == 'bend-benchmark-report-v1' and report.get('status') == 'measured',
              'Complete measured compiler report required')
    plan = report['plan']
    manifest = evidence.read(plan['manifest'])
    C.require(manifest.get('schema') == 'bend-benchmark-manifest-v1'
              and manifest.get('kind') == plan.get('kind') == 'compiler'
              and manifest['roles'] == plan['roles'] and list(manifest['roles']) == ROLES
              and manifest['reference'] == plan['reference'] == 'baseline'
              and plan['rounds'] == 2 and plan['scale'] == 1
              and plan['cases'] == M.P.CASES
              and [c['id'] for c in manifest['cases']] == M.P.CASES
              and [c['id'] for c in report['cases']] == M.P.CASES,
              'Exact four-case, two-round paired compiler plan required')
    for item in manifest['inputs']:
        evidence.verify(item)
    for role in manifest['roles'].values():
        C.require(role['host'] == 'native' and role['stage'] == stage
                  and role['target'] == 'x86' and role['emit'] == 'object'
                  and role['preparation'] == 'cache', 'Actual native cached-object stage required')
    rows, rss, warnings = [], [], []
    for case, measured in zip(manifest['cases'], report['cases']):
        name = case['id']
        C.require(measured['rounds'] == 2 and measured['sourceGroup'] == case['source']['sha256']
                  and [(r['round'], r['role']) for r in measured['samples']]
                  == [(0, 'baseline'), (0, 'candidate'), (1, 'candidate'), (1, 'baseline')],
                  'Exactly two position-balanced rounds required: '+name)
        C.require(case['requests']['baseline']['command'][1:] == case['requests']['candidate']['command'][1:],
                  'Paired request inputs differ: '+name)
        for sample in measured['samples']:
            request, process = case['requests'][sample['role']], sample['process']
            C.require(sample.get('correct') is True and sample.get('scope') == request['scope'] == 'request'
                      and process['command'] == request['command'] and process['exitCode'] == 0
                      and process['timedOut'] is False and math.isfinite(process['seconds'])
                      and process['seconds'] > 0 and sample['metricMs'] == process['seconds'] * 1000,
                      'Exact successful process clock/request required: '+name)
            for key in ('stdout', 'stderr'):
                actual, expected = evidence.verify(process[key]), evidence.verify(request[key])
                C.require(B.same_bytes(actual, expected), 'Complete own-role output oracle differs: '+name)
            rss.append(process['peakRssBytes'])
        recomputed = B.summary(measured['samples'], ROLES, 'baseline', 2)
        C.require(recomputed == measured['summary'] and recomputed['complete'], 'Recomputed case summary differs')
        samples = {role: [r['process']['seconds'] for r in measured['samples'] if r['role'] == role] for role in ROLES}
        spread = {role: max(samples[role])/min(samples[role]) for role in ROLES}
        for role in ROLES:
            if spread[role] > 1.10:
                warnings.append(stage+'/'+name+'/'+role+' max/min exceeds 1.10; retained')
        ratio = recomputed['ratios']['candidate']
        rows.append(dict(id=name, inputSource=case['source'],
            baselineSeconds=recomputed['stats']['baseline']['medianMs']/1000,
            candidateSeconds=recomputed['stats']['candidate']['medianMs']/1000,
            candidateOverBaseline=ratio, timeChangePercent=100*(ratio-1),
            samplesSeconds=samples, maxOverMin=spread,
            outputOracles={role: {key: case['requests'][role][key] for key in ('stdout', 'stderr')} for role in ROLES}))
    aggregate = B.aggregate(report['cases'], ROLES, 'baseline')
    C.require(aggregate == report['aggregate'] and aggregate['complete'], 'Recomputed aggregate differs')
    ratio = aggregate['roles']['candidate']['geomean']
    return dict(report=receipt, manifest=plan['manifest'], rounds=2, positionBalanced=True,
                observationsRevalidated=16, baselineCompiler=manifest['roles']['baseline']['compiler'],
                candidateCompiler=manifest['roles']['candidate']['compiler'],
                geomeanCandidateOverBaseline=ratio, timeChangePercent=100*(ratio-1),
                peakRssBytesRange=[min(rss), max(rss)], rows=rows, warnings=warnings)


def prepare_binding(screen_value, stage, evidence):
    preparation_pin = C.pin(Path(screen_value['manifest']['file']).with_name('report.json'))
    preparation = evidence.read(preparation_pin)
    A.P.completed(preparation, 'Phase195 compiler cost preparation')
    C.require(preparation['kind'] == 'phase198-compiler-cost-preparation' and preparation['stage'] == stage
              and preparation['manifest'] == screen_value['manifest'], 'Cost preparation/measurement binding differs')
    evidence.verify(preparation['method'])
    A.source_gate(evidence.verify(preparation['sourceAudit']), evidence, preparation['source'])
    generations = {}
    for role in ROLES:
        acquisition_pin = preparation[role+'Acquisition']
        evidence.verify(acquisition_pin)
        acquisition = A.P.load_side(Path(acquisition_pin['file']).with_name('programs.manifest.json'), 'candidate', evidence)
        C.require(acquisition['role']['stage'] == stage
                  and acquisition['producer']['image'] == screen_value[role+'Compiler'],
                  'Measured compiler differs from authenticated product acquisition')
        if role == 'candidate':
            C.require(acquisition['producer']['source'] == preparation['source'], 'Candidate selected source differs')
        else:
            C.require(acquisition['producer']['source'] == C.pin(ROOT/'selfhost/build/phase195/selected-source02/compiler.bend'),
                      'Baseline must be exact Phase195 selected source')
        generations[role] = evidence.read(A.generation_gate(acquisition, evidence))
    if stage == 'N1':
        C.require(all(generations['baseline']['request'][key] == generations['candidate']['request'][key]
                      for key in ('image', 'imageMetadata'))
                  and generations['baseline']['toolchain'] == generations['candidate']['toolchain'],
                  'Common QBE seed/toolchain differs')
    screen_value.update(preparation=preparation_pin, sourceAudit=preparation['sourceAudit'],
                        compilerSources={role: generations[role]['request']['source'] for role in ROLES})


def markdown(result):
    screens = result['screens']
    lines = ['# Phase198 source-to-object compiler cost', '',
             '; '.join(stage+' '+format(screens[stage]['geomeanCandidateOverBaseline'], '.6f')+'× Phase195 time ('
                       +format(screens[stage]['timeChangePercent'], '+.2f')+'%)' for stage in ('N1', 'N2'))+'.', '',
             'All 32 complete outputs and empty-stderr oracles were revalidated; medians and geometric means were recomputed.', '',
             '| Request | N1 baseline s | N1 candidate s | N1 ratio | N2 baseline s | N2 candidate s | N2 ratio |',
             '|---|---:|---:|---:|---:|---:|---:|']
    for a, b in zip(screens['N1']['rows'], screens['N2']['rows']):
        lines.append('| '+a['id']+' | '+' | '.join(format(row[key], '.6f') for row in (a,b)
                     for key in ('baselineSeconds','candidateSeconds','candidateOverBaseline'))+' |')
    lines += ['', SCOPE, '', INTERPRETATION, '']
    if result['warnings']:
        lines += ['Sample spread observations (no exclusions):', '', *['- '+x for x in result['warnings']], '']
    for stage in ('N1', 'N2'):
        lines += [stage+' measured report: `'+screens[stage]['report']['file']+'`.', '']
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--n1', type=Path, required=True)
    parser.add_argument('--n2', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    C.require(args.out.suffix == '.json' and not args.out.exists() and not args.out.with_suffix('.md').exists(),
              'Fresh JSON and Markdown output paths required')
    evidence = A.P.Evidence()
    for method in (__file__, M.__file__, A.__file__, A.P.__file__, B.__file__, C.__file__):
        evidence.verify(C.pin(method))
    screens = {stage: screen(getattr(args, stage.lower()), stage, evidence) for stage in ('N1', 'N2')}
    for stage, value in screens.items():
        prepare_binding(value, stage, evidence)
    C.require(screens['N1']['compilerSources'] == screens['N2']['compilerSources'], 'N1/N2 selected compiler sources differ')
    changed = C.changed_inputs(list(evidence.inputs.values()))
    C.require(not changed, 'Inputs changed during analysis')
    result = dict(kind='phase198-authenticated-compiler-cost-guardrail', version=1, complete=True,
                  targetsRun=False, method=C.pin(__file__), analyzer=C.pin(B.__file__), screens=screens,
                  observationsRevalidated=32, warnings=[x for s in screens.values() for x in s['warnings']],
                  scope=SCOPE, interpretation=INTERPRETATION, inputs=list(evidence.inputs.values()), changedInputs=changed)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    C.write_json(args.out, result)
    args.out.with_suffix('.md').write_text(markdown(result))
    print(json.dumps(dict(out=str(args.out), complete=True,
                         ratios={stage: value['geomeanCandidateOverBaseline'] for stage,value in screens.items()})))


if __name__ == '__main__':
    main()
