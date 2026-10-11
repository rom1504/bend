#!/usr/bin/env python3
"""Source-only P69-007: private two-word scheduler island around Map.bit.go."""
from __future__ import annotations
import argparse
import difflib
import hashlib
import json
import re
from pathlib import Path


def fid(name: str) -> str:
    return "FID_" + "".join(f"{ord(c)}_" for c in name)


def pin(path: Path) -> dict:
    data = path.read_bytes()
    return dict(path=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def section(source: str, name: str) -> str:
    start = source.index("  WL_CASE(" + name + ")\n")
    end = source.index("  WL_CASE(", start + 10)
    return source[start:end]


def once(source: str, old: str, new: str) -> str:
    assert source.count(old) == 1, (source.count(old), old[:150])
    return source.replace(old, new, 1)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    original = args.input.read_text()
    source = original
    edits = []

    def edit(old: str, new: str, reason: str) -> None:
        nonlocal source
        source = once(source, old, new)
        edits.append(dict(reason=reason, before=old, after=new))

    go = fid("$direct.Map.bit.go")
    private = "FID_P69_MAP_BIT_GO_WORDS"
    rec = "FID_P69_MAP_BIT_GO_RECONSTRUCT"
    box = "FID_P69_MAP_BIT_GO_BOX"
    old_go = section(source, go)
    assert old_go.count("WL_JMP(" + go + ");") == 1
    assert old_go.count("heap_alloc(e, cls_fit(2))") == 1
    assert old_go.count("ctr_take(e,") == 1
    assert old_go.count("ERR_FIDS") == 2
    for name in ["Map.bit.chr", "Map.bit.go.chr", "Map.bit.go.rec"]:
        token = "NF_" + fid("$product." + name)
        assert source.count(token + "(") == 2, (name, "expected uncalled existing worker")

    new_go = once(old_go, "WL_CASE(" + go + ")", "WL_CASE(" + private + ")")
    new_go = once(new_go, "WL_JMP(" + go + ");", "WL_JMP(" + private + ");")
    old_base = """    u64 nd_25506 = heap_alloc(e, cls_fit(2));
    e.mem[nd_25506 + 0] = rfc_seal(e, v_4294941791);
    e.mem[nd_25506 + 1] = rfc_seal(e, v_4294941790);
    r0 = term_ctr(CID_TUPLE, nd_25506);
    WL_RETN(1);"""
    new_go = once(new_go, old_base, """    r0 = v_4294941791;
    r1 = v_4294941790;
    WL_RETN(2);""")
    # Exactly the zero-index arm: retain its existing argument order/checkpoints,
    # call the already-admitted product workers, then return both result words.
    arm_start = new_go.index("    Term v_4294941781 = v_4294941784;")
    arm_end = new_go.index("    WL_JMP(" + fid("$direct.Map.bit.chr") + ");", arm_start)
    arm_end += len("    WL_JMP(" + fid("$direct.Map.bit.chr") + ");")
    old_arm = new_go[arm_start:arm_end]
    assert old_arm.count("task_node(") == 1
    chr_worker = "NF_" + fid("$product.Map.bit.chr")
    cons_worker = "NF_" + fid("$product.Map.bit.go.chr")
    new_arm = f"""    Term v_4294941781 = v_4294941784;
    if (!seq && err_seen(e.mem)) {{ return 0; }}
    Term v_4294941778 = v_4294941785;
    if (!seq && err_seen(e.mem)) {{ return 0; }}
    Term v_4294941777 = v_4294941782;
    if (!seq && err_seen(e.mem)) {{ return 0; }}
    Term p69_chr[2], p69_cons[2];
    if (!{chr_worker}(e, seq, p69_chr, v_4294941778, v_4294941777)) {{ return 0; }}
    if (!{cons_worker}(e, seq, p69_cons, v_4294941781, p69_chr[0], p69_chr[1])) {{ return 0; }}
    r0 = p69_cons[0];
    r1 = p69_cons[1];
    WL_RETN(2);"""
    new_go = once(new_go, old_arm, new_arm)
    old_rec = fid("native_k_25524")
    assert new_go.count(old_rec) == 3
    new_go = new_go.replace(old_rec, rec)
    assert new_go.count("ERR_FIDS") == old_go.count("ERR_FIDS")
    assert new_go.count("ctr_take(e,") == old_go.count("ctr_take(e,")

    helper = "NF_" + fid("$product.Map.bit.go.rec")
    continuations = f"""
  WL_CASE({rec})
  {{
    WL_POPN(1);
    Term p69_char = STK(0);
    Term p69_string = r0;
    Term p69_bit = r1;
    WL_OPEN
    Term p69_result[2];
    if (!{helper}(e, seq, p69_result, p69_char, p69_string, p69_bit)) {{ return 0; }}
    r0 = p69_result[0];
    r1 = p69_result[1];
    WL_RETN(2);
  }}}}

  WL_CASE({box})
  {{
    Term p69_string = r0;
    Term p69_bit = r1;
    WL_OPEN
    u64 p69_box = heap_alloc(e, cls_fit(2));
    e.mem[p69_box + 0] = rfc_seal(e, p69_string);
    e.mem[p69_box + 1] = rfc_seal(e, p69_bit);
    r0 = term_ctr(CID_TUPLE, p69_box);
    WL_RETN(1);
  }}}}

"""
    wrapper = f"""  WL_CASE({go})
  {{
#if !DEVICE
    WL_OPEN
    if (seq) {{
      WL_ROOM(1);
      STK(0) = {box};
      WL_PUSHN(1);
    }} else {{
      u64 p69_task = task_node(e, {box}, WL_CONT, WL_IDX, 1);
      WL_CONT = term_tsk({box}, p69_task);
      WL_IDX = 0;
    }}
    WL_JMP({private});
#else
""" + old_go.split("  {\n", 1)[1].rsplit("  }}", 1)[0] + "#endif\n  }}\n\n"
    replacement = wrapper + "#if !DEVICE\n" + new_go + continuations + "#endif\n\n"
    edit(old_go, replacement, "Generic boxed host wrapper plus private two-word recursive scheduler island; original device body retained.")

    # Insert IDs before the four runtime-reserved IDs, preserving every existing
    # user ID. Tables contain user+IO/CloApply rows, excluding EXIT and ENTER.
    reserved = "#define FID_IO_EMIT 942\n#define BEND_CLO_APPLY 943\n#define FID_EXIT 944\n#define FID_ENTER 945\n"
    edit(reserved,
         f"#define {private} 942\n#define {rec} 943\n#define {box} 944\n"
         "#define FID_IO_EMIT 945\n#define BEND_CLO_APPLY 946\n#define FID_EXIT 947\n#define FID_ENTER 948\n",
         "Three new private IDs; shift symbolic runtime-reserved IDs.")
    for table, rows in [("ARITY", [3, 3, 2]), ("FLAG", [2, 2, 2]), ("RESW", [0, 2, 2])]:
        pattern = r"CONSTV u8 FID_" + table + r"_T\[\] = \{ (.*?) \};"
        match = re.search(pattern, source)
        assert match
        values = [int(x) for x in match[1].split(",")]
        assert len(values) == 944
        values[942:942] = rows
        changed = f"CONSTV u8 FID_{table}_T[] = {{ " + ", ".join(map(str, values)) + " };"
        edit(match[0], changed, f"Private {table} metadata: {rows}; continuation arity includes returned words.")
    edit(" WL_X(FID_IO_EMIT) WL_X(BEND_CLO_APPLY) WL_X(FID_EXIT)",
         f" WL_X({private}) WL_X({rec}) WL_X({box}) WL_X(FID_IO_EMIT) WL_X(BEND_CLO_APPLY) WL_X(FID_EXIT)",
         "Dispatch table includes new private host entries in ID order.")
    edit("#define WL_RESW 1\n", "#define WL_RESW 2\n", "Reserve storage for two-word returns.")
    edit("#define WL_SAVE(V) (V)[0] = r0; \n", "#define WL_SAVE(V) (V)[0] = r0; (V)[1] = r1; \n", "Preserve both result registers at scheduler exit.")
    edit("#define WL_TAKE(V) r0 = (V)[0]; \n", "#define WL_TAKE(V) r0 = (V)[0]; r1 = (V)[1]; \n", "Restore both result registers when resuming task continuations.")

    recovered = source
    for record in reversed(edits):
        recovered = once(recovered, record["after"], record["before"])
    assert recovered == original
    output = args.out / "program.c"
    output.write_text(source)
    report = dict(kind="phase69-map-product-island-v1", targetExecuted=False,
                  producer=pin(Path(__file__)), hypothesis=pin(Path("experiments/phase69/P69-007-multiword-scheduler-products.md")),
                  input=pin(args.input), output=pin(output), edits=edits,
                  reverseEditsRecoverInput=True,
                  scope="Saved-C diagnostic only; host private two-word island. Production integration, raw error behavior and CPU/device qualification remain unproved.")
    (args.out / "derivation.json").write_text(json.dumps(report, indent=2) + "\n")
    (args.out / "program.diff").write_text("".join(difflib.unified_diff(original.splitlines(True), source.splitlines(True), fromfile="before.c", tofile="island.c")))
    assert args.input.read_text() == original
    print(json.dumps(dict(targetExecuted=False, output=str(output), edits=len(edits))))


if __name__ == "__main__":
    main()
