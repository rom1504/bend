"""Exact module composition followed by the frozen current-body literal patch."""
import hashlib
import importlib.util
import json
from pathlib import Path


def install(v):
    for name in ['ROOT', 'Q', 'C', 'bound', 'read', 'retain', 'require', 'exact']:
        globals()[name] = getattr(v, name)
    v.source_contract = source_contract


def replay_final(sm, parent, source):
    direct = bound(sm['directParentManifest'])
    require(direct['complete'] and direct['source'] == sm['directParent']
            and direct['parent'] == sm['parent'], 'Literal direct-parent identity differs')
    require(sm['source']['sha256'] == '1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'
            and sm['directParent']['sha256'] == '75a9c4ad4ed01ae7e731bb1167d7a84959c74bab778ecabdcafbb81d305e5929',
            'Exact final candidate/direct parent required')
    snapshots = sorted(Path(direct['source']['file']).parent.glob('module*.bend'),
                       key=lambda p: int(p.stem[len('module'):]))
    require(snapshots, 'Direct-parent module snapshots missing')
    for path in snapshots:
        row = Q.pin(path); retain(row)
        require(any(x['bytes'] == row['bytes'] and x['sha256'] == row['sha256'] for x in direct['inputs']),
                'Direct-parent module lacks origin identity')
    initial, added, protected = C.compose(parent, [p.read_text() for p in snapshots],
                    set(direct['overrides']), set(direct.get('moduleOverrides', [])))
    require(initial.encode() == Path(direct['source']['file']).read_bytes()
            and direct['added'] == added and direct['protectedDeclarations'] == protected,
            'Exact direct-parent composition differs')
    folder = ROOT / 'selfhost/tools/performance/phase131/identity'
    method = folder / 'expose-current-literals.py'
    for path in [method, folder/'literal-atoms.py', folder/'audit-literal-atoms.py', folder/'literal-atoms-inventory.json']:
        require(Q.pin(path) in sm['inputs'], 'Literal transform authority missing')
    spec = importlib.util.spec_from_file_location('phase131_exact_literal_replay', method)
    L = importlib.util.module_from_spec(spec); spec.loader.exec_module(L)
    inventory = read(folder/'literal-atoms-inventory.json')
    original = C.blocks(Path(inventory['source']['file']).read_text()); before = C.blocks(initial)
    require(all(C.norm(before[n]) == C.norm(original[n]) for n in ['atom', 'kt']), 'Literal factories differ')
    names = {x['owner'] for x in inventory['rows'] if not x['protected']} - set(protected) - L.PROOFS
    require(len(names) == 286 and len(protected) == 91, 'Literal eligible/protected inventory differs')
    import re
    definition = re.search(r'^def atom\(', initial, re.M); require(definition, 'Global atom definition missing')
    for pos in L.A.identifiers(initial, 'atom'):
        if pos == definition.start()+4: continue
        close = L.I.whitespace(initial, pos+4)
        require(close < len(initial) and initial[close] == '(', 'Shadowed atom identifier')
    hits = list(C.PAT.finditer(initial)); parts = [initial[:hits[0].start()]]; rows = []
    for index, hit in enumerate(hits):
        name = hit[1]; body = initial[hit.start():hits[index+1].start() if index+1<len(hits) else len(initial)]
        calls = L.I.calls(body) if name in names and not body.lstrip().startswith('law ') else []
        patched = body; changes = []
        for call in reversed(calls):
            replacement = '{KTerm{'+call['literal']+', "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}'
            require(patched[call['begin']:call['end']] == call['call'], 'Literal call slice differs')
            patched = patched[:call['begin']]+replacement+patched[call['end']:]
            changes.append(dict(**call, replacement=replacement))
        parts.append(patched)
        if calls: rows.append(dict(name=name, count=len(calls), beforeSha256=L.digest(body),
                                  afterSha256=L.digest(patched), replacements=list(reversed(changes))))
    replay = ''.join(parts); exposure = sm['literalExposure']; after = C.blocks(replay)
    require(replay == source and rows == exposure['rows'] and set(before) == set(after), 'Exact final literal replay differs')
    require(sum(r['count'] for r in rows) == exposure['actualReplacements'] == 419
            and len(rows) == exposure['changedDeclarations'] == 285
            and exposure['reviewedOriginalCalls'] == 421 and exposure['declarationCountChange'] == 0
            and len(replay.encode())-len(initial.encode()) == exposure['sourceByteGrowth'] == 17179,
            'Literal counts differ')
    require(exposure['proofDeclarationsUnchanged'] == sorted(L.PROOFS)
            and all(before[n] == after[n] for n in set(protected)|L.PROOFS), 'Protected/proof declaration changed')
    require(sm['added'] == added and sm['protectedDeclarations'] == protected, 'Final declaration inventory differs')
    retain(Q.pin(__file__))
    return added, protected


def source_contract(ad, selected):
    require(ad.get('kind') == 'phase131-native-acquisition-admission' and ad.get('complete')
            and ad.get('sourceChecked') and ad.get('originalVerifiersUnchanged')
            and ad.get('runtimeContractsUnchanged'), 'Complete checked source/runtime admission required')
    require(ad['parentAdmission'] == selected['admission'] and ad['runtime'] == selected['runtime'],
            'Qualified parent admission/runtime differs')
    sm, api = bound(ad['sourceBinding']), bound(ad['checkedApi'])
    require(sm['complete'] and sm['source'] == ad['source'] and sm['parent'] == selected['source'],
            'Composed source identity differs')
    require(api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked')
            and api['status'] == 0 and api['api'] == ad['api'] and ad['source'] in api['inputs'],
            'Independent checked API does not consume exact source')
    require(api['command'][2:4] == [ad['source']['file'], ad['api']['file']]
            and api['command'][4:] == api['exports'], 'Checked source/API command differs')
    required = {'p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission',
                'p111_emit_admitted', 'p111_compile_source'}
    require(required <= set(api['exports']), 'Missing checked request-bound exports')
    parent_api = bound(selected['checkedApi'])
    require(api['command'][:2] == parent_api['command'][:2], 'Upstream checking command changed')
    for old in parent_api['inputs']:
        if old == selected['source']:
            continue
        require(any(x['bytes'] == old['bytes'] and x['sha256'] == old['sha256'] for x in api['inputs']),
                'Upstream checker/method authority changed: ' + old['file'])
    parent = Path(selected['source']['file']).read_text()
    source = Path(ad['source']['file']).read_text()
    added, protected = replay_final(sm, parent, source)
    before, after = C.blocks(parent), C.blocks(source)
    changed = sorted(n for n in before if C.norm(before[n]) != C.norm(after[n]))
    require(sorted(ad['changedDeclarations']) == changed and sorted(ad['addedDeclarations']) == added,
            'Admission changed/added bodies differ')
    require(all(C.norm(before[n]) == C.norm(after[n]) for n in protected), 'Protected body changed')
    old_ad = bound(selected['admission'])
    inherited_admission = bound(old_ad['parentAdmission'])
    inherited = inherited_admission['runtimeContract']
    # The original structural contract retains its pending-check flags verbatim;
    # its completed outer admission supplies the later checked-source authority.
    require(inherited_admission.get('kind') == 'phase128-checked-native-acquisition-admission'
            and inherited_admission.get('complete') and inherited_admission.get('sourceChecked')
            and inherited['source'] == inherited_admission['source']
            and inherited['runtime'] == inherited_admission['runtime'] == ad['runtime'],
            'Inherited checked runtime admission differs')
    inherited_api = bound(inherited_admission['checkedApi'])
    require(inherited_api.get('complete') and inherited_api.get('checked') and inherited_api['status'] == 0
            and inherited_api['api'] == inherited_admission['api']
            and inherited['source'] in inherited_api['inputs'], 'Inherited source check differs')
    authority = C.blocks(Path(inherited['source']['file']).read_text())
    runtime_bodies = inherited['sourceDeclarations']
    for row in runtime_bodies:
        name, raw = row['name'], authority[row['name']].encode()
        require(len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'],
                'Inherited runtime body identity differs: ' + name)
        require(C.norm(before[name]) == C.norm(authority[name]) == C.norm(after[name]),
                'Runtime authority changed; a new contract is required: ' + name)
    require(ad.get('semanticChecks'), 'No candidate semantic-check authorities declared')
    for row in ad['semanticChecks']:
        check = bound(row)
        require(check.get('complete'), 'Candidate semantic check is incomplete')
        finite = ROOT / 'selfhost/tools/performance/phase128/finite.mjs'
        if Q.pin(finite) in check.get('inputs', []):
            expected = ad.get('finiteGroups', {}).get(row['file'], {})
            groups = check.get('groups', [])
            require(expected and len(groups) == len(expected)
                    and len({g['name'] for g in groups}) == len(groups)
                    and {g['name']: g['expectedCount'] for g in groups} == expected,
                    'Exact declared finite groups required')
            require(check['source'] == ad['source'] and check['sourceManifest'] == ad['sourceBinding']
                    and ad['api'] in check['inputs'] and ad['checkedApi'] in check['inputs'],
                    'Finite controls do not consume this exact checked source/API')
            for group in groups:
                require(group.get('complete') and isinstance(group['expectedCount'], int)
                        and group['expectedCount'] > 0 and len(group['rows']) == group['expectedCount']
                        and all(isinstance(v, str) and
                            (v.startswith('PASS ') if group['name'] == 'p118z_controls' else v.endswith(':pass'))
                            for v in group['rows']), 'Finite predicate failed or count differs')
        else:
            require(check.get('passed') is True or check.get('pass') is True,
                    'Candidate semantic check lacks an explicit successful verdict')
    return dict(completeSourceReplay=True, changedDeclarations=changed, addedDeclarations=added,
                changedBodies=[dict(name=n, bytes=len(after[n].encode()),
                    sha256=hashlib.sha256(after[n].encode()).hexdigest()) for n in changed + added],
                protectedDeclarations=protected, unchangedRuntimeBodies=runtime_bodies,
                independentCheckedApi=ad['checkedApi'])

