#!/usr/bin/env python3
"""Append diagnostic Bend queries to qualified Phase134; no source overrides."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
METHOD=ROOT/'selfhost/tools/performance/phase131/prepare.py'
spec=importlib.util.spec_from_file_location('compose_source',METHOD);C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();out=a.out.resolve()
 assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase136')
 authority=ROOT/'implementation/phase134/final/candidate.json';parent=json.loads(authority.read_text())
 assert parent['complete'] and parent['nativeQualified'] and C.pin(parent['source']['file'])==parent['source']
 module=Path(__file__).parent/'query-counts-v01.bend';original=Path(parent['source']['file']).read_text()
 text,added,protected=C.compose(original,[module.read_text()],set(),set())
 old,new=C.blocks(original),C.blocks(text)
 assert all(C.norm(new[n])==C.norm(v)for n,v in old.items())
 out.mkdir(parents=True);(out/'compiler.bend').write_text(text);(out/'module0.bend').write_bytes(module.read_bytes());(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
 exports=['p88_cache_prepare','p86_plan','p136q_controls','p136q_prefix','p136q_queries','p136q_zero','p136q_raw','p136q_ctor_names','p136q_take_names','p136q_find','p136q_lookup','p136q_owned','p136q_one']
 report=dict(complete=True,checked=False,targetsRun=False,source=C.pin(out/'compiler.bend'),parent=parent['source'],overrides=[],added=added,protectedDeclarations=protected,exports=exports,
  inputs=[C.pin(__file__),C.pin(METHOD),C.pin(module),C.pin(authority),parent['source']],
  scope='Append-only logical visit counters and exact original-query checks; all selected compiler declarations unchanged. Not a speed optimization, dynamic whole-request profile, or checked candidate until the independent API gate passes.')
 (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report['source']))
if __name__=='__main__':main()
