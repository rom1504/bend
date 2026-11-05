#!/usr/bin/env python3
"""Source-only extraction for the tested observer-first API and its baseline."""
import argparse,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser();p.add_argument('--out',required=True);a=p.parse_args()
modules=['phase163/direct-first','phase163/direct-optimize','phase164/hybrid-adapter','phase164/hybrid-lower',*[f'phase167/demand-{x}'for x in ['model','lower','verify','emit','controls','live','plain','single','observers']]]
exports=['p86_prepare','p88_cache_prepare','p86_plan','p167e_controls','p167ob_controls','p167ob_plan','p167ob_request','p167plainlive_plan','p134e_plan','p134e_begin','p134e_next']
cmd=[sys.executable,'-B','experiments/phase163/tools/prepare.py']
for x in modules:cmd+=['--module','selfhost/tests/'+x+'.bend']
for x in exports:cmd+=['--export',x]
cmd+=['--out',a.out]
raise SystemExit(subprocess.call(cmd,cwd=ROOT))
