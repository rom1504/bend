#!/usr/bin/env python3
"""Exact source admission for reviewed Word/selector adapters; runs no target."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/build/phase111/full-source05/compiler.bend'
BASE_SHA = '825cb03276c30a944ef1b1e8ed0624531253d2f39a502b0fcbfbfea3f3bb3f44'
MODULES = {
    'word': [
        ('word-pattern/original.bend', '526b1531863283a30b9f16970cd6573522e7877bbba24bc3800f5ce3d5063f09'),
        ('word-pattern/emit.bend', '6a51fea7589656439fd21da25b4492c004ad5440790c52c1d7e9bb36c0b74a27'),
        ('word-pattern/entry.bend', 'b8df79f6c06c4219f970953a9a278ebda4acdc3761112b2add67df6b424c5cba'),
    ],
    'selector': [
        ('selectors/original.bend', '635dd410b33156beab3cf16af56dc7fa2247ce5f78698ad56bf6b73170f17c77'),
        ('selectors/emit.bend', '9e24d5480b60d784f45a3af5ef7fc14ff673cbaa4ebaaac484e49451d06ed91b'),
        ('selectors/entry.bend', '6bcc58b69ae4a0ec628ab28f7c2a76833aa67398c2d96dc639f5d52c898cb8b5'),
    ],
}
DECL = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
PREFIXES = ('p112m_', 'p112b_', 'nw_', 'NW_', 'nd_', 'nbc_')
HOOKS = ('p111_match_apply', 'p111_ref_app')
VERIFIER_HOOK = 'p111_verify_program'


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=digest(raw))


def checked(path, expected):
    raw = path.read_bytes()
    if digest(raw) != expected:
        raise ValueError('Reviewed input changed: ' + str(path))
    return raw.decode()


def code(text):
    # Composer boundary comments may move. Preserve code, indentation, strings
    # and inline comments; only full-line comments/blank lines are omitted.
    return '\n'.join(line.rstrip() for line in text.splitlines()
                     if line.strip() and not line.lstrip().startswith('#'))


def declarations(text):
    matches = list(DECL.finditer(text))
    result = {}
    for i, match in enumerate(matches):
        key = match.group(1), match.group(2)
        if key in result:
            raise ValueError('Duplicate declaration: ' + repr(key))
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        result[key] = code(text[match.start():end])
    return result


def expected_source(profile):
    baseline = declarations(checked(BASE, BASE_SHA))
    # Bind the entire mature declaration set, rather than guessing a partial
    # nw/nd/nbc dependency closure. Phase111/112 lowering/emission extensions
    # have their own admission; original structured model/verifier stay pinned.
    expected = {key: value for key, value in baseline.items()
                if not key[1].startswith(('p111', 'p112', 'P111', 'P112', 'N111'))
                or key[1].startswith(('p111v_', 'N111', 'P111'))
                or key[1] in (*HOOKS, VERIFIER_HOOK)}
    paths = [BASE]
    selected = ['selector', 'word'] if profile == 'both' else [profile]
    for group in selected:
        for name, sha in MODULES[group]:
            path = HERE.parent / name
            expected.update(declarations(checked(path, sha)))
            paths.append(path)
    for group, original, hook in [('word', 'p112m_original_match_apply', HOOKS[0]),
                                  ('selector', 'p112b_original_ref_app', HOOKS[1])]:
        if group in selected:
            renamed = expected['def', original].replace('def ' + original + '(', 'def ' + hook + '(', 1)
            if renamed != baseline['def', hook]:
                raise ValueError('Reviewed generic fallback differs from frozen base: ' + original)
    return expected, paths


def validate(source, expected):
    actual = declarations(source)
    wrong = [key for key, body in expected.items() if actual.get(key) != body]
    extra = [key for key in actual if key[1].startswith(PREFIXES) and key not in expected]
    if wrong or extra:
        raise ValueError('Exact adapter/dependency mismatch: ' + repr((wrong + extra)[:20]))


def mutate(source, name, before, after):
    matches = list(DECL.finditer(source))
    selected = [(i, m) for i, m in enumerate(matches) if m.group(1) == 'def' and m.group(2) == name]
    if len(selected) != 1:
        raise ValueError('Missing mutation declaration: ' + name)
    i, match = selected[0]
    end = matches[i + 1].start() if i + 1 < len(matches) else len(source)
    body = source[match.start():end]
    if before not in body:
        raise ValueError('Mutation did not apply: ' + name)
    return source[:match.start()] + body.replace(before, after, 1) + source[end:]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--profile', choices=['word', 'selector', 'both'], default='both')
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase112'):
        raise ValueError('Use a fresh Phase112 receipt directory')
    expected, paths = expected_source(args.profile)
    paths = [Path(__file__), args.source, *paths]
    inputs = [pin(path) for path in paths]
    source = args.source.read_text()
    validate(source, expected)
    changes = [
        ('mature-word-depth', 'nw_walk', 'U32.is_eq(depth, 32)', 'U32.is_eq(depth, 31)'),
        ('mature-beta-variable', 'nd_beta', 'p98_tag_eq(arg, "Var")', 'p98_tag_eq(arg, "Lam")'),
        ('mature-selector-sharing', 'nbc_applicable', 'ix(body)), 1)', 'ix(body)), 2)'),
        ('original-verifier-entry', VERIFIER_HOOK, 'p111v_functions(segments,', 'p111v_functions([],')
    ]
    if args.profile in ('word', 'both'):
        changes += [
            ('word-final-hook', 'p111_match_apply', 'p112m_match_apply(', 'p112m_original_match_apply('),
            ('word-tail-escape', 'p112m_planned_row', 'Bool.not(nc_uses_has(uses,nc_id(U32.add(n,2))))', 'True{}'),
            ('word-high-bit-mask', 'p112m_mask', '4294967295', '2147483647'),
            ('word-fresh-reservation', 'p112m_planned', 'U32.add(n,3)', 'U32.add(n,2)'),
        ]
    if args.profile in ('selector', 'both'):
        changes += [
            ('selector-final-hook', 'p111_ref_app', 'p112b_ref_app(', 'p112b_original_ref_app('),
            ('selector-fresh-reservation', 'p112b_selected', 'U32.add(n,64)', 'U32.add(n,63)'),
            ('selector-known-arguments', 'p112b_guard', 'nd_comb_literal(args)', 'True{}'),
        ]
    refusals = []
    for label, name, before, after in changes:
        variant = mutate(source, name, before, after)
        try:
            validate(variant, expected)
        except ValueError as error:
            refusals.append(dict(name=label, refused=True, reason=str(error)))
        else:
            raise ValueError('Mutant admitted: ' + label)
    for label, suffix in [
        ('extra-word-helper', '\ndef p112m_unreviewed() -> U32:\n  0\n'),
        ('extra-selector-helper', '\ndef p112b_unreviewed() -> U32:\n  0\n'),
        ('duplicate-final-hook', '\n' + expected['def', HOOKS[0]] + '\n'),
    ]:
        try:
            validate(source + suffix, expected)
        except ValueError as error:
            refusals.append(dict(name=label, refused=True, reason=str(error)))
        else:
            raise ValueError('Mutant admitted: ' + label)
    report = dict(kind='phase112-word-selector-source-admission', complete=True,
                  targetsRun=False, profile=args.profile, source=pin(args.source), inputs=inputs,
                  exactDeclarations=len(expected), finalHooks=list(HOOKS),
                  declarationHashes={kind + ' ' + name: digest(body.encode())
                                     for (kind, name), body in expected.items()},
                  refusals=refusals,
                  scope='Exact reviewed modules, final hooks, original N111 model/verifier and frozen mature declarations; source mutations only.',
                  limitations=['Not an ownership proof or native semantic execution.',
                               'Other Phase111/112 lowering, backend profiles and runtime source/object need their own same-source admission and execution receipts.'])
    for item in inputs:
        if pin(item['file']) != item:
            raise ValueError('Input changed during admission: ' + item['file'])
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, declarations=len(expected), refusals=len(refusals))))


if __name__ == '__main__':
    main()
