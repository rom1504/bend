"""Compose three disjoint ELF changes on exactly the qualified x86 compiler source."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import symbols

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = ROOT / "selfhost/build/phase198/progress-portfolio01/compiler.bend"

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def run(out):
    raw = BASE.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == "72061fa57c75993b59eaf42e18c6b923eebea640c352d0f7b9cd1d27ce7be91d"
    elf = load("elf_overlay", HERE.parent / "elf/compose.py")
    fixups = load("branch_overlay", HERE.parent / "algorithm/prepare.py")
    source, changes = elf.apply(raw,list(elf.RULES))
    extra = (HERE.parent / "algorithm/reverse-fixup.bend").read_bytes().rstrip() + b"\n\n"
    assert source.count(fixups.ANCHOR) == source.count(fixups.HOOK) == 1
    source = source.replace(fixups.ANCHOR,extra+fixups.ANCHOR).replace(
        fixups.HOOK,fixups.HOOK.replace(b"x187_build_finish",b"x201f_finish"))
    result=symbols.apply(source.decode()).encode()
    out.mkdir(parents=True,exist_ok=False)
    (out/"compiler.bend").write_bytes(result)
    print(json.dumps({"bytes":len(result),"sha256":hashlib.sha256(result).hexdigest(),"elfDeclarations":changes}))

if __name__ == "__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--out",type=Path,required=True)
    run(p.parse_args().out)
