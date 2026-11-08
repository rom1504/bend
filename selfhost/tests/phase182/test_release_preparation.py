"""Metadata rejection controls; no compiler or runtime is invoked."""
import copy
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('prepare_release', Path(__file__).with_name('prepare-release.py'))
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)


class ReceiptControls(unittest.TestCase):
    def setUp(self):
        self.image = {'bytes': 10, 'sha256': '1'*64}
        self.report = dict(kind='bend-finite-qualification', complete=True, passed=True,
            upstream=prepare.UPSTREAM, host='js', stage='B2', target='c', image=self.image,
            selected=['a','b'], rows=[{'id':'a','status':'pass'},{'id':'b','status':'pass'}],
            counts={'pass':2,'fail':0,'unsupported':0})

    def qualify(self, report, count=2):
        prepare.completed(report,'fixture')
        prepare.qualification(report,'js','B2','c',self.image,count)

    def test_explicit_focused_count_is_admitted(self):
        self.qualify(self.report)
        with self.assertRaises(ValueError): self.qualify(self.report,19)

    def test_status_and_current_generation_cannot_be_overridden(self):
        for field, value in [('complete',False),('passed',False),('stage','B1'),
                             ('upstream','059266225b77c8ca256ac6b25ee5c21449bab151'),
                             ('changedInputs',['changed']),('error','failed')]:
            with self.subTest(field=field):
                report = copy.deepcopy(self.report); report[field] = value
                with self.assertRaises(ValueError): self.qualify(report)

    def test_count_requires_actual_distinct_passing_rows(self):
        for field, value in [('rows',[{'id':'a','status':'pass'},{'id':'b','status':'fail'}]),
                             ('selected',['a','a']),('rows',[{'id':'a','status':'pass'}])]:
            with self.subTest(field=field,value=value):
                report = copy.deepcopy(self.report); report[field] = value
                with self.assertRaises(ValueError): self.qualify(report)

    def test_native_lineage_binds_actual_source_and_rts_runtime(self):
        source = {'bytes':20,'sha256':'2'*64}; runtime = {'bytes':30,'sha256':'3'*64}
        report = dict(kind='bend-native-build',binary=self.image,
            request={'source':source,'target':'qbe'},
            imageBinding=dict(complete=True,host='native',stage='N2',protocol='qbe-source-v1',targets=['qbe'],
                image=self.image,sourceIdentity=source,linkedRuntime=runtime,runtimeArgumentConvention='bend-rts-v1'))
        prepare.native_generation(report,'N2',source,runtime)
        for field,value in [('stage','N1'),('sourceIdentity',runtime),('linkedRuntime',source),
                            ('runtimeArgumentConvention','bend-legacy-v1')]:
            with self.subTest(field=field):
                candidate = copy.deepcopy(report); candidate['imageBinding'][field] = value
                with self.assertRaises(ValueError): prepare.native_generation(candidate,'N2',source,runtime)


if __name__ == '__main__':
    unittest.main()
