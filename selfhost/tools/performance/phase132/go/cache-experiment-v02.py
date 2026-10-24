"""Small offline Go package-cache experiment. Run under the CPU5/RSS guard.

This is Go1.22.2 evidence, not a Bend optimizer or benchmark. The isolated cache,
source revisions, build logs, package archives and outputs are retained.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[5]
P = argparse.ArgumentParser(description=__doc__)
P.add_argument('--out', type=Path, required=True)
P.add_argument('--go', type=Path, default=Path('/home/ai/go-install/go/bin/go'))
A = P.parse_args(); OUT = A.out.resolve(); GO = A.go.resolve()
assert OUT.is_relative_to(ROOT/'selfhost/build/phase132') and not OUT.exists()
OUT.mkdir(parents=True)
for name in ('cache', 'modcache', 'tmp', 'work'): (OUT/name).mkdir()
WORK = OUT/'work'
ENV = dict(os.environ, GOCACHE=str(OUT/'cache'), GOMODCACHE=str(OUT/'modcache'),
    GOTMPDIR=str(OUT/'tmp'), GOTOOLCHAIN='local', GOPROXY='off', GOSUMDB='off',
    GOENV='off', GOWORK='off', CGO_ENABLED='0', GOMAXPROCS='1')
for key in ('GOFLAGS', 'GODEBUG', 'GOEXPERIMENT'): ENV.pop(key, None)


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def run(cmd, stem, seconds=45):
    start=time.monotonic()
    with stem.with_suffix('.stdout').open('xb') as so, stem.with_suffix('.stderr').open('xb') as se:
        child=subprocess.run(list(map(str, cmd)), cwd=WORK, env=ENV, stdout=so, stderr=se, timeout=seconds)
    result=dict(command=list(map(str, cmd)), wallSeconds=time.monotonic()-start,
        exitCode=child.returncode, stdout=pin(stem.with_suffix('.stdout')), stderr=pin(stem.with_suffix('.stderr')))
    assert child.returncode == 0, result
    return result


LEAF='''package leaf
type Record struct { Value int }
const K = 3
//go:noinline
func Value() int { return hidden() }
//go:noinline
func hidden() int { return 1 }
func Tiny() int { return 2 }
func Read(r Record) int { return r.Value }
'''
SOURCES={
    'go.mod': 'module example.invalid/p132\n\ngo 1.22\n',
    'leaf/leaf.go': LEAF,
    'side/side.go': 'package side\nfunc One() int { return 1 }\n',
    'mid/mid.go': '''package mid
import "example.invalid/p132/leaf"
func Sum() int { return leaf.Value() + leaf.Tiny() + leaf.Read(leaf.Record{Value: leaf.K}) }
''',
    'main.go': '''package main
import "example.invalid/p132/mid"
import "example.invalid/p132/side"
func main() { println(mid.Sum() + side.One()) }
'''
}
for name, text in SOURCES.items():
    path=WORK/name; path.parent.mkdir(exist_ok=True); path.write_text(text)
shutil.copyfile(__file__, OUT/'method.py')
version=run([GO,'version'],OUT/'version',5)
goroot=subprocess.check_output([str(GO),'env','GOROOT'],env=ENV,text=True).strip()
inputs=[pin(OUT/'method.py'),pin(GO)]
for name in ('VERSION','src/cmd/go/internal/work/buildid.go','src/cmd/go/internal/work/exec.go'):
    inputs.append(pin(Path(goroot)/name))
REPORT=dict(complete=False, version=version, inputs=inputs, stages=[],
    environment={k:ENV[k] for k in ('GOCACHE','GOMODCACHE','GOTMPDIR','GOTOOLCHAIN','GOPROXY','GOSUMDB','GOENV','GOWORK','CGO_ENABLED','GOMAXPROCS')},
    scope='One sequential diagnostic run per edit; no statistical speed claim, no toolchain download, no Bend changes. Go1.22.2 local behavior, released/development source research reported separately.')


def save(): (OUT/'report.json').write_text(json.dumps(REPORT,indent=2)+'\n')


save()
for label, leaf, expected in [
    ('00-cold',LEAF,7),('01-noop',LEAF,7),
    ('02-comment',LEAF+'// semantically unchanged trailing comment\n',7),
    ('03-private-body',LEAF.replace('return 1 }','return 4 }'),10),
    ('04-revert',LEAF,7),
    ('05-inline-body',LEAF.replace('return 2 }','return 8 }'),13),
    ('06-interface-constant',LEAF.replace('const K = 3','const K = 9'),13),
]:
    stage=OUT/label; stage.mkdir(); (WORK/'leaf/leaf.go').write_text(leaf)
    for name in SOURCES:
        path=stage/'source'/name;path.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(WORK/name,path)
    row=dict(name=label,source=[pin(stage/'source'/name) for name in SOURCES]);REPORT['stages'].append(row);save()
    row['build']=run([GO,'build','-x','-p=1','-trimpath','-buildvcs=false','-o',WORK/'program','.'],stage/'build')
    log=(stage/'build.stderr').read_text()
    row['compilePackages']=re.findall(r'/compile .*? -p ([^\s]+)',log)
    row['linkInvocations']=sum(bool(re.search(r'/link\s+-o\s',line)) for line in log.splitlines())
    shutil.copy2(WORK/'program',stage/'program');row['binary']=pin(stage/'program')
    row['execute']=run([stage/'program'],stage/'execute',5)
    assert (stage/'execute.stdout').read_bytes()==b''
    assert (stage/'execute.stderr').read_bytes()==f'{expected}\n'.encode()
    row['outputExact']=True
    row['list']=run([GO,'list','-export','-trimpath','-buildvcs=false','-f','{{.ImportPath}}|{{.Export}}|{{.BuildID}}','./...'],stage/'list',10)
    row['packages']=[]
    for line in (stage/'list.stdout').read_text().splitlines():
        name,archive,bid=line.split('|');stem=stage/('export-'+name.rsplit('/',1)[-1])
        run([GO,'tool','pack','p',archive,'__.PKGDEF'],stem,5)
        row['packages'].append(dict(name=name,archive=pin(archive),buildID=bid,exportData=pin(stem.with_suffix('.stdout'))))
    save()
REPORT['complete']=True
REPORT['cacheBytes']=sum(p.stat().st_size for p in (OUT/'cache').rglob('*') if p.is_file())
save()
print(json.dumps(dict(complete=True,report=str(OUT/'report.json'),stages=[dict(name=s['name'],seconds=s['build']['wallSeconds'],compiled=s['compilePackages'],links=s['linkInvocations']) for s in REPORT['stages']])))
