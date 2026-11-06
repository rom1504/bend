#!/usr/bin/env python3
"""Independent finite oracle: hash frozen complete Phase156 results, never execute Bend.

This is a transport/observer implementation, not a checker. Each captured input
was previously checked against the independent publication checker and legacy
error verdict. The raw complete-value gate remains necessary before timing.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FIXTURES = ROOT / 'experiments/phase156/publication/fixtures.json'
RECEIPT = ROOT / 'selfhost/build/phase156/controls02/report.json'
MODULE = ROOT / 'selfhost/tests/phase169/checker-workload.bend'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(record):
    assert pin(record['file']) == record, 'Frozen oracle input changed: ' + record['file']


def decode(graph):
    assert graph['kind'] == 'phase154-object-graph' and graph['version'] == 1
    values = [[] if 'array' in n else {} for n in graph['nodes']]
    def get(value):
        if not isinstance(value, dict):
            return value
        assert set(value) == {'ref'} and 0 <= value['ref'] < len(values)
        return values[value['ref']]
    for target, node in zip(values, graph['nodes']):
        if 'array' in node:
            target.extend(map(get, node['array']))
        else:
            for key, value in node['object']:
                assert key not in target
                target[key] = get(value)
    return get(graph['root'])


def items(value):
    while value['$'] == 'Con':
        yield value['head']
        value = value['tail']
    assert value == {'$': 'Nil'}


class Observer:
    def __init__(self):
        self.words = []
        self.records = 0

    def word(self, value):
        assert isinstance(value, int) and 0 <= value <= 0xffffffff
        self.words.append(int(value))

    def text(self, text):
        assert isinstance(text, str)
        for char in text:
            self.word(42)
            self.word(ord(char))
        self.word(41)

    def seq(self, values, empty, cons, emit):
        for value in items(values):
            self.word(cons)
            emit(value)
        self.word(empty)

    def terms(self, values):
        self.seq(values, 61, 62, self.term)

    def defs(self, values):
        self.seq(values, 11, 12, self.definition)

    def term(self, value):
        kind = value['$']
        if kind == 'KLiteral':
            self.word(33); self.text(value['kind']); self.word(value['number'])
            self.text(value['text']); self.word(value['originBegin']); self.word(value['originEnd'])
            return
        assert kind in ['KTerm', 'KLambda']
        self.word(31 if kind == 'KTerm' else 32)
        if kind == 'KTerm':
            self.text(value['tag'])
        self.text(value['name']); self.word(value['id']); self.word(value['quant'])
        self.terms(value['kids']); self.seq(value['removed'], 51, 52, self.text)
        self.word(value['originBegin']); self.word(value['originEnd'])
        if kind == 'KLambda':
            self.word(value['quantityPresent'])

    def definition(self, value):
        self.records += 1
        kind = value['$']
        if kind == 'KIndexLeaf':
            self.word(22); self.word(value['hash']); self.defs(value['bucket'])
        elif kind == 'KIndexNode':
            self.word(23); self.word(value['hash']); self.word(value['mask'])
            self.definition(value['left']); self.definition(value['right'])
        else:
            assert kind == 'KDef'
            self.word(21); self.text(value['name']); self.text(value['kind'])
            self.word(value['arity']); self.word(value['templates'])
            self.term(value['typ']); self.term(value['value']); self.defs(value['ctors'])
            self.word(value['native']); self.word(value['unsafe'])

    def expression(self, value):
        if value['$'] == 'DText':
            self.word(100); self.text(value['text'])
        else:
            assert value['$'] == 'DTerm'
            self.word(101); self.term(value['term'])

    def checked(self, checked):
        assert checked['$'] == 'DChecking'
        result, diagnostic = checked['result'], checked['diagnostic']
        assert result['$'] == 'KChecking' and diagnostic['$'] == 'DDiagnostic'
        self.word(140); self.term(result['term']); self.term(result['typ'])
        self.terms(result['uses']); self.text(result['error']); self.word(result['consumed'])
        world = result['world']; assert world['$'] == 'KWorld'
        self.word(130); self.defs(world['book'])
        for memo in items(world['memo']):
            assert memo['$'] == 'KSpecMemo'
            self.word(81); self.text(memo['template']); self.text(memo['key'])
            self.text(memo['name']); self.word(memo['active'])
        self.word(80)
        fresh = world['fresh']
        if fresh['$'] == 'KFreshKnown':
            self.word(90); self.word(fresh['next'])
        else:
            assert fresh['$'] == 'KFreshDeferred'
            self.word(91); self.terms(fresh['roots'])
        self.defs(world['checked'])
        self.word(120); self.expression(diagnostic['expected']); self.expression(diagnostic['observed'])
        self.word(diagnostic['has_observed']); self.terms(diagnostic['context'])
        self.text(diagnostic['definition']); span = diagnostic['span']
        if span['$'] == 'DNoSpan':
            self.word(110)
        else:
            assert span['$'] == 'DSpan'
            self.word(111); self.text(span['source']); self.word(span['begin']); self.word(span['end'])
        self.text(diagnostic['note']); self.terms(diagnostic['trail'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), 'Fresh output directory required'
    publication = json.loads(FIXTURES.read_text())
    receipt = json.loads(RECEIPT.read_text())
    assert receipt['complete'], 'Historical run did not complete'
    fixture_pin = next(r for r in receipt['inputs'] if r['file'] == str(FIXTURES))
    verify(fixture_pin)
    selected = [f for f in publication['cases'] if f['name'] not in ['empty', 'duplicate-definition']]
    assert len(selected) == 10 and sum(f['success'] for f in selected) == 6
    string = r'"(?:[^"\\]|\\.)*"'
    literals = re.findall(r'P169CFixture\{(' + string + '),(' + string + '),(' + string + ')\}', MODULE.read_text())
    expected_literals = [(f['name'], '' if f['success'] else 'bad: type mismatch', f['source']) for f in selected]
    assert [tuple(map(json.loads, row)) for row in literals] == expected_literals, 'Workload/source mismatch'
    observer, cases = Observer(), []
    for index, fixture in enumerate(selected):
        row = next(r for r in receipt['rows'] if r['name'] == 'publication-' + fixture['name'])
        assert row['passed'] and row['success'] == fixture['success']
        assert row['checkerError'] == expected_literals[index][1]
        verify(row['fullResult'])
        capture = decode(json.loads(Path(row['fullResult']['file']).read_text()))
        assert capture['original']['result']['error'] == row['checkerError']
        observer.defs(capture['book']); observer.checked(capture['original'])
        cases.append(dict(index=index, name=fixture['name'], success=fixture['success'],
                          error=row['checkerError'], graph=row['fullResult']))
    expected, h, g = {'0': [0, 0, 0, 0, 0, 2166136261, 5381]}, 2166136261, 5381
    for rounds in range(1, 65):
        for word in observer.words:
            h = ((h ^ word) * 16777619) & 0xffffffff
            g = (g * 33 + word) & 0xffffffff
        if rounds in [1, 32, 64]:
            expected[str(rounds)] = [10 * rounds, 6 * rounds, 4 * rounds, 0,
                                     observer.records * rounds, h, g]
    plan = dict(kind='phase169-checker-workload-oracle', version=1, complete=True,
                targetsRun=False, inputs=[pin(__file__), pin(MODULE), fixture_pin, pin(RECEIPT),
                pin(ROOT / 'selfhost/tests/phase163/direct-runtime.bend')], cases=cases,
                expected=expected, observerWordsPerRound=len(observer.words),
                recordsPerRound=observer.records, historicalWholeSuitePassed=receipt['passed'],
                excluded=['empty', 'duplicate-definition'],
                rawGate='p169c_result(i).book == captured book; .checked == captured original, every field',
                scope='Frozen finite results and independent fixture verdicts; not a proof of the whole checker or hash collision freedom.')
    args.out.mkdir(parents=True)
    (args.out / 'report.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(json.dumps(dict(expected=expected, observerWordsPerRound=len(observer.words),
                          recordsPerRound=observer.records)))


if __name__ == '__main__':
    main()
