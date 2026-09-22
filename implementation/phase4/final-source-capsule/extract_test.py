"""Small failure-boundary tests; no compiler execution or bootstrap."""
import gzip
import hashlib
import importlib.util
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('capsule_extract', HERE / 'extract.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class CapsuleTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / 'final-source-capsule'
        shutil.copytree(HERE, self.root, ignore=shutil.ignore_patterns('__pycache__'))
        evidence = self.base / 'final-source-evidence'
        evidence.mkdir()
        for name in ['fixedpoint.json', 'checked-build.json.gz']:
            shutil.copyfile(HERE.parent / 'final-source-evidence' / name, evidence / name)

    def test_valid_restore(self):
        _, _, restored = module.verify(self.root)
        output = self.base / 'restored'
        process = subprocess.run([sys.executable, str(self.root / 'extract.py'), str(output)], capture_output=True, text=True)
        self.assertEqual(process.returncode, 0, process.stderr)
        for name, data in restored.items():
            self.assertEqual((output / name).read_bytes(), data)
        self.assertIs(json.loads((output / 'extraction-record.json').read_text())['newBootstrap'], False)

    def test_existing_directory_is_not_overwritten(self):
        output = self.base / 'existing'
        output.mkdir()
        (output / 'h.mjs').write_text('preserve me')
        process = subprocess.run([sys.executable, str(self.root / 'extract.py'), str(output)], capture_output=True, text=True)
        self.assertNotEqual(process.returncode, 0)
        self.assertEqual((output / 'h.mjs').read_text(), 'preserve me')
        self.assertEqual(len(list(output.iterdir())), 1)

    def test_corrupt_archive(self):
        target = self.root / 'h.mjs.gz'
        data = bytearray(target.read_bytes())
        data[len(data) // 2] ^= 1
        target.write_bytes(data)
        with self.assertRaisesRegex(ValueError, 'Archive hash mismatch'):
            module.verify(self.root)

    def test_restored_size_mismatch(self):
        manifest = self.root / 'manifest.json'
        data = json.loads(manifest.read_text())
        data['artifacts'][0]['bytes'] -= 1
        manifest.write_text(json.dumps(data))
        with self.assertRaisesRegex(ValueError, 'Restored identity mismatch'):
            module.verify(self.root)

    def test_incomplete_proof_even_with_matching_hash(self):
        manifest = self.root / 'manifest.json'
        data = json.loads(manifest.read_text())
        proof_path = self.root / data['proof']['archive']
        proof = json.loads(proof_path.read_text())
        proof['complete'] = False
        raw = json.dumps(proof).encode()
        proof_path.write_bytes(raw)
        data['proof'].update(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), archiveSha256=hashlib.sha256(raw).hexdigest())
        manifest.write_text(json.dumps(data))
        with self.assertRaisesRegex(ValueError, 'Incomplete historical proof'):
            module.verify(self.root)


if __name__ == '__main__':
    unittest.main(verbosity=2)
