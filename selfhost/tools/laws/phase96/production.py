#!/usr/bin/env python3
"""Execute frozen production contracts serially, optionally through native C."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
GUARD = ROOT / 'selfhost/tools/performance/phase86/guard.py'
CLANG = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')


def pin(file):
    file = Path(file).resolve(); digest = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''): digest.update(block)
    return dict(file=str(file), bytes=file.stat().st_size, sha256=digest.hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--native', action='store_true')
    parser.add_argument('--expect-mutation', action='store_true')
    args = parser.parse_args(); manifest = args.manifest.resolve(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase96')
    assert not (args.native and args.expect_mutation), 'Native mutation controls are not implemented'
    out.mkdir(parents=True, exist_ok=False)
    data = json.loads(manifest.read_text())
    node = Path(shutil.which('node')).resolve()
    report = dict(complete=False, manifest=pin(manifest), method=pin(__file__), node=pin(node),
                  guard=pin(GUARD), native=args.native, mutationControl=args.expect_mutation, rows={})
    def save(): (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    def run(name, argv, expected=0, seconds=120):
        destination = out / (name + '-guard')
        command = [sys.executable, '-B', str(GUARD), '--out', str(destination),
                   '--seconds', str(seconds), '--rss-mib', '2048', '--available-mib', '4096',
                   '--cpu', '3', '--', *map(str, argv)]
        process = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        (out / (name + '-wrapper.stdout')).write_text(process.stdout)
        (out / (name + '-wrapper.stderr')).write_text(process.stderr)
        receipt = json.loads((destination / 'process.json').read_text())
        report['rows'][name] = dict(receipt=pin(destination / 'process.json'), process=receipt)
        save()
        assert receipt['returncode'] == expected and not receipt.get('stoppedFor'), name
        assert process.returncode == expected, name
        return destination
    try:
        assert bool(data['mutation']) == args.expect_mutation, 'Explicit mutation classification required'
        mode = 'emit-native' if args.native else 'js'
        worker = manifest.parent / 'methods/run.mjs'; report['worker'] = pin(worker)
        run('compile', [node, '--stack-size=4096', '--max-old-space-size=1024', worker,
                        manifest, out / 'execution', mode], expected=int(args.expect_mutation))
        result_file = out / 'execution/report.json'; result = json.loads(result_file.read_text())
        report['execution'] = pin(result_file)
        assert result['complete'] and result['inputsUnchanged']
        assert result['compile']['status'] == 'ok', 'Compilation failure is not a mutation kill'
        if args.expect_mutation:
            witness = data['mutation']['case']
            rows = {row['id']: row for row in result['rows']}
            assert witness in rows and not rows[witness]['passed'] and not result['passed']
            assert 'actual' in rows[witness] and 'expected' in rows[witness]
            assert rows[witness]['actual'] != rows[witness]['expected'], 'Require a semantic mismatch'
            report['rejectedWitness'] = witness
        elif args.native:
            assert result['passed'] and not result['nativeExecutionPerformed']
            include = CLANG.parent.parent / 'include/clang'
            report['clang'] = pin(CLANG)
            product = out / 'execution/laws.c'; binary = out / 'laws'
            run('clang', [CLANG, '-isystem', include, '-std=c11', '-O3', product,
                          '-o', binary, '-lm', '-pthread'])
            report['binary'] = pin(binary)
            folder = run('native', [binary], seconds=30)
            expected = manifest.parent / 'native.expected.txt'
            actual = folder / 'stdout.log'
            report.update(expected=pin(expected), actual=pin(actual), cases=len(data['nativeCaseIds']))
            assert actual.read_bytes() == expected.read_bytes(), 'Native full-output mismatch'
            assert not (folder / 'stderr.log').read_bytes()
            assert pin(CLANG) == report['clang']
        else:
            assert result['passed'] and len(result['rows']) == len(data['cases'])
            report['cases'] = len(result['rows'])
        for key in ['manifest', 'method', 'node', 'guard', 'worker']:
            assert pin(report[key]['file']) == report[key]
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: save()
    print(json.dumps({key: report[key] for key in ['complete', 'native', 'mutationControl']}))


if __name__ == '__main__': main()
