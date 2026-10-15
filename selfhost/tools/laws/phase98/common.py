"""Small Phase98 evidence helpers; guarded target processes remain serial."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT/'selfhost/build/phase98'
GUARD = ROOT/'selfhost/tools/performance/phase86/guard.py'
CLANG = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')


def pin(file):
    file=Path(file).resolve(); h=hashlib.sha256()
    with file.open('rb') as f:
        for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
    return dict(file=str(file),bytes=file.stat().st_size,sha256=h.hexdigest())


def save(file,data):file.write_text(json.dumps(data,indent=2)+'\n')


def read(file):return json.loads(Path(file).read_text())


def verify(item):assert pin(item['file'])==item,item['file']


def run(folder,argv,seconds=60,rss=2048):
    assert folder.resolve().is_relative_to(BUILD) and not folder.exists()
    command=[sys.executable,'-B',str(GUARD),'--out',str(folder),'--seconds',str(seconds),
             '--rss-mib',str(rss),'--available-mib','4096','--cpu','3','--',*map(str,argv)]
    process=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
    folder.mkdir(parents=True,exist_ok=True)
    (folder/'wrapper.stdout').write_text(process.stdout);(folder/'wrapper.stderr').write_text(process.stderr)
    receipt=read(folder/'process.json')
    return dict(receipt=pin(folder/'process.json'),process=receipt,
                stdout=(folder/'stdout.log').read_text(),stderr=(folder/'stderr.log').read_text())


def passed(row):
    return row['process'].get('complete') and row['process']['returncode']==0 and not row['process'].get('stoppedFor')
