"""Check sliced old and new Bend implementations under one held-out fixture."""
import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
from prepare import ROOT, BASE, HERE

def run(out, candidate):
    out.mkdir(parents=True, exist_ok=False)
    upstream = ROOT/"selfhost/.bootstrap/upstream-phase182"
    bun = ROOT/"selfhost/.assets/bin/bun"
    spec=importlib.util.spec_from_file_location("fixture",ROOT/"research/phase201/elf/standalone.py")
    mod=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    common=["x185_copy_function","x190_l_fixed","x190_l_body","p111v_put","missing","x190_l_bit","x185_copy_write","x191_joint_reads","p111v_get"]
    def call(label, cmd):
        with (out/(label+".out")).open("xb") as f,(out/(label+".err")).open("xb") as e:
            subprocess.run(cmd,stdout=f,stderr=e,check=True)
    for label,src,extra in [("old",BASE,[]),("new",candidate,["x204_for_collection","x190_register_loop"])]:
        names=common+extra
        roots=b"\n".join(s.encode() for s in names)
        data,_=mod.slice_source(src.read_bytes(),roots)
        source=out/(label+".bend")
        source.write_bytes(data[:-len(roots)])
        exports=out/(label+".json")
        exports.write_text(json.dumps(dict(kind="bend-hosted-api-exports",version=1,protocol="typed-api-v1",targets=["qbe"],exports=names)))
        call(label,[bun,"selfhost/tools/build/hosted.mjs","acquire","--source",source,"--exports",exports,"--out",out/label,"--engine",bun,"--upstream",upstream])
    call("controls",[bun,HERE/"controls.mjs",out])

if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("out",type=Path);p.add_argument("candidate",type=Path);a=p.parse_args()
    run(a.out.resolve(),a.candidate.resolve())
