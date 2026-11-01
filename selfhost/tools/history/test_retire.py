"""Retirement semantics in disposable Git repositories, never the real checkout."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock
import contextlib
import io
import sys
from history_data import read_json, write_json
import inventory as INVENTORY
import restore as RESTORE

SPEC = importlib.util.spec_from_file_location('history_retire', Path(__file__).with_name('retire.py'))
R = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(R)


class Retirement(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='bend-retirement-test-')
        self.root = Path(self.temp.name)
        self.git('init', '-q')
        for path, body in [('history/clean.c', 'old clean\n'), ('history/dirty.py', 'old dirty\n'),
                           ('history/staged.c', 'old staged\n')]:
            dest = self.root/path; dest.parent.mkdir(parents=True, exist_ok=True); dest.write_text(body)
        self.git('add', '.')
        self.git('-c', 'user.name=Retirement Test', '-c', 'user.email=test@example.invalid', 'commit', '-qm', 'baseline')
        self.baseline = self.git('rev-parse', 'HEAD').decode().strip()
        rows = []
        for path, row in R.tree(self.root, self.baseline).items():
            rows.append(dict(path=path, **row, bytes=(self.root/path).stat().st_size, action='retire', reason='test-fixture'))
        self.inv = self.root/'inventory.json'
        self.inv.write_text(json.dumps(dict(schema='bend-history-inventory-v1', proposalOnly=True,
            baselineCommit=self.baseline, files=rows)))

    def tearDown(self):
        self.temp.cleanup()

    def git(self, *args):
        return R.git(self.root, *args)

    def plan(self):
        self.path = self.root/'plan.json'
        self.result = R.make_plan(self.root, self.inv, self.path)
        return json.loads(self.path.read_text())

    def apply(self):
        return R.apply_plan(self.root, self.path, self.result['plan']['sha256'], self.root/'receipt.json')

    def test_clean_delete_dirty_preserve_staged_exclude(self):
        (self.root/'history/dirty.py').write_text('user uncommitted work\n')
        (self.root/'history/staged.c').write_text('user staged work\n')
        self.git('add', 'history/staged.c')
        before = self.git('show', ':history/staged.c')
        plan = self.plan()
        self.assertEqual(len(plan['files']), 2)
        self.assertEqual(plan['exclusions'][0]['reason'], 'index-does-not-match-baseline')
        self.assertTrue((self.root/'history/clean.c').exists())
        self.assertEqual(len(R.index(self.root)), 3)  # Planning did not stage anything.
        result = self.apply()
        self.assertTrue(result['complete'])
        self.assertFalse((self.root/'history/clean.c').exists())
        self.assertEqual((self.root/'history/dirty.py').read_text(), 'user uncommitted work\n')
        self.assertEqual(self.git('show', ':history/staged.c'), before)
        self.assertEqual(list(R.index(self.root)), ['history/staged.c'])

    def test_changed_working_file_refuses_before_index_mutation(self):
        self.plan(); before = R.index(self.root)
        (self.root/'history/clean.c').write_text('later edit\n')
        with self.assertRaisesRegex(ValueError, 'Working file changed'):
            self.apply()
        self.assertEqual(R.index(self.root), before)
        self.assertFalse((self.root/'receipt.json').exists())

    def test_literal_dependency_excluded(self):
        tool = self.root/'selfhost/tools/active.py'; tool.parent.mkdir(parents=True)
        tool.write_text("path = '../../history/clean.c'\n")
        plan = self.plan()
        self.assertTrue(any(r['path']=='history/clean.c' and r['reason']=='active-tool-literal-reference' for r in plan['exclusions']))

    def test_transitive_dependency_excluded(self):
        tool = self.root/'selfhost/tools/active.py'; tool.parent.mkdir(parents=True)
        tool.write_text("path = '../../history/dirty.py'\n")
        (self.root/'history/dirty.py').write_text("path = 'staged.c'\n")
        plan = self.plan()
        blocked = {row['path'] for row in plan['exclusions'] if row['reason']=='active-tool-literal-reference'}
        self.assertEqual(blocked, {'history/dirty.py','history/staged.c'})

    def test_historical_tree_is_not_scanned_as_active_code(self):
        old = self.root/'selfhost/tools/performance/phase999/huge-history.py'
        old.parent.mkdir(parents=True)
        old.write_bytes(b'\xffnot current UTF-8 source')
        self.assertEqual(len(self.plan()['files']), 3)

    def test_generic_distribution_prefix_is_not_a_read_of_all_history(self):
        tool = self.root/'selfhost/tools/publisher.py'; tool.parent.mkdir(parents=True)
        tool.write_text("prefix = 'dist/'\n")
        blockers, _ = R.dependencies(self.root, {'selfhost/dist/history/old-api.mjs'})
        self.assertEqual(blockers, {})

    def test_gzip_index_and_receipt_roundtrip(self):
        data = json.loads(self.inv.read_text()); first=self.root/'inventory.json.gz'; second=self.root/'copy.json.gz'
        write_json(first,data); write_json(second,data)
        self.assertEqual(first.read_bytes(),second.read_bytes())
        self.inv=first;self.plan()
        receipt=self.root/'receipt.json.gz'
        result=R.apply_plan(self.root,self.path,self.result['plan']['sha256'],receipt)
        self.assertTrue(result['complete'])
        self.assertTrue(read_json(receipt)['complete'])

    def test_reviewed_incidental_copy_is_exact_consumer_bound(self):
        tool=self.root/'selfhost/tools/active.py';tool.parent.mkdir(parents=True)
        tool.write_text("copied = '../../history/clean.c'\n")
        review=self.root/'selfhost/manifests/history-dependency-review-v1.json';review.parent.mkdir(parents=True)
        review.write_text(json.dumps(dict(schema='bend-history-dependency-review-v1',exceptions=[dict(target='history/clean.c',consumer='selfhost/tools/active.py',consumerSha256=R.pin(tool)['sha256'],reason='Test explicit review')])) )
        self.assertEqual(self.plan()['exclusions'],[])
        tool.write_text(tool.read_text()+'# changed after review\n')
        with self.assertRaisesRegex(ValueError,'Reviewed dependency consumer changed'):
            R.dependencies(self.root,{'history/clean.c'})

    def test_reviewed_edge_disconnects_only_unreachable_historical_dependencies(self):
        tool=self.root/'selfhost/tools/active.py';tool.parent.mkdir(parents=True)
        tool.write_text("absent = '../../history/dirty.py'\n")
        (self.root/'history/dirty.py').write_text("dependency = 'clean.c'\n")
        proposed={'history/dirty.py','history/clean.c'}
        self.assertEqual(set(R.dependencies(self.root,proposed)[0]),proposed)
        review=self.root/'selfhost/manifests/history-dependency-review-v1.json';review.parent.mkdir(parents=True)
        review.write_text(json.dumps(dict(schema='bend-history-dependency-review-v1',exceptions=[dict(target='history/dirty.py',consumer='selfhost/tools/active.py',consumerSha256=R.pin(tool)['sha256'],reason='Reviewed absence assertion')])) )
        self.assertEqual(R.dependencies(self.root,proposed)[0],{})
        independent=self.root/'selfhost/tools/other.py'
        independent.write_text("required = '../../history/clean.c'\n")
        remaining=R.dependencies(self.root,proposed)[0]
        self.assertEqual(set(remaining),{'history/clean.c'})
        self.assertEqual([r['consumer']for r in remaining['history/clean.c']],['selfhost/tools/other.py'])

    def test_canonical_module_protected(self):
        path = self.root/'selfhost/src/example.bend'; path.parent.mkdir(parents=True)
        path.write_text('def example(): 1\n')
        self.git('add', 'selfhost/src/example.bend')
        self.git('-c', 'user.name=Retirement Test', '-c', 'user.email=test@example.invalid', 'commit', '-qm', 'add source')
        self.baseline = self.git('rev-parse', 'HEAD').decode().strip()
        manifest = self.root/'selfhost/src/compiler.json'; manifest.parent.mkdir(parents=True, exist_ok=True)
        manifest.write_text(json.dumps(dict(modules=['src/example.bend'])))
        inv = json.loads(self.inv.read_text()); inv['baselineCommit'] = self.baseline
        inv['files'].append(dict(path='selfhost/src/example.bend', **R.tree(self.root,self.baseline)['selfhost/src/example.bend'], bytes=path.stat().st_size,action='retire',reason='test'))
        self.inv.write_text(json.dumps(inv))
        plan = self.plan()
        self.assertTrue(any(r['path']=='selfhost/src/example.bend' and r['reason']=='canonical-source' for r in plan['exclusions']))

    def test_wrong_baseline_blob_refuses(self):
        inv = json.loads(self.inv.read_text()); inv['files'][0]['gitBlob'] = '0'*40
        self.inv.write_text(json.dumps(inv))
        with self.assertRaisesRegex(ValueError, 'Inventory/baseline mismatch'):
            self.plan()

    def test_wrong_review_hash_refuses(self):
        self.plan(); before = R.index(self.root)
        with self.assertRaisesRegex(ValueError, 'Plan hash differs'):
            R.apply_plan(self.root, self.path, '0'*64, self.root/'receipt.json')
        self.assertEqual(R.index(self.root), before)

    def test_clean_workspace_protection_is_index_only(self):
        inv = json.loads(self.inv.read_text()); inv['files'][0]['workspaceProtected'] = True
        self.inv.write_text(json.dumps(inv)); path=inv['files'][0]['path']
        self.plan(); self.apply()
        self.assertTrue((self.root/path).exists())
        self.assertNotIn(path,R.index(self.root))


class SplitArchives(unittest.TestCase):
    def policy(self):
        return dict(keepPaths=[],pendingMigrationPaths=[],pendingMigrationPrefixes=[])

    def rows(self, suffixes):
        return [dict(path='implementation/example/archive.tar.gz'+suffix,gitBlob=f'{i:040x}',bytes=i+1)
                for i,suffix in enumerate(suffixes)]

    def test_split_variants_are_archives_but_reports_are_not(self):
        for suffix in ['.tar.gz.part-001','.tar.gz.part001','.tar.gz.part00001','.zip.part000','.tar.xz.part-00001']:
            self.assertEqual(INVENTORY.classify('implementation/example/a'+suffix,self.policy())[0],'retire')
        for name in ['archive.tar.gz.part001.json','partition.json','partial-results.md']:
            self.assertEqual(INVENTORY.classify('implementation/example/'+name,self.policy())[0],'keep')
        policy=self.policy();policy['pendingMigrationPrefixes']=['selfhost/tools/native/']
        self.assertEqual(INVENTORY.classify('selfhost/tools/native/old.zip.part001',policy)[0],'blocked')

    def test_group_order_pins_and_missing_part_refusal(self):
        rows=self.rows(['.part002','.part001']);groups=INVENTORY.archive_groups(rows)
        self.assertEqual([p['partNumber']for p in groups[0]['parts']],[1,2])
        manifest=dict(files=rows,archiveGroups=groups)
        self.assertEqual(RESTORE.select_paths(manifest,[],groups[0]['archivePath']),[rows[1]['path'],rows[0]['path']])
        broken=dict(files=rows,archiveGroups=INVENTORY.archive_groups(self.rows(['.part001','.part003'])))
        with self.assertRaisesRegex(ValueError,'nonconsecutive'):
            RESTORE.select_paths(broken,[],groups[0]['archivePath'])
        groups[0]['parts'].pop()
        with self.assertRaisesRegex(ValueError,'omits or duplicates'):
            RESTORE.select_paths(manifest,[],groups[0]['archivePath'])

    def test_duplicate_number_and_pin_mismatch_refusal(self):
        rows=self.rows(['.part1','.part01'])
        self.assertFalse(INVENTORY.archive_groups(rows)[0]['consecutiveTrackedParts'])
        rows=self.rows(['.part001','.part002']);groups=INVENTORY.archive_groups(rows)
        groups[0]['parts'][0]['gitBlob']='f'*40
        with self.assertRaisesRegex(ValueError,'disagree'):
            RESTORE.select_paths(dict(files=rows,archiveGroups=groups),[],groups[0]['archivePath'])

    def test_exact_git_parts_restore_without_repacking(self):
        with tempfile.TemporaryDirectory(prefix='bend-split-restore-') as td:
            root=Path(td);R.git(root,'init','-q')
            bodies={'implementation/archive.zip.part002':b'second-part','implementation/archive.zip.part001':b'first-part'}
            for name,body in bodies.items():
                p=root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(body)
            R.git(root,'add','.')
            R.git(root,'-c','user.name=History Test','-c','user.email=test@example.invalid','commit','-qm','split archive')
            baseline=R.git(root,'rev-parse','HEAD').decode().strip()
            rows=[dict(path=name,**pin,bytes=len(bodies[name]))for name,pin in R.tree(root,baseline).items()]
            manifest=root/'index.json.gz';write_json(manifest,dict(schema='bend-history-inventory-v1',baselineCommit=baseline,files=rows,archiveGroups=INVENTORY.archive_groups(rows)))
            out=root/'restored'
            argv=['restore.py','--manifest',str(manifest),'--archive-group','implementation/archive.zip','--out',str(out),'--max-mib','1']
            with mock.patch.object(RESTORE,'ROOT',root),mock.patch.object(sys,'argv',argv),contextlib.redirect_stdout(io.StringIO()):
                RESTORE.main()
            receipt=read_json(out/'restore.json')
            self.assertTrue(receipt['complete']);self.assertFalse(receipt['targetsRun'])
            self.assertEqual([row['path']for row in receipt['files']],sorted(bodies))
            for name,body in bodies.items():self.assertEqual((out/name).read_bytes(),body)
            self.assertFalse((out/'implementation/archive.zip').exists())


class PolicyRefresh(unittest.TestCase):
    def test_reclassify_preserves_recovery_and_original_workspace_pins(self):
        policy=dict(baselineCommit='a'*40,keepPaths=[],pendingMigrationPaths=[],
                    pendingMigrationPrefixes=[],retirePrefixes=['selfhost/tools/native/'])
        original=dict(schema='bend-history-inventory-v1',proposalOnly=True,baselineCommit='a'*40,
            dirtyTrackedFiles=[dict(path='historical/removed.py',sha256='preserved')],
            archiveGroups=[dict(archivePath='original-group')],files=[
                dict(path='selfhost/tools/native/selection.json',gitBlob='b'*40,gitMode='100644',
                     bytes=20,action='blocked',reason='pending',workspaceProtected=True),
                dict(path='historical/removed.py',gitBlob='c'*40,gitMode='100644',bytes=30,
                     action='retire',reason='historical')])
        result=INVENTORY.refresh_policy(original,policy)
        self.assertEqual(len(result['files']),2)
        self.assertEqual(result['files'][0]['action'],'retire')
        self.assertEqual(result['files'][0]['application'],'index-only-preserve-working-bytes')
        for before,after in zip(original['files'],result['files']):
            for key in ['path','gitBlob','gitMode','bytes']:
                self.assertEqual(before[key],after[key])
        self.assertEqual(result['dirtyTrackedFiles'],original['dirtyTrackedFiles'])
        self.assertEqual(result['archiveGroups'],original['archiveGroups'])
        self.assertEqual(original['files'][0]['action'],'blocked')
        policy['baselineCommit']='d'*40
        with self.assertRaisesRegex(ValueError,'recovery baseline'):
            INVENTORY.refresh_policy(original,policy)

    def test_pending_migration_wins_over_explicit_retirement(self):
        policy=dict(keepPaths=[],pendingMigrationPaths=[],pendingMigrationPrefixes=['selfhost/tools/native/'],
                    retirePrefixes=['selfhost/tools/native/'])
        self.assertEqual(INVENTORY.classify('selfhost/tools/native/selection.json',policy)[0],'blocked')

    def test_exact_retirement_selection_is_migration_gated(self):
        path='selfhost/tests/conformance/development.test.mjs'
        policy=dict(keepPaths=[],pendingMigrationPaths=[path],pendingMigrationPrefixes=[],retirePaths=[path])
        self.assertEqual(INVENTORY.classify(path,policy)[0],'blocked')
        policy['pendingMigrationPaths']=[]
        self.assertEqual(INVENTORY.classify(path,policy)[0],'retire')
        self.assertEqual(INVENTORY.classify('selfhost/tests/conformance/independent.mjs',policy)[0],'keep')


if __name__ == '__main__':
    unittest.main()
