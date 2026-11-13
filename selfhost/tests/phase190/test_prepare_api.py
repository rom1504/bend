"""Literal source transport controls; no compiler or generated target execution."""
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('phase190_prepare', Path(__file__).with_name('prepare-api.py'))
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


class SourceConstants(unittest.TestCase):
    source = b'def policy() -> U32: 0\n\ndef enabled() -> Bool: False{}\n'

    def test_records_literal_u32_and_bool_overrides(self):
        result, changes = P.override_constants(self.source, ['policy=2', 'enabled=true'], {})
        self.assertEqual(result, b'def policy() -> U32: 2\n\ndef enabled() -> Bool: True{}\n')
        self.assertEqual([(x['name'], x['before'], x['after']) for x in changes],
                         [('policy', '0', '2'), ('enabled', 'False{}', 'True{}')])

    def test_rejects_expression_type_range_and_missing_constant(self):
        for value in ['policy=1+1', 'policy=-1', 'policy=4294967296', 'enabled=1', 'absent=0']:
            with self.subTest(value=value), self.assertRaises(ValueError):
                P.override_constants(self.source, [value], {})

    def test_rejects_protected_and_duplicate_constants(self):
        with self.assertRaises(ValueError):
            P.override_constants(self.source, ['policy=1'], {'policy': {}})
        with self.assertRaises(ValueError):
            P.override_constants(self.source, ['policy=1', 'policy=2'], {})

    def test_no_override_preserves_every_source_byte(self):
        self.assertEqual(P.override_constants(self.source, [], {}), (self.source, []))


if __name__ == '__main__':
    unittest.main()
