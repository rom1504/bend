"""Isolated safety controls for lossless build-retention pruning and restoration."""
import argparse
import gzip
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import stat
import tarfile
import tempfile
import unittest
from unittest import mock

METHOD = Path(__file__).with_name('archive-v02.py')
spec = importlib.util.spec_from_file_location('retention_archive_under_test', METHOD)
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)


def fingerprint(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


class ArchiveSafety(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='bend-retention-test-')
        self.root = Path(self.temp.name).resolve()
        self.build = self.root/'selfhost/build/phase5'
        self.build.mkdir(parents=True)
        self.lock = self.root/'selfhost/build/phase32/execution.lock'
        self.lock.parent.mkdir(parents=True)
        self.lock.touch()
        self.patch_root = mock.patch.object(A, 'ROOT', self.root)
        self.patch_lock = mock.patch.object(A, 'LOCK', self.lock)
        self.patch_root.start()
        self.patch_lock.start()
        self.addCleanup(self.patch_root.stop)
        self.addCleanup(self.patch_lock.stop)
        self.addCleanup(self.temp.cleanup)
        self.serial = 0
        self.policy_path = self.root/'policy.json'
        self.receipt_path = self.root/'archives/receipt.json'
        self.receipt_path.parent.mkdir()
        self.archive_path = self.receipt_path.parent/'raw.tar.gz'
        self.policy = dict(allowedRoots=['selfhost/build/phase5'],
                           archiveRoots={'archives/receipt.json':'selfhost/build/phase5'},
                           keepPrefixes=[])
        self.write_policy()

    def write_policy(self):
        self.policy_path.write_text(json.dumps(self.policy)+'\n')

    def output(self):
        self.serial += 1
        return self.root/'selfhost/build-retention'/str(self.serial)

    def fixture(self, items=None, *, members=None, archive_mode=0o644, current_mode=0o644):
        items = items or {'nested/product.bin':b'unchanged generated product\n'}
        for name, data in items.items():
            # Bad tar paths are constructed through members, never written here.
            path = self.build/name
            path.parent.mkdir(parents=True,exist_ok=True)
            path.write_bytes(data)
            path.chmod(current_mode)
        manifest = {name:fingerprint(data) for name,data in items.items()}
        with tarfile.open(self.archive_path,'w:gz') as archive:
            for name,data,kind in (members if members is not None else [(n,d,'file') for n,d in items.items()]):
                info = tarfile.TarInfo(name)
                info.mode = archive_mode
                if kind == 'file':
                    info.size = len(data)
                    archive.addfile(info,io.BytesIO(data))
                else:
                    info.type = tarfile.SYMTYPE if kind == 'symlink' else tarfile.LNKTYPE
                    info.linkname = '../outside'
                    archive.addfile(info)
        self.receipt = dict(complete=True,reopenedVerified=True,inputStabilityVerified=True,
                            rawRoot=str(self.build),archive=dict(path='raw.tar.gz',**fingerprint(self.archive_path.read_bytes())),
                            files=manifest,members=len(manifest))
        self.save_receipt()
        return items

    def save_receipt(self):
        self.receipt_path.write_text(json.dumps(self.receipt)+'\n')

    def verify(self):
        out = self.output()
        result = A.verify(argparse.Namespace(policy=self.policy_path,receipt=self.receipt_path,out=out))
        return out/'plan.json',result

    def apply(self,plan):
        return A.apply(argparse.Namespace(plan=plan,out=self.output()))

    def restore(self,plan,**kw):
        return A.restore(argparse.Namespace(plan=plan,out=self.output(),member=kw.get('member'),destination=kw.get('destination')))

    def forge_row(self,plan_path,name,path=None):
        plan = json.loads(plan_path.read_text())
        listing = Path(plan['files']['file'])
        path = path or self.build/name
        row = dict(member=name,relative=name,file=A.pin(path),metadata=A.metadata(path),archiveMode=0o644)
        listing.write_text(json.dumps(row)+'\n')
        plan['files'] = A.pin(listing)
        plan['selectedFiles'] = 1
        plan['allocatedBytes'] = row['metadata']['allocatedBytes']
        plan['logicalBytes'] = row['file']['bytes']
        plan_path.write_text(json.dumps(plan)+'\n')

    def test_roundtrip_preserves_current_mode_even_if_archive_mode_differs(self):
        items = self.fixture(current_mode=0o755,archive_mode=0o644)
        original = self.build/next(iter(items))
        before = original.stat()
        plan,result = self.verify()
        self.assertEqual(result['selectedFiles'],1)
        self.assertTrue(self.apply(plan)['complete'])
        self.assertFalse(original.exists())
        self.assertEqual(self.restore(plan)['restored'],1)
        self.assertEqual(original.read_bytes(),items[next(iter(items))])
        self.assertEqual(stat.S_IMODE(original.stat().st_mode),0o755)
        self.assertEqual(original.stat().st_mtime_ns,before.st_mtime_ns)
        self.assertEqual(self.restore(plan)['alreadyExact'],1)

    def test_archive_checksum_corruption_refused(self):
        self.fixture()
        data = bytearray(self.archive_path.read_bytes())
        data[len(data)//2] ^= 1
        self.archive_path.write_bytes(data)
        with self.assertRaises((ValueError,tarfile.TarError,EOFError,OSError)):
            self.verify()
        self.assertTrue((self.build/'nested/product.bin').exists())

    def test_bad_gzip_trailer_refused_even_when_transport_digest_matches(self):
        self.fixture()
        data = bytearray(self.archive_path.read_bytes())
        data[-8] ^= 1  # CRC mismatch while deflated tar members remain intact.
        self.archive_path.write_bytes(data)
        self.receipt['archive'].update(fingerprint(data))
        self.save_receipt()
        with self.assertRaises((ValueError,tarfile.TarError,EOFError,OSError)):
            self.verify()

    def test_missing_gzip_trailer_refused_even_when_transport_digest_matches(self):
        self.fixture()
        data = self.archive_path.read_bytes()[:-8]
        self.archive_path.write_bytes(data)
        self.receipt['archive'].update(fingerprint(data))
        self.save_receipt()
        with self.assertRaises((ValueError,tarfile.TarError,EOFError,OSError)):
            self.verify()

    def test_member_content_mismatch_refused(self):
        self.fixture({'a':b'expected'},members=[('a',b'changed!','file')])
        with self.assertRaises(ValueError):
            self.verify()

    def test_extra_duplicate_and_nonregular_members_refused(self):
        for members in [[('a',b'x','file'),('extra',b'x','file')],
                        [('a',b'x','file'),('a',b'x','file')],
                        [('a',b'','symlink')],[('a',b'','hardlink')]]:
            with self.subTest(members=members):
                self.fixture({'a':b'x'},members=members)
                with self.assertRaises(ValueError):
                    self.verify()

    def test_missing_member_refused(self):
        self.fixture({'a':b'a','b':b'b'},members=[('a',b'a','file')])
        with self.assertRaises(ValueError):
            self.verify()

    def test_unsafe_member_paths_refused(self):
        for name in ['../outside','/absolute','nested/../../outside','nested//product']:
            with self.subTest(name=name):
                self.fixture({'a':b'x'},members=[(name,b'x','file')])
                self.receipt['files']={name:fingerprint(b'x')}
                self.receipt['members']=1
                self.save_receipt()
                with self.assertRaises(ValueError):
                    self.verify()

    def test_symlinked_artifact_parent_refused(self):
        self.fixture({'nested/product':b'x'})
        (self.build/'nested/product').unlink()
        (self.build/'nested').rmdir()
        outside=self.root/'outside'
        outside.mkdir()
        (outside/'product').write_bytes(b'x')
        (self.build/'nested').symlink_to(outside,target_is_directory=True)
        with self.assertRaises(ValueError):
            self.verify()
        self.assertEqual((outside/'product').read_bytes(),b'x')

    def test_hardlinks_and_changed_products_are_kept(self):
        self.fixture({'shared':b'shared','changed':b'old','exact':b'exact'})
        os.link(self.build/'shared',self.root/'alias')
        (self.build/'changed').write_bytes(b'new')
        plan,result=self.verify()
        self.assertEqual(result['selectedFiles'],1)
        self.apply(plan)
        self.assertTrue((self.build/'shared').exists())
        self.assertEqual((self.build/'changed').read_bytes(),b'new')
        self.assertFalse((self.build/'exact').exists())

    def test_nonempty_xattrs_are_kept(self):
        self.fixture({'a':b'a'})
        try:
            os.setxattr(self.build/'a','user.retention-test',b'preserve')
        except OSError as error:
            self.skipTest('Temporary filesystem lacks user xattrs: '+str(error))
        plan,result=self.verify()
        self.assertEqual(result['selectedFiles'],0)
        self.assertEqual(os.getxattr(self.build/'a','user.retention-test'),b'preserve')

    def test_stale_late_row_prevents_all_deletions(self):
        self.fixture({'first':b'first','second':b'second'})
        plan,_=self.verify()
        (self.build/'second').write_bytes(b'CHANGED')
        with self.assertRaises(ValueError):
            self.apply(plan)
        self.assertTrue((self.build/'first').exists())
        self.assertTrue((self.build/'second').exists())

    def test_restore_never_overwrites_changed_content_or_mode(self):
        self.fixture({'a':b'a'})
        plan,_=self.verify()
        self.apply(plan)
        (self.build/'a').write_bytes(b'new user work')
        with self.assertRaises(ValueError):
            self.restore(plan)
        self.assertEqual((self.build/'a').read_bytes(),b'new user work')
        (self.build/'a').write_bytes(b'a')
        (self.build/'a').chmod(0o755)
        with self.assertRaises(ValueError):
            self.restore(plan)
        self.assertEqual(stat.S_IMODE((self.build/'a').stat().st_mode),0o755)

    def test_multipart_archive_roundtrip(self):
        self.fixture({'nested/a':b'alpha'*5000,'nested/b':b'beta'*5000})
        data=self.archive_path.read_bytes()
        cuts=[0,len(data)//3,2*len(data)//3,len(data)]
        for i,(left,right) in enumerate(zip(cuts,cuts[1:])):
            self.archive_path.with_name('raw.tar.gz.part-'+f'{i:03d}').write_bytes(data[left:right])
        self.archive_path.unlink()
        plan,result=self.verify()
        self.assertEqual(result['selectedFiles'],2)
        self.apply(plan)
        self.assertEqual(self.restore(plan)['restored'],2)
        self.assertEqual((self.build/'nested/a').read_bytes(),b'alpha'*5000)

    def test_multipart_gap_refused(self):
        self.fixture()
        data=self.archive_path.read_bytes()
        self.archive_path.with_name('raw.tar.gz.part-000').write_bytes(data[:10])
        self.archive_path.with_name('raw.tar.gz.part-002').write_bytes(data[10:])
        self.archive_path.unlink()
        with self.assertRaises(ValueError):
            self.verify()

    def test_repository_relative_archive_verifies_but_keeps_outside_members(self):
        self.fixture({'a':b'generated'})
        outside=self.root/'outside-evidence.json'
        outside.write_bytes(b'preserve outside evidence')
        members={'selfhost/build/phase5/a':b'generated',
                 'outside-evidence.json':outside.read_bytes()}
        with tarfile.open(self.archive_path,'w:gz') as archive:
            for name,data in members.items():
                info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644
                archive.addfile(info,io.BytesIO(data))
        self.receipt=dict(complete=True,reopenedAllMembers=True,
                          inputInventoryAndHashesUnchanged=True,
                          archive=dict(file='archives/raw.tar.gz',**fingerprint(self.archive_path.read_bytes())),
                          files=[dict(file=name,**fingerprint(data)) for name,data in members.items()],
                          fileCount=len(members))
        self.save_receipt()
        plan,result=self.verify()
        self.assertEqual(result['selectedFiles'],1)
        self.assertEqual(result['kept']['outside-approved-root'],1)
        self.apply(plan)
        self.assertEqual(outside.read_bytes(),b'preserve outside evidence')
        self.assertFalse((self.build/'a').exists())
        self.assertEqual(self.restore(plan)['restored'],1)
        self.assertEqual((self.build/'a').read_bytes(),b'generated')

    def test_explicit_multipart_receipt(self):
        self.fixture({'a':b'explicit transport'})
        data=self.archive_path.read_bytes()
        parts=[]
        for index,part in enumerate([data[:17],data[17:]]):
            p=self.root/'archives'/f'transport-{index}'
            p.write_bytes(part)
            parts.append(dict(file=str(p.relative_to(self.root)),**fingerprint(part)))
        self.receipt['archive']['parts']=parts
        self.save_receipt()
        self.archive_path.unlink()
        plan,result=self.verify()
        self.assertEqual(result['selectedFiles'],1)
        self.apply(plan)
        self.assertEqual(self.restore(plan)['restored'],1)

    def test_restore_rejects_outside_or_symlinked_destination_and_unknown_member(self):
        self.fixture({'a':b'a'})
        plan,_=self.verify()
        with self.assertRaises(ValueError):
            self.restore(plan,destination=self.root.parent/'outside-restore-forbidden')
        redirected=self.root/'redirect'
        redirected.symlink_to(self.root.parent,target_is_directory=True)
        with self.assertRaises(ValueError):
            self.restore(plan,destination=redirected)
        with self.assertRaises(ValueError):
            self.restore(plan,member=['not-in-plan'])

    def test_interrupted_prune_has_durable_intent_and_is_restorable(self):
        self.fixture({'first':b'first','second':b'second'})
        plan,_=self.verify()
        out=self.output()
        original=Path.unlink
        def stop_second(path,*args,**kwargs):
            if path == self.build/'second':
                raise OSError('simulated interrupted unlink')
            return original(path,*args,**kwargs)
        with mock.patch.object(Path,'unlink',new=stop_second):
            with self.assertRaises(OSError):
                A.apply(argparse.Namespace(plan=plan,out=out))
        intent=json.loads((out/'intent.json').read_text())
        report=json.loads((out/'report.json').read_text())
        self.assertTrue(intent['complete'])
        self.assertEqual(intent['selectedFiles'],2)
        self.assertFalse(report['complete'])
        self.assertEqual(report['removedFiles'],1)
        self.assertFalse((self.build/'first').exists())
        self.assertTrue((self.build/'second').exists())
        restored=self.restore(plan)
        self.assertEqual(restored['restored'],1)
        self.assertEqual(restored['alreadyExact'],1)
        self.assertEqual((self.build/'first').read_bytes(),b'first')

    def test_forged_unarchived_member_cannot_be_deleted(self):
        self.fixture({'archived':b'a'})
        plan,_=self.verify()
        (self.build/'unarchived').write_bytes(b'unique data')
        self.forge_row(plan,'unarchived')
        with self.assertRaises(ValueError):
            self.apply(plan)
        self.assertEqual((self.build/'unarchived').read_bytes(),b'unique data')

    def test_protected_member_cannot_be_inserted_into_plan(self):
        self.fixture({'ordinary':b'a','protected':b'protected data'})
        self.policy['keepPrefixes']=['selfhost/build/phase5/protected']
        self.write_policy()
        plan,_=self.verify()
        self.forge_row(plan,'protected')
        with self.assertRaises(ValueError):
            self.apply(plan)
        self.assertEqual((self.build/'protected').read_bytes(),b'protected data')

    def test_forged_plan_root_cannot_target_another_allowed_tree(self):
        self.fixture({'a':b'a'})
        self.policy['allowedRoots'].append('selfhost/build/phase16')
        self.write_policy()
        plan_path,_=self.verify()
        other=self.root/'selfhost/build/phase16'
        other.mkdir()
        (other/'a').write_bytes(b'a')
        self.forge_row(plan_path,'a',other/'a')
        plan=json.loads(plan_path.read_text());plan['root']=str(other);plan_path.write_text(json.dumps(plan))
        with self.assertRaises(ValueError):
            self.apply(plan_path)
        self.assertTrue((other/'a').exists())

    def test_policy_changed_during_verification_not_blessed(self):
        self.fixture({'a':b'a'})
        original=A.archive_parts
        def mutate(*args):
            result=original(*args)
            self.policy['keepPrefixes']=['selfhost/build/phase5/a']
            self.write_policy()
            return result
        with mock.patch.object(A,'archive_parts',side_effect=mutate):
            with self.assertRaises(ValueError):
                self.verify()
        self.assertTrue((self.build/'a').exists())

    def test_shared_lock_is_not_replaced_or_reentered(self):
        before=self.lock.stat().st_ino
        with A.exclusive():
            with self.assertRaises(BlockingIOError):
                with A.exclusive():
                    self.fail('second cleanup admitted')
        self.assertEqual(self.lock.stat().st_ino,before)


if __name__ == '__main__':
    unittest.main()
