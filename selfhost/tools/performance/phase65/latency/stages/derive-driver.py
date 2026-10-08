#!/usr/bin/env python3
"""Insertion-only diagnostic copy of an exact prepared image's ordinary driver."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[6]
BOUNDARY=ROOT/'selfhost/build/phase65'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('source',type=Path);p.add_argument('output',type=Path)
p.add_argument('--expected-sha',required=True)
a=p.parse_args();source=a.source.resolve();output=a.output.resolve()
assert source.is_relative_to(BOUNDARY.resolve()) and output.is_relative_to(BOUNDARY.resolve())
assert source.parent==output.parent and source.name=='typed-driver.mjs'
assert output.name=='typed-driver-stages.mjs' and not output.exists()
receipt=output.with_suffix('.derivation.json');assert not receipt.exists()


def sha(b):return hashlib.sha256(b).hexdigest()


def identity(file):
    file=Path(file).resolve(strict=True);b=file.read_bytes()
    return dict(file=str(file),sha256=sha(b),bytes=len(b))


before=source.read_bytes();assert sha(before)==a.expected_sha
text=before.decode();assert '$p63' not in text
edits=[];skipped=[]


def insert(at,value,reason):edits.append(dict(offset=at,insert=value,reason=reason))


def unique(value):
    assert text.count(value)==1,(value[:100],text.count(value))
    return text.index(value)


def function(header,name,optional=False):
    if optional and header not in text:skipped.append(dict(header=header,name=name));return
    start=unique(header)+len(header);end=text.index('\n}\n',start)
    insert(start,'\n  const $p63Scope=$p63.begin('+json.dumps(name)+');\n  try {','function begin '+name)
    insert(end,'\n  } finally {$p63.end($p63Scope);}','function end '+name)


def statement(value,name):
    if value not in text:skipped.append(dict(statement=value,name=name));return
    at=unique(value);indent=value[:len(value)-len(value.lstrip())]
    insert(at,indent+'$p63.begin('+json.dumps(name)+');\n','call begin '+name)
    insert(at+len(value),'\n'+indent+'$p63.end('+json.dumps(name)+');','call end '+name)


insert(unique('export const driverPath='),'''// Private diagnostic worker only; no API override is passed to inspect.
const $p63=globalThis[Symbol.for('bend.phase62.stages')];
if($p63?.version!==1)throw Error('Phase63 stage clock is not installed');
const $p63Wrapped=new WeakSet();
const $p63Name=name=>name.replaceAll('_','-').toLowerCase();
function $p63WrapApi(api) {
  if($p63Wrapped.has(api))return;
  $p63Wrapped.add(api);
  for(const [name,method] of Object.entries(api)) {
    if(typeof method!=='function')continue;
    const wrapped=function(...args) {
      const token=$p63.begin('api.'+$p63Name(name));
      try {return Reflect.apply(method,this,args)} finally {$p63.end(token)}
    };
    Object.defineProperty(wrapped,'name',{value:method.name});
    Object.defineProperty(wrapped,'length',{value:method.length});
    api[name]=wrapped;
  }
}
function $p63Abi(event) {
  const prefix='abi.'+$p63Name(event.name)+'.';
  if(event.phase==='encode')$p63.begin(prefix+'encode');
  else if(event.phase==='invoke'){$p63.end(prefix+'encode');$p63.begin(prefix+'invoke');}
  else if(event.phase==='decode'){$p63.end(prefix+'invoke');$p63.begin(prefix+'decode');}
  else if(event.phase==='return')$p63.end(prefix+'decode');
}

''','clock binding and synchronous API entry/ABI phase observers')
needle='  const module=await import(url);'
insert(unique(needle)+len(needle),'\n  $p63WrapApi(module.default);','observe actual imported API without custom inspect API')
needle='onPhase:process.env.BEND_TYPED_TRACE?'
insert(unique(needle)+len('onPhase:'),'$p63?$p63Abi:','observe existing ABI adapter phases')
for header,name,optional in [
 ('async function loadApiForIdentity(identity=null) {','driver.api-load',False),
 ('export function validateSpanBook(book,ranges,termAbi=0) {','driver.span-validation',False),
 ('export function validateSpanCache(c,{compilerSha256,baseSha256,sourcePath,sourceText,termAbi=0}) {','driver.legacy-cache-validation',False),
 ('export function decodeBaseCacheFrame(bytes) {','driver.cache-decode',False),
 ('function decodeBaseCacheGraphFrame(header,payload) {','driver.cache-graph-decode',True),
 ('function validateSpanCacheFrame(c,{compilerSha256,baseSha256,sourcePath,sourceText,termAbi=0}) {','driver.cache-validation',False),
 ('function validateSpanJsonTree(book,ranges,termAbi=0) {','driver.json-tree-validation',False),
 ('function checkedPrefixStateShape(state) {','driver.checked-state-shape',False),
 ('function admitCheckedPrefixState(cached,info) {','driver.checked-state-admission',False),
 ('function admitFreshPrefixState(cached) {','driver.fresh-state-admission',False),
 ('function admitPreparedWorld(cached) {','driver.world-admission',True),
 ('function admitFrontendReadyState(cached) {','driver.frontend-state-admission',True),
 ('export function discoverSources(api,input,{seed=null,freshPrefixPermission=null,nativePrefixPermission=null}={}) {','driver.source-graph',False),
 ('function baseCacheInfo(api) {','driver.base-identity',False),
 ('function readBaseCache(info,memo=null) {','driver.base-cache',False),
 ('export async function prepareBase(api) {','driver.prepare-base',False),
 ("async function inspectWithMemo(input,{mode='check',backend,api,args=[],timeoutMs=5000,combinedOutput=false,withReport=false,proofOnly=false}={},memo=null) {",'driver.inspect',False),
 ("function foreignSources(graph,extension,required=null,api=null,book=null,scope=book,sourcePath=file=>file) {",'driver.foreign-source',False),
 ('function directForeignResolver(paths) {','driver.foreign-resolver',False),
]:function(header,name,optional)
for value,name in [
 ('    const bytes=fs.readFileSync(readFile);','driver.cache-read'),
 ("  const header=JSON.parse(bytes.subarray(0,cut).toString('utf8'));",'driver.cache-header-parse'),
 ("  const checkedHash=nc?digest(checkedBytes):null,freshHash=nf?digest(freshBytes):null;",'driver.cache-state-digests'),
 ("  if(typeof header.bookSha256!=='string'||header.bookSha256!==digest(bookBytes))throw Error('Invalid source-aware Base cache');",'driver.cache-book-digest'),
 ("  const cached={...metadata,book:JSON.parse(bookBytes.toString('utf8'))},states={};",'driver.cache-book-parse'),
 ("  if(nc&&checkedHash===header.checkedPrefixStateSha256){try{cached.checkedPrefixState=JSON.parse(checkedBytes.toString('utf8'));states.checked={value:cached.checkedPrefixState,sha256:checkedHash};}catch(error){if(!(error instanceof SyntaxError))throw error;}}",'driver.cache-checked-state-parse'),
 ("  if(nf&&freshHash===header.freshPrefixStateSha256){try{cached.freshPrefixState=JSON.parse(freshBytes.toString('utf8'));states.fresh={value:cached.freshPrefixState,sha256:freshHash};}catch(error){if(!(error instanceof SyntaxError))throw error;}}",'driver.cache-fresh-state-parse'),
 ("  if(typeof header.bookGraphSha256!=='string'||header.bookGraphSha256!==digest(bookBytes))throw Error('Invalid source-aware Base cache');",'driver.graph-book-digest'),
 ("  const book=decodeBaseGraph(bookBytes,{...options,rootKinds:['defs']});",'driver.graph-book-decode'),
 ("      const graph=decodeBaseGraph(preparedBytes,{...options,base:book,rootKinds:['checked','fresh','world','frontend']});",'driver.graph-prepared-decode'),
 ("  const book=decode(bookBytes,{...options,rootKinds:['defs']});",'driver.graph-book-decode'),
 ("      const graph=decode(preparedBytes,{...options,base:book,rootKinds:['checked','fresh','world','frontend']});",'driver.graph-prepared-decode'),
]:statement(value,name)
# Removing exactly these inserted spans restores the complete original driver.
ordered=sorted(enumerate(edits),key=lambda pair:(pair[1]['offset'],pair[0]))
parts=[];cursor=0;output_cursor=0
for _,edit in ordered:
    piece=text[cursor:edit['offset']];parts.append(piece);output_cursor+=len(piece)
    edit['outputOffset']=output_cursor;parts.append(edit['insert']);output_cursor+=len(edit['insert']);cursor=edit['offset']
parts.append(text[cursor:]);derived=''.join(parts);restored=derived
for _,edit in reversed(ordered):
    at=edit['outputOffset'];assert restored[at:at+len(edit['insert'])]==edit['insert']
    restored=restored[:at]+restored[at+len(edit['insert']):]
assert restored.encode()==before and source.read_bytes()==before
result=dict(kind='phase62-private-driver-stage-derivation',complete=True,**{'pass':True},
    dataOnly=True,targetExecuted=False,diagnosticOnly=True,productionQualified=False,
    source=identity(source),output=dict(file=str(output),sha256=sha(derived.encode()),bytes=len(derived.encode())),
    producer=identity(__file__),clock=identity(Path(__file__).with_name('clock.mjs')),
    exactInverse=True,offsetUnit='Unicode code points',edits=edits,optionalBoundariesAbsent=skipped,
    scope='Private fresh worker only. Original statements/arguments/returns retained; synchronous '
          'function clocks and imported default API entry observers preserve call return values. '
          'No custom API passed into inspect, preserving owned prefix/world/plan paths. Existing '
          'ABI onPhase hook separates encode/invoke/decode if the image uses it. Nested exclusive '
          'wall intervals include instrumentation overhead; not clean latency or isolated attribution.')
with output.open('x') as stream:stream.write(derived)
with receipt.open('x') as stream:stream.write(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(output=result['output'],receipt=identity(receipt),insertions=len(edits))))
