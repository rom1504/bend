"""Synthetic offline comparison controls; no compiler or benchmark execution."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location('bend_compare', Path(__file__).with_name('compare.py'))
C = importlib.util.module_from_spec(SPEC); SPEC.loader.exec_module(C)


def analysis(count, period, first, *, bad=None, binary='/program'):
    quality = dict(near_complete_process_cpu_coverage=True, thread_lifecycle_complete=True,
                   handler_intact=True, main_thread_shutdown=True, delivery_plausible=True,
                   unknown_samples=0, enough_samples=count >= 500)
    if bad: quality[bad] = False
    return dict(header=dict(exe=binary, samples=count, period_us=period, dropped=0, overruns=0,
                            process_cpu_ns=1_000_000_000),
        quality=quality, group_rules={'first':'first','second':'second'},
        top_functions=[dict(name='first',decoded='first',object=binary,samples=first),
                       dict(name='second',decoded='second',object=binary,samples=count-first)],
        groups=[dict(name='first',samples=first),dict(name='second',samples=count-first)],
        categories=[dict(name='executable',samples=count)])


def capture(a, child_cpu=1.0):
    return dict(identity=dict(file='capture', bytes=1, sha256='synthetic'), analysis=a,
                childCpuSeconds=child_cpu)


class Pooling(unittest.TestCase):
    def test_short_captures_pool_with_correct_period_weights(self):
        result = C.pool_captures([capture(analysis(300,1000,300)), capture(analysis(300,3000,0))], 2.0)
        self.assertTrue(result['adequate'])
        first = next(row for row in result['functions'] if row['decoded']=='first')
        self.assertEqual(first['rawFraction'], 0.5)
        self.assertEqual(first['periodWeightedFraction'], 0.25)
        self.assertEqual(first['estimatedCleanCpuSeconds'], 0.5)
        self.assertEqual(sum(row['estimatedCleanCpuSeconds'] for row in result['functions']), 2.0)

    def test_lost_or_bad_coverage_capture_is_retained_but_excluded(self):
        lost = analysis(500,1000,500); lost['header']['overruns'] = 1
        bad = analysis(500,1000,500,bad='near_complete_process_cpu_coverage')
        result = C.pool_captures([capture(lost),capture(bad),capture(analysis(100,1000,50))], 2.0)
        self.assertEqual(len(result['rejectedCaptures']), 2)
        self.assertEqual(result['captureLossTotals']['overruns'], 1)
        self.assertEqual(result['samples'],100)
        self.assertFalse(result['estimateAvailable'])
        self.assertTrue(all('estimatedCleanCpuSeconds' not in r for r in result['functions']))

    def test_bad_histogram_denominator_is_rejected(self):
        bad=analysis(500,1000,200);bad['groups'][0]['samples']+=1
        with self.assertRaisesRegex(ValueError,'denominator'):
            C.pool_captures([capture(bad)])

    def test_incomplete_lifetime_preserves_fractions_but_refuses_absolute_costs(self):
        result=C.pool_captures([capture(analysis(500,1000,250),child_cpu=2)],2.0)
        self.assertTrue(result['adequate'])
        self.assertFalse(result['wholeChildCpuCoverageAdequate'])
        self.assertFalse(result['estimateAvailable'])
        self.assertEqual(result['functions'][0]['rawFraction'],0.5)
        self.assertTrue(all('estimatedCleanCpuSeconds' not in r for r in result['functions']))

    def test_missing_lifetime_is_not_assumed_complete(self):
        a=analysis(500,1000,250);del a['header']['process_cpu_ns']
        result=C.pool_captures([capture(a)],2.0)
        self.assertFalse(result['estimateAvailable'])
        self.assertIsNone(result['acceptedCaptures'][0]['captureWindowChildCpuFraction'])

    def test_anonymous_function_deltas_are_not_matched(self):
        rows=[dict(decoded='$p111.k.42',object='executable',samples=20,rawFraction=1,periodWeightedFraction=1)]
        self.assertEqual(C._delta(rows,rows,lambda row:row['decoded']),[])

    def test_event_overflow_and_duplicate_fids_are_rejected(self):
        data=dict(schema='bend-native-dispatch-events-v1',complete=True,counts_enabled=True,
                  counter_overflow=False,invalid_context_events=0,counter_names=['a','b'],
                  rows=[dict(fid=0,counts=[2,3]),dict(fid=1,counts=[4,5])])
        self.assertEqual(C.event_totals(data),{'a':6,'b':8})
        data['rows'][1]['fid']=0
        with self.assertRaisesRegex(ValueError,'Duplicate FID'):C.event_totals(data)
        data['rows'][1]['fid']=1;data['counter_overflow']=True
        with self.assertRaisesRegex(ValueError,'Invalid diagnostic'):C.event_totals(data)


class Reports(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.root=Path(self.temp.name)
        self.source=self.root/'input.bend';self.source.write_text('fixed source')
        self.sequence=0

    def tearDown(self):self.temp.cleanup()

    def build(self, name, *, workload='work', variant='base', binary_text='binary',
              argument='arg', diagnostic=False, clean_cpu=2.0, source=None):
        out=self.root/name;out.mkdir()
        binary=self.root/(variant+'.bin')
        if not binary.exists():binary.write_text(binary_text)
        source=source or self.source
        oracle=self.root/'oracle';oracle.write_text('correct\n')
        empty=self.root/'empty';empty.write_bytes(b'')
        expected=dict(exitCode=0,stdout=dict(kind='exact',**C.pin(oracle)),stderr=dict(kind='exact',**C.pin(empty)))
        command=[str(binary),str(source),argument]
        v=dict(name=variant,binary=C.pin(binary),command=command,inputs=[C.pin(binary),C.pin(source)],
               expected=expected,dispatchInstrumentation=diagnostic)
        manifest=dict(schema='bend-native-profile-workloads-v1',cwd=str(self.root),workloads=[dict(name=workload,variants=[v])])
        mp=out/'manifest.json';mp.write_text(json.dumps(manifest))
        rows=[]
        for index, mode in enumerate(['clean','sample','sample']):
            stdout=out/f'{index}.stdout';stdout.write_text('correct\n')
            stderr=out/f'{index}.stderr';stderr.write_bytes(b'')
            row=dict(workload=workload,variant=variant,mode=mode,command=command,correct=True,
                diagnosticRuntime=diagnostic,returncode=0,timedOut=False,wallSeconds=clean_cpu,
                cpuSeconds=clean_cpu,peakRssKiB=100,stdout=C.pin(stdout),stderr=C.pin(stderr))
            if mode=='sample':
                raw=out/f'{index}.samples';raw.write_text('frozen capture'+str(index))
                a=analysis(300,index*1000,150,binary=str(binary))
                a['header']['process_cpu_ns']=int(clean_cpu*1e9)
                a['identities']=dict(capture=C.pin(raw),binary=C.pin(binary))
                ap=out/f'{index}.analysis';ap.write_text(json.dumps(a))
                row.update(profile=C.pin(raw),analysis=C.pin(ap))
            rows.append(row)
        report=dict(schema='bend-native-profile-run-v1',complete=True,passed=True,changedInputs=[],
            started=1,finished=10,inputs=[C.pin(mp)],rows=rows)
        rp=out/'report.json';rp.write_text(json.dumps(report));return rp

    def test_reports_preserve_workload_separation(self):
        a=self.build('a',workload='one');b=self.build('b',workload='two')
        result=C.summarize_reports([a,b])
        self.assertEqual(set(result['workloads']),{'one','two'})
        self.assertEqual(result['workloads']['one']['base']['profile']['samples'],600)

    def test_same_workload_with_changed_arguments_is_rejected(self):
        a=self.build('a');b=self.build('b',argument='different')
        with self.assertRaisesRegex(ValueError,'different source/arguments'):
            C.summarize_reports([a,b])

    def test_same_identity_pools_across_reports(self):
        a=self.build('a');b=self.build('b')
        result=C.summarize_reports([a,b])
        self.assertEqual(result['workloads']['work']['base']['profile']['samples'],1200)

    def test_same_workload_with_different_source_is_rejected(self):
        different=self.root/'other.bend';different.write_text('another source')
        a=self.build('a');b=self.build('b',source=different)
        with self.assertRaisesRegex(ValueError,'different source/arguments'):
            C.summarize_reports([a,b])

    def test_diagnostic_profile_needs_explicit_clean_baseline(self):
        path=self.build('d',variant='diagnostic',diagnostic=True)
        profile=C.summarize_reports([path])['workloads']['work']['diagnostic']['profile']
        self.assertTrue(profile['adequate'])
        self.assertFalse(profile['estimateAvailable'])

    def test_clean_comparison_and_explicit_diagnostic_baseline(self):
        a=self.build('a',variant='base',clean_cpu=2)
        b=self.build('b',variant='candidate',clean_cpu=3)
        d=self.build('d',variant='diagnostic',diagnostic=True,clean_cpu=4)
        result=C.summarize_reports([a,b,d],reference='base',baseline_variants={'diagnostic':'candidate'})
        comparison=next(r for r in result['comparisons'] if r['variant']=='candidate')
        self.assertEqual(comparison['cleanRatios']['cpuSeconds'],1.5)
        diag=result['workloads']['work']['diagnostic']
        self.assertEqual(diag['clean']['cpuSeconds']['count'],0)
        self.assertEqual(diag['profile']['cleanCpuSeconds'],3)
        self.assertEqual(diag['diagnosticOverCleanWallRatio'],4/3)

    def test_repeated_report_is_not_double_counted(self):
        a=self.build('a')
        with self.assertRaisesRegex(ValueError,'Duplicate run report'):C.summarize_reports([a,a])

    def test_context_only_and_counter_overheads_are_not_pooled(self):
        a=self.build('a',variant='base',clean_cpu=2)
        d=self.build('d',variant='diagnostic',diagnostic=True,clean_cpu=4)
        document=json.loads(d.read_text()); row=copy.deepcopy(document['rows'][0])
        row.update(mode='events',wallSeconds=8,cpuSeconds=8)
        events=d.with_name('events.json');events.write_text(json.dumps(dict(
            schema='bend-native-dispatch-events-v1',complete=True,counts_enabled=True,
            counter_overflow=False,invalid_context_events=0,counter_names=['calls'],
            rows=[dict(fid=0,counts=[3])])))
        row['events']=C.pin(events);document['rows'].append(row);d.write_text(json.dumps(document))
        diag=C.summarize_reports([a,d],baseline_variants={'diagnostic':'base'})['workloads']['work']['diagnostic']
        self.assertEqual(diag['contextOnlyOverCleanWallRatio'],2)
        self.assertEqual(diag['countersOverCleanWallRatio'],4)
        self.assertIsNone(diag['diagnosticOverCleanWallRatio'])
        self.assertEqual(diag['diagnosticUnsampled']['wallSeconds']['count'],0)

    def test_changed_analysis_is_rejected(self):
        a=self.build('a');r=json.loads(a.read_text());path=Path(r['rows'][1]['analysis']['file'])
        path.write_text(path.read_text()+' ')
        with self.assertRaisesRegex(ValueError,'Changed evidence'):C.summarize_reports([a])


if __name__=='__main__':unittest.main()
