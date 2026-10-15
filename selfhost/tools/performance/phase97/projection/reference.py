"""Independent first-match specification and complete positional constructor data."""
import copy
import json


def wire(value):
    if isinstance(value, str):
        return [ord(c) for c in value]
    if isinstance(value, list):
        return [wire(x) for x in value]
    return value


def quote(value):
    return json.dumps(value, ensure_ascii=False)


def show_list(values, show):
    return '[' + ', '.join(map(show, values)) + ']' if values else 'Nil{}'


def boolean(value):
    return 'True{}' if value else 'False{}'


def term(tag='Absent', name='', ident=0, quant=0, kids=None, removed=None, begin=0, end=0):
    return [0, tag, name, ident, quant, kids or [], removed or [], begin, end]


def show_term(t):
    if t[0] == 0:
        _, tag, name, ident, quant, kids, removed, begin, end = t
        fields = [quote(tag), quote(name), str(ident), str(quant), show_list(kids, show_term), show_list(removed, quote), str(begin), str(end)]
        return 'KTerm{' + ', '.join(fields) + '}'
    if t[0] == 1:
        _, name, ident, quant, kids, removed, begin, end, present = t
        fields = [quote(name), str(ident), str(quant), show_list(kids, show_term), show_list(removed, quote), str(begin), str(end), boolean(present)]
        return 'KLambda{' + ', '.join(fields) + '}'
    _, kind, number, text, begin, end = t
    return 'KLiteral{' + ', '.join([quote(kind), str(number), quote(text), str(begin), str(end)]) + '}'


def show_def(d):
    if d[0] == 1:
        return 'KIndexLeaf{' + str(d[1]) + ', ' + show_list(d[2], show_def) + '}'
    if d[0] == 2:
        return 'KIndexNode{' + ', '.join([str(d[1]), str(d[2]), show_def(d[3]), show_def(d[4])]) + '}'
    _, name, kind, arity, templates, typ, value, ctors, native, unsafe = d
    return 'KDef{' + ', '.join([quote(name), quote(kind), str(arity), str(templates), show_term(typ), show_term(value), show_list(ctors, show_def), boolean(native), boolean(unsafe)]) + '}'


def definition(name, serial):
    # Every scalar/metadata position is distinguishable; children/removals repeat.
    var = term('Var', 'x', serial + 17, 1, removed=['kept', 'kept'], begin=3, end=9)
    typ = term('All', 'binder', serial + 17, 2, [var, var], ['old', 'old', 'β'], 11, 37)
    value = [1, 'lambda', serial + 17, 1, [[2, 'String', serial, 'α\n🙂', 53, 71]], ['r', 'r'], 41, 89, serial % 2 == 0]
    ctor = [0, 'nested', 'Ctr', 1, 3, var, [2, 'U32', serial + 5, '', 97, 101], [], False, True]
    return [0, name, 'Def', serial + 1, serial + 7, typ, value, [ctor, copy.deepcopy(ctor)], serial % 2 == 0, serial % 3 == 0]


def name_of(d):
    return d[1] if d[0] == 0 else ''


def find(book, key):
    # First matching complete row; indexes expose the same neutral empty name
    # as the public KDef projection. This is not indexed lookup/tree traversal.
    hits = [i for i, row in enumerate(book) if name_of(row) == key]
    return copy.deepcopy(book[min(hits)]) if hits else [0, key, 'Missing', 0, 0, term(), term(), [], False, False]


def cases():
    a, b, dup = definition('same', 0), definition('middle', 1), definition('same', 2)
    leaf = [1, 0xffffffff, [a, b, dup]]
    node = [2, 0x5e4daa9d, 0x80000000, leaf, [1, 0, [dup]]]
    empty = definition('', 3)
    rows = [
        ('empty', [], 'missing'), ('empty-key-empty-book', [], ''),
        ('singleton-hit', [a], 'same'), ('singleton-miss', [a], 'missing'),
        ('first-duplicate', [a, b, dup], 'same'), ('middle', [a, b, dup], 'middle'),
        ('tail', [a, b, definition('tail', 4)], 'tail'), ('missing', [a, b, dup], 'missing'),
        ('empty-name', [b, empty, a], ''),
        ('unicode-hit', [definition('α', 5), definition('🙂', 6)], '🙂'),
        ('unicode-distinct', [definition('é', 7)], 'é'),
        ('prefix-distinct', [definition('prefix', 8), definition('prefix-long', 9)], 'prefix-'),
        ('collision-first', [definition('costarring', 10), definition('liquid', 11)], 'costarring'),
        ('collision-second', [definition('costarring', 10), definition('liquid', 11)], 'liquid'),
        ('index-leaf-empty-hit', [leaf, a], ''), ('index-node-empty-hit', [node, b], ''),
        ('index-leaf-skip', [leaf, a], 'same'), ('index-node-skip', [node, b], 'middle'),
        ('index-bucket-not-searched', [leaf], 'same'), ('index-children-not-searched', [node], 'same'),
        ('empty-before-index', [empty, node], ''), ('index-before-empty', [node, empty], ''),
        ('all-index-miss', [leaf, node], 'missing'), ('duplicate-tail-metadata', [b, dup, a], 'same'),
    ]
    result = []
    for label, book, key in rows:
        found = find(book, key)
        result.append(dict(id=label, book=book, key=key, expected=wire([name_of(found), found, book, key])))
    return result


def micro_row(i):
    return [0, 'module:worker~' + str(i), 'Def', i + 1, 7,
            term('ADT', 'U32', begin=3, end=9),
            [2, 'U32', i, '', 11, 19], [], True, False]


def micro_expected(repetitions, size, mode):
    assert 0 <= repetitions < 2**32 and 0 <= size < 2**32 - 1 and mode in range(4)
    book = [micro_row(i) for i in reversed(range(size))]
    index = [max(0, size - 1), size // 2, size, 0][mode]
    key = 'module:worker~' + str(index)
    found = find(book, key)
    return dict(initial=wire(found), successes=repetitions, final=wire(found), alias=wire(book), key=key)
