#!/usr/bin/env python3
"""Prepare the five-definition lexer experiment; metadata only, no compiler jobs."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
import source
from common import changed_inputs, fresh_output, pin, require, write_json

PAIRS = [('p150l_word', 'p170ls_word', 's'),
         ('p150l_other', 'p170ls_other', 'rest'),
         ('p150l_symbol', 'p170ls_symbol', 'rest'),
         ('p150l_plus_at', 'p170ls_plus', 'rest'),
         ('p150l_greater_at', 'p170ls_greater', 'rest')]


def declaration(item):
    return item['data'][item['headerOffset'] - item['offset']:]


def body(item):
    text = declaration(item).decode()
    if text.startswith('@unsafe\n'):
        text = text[len('@unsafe\n'):]
    return text.split('\n', 1)[1].strip()


def prepare(a):
    baseline = pin(a.source)
    overlay = pin(a.overlay)
    recipe = pin(a.canonical_manifest)
    canonical = source.maintained_assemble(a.canonical_manifest, a.module_root, a.profile)
    old = Path(baseline['file']).read_bytes()
    require(old == canonical, 'Frozen source differs from the maintained canonical profile')
    prefix, original = source.blocks(old)
    patch_prefix, edits = source.blocks(Path(overlay['file']).read_bytes())
    require(not patch_prefix, 'Overlay has unassigned bytes')
    old_by_key = {(x['kind'], x['name']): x for x in original}
    edit_by_key = {(x['kind'], x['name']): x for x in edits}
    names = [name for pair in PAIRS for name in pair[:2]]
    require(len(edit_by_key) == len(edits) == 10 and set(edit_by_key) == {('def', n) for n in names},
            'Exactly five wrappers and five private helpers required')
    require(len(old_by_key) == len(original), 'Duplicate original declaration')
    checks = []
    for old_name, helper, suffix in PAIRS:
        original_item = old_by_key[('def', old_name)]
        helper_item = edit_by_key[('def', helper)]
        require(('def', helper) not in old_by_key, 'Helper name already exists')
        # The only changed body operation is returning a separately retained
        # equal suffix. Substituting both helper parameters recovers the old body.
        restored = re.sub(r'\b(inspected|original)\b', suffix, body(helper_item))
        require(restored == body(original_item), 'Helper changed lexical operations: ' + helper)
        wrapper = body(edit_by_key[('def', old_name)])
        parameters = ('s,s,acc,n,last' if suffix == 's' else
                      'head,rest,rest,l,c,d,acc,offset,previous' if old_name in ('p150l_other', 'p150l_symbol') else
                      'rest,rest,l,c,d,acc,offset,previous,' + ('contiguous' if old_name == 'p150l_plus_at' else 'gap'))
        require(wrapper == helper + '(' + parameters + ')', 'Wrapper does not preserve equal suffixes')
        before = declaration(original_item).split(b'\n')[:2]
        after = declaration(edit_by_key[('def', old_name)]).split(b'\n')[:2]
        require(before == after, 'Original signature/annotation changed: ' + old_name)
        checks.append(dict(name=old_name, helper=helper, suffix=suffix,
                           bodyAfterEqualSuffixSubstitutionExact=True, signatureExact=True))
    pieces, replacements, position = [prefix], [], len(prefix)
    replace_names = {pair[0] for pair in PAIRS}
    for item in original:
        data = item['data']
        if item['kind'] == 'def' and item['name'] in replace_names:
            preceding = data[:item['headerOffset'] - item['offset']]
            replacement = preceding + declaration(edit_by_key[('def', item['name'])]).rstrip() + b'\n'
            replacements.append(dict(name=item['name'], offset=position, newBytes=len(replacement),
                                     oldBytes=data, newSha256=hashlib.sha256(replacement).hexdigest()))
            data = replacement
        pieces.append(data)
        position += len(data)
    altered = b''.join(pieces)
    inverse = altered
    for row in reversed(replacements):
        begin = row['offset']
        inverse = inverse[:begin] + row['oldBytes'] + inverse[begin + row['newBytes']:]
    require(inverse == old, 'Inverse replacement did not recover exact original source')
    helpers = b'\n' + b'\n'.join(declaration(edit_by_key[('def', helper)]).strip() for _, helper, _ in PAIRS) + b'\n'
    candidate = altered + helpers
    _, final_items = source.blocks(candidate)
    require(len(final_items) == len(original) + 5 and
            {(x['kind'], x['name']) for x in final_items} == set(old_by_key) | {('def', p[1]) for p in PAIRS},
            'Unexpected candidate declaration inventory')
    fixture = pin(ROOT / 'selfhost/tests/phase150/lexer-probe.bend')
    inputs = [baseline, overlay, recipe, fixture, pin(__file__), pin(source.__file__)]
    out = fresh_output(a.out, ROOT)
    (out / 'compiler.bend').write_bytes(candidate)
    export_path = out / 'exports.json'
    write_json(export_path, dict(kind='bend-hosted-api-exports', version=1,
        protocol='hosted-api-v1', targets=['js'], preparationModes=['live'],
        exports=['f_lex_cursor', 'f_load_graph_trace'],
        scope='Checked lexer/loader experiment API only; no public compiler or target-emission capability claim.'))
    report = dict(kind='phase170-lexer-suffix-source', version=1, complete=True, targetsRun=False,
        baseline=baseline, candidate=pin(out / 'compiler.bend'), overlay=overlay,
        exports=pin(export_path), fixture=fixture, inputs=inputs,
        replacedDeclarations=[p[0] for p in PAIRS], addedDeclarations=[p[1] for p in PAIRS],
        unchangedDeclarations=len(original) - 5, baselineDeclarations=len(original),
        candidateDeclarations=len(final_items), inverseByteExact=True,
        allOtherOriginalBytesPreserved=True, equalSuffixBodyChecks=checks,
        replacements=[dict(name=r['name'], offset=r['offset'], newBytes=r['newBytes'],
                           oldSha256=hashlib.sha256(r['oldBytes']).hexdigest(), newSha256=r['newSha256']) for r in replacements],
        scope='Source transport and exact five-body audit. No typecheck, semantic equivalence, speed or promotion claim.')
    require(not changed_inputs(inputs), 'Preparation inputs changed')
    write_json(out / 'report.json', report)
    return report


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--overlay', type=Path, default=Path(__file__).with_name('lexer-suffix.bend'))
    p.add_argument('--canonical-manifest', type=Path, default=ROOT / 'selfhost/src/compiler.json')
    p.add_argument('--module-root', type=Path, default=ROOT / 'selfhost')
    p.add_argument('--profile', default='qbe')
    report = prepare(p.parse_args())
    print(json.dumps({k: report[k] for k in ('complete', 'targetsRun', 'baseline', 'candidate', 'exports', 'replacedDeclarations', 'addedDeclarations', 'inverseByteExact')}, indent=2))


if __name__ == '__main__':
    main()
