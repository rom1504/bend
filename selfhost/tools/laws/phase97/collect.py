#!/usr/bin/env python3
"""Authenticate Phase97 receipts and archive all attempts; execute no targets."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase97'
HERE = Path(__file__).resolve().parent
REQUIRED = ['challenge-check01', 'challenge-followups01', 'ownership-proof02',
            'ownership-negatives01', 'ownership-boundary01', 'projection-contracts02']


def read(path):
    return json.loads(Path(path).read_text())


def path_of(item):
    return (ROOT / item.get('file', item.get('path', ''))).resolve()


def name(path):
    path = Path(path).resolve()
    return str(path.relative_to(ROOT)) if path.is_relative_to(ROOT) else str(path)


def pin(path):
    path = Path(path).resolve(strict=True)
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=name(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def pins(value, location='$'):
    if isinstance(value, dict):
        if ('file' in value or 'path' in value) and {'bytes', 'sha256'} <= value.keys():
            if re.fullmatch('[0-9a-f]{64}', str(value['sha256'])):
                yield location, value
        for key, child in value.items():
            yield from pins(child, location + '.' + key)
    elif isinstance(value, list):
        for i, child in enumerate(value):
            yield from pins(child, f'{location}[{i}]')


class Collector:
    def __init__(self):
        self.checked = {}
        self.authenticated = set()
        self.expected = {}

    def verify(self, item):
        path = path_of(item)
        key = (path, path.stat().st_size, path.stat().st_mtime_ns)
        if key not in self.checked:
            self.checked[key] = pin(path)
        actual = self.checked[key]
        assert all(actual[k] == item[k] for k in ['bytes', 'sha256']), (path, item, actual)
        return path

    def authenticate(self, path):
        """Verify the pinned Phase97 JSON closure; before-images are replay data."""
        path = Path(path).resolve()
        data = read(path)
        if path in self.authenticated:
            return data
        self.authenticated.add(path)
        for location, item in pins(data):
            if '.before.' in location or location.endswith('.before'):
                continue  # A mutation's before pin intentionally names the changed path.
            target = self.verify(item)
            if target.is_relative_to(RAW) and target.suffix == '.json':
                self.authenticate(target)
        return data

    def process(self, report, stage, row, expected=0, classification=None):
        path = self.verify(row['receipt']) if 'receipt' in row else report.parent / stage / 'process.json'
        actual = read(path)
        assert actual == row['process'], path
        assert actual.get('returncode') == expected and not actual.get('stoppedFor'), path
        assert actual.get('complete') == (expected == 0), path
        assert 'finished' in actual and actual['finished'] >= actual['started'], path
        logs = {}
        for channel in ['stdout', 'stderr']:
            logs[channel] = (path.parent / (channel + '.log')).read_text()
            if channel in row:
                recorded = row[channel]
                if isinstance(recorded, dict):
                    recorded = self.verify(recorded).read_text()
                assert logs[channel] == recorded, (path, channel)
        if classification:
            self.expected[path.resolve()] = classification
        return logs

    def execution(self, item, passed=None):
        path = self.verify(item)
        data = self.authenticate(path)
        assert data['complete'] and data['inputsUnchanged'], path
        assert data['compile']['status'] == 'ok', path
        if passed is not None:
            assert data['passed'] == passed, path
        return data

    def production(self, path):
        data = self.authenticate(path)
        assert data['complete']
        result = self.execution(data['execution'], not data['mutationControl'])
        manifest = read(self.verify(data['manifest']))
        if data['mutationControl']:
            witness = next(r for r in result['rows'] if r['id'] == data['rejectedWitness'])
            assert not witness['passed'] and witness['actual'] != witness['expected']
            self.process(path, 'compile', data['rows']['compile'], 1, 'expected-semantic-rejection')
            return dict(kind='finite-semantic-rejection', witness=data['rejectedWitness'])
        for stage, row in data['rows'].items():
            self.process(path, stage, row)
        if data['native']:
            expected, actual = self.verify(data['expected']), self.verify(data['actual'])
            assert expected.read_bytes() == actual.read_bytes()
            assert data['cases'] == len(manifest['nativeCaseIds'])
            return dict(kind='native-full-output', cases=data['cases'])
        assert data['cases'] == len(result['rows']) == len(manifest['cases'])
        assert all(row['passed'] for row in result['rows'])
        return dict(kind='finite-js-full-values', cases=data['cases'])

    def campaign(self, path):
        data = self.authenticate(path)
        assert data['complete']
        rows = []
        for row in data['rows']:
            assert row['complete']
            target = self.verify(row['report'])
            rows.append(dict(name=row['name'], report=pin(target), **self.production(target)))
        return dict(kind='production-contract-campaign', section=data['section'], rows=rows)

    def challenges(self, path):
        data = self.authenticate(path)
        assert data['complete'] and data['inputsUnchanged'] and len(data['rows']) == 10
        baseline = self.execution(data['baseline']['report'], True)
        assert len(baseline['rows']) == 226 and all(r['passed'] for r in baseline['rows'])
        self.process(path, 'baseline', data['baseline']['guard'])
        counts = Counter()
        for row in data['rows']:
            classification = row['classification']; counts[classification] += 1
            if not row['targetExecuted']:
                assert classification == 'outside-extracted-closure'
                continue
            result_path = self.verify(row['report'])
            result = self.authenticate(result_path)
            if classification == 'compilation-refusal':
                compile_result = result['compile']
                assert compile_result['status'] != 'ok' and not compile_result['typeAccepted']
                assert compile_result['phase'] == 'check' and compile_result['exitCode'] == 1
                assert compile_result['diagnostic'] and not result['complete'] and not result['passed']
                assert not result['rows'] and not row['caseFailures'] and not row['semanticMismatches']
                self.process(path, row['id'], row['guard'], 1, 'compilation-refusal')
                continue
            result = self.execution(row['report'])
            mismatches = [r['id'] for r in result['rows'] if not r['passed'] and
                          'actual' in r and 'expected' in r and r['actual'] != r['expected']]
            assert mismatches == row['semanticMismatches']
            if classification == 'semantic-detection':
                assert row['kind'] == 'bad' and mismatches and not result['passed']
                self.process(path, row['id'], row['guard'], 1, 'expected-semantic-rejection')
            else:
                assert classification in ['escaped', 'valid-change-accepted']
                assert not mismatches and result['passed'] and all(r['passed'] for r in result['rows'])
                assert (classification == 'valid-change-accepted') == (row['kind'] == 'good')
                self.process(path, row['id'], row['guard'])
        return dict(kind='frozen-independent-challenges', classifications=dict(counts), baselineCases=226)

    def proof(self, path):
        data = self.authenticate(path)
        assert data['complete'] and data['independentlyChecked'] and data['inputsUnchanged']
        assert len(data['lawBindings']) == len(data['lawNames']) == 7
        assert not data['opaqueDefinitions']
        for matches in data['lawBindings'].values():
            assert matches and all(n in data['definitions'] for n in matches)
        self.process(path, 'check', data['rows']['check'])
        self.process(path, 'elaborate', data['rows']['elaborate'])
        logs = self.process(path, 'kernel', data['rows']['kernel'])
        assert logs['stdout'] == 'ALL PROOFS CHECK\n' and not logs['stderr']
        logs = self.process(path, 'kernel-negative', data['rows']['kernel-negative'], 1,
                            'expected-kernel-rejection')
        assert 'expected: .left' in logs['stdout'] and 'observed: .right' in logs['stdout']
        return dict(kind='independent-model-proof', publicLaws=4, supportLemmas=3,
                    definitions=len(data['definitions']), opaqueDefinitions=0)

    def negatives(self, path):
        data = self.authenticate(path)
        assert data['complete']
        done, rejects, helpers, baseline_laws = set(), 0, 0, 0
        for row in data['rows']:
            assert row['passed'] and set(row['requires']) <= done
            child_path = self.verify(row['report']); child = read(child_path)
            assert child['sourceOnly'] and not child['independentlyChecked']
            expected = row['expectedExit']; assert expected in [0, 1]
            logs = self.process(child_path, 'check', child['rows']['check'], expected,
                                'expected-frontend-proof-rejection' if expected else None)
            if expected:
                diagnostic = logs['stdout'] + logs['stderr']
                assert not child['complete'] and row['rejectedLaw'] in diagnostic
                assert 'expected :' in diagnostic and 'observed :' in diagnostic
                assert 'Location: ' + row['rejectedLaw'] in diagnostic
                rejects += 1
            else:
                assert child['complete']
                assert logs['stdout'] == 'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
                if child['lawNames']: baseline_laws += 1
                else: helpers += 1
            done.add(row['name'])
        assert rejects == data['rejectedCases']
        assert helpers + baseline_laws == data['helperAdmissions']
        return dict(kind='frontend-proof-controls', semanticRejections=rejects,
                    lawFreeHelperAdmissions=helpers, positiveLawChecks=baseline_laws,
                    reportedHelperAdmissions=data['helperAdmissions'])

    def boundary(self, path):
        data = self.authenticate(path)
        assert data['complete'] and data['inputsUnchanged'] and data['detected']
        assert data['classification'] == 'runtime-rejection'
        baseline = self.process(path, 'baseline', data['rows']['baseline'])
        self.process(path, 'build', data['rows']['build'])
        mutant = self.process(path, 'mutated', data['rows']['mutated'], 1, 'expected-runtime-rejection')
        assert mutant['stderr'] == 'bend: a function the device does not hold\n'
        expected = next(self.verify(x) for x in data['inputs'] if x['file'].endswith('native.expected.txt'))
        assert baseline['stdout'] == expected.read_text() and baseline['stdout'].startswith(mutant['stdout'])
        original = next(self.verify(x) for x in data['inputs'] if x['file'].endswith('/execution/laws.c'))
        before, after = data['mutation']['before'], data['mutation']['after']
        assert original.read_text().count(before) == 1
        assert original.read_text().replace(before, after, 1) == self.verify(data['candidate']).read_text()
        return dict(kind='generated-c-runtime-rejection', baselineLines=len(baseline['stdout'].splitlines()),
                    matchingPrefixLines=len(mutant['stdout'].splitlines()))

    def timing(self, path):
        data = self.authenticate(path)
        assert data['complete'] and data['inputsUnchanged']
        for row in data['records']:
            self.process(path, '', row)
            assert row['correct']
        assert data['cases'] and all(row['passed'] for row in data['scaling'])
        return dict(kind='extracted-helper-timing', scope=data['scope'],
                    cases=[dict(shape=r['shape'], candidateOverBaseline=r['candidateOverBaseline'])
                           for r in data['cases']],
                    speedupThresholdRequired=False, compilerSpeedClaim=False)

    def compiler_screen(self, path):
        """Authenticate active screen evidence, retaining historical provenance.

        Phase92's explicit inputs are the current authentication boundary. Its
        embedded role admissions also contain deliberately reclaimed older
        comparison products; those remain inventoried without becoming inputs.
        """
        data = read(path)
        assert data['complete'] and data['inputsUnchanged'] and data['executionPerformed']
        assert data['mode'] == 'screen' and data['rounds'] == 4
        baseline = data['baseline']
        assert baseline['kind'] == 'phase92-matched-native-compiler-authentication'
        active = {self.verify(item):item for item in data['inputs']}
        assert len(active) == len(data['inputs'])
        for relative in ['selfhost/tools/performance/phase97/compiler-compare.py',
                         'selfhost/tools/performance/phase97/compiler-compare-derivation.json',
                         'selfhost/tools/performance/phase92/comparison/support.py']:
            assert ROOT / relative in active
        for item in baseline['inputs']:
            assert active[self.verify(item)] == item
        for item in [data['candidatePatch']['receipt'], data['candidate']['source'],
                     data['candidate']['c'], data['candidate']['binary']]:
            assert active[self.verify(item)] == item
        build_path = RAW / 'projection-build01/process.json'
        assert build_path in active and read(build_path) == data['candidate']['build']
        self.process(path, '', dict(receipt=active[build_path], process=data['candidate']['build']))
        checked_path = RAW / 'projection-checked01/report.json'
        assert checked_path in active
        checked = read(checked_path)
        assert checked['complete'] and checked['holes'] == 0
        assert checked['source'] == data['candidate']['source'] and checked['c'] == data['candidate']['c']
        assert data['candidatePatch']['forwardReplayExact']
        cases = {row['name']:row for row in data['cases']}
        assert len(cases) == len(data['cases']) == 6
        for case in cases.values():
            for key in ['source', 'oracle']:
                assert active[self.verify(case[key])] == case[key]
        expected = 'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n'
        assert data['expectedDiagnostic']['text'] == expected
        assert data['expectedDiagnostic']['sha256'] == hashlib.sha256(expected.encode()).hexdigest()
        clock_line = r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n'
        seen, direct_pins = set(), set(active)
        for row in data['rows']:
            cell = (row['round'], row['case'], row['role'])
            assert cell not in seen; seen.add(cell)
            assert row['passed'] and row['exactC'] and row['diagnosticExact']
            raw = {self.verify(item).name:item for item in row['raw']}
            assert len(raw) == len(row['raw']) == 3
            assert set(raw) == {'process.json', 'stdout.log', 'stderr.log'}
            receipt = path_of(raw['process.json'])
            assert path_of(raw['stdout.log']).parent == path_of(raw['stderr.log']).parent == receipt.parent
            logs = self.process(path, '', dict(receipt=raw['process.json'], process=row['process'],
                                               stdout=raw['stdout.log'], stderr=raw['stderr.log']))
            direct_pins.update(path_of(item) for item in row['raw'])
            output = self.verify(row['output']); direct_pins.add(output)
            assert output.read_bytes() == self.verify(cases[row['case']]['oracle']).read_bytes()
            assert not logs['stdout']
            diagnostic = re.sub(clock_line, '', logs['stderr'], flags=re.M)
            assert diagnostic == expected
            assert hashlib.sha256(diagnostic.encode()).hexdigest() == row['diagnosticSha256']
        assert seen == {(rnd, case, role) for rnd in range(1, 5) for case in cases
                        for role in ['baseline', 'candidate']}
        assert len(data['rows']) == data['summary']['exactCCount'] == data['summary']['exactDiagnosticCount'] == 48
        return dict(kind='native-compiler-screen', scope=data['scope'], activeInputPins=len(active),
                    directlyVerifiedUniqueFiles=len(direct_pins), cases=6, rounds=4,
                    exactCCount=48, exactDiagnosticCount=48,
                    recordedMetricSummary=data['summary'],
                    authenticationBoundary='Phase92 explicit active inputs; embedded historical role provenance inventoried separately.',
                    methodResponsibility='Pinned comparator/derivation validates patch replay, matched build flags, balanced order and timing arithmetic.',
                    speedupThresholdRequired=False, generatedProgramSpeedClaim=False)


def excluded_reason(path):
    # Executable scripts remain sources; identify compiled products by content.
    if '__pycache__' in path.parts or path.suffix in ['.pyc', '.olean', '.ilean', '.o', '.a', '.so', '.dll', '.dylib']:
        return 'compiled artifact or cache'
    if any(part in ['toolchain', 'toolchains'] or 'bun-toolchain' in part for part in path.parts):
        return 'external toolchain installation'
    if path.suffix in ['.zip', '.gz', '.xz', '.zst', '.tar']:
        return 'preexisting archive; referenced by identity without recursive copying'
    with path.open('rb') as stream: head = stream.read(8192)
    if head.startswith((b'\x7fELF', b'MZ', b'\x00asm', b'\xcf\xfa\xed\xfe', b'\xfe\xed\xfa\xcf')):
        return 'compiled binary executable or image'
    if b'\x00' in head:
        return 'binary artifact'
    if not path.is_relative_to(RAW) and path.suffix == '.mjs' and path.stat().st_size > 1024 * 1024:
        return 'external generated compiler image; pinned dependency'
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--projection-timing', type=Path)
    parser.add_argument('--accepted-report', action='append', default=[], metavar='LABEL=PATH',
                        help='Additional completed scoped receipt; known negative/campaign schemas receive semantic validation.')
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(HERE) and not out.exists()
    collector = Collector(); accepted = {}
    validators = [collector.challenges, collector.campaign, collector.proof,
                  collector.negatives, collector.boundary, collector.campaign]
    for attempt, validate in zip(REQUIRED, validators):
        path = RAW / attempt / 'report.json'
        accepted[attempt] = dict(report=pin(path), **validate(path))
    if args.projection_timing:
        path = args.projection_timing.resolve()
        assert path.is_relative_to(RAW)
        accepted['projection-timing'] = dict(report=pin(path), **collector.timing(path))
    for item in args.accepted_report:
        label, separator, filename = item.partition('=')
        assert separator and re.fullmatch('[A-Za-z0-9_-]+', label) and label not in accepted
        path = Path(filename).resolve(); assert path.is_relative_to(RAW)
        data = read(path); assert data['complete']
        if data.get('mode') == 'screen' and data.get('baseline', {}).get('kind') == 'phase92-matched-native-compiler-authentication':
            detail = collector.compiler_screen(path)
        elif 'rejectedCases' in data and 'plan' in data:
            detail = collector.negatives(path)
        elif data.get('section') in ['projection', 'followups']:
            detail = collector.campaign(path)
        elif 'mutationControl' in data and 'execution' in data:
            detail = collector.production(path)
        else:
            data = collector.authenticate(path)
            assert data.get('inputsUnchanged', True)
            detail = dict(kind='authenticated-completed-scope', scope=data.get('scope'),
                          semanticInterpretation='Receipt authenticated; no extra proof or performance claim inferred.')
        accepted[label] = dict(report=pin(path), **detail)

    # Snapshot all attempts, not only accepted ones. Current authoring methods
    # supplement the frozen copies in raw attempts; previous capsules are excluded.
    roots = [RAW, HERE, ROOT/'selfhost/proofs/phase97',
             ROOT/'selfhost/tools/performance/phase97', ROOT/'implementation/phase97', ROOT/'research/phase97']
    files = set()
    for root in roots:
        if root.exists():
            files.update(p.resolve() for p in root.rglob('*') if p.is_file() and not p.is_relative_to(out))
    raw_files = {p.resolve() for p in RAW.rglob('*') if p.is_file()}
    claims, historical_unavailable = {}, []
    # Discover pinned source dependencies from every raw JSON, including failed
    # attempts. Old before-images/mutable-origin claims are recorded, not rewritten.
    for document in sorted(files):
        if document.suffix != '.json': continue
        try: content = read(document)
        except (ValueError, UnicodeError): continue
        for location, item in pins(content):
            target = path_of(item)
            key = (str(target), item['bytes'], item['sha256'])
            entry = claims.setdefault(key, dict(file=name(target), bytes=item['bytes'], sha256=item['sha256'], references=[]))
            entry['references'].append(dict(document=name(document), location=location))
    for entry in claims.values():
        target = path_of(entry)
        if not target.is_file():
            entry['currentStatus'] = 'missing'; historical_unavailable.append(entry)
            continue
        actual = pin(target)
        if any(actual[k] != entry[k] for k in ['bytes', 'sha256']):
            entry['currentStatus'] = 'different-current-bytes'; historical_unavailable.append(entry)
            continue
        entry['currentStatus'] = 'verified'
        files.add(target)

    ledger = []
    for path in sorted(RAW.rglob('process.json')):
        data = read(path)
        assert {'started', 'finished', 'returncode', 'wallSeconds'} <= data.keys(), path
        assert data['finished'] >= data['started'], path
        diagnostic = ''.join((path.parent/(channel+'.log')).read_text() for channel in ['stdout', 'stderr'])
        if data.get('stoppedFor'):
            classification = 'resource-stop'
        elif path.resolve() in collector.expected:
            classification = collector.expected[path.resolve()]
        elif data['returncode'] == 0:
            classification = 'success'
        elif path.parent.name == 'kernel-negative' and 'expected: .left' in diagnostic and 'observed: .right' in diagnostic:
            classification = 'expected-kernel-rejection'
        else:
            classification = 'nonzero-target-failure'
        ledger.append(dict(receipt=pin(path), classification=classification, **data))
    ledger.sort(key=lambda row: (row['started'], row['finished']))
    overlaps = []
    active = []
    for row in ledger:
        active = [prior for prior in active if prior['finished'] > row['started']]
        overlaps.extend([dict(first=p['receipt']['file'], second=row['receipt']['file']) for p in active])
        active.append(row)
    assert not overlaps, ('Target intervals overlap; do not call this serial evidence', overlaps)
    assert ledger

    inventory, exclusions = [], []
    for path in sorted(files):
        reason = excluded_reason(path)
        item = pin(path)
        if reason:
            exclusions.append(dict(**item, reason=reason, phase97Raw=path in raw_files))
        else:
            # External text dependencies use a separate namespace, never an absolute ZIP path.
            member = name(path) if path.is_relative_to(ROOT) else 'external-source/' + str(path).lstrip('/')
            inventory.append(dict(**item, member=member))
    out.mkdir(parents=True)
    archive = out / 'raw-evidence.zip'
    with zipfile.ZipFile(archive, 'x', compression=zipfile.ZIP_DEFLATED, compresslevel=6) as stream:
        for item in inventory:
            stream.write(path_of(item), item['member'])
    with zipfile.ZipFile(archive) as stream:
        assert len(stream.namelist()) == len(inventory) == len(set(stream.namelist()))
        for item in inventory:
            data = stream.read(item['member'])
            assert len(data) == item['bytes'] and hashlib.sha256(data).hexdigest() == item['sha256']
            assert pin(path_of(item)) == {k:item[k] for k in ['file','bytes','sha256']}
    assert raw_files == {p.resolve() for p in RAW.rglob('*') if p.is_file()}, 'New raw files appeared during collection'
    for entry in exclusions:
        assert pin(path_of(entry)) == {k:entry[k] for k in ['file','bytes','sha256']}
    for (path, size, modified), item in collector.checked.items():
        assert path.stat().st_size == size and path.stat().st_mtime_ns == modified, path

    archived = {item['file']: item for item in inventory}
    omitted = {item['file']: item for item in exclusions}
    for entry in claims.values():
        if entry['currentStatus'] == 'verified':
            if entry['file'] in archived:
                entry['archivedMember'] = archived[entry['file']]['member']
            else:
                entry['excludedReason'] = omitted[entry['file']]['reason']
    external = [entry for entry in claims.values() if not path_of(entry).is_relative_to(RAW)]
    counts = dict(Counter(row['classification'] for row in ledger))
    summary = dict(complete=True, targetsRun=False, accepted=accepted, method=pin(__file__),
                   archive=pin(archive), archivedFiles=len(inventory), archivedBytes=sum(x['bytes'] for x in inventory),
                   archiveReadbackVerified=True, excludedFiles=len(exclusions),
                   rawFiles=len(raw_files), allRawFilesAccountedFor=True,
                   guardedJobs=len(ledger), jobClassifications=counts,
                   targetOccupancySeconds=sum(row['wallSeconds'] for row in ledger),
                   targetSpanSeconds=ledger[-1]['finished']-ledger[0]['started'],
                   peakTreeRssBytes=max(row.get('peakTreeRssBytes', 0) for row in ledger),
                   minimumAvailableBytes=min(row.get('minimumAvailableBytes', 0) for row in ledger),
                   resourceStoppedJobs=counts.get('resource-stop', 0), serialVerified=True, overlaps=overlaps,
                   historicalUnverifiedClaims=len(historical_unavailable),
                   controllerFailureRecords=[pin(p) for p in sorted(RAW.rglob('controller-failures.json'))],
                   limitations=['All raw attempts retained, including failures; accepted scopes are separately authenticated.',
                                'Normal nonzero semantic controls are not resource stops or extra theorems.',
                                'External executables, compiled images and toolchains are inventoried rather than copied.',
                                'Controller failures without process.json are retained raw, not counted as guarded target jobs.',
                                'Timing is optional; no required speedup and no full-compiler claim is inferred.'])
    outputs = {'execution-ledger.json': ledger, 'archive-members.json': inventory,
               'excluded-files.json': exclusions, 'external-dependencies.json': external,
               'recorded-pin-claims.json': list(claims.values()), 'summary.json': summary}
    for filename, data in outputs.items():
        (out/filename).write_text(json.dumps(data, indent=2)+'\n')
    print(json.dumps(dict(complete=True, archivedFiles=len(inventory), guardedJobs=len(ledger),
                         exclusions=len(exclusions), out=str(out))))


if __name__ == '__main__':
    main()
