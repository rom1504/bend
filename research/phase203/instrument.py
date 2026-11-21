"""Build stock, timestamp-only and counted versions of the generated compiler listing."""
import argparse
from collections import Counter
import functools
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
from assembly import ROOT, P201, sha, REF

HERE = Path(__file__).resolve().parent
# Only the first entry at each declared stage snapshots counters and clocks.
STAGES = ["@start","x181_request","p86_plan","x198pw_plan","x198pw_after",
          "p168_request_mode","p169s_seeded","p169s_registered","p168j_forwards","p134e_registered",
          "x187_print_mode","x202p_x187_prepared","x181_cursor_index",
          "x181_program_private","x181_program_public","x202p_x201f_finish","x202e_open","@exit"]
TARGETS = set("""index_hash p111v_get p111v_put index_find index_set p131i_insert
    p168j_forwards p168j_forward_if p168j_forward x181_forward_selected x181_forward
    x181_forward_index x181_program_private x181_program_public x181_segment x193f_public
    x202k_shape x202k_template p111_segment p111v_segment x187_e_spec x187_elf_section_header""".split())
HOT_CALLERS = {"index_hash","p111v_get","p111v_put","p131i_insert","x181_segment","x193f_public","p168j_forward"}
SYMBOL = re.compile(rb'p(?:111|112w|113d)_FID_(?:\d+_)+')
CALL = re.compile(rb'\s*(?:callq?|jmpq?)\s+(p(?:111|112w|113d)_FID_(?:\d+_)+)\s*$')

@functools.lru_cache(maxsize=None)
def decode(symbol):
    tail=symbol.split(b"_FID_",1)[1].rstrip(b"_")
    return "".join(chr(int(n)) for n in tail.split(b"_"))

def canonical(name):
    for prefix in ("$direct.", "$product.", "$p118borrow.read.", "$p128borrow.owned."):
        if name.startswith(prefix):
            return name[len(prefix):]
    return name

def marker_definition():
    # Runs before the function prologue. Preserve the SysV integer, flag and
    # XMM argument state; the original stack and return address remain intact.
    return b"""
.macro p203_stage id
 pushfq
 cmpb $0, p203_seen+\\id(%rip)
 jne .Lp203_seen_\\@
 .irp reg,rax,rcx,rdx,rsi,rdi,r8,r9,r10,r11
 pushq %\\reg
 .endr
 subq $264,%rsp
 .irp n,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 movdqu %xmm\\n,16*\\n(%rsp)
 .endr
 movl $\\id,%edi
 call p203_mark
 .irp n,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 movdqu 16*\\n(%rsp),%xmm\\n
 .endr
 addq $264,%rsp
 .irp reg,r11,r10,r9,r8,rdi,rsi,rdx,rcx,rax
 popq %\\reg
 .endr
.Lp203_seen_\\@:
 popfq
.endm
.macro p203_count n
 pushfq
 incq p203_counts+8*\\n(%rip)
 popfq
.endm
"""

def assemble(listing, mode, out):
    ids={}
    static=Counter()
    gates=Counter()
    owner=b""
    owner_name=""
    owner_base=""
    def bump(key):
        static[key]+=1
        i=ids.setdefault(key,len(ids))
        return f" p203_count {i}\n".encode()
    with gzip.open(listing,"rb") as src:
        out.write(marker_definition())
        for line in src:
            if line.startswith(b"p") and line.rstrip().endswith(b":"):
                label=line.rstrip()[:-1]
                if SYMBOL.fullmatch(label):
                    owner=label
                    owner_name=decode(label)
                    owner_base=canonical(owner_name)
                    out.write(line)
                    if mode!="stock" and owner_base in STAGES:
                        gates[owner_base]+=1
                        out.write(f" p203_stage {STAGES.index(owner_base)}\n".encode())
                    if mode=="counts" and owner_base in TARGETS:
                        out.write(bump("entry:"+owner.decode().split("_FID_")[0]+":"+owner_name))
                    continue
            if mode=="counts" and owner:
                if line.startswith(b".L") and owner_base in TARGETS and line.rstrip()==b".L"+owner+b"_loop:":
                    out.write(line)
                    out.write(bump("loop:"+owner.decode().split("_FID_")[0]+":"+owner_name))
                    continue
                if b"FID_" in line and not line.startswith(b"."):
                    m=CALL.fullmatch(line)
                    if m:
                        target=canonical(decode(m[1]))
                        if target in HOT_CALLERS and owner_base!=target:
                            caller="continuation" if owner_name.startswith("$p111.k.") else owner_base
                            out.write(bump("call:"+target+":"+caller))
            out.write(line)
    return {"counters":list(ids),"staticSites":static,"stageSites":gates}

def build(out, directory):
    out.mkdir(parents=True,exist_ok=False)
    listing=directory/"program.s.gz"
    receipt=json.loads((directory/"report.json").read_text())
    runtime=P201/"runtime01/runtime.o"
    assert sha(runtime)==json.loads((P201/"p202acquire01/results.json").read_text())["productRuntimeSha256"]
    for mode in ("stock","marks","counts"):
        with tempfile.TemporaryDirectory(dir=out) as tmp:
            tmp=Path(tmp)
            obj=tmp/"compiler.o"
            with subprocess.Popen(["as","--64","-o",str(obj),"-"],stdin=subprocess.PIPE) as assembler:
                with assembler.stdin:
                    schema=assemble(listing,mode,assembler.stdin)
                if assembler.wait(): raise RuntimeError("assembler failed: "+mode)
            if mode!="stock":
                assert set(STAGES[1:-1])<=schema["stageSites"].keys()
            (tmp/"dimensions.h").write_text(f"#define P203_STAGES {len(STAGES)}\n#define P203_COUNTERS {max(1,len(schema['counters']))}\n")
            cmd=[REF["jobs"][1]["command"][0],"-no-pie",str(obj),str(runtime),"-pthread","-lm","-o",str(out/mode)]
            if mode!="stock":cmd[2:2]=["-O2","-I",str(tmp),str(HERE/"probe.c")]
            subprocess.run(cmd,check=True)
        (out/(mode+".json")).write_text(json.dumps(dict(stages=STAGES,**schema,elfSha256=sha(out/mode),listing=receipt),indent=2)+"\n")

if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("out",type=Path);p.add_argument("listing",type=Path)
    args=p.parse_args();build(args.out,args.listing)
