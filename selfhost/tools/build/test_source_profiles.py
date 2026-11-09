"""Metadata-only profile assembly controls; no Bend or target execution."""
import json
from pathlib import Path
import tempfile
import unittest

import source


class SourceProfiles(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.preamble = b'import Base\n\n'
        self.core = (
            b'# Retained type bytes.\ntype Choice is Data:\n  KeptCtor{}\n\n'
            b'def original() -> U32:\n  7\n\n'
            b'def unused() -> U32:\n  99\n\n'
            b'def main() -> U32:\n  original()\n')
        self.model = b'law helper:\n  Choice\n\n'
        self.extra = (
            b'# Retained helper bytes.\ndef helper() -> Choice:\n'
            b'  let quote = \'"\'\n  let hash = \'#\'\n'
            b'  let text = "unused"\n  # unused\n  KeptCtor{}\n')
        self.entry = b'def main() -> Choice:\n  helper()\n'
        for name, data in [('preamble.bend', self.preamble), ('core.bend', self.core),
                           ('model.bend', self.model), ('extra.bend', self.extra),
                           ('entry.bend', self.entry)]:
            (self.root / name).write_bytes(data)
        _, items = source.blocks(self.core)
        self.recipe = dict(kind='bend-maintained-source-v1', preamble='preamble.bend',
            modules=['core.bend'], order=[[0, row['kind'], row['name']] for row in items],
            defaultProfile='canonical', profiles={
                'canonical': dict(entryModule=None, omitMain=False),
                'api': dict(entryModule=None, omitMain=True),
                'adapter': dict(entryModule='entry.bend', omitMain=False),
                'machine': dict(entryModule='entry.bend', omitMain=False,
                    modules=['model.bend', 'extra.bend'], roots=['main'])})
        self.manifest = self.root / 'compiler.json'

    def assemble(self, profile, with_map=False):
        self.manifest.write_text(json.dumps(self.recipe))
        return source.maintained_assemble(self.manifest, self.root, profile, with_map)

    def test_existing_profiles_keep_exact_bytes(self):
        _, rows = source.blocks(self.core)
        no_main = b''.join(row['data'] for row in rows if row['name'] != 'main')
        self.assertEqual(self.assemble('canonical'), self.preamble + self.core)
        self.assertEqual(self.assemble('api'), self.preamble + no_main)
        self.assertEqual(self.assemble('adapter'), self.preamble + no_main + self.entry)

    def test_constructor_closure_and_forward_law_preserve_bytes(self):
        data, mapping = self.assemble('machine', True)
        _, core_rows = source.blocks(self.core)
        expected = self.preamble + core_rows[0]['data'] + self.model + self.extra + self.entry
        self.assertEqual(data, expected)
        self.assertEqual([(row['kind'], row['name']) for row in mapping],
                         [('type', 'Choice'), ('law', 'helper'), ('def', 'helper'), ('def', 'main')])
        self.assertEqual(mapping[-1]['file'], 'entry.bend')
        for row in mapping:
            original = (self.root / row['file']).read_bytes()
            start, offset, size = row['generatedStartByte'], row['sourceStartByte'], row['spanBytes']
            self.assertEqual(data[start:start+size], original[offset:offset+size])
            self.assertEqual(row['generatedLine'], data[:row['generatedByte']].count(b'\n') + 1)

    def test_duplicate_and_shadowed_declarations_are_refused(self):
        for extra in [b'def original() -> U32:\n  8\n', b'law original:\n  U32\n',
                      self.extra + b'\ndef helper() -> Choice:\n  KeptCtor{}\n',
                      b'def main() -> U32:\n  8\n']:
            with self.subTest(extra=extra):
                (self.root / 'extra.bend').write_bytes(extra)
                with self.assertRaisesRegex(ValueError, 'Duplicate or shadowed'):
                    self.assemble('machine')

    def test_profile_paths_and_roots_are_explicit(self):
        profile = self.recipe['profiles']['machine']
        for roots in [[], ['main', 'main'], ['missing'], 'main', [3]]:
            with self.subTest(roots=roots):
                profile['roots'] = roots
                with self.assertRaisesRegex(ValueError, '[Rr]oot'):
                    self.assemble('machine')
        profile['roots'] = ['main']
        for modules in [['../outside.bend'], ['extra.bend', 'extra.bend'], ['core.bend'], ['entry.bend']]:
            with self.subTest(modules=modules):
                profile['modules'] = modules
                with self.assertRaises(ValueError):
                    self.assemble('machine')

    def test_ambiguous_constructor_owner_is_refused(self):
        (self.root / 'extra.bend').write_bytes(
            b'type Another is Data:\n  KeptCtor{}\n\n' + self.extra)
        with self.assertRaisesRegex(ValueError, 'Ambiguous constructor'):
            self.assemble('machine')

    def test_canonical_inventory_and_protection_still_apply(self):
        self.recipe['protectedDeclarations'] = dict(original={'normalizedSha256': '0'*64})
        with self.assertRaisesRegex(ValueError, 'Protected'):
            self.assemble('machine')
        del self.recipe['protectedDeclarations']
        (self.root / 'core.bend').write_bytes(self.core + b'\ndef new() -> U32:\n  1\n')
        with self.assertRaisesRegex(ValueError, 'inventory changed'):
            self.assemble('machine')


if __name__ == '__main__':
    unittest.main()
