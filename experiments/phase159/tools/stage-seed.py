#!/usr/bin/env python3
"""Prepare, never compile/run, the pinned historical bendc diagnostic seed."""
import argparse
import hashlib
import json
from pathlib import Path
import re

REPO = Path(__file__).resolve().parents[3]
PIN = "9c54842eb5756803af599583ca49870d1e09186a"
SEED_SHA = "039673e7cd0a3f8534b30b44af6256b1e957e473814a6337b43e4ba687e90db2"
RT_SHA = "60fe68f74102565f96947c0117bd60a4c613daf03b8ad901cbd0734509d7bb09"
# label, exact C name, arity, input list argument, output list kind
STAGES = [
    ("Gen.program", "F_Gen_dprogram", 4, 0, None),
    ("Lo.program", "F_Lo_dprogram", 2, 1, "decl"),
    ("Opt.lowers", "F_Opt_dlowers", 3, 2, "od"),
    ("Opt.inls+simps.fused", "F_Opt_dsimps_x37f2732048478x2679117276", 3, 2, "od"),
    ("Opt.spec", "F_Opt_dspec", 2, 1, "od"),
    ("Opt.fuse", "F_Opt_dfuse", 2, 1, "od"),
    ("Opt.raises", "F_Opt_draises", 1, 0, "decl"),
    ("G.new", "F_G_dnew", 1, 0, None),
    ("Dps.build", "F_Dps_dbuild", 3, 1, None),
    ("Pick.decls", "F_Pick_ddecls", 1, 0, "decl"),
    ("LM.decls", "F_LM_ddecls", 2, 1, "decl"),
    ("Lex.all", "F_Lex_dall", 1, None, None),
    ("Gen.program.fin", "F_Gen_dprogram_dfin", 3, None, None),
]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def checked(path, expected):
    data = path.read_bytes()
    if digest(data) != expected:
        raise ValueError(f"input hash mismatch: {path}")
    return data.decode("utf-8")


def function(text, name, arity):
    params = ", ".join(f"V a{i}" for i in range(arity))
    signature = f"static V {name}({params}) {{"
    starts = [m.start() for m in re.finditer(re.escape(signature), text)]
    if len(starts) != 1:
        raise ValueError(f"expected one exact definition signature: {signature}")
    start = starts[0]
    opening = start + len(signature) - 1
    depth, state, i = 1, "code", opening + 1
    while i < len(text) and depth:
        c, pair = text[i], text[i:i + 2]
        if state == "code":
            if pair in ("//", "/*"):
                state = pair
                i += 2
                continue
            if c in ('"', "'"):
                state = c
            elif c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
        elif state in ('"', "'"):
            if c == "\\":
                i += 2
                continue
            if c == state:
                state = "code"
        elif state == "//" and c == "\n":
            state = "code"
        elif state == "/*" and pair == "*/":
            state = "code"
            i += 2
            continue
        i += 1
    if depth or state != "code":
        raise ValueError(f"unterminated C body: {name}")
    return start, i, params, text[start:i]


def header(allocations):
    labels = ["outside_stages"] + [s[0] for s in STAGES]
    prefix = (
        "/* Private Phase159 diagnostic; not a production runtime. */\n"
        "#include <inttypes.h>\n"
        f"#define P159_N {len(labels)}\n"
        f"#define P159_ALLOCATIONS {int(allocations)}\n"
        "static const char *p159_names[P159_N] = {"
        + ",".join(json.dumps(n) for n in labels) + "};\n"
    )
    return prefix + r'''
typedef struct {
  _Atomic uint64_t calls, inclusive_ns, exclusive_ns, input_items, output_items;
  _Atomic uint64_t output_core, output_keep, allocation_calls, requested_words;
} P159Row;
static P159Row p159_rows[P159_N];
static _Atomic uint64_t p159_gen_def_calls, p159_opt_lower_calls;
static _Atomic uint64_t p159_opt_lower_core, p159_opt_lower_keep, p159_errors;
static int p159_count_allocs;
typedef struct P159Frame {
  struct P159Frame *parent;
  uint64_t start, children;
  unsigned stage;
} P159Frame;
static _Thread_local P159Frame *p159_top;
static uint64_t p159_cpu(void) {
  struct timespec ts;
  if (clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ts) != 0) {
    atomic_fetch_add_explicit(&p159_errors, 1, memory_order_relaxed);
    return 0;
  }
  return (uint64_t)ts.tv_sec * 1000000000ull + (uint64_t)ts.tv_nsec;
}
static void p159_enter(P159Frame *f, unsigned stage) {
  f->parent = p159_top; f->children = 0; f->stage = stage;
  atomic_fetch_add_explicit(&p159_rows[stage].calls, 1, memory_order_relaxed);
  p159_top = f; f->start = p159_cpu();
}
static void p159_leave(P159Frame *f) {
  uint64_t end = p159_cpu();
  uint64_t dt = end >= f->start ? end - f->start : 0;
  if (p159_top != f || end < f->start || f->children > dt)
    atomic_fetch_add_explicit(&p159_errors, 1, memory_order_relaxed);
  atomic_fetch_add_explicit(&p159_rows[f->stage].inclusive_ns, dt, memory_order_relaxed);
  atomic_fetch_add_explicit(&p159_rows[f->stage].exclusive_ns,
    dt >= f->children ? dt - f->children : 0, memory_order_relaxed);
  p159_top = f->parent;
  if (f->parent) f->parent->children += dt;
}
static inline void p159_alloc(size_t words) {
  if (!p159_count_allocs) return;
  unsigned s = p159_top ? p159_top->stage : 0;
  atomic_fetch_add_explicit(&p159_rows[s].allocation_calls, 1, memory_order_relaxed);
  atomic_fetch_add_explicit(&p159_rows[s].requested_words, words, memory_order_relaxed);
}
#define P159_GET(p) atomic_load_explicit(&(p), memory_order_relaxed)
static void p159_report(void) {
  struct timespec ts = {0, 0};
  if (clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &ts) != 0)
    atomic_fetch_add_explicit(&p159_errors, 1, memory_order_relaxed);
  fprintf(stderr, "{\"kind\":\"phase159-bendc-stages\",\"version\":1,"
    "\"clock\":\"CLOCK_THREAD_CPUTIME_ID\",\"inclusive_not_additive\":true,"
    "\"allocation_hook\":%s,\"count_allocations\":%s,\"process_cpu_ns\":%" PRIu64 ","
    "\"gen_def_calls\":%" PRIu64 ",\"opt_lower_calls\":%" PRIu64 ","
    "\"opt_lower_core\":%" PRIu64 ",\"opt_lower_keep\":%" PRIu64 ","
    "\"diagnostic_errors\":%" PRIu64 ",\"rows\":[",
    P159_ALLOCATIONS ? "true" : "false",
    p159_count_allocs ? "true" : "false",
    (uint64_t)ts.tv_sec * 1000000000ull + (uint64_t)ts.tv_nsec,
    P159_GET(p159_gen_def_calls), P159_GET(p159_opt_lower_calls),
    P159_GET(p159_opt_lower_core), P159_GET(p159_opt_lower_keep), P159_GET(p159_errors));
  for (unsigned i = 0; i < P159_N; i++) {
    P159Row *r = &p159_rows[i];
    fprintf(stderr, "%s{\"stage\":\"%s\",\"calls\":%" PRIu64
      ",\"inclusive_ns\":%" PRIu64 ",\"exclusive_ns\":%" PRIu64
      ",\"input_items\":%" PRIu64 ",\"output_items\":%" PRIu64
      ",\"output_core\":%" PRIu64 ",\"output_keep\":%" PRIu64
      ",\"allocation_calls\":%" PRIu64 ",\"requested_words\":%" PRIu64 "}",
      i ? "," : "", p159_names[i], P159_GET(r->calls), P159_GET(r->inclusive_ns),
      P159_GET(r->exclusive_ns), P159_GET(r->input_items), P159_GET(r->output_items),
      P159_GET(r->output_core), P159_GET(r->output_keep),
      P159_GET(r->allocation_calls), P159_GET(r->requested_words));
  }
  fputs("]}\n", stderr);
}
__attribute__((constructor)) static void p159_install(void) {
  const char *enabled = getenv("P159_COUNT_ALLOCS");
  p159_count_allocs = P159_ALLOCATIONS && enabled && strcmp(enabled, "1") == 0;
  if (atexit(p159_report) != 0) abort();
}
'''


LIST_HELPER = r'''
/* Only called on source-authenticated List<Decl> / List<OD> fields. */
static uint64_t p159_list(V xs, unsigned stage, int output, int od) {
  uint64_t n = 0, core = 0, keep = 0;
  while (xs != IMM(0)) {
    if ((xs & 1) || TAG(xs) != 1 || n == 10000000ull) {
      atomic_fetch_add_explicit(&p159_errors, 1, memory_order_relaxed);
      break;
    }
    if (od) {
      V d = FLD(xs, 0);
      if (d & 1) atomic_fetch_add_explicit(&p159_errors, 1, memory_order_relaxed);
      else if (TAG(d) == 0) core++;
      else if (TAG(d) == 1) keep++;
      else atomic_fetch_add_explicit(&p159_errors, 1, memory_order_relaxed);
    }
    n++; xs = FLD(xs, 1);
  }
  if (output) {
    atomic_fetch_add_explicit(&p159_rows[stage].output_items, n, memory_order_relaxed);
    atomic_fetch_add_explicit(&p159_rows[stage].output_core, core, memory_order_relaxed);
    atomic_fetch_add_explicit(&p159_rows[stage].output_keep, keep, memory_order_relaxed);
  } else atomic_fetch_add_explicit(&p159_rows[stage].input_items, n, memory_order_relaxed);
  return n;
}
'''


def prepare(source, runtime, allocations):
    edits, bindings = [], []
    for sid, (label, name, arity, input_arg, output) in enumerate(STAGES, 1):
        start, end, params, original = function(source, name, arity)
        internal = "p159_body_" + name
        body = original.replace("static V " + name + "(", "static V " + internal + "(", 1)
        args = ", ".join(f"a{i}" for i in range(arity))
        # Counts are outside the wrapped body's interval, but nested observers
        # can remain inside a parent's interval. This is recorded in the method.
        pre = f"  p159_list(a{input_arg}, {sid}, 0, 0);\n" if input_arg is not None else ""
        post = f"  p159_list(result, {sid}, 1, {int(output == 'od')});\n" if output else ""
        wrapper = (f"\nstatic V {name}({params}) {{\n{pre}"
                   f"  P159Frame frame; p159_enter(&frame, {sid});\n"
                   f"  V result = {internal}({args});\n"
                   f"  p159_leave(&frame);\n{post}  return result;\n}}")
        edits.append((start, end, body + wrapper))
        bindings.append({"stage": label, "function": name, "signature": params,
                         "original_sha256": digest(original.encode()),
                         "input_list_arg": input_arg, "output_list": output})
    for name, arity, counter in [("F_Gen_ddef", 2, "p159_gen_def_calls"),
                                  ("F_Opt_dlower", 3, "p159_opt_lower_calls")]:
        start, end, params, original = function(source, name, arity)
        internal = "p159_counted_" + name
        body = original.replace("static V " + name + "(", "static V " + internal + "(", 1)
        after = ""
        if name == "F_Opt_dlower":
            after = ("  if (!(result & 1) && TAG(result) == 0) atomic_fetch_add_explicit(&p159_opt_lower_core, 1, memory_order_relaxed);\n"
                     "  else if (!(result & 1) && TAG(result) == 1) atomic_fetch_add_explicit(&p159_opt_lower_keep, 1, memory_order_relaxed);\n"
                     "  else atomic_fetch_add_explicit(&p159_errors, 1, memory_order_relaxed);\n")
        wrapper = (f"\nstatic V {name}({params}) {{\n"
                   f"  atomic_fetch_add_explicit(&{counter}, 1, memory_order_relaxed);\n"
                   f"  V result = {internal}({', '.join(f'a{i}' for i in range(arity))});\n"
                   f"{after}  return result;\n}}")
        edits.append((start, end, body + wrapper))
        bindings.append({"counter": counter, "function": name,
                         "original_sha256": digest(original.encode())})
    for start, end, replacement in sorted(edits, reverse=True):
        source = source[:start] + replacement + source[end:]
    anchor = '#include "bendrt.h"\n#endif\n'
    if source.count(anchor) != 1:
        raise ValueError("runtime include anchor mismatch")
    source = source.replace(anchor, anchor + LIST_HELPER, 1)
    source = '#ifdef BEND_RT_SPLIT\n#error Phase159 diagnostics require the private monolithic runtime\n#endif\n' + source
    anchor = "typedef uint64_t V;"
    if runtime.count(anchor) != 1:
        raise ValueError("runtime diagnostic include anchor mismatch")
    runtime = runtime.replace(anchor, '#include "p159-diagnostic.h"\n\n' + anchor, 1)
    if allocations:
        anchor = "static inline V *gc_alloc_x(size_t w, int atomic, int hole) {"
        if runtime.count(anchor) != 1:
            raise ValueError("allocator signature mismatch")
        runtime = runtime.replace(anchor, anchor + "\n  p159_alloc(w);", 1)
    return source, runtime, bindings


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, default=REPO / "selfhost/build/phase158/historical")
    parser.add_argument("--out", type=Path, required=True, help="new directory; must not exist")
    parser.add_argument("--allocations", action="store_true", help="add allocation hooks enabled at runtime only by P159_COUNT_ALLOCS=1")
    args = parser.parse_args()
    source_root, out = args.source_root.resolve(), args.out.resolve()
    if out.exists():
        raise ValueError(f"output must be fresh: {out}")
    source = checked(source_root / "seed/bendc.c", SEED_SHA)
    runtime = checked(source_root / "rt/bendrt.h", RT_SHA)
    generated, modified_runtime, bindings = prepare(source, runtime, args.allocations)
    files = {"program.c": generated, "bendrt.h": modified_runtime,
             "p159-diagnostic.h": header(args.allocations)}
    manifest = {
        "kind": "phase159-bendc-stage-preparation", "version": 1, "commit": PIN,
        "source_root": str(source_root), "input_seed_sha256": SEED_SHA,
        "input_runtime_sha256": RT_SHA, "script_sha256": digest(Path(__file__).read_bytes()),
        "allocation_hook": args.allocations, "bindings": bindings,
        "generated": {name: {"bytes": len(text.encode()), "sha256": digest(text.encode())}
                      for name, text in files.items()},
        "method": {
            "timing": "Synchronous pure function bodies, CLOCK_THREAD_CPUTIME_ID; inclusive totals overlap. Exclusive subtracts nested measured intervals only.",
            "scope": "Gen.program includes deferred Gen actions forced inside its body; Gen.def is call-count-only because it returns a Gen action.",
            "counts": "List lengths are aggregate across calls, not unique declarations. OCore=tag0 and OKeep=tag1 in List Con tag1/Nil IMM0, authenticated by pinned C.",
            "observer_cost": "List traversals sit outside their own stage interval but can enter parent exclusive time; wrappers, clocks, atomics and changed stack roots perturb execution.",
            "allocations": "--allocations installs gc_alloc_x hooks, enabled only by P159_COUNT_ALLOCS=1 at runtime (unset/0 disables increments). Counts are entries/requested words before size-class rounding, attributed exclusively to innermost synchronous TLS stage. Outside work uses stage0. Not system malloc counts or lifetime provenance. Disabled hooks still add a branch.",
            "threads": "TLS stack and atomic totals support concurrent calls, but stage clocks omit deferred work on other threads. Use --threads 1 and --no-check for intended attribution.",
            "gate": "Require exit0, exact original seed stdout, exactly one diagnostic JSON on stderr, diagnostic_errors0, and retained clean-vs-diagnostic overhead; no speed result from instrumented timings.",
            "failure": "atexit report is not guaranteed after abort/signal/_exit; missing report is a failed capture. Report may also occur on ordinary error exit; caller must validate status.",
            "build": "Pinned clang -O2 -w -I OUT OUT/program.c -o OUT/program -lm -lpthread; no split runtime. Preparation performs no build/run."
        }
    }
    out.mkdir(parents=True, exist_ok=False)
    for name, text in files.items():
        (out / name).write_text(text)
    (out / "preparation.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps({"out": str(out), "manifest": str(out / "preparation.json"),
                      "generated": manifest["generated"]}))


if __name__ == "__main__":
    main()
