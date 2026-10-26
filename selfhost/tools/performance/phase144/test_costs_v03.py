"""Metadata-only denominator and classification checks; no compiler execution."""
import importlib.util
from pathlib import Path
import unittest

spec=importlib.util.spec_from_file_location('costs',Path(__file__).with_name('costs-v03.py'))
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

class LaterCampaignCosts(unittest.TestCase):
    def test_smokes_classify_under_arbitrary_guard_names(self):
        for path in ['phase144/guard01/final03-host-smokes/process.json',
                     'phase144/final03-host-smokes02-guard/process.json',
                     'phase144/final04-host-smokes01-guard/process.json']:
            self.assertEqual(costs.category(path,['python3','native/host-smokes-v01.py'])[0], 'nativeQualification')

    def test_partial_resume_recheck_are_measurement(self):
        for path in ['phase144/programs-plan04-measure-guard/process.json',
                     'phase144/programs-last-resume01-guard/process.json',
                     'phase144/programs-recheck01-guard/process.json']:
            self.assertEqual(costs.category(path,['python3','selfhost/tools/performance/phase144/programs/measure.py'])[0], 'measurement')

    def test_program_acquisition_stays_acquisition(self):
        self.assertEqual(costs.category('phase144/programs-final04-acquire01-guard/process.json', ['python3','build-aligned.py'])[0], 'acquisition')

    def test_partial_failure_plus_resume_is_fully_charged(self):
        partial=row('partial',0,400,'failed'); partial['category']='measurement'
        resumed=row('resumed',410,424); resumed['category']='measurement'
        result=costs.summarize([partial,resumed])
        self.assertEqual(result['summedGuardSeconds'],414)
        self.assertEqual(result['guardIntervalUnion']['seconds'],414)
        self.assertEqual(result['failedGuardSeconds'],400)
        self.assertEqual(result['categories']['measurement']['summedGuardSeconds'],414)

class FinalClassification(unittest.TestCase):
    def test_q3_self_reproduction(self):
        for name in ['final03','final04']:
            self.assertEqual(costs.category('phase144/p144-'+name+'-q3-guard/process.json', ['native-request.py'])[0], 'nativeQualification')

    def test_exact_native_packaging_checks_are_not_profile(self):
        path='phase144/native-profile-plan02/native-lexer-guard/process.json'
        self.assertEqual(costs.category(path,['/phase130/native-request.py','--expected-qbe','prior.ssa'])[0], 'checks')
        self.assertEqual(costs.category(path,['other'])[0], 'unknown')

    def test_explicit_latency_and_consumer_measurements(self):
        for path,command in [
            ('phase144/range-fast-native-plan01/fast-fixed142-latency-guard/process.json',['native-request.py']),
            ('phase144/range-produced-latency-plan01/request-guard/process.json',['native-request.py']),
            ('phase144/existence-source01/actual-compiler-consumers-guard/process.json',['/existence/screen-v01.mjs']),
            ('phase144/small-transfer-fast02-guard/process.json',['/emission/transport/fast-request-v01.py'])]:
            self.assertEqual(costs.category(path,command)[0], 'measurement')

    def test_concat_observer_and_small_product_acquisition(self):
        self.assertEqual(costs.category('concat-profile-observe01-guard/process.json',['/emission/string-append/profile/observe-v01.py'])[0], 'profile')
        self.assertEqual(costs.category('three-small-products-guard/process.json',['/emission/string-append/emit-v01.mjs'])[0], 'acquisition')

if __name__=='__main__':unittest.main()


