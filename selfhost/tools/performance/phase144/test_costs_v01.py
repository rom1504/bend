"""Metadata-only denominator and classification checks; no compiler execution."""
import importlib.util
from pathlib import Path
import unittest

spec=importlib.util.spec_from_file_location('costs',Path(__file__).with_name('costs-v01.py'))
costs=importlib.util.module_from_spec(spec)
spec.loader.exec_module(costs)

def row(name,start,end,status='passed'):
    return dict(path=name,category='checks',status=status,start=start,end=end,
                seconds=None if end is None else end-start,resourceStop=False,
                peakTreeRssBytes=None,minimumAvailableBytes=None)

class Costs(unittest.TestCase):
    def test_nested_is_summed_but_union_once(self):
        result=costs.summarize([row('outer',0,10),row('inner',2,6)])
        self.assertEqual(result['summedGuardSeconds'],14)
        self.assertEqual(result['guardIntervalUnion']['seconds'],10)
        self.assertEqual(result['nestedIntervals'],[dict(receipt='inner',inside='outer')])

    def test_parallel_partial_overlap(self):
        result=costs.summarize([row('a',0,5),row('b',3,8),row('c',10,11)])
        self.assertEqual(result['summedGuardSeconds'],11)
        self.assertEqual(result['guardIntervalUnion']['seconds'],9)
        self.assertEqual(result['timeOutsideClosedGuardUnionWithinSpanSeconds'],2)

    def test_pending_has_no_invented_duration(self):
        result=costs.summarize([row('open',2,None,'pendingOrUnclosed')])
        self.assertEqual(result['pending'],1)
        self.assertEqual(result['closed'],0)
        self.assertEqual(result['categories']['checks']['pending'],1)

    def test_expected_rejection_is_not_failed_experiment(self):
        result=costs.summarize([row('negative',0,1,'expectedNegative'),row('failure',2,5,'failed')])
        self.assertEqual(result['failedGuardSeconds'],3)
        self.assertEqual(result['nonzeroOrFailedGuardSeconds'],4)
        self.assertEqual(result['expectedNegativeSeconds'],1)

    def test_unknown_not_implicitly_timing(self):
        self.assertEqual(costs.category('other/process.json',['other'])[0],'unknown')

    def test_category_not_guard_suffix_dependent(self):
        self.assertEqual(costs.category('native-profile-acquire-guard01/process.json',['native-build'])[0],'acquisition')
        self.assertEqual(costs.category('integrated-stages01/capture-guard/process.json',['selfhost/tools/profiler/run.py'])[0],'profile')
        self.assertEqual(costs.category('p144-final03-n2-focused19/process.json',['other'])[0],'nativeQualification')

if __name__=='__main__':unittest.main()
