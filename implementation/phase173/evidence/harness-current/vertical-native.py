#!/usr/bin/env python3
"""Transport authenticated complete values into small native Bend workloads.

No compiler transformation executes here. Checked API observations supply both
the erased-body corpus and the independent expected results. Every value field
is encoded as a Bend constructor literal; actual consumer code is extracted
unchanged from its authenticated checked source. The root runs all target jobs.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import fresh_output, pin, require, verify, write_json


def fields(value, constructor, names):
    require(isinstance(value, dict) and value.get('$') == constructor,
            'Wrong literal constructor: '+constructor)
    require(set(value) == {'$', *names}, 'Unexpected complete fields: '+constructor)
    return [value[name] for name in names]


def word(value):
    require(type(value) is int and 0 <= value <= 4294967295, 'Not a U32 literal')
    return str(value)


def string(value):
    require(isinstance(value, str), 'Not a String literal')
    value.encode('utf8', errors='strict')
    if any(ord(char) < 32 and char not in '\n\r\t' for char in value):
        result = 'SNil{}'
        for char in reversed(value):
            result = 'SCon{'+str(ord(char))+','+result+'}'
        return result
    return json.dumps(value, ensure_ascii=False)


def boolean(value):
    require(type(value) is bool, 'Not a Bool literal')
    return 'True{}' if value else 'False{}'


def rows(value):
    out = []
    while isinstance(value, dict) and value.get('$') == 'Con':
        require(len(out) < 1000000, 'List transport bound')
        head, value = fields(value, 'Con', ['head', 'tail'])
        out.append(head)
    fields(value, 'Nil', [])
    return out


class Literal:
    def __init__(self, text, units, typ):
        self.text, self.units, self.typ = text, units, typ


class Transport:
    """Bound literal construction, without interpreting or transforming terms.

    Units conservatively count constructors, scalar fields and String code
    points. They are a transport budget, not a QBE local-count prediction.
    Every helper retains its complete literal subtree; no corpus is pruned.
    """
    def __init__(self, budget=512):
        self.budget, self.helpers, self.helper_units = budget, [], []

    def save(self, expr):
        require(expr.units <= self.budget, 'Unbounded transport helper')
        name = 'p173vn_literal_'+str(len(self.helpers))
        self.helpers.append('def '+name+'() -> '+expr.typ+':\n  '+expr.text+'\n')
        self.helper_units.append(expr.units)
        return Literal(name+'()', 1, expr.typ)

    def constructor(self, name, typ, parts):
        parts = list(parts)
        while 1+sum(part.units for part in parts) > self.budget:
            biggest = max(range(len(parts)), key=lambda i: parts[i].units)
            require(parts[biggest].units > 1, 'Constructor arity exceeds budget')
            parts[biggest] = self.save(parts[biggest])
        return Literal(name+'{'+','.join(part.text for part in parts)+'}',
                       1+sum(part.units for part in parts), typ)

    def number(self, value):
        return Literal(word(value), 1, 'U32')

    def boolean(self, value):
        return Literal(boolean(value), 1, 'Bool')

    def string(self, value):
        encoded = string(value)  # Validate every code point even for split text.
        units = 1+2*len(value)
        if units <= self.budget:
            return Literal(encoded, units, 'String')
        tail = Literal('SNil{}', 1, 'String')
        for char in reversed(value):
            tail = self.constructor('SCon', 'String', [self.number(ord(char)), tail])
        return tail

    def sequence(self, value, render, item_type, force_items=False):
        typ = 'List<&2,'+item_type+'>'
        # Preserve helper and source construction order deterministically.
        items = [render(item) for item in rows(value)]
        if force_items:
            items = [self.save(item) for item in items]
        tail = Literal('Nil{}', 1, typ)
        for at, head in enumerate(reversed(items)):
            if force_items and at and at % 32 == 0:
                tail = self.save(tail)
            tail = self.constructor('Con', typ, [head, tail])
        return tail

    def term(self, value):
        require(isinstance(value, dict), 'Not a complete KTerm')
        tag = value.get('$')
        if tag == 'KTerm':
            vs = fields(value, tag, ['tag', 'name', 'id', 'quant', 'kids', 'removed', 'originBegin', 'originEnd'])
            parts = [self.string(vs[0]), self.string(vs[1]), self.number(vs[2]), self.number(vs[3]),
                     self.sequence(vs[4], self.term, 'KTerm'), self.sequence(vs[5], self.string, 'String'),
                     self.number(vs[6]), self.number(vs[7])]
        elif tag == 'KLambda':
            vs = fields(value, tag, ['name', 'id', 'quant', 'kids', 'removed', 'originBegin', 'originEnd', 'quantityPresent'])
            parts = [self.string(vs[0]), self.number(vs[1]), self.number(vs[2]), self.sequence(vs[3], self.term, 'KTerm'),
                     self.sequence(vs[4], self.string, 'String'), self.number(vs[5]), self.number(vs[6]), self.boolean(vs[7])]
        elif tag == 'KLiteral':
            vs = fields(value, tag, ['kind', 'number', 'text', 'originBegin', 'originEnd'])
            parts = [self.string(vs[0]), self.number(vs[1]), self.string(vs[2]), self.number(vs[3]), self.number(vs[4])]
        else:
            raise ValueError('Unsupported KTerm variant: '+str(tag))
        return self.constructor(tag, 'KTerm', parts)

    def input(self, value):
        name, body = fields(value, 'P173VInput', ['name', 'body'])
        return self.constructor('P173VInput', 'P173VInput', [self.string(name), self.term(body)])

    def output(self, value):
        name, body, refs, error = fields(value, 'P173VBody', ['name', 'body', 'references', 'error'])
        require(error == '', 'An unsuccessful observation is not an oracle')
        return self.constructor('P173VBody', 'P173VBody', [self.string(name), self.term(body),
            self.sequence(refs, self.string, 'String'), self.string(error)])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--controls', type=Path, required=True)
    p.add_argument('--role', choices=['baseline', 'candidate', 'oracle'], required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    receipt = pin(a.controls)
    report = json.loads(verify(receipt).read_text())
    require(report.get('kind') == 'phase173-indexed-vertical-controls' and
            report.get('complete') and report.get('passed'), 'Passing complete controls required')
    require(report.get('completeInputs', {}).get('completeValuesEqual') and
            report.get('completePassOutputs', {}).get('completeValuesEqual'), 'Complete oracle comparison required')
    expected = next(row for row in report['observations'] if row['role'] == 'baseline')
    captured = report['capturedInputs']
    inputs = [pin(__file__), receipt, pin(assembly.__file__), *report['inputs'], captured, expected]
    for item in inputs:
        verify(item)
    input_values = json.loads(verify(captured).read_text())
    output_values = json.loads(verify(expected).read_text())
    require(len(rows(input_values)) == len(rows(output_values)) == report['actualBodies'] > 0,
            'Complete actual corpus length differs')
    authority = report['authorities']['candidate' if a.role == 'candidate' else 'baseline']
    source = authority['source']
    inputs.append(source)
    original = verify(source).read_bytes()
    _, declarations = assembly.blocks(original)
    original = b'\n'.join(row['data'] for row in declarations if row['name'] != 'main')
    transport = Transport()
    if a.role == 'oracle':
        literal = transport.sequence(output_values, transport.output, 'P173VBody', force_items=True)
        entry = 'def main() -> List<&2,P173VBody>:\n  '+literal.text+'\n'
    else:
        consume = 'p173v_baseline' if a.role == 'baseline' else 'p173v_candidate'
        literal = transport.sequence(input_values, transport.input, 'P173VInput', force_items=True)
        entry = ('def p173vn_inputs() -> List<&2,P173VInput>:\n  '+literal.text+'\n\n'
                 'def main() -> List<&2,P173VBody>:\n  '+consume+'(p173vn_inputs())\n')
    root = '\n'.join(transport.helpers)+'\n'+entry
    metadata = ROOT/'experiments/phase147/tools/prepare.py'
    spec = importlib.util.spec_from_file_location('phase173_literal_extract', metadata)
    extractor = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(extractor)
    inputs.append(pin(metadata))
    selected, inventory = extractor.extract([('authenticated-'+a.role, original),
        ('literal-corpus-and-entry', root.encode())], ['main'], 4_000_000)
    out = fresh_output(a.out, ROOT)
    (out/'compiler.bend').write_bytes(selected)
    (out/'literal-entry.bend').write_text(root)
    write_json(out/'exports.json', dict(kind='bend-hosted-api-exports', version=1,
        exports=['main'], protocol='hosted-api-v1', targets=['qbe'], preparationModes=['live'],
        scope='Private complete consumer or frozen-value oracle, not a compiler image.'))
    for item in inputs:
        verify(item)
    manifest = dict(kind='phase173-native-complete-consumer-source', version=1, complete=True,
        targetsRun=False, checked=False, role=a.role, inputs=inputs, authority=authority,
        controls=receipt, capturedInputs=captured, completeExpected=expected,
        workloadSource=report['source'], bodies=report['actualBodies'], repetitions=1,
        literalTransport=dict(version=2, budgetUnits=transport.budget,
            helpers=len(transport.helpers), maxHelperUnits=max([literal.units,*transport.helper_units]),
            topLevelItemsPerChunk=32, completeCorpusPreserved=True,
            scope='Literal constructor grouping only; no compiler admission/verification threshold changed.'),
        source=pin(out/'compiler.bend'), entry=pin(out/'literal-entry.bend'), exports=pin(out/'exports.json'),
        declarations=inventory,
        costScope='Fresh process, full consumer, all import/export/store cleanup, complete derived-value output and exit. Static literal corpus creation/sharing is visible and matched; this is not a full compiler request.',
        oracleScope='Every complete output field comes from independent checked baseline observations; constant oracle has no compaction algorithm. Compare complete native stdout, not only a checksum.',
        requiredValidation='Source-check all three programs; compile with one same qualified producer/runtime/toolchain; baseline and candidate stdout must exactly equal constant-oracle stdout.')
    write_json(out/'manifest.json', manifest)
    print(json.dumps(dict(role=a.role, source=manifest['source'], declarations=len(inventory), bodies=report['actualBodies'], targetsRun=False)))


if __name__ == '__main__':
    main()
