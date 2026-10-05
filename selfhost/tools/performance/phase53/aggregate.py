#!/usr/bin/env python3
"""Metadata-only adapter of the frozen Phase52 full45 aggregation method."""
import hashlib, sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
PARENT=HERE.parent/'phase52/aggregate.py'
source=PARENT.read_text()
assert hashlib.sha256(PARENT.read_bytes()).hexdigest()=='ca43c17e30d740590b9aaae607eb9a5c579911e7fb50ff9ebb1b17e390c5bf90'
def replace(old,new,count):
 global source
 assert source.count(old)==count,(old,source.count(old));source=source.replace(old,new)
replace('c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061','472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a',1)
replace('phase52-comparison.json','phase53-comparison.json',1)
replace('phase52-completed-direct-full45-aggregate','phase53-completed-direct-full45-aggregate',1)
replace('Phase52 direct backend:','Phase53 direct backend:',1)
replace('Phase51','Prior direct06',8)
replace('new upstream-compatible direct ABI','same upstream-compatible direct ABI',1)
replace("    catalog, profile = read(a.catalog), read(HERE / 'profiles.json')","    keep(HERE.parent / 'phase52/aggregate.py')\n    catalog, profile = read(a.catalog), read(HERE / 'profiles.json')\n    prior_profile = HERE.parent / 'phase52/profiles.json'\n    assert keep(prior_profile)['sha256'] == 'd7f373d1e4861f7a6f4dc3cc57c04ce5e9bd2fe4ce8af6f9e9893a8f907e558a'\n    assert profile['full45Batches'] == read(prior_profile)['full45Batches']",1)
replace("    compiler = bundles['candidate']['roles']['candidate']['compiler']", "    historical = HERE.parent / 'phase52/bundles/current/manifest.json'\n    assert keep(historical)['sha256'] == 'cb084a94c3ff1db33d6de1bd1f30c0d009beed609ad72496ef8d52c3247cb005'\n    assert baseline == read(historical)['roles']['candidate']['compiler']\n    assert baseline['backend'] == 'direct' and baseline['callingContract'] == 'upstream-compatible-direct-v1'\n    assert baseline['directRuntime']['sha256'] == '417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a'\n    compiler = bundles['candidate']['roles']['candidate']['compiler']",1)
exec(compile(source,str(PARENT),'exec'),dict(__name__='__main__',__file__=str(Path(__file__).resolve())))
