#!/usr/bin/env python3
"""Freeze independent source challenges; no compiler or program execution."""
import datetime
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
TERM = 'selfhost/src/core/term.bend'
STRINGS = 'selfhost/tools/performance/phase88/strings/helpers.bend'


def pin(path):
    data = path.read_bytes()
    return dict(path=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def save(path, value):
    if path.exists():
        assert json.loads(path.read_text()) == value, path
        return
    with path.open('x') as stream:
        json.dump(value, stream, indent=2, ensure_ascii=False)
        stream.write('\n')


def case(identifier, kind, file, function, before, after, rationale,
         expression, result_type, expected, changed):
    return dict(id=identifier, kind=kind, file=file, function=function,
                before=before, after=after, expectedBehavior=rationale,
                witness=dict(expression=expression, returnType=result_type,
                             baselineValueBend=expected, challengeValueBend=changed),
                provenance=dict(classification='synthetic-semantic-fault' if kind == 'bad'
                                else 'equivalent-control',
                                selection='Maintained/helper source reasoning before Phase98 law bodies, finite cases, or outcomes.'))


def main():
    literal = 'KLiteral{"U32", 37, "retained", 13, 29}'
    child = 'KTerm{"Var", "x", 2147483649, 1, Nil{}, ["hidden"], 31, 47}'
    original_lambda = 'KLambda{"bound", 17, 2, [' + literal + '], ["A", "B"], 11, 53, False{}}'
    new_lambda = 'KLambda{"bound", 17, 2, [' + child + '], ["A", "B"], 11, 53, False{}}'
    generic_lambda = 'KTerm{"Lam", "bound", 17, 2, [' + child + '], ["A", "B"], 11, 53}'
    rows = [
        case('bad01-logical-literal-is-constructor', 'bad', TERM, 'core_literal',
             'def core_literal(+t: KTerm) -> Bool:\n  match t:\n    case KTerm{tag, name, id, quant, kids, removed, begin, end}: False{}\n    case KLambda{name, id, quant, kids, removed, begin, end, present}:\n      False{}\n    case KLiteral{kind, number, text, begin, end}: True{}',
             'def core_literal(+t: KTerm) -> Bool:\n  String.eq(tg(t), "Lit")',
             'Replacing a representation discriminator by its logical tag admits a generic KTerm tagged Lit as an actual literal. Arbitrary typed KTerm tags are part of this helper domain; no parser-reachability claim is made.',
             'core_literal(KTerm{"Lit", "U32", 7, 2, [' + literal + '], ["kept"], 13, 29})',
             'Bool', 'False{}', 'True{}'),
        case('bad02-lambda-observation-loses-variant', 'bad', TERM, 'k_with_children',
             '      KLambda{name, id, quant, newKids, removed, begin, end, present}',
             '      KTerm{"Lam", name, id, quant, newKids, removed, begin, end}',
             'Normalizing a lambda into the generic tag representation preserves tg/nm/ix/qt/ks but loses its constructor and explicit quantity-presence flag. A complete-value obligation must reject it even if an observation-only model accepts it.',
             'k_with_children(' + original_lambda + ', [' + child + '])',
             'KTerm', new_lambda, generic_lambda),
        case('bad03-equality-forgets-last-mismatch', 'bad', STRINGS, 'p88_string_eq_go',
             '    case SNil{} SNil{} result: result',
             '    case SNil{} SNil{} result: True{}',
             'Simultaneous end of input does not erase the carried comparison result; a mismatch on the last character must remain false.',
             'p88_string_eq("ax", "ay")', 'Bool', 'False{}', 'True{}'),
        case('bad04-order-forgets-earlier-mismatch', 'bad', STRINGS, 'p88_string_order_go',
             '    case SNil{} SCon{h, t} GT{}: GT{}',
             '    case SNil{} SCon{h, t} GT{}: LT{}',
             'A prior greater-than character decides lexicographic order even when that string ends first. Reapplying prefix length order after a mismatch is unsound.',
             'p88_string_order("b", "aa")', 'Cmp', 'GT{}', 'LT{}'),
        case('bad05-equality-truncates-characters', 'bad', STRINGS, 'p88_string_eq_go',
             '      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))',
             '      p88_string_eq_go(t1, t2, U32.is_eq(U32.and(Char.to_u32(h1), 255), U32.and(Char.to_u32(h2), 255)))',
             'A byte-width comparison shortcut aliases full-width Bend characters. U+0141 and U+0041 share their low byte but are distinct characters; no Unicode normalization premise is involved.',
             'p88_string_eq("Ł", "A")', 'Bool', 'False{}', 'True{}'),
        case('good01-reconstruct-literal-exactly', 'good', TERM, 'k_with_children',
             '    case KLiteral{kind, number, text, literalBegin, literalEnd}:\n      t',
             '    case KLiteral{kind, number, text, literalBegin, literalEnd}:\n      KLiteral{kind, number, text, literalBegin, literalEnd}',
             'Reconstructing every literal field yields the identical finite value. Pointer identity, allocation, reference-count operations and timing are not claimed equivalent.',
             'k_with_children(' + literal + ', [' + child + '])', 'KTerm', literal, literal),
        case('good02-character-equality-by-codepoint', 'good', STRINGS, 'p88_string_eq_go',
             '      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))',
             '      p88_string_eq_go(t1, t2, U32.is_eq(Char.to_u32(h1), Char.to_u32(h2)))',
             'Base defines Char.is_eq by comparing the exact U32 fields extracted by Char.to_u32. This keeps the entire character domain, unlike the low-byte fault.',
             '[p88_string_eq("Ł", "A"), p88_string_eq("Ł", "Ł"), p88_string_eq("ax", "ay")]',
             'List<&2, Bool>', '[False{}, True{}, False{}]', '[False{}, True{}, False{}]'),
    ]
    source_pins = {file: pin(ROOT / file) for file in [TERM, STRINGS]}
    for row in rows:
        source = (ROOT / row['file']).read_text()
        # The equality end-state text occurs in the order helper too; its exact
        # function header is part of this one recipe's authenticated span.
        if row['id'] == 'bad03-equality-forgets-last-mismatch':
            head = 'def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:\n  match a b same:\n'
            row['before'] = head + row['before']
            row['after'] = head + row['after']
        if row['id'] == 'good01-reconstruct-literal-exactly':
            begin = source.index('def k_with_children(')
            end = source.index('\n@unsafe\n', begin)
            body = source[begin:end]
            assert body.count(row['before']) == 1
            row['before'], row['after'] = body, body.replace(row['before'], row['after'], 1)
        assert source.count(row['before']) == 1, row['id']
        changed = source.replace(row['before'], row['after'], 1).encode()
        row.update(schema='phase98-independent-challenge-v1', source=source_pins[row['file']],
                   expectedOccurrences=1, line=source[:source.index(row['before'])].count('\n') + 1,
                   changedSourceSha256=hashlib.sha256(changed).hexdigest(),
                   changedSourceBytes=len(changed), admission='predicted well-typed; root must check',
                   domain='Finite typed helper values; pure extensional behavior only.', targetsRun=False)
        witness = row['witness']; stem = row['id'].replace('-', '_')
        path = HERE / (row['id'] + '.witness.bend')
        text = '# Append to an assembly containing the exact helper dependency closure.\n'
        for suffix, expression in [('actual', witness['expression']), ('baseline_expected', witness['baselineValueBend']), ('challenge_expected', witness['challengeValueBend'])]:
            text += '\n@unsafe\ndef p98_' + stem + '_' + suffix + '() -> ' + witness['returnType'] + ':\n  ' + expression + '\n'
        if path.exists():
            assert path.read_text() == text, path
        else:
            with path.open('x') as stream:
                stream.write(text)
        witness['source'] = pin(path)
        save(HERE / (row['id'] + '.json'), row)
    for file, record in source_pins.items():
        assert pin(ROOT / file) == record
    save(HERE / 'manifest.json', dict(schema='phase98-independent-challenges-v1',
         frozenAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
         commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
         method=pin(Path(__file__)), previousPreparation=pin(HERE/'preparation01.json'), sources=list(source_pins.values()),
         rationaleSource=pin(ROOT/'bend2/base.bend'),
         cases=[pin(HERE / (row['id'] + '.json')) for row in rows],
         counts=dict(bad=5, good=2), targetsRun=False,
         independence='No Phase98 law bodies, new cases/oracles, outcomes or candidate implementation inspected before freeze. Broad task and prior Phase96/97 results known; not rigorous blinding.',
         protocol='First run unchanged existing finite suites and frozen laws. Preserve outcomes; only then add these witnesses. Require helper admission before semantic rejection credit. Label proof-only, finite-only, both, neither and extraction gaps separately.'))


if __name__ == '__main__':
    main()
