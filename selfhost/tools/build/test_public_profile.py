"""Offline public CLI asset binding controls; no compiler or target execution."""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
spec = importlib.util.spec_from_file_location('public_profile', Path(__file__).with_name('public-cli.py'))
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


class PublicProfileAssets(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'selfhost').mkdir()
        self.doc = dict(kind='bend-build-assets', version=1, complete=True, assets={})
        self.manifest = self.root / 'assets.json'
        self.base = self.asset('base', b'Base fixture\n')
        identity = dict(format='p88-private-base-text-1', cache='a'*64, api='b'*64,
                        base=self.base['sha256'], path=self.base['file'], begin=1, end=15,
                        termAbi=1, spanAbi=3, worldVersion=3)
        self.stamp = 'p88-private-base-text-1:' + hashlib.sha256(json.dumps(
            identity, separators=(',', ':'), ensure_ascii=False).encode()).hexdigest()
        self.decimal = self.asset('decimal', (str(len(self.stamp))+'\n'+self.stamp+'\nfixture\n').encode())
        self.carrier = dict(kind='bend-prepared-base-carrier', version=1, complete=True,
                            base=self.base, decimalCarrier=self.decimal, sourceIdentity=identity,
                            sourceBegin=1, sourceEnd=15, originalStamp=self.stamp)
        self.asset_json('carrier-receipt', self.carrier)
        self.parts = ['// λ🙂\n', 'one\n', 'two\n', 'three\n', 'four\n']
        self.runtime = self.asset('runtime', ''.join(self.parts).encode())
        self.doc['assets']['runtime']['runtimeArgumentConvention'] = 'bend-rts-v1'
        self.template = dict(version=1, runtimeSha256=self.runtime['sha256'],
                             runtimeArgumentConvention='bend-rts-v1', parts=self.parts)
        self.template_row = self.asset_json('template', self.template)
        self.prepared = dict(kind='bend-native-template', version=2, complete=True,
                             exactRoundTrip=True, chunks=5, artifact=self.template_row,
                             runtime=self.runtime, runtimeArgumentConvention='bend-rts-v1')
        self.asset_json('template-receipt', self.prepared)
        effects = {}
        for name in P.EFFECTS:
            key = 'effect-'+name
            self.asset(key, ('fixture '+name).encode())
            effects[name] = key
        self.doc['publicCliAssets'] = dict(base='base', decimalCarrier='decimal',
            carrierReceipt='carrier-receipt', runtime='runtime', runtimeTemplate='template',
            runtimeTemplateReceipt='template-receipt', effects=effects)
        self.save()

    def asset(self, name, data):
        file = self.root / name
        file.write_bytes(data)
        row = P.pin(file)
        self.doc['assets'][name] = row
        return row.copy()

    def asset_json(self, name, value):
        return self.asset(name, (json.dumps(value)+'\n').encode())

    def save(self):
        self.manifest.write_text(json.dumps(self.doc))

    def select(self):
        self.save()
        return P.fresh_assets(self.manifest, self.root)

    def test_fresh_assets_need_no_incumbent_and_preserve_exact_bytes(self):
        got = self.select()
        self.assertEqual(set(got['payloads']), P.ASSET_NAMES)
        self.assertEqual(got['baseIdentity'], self.base['file'])
        self.assertEqual(got['cacheStamp'], self.stamp)
        self.assertEqual(got['runtimeArgumentConvention'], 'bend-rts-v1')
        self.assertEqual(b''.join(got['payloads']['runtime.c.part'+str(i)] for i in range(5)),
                         Path(self.runtime['file']).read_bytes())
        self.assertEqual(got['authority'], P.pin(self.manifest))
        self.assertEqual(len(got['receipts']), 2)

    def test_carrier_receipt_cannot_bind_different_bytes(self):
        self.asset('decimal', b'another decimal carrier')
        with self.assertRaisesRegex(ValueError, 'decimal Base receipt'):
            self.select()

    def test_carrier_header_and_original_stamp_are_checked(self):
        self.carrier['decimalCarrier'] = self.asset('decimal', b'wrong stamp\n')
        self.asset_json('carrier-receipt', self.carrier)
        with self.assertRaisesRegex(ValueError, 'decimal Base header'):
            self.select()
        self.carrier['originalStamp'] = 'p88-private-base-text-1:'+'0'*64
        self.asset_json('carrier-receipt', self.carrier)
        with self.assertRaisesRegex(ValueError, 'decimal Base stamp'):
            self.select()

    def test_template_boundary_changes_require_new_receipt(self):
        self.template['parts'] = ['', ''.join(self.parts[:2]), *self.parts[2:]]
        self.asset_json('template', self.template)
        with self.assertRaisesRegex(ValueError, 'template receipt'):
            self.select()

    def test_exact_roundtrip_and_runtime_convention_are_checked(self):
        self.doc['assets']['runtime']['runtimeArgumentConvention'] = 'bend-legacy-v1'
        with self.assertRaisesRegex(ValueError, 'convention bindings'):
            self.select()
        self.doc['assets']['runtime']['runtimeArgumentConvention'] = 'bend-rts-v1'
        self.template['parts'][0] += 'different'
        self.prepared['artifact'] = self.asset_json('template', self.template)
        self.asset_json('template-receipt', self.prepared)
        with self.assertRaisesRegex(ValueError, 'round-trip exactly'):
            self.select()

    def test_incumbent_assets_remain_supported(self):
        got = self.select()
        package = self.root / 'package'
        rows = {}
        for name, data in got['payloads'].items():
            file = package / 'assets' / name
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_bytes(data)
            rows[name] = P.pin(file)
        (package / 'BUILD.json').write_text(json.dumps(dict(kind='bend-public-cli-package',
            complete=True, protocol='native-public-cli-v1', assets=rows,
            baseIdentity=got['baseIdentity'], cacheStamp=got['cacheStamp'])))
        runtime_dir = self.root / 'selfhost/src/runtime/native'
        runtime_dir.mkdir(parents=True)
        (runtime_dir / 'runtime.c').write_bytes(Path(self.runtime['file']).read_bytes())
        (runtime_dir / 'runtime-template.json').write_text(json.dumps(self.template))
        with patch.object(P, 'ROOT', self.root):
            old = P.incumbent_assets(package)
        self.assertEqual(old['payloads'], got['payloads'])
        self.assertEqual(old['cacheStamp'], got['cacheStamp'])
        self.assertEqual(old['receipts'], {})


if __name__ == '__main__':
    unittest.main()
