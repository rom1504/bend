import argparse
from pathlib import Path
import subprocess
from projection import HERE,BUILD,read
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
out=p.parse_args().out
out.mkdir(parents=True)
binding=read(BUILD/'phase195/ctor-gate-emission-plan01.json')['producer']['bindingValue']
subprocess.run([binding['engine']['file'], HERE/'inspect.mjs',out],check=True,timeout=25)
