"""Read explicit frozen final-program selections and the active emitted flag header."""
from pathlib import Path
import re
from support import read


def native_flags(path):
    # Later runtime #ifndef fallbacks are not active redefinitions of this header.
    text = Path(path).read_text()
    header = re.match(r'(?:#define NATIVE_\w+ [01]\n)+', text)
    assert header, 'Missing native emitter flag header'
    pairs = re.findall(r'^#define NATIVE_(\w+) ([01])$', header[0], re.M)
    assert len(pairs) == len({name for name, value in pairs})
    flags = {name:int(value) for name, value in pairs}
    assert set(flags) == {'READONLY_OBSERVERS', 'PACK_CTORS', 'TYPED_SCALARS',
                          'COLD_USER_CTORS', 'SCALAR_ARRAYS', 'UNSHARED_ARRAYS'}
    return flags


def load_cases(evidence, bindings):
    selections = evidence['finalImageControlPlans']
    assert len(selections) == 3
    qualified = read(bindings.bind(evidence['qualifiedSourceControls'])['file'])
    corpus = read(bindings.bind(evidence['qualifiedSourceCorpus'])['file'])
    origin = read(bindings.bind(evidence['originControls'])['file'])
    assert selections[0]['plan'] == qualified['plan']
    assert selections[1]['plan'] in corpus['inputs']
    assert selections[2]['plan'] == origin['plan']
    assert [row['caseIds'] for row in selections] == [
        ['real-io', 'generic-array', 'schema-refusals'], ['full-string-corpus'], ['origin-swap']]
    plans, cases = [], []
    for selection in selections:
        plan_pin = bindings.bind(selection['plan']); plans.append(plan_pin)
        plan = read(plan_pin['file'])
        by_id = {row['id']:row for row in plan['controls']}
        assert len(by_id) == len(plan['controls'])
        for name in selection['caseIds']:
            old = by_id[name]; bindings.bind(old['source'])
            assert re.findall(r'(?m)^import (.+)$', Path(old['source']['file']).read_text()) == ['Base']
            case = dict(id=name, source=old['source'], plan=plan_pin,
                        expectedStdout=old['stdout'], expectedStderr=old['stderr'],
                        scalar=old.get('scalar', 0))
            if 'declinedOwner' in old: case['declinedOwner'] = old['declinedOwner']
            cases.append(case)
    assert len(cases) == 5 and len({row['id'] for row in cases}) == 5
    assert cases[-1]['declinedOwner'] == 'p98_origin_swap'
    return plans, cases
