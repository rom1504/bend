"""Private candidate provenance and unchanged native request transport."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PERF = ROOT / 'selfhost/tools/performance'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    sys.modules[name] = result
    spec.loader.exec_module(result)
    return result


BASE = module('phase98_qualification_baseline', PERF / 'phase92/comparison/support.py')
S = module('phase98_qualification_guard', PERF / 'programs/support.py')
pin, read, verify = BASE.pin, BASE.read, BASE.verify


class Bindings:
    def __init__(self): self.rows = {}
    def bind(self, value):
        row = verify(value) if isinstance(value, dict) else pin(value)
        assert self.rows.setdefault(row['file'], row) == row
        return row
    def unchanged(self):
        for row in self.rows.values(): assert pin(row['file']) == row
    def tree(self, value):
        if isinstance(value, dict):
            if {'file', 'sha256', 'bytes'} <= value.keys(): self.bind(value)
            else:
                for child in value.values(): self.tree(child)
        elif isinstance(value, list):
            for child in value: self.tree(child)


def baseline(bindings):
    result = BASE.authenticate(ROOT / 'selfhost/build/phase92/upstream-b1/build.json')
    for row in result['inputs']: bindings.bind(row)
    return result


def entry_definitions(source):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?def (p86_\w+)\(', source))
    result = {}
    for match in matches:
        end = re.search(r'(?m)^(?:@unsafe|def |law |type |import )', source[match.end():])
        stop = match.end() + end.start() if end else len(source)
        result[match[1]] = source[match.start():stop].rstrip()
    assert 'p86_cli' in result and 'p86_effect_file' in result
    return result


def authenticate(binary, stage, source, build_receipt, bindings, context=None):
    context = context or baseline(bindings)
    receipt_pin = bindings.bind(build_receipt)
    receipt = read(receipt_pin['file'])
    assert receipt['kind'] == 'phase98-private-native-build' and receipt['complete']
    assert receipt['stage'] == stage and receipt['cPatched'] is False
    assert bindings.bind(binary) == bindings.bind(receipt['binary'])
    assert bindings.bind(source) == bindings.bind(receipt['source'])
    for row in receipt['inputs']: bindings.bind(row)
    bindings.bind(receipt['c'])
    guard = read(receipt['guard']['file'])
    assert guard['complete'] and guard['returncode'] == 0 and not guard.get('stoppedFor')
    assert guard['command'] == receipt['command']
    old = Path(context['source']['file']).read_text()
    new = Path(receipt['source']['file']).read_text()
    assert entry_definitions(new) == entry_definitions(old), 'This runner requires unchanged p86 transport definitions'
    return dict(stage=stage, source=receipt['source'], binary=receipt['binary'], c=receipt['c'],
                build=receipt_pin, argvSentinel=stage == 'b2', publicAdmission=False,
                scope='Private source-bound build; transport compatibility only. Qualification reports are separate.')


def native_args(context, producer, source, prefix, live=False):
    role = producer['stage']
    argv = BASE.native_args(context, role, source, prefix, live=live)
    argv[0] = producer['binary']['file']
    return argv


def baseline_producer(context, role):
    row = context['roles'][role]
    return dict(stage=role, source=context['source'], binary=row['admission']['binary'],
                build=context['build'] if role == 'b1' else row['admission']['build'],
                argvSentinel=row['argvSentinel'], historicalBaseline=True, producer=row['producer'])


def freeze_methods(out, bindings):
    for file in sorted(HERE.glob('*')):
        if file.is_file():
            bindings.bind(file)
            destination = out / 'methods' / file.name
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(file.read_bytes())
            bindings.bind(destination)
    bindings.bind(PERF / 'programs/support.py')
    bindings.bind(PERF / 'phase92/comparison/support.py')


SUCCESS_DIAGNOSTIC = 'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n'
CLOCK_LINE = r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n'


def strip_clocks(text): return re.sub(CLOCK_LINE, '', text, flags=re.M)


def run_request(guard, context, producer, source, out, seconds=300, live=False, oracle=None, negative=None,
                expected_diagnostic=SUCCESS_DIAGNOSTIC, capture_reference_diagnostic=False):
    import shutil
    import time
    assert not out.exists()
    out.mkdir(parents=True)
    assert shutil.disk_usage(ROOT).free > 210 * 1024**2, 'Need output room plus160MiB floor'
    prefix = out / 'output'
    argv = native_args(context, producer, source['file'], prefix, live)
    command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase98', 'taskset', '-c', '3', *argv]
    process = guard.run(command, out / 'guard', time.monotonic() + seconds)
    row = dict(source=source, live=live, command=command, process=process, passed=False,
               raw=[pin(out / 'guard' / name) for name in ['process.json', 'stdout.log', 'stderr.log']])
    stdout = (out / 'guard/stdout.log').read_text()
    stderr = (out / 'guard/stderr.log').read_text()
    diagnostic = strip_clocks(stderr)
    row['diagnostic'] = diagnostic
    (out / 'diagnostic.txt').write_text(diagnostic)
    row['diagnosticFile'] = pin(out / 'diagnostic.txt')
    clocks = re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$', stderr, re.M)
    row['clocks'] = clocks
    output = Path(str(prefix) + '.1.c')
    if output.exists(): row['output'] = pin(output)
    if negative is not None:
        row['expectedDiagnostic'] = strip_clocks(negative)
        row['passed'] = bool(process['returncode'] == 1 and not process.get('stoppedFor') and not process.get('interrupted') and not stdout and not output.exists() and diagnostic == row['expectedDiagnostic'])
    else:
        unsafe = re.fullmatch(r'SOME PROOFS FAIL\nError: (\d+) defs rely on unsafe or foreign code:\n((?:- [^\n]+\n)+)\n', diagnostic)
        row['unsafeOrForeignDefinitions'] = int(unsafe[1]) if unsafe else 0 if diagnostic == SUCCESS_DIAGNOSTIC else None
        if capture_reference_diagnostic:
            # Reference creation freezes the whole diagnostic, accepting only
            # the actual success/unsafe-dependency protocol plus successful C.
            row['referenceDiagnosticCaptured'] = bool(not stdout and (diagnostic == SUCCESS_DIAGNOSTIC or
                (unsafe and int(unsafe[1]) == len(unsafe[2].splitlines()))))
            diagnostic_ok = row['referenceDiagnosticCaptured']
        else:
            row['diagnosticExact'] = diagnostic == expected_diagnostic and not stdout
            diagnostic_ok = row['diagnosticExact']
        row['passed'] = bool(process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and diagnostic_ok and len(clocks) == 1 and clocks[0][0] == '1' and output.exists())
        if oracle is not None:
            row['oracle'] = oracle
            row['exactC'] = output.exists() and all(row['output'][k] == oracle[k] for k in ['sha256', 'bytes'])
            row['passed'] = row['passed'] and row['exactC']
        if clocks:
            row['requestMs'] = int(clocks[0][1])
            row['processWallMs'] = process['wallSeconds'] * 1000
    S.save(out / 'report.json', row)
    return row
