"""Metadata controls only; no compiler image or target process is executed."""
import copy
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
def module(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    value = importlib.util.module_from_spec(spec); spec.loader.exec_module(value)
    return value
S = module('stage_js_cli', Path(__file__).with_name('stage-js-cli.py'))
P = module('staged_public_cli', ROOT/'selfhost/tools/conformance/public-cli.py')


class StagedAuthority(unittest.TestCase):
    def setUp(self):
        self.image = dict(bytes=17, sha256='1'*64)
        names = ['focused/test'+str(i) for i in range(18)]
        self.report = dict(kind='bend-finite-qualification', complete=True, passed=True,
            upstream=S.UPSTREAM, host='js', stage='B2', target='js', image=self.image,
            selected=names, rows=[dict(id=name, status='pass') for name in names],
            counts=dict(pass_=18, fail=0, unsupported=0))
        self.report['counts'] = {'pass':18, 'fail':0, 'unsupported':0}

    def test_exact_current_b2_target_and_eighteen_rows_required(self):
        S.qualified(self.report, self.image, 'js')
        for field, value in [('stage','B1'), ('target','c'), ('upstream','0'*40),
                             ('passed',False), ('complete',False), ('changedInputs',['changed']),
                             ('image',dict(bytes=17,sha256='2'*64))]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                S.qualified(dict(self.report, **{field:value}), self.image, 'js')

    def test_duplicate_rows_or_unsupported_cannot_count_as_qualified(self):
        for field, value in [('rows',self.report['rows'][:-1]),
                             ('selected',[self.report['selected'][0]]*18),
                             ('counts',{'pass':17,'fail':0,'unsupported':1})]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                S.qualified(dict(self.report, **{field:value}), self.image, 'js')
        report = copy.deepcopy(self.report); report['rows'][0]['status'] = 'fail'
        with self.assertRaises(ValueError): S.qualified(report, self.image, 'js')

    def test_cli_workspace_must_be_inside_build_and_have_stage_authority(self):
        with tempfile.TemporaryDirectory(prefix='p182-staged-cli-metadata-') as directory:
            root = Path(directory)
            outside = root/'elsewhere'; outside.mkdir()
            with self.assertRaisesRegex(ValueError, 'confined'):
                P.staged_cli(outside, root, {})
            tree = root/'selfhost/build/test/workspace'; tree.mkdir(parents=True)
            S.write_json(tree.parent/'report.json', dict(kind='bend-current-bindings', complete=True))
            with self.assertRaisesRegex(ValueError, 'candidate image/Base'):
                P.staged_cli(tree, root, {})


if __name__ == '__main__': unittest.main()
