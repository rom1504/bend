#!/usr/bin/env python3
"""Journal exact closed native assembly/object dedup. No compiler is executed.

Adapted from Phase146 dedup-native-v01.py (8bd91d2), using maintained lock,
pinning, literal comparison and durable receipts. Both paths stay immutable.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import stat

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT/'selfhost/build'
PHASE = BUILD/'phase175'
KEYS = {'assembly': 'program.s', 'object': 'program.o',
        'retainedIR': 'program.ssa', 'product': 'program.ssa'}


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec); spec.loader.exec_module(obj)
    return obj


A = module('archive', ROOT/'selfhost/tools/build-retention/archive-v02.py')
C = module('common', ROOT/'selfhost/tools/build/common.py')
need = A.need


def metadata(path):
    need(path.resolve() == path and path.is_relative_to(BUILD), 'Unsafe product path')
    s = path.lstat()
    need(stat.S_ISREG(s.st_mode) and s.st_uid == os.geteuid() and s.st_gid == os.getegid(), 'Not owned regular file')
    need(not stat.S_IMODE(s.st_mode) & 0o7000 and not os.listxattr(path), 'Special mode/xattrs')
    return dict(device=s.st_dev, inode=s.st_ino, size=s.st_size, mode=stat.S_IMODE(s.st_mode),
                uid=s.st_uid, gid=s.st_gid, links=s.st_nlink, mtimeNs=s.st_mtime_ns,
                ctimeNs=s.st_ctime_ns, allocatedBytes=s.st_blocks*512)


def closed(report_path):
    need(report_path.name == 'report.json' and report_path.is_relative_to(BUILD), 'Build report required')
    root = report_path.parent
    guard = root.with_name(root.name+'-guard')
    inputs = [A.pin(p) for p in [report_path, guard/'process.json', guard/'retention.json']]
    r, g, life = [json.loads(Path(x['file']).read_text()) for x in inputs]
    need(r.get('complete') is True and not r.get('changedInputs') and r.get('target') == 'qbe', 'Incomplete/changed QBE build')
    if r.get('kind') == 'bend-native-build':
        need(r.get('compilerExitCode') == r.get('qbeExitCode') == 0, 'Failed producer')
        need([x['label'] for x in r['jobs']] == ['assemble', 'link'] and all(x.get('complete') and x.get('exitCode') == 0 for x in r['jobs']), 'Failed machine build')
    else:
        need(r.get('kind') == 'bend-build-request' and r.get('process',{}).get('complete') is True and r['process'].get('exitCode') == 0, 'Failed or unsupported request')
        need(r.get('request',{}).get('expected') and r.get('byteExact') is True, 'Independent exact request bridge required')
    need(g.get('complete') is True and g.get('returncode') == 0, 'Writer guard incomplete')
    need(life.get('state') == 'sealed' and life.get('closed') is True and life.get('outcome') == 'succeeded', 'Writer not closed')
    need(str(root) in g['artifactRoots'] and str(root) in life['artifactRoots'], 'Wrong writer root')
    for x in inputs: A.authenticate(x)
    return r, inputs


def inspect(left, right, pairs):
    a, ap = closed(left); b, bp = closed(right)
    rows = []
    for lk,rk in pairs:
        lp, rp = left.parent/KEYS[lk], right.parent/KEYS[rk]
        need(lp != rp and Path(a[lk]['file']) == lp and Path(b[rk]['file']) == rp, 'Product outside report root')
        lm, rm = metadata(lp), metadata(rp)
        need(all(lm[k] == rm[k] for k in ['device','size','mode','uid','gid']), 'Incompatible product metadata')
        linked = lm['inode'] == rm['inode']
        need(lm['links'] == rm['links'] == (2 if linked else 1), 'Unknown hardlink aliases')
        need(a[lk]['bytes'] == b[rk]['bytes'] and a[lk]['sha256'] == b[rk]['sha256'], 'Original product hashes differ')
        A.authenticate(a[lk]); A.authenticate(b[rk])
        need(C.same_bytes(lp, rp), 'Literal product comparison failed')
        need(metadata(lp) == lm and metadata(rp) == rm, 'Product changed while reading')
        rows.append(dict(key=lk+':'+rk, left=a[lk], right=b[rk], leftMetadata=lm, rightMetadata=rm,
                         literalEqual=True, alreadyLinked=linked))
    for x in ap+bp: A.authenticate(x)
    return dict(inputs=ap+bp, rows=rows)


def sync_parent(path):
    fd = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
    try: os.fsync(fd)
    finally: os.close(fd)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('command', choices=['verify','apply'])
    p.add_argument('--left-report', type=Path, required=True)
    p.add_argument('--right-report', type=Path, required=True)
    p.add_argument('--pair', action='append', help='Explicit report fields, e.g. assembly:assembly or retainedIR:product')
    p.add_argument('--verified', type=Path)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    left, right, out = [x.absolute() for x in [args.left_report, args.right_report, args.out]]
    need(right.parent.is_relative_to(PHASE), 'Only Phase175 duplicate storage may change')
    need(out.is_relative_to(PHASE) and out.resolve() == out and not out.exists(), 'Fresh Phase175 receipt required')
    pairs = [tuple(x.split(':')) for x in (args.pair or ['assembly:assembly','object:object'])]
    need(all(len(x)==2 and all(k in KEYS for k in x) for x in pairs), 'Unknown report field')
    need(len({KEYS[x[0]] for x in pairs}) == len(pairs) == len({KEYS[x[1]] for x in pairs}), 'Repeated product path')
    with A.exclusive():
        need(shutil.disk_usage(ROOT).free >= 5*2**30 + 2**20, '5 GiB reserve plus 1 MiB receipt allowance')
        method = [A.pin(Path(__file__).resolve()), A.pin(Path(A.__file__)), A.pin(Path(C.__file__))]
        before = inspect(left, right, pairs)
        result = dict(kind='phase175-closed-native-machine-dedup', command=args.command,
                      complete=False, targetsRun=False, method=method, before=before,
                      semantics='Storage identity only; no compiler qualification claim.',
                      futureWrites='Both product paths must remain immutable. Use fresh build roots. Inode/mtime/ctime become shared.')
        if args.command == 'apply':
            need(args.verified is not None, '--verified required')
            vpin = A.pin(args.verified.absolute()); v = json.loads(Path(vpin['file']).read_text())
            need(v.get('complete') is True and v.get('command') == 'verify' and v['method'] == method and v['before'] == before, 'Verification is stale')
            result['verified'] = vpin
            A.write_new(Path(str(out)+'.intent.json'), result)
            with Path(str(out)+'.journal.jsonl').open('x') as journal:
                for row in before['rows']:
                    if row['alreadyLinked']: continue
                    lp, rp = Path(row['left']['file']), Path(row['right']['file'])
                    need(metadata(lp) == row['leftMetadata'] and metadata(rp) == row['rightMetadata'], 'Changed before replacement')
                    temp = rp.with_name(rp.name+'.phase175-dedup-tmp')
                    need(not temp.exists() and not temp.is_symlink(), 'Existing temporary path')
                    try:
                        os.link(lp, temp)
                        A.authenticate(row['left']); A.authenticate(row['right'])
                        need(C.same_bytes(temp,rp) and metadata(rp) == row['rightMetadata'], 'Changed destination')
                        current = metadata(lp)
                        expected = dict(row['leftMetadata'], links=2, ctimeNs=current['ctimeNs'])
                        need(current == expected and temp.stat().st_ino == current['inode'], 'Changed keeper')
                        os.replace(temp,rp); sync_parent(rp)
                        journal.write(json.dumps(dict(key=row['key'], destination=str(rp), sha256=row['right']['sha256'], recoveredAllocatedBytes=row['rightMetadata']['allocatedBytes']))+'\n')
                        journal.flush(); os.fsync(journal.fileno())
                    finally:
                        if temp.exists(): temp.unlink()
        result['after'] = inspect(left,right,pairs)
        for x in before['inputs']+method: A.authenticate(x)
        need(result['after']['inputs'] == before['inputs'], 'Original build receipts changed')
        need([(x['left'],x['right']) for x in result['after']['rows']] == [(x['left'],x['right']) for x in before['rows']], 'Original products changed')
        result.update(complete=True, recoveredAllocatedBytes=sum(r['rightMetadata']['allocatedBytes'] for r in before['rows'] if not r['alreadyLinked']) if args.command=='apply' else 0,
                      potentialAllocatedBytes=sum(r['rightMetadata']['allocatedBytes'] for r in before['rows'] if not r['alreadyLinked']))
        A.write_new(out,result)
        print(json.dumps(dict(complete=True,command=args.command,potentialAllocatedBytes=result['potentialAllocatedBytes'],recoveredAllocatedBytes=result['recoveredAllocatedBytes'])))


if __name__ == '__main__':
    main()
