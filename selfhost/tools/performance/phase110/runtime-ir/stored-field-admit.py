#!/usr/bin/env python3
"""Authenticate the stored-field omission premises; no target execution.

This is an explicit experimental source-admission receipt, not a heap proof.
Every admitted dynamic payload writer seals external fields. The only raw
payload writer is the checked static constructor, whose address is below the
dynamic threshold. Exact private graph regeneration and closed owning calls
preserve this boundary. Fabricated native Terms and arbitrary heap writers are
outside the admission contract.
"""
import argparse
import hashlib
import itertools
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE_SHA = '0d69b87878551c42492b9b173ebf6af92eebf1a9eb8cb6afccb5535366dea3ca'
ALLOWED_KINDS = {
    'phase109-production-runtime-core', 'phase110-additive-runtime-core',
    'phase110-explicit-runtime-variant', 'phase110-private-runtime-ir-core',
    'phase110-runtime-ir-test-probe-core'}


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(raw),
                sha256=hashlib.sha256(raw).hexdigest())


def runtime_chain(manifest, seen=None):
    seen = {} if seen is None else seen
    manifest = manifest.resolve()
    if manifest in seen:
        return seen
    facts = json.loads(manifest.read_text())
    if not facts.get('complete') or facts.get('kind') not in ALLOWED_KINDS:
        raise ValueError('unknown runtime receipt kind: ' + str(manifest))
    seen[manifest] = facts
    records = [*facts.get('inputs', []), *facts.get('outputs', [])]
    if isinstance(facts.get('base'), dict) and 'file' in facts['base']:
        records.append(facts['base'])
    for record in records:
        if pin(Path(record['file'])) != record:
            raise ValueError('changed authenticated file: ' + record['file'])
    for record in facts.get('inputs', []):
        if record['file'].endswith('/manifest.json'):
            runtime_chain(Path(record['file']), seen)
    return seen


def runtime_text_ok(source, base, components):
    if hashlib.sha256(base.encode()).hexdigest() != BASE_SHA:
        raise ValueError('unknown complete Phase109 payload writers')
    for construct, take, general, probe in itertools.product(
            ['helper', 'direct'], [False, True], [False, True], [False, True]):
        selected = [construct] + (['take'] if take else []) + ['private']
        selected += ['general'] if general else []
        selected += ['probe'] if probe else []
        expected = base + ''.join('\n' + components[key] for key in selected)
        if source == expected:
            return selected
    raise ValueError('runtime contains an unknown payload writer or component')


def definitions(text):
    """Read column-zero Bend declarations, excluding inter-declaration comments."""
    starts = list(re.finditer(r'(?m)^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\(', text))
    result = {}
    for index, match in enumerate(starts):
        end = starts[index + 1].start() if index + 1 < len(starts) else len(text)
        body = text[match.start():end]
        body = re.split(r'\n(?=#|type |import |@safe)', body, maxsplit=1)[0].rstrip()
        if match.group(1) in result:
            raise ValueError('duplicate declaration: ' + match.group(1))
        result[match.group(1)] = body
    return result


def source_ok(source, expected, allowed, omission):
    actual = definitions(source)
    if actual.get('nx110rt_rebuild_fast') != omission:
        raise ValueError('exact retained-field omission is not selected')
    for name, original in expected.items():
        choices = [original, *allowed.get(name, [])]
        if name == 'nx110rt_rebuild_fast':
            choices = [omission]
        if actual.get(name) not in choices:
            raise ValueError('unknown private template declaration: ' + name)
    # A source that admits ordinary owning calls must use the closed catalogue
    # verifier, never the earlier scalar-only private verifier.
    if 'NxoCall{' in source and 'nx110rt_calls_ok' not in actual['nx110rt_verify']:
        raise ValueError('ordinary calls require the closed ownership catalogue')
    return True


def refused(action):
    try:
        action()
    except ValueError:
        return True
    return False


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime', type=Path, required=True)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    chain = runtime_chain(a.runtime / 'manifest.json')
    roots = [facts for facts in chain.values()
             if facts['kind'] == 'phase109-production-runtime-core']
    if len(roots) != 1:
        raise ValueError('one authenticated production runtime required')
    base_path = Path(next(r['file'] for r in roots[0]['outputs']
                         if r['file'].endswith('/runtime.c')))
    base = base_path.read_text()
    paths = {'helper': HERE.parent / 'runtime/adapter.inc.c',
             'direct': HERE.parent / 'runtime/adapter-direct.inc.c',
             'take': HERE.parent / 'runtime/take-pair.inc.c',
             'private': HERE / 'adapter.inc.c',
             'general': HERE / 'general-runtime.inc.c',
             'probe': HERE / 'probe-runtime.inc.c'}
    components = {key: path.read_text() for key, path in paths.items()}
    runtime = (a.runtime / 'runtime.c').read_text()
    selected = runtime_text_ok(runtime, base, components)
    template_paths = [HERE / 'lower.bend', HERE / 'library.bend']
    if 'general' in selected:
        template_paths.append(HERE / 'general.bend')
    source = a.source.read_text()
    if 'NxoCall{' in source:
        template_paths.append(HERE.parent / 'calls/runtime-library.bend')
    expected = {}
    for path in template_paths:
        expected.update(definitions(path.read_text()))
    override_paths = [HERE / 'predicate-overrides.json',
                      HERE / 'general-overrides.json',
                      HERE.parent / 'calls/runtime-overrides.json']
    allowed = {}
    for path in override_paths:
        for replacement in json.loads(path.read_text())['replacements']:
            allowed.setdefault(replacement['name'], []).append(replacement['new'])
    omission_path = HERE / 'stored-field-overrides.json'
    omission_record = json.loads(omission_path.read_text())['replacements'][0]
    omission = omission_record['new']
    if expected['nx110rt_rebuild_fast'] != omission_record['old']:
        raise ValueError('omission origin changed')
    source_ok(source, expected, allowed, omission)
    mutations = {
        'reject-unsealed-dynamic-head': runtime.replace(
            'e.mem[loc] = rfc_seal(e, head);', 'e.mem[loc] = head;', 1),
        'reject-unsealed-dynamic-tail': runtime.replace(
            'e.mem[loc + 1] = rfc_seal(e, tail);', 'e.mem[loc + 1] = tail;', 1),
        'reject-static-writer-in-heap': runtime.replace(
            'Loc loc = STAT_OFF + ctx->static_words;',
            'Loc loc = HEAP_OFF + ctx->static_words;', 1),
        'reject-new-raw-writer': runtime + '\nvoid unsafe_payload(Env e, Loc p, Term t) { e.mem[p] = t; }\n',
    }
    controls = [{'name': name, 'ok': text != runtime and refused(
        lambda text=text: runtime_text_ok(text, base, components))}
        for name, text in mutations.items()]
    altered = source.replace('nx110rt_seal("ir_tail")', '[]')
    controls.append(dict(name='reject-omitted-external-field-seal', ok=altered != source and
        refused(lambda: source_ok(altered, expected, allowed, omission))))
    altered = source.replace('NxSet{"ir_ok",nx110rt_dynamic(NxVar{"ir_src"})}',
                             'NxSet{"ir_ok",NxConst{NxU32{},1}}')
    controls.append(dict(name='reject-rfc-to-static-fast-admission', ok=altered != source and
        refused(lambda: source_ok(altered, expected, allowed, omission))))
    altered = source.replace(omission, omission_record['old'])
    controls.append(dict(name='reject-unselected-ablation', ok=altered != source and
        refused(lambda: source_ok(altered, expected, allowed, omission))))
    if not all(c['ok'] for c in controls):
        raise ValueError('source refusal control failed: ' + repr(controls))
    record = dict(kind='phase110-stored-field-admission', version=1,
        complete=True, targetsRun=False, runtimeComponents=selected,
        runtimeChain=[pin(path) for path in chain],
        inputs=[pin(a.source), pin(a.runtime / 'runtime.c'), pin(base_path),
                pin(Path(__file__)), pin(omission_path),
                *[pin(path) for path in paths.values()],
                *[pin(path) for path in template_paths + override_paths]],
        invariant='Every payload field in an admitted dynamic binary constructor is fixed by rfc_seal',
        preservation='Public/trusted constructor and fallback writers seal both inputs; private rebuild seals new external input and transfers the already-sealed retained input; Take2 transfers without mutation of live children; Keep/Sink never write live payload fields',
        exclusions=['static shell, including count1 RFC redirect, before fast mutation',
                    'fabricated native Terms, arbitrary heap writers, concurrent mutation',
                    'unknown runtime components or changed private regeneration templates'],
        limitation='This authenticates the experimental source premises; it is not a mechanized C heap or whole-compiler proof',
        controls=controls)
    out.mkdir(parents=True)
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record))


if __name__ == '__main__':
    main()
