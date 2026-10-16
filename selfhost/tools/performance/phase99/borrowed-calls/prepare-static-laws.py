#!/usr/bin/env python3
"""Extract the actual all-trivial predicate emitter and three laws; no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
EXTRACTOR = ROOT / 'selfhost/proofs/phase98/prepare-current.py'
SOURCE_SHA = 'c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(HERE) and not out.exists()
    before = pin(args.source); assert before['sha256'] == SOURCE_SHA
    spec = importlib.util.spec_from_file_location('phase98_extract', EXTRACTOR)
    extractor = importlib.util.module_from_spec(spec); spec.loader.exec_module(extractor)
    table = extractor.declarations(args.source.read_text())
    names = ['N_WordKind', 'N_Param', 'nt_choose', 'no_root_index', 'no_all_trivial_roots']
    records = []
    for name in names:
        original = extractor.unique(table, name)
        body = original.removeprefix('@unsafe\n'); assert '@unsafe' not in body
        records.append(dict(name=name, original=original, extracted=body,
                            removedUnsafe=original != body,
                            extractedSha256=hashlib.sha256(body.encode()).hexdigest()))
    caller = extractor.unique(table, 'no_scalar_redirect')
    assert 'no_shared_roots(params, roots, 0) ++ ") || (" ++ no_all_trivial_roots(params, roots, 0)' in caller
    positive = 'import Base\n\n' + ''.join(r['extracted'] for r in records)
    helper = records[-1]['extracted']
    mutations = {
        'bad-any-trivial': ('") && "', '") || "'),
        'bad-tail-false': ('case Nil{}: "1"', 'case Nil{}: "0"'),
        'bad-scalar-included': ('no_root_index(roots, i)', 'True{}'),
    }
    bodies = {'positive': positive}; edits = []
    for role, (old, new) in mutations.items():
        assert helper.count(old) == 1, (role, old)
        bodies[role] = positive[:-len(helper)] + helper.replace(old, new)
        edits.append(dict(role=role, helper='no_all_trivial_roots', old=old, new=new))
    assert len(set(bodies.values())) == 4
    template = HERE / 'static-laws.template.bend'; laws = template.read_text()
    out.mkdir(parents=True); rows = []
    for role, body in bodies.items():
        folder = out / role; folder.mkdir()
        (folder / 'candidate.bend').write_text(body); (folder / 'laws.bend').write_text(laws)
        rows.append(dict(role=role, helper=pin(folder / 'candidate.bend'),
                         laws=pin(folder / 'laws.bend'), expectedStandaloneAdmission='accept',
                         expectedLawCheck='accept' if role == 'positive' else 'reject',
                         status='prepared; unexecuted'))
    assert pin(args.source) == before
    report = dict(kind='phase99-all-trivial-guard-law-preparation', complete=True,
                  targetsRun=False, source=before, method=pin(__file__),
                  extractor=pin(EXTRACTOR), template=pin(template), declarations=records,
                  actualCaller=caller, mutations=edits, rows=rows,
                  scope='Actual predicate emitter: both roots conjoined, non-root scalar skipped, empty fold tail true. The caller is authenticated separately.',
                  limits=['Only leading unsafe annotations removed; standalone safe admission and independent proof checks remain unexecuted.',
                          'Empty-fold identity is internal: admitted production schemas still require one or two roots.',
                          'No proof of C runtime term_triv, native lifetime, source-to-C meaning, authority or performance.',
                          'Mutants must first pass safe helper admission; only then does law rejection count.'])
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(manifest=pin(out / 'manifest.json'), targetsRun=False)))


if __name__ == '__main__':
    main()
