#!/usr/bin/env python3
"""P5-019 explicit parser expectation overlay over a genuinely checked frozen project."""
import hashlib,json,pathlib,re,shutil,sys
source=pathlib.Path(sys.argv[1]).resolve(); proof=pathlib.Path(sys.argv[2]).resolve(); out=pathlib.Path(sys.argv[3]).resolve()
assert not out.exists();meta=json.loads(proof.read_text());sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
assert meta['stage']=='upstream-bootstrap' and meta['provenance']['verifiedAfterBuild']
assert sha(meta['apiPath'])==meta['apiSha256'] and sha(meta['source'])==meta['sourceSha256']
inputs=[{'file':str(proof),'sha256':sha(proof)},{'file':meta['apiPath'],'sha256':meta['apiSha256']}]+meta['provenance']['inputs']
for x in inputs:assert sha(x['file'])==x['sha256'],x['file']
for m in meta['modules']:assert sha(source/m['file'])==m['sha256'],m['file']
project=out/'project';project.mkdir(parents=True);shutil.copytree(source/'src',project/'src');(project/'tools').mkdir();(project/'dist').mkdir()
for n in ['typed-driver','stage0-library','assemble','compiler-abi','native-build','node-resource-args']:
 p=source/'tools'/f'{n}.mjs';inputs.append({'file':str(p),'sha256':sha(p)});shutil.copyfile(p,project/'tools'/p.name)
inputs.append({'file':str(pathlib.Path(__file__).resolve()),'sha256':sha(__file__)})
def once(s,a,b):
 assert s.count(a)==1,(a,s.count(a));return s.replace(a,b)
p=project/'src/front/parser.bend';s=p.read_text()
s=once(s,'u => f_err(ts, "expected term"))))))))))))))','u => f_choose(FParsed, f_reserved(f_tx(ts)), u => f_err(ts, "expected term"), u => fpe_error(ts, "expected term", "a term")))))))))))))))')
a='f_err(spaced, f_choose(String, f_eq(end, "]"), u => "expected term; a list does not use semicolon separators", u => "expected term; arguments do not use semicolon separators"))'
b='fpe_error(spaced, f_choose(String, f_eq(end, "]"), u => "expected term; a list does not use semicolon separators", u => "expected term; arguments do not use semicolon separators"), "a term")'
s=once(s,a,b)
s=once(s,'def fpe_error(ts, legacy, expected):\n  FParsed{kt("Error", nm(f_pn(f_err(ts, legacy))),','def fpe_error(ts, legacy, expected):\n  fpe_legacy(ts, nm(f_pn(f_err(ts, legacy))), expected)\n\n# Keep an already formatted fallback unchanged; expectation is explicit input.\nlaw fpe_legacy:\n  for +ts: List<&2,FToken>\n  for +legacy: String\n  for +expected: String\n  FParsed\n\n@unsafe\ndef fpe_legacy(ts, legacy, expected):\n  FParsed{kt("Error", legacy,')
p.write_text(s)
p=project/'src/front/declarations.bend';s=p.read_text()
a='f_pn(f_err(ts, "expected def, law, type or import"))'
b='f_pn(f_choose(FParsed, f_eq(f_tx(ts), "@"), u => f_err(ts, "expected def, law, type or import"), u => fpe_error(ts, "expected def, law, type or import", "\'def\', \'type\' or \'law\'")))'
s=once(s,a,b)
s=once(s,'f_pn(f_err(ts, "expected def, law or type; imports must precede declarations"))','f_pn(fpe_error(ts, "expected def, law or type; imports must precede declarations", "\'def\', \'type\' or \'law\'"))')
s=once(s,'f_pn(f_err(ts, "expected a plain clause (only leading clauses take ~)"))','f_pn(fpe_error(ts, "expected a plain clause (only leading clauses take ~)", "a plain clause (only leading clauses take ~)"))')
s=once(s,'kt("Error", "foreign import requires a quoted .c or .js path", 0, 0, Nil{})','fpe_foreign(f_space(f_tl(ts)))')
s+='''
# The wrong-extension cursor follows the closing quote; keep that case legacy.
law fpe_foreign:
  for +ts: List<&2,FToken>
  KTerm

@unsafe
def fpe_foreign(ts):
  f_choose(KTerm, Char.is_eq(f_head(f_tx(ts)), '\"'), u => kt("Error", "foreign import requires a quoted .c or .js path", 0, 0, Nil{}), u => f_pn(fpe_legacy(ts, "foreign import requires a quoted .c or .js path", "'\\\"'")))
'''
p.write_text(s)
p=project/'src/front/sugar.bend';s=p.read_text();s=once(s,'f_err(ts, "expected <")','fpe_error(ts, "expected <", "\'<\'")');s=once(s,'f_err(ts, "expected term")','fpe_error(ts, "expected term", "a term")');p.write_text(s)
for x in inputs:assert sha(x['file'])==x['sha256'],x['file']
outputs=[{'file':str(p),'sha256':sha(p)}for p in sorted((project/'src').rglob('*'))if p.is_file()]
report={'kind':'phase5-parser-expectations-preparation','complete':True,'newBootstrap':False,'baselineApi':meta['apiPath'],'baselineBootstrap':str(proof),'baselineSourceSha256':meta['sourceSha256'],'inputs':inputs,'outputs':outputs,'scope':'Three isolated source files; genuine candidate bootstrap still required.'}
(out/'preparation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'complete':True,'project':str(project)}))
