"""Temporary-file transaction controls; never publish real maps or run targets."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase183_publish_assets', HERE/'publish-assets.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


class PublicationTransaction(unittest.TestCase):
    def fixture(self, root):
        out = root/'transaction'; out.mkdir()
        destinations, originals, proposed, rollback = {}, {}, {}, {}
        for index, name in enumerate(P.MAPS):
            destination, candidate, saved = (root/(prefix+name) for prefix in ('', 'proposed-', 'rollback-'))
            destination.write_bytes(b'original '+bytes([index]))
            candidate.write_bytes(b'candidate '+bytes([index]))
            saved.write_bytes(destination.read_bytes())
            destinations[name] = destination
            originals[name], proposed[name], rollback[name] = P.pin(destination), P.pin(candidate), P.pin(saved)
        return out, destinations, originals, proposed, rollback

    def test_exact_publication_retains_original_backups(self):
        with tempfile.TemporaryDirectory() as directory:
            out, destinations, originals, proposed, rollback = self.fixture(Path(directory))
            validations = []
            report = P.transaction(out, destinations, originals, proposed, rollback, [], lambda: validations.append(True))
            self.assertTrue(report['complete']); self.assertFalse(report['rollback'])
            self.assertEqual(len(validations), 2)
            for name in P.MAPS:
                self.assertTrue(P.release.same(P.pin(destinations[name]), proposed[name]))
                self.assertTrue(P.release.same(report['backups'][name], originals[name]))
                P.verify(rollback[name])

    def test_failure_during_second_replacement_restores_all_original_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            out, destinations, originals, proposed, rollback = self.fixture(Path(directory))
            real_replace = P.os.replace
            def replace(source, target):
                if Path(source).name == 'stage-'+P.MAPS[1]:
                    raise OSError('injected second replacement failure')
                return real_replace(source, target)
            with patch.object(P.os, 'replace', side_effect=replace):
                report = P.transaction(out, destinations, originals, proposed, rollback, [], lambda: None)
            self.assertFalse(report['complete']); self.assertTrue(report['rollback'])
            for name in P.MAPS: self.assertEqual(P.pin(destinations[name]), originals[name])

    def test_failed_postpublication_release_check_rolls_back(self):
        with tempfile.TemporaryDirectory() as directory:
            out, destinations, originals, proposed, rollback = self.fixture(Path(directory))
            calls = []
            def validate():
                calls.append(True)
                if len(calls) == 2: raise ValueError('changed installed release')
            report = P.transaction(out, destinations, originals, proposed, rollback, [], validate)
            self.assertFalse(report['complete']); self.assertTrue(report['rollback'])
            for name in P.MAPS: self.assertEqual(P.pin(destinations[name]), originals[name])

    def test_changed_original_refuses_before_any_replacement(self):
        with tempfile.TemporaryDirectory() as directory:
            out, destinations, originals, proposed, rollback = self.fixture(Path(directory))
            destinations[P.MAPS[-1]].write_bytes(b'unrelated edit')
            report = P.transaction(out, destinations, originals, proposed, rollback, [], lambda: None)
            self.assertFalse(report['complete']); self.assertFalse(report['rollback'])
            self.assertEqual(report['mutations'], [])
            self.assertEqual(destinations[P.MAPS[-1]].read_bytes(), b'unrelated edit')
            for name in P.MAPS[:-1]: self.assertEqual(P.pin(destinations[name]), originals[name])

    def test_success_receipt_write_failure_rolls_back_published_maps(self):
        with tempfile.TemporaryDirectory() as directory:
            out, destinations, originals, proposed, rollback = self.fixture(Path(directory))
            real_write = P.write_json
            def write(file, value):
                if value.get('complete') is True: raise OSError('injected final receipt failure')
                return real_write(file, value)
            with patch.object(P, 'write_json', side_effect=write):
                report = P.transaction(out, destinations, originals, proposed, rollback, [], lambda: None)
            self.assertFalse(report['complete']); self.assertTrue(report['rollback'])
            for name in P.MAPS: self.assertEqual(P.pin(destinations[name]), originals[name])

    def test_bad_rollback_copy_refuses_before_any_replacement(self):
        with tempfile.TemporaryDirectory() as directory:
            out, destinations, originals, proposed, rollback = self.fixture(Path(directory))
            Path(rollback[P.MAPS[0]]['file']).write_bytes(b'changed rollback')
            with self.assertRaises(ValueError):
                P.transaction(out, destinations, originals, proposed, rollback, [], lambda: None)
            for name in P.MAPS: self.assertEqual(P.pin(destinations[name]), originals[name])


if __name__ == '__main__': unittest.main()
