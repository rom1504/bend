"""Use the exact Phase201 independent ELF oracle and balanced runtime procedure."""
import argparse,importlib.util
from pathlib import Path
import sys
from prepare import ROOT
p=ROOT/'research/phase201/elf';sys.path.insert(0,str(p));s=importlib.util.spec_from_file_location('phase201_elf_screen',p/'screen.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
a=argparse.ArgumentParser();a.add_argument('--out',type=Path,required=True);a.add_argument('--fixture',type=Path,required=True);v=a.parse_args();m.FIXTURE=v.fixture.resolve();m.run(v.out)
