#!/usr/bin/env python3
"""Phase58 bindings for the unchanged full45 median/weight/flag/plot method."""
import hashlib,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
TOOLS=HERE.parents[1]
PARENT=TOOLS/'phase52/aggregate.py'
source=PARENT.read_text()
assert hashlib.sha256(PARENT.read_bytes()).hexdigest()=='ca43c17e30d740590b9aaae607eb9a5c579911e7fb50ff9ebb1b17e390c5bf90'
def replace(old,new,count=1):
 global source
 assert source.count(old)==count,(old,source.count(old));source=source.replace(old,new)
replace("PROGRAMS = HERE.parent / 'programs'", "PROGRAMS = HERE.parents[1] / 'programs'")
replace("default=HERE.parent / 'phase37/catalog.json'", "default=HERE.parents[1] / 'phase37/catalog.json'")
replace("    p.add_argument('--smoke', type=Path, required=True)", "    p.add_argument('--smoke', type=Path, required=True)\n    p.add_argument('--comparison', type=Path, required=True)")
replace("    catalog, profile = read(a.catalog), read(HERE / 'profiles.json')", """    keep(HERE.parents[1] / 'phase52/aggregate.py')
    phase53_method = HERE.parents[1] / 'phase53/aggregate.py'
    assert keep(phase53_method)['sha256'] == '7aa51222d09ae27ab133303f36d5162dde1c4a07a5c8157dea8ffafc738c5ff0'
    profile_file = HERE.parents[1] / 'phase52/profiles.json'
    assert keep(profile_file)['sha256'] == 'd7f373d1e4861f7a6f4dc3cc57c04ce5e9bd2fe4ce8af6f9e9893a8f907e558a'
    catalog, profile = read(a.catalog), read(profile_file)
    comparison = read(a.comparison)
    assert comparison['kind'] == 'phase58-performance-retention' and comparison['complete']
    assert comparison['dataOnly'] and comparison['targetExecuted'] is False and comparison['inputsUnchanged']
    assert comparison['timingScope'] == 'full'
    assert len(comparison['selectedTimingIds']) == len(set(comparison['selectedTimingIds'])) == 45
    assert set(comparison['selectedTimingIds']) == set(catalog['sets']['full'])
    comparison_inputs = [pointer(row) for row in comparison['inputs']]
    producer = keep(HERE / 'compare.py')
    assert producer['sha256'] == '3ba8926f642a2df5afbfd705e96b38dc51a0a307d3b606c81f5e76609d5bb294' and producer in comparison_inputs
    assert pointer(comparison['candidate']) == keep(a.candidate)
    assert pointer(comparison['timingBaseline']) == keep(a.baseline)
    timing_commands = read(a.comparison.parent / 'timing-commands.json')
    assert timing_commands['executed'] is False and timing_commands['timingScope'] == 'full'
    assert timing_commands['selectedIds'] == comparison['selectedTimingIds'] and len(timing_commands['commands']) == 3
    root = HERE.parents[4]
    historical = root / 'selfhost/build/phase56/string01-full/manifest.json'
    assert keep(historical)['sha256'] == '6fd08b9b05a7c4d3afeb1c05e34e18ca6c1f9501bfb83fe2cfbca4b76af2056c'
    assert pointer(comparison['baseline']) == keep(historical)
    for key in ['baselinePublication', 'baselineInstalledStart', 'baselinePreservedRelease']:
        pointer(comparison[key])
    assert comparison['counts']['points'] == 45 and comparison['counts']['sources'] == 23""")
replace("assert baseline['api']['sha256'] == 'c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061'", "assert baseline['api']['sha256'] == '128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea'")
replace("    compiler = bundles['candidate']['roles']['candidate']['compiler']", """    assert baseline == read(historical)['roles']['candidate']['compiler']
    assert baseline['backend'] == 'direct' and baseline['callingContract'] == 'upstream-compatible-direct-v1'
    assert baseline['directRuntime']['sha256'] == 'c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23'
    compiler = bundles['candidate']['roles']['candidate']['compiler']""")
replace("""        contract = read(file.parent / 'phase52-comparison.json')
        assert contract['complete'] and contract['passed'] and contract['callingContract'] == compiler['callingContract']
        assert pointer(contract['methodReport']) == keep(file)
        contract_inputs = [pointer(i) for i in contract['inputs']]
        assert keep(a.candidate) in contract_inputs and keep(a.baseline) in contract_inputs""", """        argv = timing_commands['commands'][index]
        def option(name):
            assert argv.count(name) == 1
            return argv[argv.index(name) + 1]
        assert Path(argv[1]).resolve() == (PROGRAMS / 'run.py').resolve()
        assert Path(option('--out')).resolve() == file.parent.resolve()
        assert Path(option('--candidate')).resolve() == a.candidate.resolve()
        assert Path(option('--baseline')).resolve() == a.baseline.resolve()
        assert Path(option('--catalog')).resolve() == a.catalog.resolve()
        assert option('--budget') == '600' and option('--cases').split(',') == comparison['selectedTimingIds'][index*15:(index+1)*15]
        report_inputs = [pointer(i) for i in report['inputs']]
        assert keep(a.candidate) in report_inputs and keep(a.baseline) in report_inputs""")
replace("assert report['plan']['selectedIds'] == profile['full45Batches'][index]", "assert report['plan']['selectedIds'] == comparison['selectedTimingIds'][index*15:(index+1)*15]")
replace("kind='phase52-completed-direct-full45-aggregate'", "kind='phase58-completed-direct-full45-aggregate'")
replace("        attempts=keep(attempt_file), reports=reports, points=45, sources=23, samples=sample_count,", "        attempts=keep(attempt_file), comparison=keep(a.comparison), batchOrder=[comparison['selectedTimingIds'][i:i+15] for i in range(0,45,15)], batchOrderScope='Actual saved comparator order, three disjoint15-point batches; not claimed to equal historical Phase52 batch order.', reports=reports, points=45, sources=23, samples=sample_count,")
replace('Phase52 direct backend:', 'Phase58 direct backend:')
replace('Phase51', 'Phase56 String01',8)
replace('new upstream-compatible direct ABI', 'same upstream-compatible direct ABI')
exec(compile(source,str(PARENT),'exec'),dict(__name__='__main__',__file__=str(Path(__file__).resolve())))
