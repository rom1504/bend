#!/usr/bin/env python3
"""Extract actual borrowed argument assembly; prepare three laws, run no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
EXTRACTOR = ROOT / 'selfhost/proofs/phase98/prepare-current.py'
SOURCE_SHA = '3a3d9c098fc8d091e0fde08f2b02a54e6fe96e5e0705ca8195144acb4cae5ccb'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(HERE) and not out.exists()
    assert pin(args.source)['sha256'] == SOURCE_SHA
    spec = importlib.util.spec_from_file_location('phase98_extract', EXTRACTOR)
    extractor = importlib.util.module_from_spec(spec); spec.loader.exec_module(extractor)
    source = args.source.read_text(); table = extractor.declarations(source)
    names = ['KTerm', 'kt', 'atom', 'ks', 'k_with_children', 'nt_choose',
             'p88_string_eq_go', 'p98_eq_finish', 'p88_string_eq',
             'p98_tag_eq_read', 'p98_tag_eq_finish', 'p98_tag_eq', 'nob_words_cons']
    records = []
    for name in names:
        original = extractor.unique(table, name)
        body = original.removeprefix('@unsafe\n')
        assert '@unsafe' not in body
        records.append(dict(name=name, original=original, extracted=body,
                            removedUnsafe=original != body,
                            extractedSha256=hashlib.sha256(body.encode()).hexdigest()))
    assert 'nob_words_cons(nob_arg_word(' in extractor.unique(table, 'nob_arg_words')
    positive = 'import Base\n\n' + ''.join(r['extracted'] for r in records)
    helper = records[-1]['extracted']
    mutations = {
        'bad-head': ('Bool.not(p98_tag_eq(word, "Absent")) && p98_tag_eq(rest, "NO_Args")',
                     'p98_tag_eq(rest, "NO_Args")'),
        'bad-tail': ('Bool.not(p98_tag_eq(word, "Absent")) && p98_tag_eq(rest, "NO_Args")',
                     'Bool.not(p98_tag_eq(word, "Absent"))'),
        'bad-order': ('Con{word, ks(rest)}', 'List.append(&2, KTerm, ks(rest), [word])'),
    }
    bodies = {'positive': positive}; mutation_records = []
    for role, (old, new) in mutations.items():
        assert helper.count(old) == 1
        changed = helper.replace(old, new)
        bodies[role] = positive[:-len(helper)] + changed
        mutation_records.append(dict(role=role, helper='nob_words_cons', old=old, new=new))
    assert len(set(bodies.values())) == 4
    template = HERE / 'borrowed-args-laws.template.bend'; laws = template.read_text()
    out.mkdir(parents=True); rows = []
    for role, body in bodies.items():
        folder = out / role; folder.mkdir()
        (folder / 'candidate.bend').write_text(body)
        (folder / 'laws.bend').write_text(laws)
        rows.append(dict(role=role, helper=pin(folder/'candidate.bend'),
                         laws=pin(folder/'laws.bend'), expectedStandaloneAdmission='accept',
                         expectedLawCheck='accept' if role == 'positive' else 'reject',
                         status='prepared; unexecuted'))
    report = dict(kind='phase99-borrowed-argument-law-preparation', complete=True,
                  targetsRun=False, source=pin(args.source), method=pin(__file__),
                  extractor=pin(EXTRACTOR), template=pin(template), declarations=records,
                  actualCaller=extractor.unique(table, 'nob_arg_words'), mutations=mutation_records,
                  rows=rows,
                  scope='Three source value contracts for actual nob_words_cons: prepend order, rejected-head propagation, rejected-tail propagation. No abstract substitute for production helpers.',
                  limits=['Only leading unsafe annotations removed; independent safe admission remains required.',
                          'Does not prove that supplied words have valid types/ancestry, full-list arity, registry authenticity, native demand, RC or lifetime safety.',
                          'Positive source checking, safe elaboration and independent kernel acceptance remain separate gates.',
                          'Each mutant must first pass standalone source admission; unchanged laws must then reject.'])
    (out/'manifest.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(manifest=pin(out/'manifest.json'), targetsRun=False)))


if __name__ == '__main__':
    main()
