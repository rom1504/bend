#!/usr/bin/env python3
"""Compose isolated source copies only; never invoke the compiler or a target."""
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent

def source(name):
    return (HERE/'integration-baseline'/name).read_text()

def section(src, name):
    match = re.search(r'@unsafe\ndef '+re.escape(name)+r'\b[\s\S]*?(?=\n@unsafe|\nlaw |\n#|\Z)', src)
    assert match, name
    return match.group(0)

def replace(src, name, body):
    return src.replace(section(src, name), body.rstrip()+'\n', 1)

flat=source('flat.bend')
bridge=source('bridge.bend')
direct=source('direct.bend')
flat=flat.replace('NC_Destination{+word: String, +join: String, +owner: String, +params: List<&2, NC_Binding>, +tail: Bool}', 'NC_Destination{+words: List<&2, String>, +shape: KTerm, +join: String, +owner: String, +params: List<&2, NC_Binding>, +tail: Bool, +signatures: List<&2, KDef>}')
flat=flat.replace('NF_Worker{+name: String, +params: List<&2, NC_Binding>, +code: NC_Code, +deps: List<&2, String>}', 'NF_Worker{+name: String, +params: List<&2, NC_Binding>, +code: NC_Code, +deps: List<&2, String>, +shape: KTerm}')
flat=replace(flat,'nf_return','''@unsafe
def nf_return(+word: String, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_return(word, n), u => nq_transfer(atom("Absent"), [word], n, target))
''')
flat=replace(flat,'nf_local','''@unsafe
def nf_local(+target: NC_Target, +word: String, +join: String) -> NC_Target:
  nq_local(target, [word], atom("Absent"), join)
''')
flat=flat.replace('def nf_bind(', 'def nf_bind_boxed(',1)
flat=flat.replace('nf_bind(book, kid(h, 0)', 'nq_bind_choose(book, kid(h, 0)')
old=section(flat,'nf_call_local')
new=old.replace('NC_Destination{dest, join, +owner, +params, +tail}', 'NC_Destination{dests, shape, join, +owner, +params, +tail, signatures}')
start=new.index('        u => nc_prepend("Term nf_result_')
new=new[:start]+'        u => nq_call_result(name, words, n, target))\n'
flat=flat.replace(old,new)
flat=flat.replace('nf_emitted(nc_intrinsic_value(nc_primitive_name(name), words, n), target)', 'nq_intrinsic(nc_primitive_name(name), words, n, target)')
flat=flat.replace('u => nf_call(book, nm(t), Nil{}, n, target)', 'u => nq_call(book, kt("NFCall", nm(t), 0, 0, Nil{}), Nil{}, n, target)')
flat=replace(flat,'nf_candidate','''@unsafe
def nf_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>) -> NF_Worker:
  +params = nd_entry_params(nd_arity(book, name), 0)
  +body = nc_compact(nc_definition(book, lookup(book, name), 0))
  +shape = atom("Absent")
  +code = nc_lower_to(book, nd_reapply(body, nd_entry_args(params)), params, nt_count(NC_Binding, params), NC_Destination{nq_words("nf_out", nq_width(shape), 0), shape, "", name, params, True{}, signatures})
  NF_Worker{name, params, code, nc_calls(code), shape}
''')
flat=flat.replace('+bangs: List<&2, String>) -> List<&2, NF_Worker>:', '+bangs: List<&2, String>, +signatures: List<&2, KDef>) -> List<&2, NF_Worker>:')
flat=flat.replace('nf_candidate(book, name)', 'nf_candidate(book, name, signatures)')
flat=flat.replace('nf_candidates(book, rest, bangs)', 'nf_candidates(book, rest, bangs, signatures)')
flat=flat.replace('NF_Worker{+name, params, +code, +deps}', 'NF_Worker{+name, params, +code, +deps, shape}')
flat=flat.replace('NF_Worker{+name, +params, code, deps}', 'NF_Worker{+name, +params, code, deps, +shape}')
flat=flat.replace('NF_Worker{+name, +params, +code, deps}', 'NF_Worker{+name, +params, +code, deps, shape}')
flat=flat.replace('0, atom("Absent"), kt("NFName", name', '0, shape, kt("NFName", name')
old=section(flat,'nf_wrap_segments')
needle='u => "#if !DEVICE\\n{\\nTerm nf_result;\\nif (!" ++ nf_name(nm(dv(d))) ++ "(e, seq, &nf_result" ++ nf_arg_c(nf_segment_args(params)) ++ ")) { return 0; }\\n" ++ ne_ret(["nf_result"]) ++ "}\\n#else\\n" ++ body ++ "#endif\\n", u => body)'
assert needle in old
flat=flat.replace(old,old.replace(needle,'u => nq_wrap_segment(d, params, body), u => body)'))
flat=replace(flat,'nf_finish_show','''@unsafe
def nf_finish_show(+book: List<&2, KDef>, +ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: String, requests: String, pure: Bool, show: NC_Show) -> NC_Result:
  +names = nc_live_names(book, ["main"], Nil{})
  +signatures = book_cached(nq_signatures(book, names), 0)
  +bangs = nc_bangs_book(book)
  nf_finish_workers(book, ss, cs, runtime, requests, pure, show, List.append(&2, NF_Worker, nf_candidates(book, names, bangs, signatures), nq_candidates(book, names, bangs, signatures)))
''')
guards=(HERE.parents[1]/'flat-workers/admission-shortcircuit-v1/candidate/flat.bend')
if not guards.exists():
    guards=HERE.parents[1]/'flat-workers/admission-shortcircuit-v1/flat.bend'
if guards.exists():
    for name in ['nf_deps_ready','nf_admit_pass']:
        body=section(guards.read_text(),name).replace('NF_Worker{+name, params, +code, +deps}', 'NF_Worker{+name, params, +code, +deps, shape}')
        flat=replace(flat,name,body)
bridge=bridge.replace('nf_emitted(nc_constructor_value(nm(t), nc_values(ks(t), env), n), target)', 'nq_operation(book, t, env, n, target)')
bridge=bridge.replace('nf_emitted(nc_intrinsic_value(nm(t), nc_values(ks(t), env), n), target)', 'nq_operation(book, t, env, n, target)')
bridge=bridge.replace('u => nf_call(book, nm(t), nc_values(ks(t), env), n, target)', 'u => nq_call(book, t, env, n, target)')
bridge=bridge.replace('String.eq(tag, "NMatch"), u => nc_match_apply_to(book, t, env, n, target)', 'String.eq(tag, "NMatch"), u => nq_match(book, t, env, n, target)')
old=section(bridge,'nc_lower_live_to')
new=old.replace('  nt_choose(NC_Code, String.eq(tag, "NWord"),', '  nt_choose(NC_Code, String.eq(tag, "NQBundle") && Bool.not(nf_scheduler(target)), u => nq_bundle_return(t, env, n, target), u =>\n  nt_choose(NC_Code, String.eq(tag, "NQBox") && Bool.not(nf_scheduler(target)), u => nf_emitted(nc_constructor_value(nm(t), nc_values(ks(t), env), n), target), u =>\n  nt_choose(NC_Code, String.eq(tag, "NWord"),',1).rstrip()+'))\n'
bridge=bridge.replace(old,new)
direct=direct.replace('String.eq(tg(arg), "Var"),\n    u => nc_lower_to(book, kt("NMatch"', '(String.eq(tg(arg), "Var") || (Bool.not(nf_scheduler(target)) && String.eq(tg(arg), "NQBundle"))),\n    u => nc_lower_to(book, kt("NMatch"',1)
direct=direct.replace('&& nd_match_vars(args),', '&& (nd_match_vars(args) || (Bool.not(nf_scheduler(target)) && nq_match_args(args))),')
def code_edges(src):
    """Extend NC_Code with explicit emitted-call facts; inspect Bend, not C text."""
    edits=[]
    for match in re.finditer(r'NC_Code\{',src):
        i=match.end(); start=i; depth=1; quoted=False; fields=[]
        while depth:
            c=src[i]
            if quoted:
                if c=='\\': i+=2; continue
                if c=='"': quoted=False
            elif c=='"': quoted=True
            elif c in '{([': depth+=1
            elif c in '})]':
                depth-=1
                if depth==0: fields.append(src[start:i]); break
            elif c==',' and depth==1:
                fields.append(src[start:i]); start=i+1
            i+=1
        assert len(fields)==4 or '+body: String' in fields[0], (len(fields),src[match.start():i+1])
        prefix=src[max(0,match.start()-8):match.start()]
        if '+body: String' in fields[0]: extra='+calls: List<&2, String>'
        elif re.search(r'case\s*$',prefix): extra='edges'
        else:
            children=list(dict.fromkeys(re.findall(r'nc_(?:body|segs|error|fresh)\((\w+)\)',','.join(fields))))
            extra='Nil{}'
            for child in reversed(children): extra='List.append(&2, String, nc_calls('+child+'), '+extra+')'
            if fields[1].strip() in {'segs','nc_mark_segments(ss, bang, forked, calls)'}: extra='edges'
        edits.append((i,', '+extra))
    for i,text in reversed(edits): src=src[:i]+text+src[i:]
    return src

product=(HERE/'product-source.bend').read_text()
book=source('book.bend')
for name,text in [('flat.bend',flat),('bridge.bend',bridge),('direct.bend',direct),('book.bend',book),('product.bend',product),('pattern.bend',source('pattern.bend')),('parallel.bend',source('parallel.bend'))]:
    text=code_edges(text)
    if name=='product.bend':
        note=section(text,'nq_note_call')
        text=text.replace(note,note.replace('NC_Code{body, segs, fresh, error, edges}\n', 'NC_Code{body, segs, fresh, error, Con{name, edges}}\n'))
    (HERE/'candidate'/name).write_text(text)
manifest=source('manifest.txt').replace('flat.bend\n','flat.bend\nproduct-layout.bend\nproduct.bend\n')
(HERE/'candidate/manifest.txt').write_text(manifest)
config=source('compiler.json').replace('    "src/back/native/flat.bend",\n','    "src/back/native/flat.bend",\n    "src/back/native/product-layout.bend",\n    "src/back/native/product.bend",\n')
(HERE/'candidate/compiler.json').write_text(config)
print('Composed flat-product candidate source copies; no compiler or target execution.')
