"""Independent complete selector observations; no production source parsing."""
import copy
import json

BRANCHES = {
    'infer_node': [('Var',), ('Ref',), ('Typ',), ('Qnt',), ('Qua',), ('Min',), ('All',), ('App',), ('ADT',), ('Eql',), ('Ann',)],
    'check_node': [('Lam',), ('Ctr',), ('Mat', 'Efq'), ('Rfl',), ('Hol',), ('Let',), ('Rwt',)],
    'ka_node': [('Ann',), ('Lam',), ('App',), ('Ctr',), ('Mat',), ('Let',), ('Rwt',)],
    'ka_type_node': [('Var',), ('Ref',), ('Ann',), ('App',), ('ADT',), ('Eql',), ('Qua', 'Min'), ('Typ', 'Qnt', 'All')],
}


def wire(x):
    if isinstance(x, str): return [ord(c) for c in x]
    if isinstance(x, list): return [wire(a) for a in x]
    return x


def expected(t):
    tag = t[1] if t[0] == 0 else 'Lam' if t[0] == 1 else 'Lit'
    choices = [next((i for i, keys in enumerate(bs) if tag in keys), len(bs)) for bs in BRANCHES.values()]
    return wire([choices, tag, t[0] == 2, copy.deepcopy(t)])


def cases():
    recognized = list(dict.fromkeys(tag for bs in BRANCHES.values() for keys in bs for tag in keys))
    tags = recognized + ['Lit', 'FUnboundVar', 'Absent', '', 'V', 'Va', 'Varx', 'var', 'VAR', 'Matx', 'Ef', 'Efqx', '\x00Var', 'Var\x00', 'Λ', '🍎', 'unknown-' * 9]
    child = [0, 'Var', 'nested:λ', 4294967295, 1, [], ['duplicate', 'duplicate'], 41, 93]
    terms = [[0, tag, 'payload:🍎', i + 7, i % 4, [copy.deepcopy(child), copy.deepcopy(child)], ['R', 'R', 'λ'], 17, 4294967295] for i, tag in enumerate(tags)]
    terms += [[1, 'lambda:λ', 4294967295, 2, [copy.deepcopy(child)], ['A', 'A'], 13, 29, b] for b in [False, True]]
    terms += [[2, kind, number, text, begin, end] for kind, number, text, begin, end in [('U32', 4294967295, '', 9, 19), ('String', 0, 'α\n🍎\x00', 0, 4294967295), ('arbitrary-kind', 7, 'payload', 3, 5)]]
    return [dict(id='dispatch-full-value-' + str(i).zfill(3), family='exact-selector-retained-term', input=t, expectedWire=expected(t)) for i, t in enumerate(terms)]


def quote(x):
    # Bend accepts \0 as the NUL escape, not JSON's \u0000.
    return json.dumps(x, ensure_ascii=False).replace('\\u0000', '\\0')


def bend_list(xs, show):
    return '[' + ', '.join(show(x) for x in xs) + ']' if xs else 'Nil{}'


def bend_term(t):
    if t[0] == 0:
        _, tag, name, ident, quant, kids, removed, begin, end = t
        fields = [quote(tag), quote(name), str(ident), str(quant), bend_list(kids, bend_term), bend_list(removed, quote), str(begin), str(end)]
        return 'KTerm{' + ', '.join(fields) + '}'
    if t[0] == 1:
        _, name, ident, quant, kids, removed, begin, end, present = t
        fields = [quote(name), str(ident), str(quant), bend_list(kids, bend_term), bend_list(removed, quote), str(begin), str(end), 'True{}' if present else 'False{}']
        return 'KLambda{' + ', '.join(fields) + '}'
    _, kind, number, text, begin, end = t
    return 'KLiteral{' + ', '.join([quote(kind), str(number), quote(text), str(begin), str(end)]) + '}'
