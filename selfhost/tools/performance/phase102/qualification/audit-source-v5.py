#!/usr/bin/env python3
"""Offline successor: audit projection grammar correction and stable inline-eligibility hoisting."""
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
PROJECTION_ADDED = set('nfp_identity nfp_params nfp_known nfp_reduce nfp_reduce_known nfp_reduce_head '
                       'nfp_replace nfp_capture_free nfp_capture_children nfp_schema nfp_selected '
                       'nfp_composition nfp_workers nfp_finish'.split())
ADDED.update(PROJECTION_ADDED)
ADDED.update({'nfi_eligible', 'nfp_replaced'})
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
        # Hoist the same pure per-worker predicates once, preserving stable
        # worker order and all three immutable dependency iterations.
        parent_recipe_pin, parent_recipe = read(recipe['parentRecipe'])
        parent_source = bind(recipe['parentCandidate'])
        assert parent_source['sha256'] == '86093b9cb7e58fd45b80d8214507835340dfd9f73924bcada3b5c146a5f457cb'
        assert source['sha256'] == '956a74765594da64ef30ef42ec0ec2b7710ab435fa7ddbd011501acf467048ad'
        assert parent_recipe['candidate'] == parent_source and parent_recipe['source'] == baseline
        parent_text = Path(parent_source['file']).read_text()
        assert replay(old, parent_recipe['changes']) == parent_text
        assert replay(parent_text, parent_recipe['changes'], True) == old
        assert recipe['changes'][:len(parent_recipe['changes'])] == parent_recipe['changes']
        local_edits = recipe['changes'][len(parent_recipe['changes']):]
        assert local_edits == recipe['addedChanges'] and len(local_edits) == 5
        assert replay(parent_text, local_edits) == new and replay(new, local_edits, True) == parent_text
        previous_pin, previous = read(ROOT / 'selfhost/build/phase102/authority-source-audit03/report.json')
        assert previous_pin['sha256'] == '46f8604d0d6aa7c13bfeb01fad50179d258981517fe280a199bec31187aef2be'
        assert previous['complete'] and previous['passed'] and previous['inputsUnchanged']
        assert previous['source']['sha256'] == 'a35557ead5a579a17211f2a88e8132236c99cce7d35203761af47dfbe1076b1b'
        tree(previous)
        reviewed_text = Path(bind(previous['source'])['file']).read_text()
        reviewed_defs, grammar_defs = declarations(reviewed_text), declarations(parent_text)
        assert set(reviewed_defs) <= set(grammar_defs)
        assert {n for n in reviewed_defs if reviewed_defs[n] != grammar_defs[n]} == {'nfp_replace'}
        assert set(grammar_defs) - set(reviewed_defs) == {'nfp_replaced'}
        replacement = ('@unsafe\ndef nfp_replace(+book: List<&2, KDef>, +old: NF_Worker, +producer: String, +schema: NO_Schema, +selected: KTerm) -> NF_Worker:\n'
            '  nfp_replaced(old, no_adapter(book, producer, no_plan_params(no_schema_params(schema)), no_schema_roots(schema), no_schema_result(schema), selected, no_schema_fresh(schema)))\n')
        matcher = reviewed_defs['nfp_replace'].replace(
            'def nfp_replace(+book: List<&2, KDef>, +old: NF_Worker, +producer: String, +schema: NO_Schema, +selected: KTerm) -> NF_Worker:',
            'def nfp_replaced(+old: NF_Worker, replacement: NF_Worker) -> NF_Worker:').replace(
            'match no_adapter(book, producer, no_plan_params(no_schema_params(schema)), no_schema_roots(schema), no_schema_result(schema), selected, no_schema_fresh(schema)):',
            'match replacement:')
        assert grammar_defs['nfp_replace'] == replacement and grammar_defs['nfp_replaced'] == matcher
        assert reviewed_text.count(reviewed_defs['nfp_replace']) == 1
        assert parent_text == reviewed_text.replace(reviewed_defs['nfp_replace'], replacement + '\n' + matcher)
        grammar_helpers = bind(parent_recipe['helpers'])
        assert grammar_helpers['sha256'] == 'cda40ffa253f6f910bcd618661621ec4c5f764bb2eb1e4872385143b93c5a0a7'
        grammar_producer = bind(parent_recipe['method'])
        assert grammar_producer['sha256'] == '4c6cadc5c822bf6f10d2fd724dd0b3178b1dcdaeed97de4daaebf099cbe25baa'
        grammar_audit = dict(reviewedSource=previous['source'], reviewedAudit=previous_pin,
            correctedSource=parent_source, helpers=grammar_helpers, producer=grammar_producer,
            changedDeclarations=['nfp_replace'], addedDeclarations=['nfp_replaced'],
            exactNamedParameterNormalization=True,
            scope='The reviewed adapter call is evaluated before a named-parameter matcher; selection, result shape, error/segment checks and fallback remain exact. The old computed match was rejected by the grammar and never successfully acquired.')
        producer = bind(recipe['method'])
        assert producer['sha256'] == '71534b22e43fd57809b209541a741e7dfc7c83612204462f9c4b1196fed41b1b'
        parent_defs = declarations(parent_text)
        assert set(parent_defs) <= set(after)
        assert {n for n in parent_defs if parent_defs[n] != after[n]} == {'nfi_pass', 'nf_finish_ready'}
        assert set(after) - set(parent_defs) == {'nfi_eligible'}
        pass_before = parent_defs['nfi_pass']
        substitutions = [
            ('def nfi_pass(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +previous: List<&2, String>)',
             'def nfi_pass(workers: List<&2, NF_Worker>, +previous: List<&2, String>)', 1),
            ('nb_contains(ready, name) && nct_within(nc_text(code), 8192) && nfi_deps(deps, previous)',
             'nfi_deps(deps, previous)', 1),
            ('nfi_pass(rest, ready, previous)', 'nfi_pass(rest, previous)', 2)]
        for left, right, count in substitutions:
            assert pass_before.count(left) == count
            pass_before = pass_before.replace(left, right)
        assert after['nfi_pass'] == pass_before
        before_line = '  +inline = nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), nfi_pass(no_route_workers(route), no_route_ready(route), Nil{})))'
        after_line = '  +eligible = List.filter(NF_Worker, nfi_eligible(no_route_ready(route)), no_route_workers(route))\n  +inline = nfi_pass(eligible, nfi_pass(eligible, nfi_pass(eligible, Nil{})))'
        assert parent_defs['nf_finish_ready'].count(before_line) == 1
        assert after['nf_finish_ready'] == parent_defs['nf_finish_ready'].replace(before_line, after_line)
        assert after['nfi_eligible'] == ('@unsafe\ndef nfi_eligible(+ready: List<&2, String>, worker: NF_Worker) -> Bool:\n'
            '  match worker:\n    case NF_Worker{name, params, code, deps, shape}: nb_contains(ready, name) && nct_within(nc_text(code), 8192)\n')
        assert declarations(parent_text, 'law') == declarations(new, 'law')
        inline_audit = previous['inlinePolicyAudit']
        projection_audit = previous['projectionAudit']
        filter_base = bind(previous['inheritedBase'])
        base_defs = declarations(Path(filter_base['file']).read_text())
        assert base_defs['List.filter'] == ('def List.filter(~A: Data, ~f: A -> Bool, xs: List<&2, A>) -> List<&2, A>:\n'
            '  match xs:\n    case Nil{}:\n      Nil{}\n    case +h <> t:\n      List.filter.put(A, h, List.filter(~A, ~f, t), f(h))\n')
        assert base_defs['List.filter.put'] == ('def List.filter.put(-A: Data, h: A, r: List<&2, A>, keep: Bool) -> List<&2, A>:\n'
            '  match keep:\n    case False{}:\n      r\n    case True{}:\n      h <> r\n')
        eligibility_audit = dict(parentSource=parent_source, parentRecipe=parent_recipe_pin,
            previousAudit=previous_pin, producer=producer, changedDeclarations=['nf_finish_ready', 'nfi_pass'],
            addedDeclarations=['nfi_eligible'], base=filter_base,
            filterDefinitions={name: base_defs[name] for name in ['List.filter', 'List.filter.put']},
            immutablePasses=3, sameStableWorkerOrder=True, sameEligibilityPredicate=True,
            scope='Exact hoist of unchanged readiness/8192-codepoint text predicate into the pinned stable Base filter. Pure predicate values and dependency rounds are unchanged; only repeated traversal work changes. Allocation/error timing and measured performance are not proved.')
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
        report.update(source=source, sourceRecipe=recipe_pin, parentSource=baseline, inlinePolicyAudit=inline_audit, projectionAudit=projection_audit, inlineEligibilityAudit=eligibility_audit, projectionGrammarAudit=grammar_audit,
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
