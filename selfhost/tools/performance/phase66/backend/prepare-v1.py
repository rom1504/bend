#!/usr/bin/env python3
"""Source-only, exact-seam candidate construction. Does not modify production."""
from pathlib import Path
import hashlib, json, difflib
root=Path(__file__).resolve().parents[5]
out=Path(__file__).resolve().parent
before={}; after={}
def change(path, old, new, count=1):
    if path not in before:
        before[path]=(root/path).read_text(); after[path]=before[path]
    assert after[path].count(old)==count, (path,old,after[path].count(old))
    after[path]=after[path].replace(old,new)
D='selfhost/src/back/js/direct/'
change(D+'constructors.bend', 'j_quote(nm(t)) ++ jd_ctor_fields', 'j_quote(name_key(nm(t))) ++ jd_ctor_fields')
change(D+'ordered-values.bend', 'j_quote(nm(t)) ++ named', 'j_quote(name_key(nm(t))) ++ named')
change(D+'pattern.bend', 'j_quote(nm(t)))', 'j_quote(name_key(nm(t))))')
change(D+'pattern.bend', r'u => "if(" ++ value ++ ".$===\"$FFI\")throw " ++ value ++ ";"', r'u => "if(" ++ value ++ ".$!==\"Emit\"&&" ++ value ++ ".$!==\"Halt\")throw \"bend: runtime fail-stop\";"')
change(D+'core.bend', '"unknown direct definition: " ++ dn(d)', '"unknown direct definition: " ++ name_key(dn(d))')
change(D+'program.bend', '[j_quote(dn(c))]', '[j_quote(name_key(dn(c)))]')
change(D+'program.bend', '[U32.show(jd_string_len(oldNames)), "0", U32.show(da(c)),', '[U32.show(jd_string_len(oldNames)), j_quote(name_key(dn(c))), U32.show(da(c)),')
change(D+'program.bend', r'"const $jdShowD=[" ++ jd_join(cells) ++ "];const $jdShowN=[" ++ jd_join(names) ++ "];\n"', r'"const $jdShowD=[" ++ jd_join(cells) ++ "];\n"')
change(D+'program.bend', r'",[$jdShowD,$jdShowN]);\n"', r'",$jdShowD);\n"')
V='selfhost/src/back/js/validate.bend'
change(V,'Bool.not(String.eq(tg(wnf(book, kid(ty, 0))), "ADT"))','j_layout_element_open(book, kid(ty, 0))')
change(V,'Bool.not(String.eq(tg(wnf(book, j_strip(element))), "ADT"))','j_layout_element_open(book, j_strip(element))')
change(V,'law j_layout_fields:', '# An equality has no live layout, even when its two sides remain open.\n# Keep normalization inside the original demanded Array branch.\n@unsafe\ndef j_layout_element_open(+book: List<&2,KDef>, +element: KTerm) -> Bool:\n  +tag = tg(wnf(book, element))\n  Bool.not(String.eq(tag, "ADT") || String.eq(tag, "Eql"))\n\nlaw j_layout_fields:')
for p in ['selfhost/src/back/native/validate.bend','selfhost/src/driver/api.bend']:
    change(p,'"IO.OP", "Result", "Maybe"','"IO.OP", "Result", "Poll", "Maybe"')
    change(p,'dn(d) ++ " is a name the compiler encodes itself:', 'name_key(dn(d)) ++ " is a name the compiler encodes itself:') if p.endswith('/validate.bend') else None
change('selfhost/src/driver/api.bend','dn(d) ++ " names both a constructor and a foreign def:', 'name_key(dn(d)) ++ " names both a constructor and a foreign def:')
change('selfhost/src/driver/api.bend','u => name ++ " is a name the compiler encodes itself:', 'u => name_key(name) ++ " is a name the compiler encodes itself:')
change('selfhost/src/back/native/show.bend','nc_quote_chars(nc_ctor_display(k))','nc_quote_chars(name_key(nc_ctor_display(k)))')
change('selfhost/src/back/native/book.bend','"native definition not found: " ++ name','"native definition not found: " ++ name_key(name)')
# Native C symbols and decoded constructor identities remain raw; the loader's
# Foreign.name normally provides the exact namespace prefix. Preserve the old
# heuristic for old synthetic Foreign terms lacking that source name.
NF='selfhost/src/back/native/foreign.bend'
change(NF,'nc_source_namespace(String.split(dn(d), \'.\'), "", source)', 'nc_foreign_namespace_name(dn(d), source)')
change(NF,'@unsafe\ndef nc_foreign_aliases(', '@unsafe\ndef nc_foreign_namespace_name(+name: String, +source: String) -> String:\n  match String.split(name, \':\'):\n    case Con{prefix, Con{local, rest}}: prefix ++ ":"\n    case other: nc_source_namespace(String.split(name, \'.\'), "", source)\n\n@unsafe\ndef nc_foreign_aliases(')
F='selfhost/src/back/js/foreign.bend'
change(F,"Char.is_eq(h, '.') || Char.is_eq(h, '/')", "Char.is_eq(h, '.') || Char.is_eq(h, '/') || Char.is_eq(h, ':')")
change(F,'j_quote(dn(d)) ++ ",a,["','j_quote(name_key(dn(d))) ++ ",a,["')
change(F,'j_quote(name) ++ ":typeof "','j_quote(name_key(name)) ++ ":typeof "')
change(F,'j_quote(kc(String, String.eq(nm(dv(d)), ""), u => dn(d), u => nm(dv(d))))','j_quote(kc(String, String.contains(dn(d), ":"), u => name_key(dn(d)), u => kc(String, String.eq(nm(dv(d)), ""), v => dn(d), v => nm(dv(d)))))')
change(F,'"a foreign def without a .js import: " ++ dn(d)','"a foreign def without a .js import: " ++ name_key(dn(d))')
change(F,'u => j_quote(nm(part)))','u => j_quote(name_key(nm(part))))')
E='selfhost/src/back/js/emit.bend'
old='Object.keys(G).map(k=>[k,(...args)=>call(get(G,k),args)])'
new="Object.keys(G).map(k=>[k.replace(':','.'),(...args)=>call(get(G,k),args)])"
change(E,old,new)
C='selfhost/tools/private-compiler/calls.mjs'
legacy="export {G,call,list,ctor};\\nexport default Object.fromEntries("+old+");"
current="export {G,call,list,ctor};\\nexport default Object.fromEntries("+new+");"
change(C,"  const ending='"+legacy+"';\n  if(source.split(ending).length!==2)throw Error('Expected exact self-emitted public ABI');", "  // Keep historical images replayable; accept exactly one complete known ABI.\n  const endings=[\n    "+json.dumps(legacy.replace('\\n','\n'))+",\n    "+json.dumps(current.replace('\\n','\n'))+",\n  ];\n  const counts=endings.map(ending=>source.split(ending).length-1);\n  if(counts.reduce((a,b)=>a+b,0)!==1)throw Error('Expected exact self-emitted public ABI');\n  const ending=endings[counts.indexOf(1)];")
R='selfhost/src/runtime/js/'
change(R+'core.mjs','const scope=p=>Object.create(p);', "const nameDisplay=k=>k.replace(':','.');\nconst scope=p=>Object.create(p);")
change(R+'readback.mjs','return x.typeName+', 'return nameDisplay(x.typeName)+')
change(R+'readback.mjs','return (constructorOwn[x.$]??x.$)+','return nameDisplay(constructorOwn[x.$]??x.$)+')
change(R+'foreign.mjs',"(d?.[0]==='Named'?d[1]:'datatype')", "(d?.[0]==='Named'?nameDisplay(d[1]):'datatype')")
change(R+'foreign.mjs','tags.map(k=>constructorOwn[k]??k)','tags.map(k=>nameDisplay(constructorOwn[k]??k))')
change(R+'foreign.mjs','const node={$:constructorOwn[tag]??tag}', 'const node={$:nameDisplay(constructorOwn[tag]??tag)}')
# This is the exact data-only assembly performed by runtime/js/build.mjs.
parts=['core','base','effects','readback','foreign']
runtime='selfhost/src/runtime.mjs'
header='// Generated by src/runtime/js/build.mjs; edit the fragments.\n'
assert header+'\n'.join((root/(R+n+'.mjs')).read_text() for n in parts)==(root/runtime).read_text()
before[runtime]=(root/runtime).read_text()
after[runtime]=header+'\n'.join(after.get(R+n+'.mjs',(root/(R+n+'.mjs')).read_text()) for n in parts)
rows=[]; diff=[]
sha=lambda s:hashlib.sha256(s.encode()).hexdigest()
for path in sorted(after):
    b=out/'before-v1'/path; a=out/'candidate-v1'/path
    b.parent.mkdir(parents=True,exist_ok=True); a.parent.mkdir(parents=True,exist_ok=True)
    assert not b.exists() and not a.exists(),path
    b.write_text(before[path]); a.write_text(after[path])
    rows.append({'path':path,'beforeSha256':sha(before[path]),'afterSha256':sha(after[path]),'beforeBytes':len(before[path].encode()),'afterBytes':len(after[path].encode()),'candidate':str(a.relative_to(root))})
    diff.extend(difflib.unified_diff(before[path].splitlines(True),after[path].splitlines(True),fromfile='a/'+path,tofile='b/'+path))
patch=out/'backend-v1.patch';patch.write_text(''.join(diff))
manifest={'kind':'phase66-backend-candidate','version':1,'status':'isolated-unexecuted','upstreamRevision':'059266225b77c8ca256ac6b25ee5c21449bab151','requires':['frontend name_key helper','matching direct runtime show/effect protocol'],'files':rows,'patchSha256':sha(patch.read_text())}
(out/'backend-v1.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'files':len(rows),'patchSha256':manifest['patchSha256'],'paths':[r['path'] for r in rows]},indent=2))
