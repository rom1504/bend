#!/usr/bin/env python3
"""Transport a complete upstream-observed value into bounded Bend literals.

Reuse the Phase173 512-unit literal grouping. No target executes here; no
compiler algorithm or semantic transformation is implemented by this script.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, require, fresh_output, write_json

METHOD = Path(__file__).with_name('vertical-native.py')
spec = importlib.util.spec_from_file_location('phase173_literal_transport', METHOD)
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)

L = lambda typ: ('List', typ)
SCHEMAS = {
    'GHeap': {'GEmpty': [], 'GNode': [('value', 'KTerm'), ('left', 'GHeap'), ('right', 'GHeap')]},
    'GState': {'GState': [('heap', 'GHeap'), ('next', 'U32')]},
    'GResult': {'GResult': [('state', 'GState'), ('term', 'KTerm')]},
    'P173BWReport': {'P173BWReport': [('located', L('KTerm')), ('shared', L('GResult')), ('replaced', 'KTerm')]},
    'BorrowBox': {'BorrowBox': [('label', 'String'), ('low', 'U32'), ('high', 'U32'),
                              ('values', L('U32')), ('other', L('U32')), ('kind', 'U32')]}}


def type_name(typ):
    return 'List<&2,' + type_name(typ[1]) + '>' if isinstance(typ, tuple) else typ


class Oracle(transport.Transport):
    def value(self, value, typ):
        if isinstance(typ, tuple):
            return self.sequence(value, lambda v: self.value(v, typ[1]), type_name(typ[1]))
        if typ == 'KTerm':
            return self.term(value)
        if typ in ('U32', 'String', 'Bool'):
            return {'U32': self.number, 'String': self.string, 'Bool': self.boolean}[typ](value)
        require(isinstance(value, dict) and value.get('$') in SCHEMAS[typ], 'Unknown complete value constructor')
        tag = value['$']
        shape = SCHEMAS[typ][tag]
        values = transport.fields(value, tag, [name for name, _ in shape])
        return self.constructor(tag, typ, [self.value(v, t) for v, (_, t) in zip(values, shape)])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--observation', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    observed = json.loads(a.observation.read_text())
    require(observed.get('kind') == 'phase173-independent-borrow-value-oracle'
            and observed.get('complete') is True and not observed.get('error'), 'Complete independent observation required')
    require(observed['variant'] in ('compiler', 'alias'), 'Fixed oracle schema required')
    require(0 < observed['observation']['nodes'] <= 100000
            and observed['observation']['maxDepth'] <= 512, 'Observed value exceeds original bounds')
    inputs = [pin(__file__), pin(METHOD), pin(ROOT / 'selfhost/tools/build/common.py'),
              pin(sys.executable), pin(a.observation), *observed['inputs'],
              observed['acquisition'], observed['source'], observed['value'], observed['oracleSource']]
    for item in inputs:
        verify(item)
    acquisition = json.loads(verify(observed['acquisition']).read_text())
    require(acquisition.get('kind') == 'bend-checked-hosted-api' and acquisition.get('complete')
            and acquisition.get('checked') and acquisition.get('status') == 0
            and not acquisition.get('error') and not acquisition.get('signal')
            and acquisition['exports'] == ['main'] and acquisition['source'] == observed['source'],
            'Observation must derive from checked upstream main on the same source')
    names = ['KTerm', 'GHeap', 'GState', 'GResult', 'P173BWReport'] if observed['variant'] == 'compiler' else ['BorrowBox']
    bindings = observed['typeBindings']
    require([b['name'] for b in bindings] == names, 'Unexpected checked type bindings')
    original = verify(observed['source']).read_text()
    for binding in bindings:
        require(hashlib.sha256(binding['text'].encode()).hexdigest() == binding['sha256']
                and binding['text'] in original, 'Original source/type binding differs')
    value = json.loads(verify(observed['value']).read_text())
    writer = Oracle(budget=512)
    typ = 'P173BWReport' if observed['variant'] == 'compiler' else L(L('BorrowBox'))
    literal = writer.value(value, typ)
    code = ('import Base\n\n# Complete authenticated upstream value; grouped literals only.\n'
            + '\n'.join(b['text'] for b in bindings) + '\n' + '\n'.join(writer.helpers)
            + '\ndef main() -> ' + type_name(typ) + ':\n  ' + literal.text + '\n')
    require(len(code.encode()) <= 4 * 1024 * 1024, 'Bounded literal source exceeded')
    out = fresh_output(a.out, ROOT)
    (out / 'oracle.bend').write_text(code)
    for item in inputs:
        verify(item)
    report = dict(kind='phase173-bounded-borrow-native-oracle', complete=True, checked=False,
        targetsRun=False, inputs=inputs, acquisition=observed['acquisition'],
        originalSource=observed['source'], completeValue=observed['value'], typeBindings=bindings,
        source=pin(out / 'oracle.bend'), literalTransport=dict(budgetUnits=512,
            helpers=len(writer.helpers), maxHelperUnits=max([literal.units, *writer.helper_units]),
            completeValuePreserved=True),
        scope='Complete value serialization only; independent source checking and native readback still required.')
    write_json(out / 'report.json', report)
    print(json.dumps(dict(complete=True, source=report['source'], literalTransport=report['literalTransport'], targetsRun=False)))


if __name__ == '__main__':
    main()
