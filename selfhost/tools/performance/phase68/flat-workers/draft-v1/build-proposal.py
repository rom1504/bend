#!/usr/bin/env python3
"""Data-only source composition; does not assemble or execute a compiler."""
from pathlib import Path
import re, json, hashlib, difflib

HERE = Path(__file__).resolve().parent

def section(src, name):
    pat = re.compile(r'@unsafe\ndef '+re.escape(name)+r'\b[\s\S]*?(?=\n@unsafe|\nlaw |\n#|\Z)')
    m = pat.search(src)
    assert m, name
    return m.group(0)

def replace_section(src, name, replacement):
    old = section(src, name)
    return src.replace(old, replacement, 1)

def target_calls(src, names):
    """Add the explicit result target only to calls, never C string contents."""
    edits = []
    i = 0
    quoted = False
    while i < len(src):
        if src[i] == '"':
            quoted = not quoted
            i += 1
            continue
        if quoted:
            i += 2 if src[i] == '\\' else 1
            continue
        m = re.match(r'([A-Za-z_][A-Za-z_0-9]*)\(', src[i:])
        if not m:
            i += 1
            continue
        old = m[1]
        if old in names:
            j = i + len(m[0]); depth = 1; quote = False
            while depth:
                c = src[j]
                if c == '"': quote = not quote
                elif quote and c == '\\': j += 1
                elif not quote:
                    depth += (c == '(') - (c == ')')
                j += 1
            edits.append((j-1,j-1,', target'))
            edits.append((i,i+len(old),names[old]))
        i += len(m[1])
    for a,b,value in sorted(edits, reverse=True): src=src[:a]+value+src[b:]
    return src

bridge=(HERE/'baseline/bridge.bend').read_text()
direct=(HERE/'baseline/direct.bend').read_text()
book=(HERE/'baseline/book.bend').read_text()

# Preserve public scheduler lowering and route both modes through one dispatch.
old=section(bridge,'nc_lower')
new='''@unsafe
def nc_lower(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> NC_Code:
  nc_lower_to(book, t, env, n, NC_Scheduler{})

@unsafe
def nc_lower_to(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nc_prepend(nc_drop_dead(env, t), nc_lower_live_to(book, t, nc_live_env(env, t), n, target))
'''
bridge=bridge.replace(old,new)
bridge=bridge.replace('law nc_lower_live:\n','law nc_lower_live_to:\n',1)
law_start=bridge.index('law nc_lower_live_to:')
law_end=bridge.index('\n@unsafe',law_start)
law=bridge[law_start:law_end]
bridge=bridge[:law_start]+law.replace('  NC_Code','  for +target: NC_Target\n  NC_Code')+bridge[law_end:]

# A matcher chooses the same owned arms in both result modes.
bridge=bridge.replace('law nc_match_apply_slow:\n','law nc_match_apply_slow_to:\n',1)
law_start=bridge.index('law nc_match_apply_slow_to:')
law_end=bridge.index('\n@unsafe',law_start)
law=bridge[law_start:law_end]
bridge=bridge[:law_start]+law.replace('  NC_Code','  for +target: NC_Target\n  NC_Code')+bridge[law_end:]
old=section(bridge,'nc_match_apply')
new=old.replace('def nc_match_apply(','def nc_match_apply_to(',1).replace('+n: U32) -> NC_Code:', '+n: U32, +target: NC_Target) -> NC_Code:',1)
head,body=new.split('\n',2)[0:2],new.split('\n',2)[2]
body=body.replace('U32.is_eq(terms_len(ks(t)), 2) &&', 'nf_scheduler(target) && U32.is_eq(terms_len(ks(t)), 2) &&',1)
body=target_calls(body,{'nc_match_apply_slow':'nc_match_apply_slow_to'})
bridge=bridge.replace(old,'\n'.join(head)+'\n'+body)
old=section(bridge,'nc_match_apply_slow')
new=old.replace('def nc_match_apply_slow(book, t, env, n):','def nc_match_apply_slow_to(book, t, env, n, target):',1)
head,body=new.split('\n',2)[0:2],new.split('\n',2)[2]
body=target_calls(body,{'nc_lower':'nc_lower_to'})
bridge=bridge.replace(old,'\n'.join(head)+'\n'+body)

# Constructor arguments and literals keep their existing ordered lowering.
old=section(bridge,'nc_lower_ctor')
new=old.replace('def nc_lower_ctor(','def nc_lower_ctor_to(',1).replace('literal: NC_Literal)', 'literal: NC_Literal, +target: NC_Target)').replace('lit: NC_Literal)', 'lit: NC_Literal, +target: NC_Target)')
head,body=new.split('\n',2)[0:2],new.split('\n',2)[2]
body=target_calls(body,{'nc_lower':'nc_lower_to','nc_return':'nf_return'})
bridge=bridge.replace(old,'\n'.join(head)+'\n'+body)

old=section(bridge,'nc_lower_live')
new=old.replace('def nc_lower_live(book, t, env, n):','def nc_lower_live_to(book, t, env, n, target):',1)
head,body=new.split('\n',2)[0:2],new.split('\n',2)[2]
body=target_calls(body,{'nc_lower':'nc_lower_to','nc_return':'nf_return','nc_lambda':'nf_lambda','nd_app':'nd_app_to','nc_parallel':'nf_parallel','nc_lets':'nf_lets','nc_lower_ctor':'nc_lower_ctor_to','nc_match':'nf_match_value','nc_match_apply':'nc_match_apply_to'})
body=body.replace('NC_Code{ne_jump(Nil{}, nc_ref_name(book, nm(t))), Nil{}, n, ""}', 'nf_ref(book, t, n, target)')
body=body.replace('nc_constructor(nm(t), nc_values(ks(t), env), n)', 'nf_emitted(nc_constructor_value(nm(t), nc_values(ks(t), env), n), target)')
body=body.replace('nc_intrinsic(nm(t), nc_values(ks(t), env), n)', 'nf_emitted(nc_intrinsic_value(nm(t), nc_values(ks(t), env), n), target)')
body=body.replace('u => nc_apply_code(nc_values(ks(t), env), n)', 'u => nt_choose(NC_Code, nf_scheduler(target), v => nc_apply_code(nc_values(ks(t), env), n), v => nc_fail("flat worker: dynamic application", n))')
body=body.replace('u => NC_Code{ne_jump(nc_values(ks(t), env), nm(t)), Nil{}, n, ""}', 'u => nt_choose(NC_Code, nf_scheduler(target), v => NC_Code{ne_jump(nc_values(ks(t), env), nm(t)), Nil{}, n, ""}, v => nc_fail("flat worker: scheduler call node", n))')
needle='  nt_choose(NC_Code, String.eq(tag, "NCall"),'
body=body.replace(needle,'  nt_choose(NC_Code, String.eq(tag, "NFCall"), u => nf_call(book, nm(t), nc_values(ks(t), env), n, target), u =>\n'+needle)
body=body.rstrip()+')\n'
bridge=bridge.replace(old,'\n'.join(head)+'\n'+body)

# Named-call argument lowering retains the same sequence and ownership logic.
direct=direct.replace('law nd_app:\n','law nd_app_to:\n',1)
law_start=direct.index('law nd_app_to:');law_end=direct.index('\n@unsafe',law_start)
law=direct[law_start:law_end]
direct=direct[:law_start]+law.replace('  NC_Code','  for +target: NC_Target\n  NC_Code')+direct[law_end:]
old=section(direct,'nd_match')
new=old.replace('def nd_match(','def nd_match_to(',1).replace('+n: U32) -> NC_Code:', '+n: U32, +target: NC_Target) -> NC_Code:',1)
head,body=new.split('\n',2)[0:2],new.split('\n',2)[2]
body=target_calls(body,{'nc_lower':'nc_lower_to'})
direct=direct.replace(old,'\n'.join(head)+'\n'+body)
old=section(direct,'nd_app')
new=old.replace('def nd_app(book, t, env, n):','def nd_app_to(book, t, env, n, target):',1)
head,body=new.split('\n',2)[0:2],new.split('\n',2)[2]
body=target_calls(body,{'nc_lower':'nc_lower_to','nd_match':'nd_match_to','nc_app_slow':'nf_slow_app'})
body=body.replace('  nt_choose(NC_Code, String.eq(tg(head), "Lam"),', '  nt_choose(NC_Code, String.eq(tg(head), "Efq") && Bool.not(nf_scheduler(target)), u => nc_lower_to(book, head, env, n, target), u =>\n  nt_choose(NC_Code, String.eq(tg(head), "Lam"),',1)
body=body.replace('nc_sequence("NCall", nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n)', 'nc_sequence(nt_choose(String, nf_scheduler(target), v => "NCall", v => "NFCall"), nt_choose(String, nf_scheduler(target), v => nd_name(nc_ref_name(book, nm(head))), v => nm(head)), args, Nil{}, n)')
body=body.rstrip()+')\n'
direct=direct.replace(old,'\n'.join(head)+'\n'+body)

# Workers are independent declarations. Scheduler segment identity/ABI is kept.
book=book.replace('pure: Bool, d: NC_Show) -> NC_Result:', 'pure: Bool, d: NC_Show, workers: String) -> NC_Result:',1)
book=book.replace('requests, nc_helpers(), src, pure}', 'requests, nc_helpers() ++ workers, src, pure}',1)
book=book.replace('nc_with_show(ss, cs, runtime, requests, pure, nt_choose', 'nf_finish_show(book, ss, cs, runtime, requests, pure, nt_choose',1)

for name,src in [('bridge.bend',bridge),('direct.bend',direct),('book.bend',book)]:
    (HERE/'candidate'/name).write_text(src)

manifest=(HERE/'baseline/manifest.txt').read_text().replace('direct.bend\n','direct.bend\nflat.bend\n',1)
(HERE/'candidate/manifest.txt').write_text(manifest)
config=(HERE/'baseline/compiler.json').read_text().replace('    "src/back/native/direct.bend",\n','    "src/back/native/direct.bend",\n    "src/back/native/flat.bend",\n',1)
(HERE/'candidate/compiler.json').write_text(config)

mapping={'bridge.bend':'selfhost/src/back/native/bridge.bend','direct.bend':'selfhost/src/back/native/direct.bend','book.bend':'selfhost/src/back/native/book.bend','flat.bend':'selfhost/src/back/native/flat.bend','manifest.txt':'selfhost/src/back/native/manifest.txt','compiler.json':'selfhost/src/compiler.json'}
patch=''; rows=[]
for name,dest in mapping.items():
    before=(HERE/'baseline'/name).read_text() if (HERE/'baseline'/name).exists() else ''
    after=(HERE/'candidate'/name).read_text()
    patch+=''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/'+dest if before else '/dev/null',tofile='b/'+dest))
    rows.append({'path':dest,'beforeSha256':hashlib.sha256(before.encode()).hexdigest() if before else None,'afterSha256':hashlib.sha256(after.encode()).hexdigest(),'lineDelta':len(after.splitlines())-len(before.splitlines())})
(HERE/'flat-v1.patch').write_text(patch)
(HERE/'flat-v1.json').write_text(json.dumps({'kind':'phase68-flat-worker-source-proposal','executed':False,'prerequisites':['arity-v1','prefix-v1'],'patchSha256':hashlib.sha256(patch.encode()).hexdigest(),'files':rows,'notes':'Explicit common-lowerer destination; provisional code plus transitive admission; host-only wrappers. Source-review and root-owned checked execution pending.'},indent=2)+'\n')
print(json.dumps({'patchSha256':hashlib.sha256(patch.encode()).hexdigest(),'lineDelta':sum(r['lineDelta'] for r in rows),'files':len(rows)}))
