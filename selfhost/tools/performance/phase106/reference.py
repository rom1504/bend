#!/usr/bin/env python3
"""Independent bounded interpreter for the Phase106 experimental IR.

This is evaluation tooling, not a compiler dependency or a formal proof. It
checks initialized regions, bounds, call signatures and complete reclamation
for the finite inputs actually interpreted.
"""
import bisect
import json
import sys


class Returned(Exception):
    pass


class Interpreter:
    def __init__(self, program, limit=20_000_000):
        assert program['version'] == 1
        self.functions = {f['name']: f for f in program['functions']}
        assert len(self.functions) == len(program['functions'])
        self.entry = program['entry']
        self.function_addresses = {name: (1 << 60) + 16 * i
                                   for i, name in enumerate(self.functions)}
        self.address_functions = {v: k for k, v in self.function_addresses.items()}
        self.blocks = {}
        self.bases = []
        self.next_address = 4096
        self.steps = 0
        self.limit = limit
        self.allocations = self.frees = 0

    def tick(self):
        self.steps += 1
        assert self.steps <= self.limit, 'reference instruction budget exceeded'

    @staticmethod
    def width(typ):
        return {'u32': 4, 'u64': 8, 'ptr': 8}[typ]

    def region(self, address, width):
        index = bisect.bisect_right(self.bases, address) - 1
        assert index >= 0, ('invalid pointer', address)
        base = self.bases[index]
        data = self.blocks[base]
        assert data is not None, ('use after free', address)
        offset = address - base
        assert 0 <= offset and offset + width <= len(data), ('out of bounds', address, width)
        return data, offset

    def expr(self, expr, locals_):
        self.tick()
        kind = expr['kind']
        if kind == 'const':
            typ, value = expr['type'], expr['value']
            assert 0 <= value < (1 << (self.width(typ) * 8))
            assert typ != 'ptr' or value == 0
            return typ, value
        if kind == 'var':
            return locals_[expr['name']]
        if kind == 'func':
            return 'ptr', self.function_addresses[expr['name']]
        if kind == 'ptradd':
            pt, ptr = self.expr(expr['ptr'], locals_)
            bt, amount = self.expr(expr['bytes'], locals_)
            assert (pt, bt) == ('ptr', 'u32')
            return 'ptr', ptr + amount
        if kind == 'bin':
            typ, a = self.expr(expr['lhs'], locals_)
            other, b = self.expr(expr['rhs'], locals_)
            assert typ == other
            op = expr['op']
            predicates = {'eq': lambda: a == b, 'ne': lambda: a != b,
                          'ult': lambda: a < b, 'ule': lambda: a <= b,
                          'ugt': lambda: a > b, 'uge': lambda: a >= b}
            if op in predicates:
                assert typ != 'ptr' or op in ('eq', 'ne')
                return 'u32', int(predicates[op]())
            assert typ in ('u32', 'u64')
            bits = self.width(typ) * 8
            operations = {'add': lambda: a + b, 'sub': lambda: a - b,
                          'mul': lambda: a * b, 'and': lambda: a & b,
                          'or': lambda: a | b, 'xor': lambda: a ^ b,
                          'shl': lambda: a << (b & (bits - 1)),
                          'lshr': lambda: a >> (b & (bits - 1))}
            return typ, operations[op]() & ((1 << bits) - 1)
        if kind in ('call', 'icall'):
            values = [self.expr(arg, locals_) for arg in expr['args']]
            if kind == 'icall':
                typ, address = self.expr(expr['callee'], locals_)
                assert typ == 'ptr'
                name = self.address_functions[address]
                function = self.functions[name]
                assert expr['params'] == [p['type'] for p in function['params']]
                assert expr['result'] == function['result']
            else:
                name = expr['name']
            return self.call(name, values)
        if kind == 'alloc':
            typ, size = self.expr(expr['bytes'], locals_)
            assert typ == 'u32' and size <= 64 * 1024 * 1024
            size = max(size, 1)
            base = self.next_address
            self.next_address += ((size + 15) // 16) * 16 + 16
            self.bases.append(base)
            self.blocks[base] = bytearray(size)
            self.allocations += 1
            return 'ptr', base
        if kind == 'load':
            typ, ptr = self.expr(expr['ptr'], locals_)
            assert typ == 'ptr' and expr['offset'] >= 0
            width = self.width(expr['type'])
            data, offset = self.region(ptr + expr['offset'], width)
            return expr['type'], int.from_bytes(data[offset:offset + width], 'little')
        raise AssertionError(('unsupported expression', kind))

    def body(self, statements, locals_):
        for stmt in statements:
            self.tick()
            kind = stmt['kind']
            if kind == 'set':
                value = self.expr(stmt['value'], locals_)
                assert value[0] == locals_[stmt['name']][0]
                locals_[stmt['name']] = value
            elif kind == 'return':
                raise Returned(self.expr(stmt['value'], locals_))
            elif kind == 'if':
                typ, condition = self.expr(stmt['cond'], locals_)
                assert typ == 'u32'
                self.body(stmt['then'] if condition else stmt['else'], locals_)
            elif kind == 'while':
                while True:
                    typ, condition = self.expr(stmt['cond'], locals_)
                    assert typ == 'u32'
                    if not condition:
                        break
                    self.body(stmt['body'], locals_)
            elif kind == 'store':
                typ, ptr = self.expr(stmt['ptr'], locals_)
                vt, value = self.expr(stmt['value'], locals_)
                assert typ == 'ptr' and vt == stmt['type'] and stmt['offset'] >= 0
                width = self.width(vt)
                data, offset = self.region(ptr + stmt['offset'], width)
                data[offset:offset + width] = value.to_bytes(width, 'little')
            elif kind == 'free':
                typ, ptr = self.expr(stmt['ptr'], locals_)
                assert typ == 'ptr'
                if ptr:
                    assert ptr in self.blocks and self.blocks[ptr] is not None, 'invalid/double free'
                    self.blocks[ptr] = None
                    self.frees += 1
            else:
                raise AssertionError(('unsupported statement', kind))

    def call(self, name, values):
        self.tick()
        function = self.functions[name]
        assert len(values) == len(function['params'])
        locals_ = {}
        for param, value in zip(function['params'], values):
            assert param['type'] == value[0] and param['name'] not in locals_
            locals_[param['name']] = value
        for local in function.get('locals', []):
            assert local['name'] not in locals_
            locals_[local['name']] = local['type'], 0
        try:
            self.body(function['body'], locals_)
        except Returned as result:
            value = result.args[0]
            assert value[0] == function['result']
            return value
        raise AssertionError(('function without return', name))

    def run(self, args):
        function = self.functions[self.entry]
        assert len(args) == len(function['params'])
        assert all(isinstance(a, int) and 0 <= a < (1 << 64) for a in args), 'entry uint64 ABI range'
        assert all(p['type'] in ('u32', 'u64') for p in function['params']), 'scalar entry ABI'
        value = self.call(self.entry, [(p['type'], a & ((1 << (8 * self.width(p['type']))) - 1))
                                       for p, a in zip(function['params'], args)])
        assert self.allocations == self.frees, 'unreclaimed allocated regions'
        assert value[0] == 'u32'
        return {'value': value[1], 'steps': self.steps,
                'allocations': self.allocations, 'frees': self.frees}


if __name__ == '__main__':
    with open(sys.argv[1]) as source:
        program = json.load(source)
    print(json.dumps(Interpreter(program).run([int(x) for x in sys.argv[2:]])))
