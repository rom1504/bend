import contextlib
import importlib.util
import io
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location('build_sampler', Path(__file__).with_name('build-sampler.py'))
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)


class BuildSamplerContracts(unittest.TestCase):
    def test_scope_selects_and_pins_exact_collector_without_running_compiler(self):
        for flags, name, scope in [([], 'sample.c', 'main_thread'),
                                   (['--all-threads'], 'sample-threads.c', 'all_created_threads')]:
            with self.subTest(scope=scope), tempfile.TemporaryDirectory() as directory:
                out = Path(directory)/'build'

                def fake_compile(command, **kwargs):
                    (out/'sampler.so').write_bytes(b'not an executable; mocked compiler product')
                    return SimpleNamespace(returncode=0)

                with patch.object(sys, 'argv', ['build-sampler', '--out', str(out), *flags]), \
                     patch.object(builder.shutil, 'which', return_value=sys.executable), \
                     patch.object(builder.subprocess, 'run', side_effect=fake_compile) as compiler, \
                     contextlib.redirect_stdout(io.StringIO()):
                    builder.main()
                source = Path(builder.__file__).with_name(name).resolve()
                report = builder.json.loads((out/'report.json').read_text())
                self.assertTrue(report['complete'])
                self.assertEqual(report['samplerScope'], scope)
                self.assertIn(builder.pin(source), report['inputs'])
                self.assertEqual((out/name).read_bytes(), source.read_bytes())
                self.assertIn(builder.pin(out/name), report['snapshots'])
                self.assertIn(str(out/name), compiler.call_args.args[0])

    def test_threads_and_unwind_are_rejected_before_output_or_compile(self):
        with tempfile.TemporaryDirectory() as directory:
            out = Path(directory)/'build'
            with patch.object(sys, 'argv', ['build-sampler', '--out', str(out),
                                           '--all-threads', '--unwind-table', 'table.json']), \
                 patch.object(builder.subprocess, 'run') as compiler, \
                 contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error:
                builder.main()
            self.assertEqual(error.exception.code, 2)
            self.assertFalse(out.exists())
            compiler.assert_not_called()


if __name__ == '__main__':
    unittest.main()
