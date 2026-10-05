#!/usr/bin/env python3
"""Reuse the frozen interval-union method with Phase53 paths and lineage."""
import hashlib,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
PARENT=HERE.parent/'phase52/time-use-v1.py'
source=PARENT.read_text()
assert hashlib.sha256(PARENT.read_bytes()).hexdigest()=='74f1435846cdd22f71dd7b8b2d5bbbbdbcc872ce3886fe583359099f16fe8520'
for old,new in [('build/phase52','build/phase53'),('phase52-top-level-supervisor-time','phase53-top-level-supervisor-time'),("file.startswith('smoke-direct')","file.startswith('smoke-')")]:
 assert source.count(old)==1;source=source.replace(old,new)
old='inputs.extend([identity(__file__),identity(PARENT),identity(PREVIOUS)])'
assert source.count(old)==1
source=source.replace(old,"inputs.extend([identity(__file__),identity(PARENT),identity(PREVIOUS),identity(HERE.parent/'phase52/time-use-v1.py')])")
exec(compile(source,str(PARENT),'exec'),dict(__name__='__main__',__file__=str(Path(__file__).resolve())))
