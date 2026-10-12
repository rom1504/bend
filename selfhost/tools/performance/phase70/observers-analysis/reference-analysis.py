#!/usr/bin/env python3
"""Pure-data specification of bounded observer analysis, not a compiler backend.

Reads a root-produced capture-core-v3 receipt. No compiler or target execution.
The production implementation must be in Bend and independently qualified.
"""
from __future__ import annotations
import argparse
import hashlib
import itertools
import json
from dataclasses import dataclass, field
from pathlib import Path


def node(tag, name='', ident=0, kids=()):
    return dict(tag=tag, name=name, id=ident, quant=0, kids=list(kids), removed=[])


def truth(x):
    return x is True or isinstance(x, dict) and x.get('$') == 'True'


class Refusal(Exception):
    pass


@dataclass
class Value:
    tag: str
    atom: dict | None = None
    origin: tuple | None = None
    kind: str = ''
    name: str = ''
    fields: tuple = ()
    term: dict | None = None
    env: dict = field(default_factory=dict)
    stack: tuple = ()


class Analyzer:
    def __init__(self, capture, owner, root_order=None, budget=4096):
        self.defs = {d['name']: d for d in capture['dependencies']}
        self.adts = {d['name']: d for d in capture['adts']}
        self.owner = owner
        self.definition = self.defs[owner]
        self.fuel = self.budget = budget
        self.maximum_depth = 0
        self.expansions = self.tail_calls = self.matches = self.returns = 0
        self.layouts = {}
        self.ctor_info = {}
        self.source_ids = set()
        def ids(t):
            self.source_ids.add(t['id'])
            for c in t['kids']: ids(c)
        for d in self.defs.values(): ids(d['nativeBody'])
        self.next_id = max(self.source_ids, default=0) + 1
        self.root_types = {}
        self._index_types()
        self.parameters = []
        self.root_indices = []
        for i, typ in enumerate(self.definition['telescope']['parameters']):
            name = self.type_name(typ)
            if name in self.root_types:
                kind = 'BorrowRoot:' + name
                self.root_indices.append(i)
            elif self.scalar_type(name):
                kind = 'Immediate:' + name
            else: raise Refusal('unsupported parameter layout: ' + name)
            ident = self.fresh()
            self.parameters.append(Value('atom', node('Var', ident=ident), ('param', i), kind))
        if not 1 <= len(self.root_indices) <= 2:
            raise Refusal('requires one or two immutable roots')
        self.root_order = list(root_order or self.root_indices)
        self.result_id = self.fresh()
        self.observation_kind = ''
        self.wrapper = self._wrapper(self.definition['telescope']['resultSchema'], iter(self.root_order), [0])

    def tick(self):
        self.fuel -= 1
        if self.fuel < 0: raise Refusal('global candidate budget exhausted')

    def fresh(self):
        self.next_id += 1
        if self.next_id >= 2**32: raise Refusal('fresh ID space exhausted')
        return self.next_id

    @staticmethod
    def type_name(t):
        if t['tag'] not in ('Ref', 'ADT') or t['kids']:
            return '<dependent-or-instantiated>'
        return t['name']

    def scalar_type(self, name):
        d = self.adts.get(name)
        if not d: return False
        if truth(d['native']) and name in ('Nat', 'Char', 'U32', 'F32'):
            return True
        return bool(d['ctors']) and all(c['arity'] == 0 for c in d['ctors'])

    def _index_types(self):
        # Descriptor construction is structural. Builtin representation names
        # denote backend ABI rules, never optimized function names.
        for name, d in self.adts.items():
            if d['arity'] or d['templates']: continue
            identities = {c['name']: c['identity'] for c in d['constructorIdentities']}
            ctors = []
            for c in d['ctors']:
                fields = []
                t = c['type']
                while t['tag'] == 'All':
                    if t['quant'] == 0: break
                    fields.append(self.type_name(t['kids'][0])); t = t['kids'][1]
                if len(fields) != c['arity']: continue
                ctors.append((c, identities[c['name']], fields))
            nulls = [r for r in ctors if not r[2]]
            cons = [r for r in ctors if len(r[2]) >= 2 and r[2].count(name) == 1
                    and all(f == name or self.scalar_type(f) for f in r[2])]
            if len(ctors) == 2 and len(nulls) == 1 and len(cons) == 1 and name not in ('Nat', 'U32', 'F32', 'Char', 'Word.Nil', 'Word.Con', 'Array'):
                self.root_types[name] = [nulls[0], cons[0]]
            for c, identity, fields in ctors:
                storage = 'Nullary' if not fields else None
                if truth(d['native']) and name == 'Nat' and c['name'] == 'Succ': storage = 'Succ'
                if truth(d['native']) and name == 'Char' and c['name'] == 'Chr': storage = 'Char'
                if name in self.root_types and fields: storage = 'Boxed'
                if storage:
                    self.ctor_info[identity] = dict(key=identity, ctor=identity, owner=name,
                        storage=storage, width=len(fields), fieldTypes=fields)

    def _wrapper(self, schema, roots, count):
        if 'fields' in schema:
            count[0] += 1
            if count[0] > 2: raise Refusal('more than two result shells')
            return node('Ctr', schema['ctor'], kids=[self._wrapper(x, roots, count) for x in schema['fields']])
        name = self.type_name(schema['type'])
        if name in self.root_types:
            try: index = next(roots)
            except StopIteration: raise Refusal('too many result roots')
            if self.parameters[index].kind != 'BorrowRoot:' + name: raise Refusal('root projection type mismatch')
            return self.parameters[index].atom
        if not self.scalar_type(name) or self.observation_kind: raise Refusal('requires exactly one scalar result')
        self.observation_kind = 'Immediate:' + name
        return node('Var', ident=self.result_id)

    def scalar_atom(self, v):
        if v.tag == 'atom' and v.kind.startswith('Immediate'): return v.atom
        if v.tag == 'ctr' and not v.fields:
            desc = self.ctor_info.get(v.name)
            if desc and self.scalar_type(desc['owner']): return node('Ctr', v.name)
        if v.tag == 'ctr' and v.name == 'Chr' and len(v.fields) == 1:
            return self.scalar_atom(v.fields[0])
        raise Refusal('non-immediate scalar operand')

    def equal_origin(self, v, origin, facts):
        if v.origin == origin: return True
        shape = facts.get(origin)
        return (v.tag == 'ctr' and shape is not None and v.name == shape[0]
                and len(v.fields) == len(shape[1])
                and all(self.equal_origin(x, p, facts) for x, p in zip(v.fields, shape[1])))

    def finish(self, value, facts):
        found = []
        root_by_id = {v.atom['id']: v.origin for v in self.parameters if v.kind.startswith('BorrowRoot:')}
        def check(v, template):
            if template['tag'] == 'Var':
                if template['id'] == self.result_id: found.append(self.scalar_atom(v)); return
                if not self.equal_origin(v, root_by_id[template['id']], facts): raise Refusal('returned root is changed or unproved')
                return
            if v.tag != 'ctr' or v.name != template['name'] or len(v.fields) != len(template['kids']):
                raise Refusal('result wrapper mismatch')
            for x, y in zip(v.fields, template['kids']): check(x, y)
        check(value, self.wrapper)
        if len(found) != 1: raise Refusal('observation multiplicity')
        self.returns += 1
        return node('NO_Return', kids=found)

    def eval(self, t, env, facts, stack, k):
        self.tick()
        tag, kids = t['tag'], t['kids']
        if tag == 'Var':
            if t['id'] not in env: raise Refusal('unbound source variable')
            return k(env[t['id']], facts)
        if tag == 'NWord': return k(Value('atom', t, ('constant', t['name']), 'Immediate'), facts)
        if tag in ('Lam', 'Mat'): return k(Value(tag.lower(), term=t, env=env.copy(), stack=stack), facts)
        if tag == 'Ref':
            if t['quant'] == 3: raise Refusal('bang call')
            return k(Value('ref', name=t['name'], stack=stack), facts)
        if tag == 'App':
            return self.eval(kids[0], env, facts, stack, lambda f, q: self.eval(kids[1], env, q, stack, lambda a, r: self.apply(f, a, r, k)))
        if tag == 'Ctr':
            return self.eval_args(kids, env, facts, stack, (), lambda xs, q: k(Value('ctr', name=t['name'], fields=xs), q))
        if tag in ('Ann', 'Loc', 'Src', 'Cut', 'Slf', 'Ins'): return self.eval(kids[0], env, facts, stack, k)
        if tag == 'Efq': return node('NO_Error', 'ERR_FIDS')
        if tag == 'Let' and len(kids) == 2 and kids[0]['tag'] == 'Bind':
            b = kids[0]
            return self.eval(b['kids'][0], env, facts, stack, lambda v, q: self.eval(kids[1], {**env, b['id']: v}, q, stack, k))
        raise Refusal('unsupported evaluated core tag: ' + tag)

    def eval_args(self, ts, env, facts, stack, acc, k):
        if not ts: return k(acc, facts)
        return self.eval(ts[0], env, facts, stack, lambda v, q: self.eval_args(ts[1:], env, q, stack, acc + (v,), k))

    def apply_all(self, f, args, facts, k):
        if not args: return k(f, facts)
        return self.apply(f, args[0], facts, lambda v, q: self.apply_all(v, args[1:], q, k))

    def apply(self, f, arg, facts, k):
        self.tick()
        if f.tag == 'lam': return self.eval(f.term['kids'][0], {**f.env, f.term['id']: arg}, facts, f.stack, k)
        if f.tag == 'mat': return self.match(f, arg, facts, k)
        if f.tag != 'ref': raise Refusal('dynamic application')
        d = self.defs.get(f.name)
        if not d: raise Refusal('unknown reference: ' + f.name)
        args = f.fields + (arg,)
        arity = len(d['telescope']['parameters'])
        if len(args) < arity: return k(Value('ref', name=f.name, fields=args, stack=f.stack), facts)
        if len(args) != arity: raise Refusal('call saturation')
        if f.name == self.owner: return self.recur(args, facts, k)
        if d.get('nativePrimitive') and truth(d['scalarPrimitive']):
            words = [self.scalar_atom(v) for v in args]
            kind = self.type_name(d['telescope']['result'])
            if not self.scalar_type(kind): raise Refusal('primitive result not immediate')
            ident = self.fresh()
            value = Value('atom', node('Var', ident=ident), ('computed', ident), 'Immediate:' + kind)
            body = k(value, facts)
            return node('NO_Let', ident=ident, kids=[node('NOp', d['nativePrimitive'], kids=words), body])
        if f.name in f.stack or len(f.stack) >= 8: raise Refusal('helper cycle or depth limit')
        if d['kind'] != 'Def': raise Refusal('foreign or absent helper')
        self.expansions += 1
        self.maximum_depth = max(self.maximum_depth, len(f.stack) + 1)
        return self.eval(d['nativeBody'], {}, facts, f.stack + (f.name,), lambda g, q: self.apply_all(g, args, q, k))

    def match(self, f, arg, facts, k):
        name = f.term['name']
        hit, miss = f.term['kids']
        if arg.tag == 'ctr':
            branch, args = (hit, arg.fields) if name == arg.name else (miss, (arg,))
            return self.eval(branch, f.env, facts, f.stack, lambda g, q: self.apply_all(g, args, q, k))
        if arg.tag != 'atom': raise Refusal('matcher on non-value')
        desc = self.ctor_info.get(name)
        if not desc: raise Refusal('unsupported matcher representation: ' + name)
        expected = 'BorrowRoot:' + desc['owner'] if desc['owner'] in self.root_types else 'Immediate:' + desc['owner']
        if arg.kind != expected and not (arg.kind == 'Immediate' and expected.startswith('Immediate:')):
            raise Refusal('matcher value/descriptor type mismatch')
        if f.term['id'] != desc['width'] + 1: raise Refusal('matcher width mismatch')
        fields = []
        for i, typ in enumerate(desc['fieldTypes']):
            ident = self.fresh()
            kind = ('BorrowRoot:' if typ in self.root_types else 'Immediate:') + typ
            fields.append(Value('atom', node('Var', ident=ident), ('field', arg.origin, desc['owner'], name, i), kind))
        hit_facts = {**facts, arg.origin: (name, tuple(x.origin for x in fields))}
        yes = self.eval(hit, f.env, hit_facts, f.stack, lambda g, q: self.apply_all(g, tuple(fields), q, k))
        no = self.eval(miss, f.env, facts, f.stack, lambda g, q: self.apply(g, arg, q, k))
        self.layouts[name] = {key: desc[key] for key in ('key', 'ctor', 'storage', 'width')}
        self.matches += 1
        return node('NO_Match', name, kids=[arg.atom, node('NO_Fields', kids=[x.atom for x in fields]), yes, no])

    def recur(self, args, facts, k):
        strict = False
        for i in self.root_indices:
            v = args[i]
            p = v.origin
            while p and p[0] == 'field': strict = True; p = p[1]
            if v.tag != 'atom' or v.kind != self.parameters[i].kind or p != self.parameters[i].origin:
                raise Refusal('recursive root is not original root or its field')
        if not strict: raise Refusal('recursive transition is not structural')
        marker = self.fresh()
        observed = Value('atom', node('Var', ident=marker), ('recursive-observation', marker), self.observation_kind)
        by_id = {p.atom['id']: a for p, a in zip(self.parameters, args)}
        def value(t):
            if t['tag'] == 'Var': return observed if t['id'] == self.result_id else by_id[t['id']]
            return Value('ctr', name=t['name'], fields=tuple(value(c) for c in t['kids']))
        rest = k(value(self.wrapper), facts)
        if rest['tag'] != 'NO_Return' or rest['kids'] != [observed.atom]:
            raise Refusal('recursive call has residual work or discarded observation')
        words = []
        for p, a in zip(self.parameters, args):
            if p.kind.startswith('BorrowRoot:'):
                if a.tag != 'atom': raise Refusal('non-atomic recursive cursor')
                words.append(a.atom)
            else: words.append(self.scalar_atom(a))
        self.tail_calls += 1
        return node('NO_Loop', kids=words)

    def run(self):
        body = self.eval(self.definition['nativeBody'], {}, {}, (), lambda f, q: self.apply_all(f, tuple(self.parameters), q, self.finish))
        if not self.matches or not self.returns: raise Refusal('no useful proved observer')
        return dict(owner=self.owner, params=[dict(id=p.atom['id'], kind=p.kind) for p in self.parameters],
                    roots=self.root_order, resultId=self.result_id, resultKind=self.observation_kind,
                    wrapper=self.wrapper, layouts=list(self.layouts.values()), body=body,
                    budget=dict(spent=self.budget-self.fuel, limit=self.budget, maximumHelperDepth=self.maximum_depth),
                    proof=dict(successfulReturns=self.returns, tailTransitions=self.tail_calls, helperExpansions=self.expansions,
                               binderStrategy='Invocation-local lexical environment; globally fresh runtime field/computation origins.'))


def analyze(capture, name, budget=4096):
    failures = []
    for order in (None, (1, 0)):
        try:
            a = Analyzer(capture, name, order, budget)
            if order and a.root_indices != [0, 1]: continue
            return dict(name=name, admitted=True, plan=a.run())
        except Refusal as e: failures.append(str(e))
    return dict(name=name, admitted=False, reasons=failures)


def main():
    p = argparse.ArgumentParser(); p.add_argument('--capture', type=Path, required=True);p.add_argument('--out', type=Path, required=True);p.add_argument('names', nargs='+');a=p.parse_args()
    assert not a.out.exists()
    raw=a.capture.read_bytes();receipt=json.loads(raw);assert receipt['complete']
    rows=[analyze(receipt['core'],name) for name in a.names]
    result=dict(kind='phase70-observer-reference-analysis-v1',targetExecuted=False,
                scope='Pure-data diagnostic specification; not production compiler admission or a host fallback.',
                capture=dict(path=str(a.capture.resolve()),sha256=hashlib.sha256(raw).hexdigest()),rows=rows)
    a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps([dict(name=r['name'],admitted=r['admitted'],reasons=r.get('reasons')) for r in rows]))


if __name__ == '__main__': main()
