"""Synthetic x86 promotion evidence; no compiler, target, or real installation."""
import copy
import json
from pathlib import Path
import unittest

import release
import test_release as baseline
from common import pin


CASES = ['numeric', 'array-unchecked', 'array-unchecked-boxed', 'char-output',
         'argv', 'files', 'open-errors', 'exit', 'exit-upper-valid', 'halt-valid']


class X86ReleaseFixtures(unittest.TestCase):
    def setUp(self):
        fixture = baseline.ReleaseFixtures()
        fixture.setUp()
        self.addCleanup(fixture.doCleanups)
        self.root, self.file, self.json = fixture.root, fixture.file, fixture.json
        self.proposal = copy.deepcopy(fixture.proposal)
        current = self.proposal['bindings']
        current['upstream'] = '9' * 40
        recipe_file = self.root / 'selfhost/src/compiler.json'
        recipe = json.loads(recipe_file.read_text())
        recipe['profiles']['x86'] = dict(entryModule='src/x86-main.bend',
            modules=['src/x86.bend'], roots=['main'])
        self.json('selfhost/src/compiler.json', recipe)
        self.file('selfhost/src/x86.bend', b'def machine() -> U32:\n  2\n')
        self.file('selfhost/src/x86-main.bend', b'def main() -> U32:\n  machine()\n')
        current['source']['recipe'] = dict(pin(recipe_file), file='selfhost/src/compiler.json')
        self.source = pin(self.file('x86-source.bend', release.assembly.maintained_assemble(
            recipe_file, self.root / 'selfhost', 'x86')))
        self.runtime = pin(self.file('runtime.o', b'current runtime fixture'))
        current['providers']['qbeRuntime'] = self.runtime
        images = {stage: pin(self.file(stage + '.image', ('image ' + stage).encode()))
                  for stage in ['N0', 'N1', 'N2']}
        for image in images.values():
            Path(image['file']).chmod(0o755)
        destination = 'selfhost/dist/x86'
        self.proposal['files'][destination] = images['N2']
        installed = dict(images['N2'], file=destination)
        current['files'][destination] = installed
        names = {name: 'x86-' + name for name in
                 ['sourceCheck', 'seed', 'n1', 'n2', 'reproduction', 'behavior', 'runtime']}
        self.proposal['x86Qualification'] = names
        current['components']['x86'] = dict(host='native', stage='N2', protocol='native-x86-source-v1',
            capabilities=['x86'], image=installed, sourceIdentity=self.source, gates=list(names.values()),
            sourceProfile=dict(recipe=current['source']['recipe'], root='selfhost', profile='x86'),
            linkedRuntime=self.runtime, linkedRuntimeABI=11102, runtimeArgumentConvention='bend-rts-v1')
        assembly = pin(self.file('compiler.s', b'whole assembly fixture\n'))
        self.reports = dict(sourceCheck=dict(kind='bend-independent-source-check', complete=True,
            checked=True, typeAccepted=True, unresolvedHoles=0, source=self.source, upstream=current['upstream']))
        previous = current['components']['qbe']
        for key, stage, target in [('seed', 'N0', 'qbe'), ('n1', 'N1', 'x86'), ('n2', 'N2', 'x86')]:
            metadata = dict(copy.deepcopy(previous), targets=previous.get('targets', previous.get('capabilities')),
                linkedRuntime=self.runtime, runtimeArgumentConvention='bend-rts-v1')
            request = dict(host='native', stage=previous['stage'], target=target, source=self.source,
                image=previous['image'], imageMetadata=metadata, outputContract='stdout')
            binding = dict(kind='bend-build-image-binding', version=1, complete=True, host='native',
                stage=stage, protocol='native-x86-source-v1', targets=['x86'], image=images[stage],
                sourceIdentity=self.source, linkedRuntime=self.runtime, linkedRuntimeABI=11102,
                runtimeArgumentConvention='bend-rts-v1', producer=previous['image'],
                producerHost='native', producerStage=previous['stage'])
            self.reports[key] = dict(kind='bend-native-build', complete=True, host='native',
                stage=previous['stage'], target=target, imageBinding=binding, request=request,
                binary=images[stage], runtime=self.runtime, runtimeABI=11102, runtimeArgumentConvention='bend-rts-v1',
                assemblyDigest=assembly, expectedAssembly=assembly, comparedToReference=(stage == 'N2'))
            previous = binding
        self.reports['reproduction'] = dict(kind='bend-build-request', complete=True,
            host='native', stage='N2', target='x86', byteExact=True, image=installed,
            source=self.source, product=assembly, request=dict(image=installed, source=self.source,
                host='native', stage='N2', target='x86', expected=assembly, outputContract='stdout',
                imageMetadata=copy.deepcopy(previous)),
            process=dict(complete=True, exitCode=0, timedOut=False, stdout=assembly, stderr={'bytes': 0}))
        ids = ['case-' + str(i) for i in range(64)]
        catalog = pin(self.json('catalog.json', dict(kind='bend-qualification-catalog', version=1,
            upstream=current['upstream'], cases=[dict(id=name) for name in ids])))
        self.proposal['x86QualificationCatalog'] = catalog
        self.reports['behavior'] = dict(kind='bend-finite-qualification', complete=True, passed=True,
            host='native', stage='N2', target='x86', upstream=current['upstream'], image=installed,
            catalog=catalog, inputs=[self.runtime], selected=ids,
            counts={'pass': 64, 'fail': 0, 'unsupported': 0}, rows=[dict(id=name, status='pass') for name in ids])
        self.reports['runtime'] = dict(kind='phase183-x86-runtime-controls', complete=True, passed=True,
            host='native', stage='N2', target='x86', image=installed, runtime=self.runtime, runtimeABI=11102,
            inputs=[self.runtime], selection=dict(all=True, count=10, total=10, names=CASES),
            rows=[dict(name=name, complete=True) for name in CASES])
        for key, name in names.items():
            role = 'qualification' if key in ['behavior', 'runtime'] else 'derivation' if key == 'sourceCheck' else 'lineage'
            claims = {'passed': True} if role == 'qualification' else {'complete': True}
            bindings = {'image': installed} if role == 'qualification' else {}
            if key == 'n2':
                bindings = {'binary': installed, 'request.source': self.source}
            self.proposal['gates'][name] = dict(role=role, claims=claims, bindings=bindings)

    def audit(self, proposal=None, reports=None):
        proposal = copy.deepcopy(proposal or self.proposal)
        reports = reports or self.reports
        for key, name in self.proposal['x86Qualification'].items():
            proposal['gates'][name]['report'] = pin(self.json(name + '.json', reports[key]))
        return release.audit(self.json('x86-promotion.json', proposal), self.root)

    def reject_report(self, key, update):
        reports = copy.deepcopy(self.reports)
        update(reports[key])
        with self.assertRaises((ValueError, KeyError)):
            self.audit(reports=reports)

    def test_four_component_promotion_and_existing_three_remain_admitted(self):
        _, receipt = self.audit()
        self.assertEqual(set(receipt['components']), {'qbe', 'js', 'nativeCli', 'x86'})
        proposal = copy.deepcopy(self.proposal)
        del proposal['bindings']['components']['x86']
        _, receipt = self.audit(proposal)
        self.assertEqual(set(receipt['components']), {'qbe', 'js', 'nativeCli'})

    def test_profile_and_current_runtime_binding_cannot_be_relabelled(self):
        for field, value in [('sourceProfile', dict(recipe=self.proposal['bindings']['source']['recipe'],
                                                   root='selfhost', profile='qbe')),
                             ('sourceIdentity', self.proposal['bindings']['source']['identity']),
                             ('linkedRuntimeABI', 11101), ('runtimeArgumentConvention', 'bend-legacy-v1')]:
            with self.subTest(field=field):
                proposal = copy.deepcopy(self.proposal)
                proposal['bindings']['components']['x86'][field] = value
                with self.assertRaises(ValueError):
                    self.audit(proposal)

    def test_source_check_needs_current_upstream_and_no_holes(self):
        self.reject_report('sourceCheck', lambda r: r.update(upstream='0' * 40))
        self.reject_report('sourceCheck', lambda r: r.update(unresolvedHoles=1))

    def test_real_generations_and_producer_chain_are_required(self):
        self.reject_report('seed', lambda r: r['imageBinding'].update(stage='N1'))
        self.reject_report('n1', lambda r: r['request'].update(image=self.reports['n2']['binary']))
        self.reject_report('n2', lambda r: r['imageBinding'].update(producer=self.reports['seed']['binary']))
        self.reject_report('n2', lambda r: r.update(comparedToReference=False))

    def test_seed_cannot_substitute_a_different_consistently_labelled_producer(self):
        def substitute(report):
            image = self.reports['n1']['binary']
            report['request']['image'] = image
            report['imageBinding']['producer'] = image
        self.reject_report('seed', substitute)

    def test_reproduction_uses_the_actual_nested_request_and_clean_process(self):
        self.reject_report('reproduction', lambda r: r['request'].update(source=self.runtime))
        self.reject_report('reproduction', lambda r: r['request'].update(image=self.reports['seed']['binary']))
        self.reject_report('reproduction', lambda r: r['request']['imageMetadata'].update(sourceIdentity=self.runtime))
        self.reject_report('reproduction', lambda r: r['process'].update(error='injected process error'))

    def test_behavior_cannot_substitute_another_64_cases_or_catalog(self):
        def substitute(report):
            report['selected'] = ['different-' + str(i) for i in range(64)]
            report['rows'] = [dict(id=name, status='pass') for name in report['selected']]
        self.reject_report('behavior', substitute)
        self.reject_report('behavior', lambda r: r.update(catalog=self.runtime))

    def test_runtime_cannot_relabel_failed_duplicate_or_old_provider_rows(self):
        self.reject_report('runtime', lambda r: r['rows'][0].update(complete=False))
        self.reject_report('runtime', lambda r: r['rows'][0].update(name='not-numeric'))
        self.reject_report('runtime', lambda r: r.update(runtime=self.source))
        self.reject_report('runtime', lambda r: r.update(host='js'))

    def test_runtime_object_must_also_be_an_actual_behavior_input(self):
        self.reject_report('behavior', lambda r: r.update(inputs=[]))

    def test_every_mandatory_gate_must_be_selected(self):
        proposal = copy.deepcopy(self.proposal)
        proposal['bindings']['components']['x86']['gates'].remove('x86-sourceCheck')
        with self.assertRaisesRegex(ValueError, 'mandatory gate'):
            self.audit(proposal)


if __name__ == '__main__':
    unittest.main()
