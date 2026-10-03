from pathlib import Path
import difflib, json, re, hashlib
p='selfhost/src/back/js/tree.bend'
old=Path(p).read_text();new=old
needle='''@unsafe
def j_component_covered_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:
  "function " ++ j_region_name(dn(d)) ++ "$tree("'''
replacement='''@unsafe
def j_component_covered_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:
  kc(String, j_flat_active(book) && U32.is_gt(j_component_refs([dv(d)], dn(d), 1024, 0), 0) &&
    j_hybrid_binary_shape(dv(d), dn(d), 8192),
    u => j_hybrid_declaration(book, d, body),
    u => j_component_stack_declaration(book, d, body, "$tree"))

# The normal and exhausted-budget declarations use the original iterative body.
# Only their private names differ; generic/public declarations stay unchanged.
@unsafe
def j_component_stack_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm, +suffix: String) -> String:
  "function " ++ j_region_name(dn(d)) ++ suffix ++ "("'''
assert new.count(needle)==1;new=new.replace(needle,replacement)
start=new.index('@unsafe\ndef j_component_finish(');end=new.index('\n@unsafe\ndef j_component_enter(',start)
block=new[start:end];header,body=block.split('\n',2)[0:2],None
signature=block[:block.index('\n  kc(String')]
original=block[len(signature)+1:]
assert original.rstrip().endswith(')))))')
rewritten=signature+'\n  kc(String, U32.is_eq(phase, 4), u => j_hybrid_finish(book, env, t, ty, d), u =>\n'+original.rstrip()+')\n'
new=new[:start]+rewritten+new[end:]
new+='''

# A cycle containing a budget-reset component is already refused by its exact
# full-closure j_component_closed/backedges proof. Direct helpers independently
# require an acyclic closure; the flat audit covers every emitted consumer.
# Hence native depth is bounded by source graph depth, not input tree depth.
# This initial clone accepts only the existing two-child Let leaves; unary,
# sequential and tail continuations keep the original iterative emitter.
@unsafe
def j_hybrid_binary_shape(+t: KTerm, +owner: String, +fuel: U32) -> Bool:
  +body = j_strip(t)
  kc(Bool, U32.is_gt(fuel, 0), u =>
    kc(Bool, String.eq(tg(body), "Lam"),
      u => j_hybrid_binary_shape(kid(body, 0), owner, U32.sub(fuel, 1)), u =>
    kc(Bool, String.eq(tg(body), "Mat"),
      u => j_hybrid_binary_shape(kid(body, 0), owner, U32.sub(fuel, 1)) &&
        j_hybrid_binary_shape(kid(body, 1), owner, U32.sub(fuel, 1)), u =>
    kc(Bool, U32.is_eq(j_component_refs([body], owner, 1024, 0), 0), u => True{}, u =>
      String.eq(tg(body), "Let") && U32.is_eq(terms_len(ks(body)), 3) &&
      U32.is_eq(j_component_refs([body], owner, 1024, 0), 2) &&
      String.eq(nm(j_call_spine(kid(kid(body, 0), 0), Nil{})), owner) &&
      String.eq(nm(j_call_spine(kid(kid(body, 1), 0), Nil{})), owner)))), u => False{})

# Check the budget before any source prefix or field demand. The fallback gets
# the captured current parameters once, without a new guard or proof extent.
@unsafe
def j_hybrid_declaration(+book: List<&2,KDef>, +d: KDef, +body: KTerm) -> String:
  +name = j_region_name(dn(d)) ++ "$tree"
  +args = j_region_parameters(0, da(d))
  "function " ++ name ++ "(" ++ args ++ "){return " ++ name ++ "$hybrid(" ++ args ++ ",16);}" ++
  "function " ++ name ++ "$hybrid(" ++ args ++ ",$budget){if($budget===0)return " ++ name ++ "$stack(" ++ args ++ ");" ++
    j_region_nested_slots(0, da(d)) ++ "let $value;$step:{" ++
    j_component_emit(book, Nil{}, body, dt(d), j_component_values(0, da(d)), d, 4) ++ "}return $value;}" ++
    j_component_stack_declaration(book, d, body, "$tree$stack")

# Reuse original typed child arguments and binders. Phase0 child work finishes
# before phase1 arguments; the combiner sees exactly those two completed values.
@unsafe
def j_hybrid_finish(+book: List<&2,KDef>, +env: List<&2,KTerm>, +t: KTerm, +ty: KTerm, +d: KDef) -> String:
  kc(String, U32.is_eq(j_component_refs([t], dn(d), 1024, 0), 0),
    u => "$value=" ++ j_expr(book, env, t, ty, False{}) ++ ";break $step;", u =>
      "const " ++ j_local(ix(kid(t, 0))) ++ "=" ++ j_region_name(dn(d)) ++ "$tree$hybrid(" ++
        j_apply_args(book, env, ks(j_call_spine(kid(kid(t, 0), 0), Nil{})), dt(d)) ++ "$budget-1);" ++
      "const " ++ j_local(ix(kid(t, 1))) ++ "=" ++ j_region_name(dn(d)) ++ "$tree$hybrid(" ++
        j_apply_args(book, env, ks(j_call_spine(kid(kid(t, 1), 0), Nil{})), dt(d)) ++ "$budget-1);" ++
      "$value=" ++ j_expr(book, j_context(book, env, ks(t)), kid(t, 2), ty, False{}) ++ ";break $step;")
'''
base=Path('selfhost/tools/performance/phase42/frames');patch=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+p,tofile='b/'+p));(base/'hybrid-source-v1.patch').write_text(patch);(base/'hybrid-source-v1.bend').write_text(new)
# Read-only signature/call audit; no Bend/JS execution or canonical mutation.
rows=[]
for name,arity in [('j_component_stack_declaration',4),('j_hybrid_binary_shape',3),('j_hybrid_declaration',3),('j_hybrid_finish',5)]:
 for m in re.finditer(r'\b'+name+r'\(',new):
  i=m.end();depth=0;quote=False;escape=False;count=1;isdef=new[max(0,m.start()-4):m.start()]=='def '
  if isdef: count=new[i:new.index(')',i)].count('+')
  else:
   while i<len(new):
    c=new[i]
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
  assert count==arity,(name,count,arity,new.count('\n',0,m.start())+1)
  rows.append({'name':name,'arity':count,'definition':isdef,'line':new.count('\n',0,m.start())+1})
report={'complete':True,'kind':'phase42-hybrid-source-static-arity','sourceSha256':hashlib.sha256(old.encode()).hexdigest(),'candidateSha256':hashlib.sha256(new.encode()).hexdigest(),'patchSha256':hashlib.sha256(patch.encode()).hexdigest(),'occurrences':rows,'added':sum(x.startswith('+') and not x.startswith('+++') for x in patch.splitlines()),'removed':sum(x.startswith('-') and not x.startswith('---') for x in patch.splitlines())};(base/'hybrid-source-v1-arity.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
