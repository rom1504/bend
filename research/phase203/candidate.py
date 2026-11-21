"""Stage the narrow register-choice experiment and a small independent control API."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
from assembly import ROOT, SOURCE, sha

HERE=Path(__file__).resolve().parent
ANCHOR=b"@unsafe\ndef x190_l_counted("
CALL=b"x190_l_candidates(nt_reverse(String,names,[]),reads,slots,1,32,missing(),[])"
EXPORTS=["x190_l_candidates","x203_candidates","p111v_put","p111v_get","missing","da"]
def prepare(out):
    out.mkdir(parents=True,exist_ok=False)
    src=SOURCE.read_bytes()
    assert sha(SOURCE)=="42dbbd2c900b9f51c79c337e4226a219b2bc83aaed06692d601bb9e17e373aa8"
    assert src.count(ANCHOR)==1 and src.count(CALL)==2
    new=src.replace(ANCHOR,(HERE/"rank.bend").read_bytes()+b"\n"+ANCHOR).replace(CALL,b"x203_candidates(nt_reverse(String,names,[]),reads,slots)")
    (out/"compiler.bend").write_bytes(new)
    convert=ROOT/"research/phase201/elf/standalone.py"
    mod=importlib.util.spec_from_file_location("phase201_fixture",convert);m=importlib.util.module_from_spec(mod);mod.loader.exec_module(m)
    roots=b"\n".join(n.encode() for n in EXPORTS)
    data,_=m.slice_source(new,roots)
    (out/"control.bend").write_bytes(data[:-len(roots)])
    (out/"exports.json").write_text(json.dumps(dict(kind="bend-hosted-api-exports",version=1,protocol="typed-api-v1",targets=["qbe"],exports=EXPORTS))+"\n")
    print(sha(out/"compiler.bend"),sha(out/"control.bend"))
if __name__=="__main__":
    prepare(Path(sys.argv[1]))
