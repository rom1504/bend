#!/usr/bin/env python3
"""Contract-labelled direct05 versus intrinsic successor comparison using the unchanged timing runner."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), bytes=file.stat().st_size,
                sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--catalog', type=Path, required=True)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--plan', action='store_true')
    parser.add_argument('--cases', required=True)
    parser.add_argument('--budget', type=int, required=True)
    args, _ = parser.parse_known_args()
    assert args.plan or args.out is not None
    if args.out:
        assert not args.out.exists(), 'Fresh comparison output is required'
    profile_file = HERE / 'intrinsic-profile-v1.json'
    profile = json.loads(profile_file.read_text())
    assert identity(profile_file)['sha256'] == '11e41bca09263752a3bec9500d0cc8e99731bd614398d3631a8206cdf9f637d9'
    assert args.cases.split(',') == [c['id'] for c in profile['cases']] and args.budget == 60
    assert identity(args.catalog)['sha256'] == profile['catalog']['sha256']
    inputs = [identity(file) for file in [__file__, PROGRAMS / 'run.py', PROGRAMS / 'execute.mjs',
              PROGRAMS / 'support.py', args.baseline, args.candidate, args.catalog]]
    inputs.extend([identity(profile_file), identity(HERE / 'compare.py')])
    assert inputs[-1]['sha256'] == 'd58e0cdd16cb55005ed0907e3b3176ed271af64a90538d620a79d6c39559986c'
    assert inputs[1]['sha256'] == '825f16ea085b2000595371a0b69bfc7c76b0630ae11079ae02480d7dac746a2e'
    assert inputs[2]['sha256'] == '5a37e3bdcc390cdc9a9745fcfacdcca75fc8a16a5b02405345aa618f770692c5'
    baseline = json.loads(args.baseline.read_text())
    candidate = json.loads(args.candidate.read_text())
    assert baseline['complete'] and candidate['complete']
    assert set(baseline['roles']) == {'baseline', 'typescript'} and set(candidate['roles']) == {'candidate'}
    compiler = baseline['roles']['baseline']['compiler']
    assert compiler['api']['sha256'] == 'ab23e1f04f13112fe38e5fd7a74893c5056e926e18d6ab8fc79d26680fa8d2b5'
    assert compiler['backend'] == 'direct' and compiler['callingContract'] == 'upstream-compatible-direct-v1'
    assert baseline['comparisonContract'] == compiler['callingContract']
    assert compiler['directRuntime']['sha256'] == '417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a'
    assert compiler['runtime']['sha256'] == '3158f543b3fb67d2319a83e18485c116708bc8f17998e602f29ee95e83c05e46'
    direct = candidate['roles']['candidate']['compiler']
    assert direct['backend'] == 'direct'
    assert direct['directRuntime']['sha256'] == compiler['directRuntime']['sha256']
    remap = baseline['roleRemap']
    assert identity(remap['path'])['sha256'] == remap['sha256']
    inputs.append(identity(remap['path']))
    assert direct['callingContract'] == candidate['comparisonContract'] == 'upstream-compatible-direct-v1'
    assert direct['kind'] in ['checked-development-attempt', 'installed-checked-release']
    contract = dict(kind='phase52-direct-atomic-intrinsic-comparison', complete=False, passed=False,
        callingContract='upstream-compatible-direct-v1', inputs=inputs,
        scope='Precommitted eight-source intrinsic screen: same Bend sources, points, exact result oracles and unchanged timing protocol. Baseline means direct05, not Phase51. Candidate and direct05 use the same upstream-compatible default callable/record contract; legacy G/descriptor mutation compatibility is not claimed. Compilation is excluded; saved historical timings are not denominators.',
        roles={'baseline': 'Phase52 checked direct05 predecessor, exact saved outputs explicitly relabeled baseline',
               'candidate': 'Checked atomic-intrinsic successor, same direct callable contract',
               'typescript': 'Pinned upstream checked JavaScript outputs'},
        outputObservation='All scalar outputs checked on every invocation. Generic row observes all four arrays using each backend public layout; observer work remains timed.')
    if args.plan:
        print(json.dumps(contract, indent=2))
    spec = importlib.util.spec_from_file_location('phase52_unchanged_program_runner', PROGRAMS / 'run.py')
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    code = runner.main(sys.argv[1:])
    if args.plan:
        return code
    receipt = args.out / 'report.json'
    if receipt.exists():
        result = json.loads(receipt.read_text())
        contract.update(methodReport=identity(receipt), complete=result['complete'],
                        passed=result['pass'] and code == 0, selectedCases=result['selectedCases'],
                        measuredCases=result['measuredCases'], status=result['status'])
    for item in inputs:
        assert identity(item['file']) == item, item['file']
    contract['inputsUnchanged'] = True
    with (args.out / 'phase52-comparison.json').open('x') as stream:
        json.dump(contract, stream, indent=2)
        stream.write('\n')
    return code


if __name__ == '__main__':
    raise SystemExit(main())
