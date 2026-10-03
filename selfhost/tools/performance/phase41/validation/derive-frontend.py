#!/usr/bin/env python3
"""Derive the reviewed two-worker frontend successor; acquire/execute nothing."""
import argparse, hashlib, json, pathlib

ROOT = pathlib.Path(__file__).resolve().parents[5]
PARENT = ROOT/'selfhost/build/phase40/final-plan02/tools/frontend-gate.mjs'
PARENT_SHA = '8e118b47b8652425be8f7583c0b9a80721e4c000e2cd2e27bb3e2e716b59b666'
CHANGES = [
 ("const affinity=process.env.PHASE23_FRONTEND_CPU??'4,5,6,7';", "const affinity=process.env.PHASE41_FRONTEND_CPU;\nassert.ok(affinity,'Set PHASE41_FRONTEND_CPU to two approved CPUs');", 1),
 ("assert.match(affinity,/^\\d+(?:,\\d+)*$/);", "assert.match(affinity,/^\\d+(?:,\\d+)*$/);\nassert.equal(new Set(affinity.split(',')).size,2);\nassert.equal(affinity.split(',').length,2);\nassert.ok(!reuseCandidateGateArg,'Phase41 requires a fresh two-worker candidate acquisition');\nconst memAvailableKiB=Number(fs.readFileSync('/proc/meminfo','utf8').match(/^MemAvailable:\\s+(\\d+)/m)[1]);\nassert.ok(memAvailableKiB>=5120*1024,'Require 5 GiB available before two-worker launch');", 1),
 ("jobs:1,workerMode:", "jobs:2,workerMode:", 1),
 ("kind:'phase30-explicit-layout-frontend-gate'", "kind:'phase41-two-worker-explicit-layout-frontend-gate'", 1),
 ("'--jobs','1'", "'--jobs','2'", 1),
 ("r===a?4:1", "r===a?4:2", 1),
]

def identity(file):
 return {'file':str(file.resolve()),'sha256':hashlib.sha256(file.read_bytes()).hexdigest()}

def derive(parent):
 text=parent.read_text()
 assert identity(parent)['sha256']==PARENT_SHA, 'Frozen parent changed'
 for before,after,count in CHANGES:
  assert text.count(before)==count, (before,text.count(before),count)
  text=text.replace(before,after)
 return text

def main():
 ap=argparse.ArgumentParser(description=__doc__); ap.add_argument('out',type=pathlib.Path)
 args=ap.parse_args(); text=derive(PARENT); out=args.out.resolve(); out.mkdir(parents=True,exist_ok=False)
 original=out/'original-frontend-gate.mjs'; original.write_bytes(PARENT.read_bytes())
 target=out/'frontend-gate-v1.mjs'; target.write_text(text)
 report={'kind':'phase41-two-worker-frontend-derivation','complete':True,'executed':False,
 'producer':identity(pathlib.Path(__file__)),'parent':identity(PARENT),'original':identity(original),'derived':identity(target),
 'changes':[{'before':a,'after':b,'count':n} for a,b,n in CHANGES],
 'requiredOuterSupervisor':{'tool':'phase32/bounded-run.py','rssMiB':3072,'availableFloorMiB':2048,'seconds':1200,'serialScopes':True},
 'policy':'Fresh candidate only. Exact comparator, behavioral fields, paths, layout authorization, fixture/artifact hashes, all health/error assertions and 3026/196 selections are unchanged. Four reference workers remain attested historical acquisition; exactly two candidate workers are required. No timing claim.'}
 (out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps({'complete':True,'executed':False,'derived':str(target)}))

if __name__=='__main__':main()
