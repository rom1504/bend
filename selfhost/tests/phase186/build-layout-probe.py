#!/usr/bin/env python3
"""Root-only guarded assembler/link/oracle execution for a frozen layout plan.

No Bend or QBE compiler executes. The plan copies exact parent commands and
changes only declared machine-assembly/object/output paths.
"""
import argparse
import json
import os
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path[:0] = [str(ROOT / 'selfhost/tools/bench'), str(ROOT / 'selfhost/tools/build')]
import bench as B
import common as C


def validate(plan):
    C.require(plan.get('kind') == 'phase186-layout-falsifier-plan' and plan.get('targetsRun') is False,
              'Frozen diagnostic layout plan required')
    catalog = {c['id']: c for c in B.catalog(ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json')['cases']}
    inputs = list(plan['inputs'])
    for case in plan['cases']:
        parent = B.read(C.verify(case['parentBuild']))
        C.require(parent['complete'] and parent['target'] == 'qbe' and not parent['changedInputs']
                  and parent['assembly'] == case['parentAssembly'] and parent['binary'] == case['parentBinary'],
                  'Exact completed parent QBE build required')
        original = C.verify(case['parentAssembly']).read_bytes()
        C.require(C.verify(case['originalCopy']).read_bytes() == original, 'Original assembly copy changed')
        commands = {j['label']: j['command'] for j in parent['jobs']}
        for variant in case['variants']:
            count = variant['alignmentExponent']
            C.require(count in (4, 5, 6) and variant['insertedText'] == '.p2align ' + str(count) + '\n',
                      'Only explicit alignment directives permitted')
            offset = variant['insertOffset']
            marker = (case['loopLabel'] + ':\n').encode()
            start = original.index((case['hotSymbol'] + ':\n').encode())
            end = original.index(('\n.size ' + case['hotSymbol'] + ',').encode(), start)
            C.require(start < offset < end and original[offset:].startswith(marker)
                      and original.count(marker) == 1, 'Insertion does not bind the selected hot loop')
            changed = C.verify(variant['assembly']).read_bytes()
            C.require(changed == original[:offset] + variant['insertedText'].encode() + original[offset:],
                      'Machine assembly contains an undeclared edit')
            directory = Path(plan['buildRoot']) / case['id'] / variant['role']
            C.require(variant['buildDirectory'] == str(directory), 'Build path differs from plan root')
            obj, binary = str(directory / 'program.o'), str(directory / 'program')
            replacements = {parent['assembly']['file']: variant['assembly']['file'],
                            parent['object']['file']: obj, parent['binary']['file']: binary}
            for stage in ('assemble', 'link'):
                C.require(variant[stage] == [replacements.get(word, word) for word in commands[stage]],
                          'Assembler/link command differs from exact parent flags/runtime')
            point = dict(catalog[case['id']]['point'], repetitions=1, warmups=0)
            C.require(variant['point'] == point, 'Oracle differs from frozen catalog')
            rts = B.native_runtime_arguments(dict(runtimeArgumentConvention='bend-rts-v1'))
            C.require(variant['oracle'] == [binary, *rts, '1', '0', *map(str, point['runtimeArgs'])],
                      'Oracle command differs from exact input/count protocol')
            inputs += [variant['assembly']]
        inputs += [case['parentBuild'], case['parentAssembly'], case['originalCopy'], case['parentBinary']]
    inputs = B.unique_inputs(inputs)
    for item in inputs:
        C.verify(item)
    return inputs


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--seconds', type=float, default=60)
    p.add_argument('--guarded', action='store_true')
    a = p.parse_args()
    started = time.monotonic()
    C.require(a.guarded and os.sched_getaffinity(0) == {3}, 'One outer guarded CPU3 lane required')
    C.require(0 < a.seconds <= 80, 'Bounded inner deadline of at most80 seconds required')
    C.clean_environment()
    C.require('BENDRTS' not in os.environ, 'Ambient BENDRTS must be unset')
    plan = B.read(a.plan)
    C.require(str(a.out.resolve()) == plan['buildRoot'], 'Fresh output must equal frozen build root')
    inputs = B.unique_inputs([C.pin(a.plan), C.pin(__file__), C.pin(B.__file__), C.pin(C.__file__), *validate(plan)])
    out = C.fresh_output(a.out, ROOT)
    report = dict(kind='phase186-layout-probe-build', complete=False, inputs=inputs, rows=[],
        scope=plan['scope'], secondsLimit=a.seconds, cpu=3, compilerExecuted=False)
    recipe = plan['recipe']

    def save():
        report['wallSeconds'] = time.monotonic() - started
        C.write_json(out / 'report.json', report)

    save()
    try:
        for case, selected in zip(plan['cases'], recipe['cases']):
            for variant in case['variants']:
                directory = Path(variant['buildDirectory'])
                directory.mkdir(parents=True)
                row = dict(id=case['id'], role=variant['role'], complete=False, jobs=[])
                report['rows'].append(row)
                for stage in ('assemble', 'link', 'oracle'):
                    left = a.seconds - (time.monotonic() - started)
                    C.require(left > 0, 'Whole layout diagnostic deadline exhausted')
                    job = C.run(variant[stage], cwd=ROOT, stdout=directory / (stage + '.stdout'),
                                stderr=directory / (stage + '.stderr'), seconds=left)
                    row['jobs'].append(dict(stage=stage, process=job))
                    C.write_json(directory / (stage + '-process.json'), job)
                    save()
                    C.require(job['complete'], 'Layout diagnostic stage failed: ' + stage)
                    if stage == 'oracle':
                        B.observation(C.verify(job['stdout']).read_bytes(), C.verify(job['stderr']).read_bytes(),
                                      job['exitCode'], variant['point'], job['seconds'])
                row.update(complete=True, artifact=C.pin(directory / 'program'))
                if variant['alignmentExponent'] == 4:
                    row['redundantAlignmentBinaryIdenticalToParent'] = C.same_bytes(directory / 'program', case['parentBinary']['file'])
                selected['products'][variant['role']]['inputs'] += [C.pin(a.plan), C.pin(__file__),
                    *[C.pin(directory / (stage + '-process.json')) for stage in ('assemble', 'link', 'oracle')],
                    job['stdout'], job['stderr']]
                save()
        C.require(not C.changed_inputs(inputs), 'Layout plan inputs changed')
        C.write_json(out / 'programs.recipe.json', recipe)
        B.freeze(out / 'programs.recipe.json', out / 'programs.manifest.json')
        report.update(complete=True, programManifest=C.pin(out / 'programs.manifest.json'))
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = C.changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        save()
    print(json.dumps({key: report.get(key) for key in ('complete', 'programManifest', 'error')}))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
