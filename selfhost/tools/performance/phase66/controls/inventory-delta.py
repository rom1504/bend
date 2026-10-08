#!/usr/bin/env python3
"""Data-only pinned upstream fixture delta and staged conformance selections."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
OLD = '018751270e800bc222a93dad7f257083ee53a5f7'
NEW = '059266225b77c8ca256ac6b25ee5c21449bab151'

SCREEN = [
    ('parse/array_set_call_row.bend', 'Array.set statement/source-start distinction'),
    ('parse/let_in_argument.bend', 'let in an argument, moved from printer'),
    ('flatten/order_ban_004.bend', 'late/consumed scrutinee diagnostic'),
    ('flatten/consumed_column_error_002.bend', 'introduced constructor scrutinee diagnostic'),
    ('flatten/ctor_scrutinee_error.bend', 'literal constructor scrutinee diagnostic'),
    ('import/base_family_file.bend', 'imported Word versus Base.Word identity'),
    ('check/kind_terms.bend', 'kind-valued terms and dependent application'),
    ('check/convoy_dependent.bend', 'dependent convoy cases'),
    ('check/unsafe_kind.bend', 'unsafe dependency trust is distinct from type acceptance'),
    ('check/meet_uses_in_arms.bend', 'affine meet across arms'),
    ('proof/refined_proof_copy.bend', 'ordinary checker proof terms, no Lean claim'),
    ('reg/wnf_memo_bound_key.bend', 'normalization memo binder key'),
    ('reg/rwt_type_share.bend', 'rewrite and shared type representation'),
    ('reg/u32_literal_word_field.bend', 'literal versus boxed Word field'),
    ('compile/array_equality.bend', 'proof-valued array equality'),
    ('compile/vector_boxed_default.bend', 'generic boxed vector layout'),
    ('run/list_rebox_generic_sum.bend', 'generic ADT/list reboxing'),
    ('run/f32_read_whitespace.bend', 'changed Base float parsing'),
    ('io/marshal_array_depth.bend', 'deep arrays and recursive host conversion'),
    ('io/foreign_runtime_apply.bend', 'foreign runtime callback application'),
    ('io/foreign_runtime_apply_tail.bend', 'foreign runtime tail application'),
    ('io/effect_helper_collision.bend', 'foreign helper scope collision'),
    ('io/effect_unregistered.bend', 'unregistered effect failure'),
    ('io/cid_capture.bend', 'constructor IDs across modules'),
    ('io/request_wildcard.bend', 'IO request wildcard fail-stop'),
]


def pin(file):
    data = file.read_bytes()
    return dict(file=str(file.resolve()), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def describe(file, relative):
    text = file.read_text()
    lines = text.splitlines()
    expected = '\n'.join(x[2:] for x in lines if x.startswith('#|')).strip()
    imports = re.findall(r'^\s*import\s+"([^"\n]+\.(?:js|c))"', text, re.M)
    base = bool(re.search(r'^import Base\s*$', text, re.M))
    main = bool(re.search(r'^(?:def|law) main(?:\(|:)', text, re.M))
    namespace = relative.split('/')[0]
    network = bool(re.search(r'\b(?:IO\.)?(?:tcp_|udp_|http_|fetch)|TCP\.|UDP\.|HTTP\.', text))
    scheduler = namespace == 'io' and bool(re.search(r'Chan\.|IO\.(?:sleep|fork|within)|IO\.(?:chan|spawn)', text))
    return dict(id=relative, identity=pin(file), hasOracle=any(x.startswith('#|') for x in lines), expected=expected,
        namespace=namespace, main=main, base=base, foreign=imports,
        negative=expected.startswith(('SOME PROOFS FAIL', 'Error:')),
        jsEligible=main and base and (not imports or any(x.endswith('.js') for x in imports)),
        proofLane='ordinary validation/declaration trust only; Lean kernel not executed',
        gpuMarker=bool(re.search(r'!\(', '\n'.join(x for x in lines if not x.lstrip().startswith('#')))),
        runtimeClass='network' if network else 'scheduler' if scheduler else 'foreign' if imports else 'pure',
        bodySha256=hashlib.sha256('\n'.join(x for x in lines if not x.startswith('#|')).encode()).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--old', type=Path, default=ROOT/'selfhost/.bootstrap/upstream-phase23')
    parser.add_argument('--new', type=Path, default=ROOT/'selfhost/.bootstrap/upstream-phase66')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    assert args.out.resolve().is_relative_to(ROOT/'selfhost/tools/performance/phase66/controls')
    trees = [{str(p.relative_to(base/'tests')):p for p in (base/'tests').rglob('*.bend')} for base in [args.old,args.new]]
    old,new = trees
    delta = []
    for name in sorted(old.keys()|new.keys()):
        a,b = old.get(name),new.get(name)
        if a and b and a.read_bytes() == b.read_bytes(): continue
        kind = 'added' if a is None else 'deleted' if b is None else 'modified'
        row = dict(id=name,change=kind,old=describe(a,name) if a else None,new=describe(b,name) if b else None)
        row['oracleOnly'] = bool(a and b and row['old']['bodySha256'] == row['new']['bodySha256'])
        delta.append(row)
    counts = collections.Counter(x['change'] for x in delta)
    assert counts == {'added':83,'modified':38,'deleted':9}, counts
    gate_old = [n for n in old if len(Path(n).parts)==2]
    gate_new = [n for n in new if len(Path(n).parts)==2]
    assert (len(gate_old),len(gate_new)) == (1513,1587)
    args.out.mkdir(parents=True)
    def write(name,value):
        with (args.out/name).open('x') as f: f.write(json.dumps(value,indent=2)+'\n')
    choices=[]
    for name,reason in SCREEN:
        row=describe(new[name],name)
        lanes=['parse','check']
        if row['jsEligible']: lanes.append('js')
        choices.append(dict(id='newdelta/'+name,file=str(new[name].resolve()),lanes=lanes,reason=reason,fixture=row))
    assert len(choices)==25
    write('screen25.json',dict(cases=[{k:v for k,v in x.items() if k in ['id','file','lanes']} for x in choices]))
    write('screen25-rationale.json',dict(cases=choices,scope='These are named first discriminators, not total conformance. Old TS may reject new fixtures; all outcomes remain observations.'))
    write('delta-frontend.json',dict(cases=[dict(id='newdelta/'+x['id'],file=x['new']['identity']['file'],lanes=['parse','check']) for x in delta if x['new']]))
    runtime=[describe(new[n],n) for n in sorted(gate_new)]
    write('full-js-applicable.json',dict(cases=[dict(id=x['id'],lanes=['js']) for x in runtime if x['jsEligible']]))
    write('runtime-classes.json',dict(cases=[x for x in runtime if x['jsEligible']],policy='Eligibility is not a pass. Preserve network/scheduler/Bun/native availability failures; no GPU or Lean execution is inferred.'))
    write('delta.json',dict(kind='phase66-upstream-conformance-delta',dataOnly=True,targetExecuted=False,
        oldRevision=OLD,newRevision=NEW,producer=pin(Path(__file__)),oldRoot=str(args.old.resolve()),newRoot=str(args.new.resolve()),
        upstreamSources={role:[pin(base/'bend2'/n) for n in ['bend.ts','comp.ts','base.bend','main.ts','safe.ts','bendtt.lean']] for role,base in [('old',args.old),('new',args.new)]},
        counts=dict(counts),oldGateFixtures=len(gate_old),newGateFixtures=len(gate_new),unchangedGateFixtures=len(set(gate_old)&set(gate_new))-counts['modified'],
        oracleOnlyModifications=sum(x['oracleOnly'] for x in delta),delta=delta,
        runtimeEligible=sum(x['jsEligible'] for x in runtime),runtimeClasses=dict(collections.Counter(x['runtimeClass'] for x in runtime if x['jsEligible'])),
        scope='File-tree comparison only. Revision constants identify root-attested immutable checkouts, not a new Git verification by this producer. Nested support modules are not independent gate fixtures.'))
    print(json.dumps(dict(output=str(args.out),counts=dict(counts),oldFixtures=len(gate_old),newFixtures=len(gate_new),screen=25,jsEligible=sum(x['jsEligible'] for x in runtime))))


if __name__ == '__main__': main()
