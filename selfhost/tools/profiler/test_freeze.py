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

    def test_empty_workloads_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            p = Path(directory)/'recipe'; p.write_text('{}')
            with self.assertRaises(ValueError):
                freeze(dict(cwd=directory, workloads=[]), p)


if __name__ == '__main__':
    unittest.main()
