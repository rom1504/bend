#!/usr/bin/env python3
"""Seal or restore the admitted native compiler's request assets; never run targets."""
import argparse,hashlib,importlib.util,json,os,shutil,stat,sys,tempfile,zipfile
from pathlib import Path,PurePosixPath
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
RESERVE=160*1024**2

def digest(stream):
    result=hashlib.sha256();size=0
    for chunk in iter(lambda:stream.read(1024*1024),b''):
        result.update(chunk);size+=len(chunk)
    return result.hexdigest(),size

def identity(file):
    file=Path(file).resolve();assert file.is_relative_to(ROOT),'Asset outside checkout'
    with file.open('rb') as stream:sha,size=digest(stream)
    return dict(file=str(file.relative_to(ROOT)),sha256=sha,bytes=size)

def path(name):
    relative=PurePosixPath(name)
    assert not relative.is_absolute() and '..' not in relative.parts and str(relative)==name
    result=(ROOT/name).resolve();assert result.is_relative_to(ROOT),'Escaping asset path'
    return result

def bound(record):
    file=path(record['file']);assert identity(file)==record,'Changed capsule metadata: '+str(file)
    return file

def launcher():
    spec=importlib.util.spec_from_file_location('native90_public_assets',HERE/'native.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module

def selection(pointer):
    api=launcher();admission,binding=api.load(pointer)
    records=[binding['selection'],binding['admission']]
    records.extend(admission[key] for key in ['binary','source','base','runtime','template'])
    records.extend(admission['parts']+admission['effects']+[admission['cache']['carrier']])
    records.extend(api.pin(file) for file in [HERE/'native.py',Path(__file__),
        ROOT/'selfhost/tools/performance/phase86/guard.py',ROOT/'selfhost/tools/performance/programs/support.py'])
    files={}
    for record in records:
        api.verify(record);file=Path(record['file']);item=identity(file)
        item['mode']=stat.S_IMODE(file.stat().st_mode);assert not item['mode']&0o7000
        assert item['file'] not in files or item==files[item['file']]
        files[item['file']]=item
    assert files[str(Path(admission['binary']['file']).relative_to(ROOT))]['mode']&0o111
    return sorted(files.values(),key=lambda item:item['file']),binding

def check_archive(archive,rows):
    with zipfile.ZipFile(archive) as saved:
        assert saved.namelist()==[row['file'] for row in rows],'Unexpected or duplicate archive members'
        for row in rows:
            path(row['file'])
            info=saved.getinfo(row['file']);assert info.file_size==row['bytes']
            assert stat.S_IMODE(info.external_attr>>16)==row['mode'],'Archived mode mismatch'
            with saved.open(row['file']) as stream:sha,size=digest(stream)
            assert (sha,size)==(row['sha256'],row['bytes']),'Corrupt archived asset: '+row['file']

def seal(pointer,out):
    rows,binding=selection(pointer);out=out.resolve();assert out.is_relative_to(HERE)
    assert shutil.disk_usage(ROOT).free>=sum(row['bytes'] for row in rows)+RESERVE,'Need seal space plus 160 MiB reserve'
    out.mkdir(parents=True,exist_ok=False);archive=out/'native-assets.zip'
    with zipfile.ZipFile(archive,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as saved:
        for row in rows:saved.write(path(row['file']),row['file'])
    check_archive(archive,rows)
    assert selection(pointer)==(rows,binding),'Selected assets changed while sealing'
    manifest=out/'manifest.json'
    manifest.write_text(json.dumps(dict(kind='phase90-native-public-assets',version=1,complete=True,
        canonicalRoot=str(ROOT),selection=identity(pointer),admission=identity(binding['admission']['file']),
        files=rows,rawBytes=sum(row['bytes'] for row in rows),
        scope='Same-host request assets only; historical proof remains in the Phase90 evidence capsules. Absolute source-location ABI prevents silent checkout relocation.'),indent=2)+'\n')
    receipt=dict(kind='phase90-native-public-assets-capsule',version=1,complete=True,targetJobsRun=0,
        archive=identity(archive),manifest=identity(manifest),method=identity(__file__))
    (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetJobsRun=0,files=len(rows),rawBytes=sum(row['bytes'] for row in rows),receipt=identity(out/'receipt.json'))))

def restore(receipt_file,verify_only):
    receipt=json.loads(receipt_file.read_text())
    assert receipt['kind']=='phase90-native-public-assets-capsule' and receipt['version']==1 and receipt['complete']
    assert receipt['method']==identity(__file__),'Restore method differs from sealed method'
    archive=bound(receipt['archive']);manifest=json.loads(bound(receipt['manifest']).read_text())
    assert manifest['kind']=='phase90-native-public-assets' and manifest['version']==1 and manifest['complete']
    assert manifest['canonicalRoot']==str(ROOT),'Checkout relocation requires a new carrier/admission'
    rows=manifest['files'];assert len({row['file'] for row in rows})==len(rows)
    assert manifest['rawBytes']==sum(row['bytes'] for row in rows)
    members={row['file']:row for row in rows}
    for key in ['selection','admission']:
        record=manifest[key];assert {k:members[record['file']][k] for k in record}==record
    check_archive(archive,rows);missing=[]
    for row in rows:
        dest=path(row['file'])
        if dest.exists():
            assert identity(dest)=={key:row[key] for key in ['file','sha256','bytes']},'Refusing changed existing file: '+str(dest)
            assert stat.S_IMODE(dest.stat().st_mode)==row['mode'],'Refusing changed existing mode: '+str(dest)
        else:missing.append(row)
    if not verify_only:
        assert shutil.disk_usage(ROOT).free>=sum(row['bytes'] for row in missing)+RESERVE,'Need restoration space plus 160 MiB reserve'
        with zipfile.ZipFile(archive) as saved:
            for row in missing:
                dest=path(row['file']);dest.parent.mkdir(parents=True,exist_ok=True)
                with tempfile.NamedTemporaryFile(dir=dest.parent) as temp:
                    with saved.open(row['file']) as stream:shutil.copyfileobj(stream,temp)
                    temp.flush();os.fchmod(temp.fileno(),row['mode'])
                    assert identity(temp.name)['sha256']==row['sha256']
                    os.link(temp.name,dest)  # Atomic, and never replaces an existing path.
        assert selection(path(manifest['selection']['file']))[0]==rows,'Restored request assets differ'
    print(json.dumps(dict(complete=True,mode='verify' if verify_only else 'restore',targetJobsRun=0,
        files=len(rows),missingFiles=len(missing),missingBytes=sum(row['bytes'] for row in missing))))

def main():
    parser=argparse.ArgumentParser(description=__doc__);sub=parser.add_subparsers(dest='mode',required=True)
    create=sub.add_parser('seal');create.add_argument('pointer',type=Path);create.add_argument('out',type=Path)
    recover=sub.add_parser('restore');recover.add_argument('receipt',type=Path);recover.add_argument('--verify-only',action='store_true')
    args=parser.parse_args()
    if args.mode=='seal':seal(args.pointer,args.out)
    else:restore(args.receipt,verify_only=args.verify_only)

if __name__=='__main__':main()
