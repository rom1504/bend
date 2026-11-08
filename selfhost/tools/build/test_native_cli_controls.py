"""Offline runtime binding controls for native public CLI qualification."""
import copy
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('native_cli_controls',
    ROOT / 'selfhost/tests/consolidation/native-cli/controls.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class IndependentRuntimeBinding(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'selfhost').mkdir()
        file = self.root / 'runtime.c'; file.write_text('runtime fixture')
        self.runtime = C.pin(file)
        file = self.root / 'image'; file.write_text('image fixture')
        image = C.pin(file)
        self.authority = dict(image=image,runtime=self.runtime,imageBinding=dict(
            kind='bend-build-image-binding',complete=True,protocol='native-public-cli-v1',
            image=image,linkedRuntime=self.runtime,targetRuntime=self.runtime,
            runtimeArgumentConvention='bend-rts-v1',targetRuntimeArgumentConvention='bend-rts-v1'))
        doc = dict(kind='bend-build-assets',version=1,complete=True,upstream='9'*40,
            assets={'runtime':dict(self.runtime,runtimeArgumentConvention='bend-rts-v1')},
            providers={'c':{'runtime':'runtime'}})
        self.manifest = self.root / 'assets.json'; self.manifest.write_text(json.dumps(doc))

    def select(self, authority=None):
        with patch.object(C, 'ROOT', self.root):
            return C.independent_runtime(self.manifest, authority or self.authority)

    def test_current_runtime_cli_comes_from_authenticated_provider(self):
        with patch.dict(os.environ, {}, clear=True):
            got = self.select()
        self.assertEqual(got['arguments'], ['+RTS','--threads','1','--gpu','off','-RTS','--RTS'])
        self.assertEqual(got['upstream'], '9'*40)
        self.assertIn(self.runtime, got['inputs'])

    def test_runtime_bytes_and_argument_protocol_must_both_match(self):
        for field, value in [('targetRuntime',dict(self.runtime,sha256='0'*64)),
                             ('targetRuntimeArgumentConvention','bend-legacy-v1')]:
            authority = copy.deepcopy(self.authority)
            authority['imageBinding'][field] = value
            with self.assertRaisesRegex(ValueError, 'argument binding differs'):
                self.select(authority)

    def test_ambient_rts_cannot_change_the_execution_policy(self):
        with patch.dict(os.environ, {'BENDRTS':'--threads 9'}):
            with self.assertRaisesRegex(ValueError, 'ambient BENDRTS'):
                self.select()


if __name__ == '__main__':
    unittest.main()
