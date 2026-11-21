"""Collect content pins and compact reports for the three guarded controls."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BUILD = ROOT / 'selfhost/build/phase199'


def read(file):
    return json.loads(Path(file).read_text())


def pin(file):
    path = Path(file).resolve()
    content = path.read_bytes()
    return dict(file=str(path), bytes=len(content), sha256=hashlib.sha256(content).hexdigest())


def verify(record):
    actual = pin(record['file'])
    assert (actual['bytes'], actual['sha256']) == (record['bytes'], record['sha256']), record['file']
    return actual


def same(a, b):
    return (a['bytes'], a['sha256']) == (b['bytes'], b['sha256'])


def main():
    reports = {}
    files = []
    for name in ('scan-controls-old01', 'scan-selector-controls01', 'scan-controls-new01'):
        path = BUILD / name / 'report.json'
        guard = path.parent.with_name(name + '-guard')
        process = read(guard / 'process.json')
        retention = read(guard / 'retention.json')
        report = read(path)
        assert process['complete'] and process['returncode'] == 0 and process['method']['cpu'] == '3'
        assert report['complete'] and retention['closed'] and retention['outcome'] == 'succeeded'
        reports[name] = report
        files.extend([path, guard / 'process.json', guard / 'retention.json', guard / 'stdout.log', guard / 'stderr.log'])

    old, selector, new = reports.values()
    api_file = BUILD / 'scan-api01/report.json'
    emit_file = BUILD / 'focused-emission01/scan/report.json'
    study_file = BUILD / 'focused-plan01/study.json'
    api, emission, study = map(read, (api_file, emit_file, study_file))
    assert api['complete'] and api['checked'] and emission['complete'] and study['complete']
    assert not emission.get('error') and not emission.get('changedInputs')
    assert pin(api_file) in emission['inputs'] and study['candidateApi'] == pin(api_file)
    verify(study['helperReceipt'])
    helper_receipt = read(study['helperReceipt']['file'])
    assert helper_receipt['complete'] and verify(helper_receipt['helperObject']) == new['helper']
    row, = [r for r in emission['rows'] if r['id'] == 'local-fold']
    case, = [r for r in study['cases'] if r['id'] == row['id']]
    assert row['complete'] and row['verified'] and row['sameTypedSequence']
    assert case['source'] == row['source']
    assert same(case['baselineObject'], old['object']) and row['product'] == new['object']
    assert not same(old['object'], new['object'])
    assert api['api'] == selector['api'] and api['source'] == selector['source']
    assert not old['helperSites'] and len(new['helperSites']) == 1
    assert all(x['calls'] == 0 for x in old['checks'])
    assert new['checks'][0]['longRawCalls'] > 0 and new['checks'][1]['calls'] == 0
    assert old['worker'] == new['worker'] and old['runtime'] == new['runtime']
    for left, right in zip(old['checks'], new['checks']):
        for key in ('trials', 'checkedCells', 'uniform'):
            assert left[key] == right[key]
    assert selector['positive'] == 5 and selector['negative'] == 28

    inputs = [pin(api_file), pin(emit_file), pin(study_file), study['helperReceipt'], selector['capture'],
              selector['api'], selector['source'], old['object'], new['object'], new['helper'],
              new['runtime'], case['source'], case['baselineObject'], old['source'], old['method'], selector['method']]
    for item in inputs:
        verify(item)
    files.append(Path(selector['capture']['file']))
    archive = HERE / 'controls-evidence.tar.gz'
    with archive.open('wb') as output, gzip.GzipFile(filename='', fileobj=output, mode='wb', mtime=0) as compressed:
        with tarfile.open(mode='w|', fileobj=compressed) as tar:
            for path in sorted(files):
                entry = tar.gettarinfo(str(path), arcname=str(path.relative_to(BUILD)))
                entry.mtime = entry.uid = entry.gid = 0
                entry.uname = entry.gname = ''
                with path.open('rb') as stream:
                    tar.addfile(entry, stream)

    summary = dict(complete=True, version=1, checkedWorker=row['id'], worker=new['worker'],
                   producer=pin(api_file), emittedProduct=row['product'], helper=new['helper'],
                   positive=selector['positive'], negative=selector['negative'],
                   old=dict(bytes=old['workerBytes'], helperOffsets=old['helperSites'], checks=old['checks']),
                   candidate=dict(bytes=new['workerBytes'], helperOffsets=new['helperSites'], checks=new['checks']),
                   inputs=inputs, archive=dict(file=archive.name, bytes=archive.stat().st_size,
                                              sha256=pin(archive)['sha256']),
                   archived={str(path.relative_to(BUILD)):pin(path)['sha256'] for path in sorted(files)})
    (HERE / 'receipt.json').write_text(json.dumps(summary, indent=2) + '\n')


if __name__ == '__main__':
    main()
