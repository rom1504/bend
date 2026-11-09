"""Offline additive-release metadata controls; no proposal or target is produced."""
import copy
import importlib.util
from pathlib import Path
import unittest

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase183_prepare_release', HERE/'prepare-release.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


def row(name, tag='0'):
    return dict(file=name, bytes=1, sha256=tag*64)


class ReleasePreparation(unittest.TestCase):
    def preserved(self):
        components = {name: dict(gates=['old-gate']) for name in ('qbe', 'js', 'nativeCli')}
        source = dict(recipe=row('selfhost/src/compiler.json'), root='selfhost', profile='qbe', identity=row('canonical'))
        bindings = dict(kind='bend-current-bindings', version=1, complete=True, upstream='a'*40,
                        components=components, source=source, providers={'base': row('base')},
                        files={'selfhost/dist/image': row('selfhost/dist/image')})
        previous = dict(kind='bend-release-promotion', version=1, complete=True, bindings=copy.deepcopy(bindings),
                        files={'selfhost/dist/image': row('/candidate/image')},
                        gates={'old-gate': {'report': row('/old-gate.json')}})
        current = copy.deepcopy(bindings)
        current['files'][P.AUDIT_NAME] = row(P.AUDIT_NAME)
        current.update(provenance=row(P.AUDIT_NAME), gateStatus=dict(qualified=True,
                       components={key: value['gates'] for key, value in components.items()}))
        audit = dict(kind='bend-release-audit', complete=True, qualified=True, components=components,
                     sourceIdentity=source['identity'], gates={'old-gate': row('/old-gate.json')})
        return current, previous, audit

    def test_previous_components_providers_and_files_are_preserved_without_old_audit_slot(self):
        current, previous, audit = self.preserved()
        before = copy.deepcopy((current, previous, audit))
        result = P.preserved_bindings(current, previous, audit)
        self.assertEqual(result, previous['bindings'])
        self.assertNotIn(P.AUDIT_NAME, result['files'])
        self.assertEqual((current, previous, audit), before)
        result['components']['qbe']['gates'].append('new')
        self.assertEqual(current['components']['qbe']['gates'], ['old-gate'])

    def test_changed_selected_component_or_prior_gate_refused(self):
        for field in ('component', 'gate', 'file'):
            current, previous, audit = self.preserved()
            if field == 'component': current['components']['js']['stage'] = 'changed'
            elif field == 'gate': audit['gates']['old-gate']['sha256'] = 'f'*64
            else: current['files']['selfhost/dist/image']['bytes'] = 2
            with self.subTest(field=field), self.assertRaises(ValueError):
                P.preserved_bindings(current, previous, audit)

    def operational(self):
        runtime, image, old = row('selfhost/dist/qbe/runtime.o'), row('selfhost/dist/x86/bend'), row('selfhost/dist/qbe/bend')
        prepared = {'format': 'fixture'}
        component = dict(image=image, sourceIdentity=row('assembly'), sourceProfile={'profile': 'x86'},
                         qualificationReceipts={name: row(name) for name in ('x86-n2', 'x86-behavior', 'x86-runtime')})
        current = dict(upstream='a'*40, components={'x86': component, 'qbe': {'image': old, 'preparedBase': prepared}},
                       providers={'qbeRuntime': runtime})
        original = dict(upstream='a'*40, assets={'qbe-n2': old, 'qbe-runtime': runtime, 'objcopy': row('/objcopy'),
                        'assembler': row('/assembler', 'a'), 'linker': row('/linker', 'b')},
                        images={'qbe-n2': {'sessionProtocols': ['P140/2']}}, preparedBase=prepared,
                        runtimePolicies={'qbe-runtime': {'runtimeArgumentConvention': 'bend-rts-v1', 'threads': 1}},
                        toolchains={'qbe': {'preserved': True}}, providers={'c': {'runtime': 'c-runtime'}})
        n2 = dict(inputs=[row('/assembler', 'a'), row('/linker', 'b')],
                  toolchain=dict(target='amd64_sysv', assemblerFlags=['-mbranches-within-32B-boundaries'],
                                linkerFlags=['-no-pie'], libraries=['-pthread', '-lm']))
        return original, current, n2

    def test_operational_maps_preserve_old_capabilities_and_add_exact_assembly_binding(self):
        original, current, n2 = self.operational(); before = copy.deepcopy(original)
        result = P.operational_map(original, current, n2, row('/promotion'))
        self.assertEqual(original, before)
        for key, value in original['assets'].items(): self.assertEqual(result['assets'][key], value)
        self.assertEqual(result['images']['qbe-n2'], original['images']['qbe-n2'])
        self.assertEqual(result['providers'], original['providers'])
        self.assertEqual(result['toolchains']['qbe'], original['toolchains']['qbe'])
        self.assertEqual(result['toolchains']['x86'], n2['toolchain'])
        self.assertEqual(result['runtimePolicies']['qbe-runtime']['runtimeABI'], 11102)
        self.assertEqual(result['images']['x86-n2']['stage'], 'N2')
        self.assertEqual(result['images']['x86-n2']['linkedRuntime'], current['providers']['qbeRuntime'])
        self.assertNotIn('sessionProtocols', result['images']['x86-n2'])

    def test_conflicting_runtime_or_toolchain_refused(self):
        for field in ('runtime', 'toolchain', 'assembler', 'linker'):
            original, current, n2 = self.operational()
            if field == 'runtime': original['runtimePolicies']['qbe-runtime']['runtimeABI'] = 11101
            elif field == 'toolchain': n2['toolchain']['linkerFlags'] = []
            else: original['assets'][field]['sha256'] = 'f'*64
            with self.subTest(field=field), self.assertRaises(ValueError):
                P.operational_map(original, current, n2, row('/promotion'))

    def test_failed_receipt_cannot_be_reused_as_completed(self):
        for report in ({'complete': False}, {'complete': True, 'error': 'failure'},
                       {'complete': True, 'changedInputs': ['source']}):
            with self.assertRaises(ValueError): P.completed(report, 'fixture')


if __name__ == '__main__': unittest.main()
