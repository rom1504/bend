"""Freeze a mixed found/missing discriminator; no target execution."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('prepare_read',HERE/'prepare-read-proxy.py')
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
spec=importlib.util.spec_from_file_location('oracle',HERE/'missing-timing-oracle.py')
O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)

def main():
    base=HERE/'read-proxy-candidate.bend';workload=HERE/'missing-mixed-workload.bend';change=HERE/'missing-static-v01.bend'
    original=base.read_text()
    # Full list is generated from names of checked compiler declarations, whose
    # syntax excludes the :missing: prefix. Check the frozen source too.
    assert ':missing:' not in original
    common=S.replace(original,S.declarations(workload.read_text()),['p131ip_once','p131ip_execute'])
    candidate=S.replace(common,S.declarations(change.read_text()),['missing'])
    expected=S.write('missing-mixed-expected.json',json.dumps(dict(stdout=O.ordinary_stdout()),indent=2)+'\n')
    rows=[]
    for name,source in [('original',common),('candidate',candidate)]:
        src=S.write('missing-mixed-'+name+'.bend',source)
        rows.append(dict(name='identity-missing-'+name,source=src,expected=expected,expectedStdoutEvidence=expected))
    S.write('missing-mixed-cases.json',json.dumps(dict(complete=True,cases=rows),indent=2)+'\n')
    S.write('missing-mixed-manifest.json',json.dumps(dict(complete=True,targetsRun=False,
        inputs=[S.pin(Path(__file__)),S.pin(HERE/'prepare-read-proxy.py'),S.pin(base),S.pin(workload),S.pin(change),S.pin(HERE/'missing-timing-oracle.py'),expected],
        cases=rows,overrides=['missing'],identityOracle=S.pin(HERE/'missing-timing-oracle.py'),
        scope='Same256actual compiler names and immutable constructed index. Alternate one present lookup and one guaranteed-absent lookup per name. Construct index and strings outside IO.now; exact independent U32 checksum. Only expose the closed missing sentinel to the existing verified static-data preparation.'),indent=2)+'\n')

if __name__=='__main__':main()
