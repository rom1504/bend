#!/usr/bin/env python3
"""Authenticate Phase118 generation lineage and compare raw QBE; no execution."""
import argparse
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT_PARENT_COMPARISON = HERE.parents[4] / 'selfhost/tools/performance/phase125/native/comparison.py'
spec = importlib.util.spec_from_file_location('p118_native_plan', HERE / 'plan-v2.py')
tool = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tool)
pin, verify, read, require = tool.pin, tool.verify, tool.read, tool.require


def same_bytes(left, right):
    with Path(left).open('rb') as a, Path(right).open('rb') as b:
        while True:
            x, y = a.read(1024 * 1024), b.read(1024 * 1024)
            if x != y:
                return False
            if not x:
                return True


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists(), 'Fresh comparison receipt required')
    plan = tool.verify_plan(a.plan)
    paths = {name: Path(plan['artifacts'][name]) / 'report.json' for name in ['hosted', 'n1', 'self']}
    paths['n2'] = Path(plan['artifacts']['self']) / 'build/report.json'
    inputs = [pin(__file__), pin(a.plan), *plan['inputs']]
    result = dict(kind='phase125-integrated-native-qbe-reproduction', complete=False, targetsRun=False,
                  byteExact=False, inputs=inputs,
                  stagedAdapter=dict(parent=pin(ROOT_PARENT_COMPARISON), independentlyBuiltN2=True),
                  scope='Raw hosted/N1-self QBE without normalization; actual N1/N2 source/runtime lineage. Ordinary semantic suites, runtime speed, ELF identity and N2 self-emission are separate.')
    try:
        reports = {name: read(path) for name, path in paths.items()}
        inputs.extend(pin(path) for path in paths.values())
        require(all(row.get('complete') for row in reports.values()), 'Complete hosted/native/build receipts required')
        h, n1, native, n2 = [reports[k] for k in ['hosted', 'n1', 'self', 'n2']]
        checkpoint_path = Path(plan['storageCheckpoints']['beforeN2'])
        checkpoint = read(checkpoint_path)
        require(checkpoint.get('complete') and checkpoint.get('byteExact') and
                pin(a.plan) in checkpoint['inputs'] and checkpoint['nativeReport'] == pin(paths['self']) and
                checkpoint['hostedReport'] == pin(paths['hosted']) and checkpoint['nativeProduct'] == native['product'],
                'Exact prebuild reproduction/storage receipt missing')
        inputs.extend([pin(checkpoint_path), *checkpoint['inputs']])
        require(h.get('kind') == 'phase118-integrated-checked-source-qbe-emission' and
                h.get('transportVersion') == 118 and h.get('entry') == 'p111_emit_admitted' and
                h.get('pipeline') == 'array' and h.get('explicitVerificationPasses') == 1,
                'Phase118 integrated hosted contract mismatch')
        require(h.get('requiredExports') == tool.REQUIRED[:-1], 'Hosted export contract mismatch')
        require(all(h.get(k) for k in ['sourceChecked', 'runtimeAdmitted', 'irVerified']), 'Hosted gate incomplete')
        stages = ['api-import', 'input-read', 'preparation', 'frontend', 'frontend-counts', 'runtime-admission', 'integrated-compiler', 'write', 'output-authentication']
        require([r['name'] for r in h['stages']] == stages and all(r['status'] == 'complete' for r in h['stages']), 'Integrated stages incomplete/changed')
        require(plan['api'] in h['inputs'] and plan['apiReport'] in h['inputs'], 'Hosted API identity mismatch')
        require(native.get('kind') == 'phase125-aligned-native-source-qbe-emission' and native['gates']['emission'] == 'passed' and native['gates']['build'] == 'not-requested', 'Native request gates incomplete')
        require(h['product'] in n1['inputs'] and native['image'] == n1['binary'] and
                native.get('imageReceipt') == pin(paths['n1']) and native['product'] in n2['inputs'] and
                Path(native['product']['file']).resolve() == Path(n2['jobs'][0]['command'][-1]).resolve() and
                all(plan['runtime'] in b['inputs'] for b in [n1, n2]), 'Broken actual product/image/runtime lineage')
        require(h.get('mode') == native.get('mode') == 'cache' and all(plan['source'] in r['inputs'] for r in [h, native]), 'Source/mode mismatch')
        for expected in [plan['assets']['base'], plan['assets']['cache']['carrier'], plan['assets']['selection'], plan['assets']['admission']]:
            require(all(expected in r['inputs'] for r in [h, native]), 'Base/cache/selection mismatch')
        for key, image in [('n1', n1), ('n2', n2)]:
            require(image.get('kind') == 'phase123-branch-aligned-qbe-build' and image.get('cachedRuntime') and
                    image.get('perProgramC') is False and image.get('cproc') is False, 'Build contract mismatch')
            require([r['label'] for r in image['jobs']] == ['qbe', 'assemble', 'link'] and
                    all(r['exitCode'] == 0 for r in image['jobs']), 'Machine build stages incomplete')
            require(image['jobs'][1]['command'][1:2] == ['-mbranches-within-32B-boundaries'], 'Assembler policy mismatch')
            method = plan['machineBuild']['method']
            require(any(r['bytes'] == method['bytes'] and r['sha256'] == method['sha256'] for r in image['inputs']), 'Aligned build method mismatch')
        native_request = [r for r in native['jobs'] if r['label'] == 'native-request']
        require(len(native_request) == 1 and native_request[0]['status'] == 'complete' and
                native_request[0]['stdout'] == native['product'] and native_request[0]['stderr']['bytes'] == 0,
                'Native raw-stdout request binding mismatch')
        for report in reports.values():
            inputs.extend(report['inputs'])
            for job in report.get('jobs', []):
                inputs.extend(job[k] for k in ['stdout', 'stderr'] if k in job)
        products = [h['product'], native['product'], n1['binary'], n2['binary'], n1['object'], n2['object']]
        inputs.extend(products)
        for row in tool.unique(inputs):
            verify(row)
        exact = same_bytes(h['product']['file'], native['product']['file'])
        result.update(complete=exact, byteExact=exact, hostedQbe=h['product'], nativeQbe=native['product'],
                      n1=n1['binary'], n2=n2['binary'], nativeStages=native['jobs'], hostedStages=h['stages'])
        require(exact, 'Hosted/native full-source raw QBE differs')
    except Exception as error:
        result['error'] = str(error)
        raise
    finally:
        result['inputs'] = tool.unique(inputs)
        a.out.parent.mkdir(parents=True, exist_ok=True)
        with a.out.open('x') as f:
            json.dump(result, f, indent=2)
            f.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, report=pin(a.out))))


if __name__ == '__main__':
    main()
