"""Tiny synthetic receipt/filesystem controls; never run a compiler or real cleanup."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

SPEC = importlib.util.spec_from_file_location('phase186_chain_dedup', Path(__file__).with_name('deduplicate-chain.py'))
M = importlib.util.module_from_spec(SPEC); SPEC.loader.exec_module(M)


class ChainDedupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='phase186-chain-dedup-')
        self.root = Path(self.temporary.name)
        self.patches = [mock.patch.object(module, 'ROOT', self.root) for module in (M, M.D, M.A)]
        lock = self.root/'selfhost/build/phase32/execution.lock'
        lock.parent.mkdir(parents=True); lock.touch()
        self.patches += [mock.patch.object(M.A, 'LOCK', lock),
                         mock.patch.object(M.D.shutil, 'disk_usage', return_value=mock.Mock(free=8*1024**3))]
        for patch in self.patches: patch.start()
        self.addCleanup(self.temporary.cleanup)
        for patch in self.patches: self.addCleanup(patch.stop)

    def write(self, path, data):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data, indent=2)+'\n')

    def fixture(self, target='qbe'):
        chain = self.root/'selfhost/build/phase186'/('test-'+target+'-chain')
        leaf, final, fixed = ('program.ssa', 'Q3', 'qbeFixedPoint') if target == 'qbe' else ('program.s', 'S3', 'assemblyFixedPoint')
        source = self.root/'source.bend'; source.write_text('source retained\n')
        seed = self.root/'seed'; seed.write_bytes(b'ELF seed retained\n')
        installed = self.root/'selfhost/dist/qbe/bend'
        installed.parent.mkdir(parents=True, exist_ok=True); installed.write_bytes(b'installed image retained\n')
        self.write(self.root/'selfhost/manifests/current.json', dict(
            components={k:{} for k in ('qbe', 'js', 'nativeCli', 'x86')}, gateStatus=dict(qualified=True),
            files=dict(image=dict(M.A.pin(installed), file=str(installed.relative_to(self.root))))))
        generations = []
        for stage in ('N1', 'N2', final):
            directory = chain/stage.lower(); directory.mkdir(parents=True)
            product = directory/leaf; product.write_bytes(b'generated complete text\n'*2048)
            details = dict(version=1, complete=True, changedInputs=[], target=target, host='native', inputs=[M.A.pin(source)])
            if stage in ('N1', 'N2'):
                binary = directory/'program'; binary.write_bytes(('ELF '+stage+' remains separate\n').encode())
                (directory/'program.o').write_bytes(('object '+stage+' remains separate\n').encode())
                details.update(kind='bend-native-build', retainIR=True, binary=M.A.pin(binary))
                details['retainedIR' if target == 'qbe' else 'assembly'] = M.A.pin(product)
            else:
                details.update(kind='bend-build-request', byteExact=True, product=M.A.pin(product))
            self.write(directory/'report.json', details)
            generations.append(dict(stage=stage, complete=True, report=M.A.pin(directory/'report.json')))
        receipt = dict(kind='bend-native-bootstrap-chain', version=1, complete=True, changedInputs=[],
                       producerHost='native', target=target, source=M.A.pin(source), producer=M.A.pin(seed),
                       inputs=[M.A.pin(source), M.A.pin(seed)], generations=generations, machineIdentity={leaf:True})
        receipt[fixed] = True
        self.write(chain/'report.json', receipt)
        return chain, leaf, final

    def revise_chain(self, chain, **updates):
        path = chain/'report.json'; data = json.loads(path.read_text()); data.update(updates); self.write(path, data)

    def revise_generation(self, chain, stage, **updates):
        path = chain/stage.lower()/'report.json'; data = json.loads(path.read_text()); data.update(updates); self.write(path, data)
        receipt = json.loads((chain/'report.json').read_text())
        for generation in receipt['generations']:
            if generation['stage'] == stage: generation['report'] = M.A.pin(path)
        self.write(chain/'report.json', receipt)

    def test_two_routes_default_is_read_only(self):
        for target in ('qbe', 'x86'):
            with self.subTest(target=target):
                chain, leaf, final = self.fixture(target)
                before = {str(p):M.A.metadata(p) for p in chain.glob('*/'+leaf)}
                with M.A.exclusive(): plan, inputs = M.preflight(chain)
                self.assertEqual(2, len(plan['pairs']))
                self.assertEqual(target, plan['target'])
                self.assertEqual(before, {str(p):M.A.metadata(p) for p in chain.glob('*/'+leaf)})
                self.assertFalse((self.root/'selfhost/build-retention').exists())

    def test_both_routes_apply_only_text_and_journal_metadata(self):
        for target in ('qbe', 'x86'):
            with self.subTest(target=target):
                chain, leaf, final = self.fixture(target)
                protected = [self.root/'seed', self.root/'source.bend', self.root/'selfhost/dist/qbe/bend',
                             chain/'n1/program', chain/'n2/program', chain/'n1/program.o', chain/'n2/program.o', chain/'report.json',
                             *chain.glob('*/report.json')]
                before = {str(p):(M.A.pin(p), p.stat().st_ino) for p in protected}
                out = self.root/'selfhost/build-retention/phase186'/target
                with M.A.exclusive():
                    plan, inputs = M.preflight(chain)
                    result = M.D.apply(out, plan, inputs)
                self.assertTrue(result['complete'])
                self.assertEqual(2, result['completedPairs'])
                self.assertEqual(plan['allocatedRecipientBytes'], result['expectedReleasedBytes'])
                canonical = chain/'n2'/leaf
                self.assertEqual(3, canonical.stat().st_nlink)
                self.assertEqual(canonical.stat().st_ino, (chain/'n1'/leaf).stat().st_ino)
                self.assertEqual(canonical.stat().st_ino, (chain/final.lower()/leaf).stat().st_ino)
                self.assertEqual(before, {str(p):(M.A.pin(p), p.stat().st_ino) for p in protected})
                rows = [json.loads(line) for line in (out/'journal.jsonl').read_text().splitlines()]
                self.assertEqual(['intent', 'complete', 'intent', 'complete'], [r['event'] for r in rows])
                self.assertEqual([1, 2], [r['canonicalBefore']['links'] for r in rows if r['event']=='intent'])
                self.assertEqual([2, 3], [r['canonicalAfter']['links'] for r in rows if r['event']=='complete'])
                with self.assertRaisesRegex(ValueError, 'Shared inode'): M.preflight(chain)

    def test_incomplete_changed_or_nonfixed_chain_refused(self):
        chain, leaf, final = self.fixture()
        original = json.loads((chain/'report.json').read_text())
        for updates in [dict(complete=False), dict(changedInputs=['changed']), dict(qbeFixedPoint=False),
                        dict(machineIdentity={leaf:False})]:
            with self.subTest(updates=updates):
                self.write(chain/'report.json', dict(original, **updates))
                with self.assertRaises(ValueError): M.preflight(chain)

    def test_stale_generation_receipt_refused(self):
        chain, leaf, final = self.fixture()
        path = chain/'n1/report.json'; path.write_text(path.read_text()+' ')
        with self.assertRaisesRegex(ValueError, 'Changed pinned input'): M.preflight(chain)

    def test_changed_generation_and_outside_product_refused(self):
        chain, leaf, final = self.fixture()
        self.revise_generation(chain, 'N1', changedInputs=['changed'])
        with self.assertRaisesRegex(ValueError, 'Generation receipt'): M.preflight(chain)
        self.revise_generation(chain, 'N1', changedInputs=[], retainedIR=M.A.pin(self.root/'source.bend'))
        with self.assertRaisesRegex(ValueError, 'Product outside'): M.preflight(chain)

    def test_equal_size_different_text_refused(self):
        chain, leaf, final = self.fixture()
        product = chain/'n1'/leaf; data = product.read_bytes(); product.write_bytes(b'X'+data[1:])
        self.revise_generation(chain, 'N1', retainedIR=M.A.pin(product))
        with self.assertRaisesRegex(ValueError, 'Generated products differ'): M.preflight(chain)

    def test_changed_receipt_after_preflight_prevents_first_replacement(self):
        chain, leaf, final = self.fixture()
        with M.A.exclusive():
            plan, inputs = M.preflight(chain)
            before = {str(p):p.stat().st_ino for p in chain.glob('*/'+leaf)}
            path = chain/'report.json'; path.write_text(path.read_text()+' ')
            result = M.D.apply(self.root/'selfhost/build-retention/phase186/stale', plan, inputs)
        self.assertFalse(result['complete']); self.assertEqual(0, result['completedPairs'])
        self.assertEqual(before, {str(p):p.stat().st_ino for p in chain.glob('*/'+leaf)})

    def test_outside_phase_and_symlink_refused(self):
        chain, leaf, final = self.fixture()
        with self.assertRaisesRegex(ValueError, 'Phase186'): M.preflight(chain.parent)
        alias = chain.parent/'alias'; alias.symlink_to(chain, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, 'Phase186'): M.preflight(alias)

    def test_phase185_chain_and_retention_paths_are_refused(self):
        chain, leaf, final = self.fixture()
        previous = self.root/'selfhost/build/phase185/previous-chain'
        previous.mkdir(parents=True)
        with self.assertRaisesRegex(ValueError, 'Phase186'): M.preflight(previous)
        out = self.root/'selfhost/build-retention/phase185/wrong-phase'
        with mock.patch('sys.argv', ['deduplicate-chain.py', '--chain', str(chain), '--apply', '--out', str(out)]):
            with self.assertRaisesRegex(ValueError, 'Phase186 retention'): M.main()
        self.assertFalse(out.exists())


if __name__ == '__main__':
    unittest.main()
