#!/usr/bin/env python3
"""Offline compiler-only source derivative for a checked native-host experiment.

This rewrites names in an already assembled compiler. It never rewrites imported
Base or user input and never implements equality in the host tool.
"""
import collections, hashlib, json, re, sys
from pathlib import Path

assert len(sys.argv)==3, 'Usage: native-assembly.py FROZEN_COMPILER.bend NEW_NATIVE_COMPILER.bend'
source,out=map(Path,sys.argv[1:]); here=Path(__file__).resolve().parent
root=here.parents[4]; manifest=root/'selfhost/src/compiler.json'
modules=set(json.loads(manifest.read_text())['modules'])
text=source.read_text(); assert text.startswith('import Base\n\n# Generated source assembly.')
assert 'def p88_string_eq(' not in text and 'law p88_string_eq:' not in text
assert 'def String.eq(' not in text, 'Input must not embed or replace Base'
helpers=here/'helpers.bend'; counts=collections.Counter(); current=None; seen=set()
# Strings, chars and comments are transported byte-for-byte. Only exact Bend
# identifier tokens in active compiler-manifest sections are candidates.
token=re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*|[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*')
def replace(match):
    global current
    marker=re.fullmatch(r'# Module: (.*):(\d+)',match[0])
    if marker:
        current=marker[1]
        if current in modules:seen.add(current)
    if current in modules and match[0]=='String.eq':
        counts[current]+=1
        return 'p88_string_eq'
    return match[0]
rewritten=token.sub(replace,text)
assert seen==modules, ('Input does not contain the exact active module set',sorted(modules-seen))
assert sum(counts.values())>0
prefix='import Base\n\n'
assert rewritten.startswith(prefix)
result=prefix+'# Phase88 native-host-only consuming string helpers.\n'+helpers.read_text()+'\n'+rewritten[len(prefix):]
with out.open('x') as f:f.write(result)
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
report=dict(kind='phase88-native-host-consuming-equality-assembly',complete=True,
            compilerModules=len(modules),rewrittenIdentifiers=sum(counts.values()),perModule=dict(sorted(counts.items())),
            inputs=[pin(source),pin(manifest),pin(helpers),pin(Path(__file__))],output=pin(out),
            scope='Only exact String.eq identifiers outside literals/comments in active compiler-owned module sections; '
                  'entry, imported Base, compiler input Base/user sources and all other source bytes retained. '
                  'Whole resulting Bend source must still be fully checked before C emission. '
                  'Native-host experimental derivative; ordinary JS source/primitive equality guard unchanged.')
with Path(str(out)+'.derivation.json').open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(output=str(out),rewrittenIdentifiers=sum(counts.values()),modules=len(counts))))
