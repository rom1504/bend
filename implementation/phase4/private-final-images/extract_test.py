import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('private_capsule_extract', HERE / 'extract.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class RestoreTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / 'private-final-images'
        shutil.copytree(HERE, self.root, ignore=shutil.ignore_patterns('__pycache__'))
        shared = self.base / 'final-source-capsule'
        shared.mkdir()
        for name in ['b1.mjs.gz', 'h.mjs.gz', 'compiler.bend.gz', 'runtime.mjs.gz']:
            shutil.copyfile(HERE.parent / 'final-source-capsule' / name, shared / name)

    def run_extract(self, output):
        return subprocess.run([sys.executable, str(self.root / 'extract.py'), str(output)], capture_output=True, text=True)

    def test_exact_restore(self):
        _, _, images = module.verify(self.root)
        output = self.base / 'restored'
        result = self.run_extract(output)
        self.assertEqual(result.returncode, 0, result.stderr)
        for image, files in images.items():
            for name, data in files.items():
                self.assertEqual((output / image / name).read_bytes(), data)
        record = json.loads((output / 'extraction-record.json').read_text())
        self.assertIs(record['newBootstrap'], False)
        self.assertIs(record['newPrivateBuild'], False)

    def test_existing_output_preserved(self):
        output = self.base / 'exists'
        output.mkdir()
        (output / 'keep').write_text('old')
        result = self.run_extract(output)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((output / 'keep').read_text(), 'old')
        self.assertEqual(len(list(output.iterdir())), 1)

    def test_corrupt_local_object(self):
        file = next((self.root / 'objects').iterdir())
        file.write_bytes(file.read_bytes() + b'corrupt')
        with self.assertRaisesRegex(ValueError, 'Compressed object drift'):
            module.verify(self.root)

    def test_corrupt_shared_object(self):
        file = self.base / 'final-source-capsule/h.mjs.gz'
        file.write_bytes(file.read_bytes() + b'corrupt')
        with self.assertRaisesRegex(ValueError, 'Compressed object drift'):
            module.verify(self.root)

    def test_unsafe_output_path(self):
        file = self.root / 'manifest.json'
        manifest = json.loads(file.read_text())
        files = manifest['images']['scope-fixed']['files']
        files['../escape'] = files['image.mjs']
        file.write_text(json.dumps(manifest))
        with self.assertRaisesRegex(ValueError, 'Unsafe artifact path'):
            module.verify(self.root)


if __name__ == '__main__':
    unittest.main(verbosity=2)
