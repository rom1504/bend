#!/usr/bin/env python3
"""Insert diagnostic clocks into an exact private copy, without target execution."""
import argparse, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
BOUNDARY=ROOT/'selfhost/build/phase60'
EXPECTED='eb4bb871371fb2fb61fa1c077d093a817a1f6ae35205ebb2beecfb6e064fc417'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('source',type=Path,help='Already staged, byte-identical ordinary typed-driver.mjs')
p.add_argument('output',type=Path,help='Fresh adjacent typed-driver-stages.mjs')
a=p.parse_args();source=a.source.resolve();output=a.output.resolve()
assert source.is_relative_to(BOUNDARY.resolve()) and output.is_relative_to(BOUNDARY.resolve())
assert source.parent==output.parent and source.name=='typed-driver.mjs'
assert output.name=='typed-driver-stages.mjs' and not output.exists()
receipt=output.with_suffix('.derivation.json');assert not receipt.exists()
def sha(b):return hashlib.sha256(b).hexdigest()
def identity(p):
 b=p.read_bytes();return {'file':str(p.resolve()),'sha256':sha(b),'bytes':len(b)}
before=source.read_bytes();assert sha(before)==EXPECTED
text=before.decode();assert '$p59' not in text
edits=[]
def insert(at,value,reason):edits.append({'offset':at,'insert':value,'reason':reason})
def unique(value):
 assert text.count(value)==1,(value[:100],text.count(value))
 return text.index(value)
def function(header,name):
 start=unique(header)+len(header);end=text.index('\n}\n',start)
 insert(start,'\n  const $p59Scope=$p59.begin('+json.dumps(name)+');\n  try {','function begin '+name)
 insert(end,'\n  } finally {$p59.end($p59Scope);}','function end '+name)
def statement(value,name):
 at=unique(value);indent=value[:len(value)-len(value.lstrip())]
 insert(at,indent+'$p59.begin('+json.dumps(name)+');\n','call begin '+name)
 insert(at+len(value),'\n'+indent+'$p59.end('+json.dumps(name)+');','call end '+name)
insert(unique('export const driverPath='),'''// Private diagnostic copy: the worker installs a clock before import.
const $p59=globalThis[Symbol.for('bend.phase59.stages')];
if($p59?.version!==1)throw Error('Phase59 stage clock is not installed');

''','clock binding')
for header,name in [
 ('async function loadApiForIdentity(identity=null) {','driver.api-load'),
 ('export function validateSpanBook(book,ranges,termAbi=0) {','driver.span-validation'),
 ('export function validateSpanCache(c,{compilerSha256,baseSha256,sourcePath,sourceText,termAbi=0}) {','driver.cache-validation'),
 ('export function discoverSources(api,input,{seed=null}={}) {','driver.source-graph'),
 ('function baseCacheInfo(api) {','driver.base-identity'),
 ('function readBaseCache(info,memo=null) {','driver.base-cache'),
 ('export async function prepareBase(api) {','driver.prepare-base'),
 ("async function inspectWithMemo(input,{mode='check',backend,api,args=[],timeoutMs=5000,combinedOutput=false,withReport=false,proofOnly=false}={},memo=null) {",'driver.inspect'),
 ("function foreignSources(graph,extension,required=null,api=null,book=null,scope=book,sourcePath=file=>file) {",'driver.foreign-source'),
 ('function directForeignResolver(paths) {','driver.foreign-resolver'),
]:function(header,name)
for value,name in [
 ('    const header=!seeded?api.f_source_header(raw):null;','compiler.source-header'),
 ('      const result=seeded?api.f_complete_seed(raw,completed,seed.sourcePath,seed.sourceText,seed.book):api.f_complete_source(raw,ns,header,supplied,completed,root);','compiler.source-completion'),
 ('''    const checkedResult=checkAbi===2?api.check_program_diagnostic(loaded.book,cached?cached.book:list([]),list([])):checkAbi===1?
      (cached?api.check_book_diagnostic_from_exact_prefix(loaded.book,cached.book,list([])):api.check_book_diagnostic(loaded.book,list([]))):null;''','compiler.check-and-complete'),
 ("    const emitOwned=api.driver_emit_owned?api.driver_emit_owned(book):'';",'compiler.owned-layout'),
 ("    const contextBook=mode!=='native'&&api.book_context?api.book_context(book):book;",'compiler.context'),
 ('''    const roots=backend==='direct'?api.jd_roots(contextBook,mode==='library'):api.j_roots?.(contextBook,mode==='library');
    const stops=mode!=='native'?(backend==='direct'?api.jd_stops?.(contextBook):api.j_stops?.(contextBook)):null;''','compiler.roots-and-stops'),
 ('      book=api.reach_book(contextBook,roots,stops);','compiler.source-reach'),
 ('''    let layoutDefs,layoutStops;
    if(mode==='native'&&api.nc_annotation_stops&&api.nc_annotated_context&&api.reach_book&&api.annotate_selected) {
      const stops=api.nc_annotation_stops(contextBook);
      const selected=api.reach_book(contextBook,list(['main']),stops);
      layoutDefs=api.annotate_selected(contextBook,selected,stops);layoutStops=stops;
      book=api.nc_annotated_context(contextBook,layoutDefs);
    } else book=selectedEmission?api.annotate_selected(contextBook,book,stops):api.annotate_book(book);''','compiler.annotation'),
 ('''      const reachable=api.jd_reach_selected(contextBook,book,roots);
      const error=api.jd_reach_error(reachable);
      if(error)throw Error(error);
      book=api.jd_reach_defs(reachable);''','compiler.emitted-reach'),
 ('      const foreign=api.jd_foreign_error(book);','compiler.foreign-check'),
 ('      const error=api.j_layout_error(contextBook,layoutDefs||book,roots,layoutStops||stops);','compiler.layout-proof'),
 ("    const jsPaths=backend==='direct'?array(api.jd_foreign_paths(book)):api.j_foreign_paths?array(api.j_foreign_paths(book)):null;",'compiler.foreign-paths'),
 ("      const modules=api.jd_modules(book,foreignSources(graph,'.js',jsPaths,api,contextBook,book,foreign.resolve));",'compiler.foreign-modules'),
 ("      const emitted=mode==='library'?api.jd_library_selected(contextBook,book):api.jd_program_selected(contextBook,book);",'compiler.library'),
 ('''      const host=mode!=='library'||jsPaths.length?'import {createRequire as $jdCreateRequire} from "node:module";\\nconst require=$jdCreateRequire(import.meta.url);\\n':'';
      const code=host+fs.readFileSync(directRuntimePath,'utf8')+'\\n'+modules+'\\n'+emitted;''','driver.output-assembly'),
]:statement(value,name)
# Only insertions: recover the complete original bytes in the recorded inverse.
ordered=sorted(enumerate(edits),key=lambda pair:(pair[1]['offset'],pair[0]))
parts=[];cursor=0;output_cursor=0
for _,edit in ordered:
 piece=text[cursor:edit['offset']];parts.append(piece);output_cursor+=len(piece)
 edit['outputOffset']=output_cursor;parts.append(edit['insert']);output_cursor+=len(edit['insert']);cursor=edit['offset']
parts.append(text[cursor:]);derived=''.join(parts)
restored=derived
for _,edit in reversed(ordered):
 at=edit['outputOffset'];assert restored[at:at+len(edit['insert'])]==edit['insert']
 restored=restored[:at]+restored[at+len(edit['insert']):]
assert restored.encode()==before
assert source.read_bytes()==before
result={'kind':'phase60-private-driver-stage-derivation','complete':True,'pass':True,
 'dataOnly':True,'targetExecuted':False,'diagnosticOnly':True,'productionQualified':False,
 'source':identity(source),'output':{'file':str(output),'sha256':sha(derived.encode()),'bytes':len(derived.encode())},
 'producer':identity(Path(__file__).resolve()),'clock':identity(Path(__file__).with_name('clock.mjs').resolve()),
 'exactInverse':True,'offsetUnit':'Unicode code points','edits':edits,
 'scope':'Exact original statements/returns retained; synchronous clock insertions and function try/finally only. Completed helper results are not wrapped, forced again or converted to Promises. Use stage-exclusive times, not a sum of nested inclusives. Ordinary error paths may leave incomplete child markers; those observations are not successful phase qualification.'}
with output.open('x') as f:f.write(derived)
with receipt.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps({'output':result['output'],'receipt':identity(receipt),'insertions':len(edits)}))
