"""Exact run-close safety controls; only tiny temporary fixtures are pruned."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import stat
import tempfile
import unittest
from unittest import mock

spec = importlib.util.spec_from_file_location('retention_close',Path(__file__).with_name('close.py'))
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class CloseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='bend-close-test-')
        self.root = Path(self.temp.name).resolve()
        self.run = self.root/'selfhost/build/test/guard'
        self.run.mkdir(parents=True)
        self.artifact = self.run.parent/'product'
        self.artifact.mkdir()
        self.product = self.artifact/'program'
        self.product.write_bytes(b'exact binary fixture\n')
        self.product.chmod(0o755)
        self.lock = self.root/'selfhost/build/phase32/execution.lock'
        self.lock.parent.mkdir()
        self.lock.touch()
        self.out = self.root/'selfhost/build-retention/closed'
        self.patches = [mock.patch.object(C,'ROOT',self.root),mock.patch.object(C.A,'ROOT',self.root),
                        mock.patch.object(C.A,'LOCK',self.lock),mock.patch.object(C,'free_space',return_value=16*1024*C.MIB)]
        for patch in self.patches:
            patch.start()
            self.addCleanup(patch.stop)
        self.addCleanup(self.temp.cleanup)
        self.write_guard([self.artifact])

    def write_guard(self, roots, *, complete=True, finished=True):
        self.state = dict(kind='build-retention-run-v1',version=1,state='finished' if finished else 'active',
                          closed=False,outcome='succeeded' if complete else 'failed',
                          guardDirectory=str(self.run),artifactRoots=list(map(str,roots)))
        self.process = dict(kind='build-retention-disk-guard-v1',complete=complete,
                            artifactRoots=self.state['artifactRoots'],returncode=0 if complete else 1)
        if finished:
            self.process['finished']=1
        (self.run/'retention.json').write_text(json.dumps(self.state)+'\n')
        (self.run/'process.json').write_text(json.dumps(self.process)+'\n')
        self.process_before=(self.run/'process.json').read_bytes()

    def invoke(self, **kwargs):
        args = dict(run=self.run,out=self.out,classification='completed',qualification=None,
                    keep_root=[],prune=False)
        args.update(kwargs)
        with C.A.exclusive():
            return C.close(argparse.Namespace(**args))

    def retention(self):
        return json.loads((self.run/'retention.json').read_text())

    def test_completed_archive_without_prune_preserves_hot_original(self):
        result = self.invoke()
        self.assertTrue(result['complete'])
        self.assertTrue(self.product.exists())
        self.assertEqual(result['roots'][0]['archivedFiles'],1)
        self.assertEqual(self.retention()['state'],'sealed')
        self.assertTrue(self.retention()['closed'])
        self.assertEqual((self.run/'process.json').read_bytes(),self.process_before)
        C.A.authenticate(self.retention()['closure'])

    def test_prune_then_restore_exact_bytes_and_mode(self):
        before=self.product.stat()
        result=self.invoke(prune=True)
        self.assertEqual(result['roots'][0]['removedFiles'],1)
        self.assertFalse(self.product.exists())
        self.assertTrue(self.artifact.is_dir())
        plan=Path(result['roots'][0]['plan']['file'])
        with C.A.exclusive():
            restored=C.A.restore(argparse.Namespace(plan=plan,out=self.root/'selfhost/build-retention/restore',member=None,destination=None))
        self.assertEqual(restored['restored'],1)
        self.assertEqual(self.product.read_bytes(),b'exact binary fixture\n')
        self.assertEqual(stat.S_IMODE(self.product.stat().st_mode),0o755)
        self.assertEqual(self.product.stat().st_mtime_ns,before.st_mtime_ns)

    def test_qualified_requires_evidence_and_keeps_all_hot(self):
        with self.assertRaisesRegex(ValueError,'qualification'):
            self.invoke(classification='qualified')
        qualification=self.root/'qualification.json'
        qualification.write_text('{"complete":true}\n')
        result=self.invoke(classification='qualified',qualification=qualification)
        self.assertTrue(result['roots'][0]['keptHot'])
        self.assertNotIn('archiveReceipt',result['roots'][0])
        self.assertTrue(self.product.exists())
        self.assertEqual(self.retention()['classification'],'qualified')

    def test_qualified_cannot_prune(self):
        qualification=self.root/'qualification.json'
        qualification.write_text('{"complete":true}\n')
        with self.assertRaisesRegex(ValueError,'no pruning'):
            self.invoke(classification='qualified',qualification=qualification,prune=True)
        self.assertFalse(self.out.exists())

    def test_keep_root_protects_whole_selected_root(self):
        second=self.run.parent/'second'
        second.mkdir()
        (second/'temporary').write_text('result')
        self.write_guard([self.artifact,second])
        result=self.invoke(keep_root=[self.artifact],prune=True)
        self.assertTrue(self.product.exists())
        self.assertFalse((second/'temporary').exists())
        self.assertTrue(result['roots'][0]['keptHot'])
        self.assertEqual(self.retention()['retained'],[str(self.artifact)])

    def test_hardlinks_have_regular_archive_members_but_remain_hot(self):
        alias=self.artifact/'alias'
        os.link(self.product,alias)
        result=self.invoke(prune=True)
        self.assertEqual(result['roots'][0]['archivedFiles'],2)
        self.assertEqual(result['roots'][0]['prunableFiles'],0)
        self.assertEqual(result['roots'][0]['kept']['Shared inode'],2)
        self.assertTrue(self.product.exists() and alias.exists())

    def test_symlink_second_root_refuses_before_any_prune(self):
        second=self.run.parent/'second'
        second.mkdir()
        (second/'link').symlink_to(self.product)
        self.write_guard([self.artifact,second])
        with self.assertRaisesRegex(ValueError,'Symlinked'):
            self.invoke(prune=True)
        self.assertTrue(self.product.exists())
        self.assertFalse(self.retention()['closed'])
        self.assertFalse(json.loads((self.out/'report.json').read_text())['complete'])

    def test_root_size_limit_keeps_source_and_unsealed_state(self):
        with mock.patch.object(C,'MAX_RAW',4):
            with self.assertRaisesRegex(ValueError,'closure limit'):
                self.invoke(prune=True)
        self.assertTrue(self.product.exists())
        self.assertFalse(self.retention()['closed'])

    def test_disk_scratch_refusal_does_not_prune(self):
        with mock.patch.object(C,'free_space',return_value=513*C.MIB):
            with self.assertRaisesRegex(ValueError,'scratch'):
                self.invoke(prune=True)
        self.assertTrue(self.product.exists())
        self.assertFalse(self.retention()['closed'])

    def test_disk_pressure_during_archive_keeps_run_unsealed(self):
        def remaining():
            return C.RESERVE-1 if (self.out/'root-00/files.tar.gz').exists() else 16*1024*C.MIB
        with mock.patch.object(C,'free_space',side_effect=remaining):
            with self.assertRaisesRegex(ValueError,'reserve'):
                self.invoke(prune=True)
        self.assertTrue(self.product.exists())
        self.assertFalse(self.retention()['closed'])

    def test_changed_guard_receipt_refuses_before_prune(self):
        original=C.capsule
        def changed(*args,**kwargs):
            receipt=original(*args,**kwargs)
            (self.run/'process.json').write_text('{"changed":true}\n')
            return receipt
        with mock.patch.object(C,'capsule',side_effect=changed):
            with self.assertRaisesRegex(ValueError,'Changed pinned input'):
                self.invoke(prune=True)
        self.assertTrue(self.product.exists())
        self.assertFalse(self.retention()['closed'])

    def test_failed_atomic_commit_does_not_claim_closed_lifecycle(self):
        with mock.patch.object(C.os,'replace',side_effect=OSError('simulated commit failure')):
            with self.assertRaises(OSError):
                self.invoke()
        self.assertFalse(self.retention()['closed'])
        self.assertFalse(json.loads((self.out/'failure.json').read_text())['complete'])
        self.assertEqual(list(self.run.glob('.retention-close-*')),[])
        self.assertTrue(self.product.exists())

    def test_active_run_and_repeat_close_refused(self):
        self.write_guard([self.artifact],finished=False)
        with self.assertRaisesRegex(ValueError,'finished guarded'):
            self.invoke()
        self.write_guard([self.artifact])
        self.invoke()
        self.out=self.root/'selfhost/build-retention/second-close'
        with self.assertRaisesRegex(ValueError,'finished guarded'):
            self.invoke()

    def test_failed_classification_preserves_failure_evidence(self):
        self.write_guard([self.artifact],complete=False)
        with self.assertRaisesRegex(ValueError,'successful guarded'):
            self.invoke()
        result=self.invoke(classification='failed',prune=True)
        self.assertEqual(result['classification'],'failed')
        self.assertFalse(self.product.exists())
        self.assertEqual((self.run/'process.json').read_bytes(),self.process_before)
        self.assertTrue((self.run/'retention.json').exists())

    def test_shared_lock_and_guard_directory_cannot_be_artifact_roots(self):
        for root in [self.lock.parent,self.run]:
            with self.subTest(root=root):
                self.write_guard([root])
                with self.assertRaises(ValueError):
                    self.invoke(prune=True)
        self.assertTrue(self.lock.exists())


if __name__ == '__main__':
    unittest.main()
