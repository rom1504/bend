"""Independent finite specifications and deterministic cases; no compiler imports."""
import copy
import json


def quote(value):
    return json.dumps(value, ensure_ascii=False)


def wire(value):
    if isinstance(value, str):
        return [ord(c) for c in value]
    if isinstance(value, list):
        return [wire(x) for x in value]
    return value


def term(tag='Ref', name='', ident=0, quant=0, kids=None, removed=None, begin=0, end=0):
    return [0, tag, name, ident, quant, kids or [], removed or [], begin, end]


def lam(name, ident, body, present=True):
    return [1, name, ident, 2, [body], ['hidden', 'hidden'], 11, 19, present]


def literal(kind='U32', number=17, text='', begin=3, end=7):
    return [2, kind, number, text, begin, end]


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


def examples():
    leaf = term('Var', 'x', 7, begin=4, end=6)
    return [term('Ref', 'ns:α', removed=['A', 'A', 'B'], begin=1, end=9),
            term('Ctr', 'Pair', quant=1, kids=[leaf, leaf], removed=['R', 'R'], begin=2, end=14),
            lam('x', 7, leaf, False), lam('x', 7, leaf, True),
            literal(), literal('String', 0, 'α\n🍎', 20, 25)]


def array(parts):
    return '"[" ++ ' + ' ++ "," ++ '.join(parts) + ' ++ "]"'


def tag(t):
    return t[1] if t[0] == 0 else 'Lam' if t[0] == 1 else 'Lit'


def ident(t):
    return t[3] if t[0] == 0 else t[2] if t[0] == 1 else 0


def children(t):
    return t[5] if t[0] == 0 else t[4] if t[0] == 1 else []


def substitute(t, target, replacement):
    """Structural capture-free substitution on globally unique IDs, then beta.

    An App is rebuilt even if the requested ID is absent. The corpus uses
    well-shaped two-child Apps and one-body Lambdas, never malformed arities.
    """
    if tag(t) == 'Var':
        return copy.deepcopy(replacement if ident(t) == target else t)
    out = copy.deepcopy(t)
    if t[0] == 2:
        return out
    kids = [substitute(x, target, replacement) for x in children(t)]
    out[5 if t[0] == 0 else 4] = kids
    if tag(t) == 'App':
        function, argument = kids
        if tag(function) == 'Lam':
            return substitute(children(function)[0], ident(function), argument)
        # Application construction preserves source span but canonicalizes
        # tag/name/id/quantity/removals, as the independent beta syntax requires.
        return term('App', kids=kids, begin=t[7], end=t[8])
    return out


def has_variable(t):
    return tag(t) == 'Var' or any(has_variable(k) for k in children(t))


def definition(name, serial, unsafe=False):
    return [0, name, 'Def', 0, 0, term('ADT', 'Nat'), literal('Nat', serial, '', serial, serial + 1), [], False, unsafe]


def absent():
    return [0, '', 'Absent', 0, 0, term('Absent'), term('Absent'), [], False, False]


def bend_def(d):
    _, name, kind, arity, templates, typ, value, ctors, native, unsafe = d
    return 'KDef{' + ', '.join([quote(name), quote(kind), str(arity), str(templates), bend_term(typ), bend_term(value), bend_list(ctors, bend_def), 'True{}' if native else 'False{}', 'True{}' if unsafe else 'False{}']) + '}'


def find(book, name):
    return next((copy.deepcopy(d) for d in book if d[1] == name), absent())


def put(book, d):
    return [d] + [x for x in book if x[1] != d[1]]


def final_events(events, done):
    # Declarative last-event-wins order: descending last positions, followed
    # by untouched prior rows in their original order, including duplicates.
    last = {d[1]: i for i, d in enumerate(events)}
    return [events[i] for i in sorted(last.values(), reverse=True)] + [d for d in done if d[1] not in last]


def hash_name(name):
    value = 2166136261
    for char in name:
        value = ((value ^ ord(char)) * 16777619) & 0xffffffff
    return value


def set_tree(keys):
    """Canonical low-bit partition of a mathematical set, without insertion."""
    keys = sorted(set(keys))
    if not keys: return [0]
    if len(keys) == 1: return [1, keys[0]]
    mask = next(1 << i for i in range(32) if len({(x >> i) & 1 for x in keys}) == 2)
    return [2, mask, set_tree([x for x in keys if not x & mask]), set_tree([x for x in keys if x & mask])]


def bend_set(keys):
    out = 'NU_Empty{}'
    for key in keys:
        out = f'nu_add({out}, {key})'
    return out


def used_ids(t):
    if tag(t) == 'Var': return {ident(t)}
    return set().union(*(used_ids(k) for k in children(t))) if children(t) else set()


def bend_binding(b):
    ident, word, kind = b
    return f'NC_Binding{{{ident}, {quote(word)}, { ["N_W32{}", "N_W64{}", "N_Box{}"][kind] }}}'


def ctor_encode(name):
    return '$ctor.' + ''.join(str(ord(c)) + '_' for c in name)


def make_cases():
    cases = []

    def add(family, expression, expected, inputs):
        cases.append(dict(id=f'{family}-{sum(x["family"] == family for x in cases):03}',
                          family=family, expression=expression, expected=expected,
                          expectedWire=wire(expected), inputs=inputs))

    replacements = [[], [literal('Nat', 0)], [term('Ref', 'dup'), term('Ref', 'dup')]]
    for t in examples():
        for new in replacements:
            changed = copy.deepcopy(t)
            if t[0] != 2:
                changed[5 if t[0] == 0 else 4] = new
            add('children-update', f'p96.term(k_with_children({bend_term(t)}, {bend_list(new, bend_term)}))', changed, [t, new])
        for begin, end in [(0, 0), (1, 2), (31, 57)]:
            changed = copy.deepcopy(t)
            if t[0] == 0: changed[7:9] = [begin, end]
            elif t[0] == 1: changed[6:8] = [begin, end]
            else: changed[4:6] = [begin, end]
            add('span-update', f'p96.term(k_with_span({bend_term(t)}, {begin}, {end}))', changed, [t, begin, end])

    for t in examples():
        if t[0] == 0:
            expected = [t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[1] == 'Lam', 0, '', t]
        elif t[0] == 1:
            expected = ['Lam', t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], 0, '', t]
        else:
            expected = ['Lit', t[1], 0, 0, [], [], t[4], t[5], False, t[2], t[3], t]
        observations = ['p96.string(tg(t))', 'p96.string(nm(t))', 'U32.show(ix(t))', 'U32.show(qt(t))', 'p96.terms(ks(t))', 'p96.strings(rm(t))', 'U32.show(kb(t))', 'U32.show(ke(t))', 'p96.bool(k_quantity_present(t))', 'U32.show(kl_number(t))', 'p96.string(kl_text(t))', 'p96.term(t)']
        add('projections', '+t : KTerm = ' + bend_term(t) + '\n' + array(observations), expected, [t])
        new_kids, removed = [literal('Nat', 3)], ['z', 'z', 'α']
        changed = ([0, t[1], 'new', 41, 1, new_kids, removed, 61, 73] if t[0] == 0 else
                   [1, 'new', 41, 1, new_kids, removed, 61, 73, t[8]] if t[0] == 1 else t)
        expr = '+old : KTerm = ' + bend_term(t) + '\n+new : KTerm = k_rebuild(old, "new", 41, 1, ' + bend_list(new_kids, bend_term) + ', ' + bend_list(removed, quote) + ', 61, 73)\n'
        add('structural-rebuild', expr + array(['p96.term(new)', 'p96.term(old)']), [changed, t], [t, 'new', 41, 1, new_kids, removed, 61, 73])

    var7, var9 = term('Var', 'x', 7, begin=8, end=9), term('Var', 'y', 9)
    identity = lam('z', 101, term('Var', 'z', 101))
    terms = [var7, var9, literal(), term('Ctr', 'Triple', quant=1, kids=[var7, var7, var9], removed=['R', 'R'], begin=2, end=15),
             lam('z', 101, term('Ctr', 'Pair', quant=1, kids=[var7, term('Var', 'z', 101)]), False),
             term('App', kids=[term('Ref', 'f'), var7], begin=20, end=27),
             term('App', kids=[identity, var7], begin=30, end=38),
             term('App', kids=[identity, literal('Nat', 5)], begin=40, end=49)]
    replacement = literal('String', 0, 'replacement', 80, 92)
    for t in terms:
        for target in [7, 404]:
            add('substitution-beta', f'p96.term(subst({bend_term(t)}, {target}, {bend_term(replacement)}))', substitute(t, target, replacement), [t, target, replacement])
    stable = [literal(), term('Ref', 'closed'), term('Ctr', 'Pair', quant=1, kids=[literal(), term('Ref', 'closed')], removed=['A', 'A'], begin=5, end=8),
              lam('unused', 101, literal('Nat', 3), False), term('App', kids=[term('Ref', 'f'), literal()], begin=1, end=4)]
    for t in stable:
        assert not has_variable(t)
        expr = '+t : KTerm = ' + bend_term(t) + '\n' + array(['p96.bool(core_subst_stable(t))', f'p96.term(subst(t, 7, {bend_term(replacement)}))', 'p96.term(t)'])
        add('stable-substitution', expr, [True, t, t], [t, 7, replacement])
    # False certificates are retained, without claiming their converse.
    for t in [var7, terms[-1]]:
        add('stable-substitution', f'p96.bool(core_subst_stable({bend_term(t)}))', False, [t])

    names = ['', 'a', 'aa', 'a:b', 'a.b', 'α', '🍎']
    for values in [[], ['a'], ['a', 'a', 'α', '🍎'], ['aa', '', 'a:b', 'a.b']]:
        for key in names:
            xs = bend_list(values, quote)
            add('membership', array([f'p96.bool(has_name({xs}, {quote(key)}))', f'p96.bool(nb_contains({xs}, {quote(key)}))', f'p96.strings({xs})']), [key in values, key in values, values], [values, key])

    assert hash_name('costarring') == hash_name('liquid') == 0x5e4daa9d
    books = [[], [definition('a', 1)], [definition('a', 1), definition('a', 2, True), definition('α', 3), definition('z', 4)],
             [definition('costarring', 5), definition('liquid', 6), definition('costarring', 7), definition('🍎', 8)]]
    for book in books:
        for key in ['a', 'α', 'missing', 'costarring', 'liquid', '🍎']:
            bs = bend_list(book, bend_def)
            add('lookup-shadowing', f'p96.def(lookup({bs}, {quote(key)}))', find(book, key), [book, key])
            expr = '+book : List<&2,KDef> = ' + bs + '\n+cache : List<&2,KDef> = book_cached(book, 117)\n' + array([f'p96.def(lookup(cache, {quote(key)}))', 'p96.defs(book)', 'p96.defs(p96.cache_events(cache))'])
            add('cached-lookup', expr, [find(book, key), book, book], [book, key, 117])
        overlay = [definition('a', 30), definition('new', 31), definition('a', 32, True)]
        current = book
        for d in overlay: current = put(current, d)
        expr = '+book : List<&2,KDef> = ' + bend_list(book, bend_def) + '\n+updated : List<&2,KDef> = book_put_many(book, ' + bend_list(overlay, bend_def) + ')\n'
        add('book-update', expr + array(['p96.defs(updated)', 'p96.defs(book)']), [current, book], [book, overlay])
        d = definition('costarring', 41)
        expr = '+book : List<&2,KDef> = ' + bend_list(book, bend_def) + '\n+cache : List<&2,KDef> = book_cached(book, 117)\n+updated : List<&2,KDef> = book_put(cache, ' + bend_def(d) + ')\n'
        add('book-update', expr + array(['p96.defs(p96.cache_events(updated))', 'p96.defs(p96.cache_events(cache))', 'p96.def(lookup(updated, "costarring"))', 'p96.def(lookup(cache, "costarring"))']), [put(book, d), book, d, find(book, 'costarring')], [book, d])

    done = [definition('event2', 800), definition('prior', 801), definition('prior', 802)]
    for count in [0, 1, 7, 8, 255, 256, 257]:
        events = [definition('event' + str(i % 7), i) for i in range(count)]
        expression = f'p96.defs(book_final_fast(p96.events({count}n, 0), {bend_list(done, bend_def)}))'
        add('final-events', expression, final_events(events, done), dict(generatedEvents=dict(count=count, first=0, nameModulo=7), done=done))

    key_sets = [[], [0], [0, 0, 1, 1], [0, 1, 2, 3, 7], [0xffffffff, 0x80000000, 0, 1], [3, 2, 1, 0, 3]]
    for keys in key_sets:
        queries = sorted(set(keys + [0, 1, 31, 0x80000000, 0xffffffff]))
        expr = '+s : NU_Set = ' + bend_set(keys) + '\n' + array(['p96.set(s)', array([f'p96.bool(nu_has(s, {key}))' for key in queries]), 'p96.set(s)'])
        add('occurrence-analysis', expr, [set_tree(keys), [key in keys for key in queries], set_tree(keys)], dict(keys=keys, queries=queries))
    for t in terms + stable:
        add('occurrence-analysis', f'p96.set(nc_uses({bend_term(t)}))', set_tree(used_ids(t)), [t])

    envs = [[], [[7, 'first', 2], [7, 'second', 0], [9, 'nine', 1], [17, 'last', 2]], [[9, 'x', 0], [7, 'y', 1], [9, 'z', 2]]]
    for env in envs:
        for key in [7, 9, 17, 404]:
            match = next((i for i, row in enumerate(env) if row[0] == key), None)
            expected_word = env[match][1] if match is not None else 'NATIVE_UNBOUND_VARIABLE'
            rest = env if match is None else env[:match] + env[match + 1:]
            expr = '+env : List<&2,NC_Binding> = ' + bend_list(env, bend_binding) + '\n' + array([f'p96.string(nc_word({key}, env))', f'p96.env(nc_remove_env(env, {key}))', 'p96.env(env)'])
            add('environment-selection', expr, [expected_word, rest, env], [env, key])
        for keys in [[], [7], [7, 9], [17, 404]]:
            live = [row for row in env if row[0] in keys]
            drops = ''.join('term_sink(e, ' + row[1] + ');\n' for row in env if row[0] not in keys)
            t = term('Ctr', 'EnvironmentWitness', quant=1, kids=[term('Var', 'v', key) for key in keys])
            expr = '+env : List<&2,NC_Binding> = ' + bend_list(env, bend_binding) + '\n+uses : NU_Set = ' + bend_set(keys) + '\n' + array(['p96.partition(nc_partition_uses(env, uses))', 'p96.env(nc_live_uses(env, uses))', f'p96.partition(nc_prepare_env(env, {bend_term(t)}))', 'p96.env(env)'])
            add('environment-partition', expr, [[live, drops], live, [live, drops], env], [env, keys, t])

    for name in ['', 'a', 'A', 'a.b', 'a:b', 'a_b', 'α', '🍎', '中α🍎', '$ctor.97_']:
        encoded = ctor_encode(name)
        add('constructor-encoding', array([f'p96.string(nc_ctor_encode({quote(name)}))', f'p96.string(nc_ctor_display(nc_ctor_encode({quote(name)})))']), [encoded, name], [name])
    # These are ordinary scalar strings, not malformed runtime values.
    for encoded in ['$ctor.097_', '$ctor.55296_', '$ctor.1114112_', '$ctor.97', '$ctor.x_', 'plain']:
        add('constructor-encoding', f'p96.string(nc_ctor_display({quote(encoded)}))', encoded, [encoded])
    for chunks, sep in [([], ','), ([''], ','), (['a', '', 'b'], '|'), (['α', '🍎', 'α'], ':'), (['x', 'x'], '')]:
        xs = bend_list(chunks, quote)
        add('text-assembly', array([f'p96.string(nt_join({xs}, {quote(sep)}))', f'p96.string(nt_text_finish({xs}, "tail"))', f'p96.strings(nt_append(String, {xs}, ["z", "z"]))']), [sep.join(chunks), ''.join(reversed(chunks)) + 'tail', chunks + ['z', 'z']], [chunks, sep])
    return cases
