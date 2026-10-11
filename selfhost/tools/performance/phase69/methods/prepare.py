#!/usr/bin/env python3
"""Materialize exact, recorded Phase69 successors of existing methods; no targets."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
TOOLS = ROOT / 'selfhost/tools/performance'
RAW = ROOT / 'selfhost/build/phase69'


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write(path, value):
    with path.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', required=True, type=Path)
    args = p.parse_args()
    assert os.sched_getaffinity(0) == {0}, 'Data preparation belongs on CPU0'
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    out.mkdir(parents=True)
    rows = []

    def derive(name, parent, edits):
        parent = TOOLS / parent
        text = parent.read_text()
        changes = []
        for old, new, count in edits:
            assert text.count(old) == count, (parent, old, text.count(old), count)
            text = text.replace(old, new)
            changes.append(dict(before=old, after=new, count=count))
        ast.parse(text, filename=name)
        path = out / name
        write(path, text)
        rows.append(dict(name=name, parent=pin(parent), output=pin(path), edits=changes))

    fixed_root = 'ROOT = Path(' + repr(str(ROOT)) + ')'
    root5 = ('ROOT = Path(__file__).resolve().parents[5]', fixed_root, 1)
    phase = ('selfhost/build/phase68', 'selfhost/build/phase69', 1)
    # Keep original fixture/method locations. Only writable output boundaries move.
    derive('prepare-integration.py', 'phase68/controls/integration-v3/prepare.py', [
        ('ROOT = Path(__file__).resolve().parents[6]', fixed_root, 1),
        ('HERE = Path(__file__).resolve().parent',
         "HERE = ROOT / 'selfhost/tools/performance/phase68/controls/integration-v3'", 1), phase])
    derive('prepare-raw.py', 'phase68/controls/prepare-raw-v5.py', [root5, phase])
    derive('prepare-threads.py', 'phase68/controls/prepare-threads.py', [root5,
        ('selfhost/build/phase68', 'selfhost/build/phase69', 2)])
    derive('compare-native.py', 'phase68/facts-calls/compare-native.py', [
        ('ROOT=Path(__file__).resolve().parents[5]', 'ROOT=Path(' + repr(str(ROOT)) + ')', 1),
        ('baseline20', 'baseline23', 8),
        ("['native-scalar20','native-scalar20-rest']", "['native-facts23-lexer','native-facts23-rest']", 1),
        ("out.is_relative_to(ROOT/'selfhost/build/phase68')", "out.is_relative_to(ROOT/'selfhost/build/phase69')", 1),
        ('Compare saved compiler20/candidate/upstream', 'Compare saved compiler23/candidate/upstream', 1)])
    derive('verify-js.py', 'phase68/facts-calls/verify-js.py', [
        ('root = Path(__file__).resolve().parents[5]', 'root = Path(' + repr(str(ROOT)) + ')', 1),
        ("assert changed == ['$kf_known$'], changed", 'assert changed == [], changed', 1),
        ('unchangedFunctions=len(left)-1', 'unchangedFunctions=len(left)', 2),
        ('All exported non-native roots. Only the foreign-ID resolver changes; its behavior needs separate controls.',
         'Exact generated closure of all exported roots not starting nc_, runtime and public wrappers; no changed function permitted.', 1)])
    derive('prepare-compilation.py', 'phase68/compilation/prepare-selected-v2.py', [
        ('HERE = Path(__file__).resolve().parent',
         "HERE = Path(" + repr(str(TOOLS / 'phase68/compilation')) + ')', 1),
        ('ROOT = HERE.parents[4]', fixed_root, 1), phase])
    # This consumed producer already admits the Phase66 source/API contract and
    # Phase68 export set through an explicit admission file. Preserve all of it.
    bootstrap = ROOT / 'selfhost/build/phase68/qualification-method17/bootstrap/prepare-bootstrap.py'
    derive('prepare-bootstrap.py', bootstrap, [phase])
    config = dict(project=str(ROOT/'selfhost'), upstream=str(ROOT/'selfhost/.bootstrap/upstream-phase66'),
                  profile='equality', strictExact=True, jobs=1, cpu='3', heapMb=1024)
    write(out/'development.json', config)
    dependencies = [TOOLS / name for name in [
        'phase67/benchmark/freeze.py', 'phase67/benchmark/run.py',
        'phase68/compilation/run.py', 'phase68/compilation/worker.mjs',
        'phase68/compilation/analyze.py', 'phase32/bounded-run.py',
        'phase68/controls/raw-controls-v7.mjs']]
    dependencies += [ROOT/'selfhost/tools/development/workflow.mjs',
                     ROOT/'selfhost/build/phase68/scalar-export-admission20.json']
    result = dict(kind='phase69-method-derivations', dataOnly=True, targetsExecuted=False,
                  producer=pin(__file__), methods=rows, development=pin(out/'development.json'),
                  dependencies=[pin(x) for x in dependencies],
                  scope='Output-boundary relocations; runtime comparator baseline advances to actual compiler23; JS closure requires zero changes. Historical methods and raw remain unchanged. Preparation is not validation.')
    write(out/'methods.json', result)
    print(json.dumps(dict(methods=pin(out/'methods.json'), targetExecuted=False, derivatives=len(rows))))


if __name__ == '__main__':
    main()
