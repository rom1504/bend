#!/usr/bin/env python3
"""Freeze independently selected source challenges; no compiler/test execution."""
import datetime
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
SOURCES = ['core/term.bend', 'core/index.bend', 'back/native/uses.bend',
           'back/native/ir.bend', 'back/native/text.bend', 'back/native/identity.bend',
           'back/native/tables.bend', 'back/native/bridge.bend']


def pin(path):
    data = path.read_bytes()
    return dict(path=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def recipe(identifier, label, source, before, after, reason, witness, expected, changed,
           classification='synthetic-semantic-fault', domain='Finite well-typed helper data.'):
    return dict(id=identifier, label=label, classification=classification,
                source=source, before=before, after=after,
                rationale=reason, witness=dict(expression=witness, baselineExpected=expected,
                                               challengeExpected=changed), domain=domain,
                expectedDisposition='accept-equivalent' if classification == 'equivalent-control'
                else 'reject-semantic-change', executed=False)


def main():
    definitions = 'KDef{"%s", "%s", 0, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}'
    duplicates = '[' + ', '.join(definitions % x for x in [('x', 'old1'), ('y', 'keep'), ('x', 'old2')]) + ']'
    rows = [
        recipe('bad01-literal-span-payload', 'Span update resets a numeric literal payload',
            'core/term.bend',
            '      KLiteral{kind, number, text, newBegin, newEnd}',
            '      KLiteral{kind, 0, text, newBegin, newEnd}',
            'A structural updater rebuilt with a default numeric field silently changes a closed literal while updating only its source range.',
            'k_with_span(KLiteral{"U32", 37, "", 2, 4}, 11, 19)',
            'KLiteral{"U32", 37, "", 11, 19}',
            'KLiteral{"U32", 0, "", 11, 19}'),
        recipe('bad02-index-remove-first', 'Definition removal accidentally stops after the first match',
            'core/index.bend',
            '    case True{}: index_remove(rest, name)',
            '    case True{}: rest',
            'Replacing a filtering removal with an ordinary first-hit deletion leaves shadowed declarations behind. This deliberately contrasts the environment helper, whose contract really does remove only the first match.',
            'index_remove(' + duplicates + ', "x")',
            '[' + definitions % ('y', 'keep') + ']',
            '[' + definitions % ('y', 'keep') + ', ' + definitions % ('x', 'old2') + ']',
            domain='Finite KDef event lists; duplicate names are supported, not an invalid input assumption.'),
        recipe('bad03-membership-high-bit', 'Occurrence membership aliases distinct full-width binder IDs',
            'back/native/uses.bend',
            '    case NU_Leaf{stored}: U32.is_eq(stored, key)',
            '    case NU_Leaf{stored}: U32.is_eq(U32.and(stored, 2147483647), U32.and(key, 2147483647))',
            'Treating binder IDs as signed-safe 31-bit keys makes a plausible compact-key shortcut unsound. The compressed trie retains exact U32 keys.',
            'nu_has(NU_Leaf{1}, 2147483649)', 'False{}', 'True{}'),
        recipe('bad04-empty-chunk-separator', 'Empty join elements suppress their separator',
            'back/native/text.bend',
            '    case Con{h, t}: nt_join_chunks(t, sep, False{}, Con{h, Con{nt_choose(String, first, u => "", u => sep), acc}})',
            '    case Con{h, t}: nt_join_chunks(t, sep, False{}, Con{h, Con{nt_choose(String, first || String.eq(h, ""), u => "", u => sep), acc}})',
            'An empty payload is still an element. Skipping its separator during chunk optimization changes emitted text and list position.',
            'nt_join(["a", "", "b"], ",")', 'a,,b', 'a,b'),
        recipe('bad05-frame-pop-is-slots', 'Frame result width uses pop instead of captured-slot count',
            'back/native/tables.bend',
            '    case N_Frame{+pop, +at}: U32.sub(n, nt_count(String, at))',
            '    case N_Frame{+pop, +at}: U32.sub(n, pop)',
            'Frame metadata fields are not interchangeable. Replacing a list count with a convenient cached-looking scalar changes FID_RESW_T.',
            'nb_frame_results(N_Frame{1, ["saved0", "saved1"]}, 5)', 3, 4,
            domain='Finite typed N_Frame helper data. This is a direct helper witness, not a claim that the lowerer constructs this exact combination.'),
        recipe('bad06-environment-remove-all', 'Environment removal accidentally removes every duplicate ID',
            'back/native/bridge.bend',
            '      nt_choose(List<&2, NC_Binding>, U32.is_eq(at, id), u => rest, u => Con{NC_Binding{at, word, kind}, nc_remove_env(rest, id)})',
            '      nt_choose(List<&2, NC_Binding>, U32.is_eq(at, id), u => nc_remove_env(rest, id), u => Con{NC_Binding{at, word, kind}, nc_remove_env(rest, id)})',
            'A generic filtering rewrite changes this ordered environment operation from remove-first to remove-all, unlike index_remove. Full binding words and kinds after the first match must survive.',
            'nc_remove_env([NC_Binding{7, "first", N_Box{}}, NC_Binding{8, "middle", N_W32{}}, NC_Binding{7, "second", N_W64{}}], 7)',
            '[NC_Binding{8, "middle", N_W32{}}, NC_Binding{7, "second", N_W64{}}]',
            '[NC_Binding{8, "middle", N_W32{}}]',
            domain='Finite typed helper environments including repeated IDs. No claim that every checked source lowering produces duplicates.'),
        recipe('bad07-noncanonical-constructor-display', 'Display accepts noncanonical decimal constructor escapes',
            'back/native/identity.bend',
            '      kc(String, U32.is_eq(digits, 0) && String.eq(nc_ctor_encode(out), original), u => out, u => original)',
            '      kc(String, U32.is_eq(digits, 0), u => out, u => original)',
            'Dropping the apparent redundant re-encoding check accepts leading-zero encodings that were not produced by the encoder, changing fallback display of reserved-looking names.',
            'nc_ctor_display("$ctor.065_")', '$ctor.065_', 'A'),
        recipe('bad08-historical-fid-collision', 'Restore the actual historical C identifier collision',
            'back/native/text.bend',
            '  "FID_" ++ nc_ctor_codes(k)',
            '  "FID_" ++ String.to_upper(nt_clean(k))',
            'This exact previous helper expression conflates source names after case folding and punctuation cleanup, so distinct function segments can share a C macro.',
            '[nt_fid("foo"), nt_fid("Foo"), nt_fid("a.b"), nt_fid("a_b")]',
            ['FID_102_111_111_', 'FID_70_111_111_', 'FID_97_46_98_', 'FID_97_95_98_'],
            ['FID_FOO', 'FID_FOO', 'FID_A_B', 'FID_A_B'],
            classification='historical-semantic-regression'),
        recipe('good01-direct-append', 'Use the direct recursive definition of finite list append',
            'back/native/text.bend',
            'def nt_append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:\n  nt_reverse(A, nt_reverse(A, xs, Nil{}), ys)',
            'def nt_append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:\n  match xs:\n    case Nil{}: ys\n    case Con{h, t}: Con{h, nt_append(A, t, ys)}',
            'Reversing a list into an empty accumulator then reversing it onto ys equals structural append by induction on xs. Values, order and duplicates remain unchanged; allocation/stack behavior may differ.',
            'nt_append(String, ["a", "", "a"], ["z"])', ['a', '', 'a', 'z'], ['a', '', 'a', 'z'],
            classification='equivalent-control',
            domain='Extensional equality for finite lists of Data values; no pointer identity, stack-use or performance equivalence claim.'),
        recipe('good02-lowest-bit-algebra', 'Isolate the lowest set bit with xor after clearing it',
            'core/index.bend',
            '  U32.and(diff, U32.sub(0, diff))',
            '  U32.xor(diff, U32.and(diff, U32.sub(diff, 1)))',
            'For nonzero unsigned x, x & (x-1) clears exactly its lowest set bit; xor with x restores exactly that bit. Both expressions give zero at x=0 under U32 wraparound.',
            '[index_split_bit(0), index_split_bit(1), index_split_bit(12), index_split_bit(2147483648), index_split_bit(4294967295)]',
            [0, 1, 4, 2147483648, 1], [0, 1, 4, 2147483648, 1],
            classification='equivalent-control', domain='All 2^32 U32 values; arithmetic wraps modulo 2^32.'),
    ]
    functions = ['k_with_span', 'index_remove_step', 'nu_has', 'nt_join_chunks', 'nb_frame_results',
                 'nc_remove_env', 'nc_ctor_decode', 'nt_fid', 'nt_append', 'index_split_bit']
    returns = ['KTerm', 'List<&2,KDef>', 'Bool', 'String', 'U32', 'List<&2,NC_Binding>',
               'String', 'List<&2,String>', 'List<&2,String>', 'List<&2,U32>']
    require_new = [HERE / (row['id'] + suffix) for row in rows for suffix in ['.json', '.witness.bend']]
    require_new += [HERE / 'manifest.json', HERE / 'historical-fid-fix.patch']
    if any(p.exists() for p in require_new):
        raise RuntimeError('Frozen challenge output already exists; do not overwrite it.')
    sources = {name: ROOT / 'selfhost/src' / name for name in SOURCES}
    source_pins = {name: pin(path) for name, path in sources.items()}
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    fix = '5350b2fec8f6f8484c7a689e915b359d7ce86847'
    parent = 'dcae30ca0a3ea940dfc3edd1cb93c26db0f02696'
    historical_paths = ['selfhost/src/back/native/text.bend', 'selfhost/src/back/native/tables.bend']
    patch = subprocess.check_output(['git', 'diff', parent, fix, '--'] + historical_paths, cwd=ROOT)
    with (HERE / 'historical-fid-fix.patch').open('xb') as stream:
        stream.write(patch)
    history = dict(fixCommit=fix, parentCommit=parent,
        title='selfhost: reduce lookup overhead and fix emission name collisions', date='2026-09-29',
        patch=pin(HERE / 'historical-fid-fix.patch'),
        beforeTextBlob='187331222f7b66bd23e058dd6423caaa7c6ffd34',
        afterTextBlob='285559c4920c0e51a6d815e85240ca0b5f4c7e0b',
        beforeTablesBlob='aa3ddd6f678d17ad63dff8f9b3ec058ad1a659cb',
        afterTablesBlob='9829088608b67d44d2f76a11d3150898e13d7245',
        applicability='Exact old nt_fid expression remains a one-line semantic regression on current helpers. Current MAIN_FID already delegates to nt_fid; no table edit is needed to reproduce collisions.',
        witnessProvenance='Witness names are newly derived from helper behavior, not claimed to be the original historical test cases.')
    entries = []
    for row, function, return_type in zip(rows, functions, returns):
        name, before, after = row.pop('source'), row.pop('before'), row.pop('after')
        source = sources[name].read_text()
        if source.count(before) != 1 or before == after:
            raise RuntimeError('Edit is not unique and nonempty: ' + row['id'])
        changed = source.replace(before, after, 1).encode()
        row['schema'] = 'phase97-independent-challenge-recipe-v1'
        row.update(kind=('good' if row['classification'] == 'equivalent-control' else
                         'historical' if row['classification'] == 'historical-semantic-regression' else 'bad'),
                   file=source_pins[name]['path'], function=function, before=before, after=after,
                   expectedBehavior=row['rationale'])
        row['edits'] = [dict(source=source_pins[name], before=before, after=after,
                             expectedOccurrences=1, line=source[:source.index(before)].count('\n') + 1,
                             changedSourceSha256=hashlib.sha256(changed).hexdigest(), changedSourceBytes=len(changed))]
        if row['classification'] == 'historical-semantic-regression':
            row['historicalProvenance'] = history
        row['provenance'] = history if row['kind'] == 'historical' else dict(
            classification=row['classification'], selection='Independent maintained-source reasoning before suite results.')
        witness = row['witness']
        def bend_value(value):
            if return_type == 'String' or isinstance(value, list):
                return json.dumps(value, ensure_ascii=False)
            return str(value)
        witness.update(returnType=return_type,
                       baselineValueBend=bend_value(witness['baselineExpected']),
                       challengeValueBend=bend_value(witness['challengeExpected']))
        stem = 'p97_' + row['id'].replace('-', '_')
        text = '# Source-reasoned witness; not executed. Append to an assembly containing its maintained helper dependencies.\n'
        for suffix, expression in [('_actual', witness['expression']),
                                   ('_baseline_expected', witness['baselineValueBend']),
                                   ('_challenge_expected', witness['challengeValueBend'])]:
            text += '\n@unsafe\ndef ' + stem + suffix + '() -> ' + return_type + ':\n  ' + expression + '\n'
        witness_path = HERE / (row['id'] + '.witness.bend')
        with witness_path.open('x') as stream:
            stream.write(text)
        witness['source'] = pin(witness_path)
        save(HERE / (row['id'] + '.json'), row)
        entries.append(dict(id=row['id'], classification=row['classification'],
                            recipe=pin(HERE / (row['id'] + '.json'))))
    for name, path in sources.items():
        if pin(path) != source_pins[name]:
            raise RuntimeError('Maintained input changed while freezing: ' + name)
    save(HERE / 'manifest.json', dict(schema='phase97-independent-challenge-manifest-v1',
        frozen=datetime.datetime.now(datetime.timezone.utc).isoformat(), sourceCommit=head,
        producer=pin(Path(__file__)), sourceInputs=list(source_pins.values()),
        badChallenges=8, equivalentControls=2, historicalChallenges=1, syntheticFaults=7,
        entries=entries, targetsExecuted=False, productionEdited=False,
        methodology=dict(selection='Read maintained helper implementations and restricted Git history before freezing this set.',
            excludedInputs=['Phase96 law bodies', 'Phase96 mutation recipes', 'Phase96 case corpus', 'Phase96 reference.py'],
            knownContext='Broad task, helper scope and high-level Phase96 totals in STEERING.md were known; this is independent selection, not rigorous blinding.',
            expectedOutputs='Source reasoning only. Witnesses have not been executed and no detection result is predicted.',
            historicalSearch='One exact defect found. No equally strong second historical match; synthetic faults stay labeled synthetic.',
            scoring='Root should keep type/extraction failures separate from semantic counterexamples, and good-control failures separate from bad-challenge detection. Do not tune recipes after seeing frozen-suite results.')))
    print(json.dumps(dict(manifest=pin(HERE / 'manifest.json'), recipes=len(entries), targetsExecuted=False)))


if __name__ == '__main__':
    main()
