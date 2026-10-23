"""Preserve measured proxy results and selected QBE/machine shape; no target execution."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SPEC = importlib.util.spec_from_file_location('p131_inspect', HERE.parent / 'projection/inspect.py')
I = importlib.util.module_from_spec(SPEC); SPEC.loader.exec_module(I)


def read(path):
    return json.loads(path.read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args(); out = args.out.resolve()
    assert not out.exists(); out.mkdir(parents=True)
    timing_path = ROOT / 'selfhost/build/phase131/regions-late02-run/timing/report.json'
    timing = read(timing_path); assert timing['passed'] and timing['complete']
    inputs = [I.pin(__file__), I.pin(SPEC.origin), I.pin(timing_path)]
    rows = []
    for case in ('compiler-tag', 'record-transfer', 'compiler-uses'):
        result = dict(case=case, variants={})
        for role in ('baseline', 'candidate'):
            if case == 'compiler-uses':
                emit_stem = f'p131-regions-uses01-{role}'
                build_stem = emit_stem + '-build'
                names = ['$direct.p98_tag_eq', '$p118borrow.read.p98_tag_eq', '$direct.nq_uses']
            else:
                emit_stem = 'p131-regions-jobs02-baseline-emit' if role == 'baseline' else 'p131-regions-late02'
                build_stem = f'p131-regions-jobs02-baseline-{case}-build' if role == 'baseline' else f'p131-regions-late02-run-{case}-build'
                names = ['$direct.p131_once', '$direct.p131_repeat',
                         '$p118borrow.read.p98_tag_eq' if case == 'compiler-tag' else '$p118borrow.read.p131_packet_query']
            emit_path = ROOT / 'selfhost/build/phase118' / emit_stem / 'report.json'
            build_path = ROOT / 'selfhost/build/phase111' / build_stem / 'report.json'
            emission, build = read(emit_path), read(build_path)
            assert emission['complete'] and build['complete'] and build['outputExact']
            row = next(x for x in emission['cases'] if x['name'] == case)
            assert row['verified'] and row['parentVerified']
            for item in [row['qbe'], build['binary']]: assert I.pin(item['file']) == item
            inputs += [I.pin(emit_path), I.pin(build_path), row['qbe'], build['binary']]
            funcs = I.functions(row['qbe']['file']); selected = {}
            for name, body in funcs.items():
                if any(name == prefix + suffix for suffix in names for prefix in ('p113d_FID_', 'p111_FID_')):
                    info = I.info(body); symbol = I.FUNCTION.match(body.splitlines()[0])[1]
                    machine = subprocess.check_output(['objdump', '-d', '--no-show-raw-insn', '--disassemble=' + symbol, build['binary']['file']], text=True)
                    info['machineInstructions'] = sum(bool(re.match(r'^\s*[0-9a-f]+:\s+\S', line)) for line in machine.splitlines())
                    stem = case + '-' + role + '-' + re.sub('[^a-zA-Z0-9_-]', '-', name)
                    (out / (stem + '.ssa')).write_text(body)
                    (out / (stem + '.asm')).write_text(machine)
                    info['retainedQbe'] = I.pin(out / (stem + '.ssa'))
                    info['retainedMachine'] = I.pin(out / (stem + '.asm'))
                    selected[name] = info
            result['variants'][role] = dict(qbeBytes=row['qbe']['bytes'], binaryBytes=build['binary']['bytes'],
                stageSeconds=row['stages'], functions=selected)
        if case in timing['summary']:
            summary = timing['summary'][case]
            a = summary['baseline']['clean']['wallSeconds']['median']
            b = summary['candidate']['clean']['wallSeconds']['median']
            result['cleanTiming'] = dict(baselineWallMedian=a, candidateWallMedian=b, ratio=b/a,
                reduction=1-b/a, cleanRounds=3, source='source07', repetitions=1000000)
        rows.append(result)
    report = dict(complete=True, inputs=inputs, rows=rows,
        scope='Only host disassembly/static analysis here. Existing independent ordinary native oracles and parent CPU3 clean timings reused. Static calls include mutually exclusive branches, not dynamic counts. Source07 duplicates preparation; source03 exact nq_uses timing is separately measured. Diagnostic hosted stage times are single observations and not a controlled compiler cost comparison.')
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, report=str(out / 'report.json'))))


if __name__ == '__main__': main()
