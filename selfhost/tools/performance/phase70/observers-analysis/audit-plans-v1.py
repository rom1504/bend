#!/usr/bin/env python3
"""Pure-data residual audit, not a compiler or proof of erased source semantics."""
import argparse, collections, hashlib, json
from pathlib import Path

def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def audit(record, operations):
    assert record['accepted'] and record['permission'] and not record['error']
    schema, analysis = record['schema'], record['analysis']
    params, roots = schema['params'], schema['roots']
    root_types = {params[i]['name'] for i in roots}
    specs = {}
    for spec in schema['specs']:
        key = spec['layout']['key']
        assert key not in specs or specs[key] == spec, 'conflicting descriptor'
        specs[key] = spec
    kinds = {p['id']: p['name'] for p in params}
    origins = {p['id']: ('arg', i) for i, p in enumerate(params)}
    seen = set(kinds) | {schema['result']}
    counts = collections.Counter()
    def atom(t, expected, env):
        tag = t['tag']
        if tag == 'Var': assert env.get(t['id']) == expected, ('atom kind', expected, t, env)
        elif tag == 'NWord':
            assert expected in ('Nat', 'U32', 'F32'), ('untyped numeric context', expected)
            assert t['name'].isdigit() and str(int(t['name'])) == t['name']
            assert 0 <= int(t['name']) <= 4294967295
        elif tag == 'NCtr':
            s = specs[t['name']]
            assert not t['kids'] and s['owner'] == expected
            assert s['layout']['storage'] == 'Nullary' and expected not in root_types
        else: raise AssertionError(('unknown atom', t))
    def bind(t, env, owner):
        assert t['tag'] == 'Var' and t['id'] not in seen, ('nonfresh binder', t)
        counter = 4294967295 - t['id']
        assert schema['fresh'] <= counter < analysis['fresh'], ('fresh range', t)
        seen.add(t['id']); env[t['id']] = owner
    def below(origin, want):
        return origin == want or (origin and origin[0] == 'field' and below(origin[1], want))
    def walk(t, env, org):
        tag, kids = t['tag'], t['kids']; counts[tag] += 1
        if tag == 'NO_Return':
            assert len(kids) == 1; atom(kids[0], schema['observation'], env)
        elif tag == 'NO_Error': assert not kids and t['name'] == 'ERR_FIDS'
        elif tag == 'NO_Let':
            assert len(kids) == 2 and kids[0]['tag'] == 'NOp'
            op = kids[0]; arguments, result = operations[op['name']]
            assert len(arguments) == len(op['kids'])
            for arg, expected in zip(op['kids'], arguments): atom(arg, expected, env)
            next_env = dict(env); bind({'tag':'Var','id':t['id']}, next_env, result)
            walk(kids[1], next_env, org)
        elif tag == 'NO_Match':
            assert len(kids) == 4 and kids[0]['tag'] == 'Var' and kids[1]['tag'] == 'NO_Fields'
            spec = specs[t['name']]; layout = spec['layout']; fields = kids[1]['kids']
            assert env[kids[0]['id']] == spec['owner']
            assert len(fields) == len(spec['fields']) == layout['width']
            assert ((layout['storage'] == 'Boxed' and 2 <= len(fields) <= 8)
                or (layout['storage'] in ('Succ','Char') and len(fields) == 1)
                or (layout['storage'] == 'Nullary' and not fields))
            yes_env, yes_org = dict(env), dict(org)
            for i, (field, owner) in enumerate(zip(fields, spec['fields'])):
                bind(field, yes_env, owner)
                yes_org[field['id']] = ('field', org.get(kids[0]['id']), t['name'], i)
            walk(kids[2], yes_env, yes_org); walk(kids[3], env, org)
        elif tag == 'NO_Loop':
            assert len(kids) == len(params); strict = False
            for i, (arg, parameter) in enumerate(zip(kids, params)):
                atom(arg, parameter['name'], env)
                if i in roots:
                    assert arg['tag'] == 'Var'
                    origin, want = org.get(arg['id']), ('arg', i)
                    assert below(origin, want), ('root migration', i, origin)
                    strict |= origin != want
            assert strict, 'loop not structurally smaller'
        else: raise AssertionError(('unknown statement', t))
    leaves=[]; shells=0
    def wrapper(t):
        nonlocal shells
        if t['tag']=='Var': leaves.append(t['id'])
        else:
            assert t['tag']=='Ctr'; shells+=1
            for child in t['kids']: wrapper(child)
    wrapper(schema['wrapper'])
    assert 1 <= shells <= 2
    assert sorted(leaves) == sorted([params[i]['id'] for i in roots]+[schema['result']])
    walk(analysis['body'], kinds, origins)
    return {'owner':record['owner'],'counts':dict(counts),'uniqueIds':len(seen),
        'remainingFuel':analysis['fuel'],'nextFreshCounter':analysis['fresh'],'passed':True}

if __name__ == '__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--query',action='append',required=True)
    parser.add_argument('--capture',action='append',required=True);parser.add_argument('--out',required=True)
    args=parser.parse_args();operations={};results=[]
    for path in args.capture:
        core=json.loads(Path(path).read_text())['core']
        for d in core['records']+core['dependencies']:
            if d.get('scalarPrimitive'):
                tel=d['telescope'];signature=([t['name'] for t in tel['parameters']],tel['result']['name'])
                key=d['nativePrimitive'];assert key not in operations or operations[key]==signature
                operations[key]=signature
    for path in args.query:
        query=json.loads(Path(path).read_text());assert query['complete'] and query['inputsUnchanged']
        for record in query['records']:
            if record['accepted']: results.append({'query':path,**audit(record,operations)})
            elif not record['permission']:
                assert record['analysis']['fresh']==0 and record['analysis']['fuel']==4096
    result={'kind':'phase70-independent-residual-data-audit-v1','scope':'Bend-produced plans, no target execution or source-semantic equivalence claim',
        'inputs':[{'path':p,'sha256':digest(p)} for p in args.query+args.capture],'results':results}
    Path(args.out).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(results))
