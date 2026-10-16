#!/usr/bin/env python3
"""Offline successor: preserve Phase102 authority audit and verify bounded inline hints."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
HIST = ROOT / 'selfhost/build/phase98'
ANCHORS = {
    'origin-guard-source01/compiler.bend': '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051',
    'origin-backend-specific01/report.json': 'e8582897c947d957e104d3dac67a73c9bd65415a78301573d8516653fdcf8439',
    'origin-guard-declaration-bridge01/report.json': '4e31e9c9c5d5f998c81f8c8727e9c0b672f6574d65e8f4233403cb9e48d9f6b7',
    'combined-permission-proof-check01/report.json': '7961763cc40d9eb09075a51bef04b76d0301bbbfd0cc962f1efc1a75cdfd380b',
    'combined-permission-proof-source01/manifest.json': '4eb6f9df553d36d48b374bfa57c9908f9614d807a8e8a08dfda563c4244b5187',
    'combined-tag-proof-check01/report.json': '7fb03e2499e8156cbdf2b4fee2c123a43ba1ef365f2ecc1a5942b2297af8f270',
    'combined-tag-proof-source01/manifest.json': 'ce2c16eac140f6082f5266d386f43a394b1ef1bda36efbc9af37cc83bac57693',
}
CHANGED = set('nc_let_value nc_let_prefix_call nc_destructure nc_match_apply_hit_to '
              'nc_match_apply_join nc_lower_ctor_to nc_lower_live_to nd_ref_arity '
              'nf_candidate nf_inline nf_bodies nf_finish_ready nf_plan_scoped '
              'nq_transfer nc_finish ns_compile_named_scoped'.split())
ADDED = set('nbc_applicable nbc_call nbc_closed nbc_definition nbc_evaluate nbc_expand '
            'nbc_expand_match nbc_filled nbc_match_list nbc_matchable nbc_saturated '
            'nbc_select nbc_selected nbc_uses_list nf_scheduler_attach '
            'nf_scheduler_attach_index nf_scheduler_bind nf_scheduler_compile '
            'nf_scheduler_emitted nf_scheduler_host nf_scheduler_host_rev '
            'nf_scheduler_name nf_scheduler_payload nf_scheduler_segments '
            'nf_scheduler_selected nfo_admit nfo_alias_code nfo_alias_edges '
            'nfo_alias_worker nfo_aliases nfo_entries nfo_finish nfo_plan '
            'ntr_cache_helpers ntr_cache_needed ntr_cache_prelude '
            'ntr_cached_constructor ntr_candidate ntr_candidate_code ntr_ctor '
            'ntr_ctor_selected ntr_destructure_mode ntr_drop_words ntr_eligible '
            'ntr_emit ntr_emit_ready ntr_emitted ntr_last ntr_owner ntr_params '
            'ntr_plain_bodies ntr_plain_candidate ntr_plain_lower_live_to '
            'ntr_plain_transfer ntr_prefix ntr_refs ntr_retry ntr_sequence '
            'ntr_tail_eligible ntr_take_words ntr_target ntr_transfer '
            'ntr_worker_body'.split())
CHANGED.add('nf_prototypes')
ADDED.update({'nfi_deps', 'nfi_pass'})
AUTH_CHANGED = {'nf_plan_scoped', 'ns_compile_named_scoped'}
ROOTS = ['no_effect_definitions', 'no_effect_terms', 'ns_source', 'noa_below']
STRINGS_COMMENTS = re.compile(r'"(?:\\.|[^"\\])*"|#[^\n]*')
IDENTIFIER = re.compile(r'\b[A-Za-z_][\w.]*\b')


def digest(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), **digest(path.read_bytes()))


def declarations(source, kind='def'):
    result = {}
    pattern = r'(?m)^(?:@unsafe\n)?' + kind + r' ([A-Za-z_][\w.]*)\b[^\n]*\n'
    for match in re.finditer(pattern, source):
        end = source.find('\n\n', match.end())
        assert match[1] not in result, ('duplicate declaration', match[1])
        result[match[1]] = source[match.start():len(source) if end < 0 else end + 1]
    return result


def replay(text, changes, inverse=False):
    for row in reversed(changes) if inverse else changes:
        at = row['offset']
        old, new = (row['new'], row['old']) if inverse else (row['old'], row['new'])
        assert type(at) is int and 0 <= at <= len(text) and at + len(old) <= len(text)
        assert text[at:at + len(old)] == old, ('recipe mismatch', at)
        text = text[:at] + new + text[at + len(old):]
    return text


def graph(defs, types):
    bodies = {**defs, **types}
    assert len(bodies) == len(defs) + len(types), 'Type/function namespace overlap'
    owners = {name: name for name in bodies}
    for name, body in types.items():
        for ctor in re.findall(r'(?m)^  ([A-Za-z_][\w.]*)\{', body):
            assert owners.get(ctor, name) == name, ('ambiguous constructor', ctor)
            owners[ctor] = name
    edges = {}
    for name, body in bodies.items():
        tokens = set(IDENTIFIER.findall(STRINGS_COMMENTS.sub('', body)))
        edges[name] = sorted({owners[t] for t in tokens if t in owners} - {name})
    return bodies, edges


def closure(root, edges):
    seen, pending = set(), [root]
    while pending:
        name = pending.pop()
        if name in seen:
            continue
        assert name in edges, ('missing closure declaration', name)
        seen.add(name)
        pending.extend(edges[name])
    return seen


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['source', 'recipe', 'out']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102') and not out.exists()
    out.mkdir(parents=True)
    inputs = {}

    def bind(value):
        actual = pin(value['file'] if isinstance(value, dict) else value)
        if isinstance(value, dict):
            assert actual == {k: value[k] for k in ['file', 'bytes', 'sha256']}, value
        assert inputs.setdefault(actual['file'], actual) == actual
        return actual

    def tree(value):
        if isinstance(value, dict):
            if {'file', 'bytes', 'sha256'} <= value.keys():
                bind(value)
            else:
                for child in value.values():
                    tree(child)
        elif isinstance(value, list):
            for child in value:
                tree(child)

    def read(value):
        item = bind(value)
        return item, json.loads(Path(item['file']).read_text())

    report = dict(kind='phase102-native-authority-source-audit', complete=False,
                  passed=False, inputsUnchanged=False, targetsRun=False,
                  imageQualified=False, wholeCompilerProved=False, method=bind(__file__))
    try:
        anchors = {name: bind(HIST / name) for name in ANCHORS}
        assert all(anchors[name]['sha256'] == sha for name, sha in ANCHORS.items())
        baseline = anchors['origin-guard-source01/compiler.bend']
        parent_pin, parent = read(anchors['origin-backend-specific01/report.json'])
        bridge_pin, bridge = read(anchors['origin-guard-declaration-bridge01/report.json'])
        assert parent['complete'] and parent['passed'] and parent['inputsUnchanged']
        assert not parent.get('error') and parent['source'] == baseline
        assert parent['finalCompositionBridge'] == bridge_pin
        assert bridge['complete'] and bridge['inputsUnchanged'] and bridge['source'] == baseline
        source = bind(args.source)
        recipe_pin, recipe = read(args.recipe)
        tree(recipe)
        assert recipe['complete'] and bind(recipe['candidate']) == source
        assert bind(recipe['source']) == baseline, 'Replay must start at installed Phase98 source'
        old, new = Path(baseline['file']).read_text(), Path(source['file']).read_text()
        assert replay(old, recipe['changes']) == new
        assert replay(new, recipe['changes'], True) == old
        before, after = declarations(old), declarations(new)
        # The hint successor must preserve every earlier semantic mechanism.
        parent_recipe_pin, parent_recipe = read(recipe['parentRecipe'])
        parent_source = bind(recipe['parentCandidate'])
        assert parent_source['sha256'] == '8b895aec2dc9eac2eaee0036239367f83b53910c309ba26ebab4c9a47fa5affa'
        assert parent_recipe['candidate'] == parent_source and parent_recipe['source'] == baseline
        parent_text = Path(parent_source['file']).read_text()
        assert replay(old, parent_recipe['changes']) == parent_text
        assert replay(parent_text, parent_recipe['changes'], True) == old
        assert recipe['changes'][:len(parent_recipe['changes'])] == parent_recipe['changes']
        local_edits = recipe['changes'][len(parent_recipe['changes']):]
        assert replay(parent_text, local_edits) == new and replay(new, local_edits, True) == parent_text
        previous_pin, previous = read(ROOT / 'selfhost/build/phase102/authority-source-audit01/report.json')
        assert previous_pin['sha256'] == 'c1e7316d4e4434f1af368ce46c6c0b427efc6c3d0763a5f4875d7a0efb607345'
        assert previous['complete'] and previous['passed'] and previous['inputsUnchanged'] and previous['source'] == parent_source
        tree(previous)
        parent_defs = declarations(parent_text)
        hint_changed = {'nf_inline', 'nf_prototypes', 'ntr_plain_bodies', 'nf_finish_ready', 'ntr_worker_body', 'nf_bodies'}
        assert set(parent_defs) <= set(after)
        assert {n for n in parent_defs if parent_defs[n] != after[n]} == hint_changed
        assert set(after) - set(parent_defs) == {'nfi_deps', 'nfi_pass'}
        rules = {
            'nf_inline': [('def nf_inline(+code: NC_Code)', 'def nf_inline(name: String, inline: List<&2, String>)'),
                          ('nct_within(nc_text(code), 8192)', 'nb_contains(inline, name)')],
            'nf_prototypes': [('def nf_prototypes(workers: List<&2, NF_Worker>, +ready: List<&2, String>)', 'def nf_prototypes(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +inline: List<&2, String>)'),
                              ('nf_inline(code)', 'nf_inline(name, inline)'), ('nf_prototypes(rest, ready)', 'nf_prototypes(rest, ready, inline)')],
            'ntr_plain_bodies': [('def ntr_plain_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>)', 'def ntr_plain_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +inline: List<&2, String>)'),
                                 ('nf_inline(code)', 'nf_inline(name, inline)'), ('nf_bodies(rest, ready)', 'nf_bodies(rest, ready, inline)')],
            'nf_finish_ready': [('  +route = no_route(book, ordinary, observer_names, workers, ready, observers)\n',
                                 '  +route = no_route(book, ordinary, observer_names, workers, ready, observers)\n  +inline = nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), Nil{})))\n'),
                                ('nf_prototypes(no_route_workers(route), no_route_ready(route))', 'nf_prototypes(no_route_workers(route), no_route_ready(route), inline)'),
                                ('nf_bodies(no_route_workers(route), no_route_ready(route))', 'nf_bodies(no_route_workers(route), no_route_ready(route), inline)')],
            'ntr_worker_body': [('def ntr_worker_body(+name: String, +params: List<&2, N_Param>, +code: NC_Code)', 'def ntr_worker_body(+name: String, +params: List<&2, N_Param>, +code: NC_Code, +inline: List<&2, String>)'),
                                ('nf_inline(code)', 'nf_inline(name, inline)')],
            'nf_bodies': [('def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>)', 'def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +inline: List<&2, String>)'),
                          ('ntr_worker_body(name, params, code)', 'ntr_worker_body(name, params, code, inline)'),
                          ('nf_bodies(rest, ready)', 'nf_bodies(rest, ready, inline)'), ('ntr_plain_bodies(workers, ready)', 'ntr_plain_bodies(workers, ready, inline)')],
        }
        for name, substitutions in rules.items():
            transformed = parent_defs[name]
            for left, right in substitutions:
                assert transformed.count(left) == (2 if name == 'ntr_worker_body' and left == 'nf_inline(code)' else 1), (name, left)
                transformed = transformed.replace(left, right)
            assert transformed == after[name], name
        assert after['nfi_deps'] == ('@unsafe\ndef nfi_deps(deps: List<&2, String>, +previous: List<&2, String>) -> Bool:\n'
            '  match deps:\n    case Nil{}: True{}\n    case Con{name, rest}: nb_contains(previous, name) && nfi_deps(rest, previous)\n')
        assert after['nfi_pass'] == ('@unsafe\ndef nfi_pass(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +previous: List<&2, String>) -> List<&2, String>:\n'
            '  match workers:\n    case Nil{}: Nil{}\n    case Con{NF_Worker{+name, params, code, deps, shape}, +rest}:\n'
            '      nt_choose(List<&2, String>, nb_contains(ready, name) && nct_within(nc_text(code), 8192) && nfi_deps(deps, previous),\n'
            '        u => Con{name, nfi_pass(rest, ready, previous)}, u => nfi_pass(rest, ready, previous))\n')
        inline_audit = dict(parentSource=parent_source, parentRecipe=parent_recipe_pin, previousAudit=previous_pin,
            changedDeclarations=sorted(hint_changed), addedDeclarations=['nfi_deps', 'nfi_pass'], immutablePasses=3, ownCodeBytes=8192,
            exactHintOnlyReconstruction=True, admissionAndEmittedBodyTextUnchanged=True,
            scope='Exact six-function argument/hint plumbing plus two bounded dependency helpers. The shared post-observer ready set drives prototypes, ordinary bodies and both TRMC functions. Missing dependencies decline forced inlining; ordinary C inline policy remains. No semantic or performance result inferred from the hint.')
        old_types, new_types = declarations(old, 'type'), declarations(new, 'type')
        assert old_types == new_types, 'Changed type declaration cannot inherit this audit'
        assert set(before) <= set(after), 'Removed declaration requires a new audit policy'
        changed = {name for name in before if before[name] != after[name]}
        added = set(after) - set(before)
        assert changed == CHANGED and added == ADDED, ('Unknown change set', changed ^ CHANGED, added ^ ADDED)
        authorities = bridge['exactPermissionDeclarations']
        assert len(authorities) == 16 and len({row['name'] for row in authorities}) == 16
        assert {row['name'] for row in authorities if before[row['name']] != after[row['name']]} == AUTH_CHANGED
        exact = []
        for row in authorities:
            assert row['exact'] and digest(before[row['name']].encode()) == {k: row[k] for k in ['bytes', 'sha256']}
            if row['name'] not in AUTH_CHANGED:
                assert before[row['name']] == after[row['name']]
                exact.append(row)
        # Audit exact permission flow, not just the two changed function names.
        original = before['nf_plan_scoped']
        assert original.count('  nf_plan_workers(') == 1
        expected = original.replace('  nf_plan_workers(', '  nfo_plan(book, nf_plan_workers(').rstrip('\n') + ')\n'
        assert after['nf_plan_scoped'] == expected
        original = before['ns_compile_named_scoped']
        fallback = '    u => ns_compile_fallback_scoped(prepared, names, bangs, ne_runtime_prepend(runtime, nh_macros(prepared, names, sharing)), requests, observers, sharing, nc_compile_defs(prepared, ["main"], Nil{}, 0, bangs)))\n'
        assert original.count(fallback) == 1
        replacement = ('    u => nt_choose(NC_Result, observers && List.is_empty(&2, String, bangs),\n'
                       '      v => nf_scheduler_compile(prepared, names, bangs, runtime, requests, observers, sharing),\n'
                       '      v => ns_compile_fallback_scoped(prepared, names, bangs, ne_runtime_prepend(runtime, nh_macros(prepared, names, sharing)), requests, observers, sharing, nc_compile_defs(prepared, ["main"], Nil{}, 0, bangs))))\n')
        assert after['ns_compile_named_scoped'] == original.replace(fallback, replacement)
        classifications = {
            'nf_plan_scoped': 'Existing signatures, observer candidate list and worker plan remain identical arguments; the completed plan additionally enters nfo_plan. Owning-adapter alias/readiness composition is changed backend behavior and requires new final-source controls; permission-helper laws do not prove it.',
            'ns_compile_named_scoped': 'Existing sharing-and-no-bangs planned route remains first. A new route is selected only when observers is true and reachable bangs are empty; it attaches the admitted local-worker plan. The original fallback is retained otherwise. Source flags originate in the unchanged checked/prepared authority entries; new raw/provider/bang controls remain required.',
        }
        audited = [dict(name=name, before=digest(before[name].encode()), after=digest(after[name].encode()),
                        beforeText=before[name], afterText=after[name], exact=False,
                        classification=classifications[name]) for name in sorted(AUTH_CHANGED)]
        inherited = []
        bases = []
        for item, package, count, laws in zip(bridge['inheritedSafeClosures'], ['permission', 'tag'], [5, 8], [7, 6]):
            proof_pin, proof = read(item['proof'])
            manifest_pin, manifest = read(item['manifest'])
            assert proof_pin == anchors['combined-' + package + '-proof-check01/report.json']
            assert manifest_pin == anchors['combined-' + package + '-proof-source01/manifest.json']
            assert proof['complete'] and proof['inputsUnchanged'] and proof['independentlyChecked']
            assert not proof['sourceOnly'] and proof['opaqueDefinitions'] == [] and len(proof['lawNames']) == laws
            assert manifest['candidate'] == bridge['parentSource'] and len(manifest['candidateDefinitions']) == count
            for definition in manifest['candidateDefinitions']:
                assert old.count(definition['original']) == new.count(definition['original']) == 1
            for row in proof['sourceClosure']:
                left, right = bind(row['origin']), bind(row['snapshot'])
                assert all(left[k] == right[k] for k in ['bytes', 'sha256'])
            for output in manifest['outputs']:
                if Path(output['file']).suffix == '.bend':
                    assert output in [row['origin'] for row in proof['sourceClosure']]
                    bind(output)
            base_rows = [row for row in proof['inputs'] if Path(row['file']).name == 'base.bend']
            assert len(base_rows) == 1
            bases.append(bind(base_rows[0]))
            inherited.append(dict(proof=proof_pin, manifest=manifest_pin, exactDefinitions=count,
                                  lawNames=proof['lawNames'], sourceCorrespondenceExact=True,
                                  independentRecheckPerformed=False,
                                  scope='Historical independent safe-helper proof, unchanged extracted source only; no new kernel execution or backend lifetime proof.'))
        assert bases[0] == bases[1]
        assert bases[0]['sha256'] == '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
        old_imports = re.findall(r'(?m)^import (.+)$', old)
        assert old_imports == re.findall(r'(?m)^import (.+)$', new) == ['Base']
        old_bodies, old_edges = graph(before, old_types)
        new_bodies, new_edges = graph(after, new_types)
        closures = {}
        for root in ROOTS:
            names = closure(root, old_edges)
            assert names == closure(root, new_edges)
            for name in names:
                assert old_bodies[name] == new_bodies[name] and old_edges[name] == new_edges[name], (root, name)
            closures[root] = dict(root=root, exact=True, base=bases[0],
                declarations=[dict(name=name, kind='type' if name in old_types else 'def',
                                   **digest(old_bodies[name].encode()), dependencies=old_edges[name]) for name in sorted(names)],
                definitionCount=len(names & set(before)), typeCount=len(names & set(old_types)),
                scope='Conservative lexical global-reference closure, including constructor-owner types. Strings/comments excluded; same-name locals may overapproximate edges. This is exact source correspondence, not a language-semantics or whole-compiler proof.')
        report.update(source=source, sourceRecipe=recipe_pin, parentSource=baseline, inlinePolicyAudit=inline_audit,
                      parentBackendControls=parent_pin, priorDeclarationBridge=bridge_pin,
                      forwardAndInverseExact=True, exactPermissionDeclarations=exact,
                      auditedPermissionDeclarations=audited,
                      changedDeclarations=[dict(name=name, before=digest(before[name].encode()), after=digest(after[name].encode())) for name in sorted(changed)],
                      addedDeclarations=[dict(name=name, **digest(after[name].encode())) for name in sorted(added)],
                      unchangedTypeDeclarations=[dict(name=name, **digest(body.encode())) for name, body in sorted(old_types.items())],
                      inheritedSafeClosures=inherited, inheritedRootClosures=closures, inheritedBase=bases[0],
                      counts=dict(exactAuthority=14, auditedChangedAuthority=2, changedDeclarations=len(changed), addedDeclarations=len(added), unchangedTypes=len(old_types)),
                      scope='Offline source lineage and narrow inheritance audit. Changed routing, raw/provider refusal, ownership, generated C and final native images require their separate final-source execution evidence. Historical proofs retain their original source identities.')
        assert len(exact) == 14
        for item in inputs.values():
            assert pin(item['file']) == item
        report.update(complete=True, passed=True, inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['inputs'] = list(inputs.values())
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, passed=True, targetsRun=False, report=pin(out / 'report.json'), counts=report['counts'])))


if __name__ == '__main__':
    main()
