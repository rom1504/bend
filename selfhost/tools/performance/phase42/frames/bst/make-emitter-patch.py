from pathlib import Path
import difflib,json,re
paths=['selfhost/src/back/js/tree.bend','selfhost/src/back/js/finite.bend']
old={p:Path(p).read_text() for p in paths};new=dict(old)
tree=paths[0];finite=paths[1]
# Ground-U32 algorithm selection stays unchanged; add only closed private type
# alternatives at independently guarded component/helper admission boundaries.
needle='j_list_ground_type(book, kid(head, 0)) ||'
assert new[tree].count(needle)==1
new[tree]=new[tree].replace(needle,'j_list_ground_type(book, kid(head, 0)) || j_pure_closed_list(book, kid(head, 0)) ||')
needle='j_primitive_type(book, arg, "Bool") || j_list_ground_type(book, arg) ||'
assert new[tree].count(needle)==1
new[tree]=new[tree].replace(needle,'j_primitive_type(book, arg, "Bool") || j_list_ground_type(book, arg) ||\n          j_pure_closed_list(book, arg) || j_pure_closed_sigma(book, arg) ||')
assert new[finite].count(needle)==2
new[finite]=new[finite].replace(needle,'j_primitive_type(book, arg, "Bool") || j_list_ground_type(book, arg) ||\n      j_pure_closed_list(book, arg) || j_pure_closed_sigma(book, arg) ||')
# Shared finite emitter also emits direct helper prefixes. A proven native
# product has exactly one complete Tuple arm and two nonerased typed fields.
for p,name,decl,call,body in [
 (tree,'j_component_emit_match',
  '+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>, +d: KDef, +phase: U32',
  'book, env, t, ty, arg, rest, d, phase',
  'j_component_emit(book, env, kid(t, 0), j_arm_type(book, ty, "Tuple"), j_native_tuple_fields(arg, 0, rest), d, phase)'),
 (finite,'j_finite_emit_match',
  '+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +arg: String, +rest: List<&2,String>',
  'book, env, t, ty, arg, rest',
  'j_finite_emit(book, env, kid(t, 0), j_arm_type(book, ty, "Tuple"), j_native_tuple_fields(arg, 0, rest))')]:
 signature='@unsafe\ndef '+name+'('+decl+') -> String:'
 assert new[p].count(signature)==1
 replacement='''# Full original JPure coverage plus exact closed native Sigma identity proves
# the sole Tuple arm. Its owned pair fields are dense slots, not tagged .a.
'''+signature+'\n  kc(String, j_pure_closed_sigma(book, wnf(book, kid(ty, 0))) && String.eq(nm(t), "Tuple"),\n    u => "{" ++ '+body+' ++ "}",\n    u => '+name+'_tagged('+call+'))\n\n@unsafe\ndef '+name+'_tagged('+decl+') -> String:'
 new[p]=new[p].replace(signature,replacement)
new[tree]+='''

# This helper is used only after a complete typed native Tuple arm is proved.
# Preserve binder order and aliases; no shape check or field vector is emitted.
@unsafe
def j_native_tuple_fields(+arg: String, +at: U32, +rest: List<&2,String>) -> List<&2,String>:
  kc(List<&2,String>, U32.is_eq(at, 2), u => rest, u =>
    Con{"(" ++ arg ++ ")[" ++ U32.show(at) ++ "]", j_native_tuple_fields(arg, U32.inc(at), rest)})
'''
patch=''.join(''.join(difflib.unified_diff(old[p].splitlines(True),new[p].splitlines(True),fromfile='a/'+p,tofile='b/'+p)) for p in paths)
Path('selfhost/tools/performance/phase42/frames/bst/native-emitter-source.patch').write_text(patch)
# Read-only arity check for each new/renamed emitter signature and call.
rows=[]
for p,s in new.items():
 for name,arity in [('j_component_emit_match',8),('j_component_emit_match_tagged',8),('j_finite_emit_match',6),('j_finite_emit_match_tagged',6),('j_native_tuple_fields',3)]:
  for m in re.finditer(r'\b'+name+r'\(',s):
   i=m.end();depth=0;quote=False;escape=False;count=1;isdef=s[max(0,m.start()-4):m.start()]=='def '
   if isdef:count=s[i:s.index(')',i)].count('+')
   else:
    while i<len(s):
     c=s[i]
     if quote:
      if escape:escape=False
      elif c=='\\':escape=True
      elif c=='"':quote=False
     elif c=='"':quote=True
     elif c in '([{':depth+=1
     elif c in ')]}':
      if c==')' and depth==0:break
      depth-=1
     elif c==',' and depth==0:count+=1
     i+=1
   assert count==arity,(p,name,count)
   rows.append({'file':p,'name':name,'arity':count,'definition':isdef,'line':s.count('\n',0,m.start())+1})
Path('selfhost/tools/performance/phase42/frames/bst/emitter-arity-review.json').write_text(json.dumps({'complete':True,'scope':'read-only proposed sources; no compiler execution','rows':rows},indent=2)+'\n')
print(json.dumps({'complete':True,'arityOccurrences':len(rows),'addedLines':sum(len(new[p].splitlines())-len(old[p].splitlines()) for p in paths)}))
