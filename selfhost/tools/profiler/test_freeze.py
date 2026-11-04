import json
import tempfile
import unittest
from pathlib import Path
from freeze import freeze


class FreezeContracts(unittest.TestCase):
    def test_independent_oracles_and_inputs_are_pinned(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, data in [('program', b'ELF placeholder'), ('input', b'data'),
                               ('expected', b'42\n'), ('empty', b''), ('recipe', b'{}')]:
                (root/name).write_bytes(data)
            recipe = dict(cwd=directory, workloads=[dict(name='a', variants=[dict(
                name='original', command=['program', 'input'], inputs=['input'],
                stdout='expected', stderr='empty')])])
            result = freeze(recipe, root/'recipe')
            v = result['workloads'][0]['variants'][0]
            self.assertEqual(v['command'], [str(root/'program'), 'input'])
            self.assertEqual(v['expected']['stdout']['bytes'], 3)
            self.assertEqual(v['inputs'][0]['file'], str(root/'input'))
            self.assertFalse(v['dispatchInstrumentation'])
            self.assertNotIn('argv0', v)

    def test_argv0_override_keeps_executable_pin(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ['program', 'expected', 'empty', 'recipe']:
                (root/name).write_bytes(b'')
            variant = dict(name='original', command=['program', 'argument'],
                           argv0='compiler-work', stdout='expected', stderr='empty')
            recipe = dict(cwd=directory, workloads=[dict(name='a', variants=[variant])])
            result = freeze(recipe, root/'recipe')['workloads'][0]['variants'][0]
            self.assertEqual(result['argv0'], 'compiler-work')
            self.assertEqual(result['command'], [str(root/'program'), 'argument'])
            self.assertEqual(result['binary']['file'], str(root/'program'))
            for invalid in ['', 'bad\0argument', None, 17, ['compiler-work']]:
                with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                    freeze(dict(cwd=directory, workloads=[dict(name='a', variants=[
                        variant | dict(argv0=invalid)])]), root/'recipe')

    def test_empty_workloads_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            p = Path(directory)/'recipe'; p.write_text('{}')
            with self.assertRaises(ValueError):
                freeze(dict(cwd=directory, workloads=[]), p)


if __name__ == '__main__':
    unittest.main()
