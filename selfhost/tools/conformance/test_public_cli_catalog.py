"""Offline public CLI catalog migration controls; no compiler/target execution."""
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('public_cli_controls', Path(__file__).with_name('public-cli.py'))
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
ROOT = Path(__file__).resolve().parents[3]


class PublicCliCatalog(unittest.TestCase):
    def test_default_identity_and_frozen_oracles_survive(self):
        old, old_file = P.load_catalog()
        current, _ = P.load_catalog(ROOT / 'selfhost/tests/phase182/public-cli-catalog.json')
        self.assertEqual(old['upstream'], P.Q.UPSTREAM)
        self.assertEqual(current['upstream'], '9a4223d577ba56a0cb53d1fd952d2b481c38930f')
        self.assertEqual(current['cases'], old['cases'])
        self.assertEqual(len(current['cases']), 7)
        self.assertEqual(current['parentCatalog'], P.pin(old_file))

    def test_unknown_version_pin_and_case_aliases_are_rejected(self):
        old, _ = P.load_catalog()
        with tempfile.TemporaryDirectory() as directory:
            file = Path(directory) / 'catalog.json'
            for field, value in [('version', 2), ('upstream', 'unbound'), ('cases', [])]:
                document = dict(old, **{field: value})
                file.write_text(json.dumps(document))
                with self.assertRaisesRegex(ValueError, 'Unknown public CLI catalog'):
                    P.load_catalog(file)
            for bad in ['../escape', old['cases'][1]['id']]:
                document = json.loads(json.dumps(old))
                document['cases'][0]['id'] = bad
                file.write_text(json.dumps(document))
                with self.assertRaisesRegex(ValueError, 'case identity'):
                    P.load_catalog(file)


if __name__ == '__main__':
    unittest.main()
