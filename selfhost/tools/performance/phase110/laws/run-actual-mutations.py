#!/usr/bin/env python3
"""Compile isolated consumer mutations; root must run under one outer CPU3 guard.

No runtime/harness compilation and no production edits. The accepted API supplies
the positive worker; each mutant obtains its own checked API. Compile failures,
static-control failures, signals, timeouts and malformed output never count as
native semantic mutation detections.
"""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[5]
HERE = ROOT / 'selfhost/tools/performance/phase110'
BUILD = ROOT / 'selfhost/build/phase110'
CASE = 'list-two-root-aliases'
SOURCE_SHA = '9da4f49e2427d96c5a5e0d62d90a7e5f2b939e7e51cbf09e05f902b3e5323996'
API_SHA = 'd5994ad51f2f3ec2c25a2e7bf7f1554313c1b49b25f527d060d3352499660184'
CONTROL_NAMES = {'nx', 'ownership', 'policy', 'policy110', 'pair', 'take',
                 'alias', 'calls', 'runtime-ir', 'runtime-width'}


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def verify(item):
    path = Path(item['file'])
    if not path.is_absolute():
        path = ROOT / path
    actual = pin(path)
    if any(actual[key] != item[key] for key in ('bytes', 'sha256')):
        raise ValueError('changed authenticated file: ' + str(path))
    return path


def linked_list(value):
    result = []
    while value.get('$') == 'Con':
        result.append(value['head'])
        value = value['tail']
    if value != {'$': 'Nil'}:
        raise ValueError('malformed serialized Bend list')
    return result


def expected_mutant_library(original, mutation):
    """Check activation by exact structural difference, not output agreement."""
    result = copy.deepcopy(original)
    changed = []

    def walk(value, path):
        if isinstance(value, dict):
            if mutation == 'tagged-runtime-index-flip' and value.get('$') == 'NxCall' and value.get('name') == 'rt_rebuild2':
                args = linked_list(value['args'])
                if len(args) != 5 or args[3] != {'$': 'NxConst', 'typ': {'$': 'NxU32'}, 'value': 0}:
                    raise ValueError('unexpected frozen reverse rebuild index')
                args[3]['value'] = 1
                changed.append(dict(path=path, before=0, after=1))
            if mutation == 'remaining-transfer-to-retained-local' and value.get('$') == 'NxSet' and value.get('value', {}).get('name') == 'rt_fast_field':
                args = linked_list(value['value']['args'])
                if value['name'] != 'v1' or args != [{'$': 'NxVar', 'name': 'ctx'}, {'$': 'NxConst', 'typ': {'$': 'NxU32'}, 'value': 0}]:
                    raise ValueError('unexpected frozen reverse remaining transfer')
                value['name'] = 'v0'
                changed.append(dict(path=path, before='v1', after='v0'))
            for key, child in value.items():
                walk(child, path + '/' + key)
        elif isinstance(value, list):
            for i, child in enumerate(value):
                walk(child, path + '/' + str(i))

    walk(result, '')
    if len(changed) != 2:
        raise ValueError('expected one changed operation in each reverse worker')
    return result, changed


def explicit_semantic_rejection(returncode, stdout, stderr, expected):
    if returncode == 0:
        try:
            rows = [json.loads(line) for line in stdout.splitlines()]
        except ValueError as error:
            raise ValueError('malformed output is not the required semantic witness') from error
        if len(rows) != 1 or set(rows[0]) != {'name', 'count', 'hash', 'aliases', 'released'}:
            raise ValueError('incomplete native observation')
        row = rows[0]
        if row['name'] != CASE or type(row['count']) is not int or row['count'] < 0 or row['released'] is not True:
            raise ValueError('invalid native case/count/release observation')
        if not isinstance(row['hash'], str) or not re.fullmatch('[0-9a-f]{16}', row['hash']):
            raise ValueError('invalid native observation hash')
        if not isinstance(row['aliases'], list) or len(row['aliases']) != len(expected['aliases']):
            raise ValueError('incomplete alias observations')
        for alias in row['aliases']:
            if set(alias) != {'count', 'hash'} or type(alias['count']) is not int or alias['count'] < 0 or not isinstance(alias['hash'], str) or not re.fullmatch('[0-9a-f]{16}', alias['hash']):
                raise ValueError('malformed alias observation')
        if row == expected:
            raise ValueError('mutant survived the frozen semantic control')
        return dict(kind='exact-oracle-mismatch', actual=row, expected=expected)
    abi_errors = {
        'constructor ID outside descriptor', 'constructor representation mismatch',
        'constructor location outside arena', 'constructor tail type mismatch',
        'List head must be String', 'Char must be a Unicode scalar',
        'invalid or repeated scratch transfer', 'impossible source branch',
        'unreleased scratch children', 'unreleased heap ownership',
        'over-released heap', 'free-list cycle', 'free-list address outside heap',
        'allocator length mismatch', 'host bank indices mismatch',
    }
    harness_errors = {
        'worker left scratch children', 'text ended at wrong constructor',
        'list ended at wrong constructor', 'worker leaked ownership',
    }
    for line in stderr.splitlines():
        if returncode == 1 and line.startswith('bend: nx ABI: ') and line.removeprefix('bend: nx ABI: ') in abi_errors:
            return dict(kind='explicit-runtime-abi-error', diagnostic=line)
        if returncode == 2 and line.startswith('harness: ') and line.removeprefix('harness: ') in harness_errors:
            return dict(kind='explicit-harness-semantic-error', diagnostic=line)
    raise ValueError('signal, crash, infrastructure error or unrecognized exit is not a semantic witness: ' + str(returncode))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--cached-build', type=Path, default=BUILD / 'private-build01')
    args = parser.parse_args()
    out = args.out.resolve()
    cached = args.cached_build.resolve()
    if out.exists() or not out.is_relative_to(BUILD):
        raise ValueError('fresh output under selfhost/build/phase110 required')
    out.mkdir(parents=True)
    report = dict(kind='phase110-actual-compiled-consumer-mutations', complete=False,
                  targetsRun=False, inputs=[], jobs=[], mutations=[], case=CASE,
                  profile='tagged', backend='qbe', started=time.time(),
                  scope='Actual compiled lowering consumer faults with unchanged checked facts, static controls, cached runtime/harness objects and frozen oracle. No physical runtime theorem.')

    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')

    def bind(path):
        item = pin(path)
        if not any(old['file'] == item['file'] for old in report['inputs']):
            report['inputs'].append(item)
        return item

    def unchanged():
        for item in report['inputs']:
            verify(item)

    def run(label, command, timeout, expect_success=True):
        report['targetsRun'] = True
        stdout_path, stderr_path = out / (label + '.stdout'), out / (label + '.stderr')
        row = dict(label=label, command=list(map(str, command)), timeoutSeconds=timeout,
                   stoppedFor=None, complete=False)
        report['jobs'].append(row)
        save()
        begin = time.monotonic()
        with stdout_path.open('xb') as stdout, stderr_path.open('xb') as stderr:
            proc = subprocess.Popen(row['command'], cwd=ROOT, stdout=stdout, stderr=stderr, start_new_session=True)
            row['pid'] = proc.pid
            save()
            try:
                proc.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                row['stoppedFor'] = 'timeout'
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait()
            row.update(returncode=proc.returncode, seconds=time.monotonic() - begin,
                       stdout=pin(stdout_path), stderr=pin(stderr_path), complete=proc.returncode == 0 and row['stoppedFor'] is None)
        save()
        if row['stoppedFor'] or (expect_success and proc.returncode != 0):
            raise ValueError('target failure does not satisfy mutation protocol: ' + label)
        return row, stdout_path.read_text(), stderr_path.read_text()

    save()
    try:
        source = BUILD / 'call-source04/source.bend'
        source_manifest = BUILD / 'call-source04/manifest.json'
        api_record = BUILD / 'call-api02/report.json'
        api = BUILD / 'call-api02/api.mjs'
        recipe_path = HERE / 'laws/actual-candidate-mutations.json'
        capture, harness = ROOT / 'selfhost/build/phase109/capture02', BUILD / 'train01'
        build_record = cached / 'report.json'
        build, accepted, source_facts, recipe = map(read, [build_record, api_record, source_manifest, recipe_path])
        if not build['complete'] or not accepted['complete'] or accepted['status'] != 0 or not source_facts['complete']:
            raise ValueError('completed accepted source/API/cached build required')
        if pin(source)['sha256'] != SOURCE_SHA or pin(api)['sha256'] != API_SHA:
            raise ValueError('accepted call-source04/call-api02 identity changed')
        verify(accepted['source']); verify(accepted['api']); verify(accepted['method']); verify(source_facts['source'])
        if Path(accepted['source']['file']) != source or source_facts['source'] != accepted['source']:
            raise ValueError('accepted API source correspondence differs')
        if pin(HERE / 'build-api.py') != accepted['method']:
            raise ValueError('checked API build method differs from accepted profile')
        for item in build['inputs']:
            verify(item)
            bind(item['file'])
        if not any(item == pin(api) for item in build['inputs']):
            raise ValueError('cached build did not use accepted call-api02')
        for label, output_name in [('runtime', 'runtime.o'), ('harness', 'harness.o')]:
            jobs = [job for job in build['jobs'] if job['label'] == label]
            if len(jobs) != 1 or jobs[0]['status'] != 0 or str(cached / output_name) not in jobs[0]['command']:
                raise ValueError('cached object build provenance missing: ' + output_name)
        if not build['semantics'] or not all(row['exact'] for row in build['semantics'].values()):
            raise ValueError('cached build lacks exact semantic qualification')
        runtime_obj, harness_obj = cached / 'runtime.o', cached / 'harness.o'
        report['cachedObjects'] = [bind(runtime_obj), bind(harness_obj)]
        report['cachedObjectProvenance'] = 'Prior complete receipt authenticates input sources and successful object-build commands. Object bytes are pinned now and shared by the new positive and both negative workers; the earlier receipt did not hash these two objects.'
        capture_record, harness_record = read(capture / 'report.json'), read(harness / 'manifest.json')
        if not capture_record['complete'] or not harness_record['complete'] or harness_record['variant'] != 'reverse' or harness_record['split'] != 'training':
            raise ValueError('frozen capture/training harness required')
        for item in capture_record['products'] + harness_record['outputs']:
            verify(item); bind(item['file'])
        expected_rows = [json.loads(line) for line in (harness / 'expected.jsonl').read_text().splitlines()]
        selected = [row for row in expected_rows if row['name'] == CASE]
        if len(selected) != 1:
            raise ValueError('frozen small semantic case missing')
        expected = selected[0]
        (out / 'expected.jsonl').write_text(json.dumps(expected, separators=(',', ':')) + '\n')
        source_text = source.read_text()
        module_path = HERE / 'lower/policy.bend'
        helper_path = HERE / 'laws/helper.bend'
        extracted = {}
        for path, marker, filename in [
                (module_path, '# Additive checked policies over Phase109', 'baseline-policy.bend'),
                (helper_path, '# Shared by the actual Phase110 lowering', 'baseline-helper.bend')]:
            historical = next(item for item in recipe['sourcePins'] if item['file'] == str(path.relative_to(ROOT)))
            source_bytes = source.read_bytes()
            marker_bytes = marker.encode()
            if source_bytes.count(marker_bytes) != 1:
                raise ValueError('historical module extraction marker must occur once')
            start = source_bytes.index(marker_bytes)
            module_bytes = source_bytes[start:start + historical['bytes']]
            if hashlib.sha256(module_bytes).hexdigest() != historical['sha256']:
                raise ValueError('accepted source module differs from frozen recipe: ' + str(path))
            if source_bytes.count(module_bytes) != 1:
                raise ValueError('expected complete verbatim source module once: ' + str(path))
            frozen = out / filename
            frozen.write_bytes(module_bytes)
            extracted[path] = frozen
            bind(frozen)
        module = extracted[module_path].read_text()
        for item in recipe['cases']:
            if item['file'] != str(module_path.relative_to(ROOT)) or item['profile'] != 'tagged' or module.count(item['before']) != 1:
                raise ValueError('mutation scope differs from authenticated policy')
        if [item['id'] for item in recipe['cases']] != ['tagged-runtime-index-flip', 'remaining-transfer-to-retained-local']:
            raise ValueError('unexpected mutation catalogue')
        report['recipeInterpretation'] = 'Use unchanged recipe replacement pairs within the complete authenticated policy module. Root authorized call-source04/call-api02 and private-build01 in place of historical baselineExample/transport pins. Runtime-IR has another identical scratch-transfer spelling, so global substring replacement is forbidden.'
        bun = ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun'
        qbe = ROOT / 'selfhost/build/phase108/toolchain/qbe-1.3/qbe'
        gcc, assembler = Path(shutil.which('gcc')).resolve(), Path(shutil.which('as')).resolve()
        emitter = cached / 'emit-method.mjs'
        authenticated_emitter = next(item for item in build['inputs'] if item['file'] == str(HERE / 'emit.mjs'))
        if pin(emitter)['sha256'] != authenticated_emitter['sha256']:
            raise ValueError('cached emitter does not match accepted build transport')
        for path in [Path(__file__), source, source_manifest, api_record, api, recipe_path,
                     build_record, capture / 'report.json', harness / 'manifest.json',
                     HERE / 'build-api.py', emitter,
                     ROOT / 'selfhost/tools/stage0-library.mjs', bun, qbe, gcc, assembler,
                     *[ROOT / 'bend2' / name for name in ['main.ts', 'bend.ts', 'comp.ts', 'safe.ts', 'base.bend']]]:
            bind(path)
        (out / 'method.py').write_bytes(Path(__file__).read_bytes())
        (out / 'emit-method.mjs').write_bytes(emitter.read_bytes())
        (out / 'recipe.json').write_bytes(recipe_path.read_bytes())
        report['positiveApi'] = accepted
        report['source'] = pin(source)
        report['expected'] = pin(out / 'expected.jsonl')
        save(); unchanged()

        def emit_compile(name, worker_api):
            folder = out / name
            folder.mkdir(exist_ok=True)
            emission = folder / 'emission'
            run(name + '-emit', [bun, out / 'emit-method.mjs', worker_api, capture, emission, 'reverse', 'tagged'], 45)
            emitted = read(emission / 'report.json')
            if not emitted['complete'] or set(emitted['controls']) != CONTROL_NAMES or not all(row['passed'] for row in emitted['controls'].values()):
                raise ValueError('all unchanged static control reports must pass')
            for item in emitted['inputs'] + emitted['outputs']:
                verify(item)
            assembly, obj, binary = folder / 'worker.s', folder / 'worker.o', folder / 'worker'
            run(name + '-qbe', [qbe, '-t', 'amd64_sysv', '-o', assembly, emission / 'program.ssa'], 45)
            run(name + '-assemble', [assembler, '-o', obj, assembly], 15)
            run(name + '-link', [gcc, '-no-pie', obj, runtime_obj, harness_obj, '-pthread', '-lm', '-o', binary], 20)
            return emission, binary, dict(emission=pin(emission / 'report.json'), assembly=pin(assembly), object=pin(obj), binary=pin(binary))

        baseline_emission, baseline_binary, positive = emit_compile('baseline', api)
        row, stdout, stderr = run('baseline-native', [baseline_binary, CASE, '1'], 10)
        observed = [json.loads(line) for line in stdout.splitlines()]
        if observed != [expected]:
            raise ValueError('positive worker differs from frozen small-case oracle')
        report['positive'] = dict(**positive, exact=True, expected=expected, observation=observed[0], nativeJob=row['label'])
        baseline_library = read(baseline_emission / 'library.json')
        save()
        for item in recipe['cases']:
            unchanged()
            name = item['id']
            folder = out / name
            folder.mkdir()
            replacement = module.replace(item['before'], item['after'], 1)
            if replacement.count(item['after']) != 1:
                raise ValueError('mutated scoped text must be unique')
            mutated = source_text.replace(module, replacement, 1)
            if mutated.count(replacement) != 1 or mutated.replace(replacement, module, 1) != source_text:
                raise ValueError('mutation inverse replay mismatch')
            mutant_source = folder / 'source.bend'
            mutant_source.write_text(mutated)
            mutation = dict(id=name, source=pin(mutant_source), baseline=pin(source), policyModule=pin(extracted[module_path]),
                            scopedOccurrences=1, wholeModuleOccurrences=1, unscopedBeforeOccurrences=source_text.count(item['before']),
                            inverseExact=True, nativeRejected=False, before=item['before'], after=item['after'])
            report['mutations'].append(mutation); save()
            api_out = folder / 'api'
            run(name + '-api', [sys.executable, '-B', HERE / 'build-api.py', '--source', mutant_source,
                               '--out', api_out, '--calls', '--runtime-ir'], 60)
            built = read(api_out / 'report.json')
            if not built['complete'] or built['status'] != 0 or built['exports'] != accepted['exports'] or built['method'] != accepted['method'] or built['source'] != pin(mutant_source):
                raise ValueError('mutant did not pass the exact accepted API acquisition profile')
            verify(built['api'])
            mutation['checkedApi'] = pin(api_out / 'report.json')
            emission, binary, products = emit_compile(name, api_out / 'api.mjs')
            for control in CONTROL_NAMES:
                if (emission / (control + '-controls.txt')).read_bytes() != (baseline_emission / (control + '-controls.txt')).read_bytes():
                    raise ValueError('static control observations changed: ' + control)
            for symbol in ['list_reverse', 'string_reverse']:
                if (emission / (symbol + '.owned.json')).read_bytes() != (baseline_emission / (symbol + '.owned.json')).read_bytes():
                    raise ValueError('checked ownership graph changed')
            expected_library, changes = expected_mutant_library(baseline_library, name)
            if read(emission / 'library.json') != expected_library:
                raise ValueError('generated IR differs beyond the intended consumer fault')
            mutation.update(products=products, staticControlsIdentical=True, ownedGraphsIdentical=True, activation=changes)
            save()
            row, stdout, stderr = run(name + '-native', [binary, CASE, '1'], 10, expect_success=False)
            rejection = explicit_semantic_rejection(row['returncode'], stdout, stderr, expected)
            mutation.update(nativeRejected=True, nativeJob=row['label'], rejection=rejection)
            save()
        unchanged()
        if len(report['mutations']) != 2 or not all(row['nativeRejected'] for row in report['mutations']):
            raise ValueError('both actual consumer faults must be rejected')
        report.update(complete=True, inputsUnchanged=True, finished=time.time(),
                      interpretation='The accepted source/selector and tagged native worker pass. Two isolated production consumer faults pass unchanged checked API/static/Nx controls, produce exactly the intended IR change, then fail the frozen native semantic observation. This exposes the remaining selector-to-consumer/runtime proof boundary.')
        save()
    except BaseException as error:
        report['error'] = repr(error)
        save()
        raise
    print(json.dumps(dict(complete=True, mutations=len(report['mutations']), jobs=len(report['jobs']), out=str(out))))


if __name__ == '__main__':
    main()
