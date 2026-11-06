#!/usr/bin/env python3
"""Prepare exact private runtime treatments; never compile or run a target."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RUNTIME_SHA = "aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333"


def pin(path):
    path = path.resolve()
    data = path.read_bytes()
    return {"file": str(path), "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def replace_once(text, before, after):
    assert text.count(before) == 1, before
    return text.replace(before, after, 1)


FLAGS = """/* Phase169 private experiment. Neither flag changes the public ABI.
 * The treatments apply only to the already qualified single-mutator policy.
 * Atomic/device configurations retain their complete original implementation. */
#ifndef P169_WARM_SPAN
#define P169_WARM_SPAN 0
#endif
#ifndef P169_SHARED_TAKE
#define P169_SHARED_TAKE 0
#endif
#if (P169_WARM_SPAN != 0 && P169_WARM_SPAN != 1) || \\
    (P169_SHARED_TAKE != 0 && P169_SHARED_TAKE != 1)
#error "Phase169 flags must be zero or one"
#endif
#if P169_WARM_SPAN && P144_SINGLE_MUTATOR_RFC && !DEVICE
#define P169_SPAN_OUTLINE static __attribute__((noinline)) PRESERVE(preserve_most)
#else
#define P169_SPAN_OUTLINE OUTLINE
#endif

"""

FAST = """#if P169_SHARED_TAKE && P144_SINGLE_MUTATOR_RFC && !DEVICE
  /* ctr_take already copied every field before this branch. The output is the
   * ordinary disjoint writable output buffer required by the take ABI. Read
   * those copies instead of loading the same payload from the heap again.
   * Keep the original left-to-right retain, overflow and invalid-child checks.
   * A shared, nontrivial parent cannot reach zero: the sole mutator performs
   * only child increments before this decrement. Subtract from its CURRENT
   * count (never restore the earlier snapshot), preserving aliased children.
   * Count-zero/malformed trivial handles retain the original generic route. */
  if ((cell & RFC_CNT) > 1 && !term_triv(t)) {
    for (u32 j = 0; j < n; j += 1) {
      Term f = out[j];
      if (term_rfc(f)) {
        rfc_bump(e, term_loc(f), 1);
      } else if (!term_triv(f)) {
        err_post(e.mem, ERR_RFCS);
      }
    }
    (void)p144_rfc_sub(a32_at(H, r), 1);
    return 0;
  }
#endif
"""


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    assert not out.exists(), "fresh preparation root required"
    original_path = ROOT / "selfhost/src/runtime/qbe/runtime.c"
    original = original_path.read_text()
    assert pin(original_path)["sha256"] == RUNTIME_SHA
    before1 = "OUTLINE void span_fade(Env e, Term t, Loc src, u32 n) {"
    after1 = FLAGS + "P169_SPAN_OUTLINE void span_fade(Env e, Term t, Loc src, u32 n) {"
    before2 = "  span_fade(e, t, src, n);\n  return 0;\n}"
    after2 = FAST + before2
    candidate = replace_once(replace_once(original, before1, after1), before2, after2)
    assert replace_once(replace_once(candidate, after2, before2), after1, before1) == original
    out.mkdir(parents=True)
    (out / "runtime.c").write_text(candidate)
    for filename in ("runtime.h", "primitives.h"):
        (out / filename).write_bytes((original_path.parent / filename).read_bytes())
    report_path = ROOT / "selfhost/build/phase152/native-n2/report.json"
    report = json.loads(report_path.read_text())
    assert report["complete"]
    for key in ("object", "binary", "runtime"):
        saved = report[key]
        actual = pin(Path(saved["file"]))
        assert actual["sha256"] == saved["sha256"] and actual["bytes"] == saved["bytes"], key
    compiler_object = report["object"]
    assets = json.loads((ROOT / "selfhost/manifests/assets-native.json").read_text())
    gcc_entry = assets["assets"]["linker"]
    gcc = Path(gcc_entry["file"])
    assert pin(gcc)["sha256"] == gcc_entry["sha256"]
    jobs = []
    for name, warm, shared, serial in [
        ("baseline", 0, 0, 1),
        ("warm", 1, 0, 1),
        ("shared", 0, 1, 1),
        ("both", 1, 1, 1),
        ("atomic-control", 0, 0, 0),
        ("atomic-flags", 1, 1, 0),
    ]:
        obj = out / (name + ".o")
        binary = out / name
        jobs.append({
            "label": name,
            "flags": {"warm": warm, "shared": shared, "singleMutator": serial},
            "compile": [str(gcc), "-O2", "-std=gnu11", "-ffp-contract=off",
                        f"-DP144_SINGLE_MUTATOR_RFC={serial}", f"-DP169_WARM_SPAN={warm}",
                        f"-DP169_SHARED_TAKE={shared}", "-c", str(out / "runtime.c"), "-o", str(obj)],
            "link": [str(gcc), "-no-pie", compiler_object["file"], str(obj), "-pthread", "-lm", "-o", str(binary)],
        })
    plan = {
        "kind": "phase169-runtime-private-variants", "version": 1,
        "targetsRun": False, "productionChanged": False,
        "inputs": [pin(Path(__file__)), pin(original_path), pin(report_path), compiler_object,
                   report["binary"], report["runtime"], pin(gcc)],
        "source": pin(out / "runtime.c"),
        "headers": [pin(out / f) for f in ("runtime.h", "primitives.h")],
        "edits": [{"before": before1, "after": after1}, {"before": before2, "after": after2}],
        "inverseExact": True, "jobs": jobs,
        "requiredChecks": [
            "baseline object bytes equal the qualified runtime object",
            "baseline linked binary bytes equal qualified Phase152 N2",
            "atomic-control and atomic-flags object bytes equal each other",
            "complete independent kernel outputs before timing",
            "shared aliases/duplicate child handles/static/unique/RFC-unique/overflow/error controls",
            "actual compiler full-output identity on clean small requests before full-source timing",
        ],
        "scope": "GCC-O2 unchanged from qualified runtime; no Clang substitution, QBE rebuild, semantic compiler change or ABI change",
    }
    (out / "plan.json").write_text(json.dumps(plan, indent=2) + "\n")
    print(json.dumps({"plan": str(out / "plan.json"), "source": plan["source"], "jobs": len(jobs)}))


if __name__ == "__main__":
    main()
