"""Build/run the tiny reader hypothesis probe under the shared CPU5 guard.

No performance conclusion is drawn here. The independent index-version oracle
checks output; instrumented runs count actual reader entries/loop steps/aliases.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[5]
spec = importlib.util.spec_from_file_location('probe', Path(__file__).with_name('reader-identity-probe.py'))
probe = importlib.util.module_from_spec(spec); spec.loader.exec_module(probe)
pin = probe.pin
spec = importlib.util.spec_from_file_location('oracle', Path(__file__).with_name('timing-oracle.py'))
oracle = importlib.util.module_from_spec(spec); spec.loader.exec_module(oracle)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--probe', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--build-prefix', required=True)
    a = p.parse_args()
    assert sorted(os.sched_getaffinity(0)) == [5]
    out = a.out.resolve(); assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase131')
    assert a.build_prefix.isascii() and a.build_prefix.startswith('p131-') and all(c.isalnum() or c == '-' for c in a.build_prefix)
    config = json.loads(a.probe.read_text())
    assert config['complete'] and config['exactN2ReaderMatch'] and not config['productionChange']
    inputs = [pin(Path(__file__)), pin(a.probe), pin(Path(__file__).with_name('timing-oracle.py'))]
    inputs += config['inputs'] + [config['diagnostic'], config['ceiling']]
    builder = ROOT / 'selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/method.py'
    runtime = ROOT / 'selfhost/build/phase128/runtime-borrow01/runtime.o'
    expected = ROOT / 'selfhost/build/phase131/read-lookup01/expected.stdout'
    original = ROOT / 'selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program'
    inputs += [pin(builder), pin(runtime), pin(expected), pin(original)]
    for row in inputs: assert pin(Path(row['file'])) == row
    assert expected.read_text() == oracle.ordinary_stdout()
    out.mkdir()
    r = dict(complete=False, inputs=inputs, builds=[], observations=[],
        productionChange=False, scope='Independent output and diagnostic-count experiment only. '
        'QBE patches are unqualified; no timings reported and no full compiler binary changed.')
    def save(): (out / 'report.json').write_text(json.dumps(r, indent=2) + '\n')
    save()
    try:
        binaries = {'original': original}
        for variant in ['diagnostic', 'ceiling']:
            build = ROOT / 'selfhost/build/phase111' / (a.build_prefix + '-' + variant)
            cmd = ['python3', str(builder), '--source', config[variant]['file'], '--runtime', str(runtime),
                   '--out', str(build), '--seconds', '20']
            child = subprocess.run(cmd, capture_output=True, timeout=30)
            (out / (variant + '-build.stdout')).write_bytes(child.stdout)
            (out / (variant + '-build.stderr')).write_bytes(child.stderr)
            assert child.returncode == 0, child.stderr.decode()
            receipt = json.loads((build / 'report.json').read_text()); assert receipt['complete']
            r['builds'].append(pin(build / 'report.json')); binaries[variant] = Path(receipt['binary']['file'])
            save()
        for case, args in [('ordinary', []), ('read256', ['--', '8', '2', '256', '0'])]:
            for variant, binary in binaries.items():
                cmd = [str(binary), '--threads', '1', '--gpu', 'off', *args]
                child = subprocess.run(cmd, capture_output=True, timeout=10)
                row = dict(case=case, variant=variant, command=cmd, exitCode=child.returncode,
                           stdout=child.stdout.decode(), stderr=child.stderr.decode())
                r['observations'].append(row); save()
                assert child.returncode == 0 and not child.stderr
                lines = child.stdout.decode().splitlines(keepends=True)
                if variant == 'diagnostic':
                    fields = lines.pop().split()
                    assert len(fields) == 4 and fields[0] == 'p131-identity'
                    calls, iterations, hits = map(int, fields[1:])
                    assert 0 <= calls <= iterations and 0 <= hits <= iterations
                    row['counts'] = dict(kind=config.get('kind','private-reader'), calls=calls, iterations=iterations, identicalTrueSteps=hits,
                                         fraction=hits / iterations if iterations else None)
                ordinary = ''.join(lines)
                if case == 'ordinary': assert ordinary == oracle.ordinary_stdout()
                else: oracle.validate(ordinary, 8, 2, 256)
                row['independentOutputExact'] = True; save()
        for row in inputs: assert pin(Path(row['file'])) == row
        r['complete'] = True; save()
        print(json.dumps(dict(complete=True, counts=[x['counts'] for x in r['observations'] if 'counts' in x])))
    except BaseException as e:
        r['error'] = repr(e); save(); raise

if __name__ == '__main__': main()
