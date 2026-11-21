"""Compose byte-anchored trials on the frozen Phase203 source."""
import argparse
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = ROOT/"selfhost/build/phase203/candidate01/compiler.bend"
def replace(src,a,b,n=1):
    assert src.count(a)==n, (a[:100],src.count(a),n)
    return src.replace(a,b)

def copy_trial(s):
    anchor="@unsafe\ndef x185_copy_function("
    s=replace(s,anchor,(HERE/"copy.bend").read_text()+"\n"+anchor)
    s=replace(s,"x185_copy_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096)",
                "x185_copy_enabled() && U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096) && x204_copy_possible(body)")
    s=replace(s,"def x185_copy_name(+name: String, +aliases: KDef) -> String:\n  +entry = p111v_get(aliases,name)","def x185_copy_name(+name: String, +aliases: KDef) -> String:\n  +entry = x204_local_get(aliases,name)")
    s=replace(s,"String.eq(dk(p111v_get(aliases,name)),\"X185Alias\")","String.eq(dk(x204_local_get(aliases,name)),\"X185Alias\")")
    s=replace(s,"def x190_l_bit(name: String, ids: KDef) -> U32: da(p111v_get(ids,name))","def x190_l_bit(name: String, ids: KDef) -> U32: da(x204_local_get(ids,name))")
    orig='p111v_put(counts,name,"X185Writes",U32.min(2,U32.inc(da(p111v_get(counts,name)))),0)'
    s=replace(s,orig,''' +hash = index_hash(name,2166136261)
  +count = U32.min(2,U32.inc(da(index_find(counts,name,hash,32))))
  index_set(counts,KDef{name,"X185Writes",count,0,atom("Absent"),atom("Absent"),[],False{},False{}},hash,32)'''.lstrip())
    return s

def live_trial(s):
    anchor="@unsafe\ndef x190_l_selected("
    s=replace(s,anchor,(HERE/"liveness.bend").read_text()+"\n"+anchor)
    for role in ("l","j"):
        head=f"def x190_{role}_selected(+frame: X181Frame, +params: List<&2,String>, setup:"
        s=replace(s,head,head.replace(" setup:", " +setup:"))
    s=replace(s,"x190_l_fixed(body,ids,parameters,0,33)","x204_for_collection(setup,body,ids,parameters)",2)
    s=replace(s,"u => x191_loop_counted(x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]})),\n      x191_loop_reads(body,params,False{})),",
              """u => x204_joint_counts(x181_reads_stmts(setup,x181_reads_stmts(body,X181ReadCounts{missing(),[]})),body,params),""")
    anchor="@unsafe\ndef x191_joint_reads("
    s=replace(s,anchor,"""@unsafe
def x204_joint_counts(+all: X181ReadCounts, +body: List<&2,P113DStmt>, +params: List<&2,String>) -> X181ReadCounts:
  nt_choose(X181ReadCounts,x190_register_loop(body),
    u => x191_loop_counted(all,x191_loop_reads(body,params,False{})),u => all)

"""+anchor)
    return s

def continuation_trial(s):
    anchor="@unsafe\ndef x202k_calls("
    s=replace(s,anchor,(HERE/"continuation.bend").read_text()+"\n"+anchor)
    return replace(s,'x202k_index(get,"p111_rt_stack_get",0) && x202k_tail(rest,saved)',
        'x202k_index(get,"p111_rt_stack_get",0) && x204_source_tail(rest,saved)')

if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("out",type=Path);p.add_argument("variants",nargs="+");a=p.parse_args()
    s=BASE.read_text()
    assert hashlib.sha256(s.encode()).hexdigest()=="ae66e5be0e03ee39a55e429a9d81d52c68aa31238c393e3209e0de1f36094d68"
    for v in a.variants:
        if v=="copy": s=copy_trial(s)
        elif v=="live": s=live_trial(s)
        elif v=="continuation": s=continuation_trial(s)
        else: raise ValueError(v)
    a.out.mkdir(parents=True)
    (a.out/"compiler.bend").write_text(s)
