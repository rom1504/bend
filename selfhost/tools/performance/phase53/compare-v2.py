#!/usr/bin/env python3
"""Contract-labelled direct-backend comparison using the unchanged timing runner."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
sys.path.insert(0, str(PROGRAMS))


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), bytes=file.stat().st_size,
                sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def main():
    binding_parser = argparse.ArgumentParser(add_help=False, allow_abbrev=False)
    binding_parser.add_argument('--baseline-binding', type=Path, required=True)
    binding_args, runner_args = binding_parser.parse_known_args()
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--catalog', type=Path, required=True)
    parser.add_argument('--out', type=Path)
    parser.add_argument('--plan', action='store_true')
    args, _ = parser.parse_known_args(runner_args)
    assert args.plan or args.out is not None
    if args.out:
        assert not args.out.exists(), 'Fresh comparison output is required'
    inputs = [identity(file) for file in [__file__, PROGRAMS / 'run.py', PROGRAMS / 'execute.mjs',
              PROGRAMS / 'support.py', args.baseline, args.candidate, args.catalog]]
    assert inputs[1]['sha256'] == '825f16ea085b2000595371a0b69bfc7c76b0630ae11079ae02480d7dac746a2e'
    assert inputs[2]['sha256'] == '5a37e3bdcc390cdc9a9745fcfacdcca75fc8a16a5b02405345aa618f770692c5'
    parent = identity(HERE.parent / 'phase52/compare.py')
    assert parent['sha256'] == 'd58e0cdd16cb55005ed0907e3b3176ed271af64a90538d620a79d6c39559986c'
    inputs.append(parent)
    predecessor = identity(HERE / 'compare.py')
    assert predecessor['sha256'] == '7ebe2e6f1a389cf199e0bbf8576c520dd569f6428672a9ad6b52a5d2778b8950'
    inputs.append(predecessor)
    baseline = json.loads(args.baseline.read_text())
    candidate = json.loads(args.candidate.read_text())
    assert baseline['complete'] and candidate['complete']
    assert set(baseline['roles']) == {'baseline', 'typescript'} and set(candidate['roles']) == {'candidate'}
    compiler = baseline['roles']['baseline']['compiler']
    binding_file = binding_args.baseline_binding
    binding = json.loads(binding_file.read_text())
    assert binding['kind'] == 'phase53-baseline-compiler-binding' and binding['complete']
    assert binding['manifest']['sha256'] == identity(args.baseline)['sha256']
    assert binding['compiler'] == compiler
    assert binding['catalogSha256'] == identity(args.catalog)['sha256']
    assert compiler['backend'] == 'direct' and compiler['callingContract'] == 'upstream-compatible-direct-v1'
    assert baseline['comparisonContract'] == compiler['callingContract']
    provenance = args.baseline.parent / baseline['provenance']['path']
    assert identity(provenance)['sha256'] == baseline['provenance']['sha256']
    inputs.extend([identity(binding_file), identity(provenance)])
    direct = candidate['roles']['candidate']['compiler']
    assert direct['backend'] == 'direct'
    assert direct['callingContract'] == candidate['comparisonContract'] == 'upstream-compatible-direct-v1'
    assert direct['kind'] in ['checked-development-attempt', 'installed-checked-release']
    contract = dict(kind='phase53-direct-js-execution-comparison', complete=False, passed=False,
        callingContract='upstream-compatible-direct-v1', inputs=inputs,
        scope='Same retained Bend sources, points, exact result oracles and unchanged timing protocol. Both Bend roles use the same upstream-compatible default callable/record contract; legacy G/descriptor mutation compatibility is not claimed. Compilation is excluded; saved historical timings are not denominators.',
        baselineBinding=binding,
        roles={'baseline': binding['label'],
               'candidate': 'Checked direct JavaScript backend, upstream-compatible default exports',
               'typescript': 'Pinned upstream checked JavaScript outputs'},
        outputObservation='All scalar outputs checked on every invocation. Generic row observes all four arrays using each backend public layout; observer work remains timed.')
    if args.plan:
        print(json.dumps(contract, indent=2))
    spec = importlib.util.spec_from_file_location('phase53_unchanged_program_runner', PROGRAMS / 'run.py')
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    code = runner.main(runner_args)
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
    with (args.out / 'phase53-comparison.json').open('x') as stream:
        json.dump(contract, stream, indent=2)
        stream.write('\n')
    return code


if __name__ == '__main__':
    raise SystemExit(main())
