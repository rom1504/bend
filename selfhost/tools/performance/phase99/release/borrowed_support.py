"""Shared source and raw-receipt checks for the bounded borrowed-call release gates."""
import hashlib
from pathlib import Path
import re
import reuse as R

S = R.Q.support
ROOT = R.Q.ROOT
REQUIRED = {'real-io', 'generic-array', 'schema-refusals', 'aliases', 'root-swapping', 'unique-held'}
EXTRACT = ROOT / 'selfhost/tools/performance/phase98/comparison/origin-self-c-mechanism.py'
DECLARATIONS = ROOT / 'selfhost/proofs/phase98/prepare-current.py'


def load(b, path, complete=True):
    rp = b.bind(path); value = S.read(rp['file'])
    if complete: assert value['complete'] and not value.get('error') and value.get('inputsUnchanged', True)
    b.tree(value.get('inputs', []))
    if 'method' in value: b.bind(value['method'])
    return rp, value


def process(value, code=0):
    assert S.bounded_exit(value, code), value


def raw(b, folder, row, code=0):
    folder = Path(folder); actual = S.read(b.bind(folder / 'process.json')['file'])
    assert actual == row['process']; process(actual, code)
    for stream in ['stdout', 'stderr']:
        file = folder / (stream + '.log'); b.bind(file)
        if stream in row and isinstance(row[stream], str): assert file.read_text() == row[stream]
    return actual


def extractor(b):
    assert b.bind(EXTRACT)['sha256'] == '13c25fbb44697a7a241ee1e5722dd63bebef49ae14f98ac2a9112000695f2d04'
    return S.module('phase99_borrowed_c_spans', EXTRACT)


def flags(file):
    text = Path(file).read_text(); header = re.match(r'(?:#define NATIVE_\w+ [01]\n)+', text)
    assert header, 'Missing active native flag header'
    pairs = re.findall(r'^#define NATIVE_(\w+) ([01])$', header[0], re.M)
    assert len(pairs) == len({name for name, value in pairs})
    return {name:int(value) for name, value in pairs}


def control_cases(b, plan, emission_pin):
    emission = S.read(emission_pin['file']); programs = {row['id']:row for row in emission['programs']}
    cases = []
    for case in plan['controls']:
        headers = [flags(b.bind(programs[case['id'] + '-' + role]['c'])['file']) for role in ['baseline', 'candidate']]
        assert headers[0] == headers[1]
        cases.append({**case, 'runtimeArgs':['--threads', '1', '--gpu', 'off'], 'expectedFlags':headers[1]})
    return cases


def mechanism(b, c, case, static):
    text = Path(b.bind(c)['file']).read_text(); e = extractor(b); table = e.functions(text)
    def body(name):
        start, end = table[e.symbol(name)]; return text[start:end]
    workers = [e.decoded(name) for name in table if name.startswith(e.symbol('$observer.'))
               and not name.startswith(e.symbol('$observer.adapter.'))]
    rows = []
    for worker in workers:
        code = body(worker)
        assert not any(token in code for token in ['term_keep(', 'term_sink(', 'ctr_take(', 'spare_free(', 'heap_alloc(', 'native_word(', 'term_word('])
        calls = [e.decoded(name) for name in re.findall(r'\b(NF_FID_(?:\d+_)+)\(', code)][1:]
        assert all(name.startswith('$observer.') and not name.startswith('$observer.adapter.') for name in calls)
        owner = worker.removeprefix('$observer.'); adapter = '$observer.adapter.' + owner
        adapter_body = body(adapter); assert e.symbol(worker) + '(e, seq, no_observed' in adapter_body
        ordinary = body(owner) if e.symbol(owner) in table else ''
        redirects = [line for line in ordinary.splitlines() if 'return ' + e.symbol(adapter) + '(' in line]
        for line in redirects:
            assert 'RFC_CNT) > 1' in line
            assert ('term_triv(' in line) == static
            if static: assert ') || (term_triv(' in line and ') && ' in line
        rows.append(dict(owner=owner, calls=calls, borrowedReads=code.count('term_peek('), redirects=redirects,
                         workerSha256=hashlib.sha256(code.encode()).hexdigest()))
    if case.get('observerOwner'):
        selected = next(row for row in rows if row['owner'] == case['observerOwner'])
        adapter = e.symbol('$observer.adapter.' + selected['owner'])
        assert selected['redirects'] or 'if (!' + adapter + '(e, seq, no_public_result' in text
    for name in case.get('forbiddenOwners', []): assert e.symbol('$observer.' + name) not in text
    return dict(workers=rows, refusedOwners=case.get('forbiddenOwners', []), allTrivialAlternative=static)


def small(b, path, source):
    qp, q = load(b, path)
    assert q['kind'] == 'phase99-borrowed-calls-small-qualification' and q['executionPerformed'] and not q.get('preparedOnly')
    pp, plan = load(b, q['plan'], complete=False); b.tree(plan)
    recipe = S.read(b.bind(plan['recipe'])['file']); assert recipe['complete'] and b.bind(recipe['candidate']) == source
    assert Path(plan['sourceInputs']['candidate']['file']).read_text().startswith(Path(source['file']).read_text() + '\n')
    ep, emission = load(b, q['emission']); assert emission['executionPerformed']
    observed = {row['id']:row for row in emission['cases']}; assert len(observed) == len(emission['cases'])
    assert len(plan['cases']) >= 18 and REQUIRED <= {row['id'] for row in plan['controls']}
    for case in plan['cases']:
        row = observed[case['id']]
        assert row['kind'] == 'finite-certificate' and row['passed'] and row['actual'] == row['expected'] == case['expected']
    static = 'def no_all_trivial_roots(' in Path(source['file']).read_text()
    if static:
        assert {'trivial-two-roots-use-and', 'trivial-scalar-slot-excluded', 'trivial-one-root-after-scalar', 'shared-alternative-retains-or'} <= {r['id'] for r in plan['cases']}
    jobs = {row['name']:row for row in q['rows']}; assert len(jobs) == len(q['rows'])
    for row in jobs.values():
        assert row['launcherExit'] == 0; actual = raw(b, Path(b.bind(row['guard'])['file']).parent, row)
        argv = row['command'][row['command'].index('--') + 1:]; assert actual['command'][-len(argv):] == argv
    expected = {}
    for case in plan['controls']:
        row = observed[case['id']]; assert row['passed'] and row['kind'] == 'actual-emission'
        assert row['authority']['safe'] and all(x['accepted'] for x in row['authority']['checks'])
        assert all(row[k] for k in ['checkedEntriesExact', 'falseEntriesExact', 'rawPermissionOff'])
        assert row['changedProviderRejected'] is True or not row['authority']['checks']
        for role in ['baseline', 'candidate']:
            expected[case['id'] + '-' + role] = (case['stdout'], case['stderr'])
            active = row['policies'][role]; assert active['READONLY_OBSERVERS'] == 1
            assert active['TYPED_SCALARS'] == active['SCALAR_ARRAYS'] == case['scalar']
        assert row['policies']['baseline'] == row['policies']['candidate']
        for suffix in ['explicit-false', 'raw']:
            file = Path(ep['file']).parent / (case['id'] + '-' + suffix + '.c')
            denied = flags(b.bind(file)['file'])
            assert all(denied.get(key, 0) == 0 for key in ['READONLY_OBSERVERS', 'TYPED_SCALARS', 'SCALAR_ARRAYS'])
    unknown = observed['unknown-provider']; assert unknown['passed'] and not unknown['permission']['safe'] and not unknown['driverPermission']
    assert not unknown['flags']['READONLY_OBSERVERS'] and not unknown['flags']['TYPED_SCALARS']
    for name in ['raw-forged-observer-context-is-inert', 'raw-observer-return-node-is-not-source', 'raw-observer-loop-node-is-not-source']:
        row = observed[name]; assert row['passed'] and row['kind'] == 'raw-boundary' and row['exactBaseline']
    expected['raw-forged-observer-context-is-inert'] = ('7n\n', '')
    assert len(emission['programs']) == q['fullPrograms'] == len(expected)
    assert {row['id'] for row in emission['programs']} == set(expected)
    for program in emission['programs']:
        name = program['id']; c = b.bind(program['c']); build, run = jobs[name + '-clang'], jobs[name + '-run']
        argv = build['process']['command']; binary = b.bind(argv[argv.index('-o') + 1])
        assert c['file'] in argv and '-O2' in argv and run['process']['command'][-5:] == [binary['file'], '--threads', '1', '--gpu', 'off']
        assert run['fullOutputExact'] and (program['stdout'], program['stderr']) == expected[name]
        for stream, wanted in zip(['stdout', 'stderr'], expected[name]):
            assert (Path(run['guard']['file']).parent / (stream + '.log')).read_text() == wanted
    return qp, plan, pp, ep, static


def micro(b, path, source):
    rp, value = load(b, path); assert value['samples'] and all(row['fullOutputExact'] for row in value['samples'])
    assert len(value['samples']) == 8 and {(row['round'], row['role']) for row in value['samples']} == {(n, role) for n in range(4) for role in ['baseline', 'candidate']}
    _, q = load(b, value['qualification']); plan = S.read(b.bind(q['plan'])['file'])
    assert S.read(b.bind(plan['recipe'])['file'])['candidate'] == source
    ep, emission = load(b, value['emission']); program_source = b.bind(value['source'])
    mp = Path(rp['file']).parent / 'plan.json'; micro_plan = S.read(b.bind(mp)['file']); b.tree(micro_plan)
    assert len(micro_plan['controls']) == 1 and micro_plan['controls'][0]['source'] == program_source
    jobs = {row['name']:row for row in value['rows']}; by_sample = []
    for row in jobs.values(): raw(b, Path(b.bind(row['receipt'])['file']).parent, row)
    for sample in value['samples']:
        row = jobs['round' + str(sample['round']) + '-' + sample['role']]
        assert row['process']['wallSeconds'] == sample['wallSeconds']
        command = row['process']['command']; binary = b.bind(value['binaries'][sample['role']])['file']
        args = command[command.index(binary) + 1:]; assert args[:4] == ['--threads', '1', '--gpu', 'off']
        folder = Path(row['receipt']['file']).parent
        by_sample.append((args, (folder / 'stdout.log').read_text(), (folder / 'stderr.log').read_text()))
    assert all(row == by_sample[0] for row in by_sample)
    args, stdout, stderr = by_sample[0]
    headers = [flags(b.bind(next(row['c'] for row in emission['programs'] if row['id'] == 'boundary-' + role))['file']) for role in ['baseline', 'candidate']]
    assert headers[0] == headers[1]
    return {**micro_plan['controls'][0], 'id':'micro-' + Path(rp['file']).parent.name,
            'stdout':stdout, 'stderr':stderr, 'runtimeArgs':args, 'oracleReceipt':rp, 'emission':ep, 'expectedFlags':headers[1]}
