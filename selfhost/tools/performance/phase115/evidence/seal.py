#!/usr/bin/env python3
"""Scope the unchanged Phase112 bounded evidence gate to Phase115."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
BINDING=HERE/'gate-binding01.json'
EVIDENCE=ROOT/'implementation/phase115/evidence'


def load_gate():
    binding=json.loads(BINDING.read_text())
    expected=binding['gate'];path=ROOT/expected['file'];raw=path.read_bytes()
    if len(raw)!=expected['bytes'] or hashlib.sha256(raw).hexdigest()!=expected['sha256']:
        raise ValueError('Frozen Phase112 gate changed; explicit adapter review required')
    spec=importlib.util.spec_from_file_location('phase115_original_evidence_gate',path)
    gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate)
    gate.EVIDENCE=EVIDENCE
    original_files=gate.files
    redirects={ROOT/'selfhost/tools/performance/phase112':ROOT/'selfhost/tools/performance/phase115',
               ROOT/'implementation/phase112':ROOT/'implementation/phase115'}
    # These are data-scope hooks only. Classification, capture, limits, content
    # addressing, frozen-input checks and archive verification remain original.
    gate.files=lambda directory: original_files(redirects.get(directory,directory))
    def scopes():
        roots=[ROOT/'selfhost/build/phase115']
        for phase in ['phase111','phase112','phase113']:
            roots += sorted(path for path in (ROOT/'selfhost/build'/phase).glob('p115-*')
                            if path.is_dir() or path.is_symlink())
        return roots
    gate.scopes=scopes
    return gate,binding


def code_files(gate):
    roots=[ROOT/'selfhost/tools/performance/phase115',ROOT/'implementation/phase115']
    paths={path for root in roots for path in gate.files(root) if path.suffix in gate.SOURCE or path.suffix=='.json'}
    paths.add(EVIDENCE/'README.md')
    return sorted(paths)


def inventory(gate):
    paths={path for root in gate.scopes() for path in gate.files(root)}
    paths.update(code_files(gate))
    return sorted(str(path.relative_to(ROOT)) for path in paths)


def assert_idle():
    for proc in Path('/proc').iterdir():
        if not proc.name.isdecimal() or int(proc.name)==os.getpid():continue
        try:words=(proc/'cmdline').read_bytes().split(b'\0')
        except OSError:continue
        if any(word.endswith(b'/guard.py') and b'performance/' in word for word in words):
            raise RuntimeError('Performance guard still running; wait before planning/sealing: PID '+proc.name)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    commands=parser.add_subparsers(dest='command',required=True)
    prep=commands.add_parser('plan');prep.add_argument('--out',type=Path,required=True)
    seal=commands.add_parser('seal');seal.add_argument('--plan',type=Path,required=True);seal.add_argument('--out',type=Path,required=True)
    a=parser.parse_args();gate,binding=load_gate()
    # Hold the actual target lock, rather than assuming that a completed receipt
    # proves no new guard started. This tool must run outside a target guard.
    with (ROOT/'selfhost/build/phase32/execution.lock').open('a') as lock:
        try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError:raise RuntimeError('Targets still own the serial execution lock; evidence must wait')
        assert_idle()
        if a.command=='plan':
            output=gate.fresh(a.out)
            before=inventory(gate)
            plan=gate.build_plan()
            entries={row['file']:row for row in plan['files']}
            # JSON configuration/method inventories are identity-only here.
            # Build-scope JSON remains subject to the original receipt policy.
            for path in code_files(gate):
                row=gate.pin(gate.checked(path))
                entries.setdefault(row['file'],dict(**row,payload=False,reason='current Phase115 source/document/config identity only; no payload'))
            plan['files']=sorted(entries.values(),key=lambda row:row['file'])
            after=inventory(gate)
            if before!=after:raise ValueError('Scoped paths changed while planning; wait for edits to finish')
            plan['adapter']=dict(kind='phase115-evidence-scope-adapter',version=1,
                method=gate.pin(Path(__file__).resolve()),binding=gate.pin(BINDING),
                gate=plan['method'],evidenceDirectory=str(EVIDENCE.relative_to(ROOT)),
                sourceRootRedirects=binding['sourceRootRedirects'],inventory=after,
                scope='Actual Phase115 build receipts and p115-* directories in phases111/112/113. Original Phase112 schema/kind labels and bounded capture/verification gate are retained unchanged. Current Phase115 code/config pins are separate from historical run pins. No qualification, timing aggregate or deletion authority is inferred.')
            output.write_bytes(gate.encoded(plan))
            print(json.dumps(dict(complete=True,targetsRun=False,plan=gate.pin(output),
                phase='phase115',files=len(plan['files']),uniquePayloadBytes=plan['uniquePayloadBytes'])))
        else:
            plan_path=gate.checked(a.plan);plan=json.loads(plan_path.read_text());adapter=plan.get('adapter',{})
            if (adapter.get('kind')!='phase115-evidence-scope-adapter' or
                adapter.get('method')!=gate.pin(Path(__file__).resolve()) or adapter.get('binding')!=gate.pin(BINDING) or
                adapter.get('gate')!=binding['gate'] or adapter.get('evidenceDirectory')!=str(EVIDENCE.relative_to(ROOT))):
                raise ValueError('Matching frozen Phase115 adapter, binding and gate required')
            if plan['roots']!=[str(path.relative_to(ROOT)) for path in gate.scopes()] or adapter['inventory']!=inventory(gate):
                raise ValueError('Scoped files changed since plan; prepare a fresh reviewed plan')
            gate.seal(plan_path,gate.fresh(a.out))


if __name__=='__main__':main()
