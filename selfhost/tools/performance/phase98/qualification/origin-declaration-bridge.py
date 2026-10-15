#!/usr/bin/env python3
"""Offline bind the one-function origin termination correction to parent permission evidence."""
import argparse
import hashlib
import json
from pathlib import Path
from support import Bindings, S, backend_policy, freeze_methods, module, pin, read


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['parent-controls', 'backend-policy', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); freeze_methods(out, b)
    report = dict(kind='phase98-origin-guard-declaration-bridge', complete=False, inputsUnchanged=False,
                  targetsRun=False, imageQualified=False, wholeCompilerProved=False, method=pin(__file__))
    try:
        parent_pin = b.bind(a.parent_controls); parent = read(parent_pin['file']); b.tree(parent)
        assert parent['kind'] == 'phase98-backend-specific-qualification'
        assert parent['complete'] and parent['passed'] and parent['inputsUnchanged'] and not parent.get('error')
        assert parent['imageQualified'] is False and len(parent['rows']) == 29
        policy = read(a.backend_policy); source = b.bind(policy['source']); policy_pin = backend_policy(a.backend_policy, source, b)
        recipe_pin = b.bind(policy['recipe']); recipe = read(recipe_pin['file']); b.tree(recipe)
        assert recipe['complete'] and recipe['candidate'] == source and recipe['parentSource'] == parent['source']
        old = Path(parent['source']['file']).read_text(); new = Path(source['file']).read_text()
        def replay(text, edits):
            for edit in edits:
                at, before, after = edit['offset'], edit['old'], edit['new']
                assert isinstance(at, int) and 0 <= at <= len(text) and at + len(before) <= len(text)
                assert text[at:at+len(before)] == before
                text = text[:at] + after + text[at+len(before):]
            return text
        assert replay(Path(recipe['source']['file']).read_text(), recipe['changes']) == new
        assert replay(old, recipe['localChanges']) == new and len(recipe['localChanges']) == 1
        assert recipe['localChanges'][0]['function'] == 'noa_below'
        inverse = [dict(offset=edit['offset'], old=edit['new'], new=edit['old']) for edit in reversed(recipe['localChanges'])]
        assert replay(new, inverse) == old
        prior_pin = b.bind(parent['finalCompositionBridge']); prior = read(prior_pin['file']); b.tree(prior)
        assert prior['source'] == parent['source'] and recipe['parentRecipe'] == prior['candidateRecipe']
        declarations = module('phase98_origin_declarations', prior['method']['file']).declarations
        before, after = declarations(old), declarations(new)
        assert set(before) == set(after)
        assert [name for name in before if before[name] != after[name]] == ['noa_below']
        change = recipe['localChanges'][0]
        assert before['noa_below'] == change['old'] and after['noa_below'] == change['new']
        # Pin the intended lazy guard itself, not merely a changed function name.
        assert after['noa_below'] == ('@unsafe\ndef noa_below(+origin: KTerm, +want: KTerm) -> Bool:\n'
            '  nt_choose(Bool, norm_exact(origin, want), u => True{}, u =>\n'
            '    nt_choose(Bool, p98_tag_eq(origin, "OField"), v => noa_below(kid(origin, 0), want), v => False{}))\n')
        exact = []
        for row in prior['exactPermissionDeclarations']:
            text = after[row['name']]; assert row['exact'] and text == before[row['name']]
            assert len(text.encode()) == row['bytes'] and hashlib.sha256(text.encode()).hexdigest() == row['sha256']
            exact.append(row)
        assert len(exact) == 16
        closures = []
        for proof_key, manifest_key in [('finalPermissionProof', 'finalPermissionProofManifest'), ('finalTagProof', 'finalTagProofManifest')]:
            proof = read(prior[proof_key]['file']); manifest = read(prior[manifest_key]['file'])
            assert proof['complete'] and proof['independentlyChecked'] and not proof['sourceOnly'] and proof['opaqueDefinitions'] == []
            assert manifest['candidate'] == parent['source']
            for row in manifest['candidateDefinitions']: assert new.count(row['original']) == 1
            closures.append(dict(proof=prior[proof_key], manifest=prior[manifest_key], exactDefinitions=len(manifest['candidateDefinitions']), independentRecheckPerformed=False))
        b.unchanged()
        report.update(complete=True, inputsUnchanged=True, source=source, parentSource=parent['source'],
            parentBackendControls=parent_pin, priorDeclarationBridge=prior_pin, backendPolicy=policy_pin,
            candidateRecipe=recipe_pin, exactPermissionDeclarations=exact, inheritedSafeClosures=closures,
            changedDeclarations=[dict(name='noa_below', before=before['noa_below'], after=after['noa_below'])],
            unchangedDeclarations=len(before)-1, addedDeclarations=[],
            scope='Exact source lineage and unchanged permission/safe-helper closures only. The old eager helper diverges on nonmatching nonfields, so this is a termination correction, not old/new universal helper equivalence. New finite origin decisions, valid swapping-program behavior, final-source proof where available, and actual final native-image gates remain separate obligations. No redirect or cached-schema cost edits are present.')
    except BaseException as error:
        report.update(complete=False, error=repr(error)); raise
    finally:
        report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    print(json.dumps(dict(complete=True, targetsRun=False, imageQualified=False, changed='noa_below', report=str(out / 'report.json'))))


if __name__ == '__main__': main()
