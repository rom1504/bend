#!/usr/bin/env python3
"""Replay the compiler law foundation; fast positives or audit with negatives/C."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import time

sys.dont_write_bytecode = True
from production import pin

ROOT = Path(__file__).resolve().parents[4]
METHODS = Path(__file__).resolve().parent
PROOFS = ROOT / 'selfhost/proofs/phase96'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True, help='Fresh directory in selfhost/build/phase96')
    parser.add_argument('--tier', choices=['fast', 'audit'], default='fast')
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase96')
    out.mkdir(parents=True, exist_ok=False)
    inputs = [pin(file) for root in [METHODS, PROOFS] for file in sorted(root.rglob('*'))
              if file.is_file() and file.suffix in ['.py', '.mjs', '.bend', '.json'] and 'attempts' not in file.parts]
    report = dict(complete=False, tier=args.tier, started=time.time(), inputs=inputs, steps=[])
    def save(): (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    def call(name, script, *arguments):
        command = [sys.executable, '-B', str(script), *map(str, arguments)]
        started = time.monotonic(); proc = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        (out / (name + '.stdout')).write_text(proc.stdout)
        (out / (name + '.stderr')).write_text(proc.stderr)
        row = dict(name=name, command=command, returncode=proc.returncode, wallSeconds=time.monotonic()-started)
        report['steps'].append(row); save(); print(json.dumps(row), flush=True)
        assert proc.returncode == 0, (name, proc.stderr[-2000:])
    try:
        call('algebra', METHODS/'check.py', '--source', PROOFS/'algebra/all.bend', '--out', out/'algebra')
        call('representation-prepare', PROOFS/'representation/prepare.py', '--out', out/'representation-source')
        call('representation', METHODS/'check.py', '--source', out/'representation-source/laws.bend', '--out', out/'representation')
        call('production-prepare', PROOFS/'production/prepare.py', '--out', out/'production-source')
        manifest = out/'production-source/manifest.json'
        call('production', METHODS/'production.py', '--manifest', manifest, '--out', out/'production')
        proof_reports = [json.loads((out/name/'report.json').read_text()) for name in ['algebra', 'representation']]
        assert all(r['complete'] and r['independentlyChecked'] for r in proof_reports)
        assert [len(r['lawNames']) for r in proof_reports] == [21, 17]
        report.update(publicLaws=31, supportingLemmas=7, finiteCases=226, finiteFamilies=16)
        assert len(json.loads(manifest.read_text())['cases']) == report['finiteCases']
        if args.tier == 'audit':
            call('algebra-negatives-prepare', PROOFS/'algebra/prepare-negatives.py',
                 '--proof-report', out/'algebra/report.json', '--out', out/'algebra-negative-source')
            call('algebra-negatives', METHODS/'proof-negatives.py',
                 '--plan', out/'algebra-negative-source/plan.json', '--out', out/'algebra-negatives')
            call('representation-negatives-prepare', PROOFS/'representation/mutations.py',
                 '--positive', out/'representation-source', '--out', out/'representation-negative-source')
            call('representation-negatives', METHODS/'proof-negatives.py',
                 '--plan', out/'representation-negative-source/manifest.json', '--out', out/'representation-negatives')
            recipes = json.loads((PROOFS/'production/mutations.json').read_text())
            for recipe in recipes:
                name = 'mutation-' + recipe['id']
                call(name+'-prepare', PROOFS/'production/prepare.py', '--mutant', recipe['id'], '--out', out/(name+'-source'))
                call(name, METHODS/'production.py', '--manifest', out/(name+'-source')/'manifest.json',
                     '--out', out/name, '--expect-mutation')
            call('production-native', METHODS/'production.py', '--manifest', manifest,
                 '--out', out/'production-native', '--native')
            report.update(proofRejectionControls=16, executableMutants=len(recipes), nativeCases=32)
        for item in inputs: assert pin(item['file']) == item, ('Method changed while running', item['file'])
        report.update(complete=True, inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error); raise
    finally:
        report['finished'] = time.time(); report['wallSeconds'] = report['finished'] - report['started']; save()
    print(json.dumps({key: report[key] for key in ['complete', 'tier', 'publicLaws', 'finiteCases', 'wallSeconds']}))


if __name__ == '__main__': main()
