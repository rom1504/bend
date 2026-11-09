"""Offline receipt-policy tests; synthetic metadata never stands for target evidence."""
import copy
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('profile_controls', Path(__file__).with_name('profile-controls.py'))
controls = importlib.util.module_from_spec(spec)
spec.loader.exec_module(controls)


class ProfileControlsTest(unittest.TestCase):
    def metadata(self):
        return dict(
            capture=dict(complete=True, passed=True, changedInputs=[],
                rows=[dict(mode=m, correct=True) for m in ('clean', 'sample')]),
            analysis=dict(header=dict(samples=1), usable=False, quality=dict(zero_loss=True,
                handler_intact=True, main_thread_shutdown=True, delivery_plausible=True,
                limitations=['Synthetic short capture'])),
            attribution=dict(pairing=dict(verified=True), ownerBinding=dict(producerProvenanceVerified=True,
                checkedFids=1, sourceMap={'file': 'synthetic-map'}), coverage=dict(allSamples=1)),
            events=[dict(leaf=dict(objectSha256='synthetic-elf', loweredOwner='example',
                sourceLocation=dict(file='synthetic-source', sourceLine=1)))],
            binary=dict(sha256='synthetic-elf'))

    def test_short_control_preserves_quality_limit(self):
        value = self.metadata()
        result = controls.observation(**value)
        self.assertFalse(result['originalProfileUsable'])
        self.assertFalse(result['quantitativeProfileAdmitted'])
        self.assertEqual(result['quality']['limitations'], ['Synthetic short capture'])
        self.assertEqual(result['mappedSourceOwnerSamples'], 1)

    def test_bad_capture_quality_is_not_operational_pass(self):
        for key in ('zero_loss', 'handler_intact', 'main_thread_shutdown', 'delivery_plausible'):
            with self.subTest(key=key):
                value = self.metadata(); value['analysis']['quality'][key] = False
                with self.assertRaises(ValueError): controls.observation(**value)

    def test_unbound_or_wrong_image_samples_rejected(self):
        for change in ('receipt', 'elf', 'source', 'count'):
            with self.subTest(change=change):
                value = self.metadata()
                if change == 'receipt': value['attribution']['pairing']['verified'] = False
                if change == 'elf': value['events'][0]['leaf']['objectSha256'] = 'other-elf'
                if change == 'source': value['events'][0]['leaf']['sourceLocation'] = None
                if change == 'count': value['events'] = []
                with self.assertRaises(ValueError): controls.observation(**value)

    def test_output_pair_and_unchanged_inputs_required(self):
        for change in ('output', 'changed', 'duplicate'):
            with self.subTest(change=change):
                value = self.metadata()
                if change == 'output': value['capture']['rows'][1]['correct'] = False
                if change == 'changed': value['capture']['changedInputs'] = ['synthetic-source']
                if change == 'duplicate': value['capture']['rows'].append(copy.deepcopy(value['capture']['rows'][1]))
                with self.assertRaises(ValueError): controls.observation(**value)

    def test_incomplete_reference_and_missing_pins_rejected(self):
        with self.assertRaises(ValueError): controls.reference(dict(complete=False), 'example')
        self.assertFalse(controls.same({}, {}))


if __name__ == '__main__':
    unittest.main()
