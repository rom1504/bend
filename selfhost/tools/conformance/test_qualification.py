"""Offline oracle/identity tests. Never launches a compiler or emitted program."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
BUILD = Path(__file__).parents[1] / 'build'
sys.path.insert(0, str(BUILD))
import qualification as Q


class QualificationJudges(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.path = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def child(self, stdout=b'', stderr=b'', code=0):
        (self.path / 'stdout').write_bytes(stdout)
        (self.path / 'stderr').write_bytes(stderr)
        return dict(started=1, exitCode=code, timedOut=False,
                    stdout=Q.pin(self.path / 'stdout'), stderr=Q.pin(self.path / 'stderr'))

    def test_full_output_and_closed_child(self):
        expected = dict(exitCode=0, stdout='42\n', stderr='')
        good = self.child(b'42\n')
        self.assertTrue(Q.output_exact(good, expected))
        self.assertFalse(Q.output_exact(dict(good, timedOut=True), expected))
        self.assertFalse(Q.output_exact(dict(good, exitCode=-9), expected))
        self.assertFalse(Q.output_exact(dict(good, error='launch'), expected))
        self.assertFalse(Q.output_exact(self.child(b'42'), expected))
        self.assertFalse(Q.output_exact(self.child(b'42\n', b'warning'), expected))

    def test_stage_specific_refusal(self):
        case = dict(name='negative-type', refusal=dict(prefix='check: main:', exact=False))
        child = self.child(stderr=b'check: main: wrong type\n', code=1)
        emission = dict(host='native', target='qbe', process=child, changedInputs=[])
        self.assertTrue(Q.refusal(case, emission))
        for changes in [dict(exitCode=-9), dict(timedOut=True), dict(exitCode=0), dict(error='launch')]:
            self.assertFalse(Q.refusal(case, dict(emission, process=dict(child, **changes))))
        self.assertFalse(Q.refusal(case, dict(emission, changedInputs=['source'])))
        self.assertFalse(Q.refusal(case, dict(emission, product=dict(bytes=1))))
        self.assertFalse(Q.refusal(case, dict(emission, process=self.child(stderr=b'compile: failed', code=1))))
        self.assertFalse(Q.refusal(case, dict(emission, process=self.child(stderr=b'check: main:', code=1))))

    def test_assembly_refusals_require_the_same_specific_semantic_stage(self):
        case = dict(name='negative-type', refusal=dict(prefix='check: main:', exact=False))
        args = argparse.Namespace(host='native', target='x86')
        self.assertTrue(Q.supported(case,args))
        child = self.child(stderr=b'check: main: wrong type\n',code=1)
        emission = dict(host='native',target='x86',process=child,changedInputs=[])
        self.assertTrue(Q.refusal(case,emission))
        self.assertFalse(Q.refusal(case,dict(emission,product=dict(bytes=1))))
        self.assertFalse(Q.refusal(case,dict(emission,process=dict(child,exitCode=-9))))
        self.assertFalse(Q.refusal(case,dict(emission,process=self.child(stderr=b'assembly: unsupported',code=1))))

    def test_hosted_check_is_not_crash_or_unchecked_parse(self):
        case = dict(name='negative-type')
        emission = dict(host='js', target='js', process=self.child(code=1), changedInputs=[])
        hosted = dict(kind='bend-hosted-request', complete=False,
                      observation=dict(status='error', phase='check', checked=True, diagnostic='wrong type'))
        self.assertTrue(Q.refusal(case, emission, hosted))
        self.assertFalse(Q.refusal(case, emission))
        for changes in [dict(phase='parse'), dict(checked=False), dict(typeAccepted=True), dict(status='crash')]:
            self.assertFalse(Q.refusal(case, emission, dict(hosted, observation=dict(hosted['observation'], **changes))))

    def test_catalog_is_self_contained(self):
        cases, inputs = Q.select(argparse.Namespace(suite='all', case=None), Q.workspace())
        self.assertEqual(len(cases), 64)
        self.assertEqual(sum('stdoutFile' in c for c in cases), 61)
        self.assertFalse(any('/performance/' in p['file'] for p in inputs))
        self.assertEqual(sum('refusal' in c for c in cases), 3)

    def test_explicit_new_catalog_preserves_default_identity(self):
        source = self.path / 'source.bend'; source.write_text('fixture')
        catalog = self.path / 'catalog.json'
        document = dict(kind='bend-qualification-catalog',version=1,upstream='9'*40,
                        cases=[dict(id='new',name='new',suite='focused',source=Q.pin(source),
                                    expect=dict(exitCode=0,stdout='42\n',stderr=''))])
        catalog.write_text(json.dumps(document))
        args = argparse.Namespace(catalog=catalog,suite='focused',case=None)
        cases, inputs = Q.select(args,self.path)
        self.assertEqual(len(cases),1)
        self.assertEqual(Q.load_catalog(args)[0]['upstream'],'9'*40)
        self.assertEqual(inputs[0],Q.pin(catalog))
        self.assertEqual(Q.load_catalog(argparse.Namespace())[0]['upstream'],Q.UPSTREAM)
        document['upstream']='unbound'; catalog.write_text(json.dumps(document))
        with self.assertRaisesRegex(ValueError,'qualification catalog'):
            Q.load_catalog(args)

    def test_host_closure_and_source_image_crossbinding(self):
        request_file = self.path / 'request.json'; request_file.write_text('{}')
        source_file = self.path / 'source.bend'; source_file.write_text('source')
        image_file = self.path / 'api.mjs'; image_file.write_text('image')
        emission = dict(target='js', stage='B1', source=Q.pin(source_file), image=Q.pin(image_file))
        hosted = dict(emission, kind='bend-hosted-request', version=1,
                      request=Q.pin(request_file), inputs=[Q.pin(source_file), Q.pin(image_file)])
        Q.verify_hosted(emission, hosted, request_file)
        with self.assertRaises(ValueError):
            Q.verify_hosted(emission, dict(hosted, stage='B2'), request_file)
        with self.assertRaises(ValueError):
            Q.verify_hosted(emission, dict(hosted, source=Q.pin(image_file)), request_file)
        image_file.write_text('changed')
        with self.assertRaises(ValueError):
            Q.verify_hosted(emission, hosted, request_file)

    def test_asset_default_catalog_is_hash_bound_and_explicit_override_survives(self):
        original, _ = Q.load_catalog(argparse.Namespace())
        current = dict(original, upstream='9'*40)
        file = self.path / 'current-catalog.json'; file.write_text(json.dumps(current))
        document = dict(_workspace=self.path, qualificationCatalog=Q.pin(file))
        self.assertEqual(Q.load_catalog(argparse.Namespace(), document)[0]['upstream'], '9'*40)
        self.assertEqual(Q.load_catalog(argparse.Namespace(catalog=Q.CATALOG), document)[0]['upstream'], Q.UPSTREAM)
        file.write_text(json.dumps(dict(current, scope='changed')))
        with self.assertRaises(ValueError):
            Q.load_catalog(argparse.Namespace(), document)


if __name__ == '__main__':
    unittest.main()
