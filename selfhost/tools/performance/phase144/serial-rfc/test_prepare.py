import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location('prepare', Path(__file__).with_name('prepare-v01.py'))
M = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(M)


class SourceBoundaryTests(unittest.TestCase):
    def setUp(self):
        self.source = (M.PARENT / 'runtime.c').read_text()

    def test_pinned_parent(self):
        for name, digest in M.PIN.items():
            self.assertEqual(M.identity(M.PARENT / name)['sha256'], digest)

    def test_only_reviewed_source_changes(self):
        source = M.transform(self.source)
        source = source.replace(M.HELPERS, '', 1)
        source = source.replace('u32 c = p144_rfc_add(a32_at(e.mem, r), k);',
                                'u32 c = a32_add(a32_at(e.mem, r), k);', 1)
        source = source.replace('if ((p144_rfc_sub(p, 1) & RFC_CNT) != 1) {',
                                'if ((a32_sub_rel(p, 1) & RFC_CNT) != 1) {', 1)
        source = source.replace('''OUTLINE void pool_open(void) {
#if P144_SINGLE_MUTATOR_RFC
  err_fail("phase144 serial RFC runtime refuses compute workers");
#endif''', 'OUTLINE void pool_open(void) {', 1)
        self.assertEqual(source, self.source)

    def test_atomic_macros_unchanged(self):
        source = M.transform(self.source)
        macros = lambda s: [x for x in s.splitlines() if x.startswith('#define a32_')]
        self.assertEqual(macros(source), macros(self.source))

    def test_missing_or_duplicate_anchor_refused(self):
        anchor = 'u32 c = a32_add(a32_at(e.mem, r), k);'
        for source in (self.source.replace(anchor, ''), self.source + anchor):
            with self.assertRaises(ValueError):
                M.transform(source)


if __name__ == '__main__':
    unittest.main()
