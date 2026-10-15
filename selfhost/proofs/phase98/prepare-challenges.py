#!/usr/bin/env python3
"""Prepare candidate-only independent challenges against accepted frozen laws."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CHALLENGES = ROOT / 'selfhost/tools/laws/phase98/challenge'
CHECKER = ROOT / 'selfhost/tools/laws/phase98/check.py'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--proof-report', type=Path, required=True)
    parser.add_argument('--kind', choices=['held', 'literal', 'dispatch'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT) and not out.exists()
    accepted = json.loads(args.proof_report.read_text())
    assert accepted['complete'] and accepted['independentlyChecked'] and not accepted['opaqueDefinitions']
    frozen = {}
    for row in accepted['sourceClosure']:
        assert pin(row['snapshot']['file']) == row['snapshot']
        name = Path(row['origin']['file']).name
        assert name not in frozen
        frozen[name] = Path(row['snapshot']['file']).read_bytes()
    entry_name = Path(accepted['source']['file']).name
    assert entry_name in frozen and 'candidate.bend' in frozen
    assert b'law ' not in frozen['candidate.bend'] and b'@unsafe' not in frozen['candidate.bend']
    selected = dict(held=['bad03-equality-forgets-last-mismatch', 'bad05-equality-truncates-characters',
                          'bad08-held-observation-repeats-left', 'good02-character-equality-by-codepoint'],
                    literal=['bad06-literal-recognizer-accepts-prefix'],
                    dispatch=['bad07-dispatch-loses-alternative'])[args.kind]
    out.mkdir(parents=True)
    cases, jobs = [], []

    def job(name, folder, entry, expected, purpose, requires=(), independent=False):
        check_out = out/'checks'/name
        command = [sys.executable, '-B', str(CHECKER), '--source', str(folder/entry), '--out', str(check_out)]
        if not independent: command.append('--source-only')
        jobs.append(dict(name=name, source=pin(folder/entry), expectedExit=expected,
                         purpose=purpose, requires=list(requires), independentKernel=independent,
                         command=command, evidence=str(check_out/'report.json')))

    for name in selected:
        spec_path = CHALLENGES/(name+'.json'); spec = json.loads(spec_path.read_text())
        source = ROOT/spec['source']['path']
        original_pin = pin(source)
        assert original_pin['bytes'] == spec['source']['bytes'] and original_pin['sha256'] == spec['source']['sha256']
        before, after = spec['before'], spec['after']
        adaptation = 'identity'
        if name.startswith('bad08'):
            before, after = [text.replace('p98_eq_walk(', 'p88_string_eq_go(') for text in (before, after)]
            adaptation = 'private walker call name p98_eq_walk -> actual full-candidate p88_string_eq_go; all other mutation bytes unchanged'
        elif args.kind == 'dispatch':
            before, after = [text.replace('String.eq(', 'p88_string_eq(') for text in (before, after)]
            adaptation = 'canonical String.eq -> frozen D04 p88_string_eq bridge; all other mutation bytes unchanged'
        body = frozen['candidate.bend'].decode()
        assert body.count(before) == 1, name
        folder = out/name; folder.mkdir()
        for filename, data in frozen.items(): (folder/filename).write_bytes(data)
        (folder/'candidate.bend').write_text(body.replace(before, after, 1))
        (folder/'challenge.json').write_bytes(spec_path.read_bytes())
        helper = name+'-helper'; law = name+'-law'
        job(helper, folder, 'candidate.bend', 0, 'safe law-free helper admission')
        job(law, folder, entry_name, 1 if spec['kind']=='bad' else None,
            'unchanged law semantic rejection' if spec['kind']=='bad' else 'maintenance observation; a proof failure is not a semantic fault', [helper])
        case = dict(id=name, kind=spec['kind'], independentSpec=pin(spec_path), adaptation=adaptation,
                    before=before, after=after, candidate=pin(folder/'candidate.bend'),
                    frozenLawsUnchanged=True, contract=spec['expectedBehavior'])
        if name.startswith('good02'):
            repaired = out/(name+'-maintained'); repaired.mkdir()
            for path in folder.iterdir(): (repaired/path.name).write_bytes(path.read_bytes())
            proof = repaired/entry_name
            old = '      held_walk_equal(at, bt, Char.is_eq(ah, bh))'
            new = '      match ah bh:\n        case Chr{av} Chr{bv}:\n          held_walk_equal(at, bt, U32.is_eq(av, bv))'
            text = proof.read_text(); assert text.count(old) == 1
            proof.write_text(text.replace(old, new, 1))
            # The exercise only repairs the representation-sensitive support
            # lemma body. Public theorem statements and bodies stay frozen.
            case['maintenance'] = dict(beforeSupportBody=old, afterSupportBody=new,
                                       unchangedPublicContracts=True, proof=pin(proof))
            job(name+'-maintained', repaired, entry_name, 0,
                'equivalent production helper refactor with one support-proof repair; full independent kernel check', [helper], independent=True)
        cases.append(case)
    (out/'prepare-challenges.py').write_bytes(Path(__file__).read_bytes())
    manifest = dict(schema='phase98-independent-formal-challenge-plan-v1', targetsRun=False,
                    kind=args.kind, acceptedProof=pin(args.proof_report), checker=pin(CHECKER), method=pin(__file__),
                    frozenSourceClosure=accepted['sourceClosure'], cases=cases, jobs=jobs,
                    files=[pin(path) for path in sorted(out.rglob('*.bend'))],
                    interpretation=['Run serially and admit each law-free helper before interpreting its law result.',
                                    'Only a normal source-check failure with expected/observed semantic mismatch counts as law detection; syntax, usage, resource and import failures do not.',
                                    'Source-check rejection is not independent kernel rejection.',
                                    'Good02 unchanged-proof outcome is observed, never counted as a bad optimization. Its maintained proof must independently pass.',
                                    'Bad08 violates the complete observation result; its public Bool can remain correct.'])
    (out/'plan.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(out=str(out), cases=len(cases), jobs=len(jobs), targetsRun=False)))


if __name__ == '__main__':
    main()
