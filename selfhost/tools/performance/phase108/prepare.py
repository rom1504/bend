#!/usr/bin/env python3
"""Prepare the scoped portable-register compiler profile; execute no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SELECTED_SOURCE_SHA256 = '63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'
LAUNCH_PATH = ROOT / 'selfhost/tools/native/launch.py'
spec = importlib.util.spec_from_file_location('phase108_native_launch', LAUNCH_PATH)
N = importlib.util.module_from_spec(spec)
spec.loader.exec_module(N)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def definition(text, name):
    """Extract one audited single-paragraph declaration, including @unsafe."""
    hits = list(re.finditer(r'^(?:@unsafe\n)?def ' + re.escape(name) + r'\(', text, re.M))
    require(len(hits) == 1, 'expected one definition: ' + name)
    start = hits[0].start()
    end = text.find('\n\n', start)
    require(end >= 0, 'missing declaration boundary: ' + name)
    block = text[start:end]
    require(len(re.findall(r'^def ', block, re.M)) == 1, 'ambiguous declaration: ' + name)
    return start, end, block


def split_runtime(text, marks):
    """Transport the retained marker contract; no compiler/runtime decisions."""
    parts, cursor = [], 0
    for mark in marks:
        require(text.count(mark) == 1, 'runtime marker is missing or duplicated: ' + mark)
        begin = text.find(mark, cursor)
        require(begin >= cursor, 'runtime markers are out of order')
        end = begin + len(mark)
        require(text[end:end + 1] == '\n', 'runtime marker must end at a newline')
        parts.append(text[cursor:end])
        cursor = end
    parts.append(text[cursor:])
    require(''.join(parts) == text, 'runtime reconstruction differs')
    # Compare part insertion with the existing sequential marker substitution.
    payloads = ['P108_TRANSPORT_' + str(i) for i in range(len(marks))]
    joined = ''.join(part + '\n\n' + payload for part, payload in zip(parts, payloads)) + parts[-1]
    sequential = text
    for mark, payload in zip(marks, payloads):
        sequential = sequential.replace(mark, mark + '\n\n' + payload)
    require(joined == sequential, 'runtime part insertion contract differs')
    return parts


def request_args(binary, assets, source, runtime, prefix, sentinel=True, live=False):
    argv = [str(binary), '--threads', '1', '--gpu', 'off', '--']
    if sentinel:
        argv.append(assets['argvSentinel'])
    argv.extend([str(source), assets['base']['file'], str(runtime), assets['effectsDir'], str(prefix), '1'])
    if not live:
        argv.extend([assets['cache']['carrier']['file'], assets['cache']['stamp']])
    return argv


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--selection', type=Path, default=N.DEFAULT)
    parser.add_argument('--runtime', type=Path)
    parser.add_argument('--variant', choices=['v1','v2','v3'], default='v3')
    args = parser.parse_args()
    out = args.out.resolve()
    require(out.is_relative_to(ROOT / 'selfhost/build/phase108') and not out.exists(),
            'use a fresh output directory under selfhost/build/phase108')

    release, binding = N.load(args.selection, stage='b2', live=False)
    require(release['source']['sha256'] == SELECTED_SOURCE_SHA256,
            'selected source changed; review the scoped declaration replacement')
    source_pin = N.verify(release['source'])
    tables_pin = N.pin(ROOT / 'selfhost/src/back/native/tables.bend')
    runtime_recipe_inputs = []
    if args.runtime is None:
        recipe_path = HERE / 'runtime/runtime-recipes.json'
        mspec = importlib.util.spec_from_file_location('runtime_materialize', HERE / 'runtime/materialize.py')
        materializer = importlib.util.module_from_spec(mspec); mspec.loader.exec_module(materializer)
        raw, edits = materializer.apply_variant(Path(release['assets']['runtime']['file']).read_bytes(), args.variant, json.loads(recipe_path.read_text()))
        cache = ROOT / 'selfhost/build/phase108/runtime-cache' / materializer.OUTPUTS[args.variant]['sha256']
        cache.mkdir(parents=True, exist_ok=True)
        path = cache / 'runtime.c'
        if path.exists(): require(path.read_bytes() == raw, 'changed materialized runtime cache')
        else:
            with path.open('xb') as f: f.write(raw)
        args.runtime = path
        runtime_recipe_inputs = [N.pin(recipe_path), N.pin(HERE / 'runtime/materialize.py'), release['assets']['runtime']]
    runtime_pin = N.pin(args.runtime)
    source = Path(source_pin['file']).read_text()
    tables = Path(tables_pin['file']).read_text()
    runtime = Path(runtime_pin['file']).read_text()

    begin, end, original_bank = definition(source, 'nb_bank')
    _, _, replacement_bank = definition(tables, 'nb_bank')
    _, _, helper = definition(tables, 'nb_zero')
    require(not re.search(r'^def nb_zero\(', source, re.M), 'selected source already defines nb_zero')
    macro_names = ['WL_WIDTH', 'WL_INIT_BANK', 'WL_WRITE_STATE(V)', 'WL_READ_STATE(V)']
    additions = [line for line in replacement_bank.splitlines()
                 if any('#define ' + name + ' ' in line for name in macro_names)]
    require(len(additions) == 4, 'canonical nb_bank lacks exact portable transport additions')
    stripped = '\n'.join(line for line in replacement_bank.splitlines() if line not in additions)
    require(stripped == original_bank, 'canonical nb_bank changes more than register transport metadata')
    changed = source[:begin] + helper + '\n\n' + replacement_bank + source[end:]
    inverse = changed[:begin] + original_bank + changed[begin + len(helper) + 2 + len(replacement_bank):]
    require(inverse == source, 'scoped source inverse differs')
    require(len(re.findall(r'^def main\(', changed, re.M)) == 1, 'prepared source has unexpected entry count')
    require(definition(changed, 'main')[2] == definition(source, 'main')[2], 'supervisory entry changed')

    _, _, marks_definition = definition(source, 'ne_template_marks')
    marks = json.loads(marks_definition.split('-> List<&2, String>:\n', 1)[1].strip())
    require(len(marks) == 4 and len(set(marks)) == 4, 'expected four markers and five retained parts')
    assets = release['assets']
    original_runtime = Path(assets['runtime']['file']).read_text()
    original_parts = split_runtime(original_runtime, marks)
    template = json.loads(Path(assets['template']['file']).read_text())
    require(template['version'] == 1 and template['runtimeSha256'] == assets['runtime']['sha256'],
            'selected runtime template identity differs')
    require(template['parts'] == original_parts, 'selected template differs from marker splitting')
    require([Path(part['file']).read_text() for part in assets['parts']] == original_parts,
            'selected retained parts differ from marker splitting')
    new_parts = split_runtime(runtime, marks)
    require('WL_PORTABLE' in runtime and 'WL_WRITE_STATE(wl->regs)' in runtime,
            'runtime lacks the scoped portable dispatch protocol')

    # Preserve only bounded source fragments, the changed source and runtime assets.
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(changed)
    (out / 'original-nb-bank.bend').write_text(original_bank + '\n')
    (out / 'portable-nb-bank.bend').write_text(helper + '\n\n' + replacement_bank + '\n')
    (out / 'runtime.c').write_text(runtime)
    for index, part in enumerate(new_parts):
        (out / ('runtime.c.part' + str(index))).write_text(part)
    (out / 'runtime.template.json').write_text(json.dumps(dict(
        version=1, runtimeSha256=digest(runtime.encode()), parts=new_parts), separators=(',', ':')) + '\n')

    candidate_source = N.pin(out / 'compiler.bend')
    prepared_runtime = N.pin(out / 'runtime.c')
    build_pin = N.verify(release['stages']['b2']['build'])
    build = json.loads(Path(build_pin['file']).read_text())
    clang = N.verify(build['clang'])
    binary = out / 'compiler'
    baseline_emit = N.native_args(release, candidate_source['file'], out / 'acquire', stage='b2')
    commands = dict(
        acquireEmission=baseline_emit,
        acquireLink=[clang['file'], '-isystem', str(Path(clang['file']).parents[1] / 'include/clang'),
                     '-O2', str(out / 'acquire.1.c'), '-o', str(binary), '-lm', '-pthread'],
        portableSelfEmission=request_args(binary, assets, candidate_source['file'], out / 'runtime.c', out / 'self-portable'),
        portableFixtureEmission=request_args(binary, assets,
            HERE / 'coverage/fixtures/higher-order-capture.bend', out / 'runtime.c', out / 'fixture-portable'))
    inputs = [N.pin(__file__), N.pin(LAUNCH_PATH), binding['selection'], binding['admission'],
              source_pin, tables_pin, runtime_pin, *runtime_recipe_inputs, build_pin, clang, release['stages']['b2']['binary'],
              assets['base'], assets['runtime'], assets['template'], *assets['parts'],
              assets['cache']['carrier'], *assets['effects']]
    for record in inputs:
        N.verify(record)
    require((out / 'runtime.c').read_bytes() == b''.join(
        (out / ('runtime.c.part' + str(i))).read_bytes() for i in range(5)),
        'written runtime parts do not reconstruct the written runtime')
    report = dict(
        kind='phase108-portable-native-source', version=1, prepared=True, targetsRun=False,
        method=N.pin(__file__), selection=binding, selectedSource=source_pin,
        source=candidate_source, canonicalTables=tables_pin,
        originalBank=N.pin(out / 'original-nb-bank.bend'), portableBank=N.pin(out / 'portable-nb-bank.bend'),
        sourceEdits=['insert canonical nb_zero immediately before nb_bank',
                     'replace only nb_bank with canonical four-macro transport extension'],
        inverseExact=True, supervisoryEntryUnchanged=True,
        runtimeInput=runtime_pin, runtime=prepared_runtime,
        template=N.pin(out / 'runtime.template.json'),
        parts=[N.pin(out / ('runtime.c.part' + str(i))) for i in range(5)],
        markerContract=dict(markers=marks, originalPartsExact=True, reconstructionExact=True,
                            insertionMatchesSequentialFill=True),
        assets=assets, inputs=inputs, commands=commands,
        commandNotes=['Commands are data only and require the root process-tree/resource guard.',
                      'Acquisition uses the selected original runtime and Clang; no portable macro bridge is needed.',
                      'The acquired Bend-produced image uses the existing b2 argv sentinel.',
                      'Portable emissions require WL_PORTABLE=1 and the separately qualified cproc atomic/CLZ support at build time.',
                      'QBE/cproc acquisition and execution qualification remain separate root-owned work.'],
        scope='Scoped compiler-source and runtime transport preparation only; no compiler execution or image qualification.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(prepared=True, targetsRun=False, source=candidate_source,
                          runtime=prepared_runtime, manifest=str(out / 'manifest.json'))))


if __name__ == '__main__':
    main()
