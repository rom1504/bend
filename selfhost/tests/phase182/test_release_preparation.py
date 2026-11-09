"""Metadata rejection controls; no compiler or runtime is invoked."""
import copy
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('prepare_release', Path(__file__).with_name('prepare-release.py'))
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)
spec = importlib.util.spec_from_file_location('prepare_operational', Path(__file__).with_name('prepare-operational-assets.py'))
operational = importlib.util.module_from_spec(spec)
spec.loader.exec_module(operational)


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


class PortableArtifactControls(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='p182-release-metadata-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.files, self.installed, self.inputs = {}, {}, []
        self.providers = {}
        self.document = {'_workspace': self.root, 'assets': {},
                         'preparedBase': {'sourceIdentity': {'path': '/canonical/Base.bend'},
                                          'stamp': 'unchanged-authenticated-stamp'}}
        for key, filename, provider, payload in [
            ('qbe-runtime', 'qbe/runtime.o', 'qbeRuntime', b'qualified-runtime-object'),
            ('prepared-base', 'qbe/base.p130', None, b'qualified-carrier'),
            ('c-runtime-template', 'native/runtime-template.json', 'cRuntimeTemplate', b'{"version":1}')]:
            original = self.root/(key+'.original'); original.write_bytes(payload)
            row = prepare.pin(original)
            self.document['assets'][key] = row
            installed = prepare.installable_artifact('selfhost/dist/'+filename, row,
                self.files, self.installed, self.inputs, self.root)
            if provider: self.providers[provider] = installed
        self.document['assets']['qbe-runtime']['runtimeArgumentConvention'] = 'bend-rts-v1'
        self.proposal = {'files': self.files, 'bindings': {'files': self.installed,
            'providers': self.providers, 'components': {'qbe': {'preparedBase': copy.deepcopy(self.document['preparedBase'])}}}}

    def test_prospective_pins_do_not_read_or_write_installed_paths(self):
        for name, row in self.installed.items():
            self.assertFalse(Path(name).is_absolute())
            self.assertFalse((self.root/name).exists())
            self.assertEqual(row['file'], name)
            self.assertTrue(Path(self.files[name]['file']).is_absolute())
            self.assertTrue(prepare.release.same(row, self.files[name]))
            prepare.verify(self.files[name])
        self.assertEqual(len(self.inputs), 3)

    def test_operational_rows_relocate_pins_preserving_policy_and_base_identity(self):
        before = copy.deepcopy(self.document)
        rows = operational.portable_operational_rows(self.proposal, self.document, self.root)
        self.assertEqual(self.document, before)
        self.assertEqual(rows['qbe-runtime']['file'], 'selfhost/dist/qbe/runtime.o')
        self.assertEqual(rows['prepared-base']['file'], 'selfhost/dist/qbe/base.p130')
        self.assertEqual(rows['c-runtime-template']['file'], 'selfhost/dist/native/runtime-template.json')
        self.assertEqual(rows['qbe-runtime']['runtimeArgumentConvention'], 'bend-rts-v1')
        for key, row in rows.items():
            self.assertTrue(prepare.release.same(row, self.document['assets'][key]))

    def test_changed_original_and_forged_installed_pin_are_refused(self):
        name = 'selfhost/dist/qbe/runtime.o'
        forged = copy.deepcopy(self.proposal)
        forged['bindings']['files'][name]['sha256'] = 'f'*64
        with self.assertRaises(ValueError):
            operational.portable_operational_rows(forged, self.document, self.root)
        Path(self.files[name]['file']).write_bytes(b'changed-runtime')
        with self.assertRaises(ValueError):
            operational.portable_operational_rows(self.proposal, self.document, self.root)

    def test_audited_stamp_and_provider_location_cannot_change(self):
        changed = copy.deepcopy(self.document)
        changed['preparedBase']['stamp'] = 'another-stamp'
        with self.assertRaises(ValueError):
            operational.portable_operational_rows(self.proposal, changed, self.root)
        changed = copy.deepcopy(self.proposal)
        changed['bindings']['providers']['qbeRuntime']['file'] = '/historical/build/runtime.o'
        with self.assertRaises(ValueError):
            operational.portable_operational_rows(changed, self.document, self.root)

    def test_invalid_destination_and_modified_install_source_are_refused(self):
        row = self.document['assets']['prepared-base']
        for name in ['/tmp/runtime.o', 'selfhost/dist/../runtime.o', 'selfhost/dist/qbe/runtime.o']:
            with self.subTest(name=name), self.assertRaises(ValueError):
                prepare.installable_artifact(name, row, self.files, self.installed, self.inputs, self.root)
        changed = dict(row, sha256='f'*64)
        with self.assertRaises(ValueError):
            prepare.installable_artifact('selfhost/dist/qbe/other.p130', changed,
                self.files, self.installed, self.inputs, self.root)

    def test_only_maintained_source_provider_paths_become_relative(self):
        identity = {'bytes': 25, 'sha256': 'd'*64}
        for suffix in ['runtime.mjs', 'runtime/js/direct.mjs', 'runtime/native/runtime.c',
                       'runtime/native/effs/args.c']:
            name = 'selfhost/src/'+suffix
            original = dict(identity, file=str(self.root/name))
            self.assertEqual(prepare.relative_source_provider(original, self.root), dict(identity, file=name))
            self.assertEqual(original['file'], str(self.root/name))
        for name in [str(self.root/'selfhost/build/phase182/runtime.o'),
                     '/canonical/Base.bend', 'selfhost/dist/qbe/runtime.o',
                     str(self.root/'selfhost/src-unrelated/runtime.c')]:
            row = dict(identity, file=name)
            self.assertEqual(prepare.relative_source_provider(row, self.root), row)


if __name__ == '__main__':
    unittest.main()
