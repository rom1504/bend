"""Root-run controls for catalog-relative checked source confinement."""
import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(HERE))
import prepare
from support import identity


class CatalogPreparationControls(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='bend-catalog-')
        self.root = Path(self.temp.name)
        self.catalog = self.root / 'catalog.json'
        self.catalog.write_text('{}\n')
        self.source = self.root / 'fixtures' / 'new.bend'
        self.source.parent.mkdir()
        self.source.write_text('def bench() -> U32: 37\n')
        entry = identity(self.source)
        entry['path'] = 'fixtures/new.bend'
        self.case = {'source': entry}

    def tearDown(self):
        self.temp.cleanup()

    def test_explicit_catalog_source_root(self):
        self.assertEqual(prepare.checked_source(self.case, self.catalog), self.source)

    def test_source_hash_change_is_refused(self):
        self.source.write_text('def bench() -> U32: 38\n')
        with self.assertRaisesRegex(ValueError, 'Changed catalog source'):
            prepare.checked_source(self.case, self.catalog)

    def test_parent_traversal_and_absolute_paths_are_refused(self):
        for path in ('../outside.bend', str(self.source)):
            case = {'source': {**self.case['source'], 'path': path}}
            with self.assertRaisesRegex(ValueError, 'Invalid catalog source path'):
                prepare.checked_source(case, self.catalog)

    def test_file_symlink_is_refused_even_inside_root(self):
        alias = self.source.with_name('alias.bend')
        alias.symlink_to(self.source.name)
        case = {'source': {**self.case['source'], 'path': 'fixtures/alias.bend'}}
        with self.assertRaisesRegex(ValueError, 'without symlinks'):
            prepare.checked_source(case, self.catalog)

    def test_directory_symlink_is_refused_even_inside_root(self):
        alias = self.root / 'linked'
        alias.symlink_to(self.source.parent, target_is_directory=True)
        case = {'source': {**self.case['source'], 'path': 'linked/new.bend'}}
        with self.assertRaisesRegex(ValueError, 'without symlinks'):
            prepare.checked_source(case, self.catalog)


if __name__ == '__main__':
    unittest.main()
