"""Metadata/mocked-child controls; never execute benchmark products."""
import argparse
import copy
import importlib.util
import json
import math
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('handwritten_runtime',Path(__file__).with_name('run.py'))
R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R)


class RuntimeContracts(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(); self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name); (self.root/'selfhost/build').mkdir(parents=True)
        self.catalog = {case['id']:case for case in json.loads(R.CATALOG.read_text())['cases']}
        self.files = {}
        for role in R.ROLES:
            file=self.root/role; file.write_text('unexecuted product fixture'); file.chmod(0o755)
            self.files[role] = file
        self.document = dict(kind='phase184-direct-c-products',complete=True,
                             inputs=[R.pin(file) for file in R.method_files()],cases=[])
        self.manifest = self.root/'products.json'
        self.calls = []

    def add_case(self, name):
        original=self.catalog[name]; expected=self.root/(name+'.expected')
        expected.write_text(original['point']['expectedStdout'])
        roles={role:dict(command=[str(file),str(expected)] if role == R.REFERENCE else
                               [str(file),'+RTS','--threads','1','--gpu','off','-RTS','--RTS'],
                         inputs=[R.pin(file),R.pin(expected)]) for role,file in self.files.items()}
        self.document['cases'].append(dict(id=name,family=original['family'],sourceGroup=original['sourceGroup'],
                                           point=copy.deepcopy(original['point']),roles=roles))
        self.save()

    def save(self): self.manifest.write_text(json.dumps(self.document))

    def args(self, **changes):
        values=dict(manifest=self.manifest,cases=None,rounds=3,seconds=30,target_ms=250,
                    guarded=True,cpu=3,out=self.root/'selfhost/build/results')
        values.update(changes);return argparse.Namespace(**values)

    def fake_child(self, command, directory, deadline, cwd):
        directory.mkdir(parents=True)
        name,role=directory.parent.name,Path(command[0]).name
        repetitions,warmups=map(int,command[-4:-2])
        point=self.catalog[name]['point']
        elapsed=self.elapsed(name,role,repetitions,directory.parent.parent.name)
        self.calls.append((name,role,repetitions,directory.parent.parent.name,command,deadline))
        stdout=directory/'stdout';stderr=directory/'stderr'
        stdout.write_text(point['expectedStdout']+str(warmups)+'\n'+str(repetitions)+'\n'+str(elapsed)+'\n')
        stderr.write_bytes(b'')
        return dict(command=command,seconds=elapsed/1000+.001,exitCode=0,timedOut=False,
                    stdout=R.pin(stdout),stderr=R.pin(stderr),cpuSeconds=0,peakRssBytes=0)

    def elapsed(self, name, role, repetitions, stage): return 250

    def observe(self, fake=None, **changes):
        with patch.object(R.os,'sched_getaffinity',return_value={3}), patch.dict(R.os.environ,{},clear=True), \
                patch.object(R.bench,'child',side_effect=fake or self.fake_child):
            return R.execute(self.args(**changes),self.root)

    def test_per_role_counts_exact_calls_rotations_and_best_envelope(self):
        name='scalar-region-8192';self.add_case(name)
        initial=self.catalog[name]['point']['repetitions']
        factors={'handwritten-c':10,'bend-qbe':250,'bend-c':125}
        self.elapsed=lambda name,role,count,stage: count*factors[role]//initial
        report=self.observe()
        self.assertTrue(report['complete'],report)
        case=report['cases'][0]
        self.assertEqual([case['calibration'][role]['repetitions'] for role in R.ROLES],[initial*25,initial,initial*2])
        self.assertEqual(len(case['pilots']),5)
        self.assertEqual([row['role'] for row in case['samples']],list(R.ROLES)+list(R.ROLES[1:]+R.ROLES[:1])+list(R.ROLES[2:]+R.ROLES[:2]))
        self.assertEqual(case['summary']['ratios'],{'bend-qbe':25,'bend-c':12.5})
        self.assertEqual(case['summary']['bestBendEnvelope']['role'],'bend-c')
        self.assertTrue(report['aggregate']['complete'])
        self.assertTrue(all(call[4][-2:] == list(map(str,self.catalog[name]['point']['runtimeArgs'])) for call in self.calls))
        self.assertEqual(json.loads((self.args().out/'report.json').read_text())['complete'],True)

    def test_changed_methods_and_changed_workload_are_refused(self):
        self.add_case('scalar-region-8192')
        original=copy.deepcopy(self.document)
        self.document['inputs']=self.document['inputs'][1:];self.save()
        with self.assertRaisesRegex(ValueError,'method/catalog'): R.load_manifest(self.manifest)
        self.document=copy.deepcopy(original);self.document['cases'][0]['point']['warmups']+=1;self.save()
        with self.assertRaisesRegex(ValueError,'Point/oracle'): R.load_manifest(self.manifest)
        self.document=copy.deepcopy(original);self.document['cases'][0]['sourceGroup']='arbitrary regrouping';self.save()
        with self.assertRaisesRegex(ValueError,'Source group'): R.load_manifest(self.manifest)
        self.document=copy.deepcopy(original);self.document['cases'][0]['roles']['bend-c']['inputs']=[];self.save()
        with self.assertRaisesRegex(ValueError,'pinned/executable'): R.load_manifest(self.manifest)

    def test_slow_original_batches_calibrate_down_and_keep_both_pilots(self):
        name='scalar-region-8192';self.add_case(name)
        original=self.catalog[name]['point']['repetitions']
        self.elapsed=lambda name,role,count,stage:max(1,count*2000//original)
        report=self.observe()
        self.assertTrue(report['complete'],report)
        case=report['cases'][0]
        for role in R.ROLES:
            pilots=[row for row in case['pilots'] if row['role'] == role]
            self.assertEqual(len(pilots),2)
            self.assertEqual(pilots[0]['adjustment'],'down')
            self.assertEqual(pilots[0]['nextRepetitions'],(original*250+1999)//2000)
            self.assertEqual(case['calibration'][role]['repetitions'],pilots[0]['nextRepetitions'])
        self.assertEqual(R.next_repetitions(8,20000,250),1)

    def test_zero_work_is_checked_without_calibration_or_ratios(self):
        self.add_case('scalar-region-0');self.elapsed=lambda *args:0
        report=self.observe()
        self.assertTrue(report['complete'])
        case=report['cases'][0]
        self.assertEqual(case['pilots'],[]);self.assertEqual(len(case['samples']),9)
        self.assertIsNone(case['summary']['ratios'])
        self.assertFalse(report['aggregate']['complete'])

    def test_short_timed_rows_remain_and_invalidate_aggregate(self):
        self.add_case('scalar-region-8192')
        self.elapsed=lambda name,role,count,stage:99 if stage == 'timed' and role == 'bend-qbe' else 250
        report=self.observe()
        self.assertFalse(report['complete']);self.assertTrue(report['executionComplete'])
        self.assertEqual(len(report['cases'][0]['samples']),9)
        self.assertIsNone(report['cases'][0]['summary']['ratios'])
        self.assertFalse(report['aggregate']['complete'])

    def test_failed_pilot_is_retained_and_does_not_drop_other_cases(self):
        self.add_case('scalar-region-8192');self.add_case('scalar-region-0')
        def child(*args):
            row=self.fake_child(*args)
            if len(self.calls) == 1: row['timedOut']=True
            return row
        report=self.observe(child)
        self.assertFalse(report['complete']);self.assertFalse(report['aggregate']['complete'])
        self.assertIn('deadline',report['cases'][0]['pilots'][0]['error'])
        self.assertEqual(report['cases'][0]['samples'],[])
        self.assertEqual(len(report['cases'][1]['samples']),9)

    def test_output_count_mismatch_never_becomes_a_timing(self):
        self.add_case('scalar-region-8192')
        def child(*args):
            row=self.fake_child(*args)
            if len(self.calls) == 1:
                Path(row['stdout']['file']).write_text('wrong complete output\n')
                row['stdout']=R.pin(row['stdout']['file'])
            return row
        report=self.observe(child)
        row=report['cases'][0]['pilots'][0]
        self.assertFalse(row['correct']);self.assertNotIn('metricMs',row)
        self.assertFalse(report['complete'])

    def test_input_mutation_invalidates_completed_measurements(self):
        self.add_case('scalar-region-8192')
        def child(*args):
            row=self.fake_child(*args)
            if len(self.calls) == 4:self.files['bend-c'].write_text('changed product')
            return row
        report=self.observe(child)
        self.assertFalse(report['complete']);self.assertTrue(report['changedInputs'])
        self.assertIsNone(report['cases'][0]['summary']['ratios'])
        self.assertFalse(report['aggregate']['complete'])

    def test_total_deadline_leaves_pending_cases_in_partial_report(self):
        self.add_case('scalar-region-8192');self.add_case('scalar-region-0')
        clock=[0.0]
        def child(*args):
            row=self.fake_child(*args);clock[0]=1;return row
        with patch.object(R.time,'monotonic',side_effect=lambda:clock[0]): report=self.observe(child,seconds=.5)
        self.assertFalse(report['complete']);self.assertTrue(report['deadlineReached'])
        self.assertEqual(len(self.calls),1)
        self.assertEqual(report['cases'][1]['status'],'pending')

    def test_exact_ceiling_and_log_group_weights(self):
        self.assertEqual(R.next_repetitions(17,101,250),43)
        self.assertEqual(R.next_repetitions(17,0,250),170)
        self.assertEqual(R.next_repetitions(R.MAX_REPETITIONS,0,250),R.MAX_REPETITIONS)
        cases=[dict(family='a',sourceGroup='x'),dict(family='a',sourceGroup='y'),dict(family='b',sourceGroup='y')]
        weighted=R.weighted_ratios(cases,[4,1,1])
        self.assertAlmostEqual(weighted['equalPointGeomean'],4**(1/3))
        self.assertAlmostEqual(weighted['equalFamilyGeomean'],math.sqrt(2))
        self.assertAlmostEqual(weighted['equalSourceGeomean'],2)


if __name__ == '__main__': unittest.main()
