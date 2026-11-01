#!/usr/bin/env python3
"""Supplement an immutable checkpoint with exact referenced small method bytes."""
import argparse
import hashlib
import json
from pathlib import Path
import time

ROOT = Path(__file__).resolve().parents[4]


def pin(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    before = path.stat()
    data = path.read_bytes()
    after = path.stat()
    for field in ['st_dev','st_ino','st_size','st_mtime_ns','st_ctime_ns']:
        if getattr(before,field) != getattr(after,field):
            raise ValueError('Input changed: ' + str(path))
    return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--checkpoint', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    base, out = args.checkpoint.absolute(), args.out.absolute()
    if out.exists() or out.resolve() != out or not out.is_relative_to(ROOT/'implementation/phase147/evidence'):
        raise ValueError('Fresh evidence directory required')
    report_bytes, ref_bytes = read(base/'report.json'), read(base/'references.json')
    report, refs = json.loads(report_bytes), json.loads(ref_bytes)
    if report['kind'] != 'phase147-retention-checkpoint-v1' or not report['complete']:
        raise ValueError('Completed data checkpoint required')
    rows, objects, seen = [], {}, set()
    for item in refs['occurrences']:
        declared = item['declared']
        name = declared.get('path', declared.get('file'))
        key = (name, declared['sha256'], declared.get('bytes'))
        if key in seen or item['exactExportContentKey'] or item['exactArchiveContentKey']:
            continue
        seen.add(key)
        path = Path(name)
        if not path.is_absolute():
            path = ROOT/path
        if (not path.is_relative_to(ROOT) or path.suffix not in {'.py','.mjs','.c','.h'}
                or not isinstance(declared.get('bytes'), int) or declared['bytes'] > 256*1024):
            continue
        row = dict(declared=declared, firstReceipt=item['receipt'], firstPointer=item['pointer'])
        if path.is_symlink() or not path.is_file():
            row['status']='missing-or-symlink; retained as unresolved historical prerequisite'
        elif path.stat().st_size > 256*1024:
            row['status']='current file outside small-method limit; no replacement claimed'
        else:
            data = read(path)
            actual = pin(data)
            row['currentIdentity']=actual
            if actual != {k:declared[k] for k in ['bytes','sha256']}:
                row['status']='current bytes differ; historical identity not substituted'
            else:
                row['status']='exact bytes exported'
                row['object']='objects/'+actual['sha256']
                objects[actual['sha256']]=data
        rows.append(row)
    if sum(map(len,objects.values())) > 4*1024**2:
        raise ValueError('Supplement exceeds 4 MiB')
    out.mkdir(parents=True)
    (out/'objects').mkdir()
    for digest,data in objects.items():
        with (out/'objects'/digest).open('xb') as stream:
            stream.write(data)
        assert pin((out/'objects'/digest).read_bytes())==pin(data)
    result=dict(kind='phase147-small-method-dependency-supplement-v1',complete=True,
                dataOnly=True,targetExecuted=False,created=time.time(),
                checkpoint=dict(file=str((base/'report.json').relative_to(ROOT)),**pin(report_bytes)),
                references=dict(file=str((base/'references.json').relative_to(ROOT)),**pin(ref_bytes)),
                method=dict(file=str(Path(__file__).resolve().relative_to(ROOT)),**pin(read(Path(__file__)))),
                files=rows,exactObjects=len(objects),exportedUniqueBytes=sum(map(len,objects.values())),
                scope='Exact declared small method/provider pins only. Original hot dependencies remain untouched. No complete toolchain, source closure, binary reconstruction, or qualification claim.')
    with (out/'report.json').open('x') as stream:
        json.dump(result,stream,indent=2);stream.write('\n')
    print(json.dumps(dict(files=len(rows),exactObjects=len(objects),bytes=result['exportedUniqueBytes'],
                         unresolved=sum(x['status']!='exact bytes exported' for x in rows))))


if __name__=='__main__':
    main()
