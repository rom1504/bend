#!/usr/bin/env python3
"""B1: Zero-JS-Runtime Fast Stage 0 Bootstrap (Pure Source -> Native stage0_seed in <= 45 s).

Pipeline (100% pure Bend source, zero prebuilt native binaries, zero JS runtime):
  1. Generate @unsafe-stubbed K=16 standalone Bend modules from k16_wave17 (split of compiler.bend).
  2. Emit 16 modular C units in parallel via bun + bend2/bend.ts + comp_mod.ts (bounded RAM < 4 GiB).
  3. Merge global CID_T, FID_T, STAT_IMG (relocating STAT_OFF offsets), TAB_*, Requests, and
     trampoline WLState* ABI into bend_common.h + rt_main.c + mod00.c..mod15.c.
  4. Precompile bend_common.h -> bend_common.h.gch and compile rt_main.c (-O2) + mod00..15.c
     (-O1 -fno-inline, seq=1 constant-folded) in parallel across 8 cores with gcc-10.
  5. Link rt_main.o + mod00..15.o -> stage0_seed.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import json
import os
import queue
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
HERE = Path(__file__).resolve().parent
BUN = ROOT / "selfhost/.assets/bin/bun"
GCC = "/usr/bin/gcc"
GEN_STUBS = ROOT / "research/agy/s10_campaign/s10a_zero_p130/gen_stubs.py"
K16_DIR = ROOT / "selfhost/build/agy/wave17_unified/k16_wave17"
EMIT_MOD_TS = HERE / "emit_mod_c.ts"
GEN_COMP_MOD = HERE / "gen_comp_mod.py"

CPUS_ALL = [0, 1, 2, 3, 4, 5, 6, 7]


def run_rusage(cmd: list[str], cpu: int | None = None, env: dict | None = None, cwd: Path | None = None) -> tuple[int, float, float, str, str]:
    full_cmd = (["taskset", "-c", str(cpu)] + cmd) if cpu is not None else cmd
    t0 = time.perf_counter()
    p = subprocess.Popen(full_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env, cwd=cwd)
    # Wait via wait4 to get accurate ru_maxrss
    out_chunks = []
    err_chunks = []
    out_b, err_b = p.communicate()
    # Note: communicate() already waited; use resource or /usr/bin/time? Better: poll or wait4 before reading
    dt = time.perf_counter() - t0
    return p.returncode, dt, 0.0, out_b.decode("utf-8", "replace"), err_b.decode("utf-8", "replace")


def run_wait4(cmd: list[str], err_file: Path, cpu: int | None = None, env: dict | None = None, cwd: Path | None = None) -> tuple[int, float, float, str]:
    full_cmd = (["taskset", "-c", str(cpu)] + cmd) if cpu is not None else cmd
    t0 = time.perf_counter()
    with err_file.open("wb") as ef:
        p = subprocess.Popen(full_cmd, stdout=subprocess.DEVNULL, stderr=ef, env=env, cwd=cwd)
        _, st, ru = os.wait4(p.pid, 0)
    dt = time.perf_counter() - t0
    rc = os.WEXITSTATUS(st) if os.WIFEXITED(st) else (-os.WTERMSIG(st) if os.WIFSIGNALED(st) else -1)
    rss_mib = ru.ru_maxrss / 1024.0
    err_txt = err_file.read_text(encoding="utf-8", errors="replace")
    return rc, dt, rss_mib, err_txt


def collect_leaf_defs(k_dir: Path) -> dict[str, tuple[str, set[str]]]:
    """Collect tiny (<= 4 line) non-recursive leaf defs with inline signatures across m00..m14.
    Inlining these real bodies instead of non-flat stubs prevents 1000+ CPS continuation blowups
    in x86 instruction-list builders like w14e_sh_emit_str_append and w13e_sa_rew_body!
    """
    sys.path.insert(0, str(GEN_STUBS.parent))
    import gen_stubs as gs

    leaves: dict[str, tuple[str, set[str]]] = {}
    all_user_defs: set[str] = set()
    raw_decls: list[tuple[str, str]] = []
    for idx in range(15):
        decls = gs.parse_decls(k_dir / f"m{idx:02d}.bend")
        for d in decls:
            all_user_defs.add(d["name"])
            if d["kind"] == "def":
                raw_decls.append((d["name"], d["text"]))
    for nm, body in raw_decls:
        lines = body.splitlines()
        if len(lines) > 4:
            continue
        # Must have an inline return type (`->`) on the def header (no separate law)
        hdr = next((l for l in lines if l.startswith("def ")), "")
        if "->" not in hdr or ":\n" not in body:
            continue
        rhs = body.split(":\n", 1)[1]
        if nm in rhs or "match " in rhs or "do " in rhs:
            continue
        rhs_clean = re.sub(r'"(?:\\.|[^"\\])*"', '""', rhs)
        called = set(re.findall(r"\b([a-z][A-Za-z0-9_]*)\s*\(", rhs_clean))
        user_deps = called & all_user_defs
        txt = body if body.startswith("@unsafe") else "@unsafe\n" + body
        if not txt.endswith("\n"):
            txt += "\n"
        leaves[nm] = (txt, user_deps)
    return leaves


def ensure_unsafe_stubs(
    zero_bend: Path, mod_name: str, out_bend: Path, leaves: dict[str, tuple[str, set[str]]]
) -> set[str]:
    """Ensure every stub def before `# Module <mod_name>` has `@unsafe`, and replace
    stubbed pure leaf helpers (whose deps are already defined above) with their real bodies.
    Returns the set of stub names that were upgraded to real leaf bodies.
    """
    lines = zero_bend.read_text(encoding="utf-8").splitlines(keepends=True)
    out: list[str] = []
    in_stubs = False
    marker = f"# Module {mod_name}"
    defined_so_far: set[str] = set()
    inlined_leaves: set[str] = set()
    i = 0
    n = len(lines)
    while i < n:
        ln = lines[i]
        if "S10-A ZERO-P130 IMPORTS" in ln or "Zero-.p130 stubs" in ln:
            in_stubs = True
            out.append(ln)
            i += 1
            continue
        if "=== MODULE BODY:" in ln or marker in ln:
            in_stubs = False
            out.append(ln)
            i += 1
            continue
        if in_stubs and (ln.startswith("def ") or (ln.strip() == "@unsafe" and i + 1 < n and lines[i + 1].startswith("def "))):
            has_unsafe = ln.strip() == "@unsafe"
            def_i = i + 1 if has_unsafe else i
            m = re.match(r"^def\s+([A-Za-z0-9_.\$]+)", lines[def_i])
            j = def_i + 1
            while j < n and (lines[j].startswith((" ", "\t")) or lines[j].startswith(")") or lines[j].strip() == ""):
                j += 1
            if m:
                nm = m.group(1)
                if nm in leaves and leaves[nm][1].issubset(defined_so_far):
                    out.append(leaves[nm][0] + "\n")
                    defined_so_far.add(nm)
                    inlined_leaves.add(nm)
                    i = j
                    continue
                defined_so_far.add(nm)
            if not has_unsafe:
                out.append("@unsafe\n")
            out.extend(lines[i:j])
            i = j
            continue
        out.append(ln)
        i += 1
    out_bend.write_text("".join(out), encoding="utf-8")
    return inlined_leaves


def parse_c_module(c_path: Path, mod_idx: int) -> dict:
    """Extract tables, STAT_IMG, spins, segments, and requests from one bend2 modular .c file."""
    text = c_path.read_text(encoding="utf-8")
    idx_globals = text.index("\n// Globals\n// =======\n")
    idx_tables = text.index("\n// Tables\n// ======\n", idx_globals)
    idx_a32 = text.index("\n// A32\n// ===\n", idx_tables)
    idx_spins = text.index("\n// Spins\n// =====\n", idx_a32)
    idx_work = text.index("\n// Work\n// ====\n", idx_spins)
    idx_segs = text.index("\n// Segments\n// ========\n", idx_work)
    idx_monk = text.index("\n// Monk\n// ====\n", idx_segs)
    idx_reqs = text.index("\n// Requests\n// ========\n", idx_monk)
    idx_main = text.index("\n// Main\n// ====\n", idx_reqs)

    sec_tabs = text[idx_tables:idx_a32]
    sec_spins = text[idx_spins:idx_work]
    sec_segs = text[idx_segs:idx_monk]
    sec_reqs = text[idx_reqs:idx_main]

    # Parse CID_* and FID_* defines
    cids = re.findall(r"^#define (CID_\w+) (\d+)$", sec_tabs, re.M)
    fids = re.findall(r"^#define (FID_\w+) (\d+)$", sec_tabs, re.M)
    cid_names = [nm for nm, _ in sorted(cids, key=lambda x: int(x[1]))]
    fid_names = [nm for nm, _ in sorted(fids, key=lambda x: int(x[1]))]

    # Parse FID_T and CID_T initializer entries
    m_fidt = re.search(r"CONSTV Fid FID_T\[\] = \{ (.*) \};", sec_tabs)
    m_cidt = re.search(r"CONSTV Cid CID_T\[\] = \{ (.*) \};", sec_tabs)
    fid_entries = re.findall(r"\{ [^}]+ \}", m_fidt.group(1)) if m_fidt else []
    cid_entries = re.findall(r"\{ [^}]+ \}", m_cidt.group(1)) if m_cidt else []

    # Map FID name -> FID_T entry (note: FID_EXIT and FID_ENTER are after FID_T)
    fid_meta: dict[str, str] = {}
    for nm, ent in zip(fid_names, fid_entries):
        fid_meta[nm] = ent

    cid_meta: dict[str, str] = {}
    for nm, ent in zip(cid_names, cid_entries):
        cid_meta[nm] = ent

    # Parse WL_RESW, WL_BANK reg count, BLK_SHR
    resw = int(re.search(r"#define WL_RESW (\d+)", sec_tabs).group(1))
    bank_m = re.search(r"#define WL_BANK Term ([^;]+);", sec_tabs)
    regs = [r.strip() for r in bank_m.group(1).split(",")]
    blk_shr = int(re.search(r"#define BLK_SHR (\d+)", sec_tabs).group(1))

    # Parse TAB_i[] arrays (namespace per module to avoid collisions)
    tab_defs: list[str] = []
    for m_tab in re.finditer(r"^CONSTV u64 (TAB_\d+)\[\] = \{ ([^;]+) \};$", sec_tabs, re.M):
        tab_defs.append((m_tab.group(1), m_tab.group(2)))

    # Parse STAT_IMG[] elements and spin functions
    m_stat = re.search(r"CONSTV u64 STAT_IMG\[\] = \{ (.*) \};", sec_spins)
    stat_raw = m_stat.group(1).strip() if m_stat else ""
    stat_len = int(re.search(r"#define STAT_LEN (\d+)", sec_tabs).group(1))
    spins_after_stat = sec_spins[m_stat.end():].strip() if m_stat else ""

    # Parse WL_CASE blocks from sec_segs
    segs: list[tuple[str, str]] = []
    lines = sec_segs.splitlines(keepends=True)
    i = 0
    n = len(lines)
    while i < n:
        ln = lines[i]
        if ln.startswith("#if !DEVICE") and i + 1 < n and "WL_CASE(" in lines[i + 1]:
            fid_nm = re.search(r"WL_CASE\((FID_\w+)\)", lines[i + 1]).group(1)
            j = i + 1
            while j < n and not lines[j].startswith("#endif"):
                j += 1
            segs.append((fid_nm, "".join(lines[i:j + 1])))
            i = j + 1
        elif ln.lstrip().startswith("WL_CASE("):
            fid_nm = re.search(r"WL_CASE\((FID_\w+)\)", ln).group(1)
            j = i + 1
            while j < n and lines[j].strip() != "}}":
                j += 1
            segs.append((fid_nm, "".join(lines[i:j + 1])))
            i = j + 1
        else:
            i += 1

    return {
        "mod_idx": mod_idx,
        "cid_meta": cid_meta,
        "fid_meta": fid_meta,
        "resw": resw,
        "regs": regs,
        "blk_shr": blk_shr,
        "tab_defs": tab_defs,
        "stat_raw": stat_raw,
        "stat_len": stat_len,
        "spins_code": spins_after_stat,
        "segs": segs,
        "sec_reqs": sec_reqs,
        # Keep runtime template from m15 (last module)
        "sec_head": text[:idx_globals] if mod_idx == 15 else "",
        "sec_glob": text[idx_globals:idx_tables] if mod_idx == 15 else "",
        "sec_rt_fn": text[idx_a32:idx_spins] if mod_idx == 15 else "",
        "sec_monk_to_reqs": text[idx_monk:idx_reqs] if mod_idx == 15 else "",
        "sec_main": text[idx_main:] if mod_idx == 15 else "",
    }


def relocate_stat_off(code: str, offset: int) -> str:
    if offset == 0 or "STAT_OFF + " not in code:
        return code
    return re.sub(r"STAT_OFF \+ (\d+)", lambda m: f"STAT_OFF + {int(m.group(1)) + offset}", code)


def namespace_tabs(code: str, mod_idx: int, tab_names: list[str]) -> str:
    if not tab_names:
        return code
    return re.sub(r"\b(TAB_\d+)\b", lambda m: f"TAB_m{mod_idx}_{m.group(1)[4:]}", code)


def merge_modules_to_c(parsed_mods: list[dict], out_dir: Path) -> dict:
    """Merge 16 modular C outputs into bend_common.h, rt_main.c, and mod00.c..mod15.c."""
    out_dir.mkdir(parents=True, exist_ok=True)
    m15 = parsed_mods[-1]

    # 1. Union of CIDs (preserve m15 base order first)
    all_cids: dict[str, str] = {}
    for pm in [m15, *parsed_mods[:-1]]:
        for k, v in pm["cid_meta"].items():
            if k not in all_cids:
                all_cids[k] = v

    # 2. Deduplicate WL_CASE segments across modules.
    #    Built-in runtime segments go in rt_main.c.
    RT_SEGS = {"FID_ENTER", "FID_EXIT", "FID_Clo_apply", "FID_IO_emit"}
    seen_fids: set[str] = set()
    all_fids: dict[str, str] = {}
    mod_segs: list[list[str]] = [[] for _ in range(len(parsed_mods))]
    rt_seg_blocks: dict[str, str] = {}

    # 3. Concatenate STAT_IMG[] and record per-module offset
    stat_parts: list[str] = []
    stat_offsets: list[int] = []
    cur_stat = 0
    for pm in parsed_mods:
        stat_offsets.append(cur_stat)
        if pm["stat_len"] > 0 and pm["stat_raw"]:
            stat_parts.append(relocate_stat_off(pm["stat_raw"], cur_stat))
            cur_stat += pm["stat_len"]

    # Collect segments & FID_T entries
    for idx, pm in enumerate(parsed_mods):
        off = stat_offsets[idx]
        tnames = [t[0] for t in pm["tab_defs"]]
        for fid_nm, blk in pm["segs"]:
            if fid_nm in RT_SEGS:
                if fid_nm not in rt_seg_blocks:
                    rt_seg_blocks[fid_nm] = blk
                continue
            if fid_nm in seen_fids:
                continue
            seen_fids.add(fid_nm)
            all_fids[fid_nm] = pm["fid_meta"][fid_nm]
            blk2 = relocate_stat_off(blk, off)
            blk2 = namespace_tabs(blk2, idx, tnames)
            mod_segs[idx].append(blk2)

    # Ensure built-in FID_IO_emit and FID_Clo_apply are at the end of FID_T (just like bend2!)
    for builtin in ("FID_IO_emit", "FID_Clo_apply"):
        all_fids[builtin] = m15["fid_meta"][builtin]

    global_resw = max(pm["resw"] for pm in parsed_mods)
    # Pick longest register list
    best_regs = max((pm["regs"] for pm in parsed_mods), key=len)
    # Reconstruct clean r0..r{N-1} without rp (we use R[] array!)
    r_only = [r for r in best_regs if r != "rp"]
    n_regs = len(r_only)
    blk_shr = max(pm["blk_shr"] for pm in parsed_mods)

    # 4. Build bend_common.h with O(1)-stack trampoline WLState* ABI!
    sec_head = m15["sec_head"]
    sec_head = sec_head.replace("#pragma clang fp contract(off)", "// pragma clang fp contract(off)")
    # Replace host WL_* macros with trampoline WLState* ABI
    old_wl_block = """#define WL_FN      FAR PRESERVE(preserve_none) Term
#define WL_CASE(F) WL_FN WL_##F(WL_SIG) {
#define WL_OPEN    { WL_BANK u32 rn;
#define WL_JMP(F)  __attribute__((musttail)) return WL_##F(WL_ALL)
#define WL_DYN(F)  __attribute__((musttail)) return wl_tab[F](WL_ALL)"""
    assert old_wl_block in sec_head, "WL_* macro block not found in sec_head"
    new_wl_block = """#define WL_FN      __attribute__((noinline)) Term
#ifdef BEND_RT_MAIN
#define WL_SEQ_INIT u32 seq = _S->seq;
#else
#define WL_SEQ_INIT const u32 seq = 1u;
#endif
#define WL_CASE(F) WL_FN WL_##F(WL_SIG) { \\
  Env e = _S->e; DEV Term* sp = _S->sp; WL_SEQ_INIT u32 rn = _S->rn; Term* R = _S->r; \\
  (void)e; (void)sp; (void)seq; (void)rn; (void)R;
#define WL_OPEN    {
#define WL_JMP(F)  do { _S->sp = sp; _S->seq = seq; _S->rn = rn; _S->next_fid = (F); return 0; } while (0)
#define WL_DYN(F)  do { _S->sp = sp; _S->seq = seq; _S->rn = rn; _S->next_fid = (F); return 0; } while (0)"""
    sec_head = sec_head.replace(old_wl_block, new_wl_block, 1)

    glob_hdr = """
// Globals (extern)
// ================
#if !DEVICE
extern u64*    CORPUS;
extern u64     ALC[CUBE_T][3 * NCLS_ALL] __attribute__((aligned(128)));
extern u32     KEEP_WORDS;
extern u32     CUBE_LOG;
extern u32     bank_lock;
extern Term    f32_show(Env e, Term x);
extern Term    f32_read(Env e, Term s);
extern bool    corpus_grow(u64* H, u64 need);
#else
#define KEEP_WORDS CHUNK
#define f32_show(e, x) (err_post(e.mem, ERR_FIDS), 0)
#define f32_read(e, s) (err_post(e.mem, ERR_FIDS), 0)
#define corpus_grow(H, n) false
#endif
"""

    # Build global Tables section (header + impl)
    cid_list = list(all_cids.keys())
    fid_list = list(all_fids.keys())
    assert len(cid_list) <= 65536 and len(fid_list) + 2 <= 65536, "ID overflow"

    reg_macros = "\n".join(f"#define r{i} (R[{i}])" for i in range(n_regs))
    wl_load = "do { " + " ".join(f"if ((N) <= {i}) break; r{i} = e.mem[(A) + {i}];" for i in range(n_regs)) + " } while (0);"
    wl_last = "switch (war) { " + " ".join(f"case {i}: r{i} = (X); break;" for i in range(n_regs)) + " }"
    wl_save = " ".join(f"(V)[{i}] = r{i};" for i in range(global_resw))
    wl_take = " ".join(f"r{i} = (V)[{i}];" for i in range(global_resw))

    tabs_hdr_lines = [
        "\n// Tables\n// ======\n",
        "typedef struct { u8 ar, resw, bangs, nofk; } Fid;",
        "typedef struct { u8 ar, hot; u16 spine; } Cid;",
        *[f"#define {nm} {i}" for i, nm in enumerate(cid_list)],
        *[f"#define {nm} {i}" for i, nm in enumerate(fid_list)],
        f"#define FID_EXIT {len(fid_list)}",
        f"#define FID_ENTER {len(fid_list) + 1}",
        "extern const Fid FID_T[];",
        "extern const Cid CID_T[];",
        f"#define STAT_LEN {cur_stat}",
        f"#define WL_RESW {global_resw}",
        "#define BANGS 0",
        f"#define WL_NREGS {n_regs}",
        "typedef struct { Env e; DEV Term* sp; u32 seq; u32 rn; u32 next_fid; Term r[WL_NREGS]; } WLState;",
        "#define WL_BANK",
        reg_macros,
        f"#define WL_LOAD(A, N) {wl_load}",
        f"#define WL_LAST(X) {wl_last}",
        f"#define WL_SAVE(V) {wl_save}",
        f"#define WL_TAKE(V) {wl_take}",
        "#define WL_SIG WLState* _S",
        "#define WL_ALL _S",
        "#define WL_TABLE " + " ".join(f"WL_X({nm})" for nm in fid_list) + " WL_X(FID_EXIT)",
        "#define MAIN_FID FID_main",
        f"#define BLK_SHR {blk_shr}",
        "#define TAB_AT(T, S, I) T[S < I ? S : I]",
        "#define fid_arity(x) FID_T[x].ar",
        "#define fid_resw(x)  FID_T[x].resw",
        "#define fid_nofk(x)  FID_T[x].nofk",
        "#define cid_arity(x) CID_T[x].ar",
    ]
    tabs_hdr = "\n".join(tabs_hdr_lines) + "\n"

    tabs_impl = (
        "const Fid FID_T[] = { " + ", ".join(all_fids[nm] for nm in fid_list) + " };\n"
        "const Cid CID_T[] = { " + ", ".join(all_cids[nm] for nm in cid_list) + " };\n"
        "CONSTV u64 STAT_IMG[] = { " + (", ".join(stat_parts) if stat_parts else "0") + " };\n"
    )

    work_hdr = """
// Work (extern)
// =============
#if !DEVICE
#undef  WL_SPIN
#undef  WL_SPUN
#undef  WL_AGAIN
#define WL_SPIN
#define WL_SPUN
#define WL_AGAIN    WL_JMP

typedef Term (*WlFn)(WL_SIG);
#define WL_X(F) WL_FN WL_##F(WL_SIG);
WL_TABLE WL_X(FID_ENTER)
#undef WL_X
extern const WlFn wl_tab[];
#endif
"""

    work_impl = """
// Work (impl)
// ===========
#if !DEVICE
#define WL_X(F) WL_##F,
const WlFn wl_tab[] = { WL_TABLE };
#undef WL_X
FAR Term work_loop(Env e, DEV Term* sp, Term t, u32 seq);
#endif

static Term work_loop(Env e, DEV Term* sp, Term t, u32 seq) {
  WLState S;
  S.e = e;
  S.sp = sp;
  S.seq = seq;
  S.rn = 0;
  S.r[0] = t;
  S.next_fid = ~0u;
  Term ret = WL_FID_ENTER(&S);
  while (S.next_fid != ~0u) {
    u32 fid = S.next_fid;
    S.next_fid = ~0u;
    ret = wl_tab[fid](&S);
  }
  return ret;
}
"""

    # Note: bend_common.h must be identical for PCH across mod*.c, while rt_main.c uses -DBEND_RT_MAIN (no PCH)
    header_text = sec_head + glob_hdr + tabs_hdr + m15["sec_rt_fn"] + work_hdr
    (out_dir / "bend_common.h").write_text(header_text, encoding="utf-8")

    # Build rt_main.c
    glob_impl = m15["sec_glob"]
    for pat, rep in [
        ("static u64*    CORPUS;", "u64*    CORPUS;"),
        ("static u64    ALC[CUBE_T][3 * NCLS_ALL]", "u64    ALC[CUBE_T][3 * NCLS_ALL]"),
        ("static u32    KEEP_WORDS;", "u32    KEEP_WORDS;"),
        ("static u32    CUBE_LOG = 7;", "u32    CUBE_LOG = 7;"),
        ("static u32    bank_lock;", "u32    bank_lock;"),
        ("static Term f32_show(Env e, Term x);", "Term f32_show(Env e, Term x);"),
        ("static Term f32_read(Env e, Term s);", "Term f32_read(Env e, Term s);"),
        ("static bool corpus_grow(u64* H, u64 need);", "bool corpus_grow(u64* H, u64 need);"),
    ]:
        glob_impl = glob_impl.replace(pat, rep)

    sec_monk_to_reqs = m15["sec_monk_to_reqs"]
    sec_monk_to_reqs = sec_monk_to_reqs.replace("static Term f32_show(Env e, Term x) {", "Term f32_show(Env e, Term x) {")
    sec_monk_to_reqs = sec_monk_to_reqs.replace("static Term f32_read(Env e, Term s) {", "Term f32_read(Env e, Term s) {")
    sec_monk_to_reqs = sec_monk_to_reqs.replace("static bool corpus_grow(u64* H, u64 need) {", "bool corpus_grow(u64* H, u64 need) {")

    # Deduplicate Requests blocks by section header (`// File`, `// IO`, etc.)
    # m15 has main() and all IO/File effects used by compiler.bend; avoid duplicating shared files like file.c.
    reqs_parts = [m15["sec_reqs"]]
    seen_funcs = set(re.findall(r"Term\s+(\w+_run)\s*\(", m15["sec_reqs"]))
    for pm in parsed_mods[:-1]:
        extra = set(re.findall(r"Term\s+(\w+_run)\s*\(", pm["sec_reqs"])) - seen_funcs
        if extra:
            # Split by `// ` effect-file headers and only include blocks defining unseen *_run funcs
            for blk in re.split(r"(?=^// [A-Z][^\n]*\n// =+\n)", pm["sec_reqs"], flags=re.M):
                blk_fns = set(re.findall(r"Term\s+(\w+_run)\s*\(", blk))
                if blk_fns and not (blk_fns & seen_funcs):
                    reqs_parts.append(blk)
                    seen_funcs |= blk_fns

    rt_text = (
        "#define BEND_RT_MAIN 1\n"
        '#include "bend_common.h"\n\n'
        + glob_impl + "\n"
        + tabs_impl + "\n"
        + work_impl + "\n"
        + "\n".join(rt_seg_blocks[k] for k in ("FID_ENTER", "FID_IO_emit", "FID_Clo_apply", "FID_EXIT") if k in rt_seg_blocks) + "\n"
        + sec_monk_to_reqs + "\n"
        + "\n".join(reqs_parts) + "\n"
        + m15["sec_main"]
    )
    (out_dir / "rt_main.c").write_text(rt_text, encoding="utf-8")

    # Write mod00.c .. mod15.c (each includes bend_common.h, its own TAB_m{i}_*, its own static inline spins, and its WL_CASE segs)
    mod_files: list[Path] = []
    mod_sizes: list[int] = []
    for idx, pm in enumerate(parsed_mods):
        off = stat_offsets[idx]
        tnames = [t[0] for t in pm["tab_defs"]]
        tab_c = "\n".join(f"CONSTV u64 TAB_m{idx}_{nm[4:]}[] = {{ {vals} }};" for nm, vals in pm["tab_defs"])
        spins_c = relocate_stat_off(pm["spins_code"], off)
        spins_c = namespace_tabs(spins_c, idx, tnames)
        # Note: inside spin_* functions, parameter names are `r0, r1, ...`, which would collide with `#define r0 (R[0])`!
        # So we `#undef r0..r{N-1}` before spins_c and re-`#define` them before WL_CASE segments!
        undef_regs = "\n".join(f"#undef r{i}" for i in range(n_regs)) if spins_c else ""
        redef_regs = reg_macros if spins_c else ""
        parts = ['#include "bend_common.h"\n']
        if tab_c:
            parts.append(tab_c + "\n")
        if spins_c:
            spin_open = "#undef WL_SPIN\n#undef WL_SPUN\n#undef WL_AGAIN\n#define WL_SPIN for (;;) { if (err_spun(e.mem, &wpoll)) { return 0; }\n#define WL_SPUN } break;\n#define WL_AGAIN(F) continue\n"
            spin_close = "\n#undef WL_SPIN\n#undef WL_SPUN\n#undef WL_AGAIN\n#define WL_SPIN\n#define WL_SPUN\n#define WL_AGAIN WL_JMP\n"
            parts.append(undef_regs + "\n" + spin_open + spins_c + spin_close + "\n" + redef_regs + "\n")
        parts.append("\n\n".join(mod_segs[idx]) + "\n")
        content = "\n".join(parts)
        mp = out_dir / f"mod{idx:02d}.c"
        mp.write_text(content, encoding="utf-8")
        mod_files.append(mp)
        mod_sizes.append(len(content))

    return {
        "n_cids": len(cid_list),
        "n_fids": len(fid_list),
        "stat_len": cur_stat,
        "wl_resw": global_resw,
        "wl_nregs": n_regs,
        "header_bytes": len(header_text),
        "rt_bytes": len(rt_text),
        "mod_bytes_total": sum(mod_sizes),
        "mod_bytes": mod_sizes,
    }


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--work-dir", type=Path, default=Path("/tmp/agy_b1/stage0_build"))
    ap.add_argument("--out-bin", type=Path, default=Path("/tmp/agy_b1/stage0_seed"))
    ap.add_argument("--bun-jobs", type=int, default=5, help="Parallel bun workers (keep <= 5 for < 4 GiB RAM)")
    ap.add_argument("--gcc-jobs", type=int, default=8, help="Parallel gcc workers")
    ap.add_argument("--k-dir", type=Path, default=K16_DIR)
    ap.add_argument("--report-json", type=Path, default=None)
    args = ap.parse_args()

    t_total0 = time.perf_counter()
    work = args.work_dir
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True, exist_ok=True)
    zero_dir = work / "k16_zero"
    mod_c_dir = work / "mod_c"
    merge_dir = work / "merged"
    logs_dir = work / "logs"
    for d in (zero_dir, mod_c_dir, merge_dir, logs_dir):
        d.mkdir(parents=True, exist_ok=True)

    # Ensure comp_mod.ts is fresh
    subprocess.run([sys.executable, str(GEN_COMP_MOD)], check=True, stdout=subprocess.DEVNULL)

    # Stage 1: Generate zero-.p130 stubbed modules + @unsafe fix + roots/stubs lists
    t1 = time.perf_counter()
    subprocess.run(
        [sys.executable, str(GEN_STUBS), "--k-dir", str(args.k_dir), "--out-dir", str(zero_dir)],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    leaves = collect_leaf_defs(args.k_dir)
    mod_specs: list[dict] = []
    for idx in range(16):
        mname = f"m{idx:02d}"
        raw_src = (args.k_dir / f"{mname}.bend").read_text(encoding="utf-8")
        own_defs = sorted(set(re.findall(r"^def\s+([A-Za-z0-9_.\$]+)", raw_src, re.M)))
        fix_bend = zero_dir / f"{mname}_fix.bend"
        inlined_leaves = ensure_unsafe_stubs(zero_dir / f"{mname}_zero.bend", mname, fix_bend, leaves)
        all_defs = sorted(set(re.findall(r"^def\s+([A-Za-z0-9_.\$]+)", fix_bend.read_text(encoding="utf-8"), re.M)))
        no_emit_defs = sorted(set(all_defs) - set(own_defs))
        skip_flat_defs = sorted(set(no_emit_defs) - inlined_leaves)
        roots_f = zero_dir / f"{mname}_roots.txt"
        skip_flat_f = zero_dir / f"{mname}_skip_flat.txt"
        no_emit_f = zero_dir / f"{mname}_no_emit.txt"
        roots_f.write_text("\n".join(own_defs) + "\n", encoding="utf-8")
        skip_flat_f.write_text("\n".join(skip_flat_defs) + "\n", encoding="utf-8")
        no_emit_f.write_text("\n".join(no_emit_defs) + "\n", encoding="utf-8")
        mod_specs.append({
            "idx": idx, "name": mname, "src": fix_bend,
            "roots": roots_f, "skip_flat": skip_flat_f, "no_emit": no_emit_f,
            "out_c": mod_c_dir / f"{mname}.c",
        })
    s1_s = time.perf_counter() - t1
    print(f"[Stage 1] Stubs & split prep: {s1_s:.2f}s", flush=True)

    # Stage 2: Parallel modular C emission via bun (bounded concurrency for < 4 GiB RAM)
    t2 = time.perf_counter()
    cpu_q: queue.Queue[int] = queue.Queue()
    for c in CPUS_ALL[: args.bun_jobs]:
        cpu_q.put(c)
    bun_env = dict(os.environ, BEND_NO_TELEMETRY="1")

    def emit_one(spec: dict) -> dict:
        cpu = cpu_q.get()
        try:
            err_f = logs_dir / f"bun_{spec['name']}.err"
            cmd = [str(BUN), str(EMIT_MOD_TS), str(spec["src"]), str(spec["roots"]), str(spec["skip_flat"]), str(spec["no_emit"]), str(spec["out_c"])]
            rc, dt, rss, err = run_wait4(cmd, err_f, cpu=cpu, env=bun_env, cwd=ROOT)
            if rc != 0:
                raise RuntimeError(f"emit_mod_c failed on {spec['name']} (rc={rc}): {err[-1000:]}")
            return {"mod": spec["name"], "wall_s": round(dt, 2), "rss_mib": round(rss, 1), "c_bytes": spec["out_c"].stat().st_size}
        finally:
            cpu_q.put(cpu)

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.bun_jobs) as ex:
        bun_results = list(ex.map(emit_one, mod_specs))
    s2_s = time.perf_counter() - t2
    bun_peak_rss = max(r["rss_mib"] for r in bun_results)
    print(f"[Stage 2] Parallel bun C emit ({args.bun_jobs} workers): {s2_s:.2f}s (max worker RSS {bun_peak_rss:.0f} MiB)", flush=True)

    # Stage 3: Merge global tables/STAT_IMG + trampoline header
    t3 = time.perf_counter()
    parsed_mods = [parse_c_module(spec["out_c"], spec["idx"]) for spec in mod_specs]
    merge_info = merge_modules_to_c(parsed_mods, merge_dir)
    # Free raw modular C files immediately to save disk space!
    shutil.rmtree(mod_c_dir)
    s3_s = time.perf_counter() - t3
    print(f"[Stage 3] Global C merge: {s3_s:.2f}s (CIDs={merge_info['n_cids']}, FIDs={merge_info['n_fids']}, STAT={merge_info['stat_len']}, C={merge_info['mod_bytes_total']/1048576:.1f} MiB)", flush=True)

    # Stage 4: Precompile bend_common.h -> .gch + parallel gcc compile across 8 cores
    t4 = time.perf_counter()
    pch_flags = ["-std=c11", "-O1", "-fno-inline", "-Wno-unknown-pragmas"]
    rc, dt_pch, rss_pch, err_pch = run_wait4(
        [GCC, *pch_flags, "-x", "c-header", str(merge_dir / "bend_common.h"), "-o", str(merge_dir / "bend_common.h.gch")],
        logs_dir / "gcc_pch.err", cpu=0, cwd=merge_dir,
    )
    if rc != 0:
        raise RuntimeError(f"PCH failed: {err_pch[-1000:]}")

    # Compile rt_main.c (-O2, no PCH because -DBEND_RT_MAIN) and mod00..15.c (-O1 -fno-inline, with PCH) in parallel!
    gcc_q: queue.Queue[int] = queue.Queue()
    for c in CPUS_ALL[: args.gcc_jobs]:
        gcc_q.put(c)

    # Schedule largest modules first (LPT)
    compile_jobs = [("rt_main", merge_dir / "rt_main.c", merge_dir / "rt_main.o", ["-std=c11", "-O2", "-Wno-unknown-pragmas", "-I", str(merge_dir)])]
    for idx in sorted(range(16), key=lambda i: merge_info["mod_bytes"][i], reverse=True):
        compile_jobs.append((f"mod{idx:02d}", merge_dir / f"mod{idx:02d}.c", merge_dir / f"mod{idx:02d}.o", [*pch_flags, "-I", str(merge_dir)]))

    def compile_one(job: tuple[str, Path, Path, list[str]]) -> dict:
        name, src_c, obj_o, flags = job
        cpu = gcc_q.get()
        try:
            err_f = logs_dir / f"gcc_{name}.err"
            cmd = [GCC, *flags, "-c", str(src_c), "-o", str(obj_o)]
            rc, dt, rss, err = run_wait4(cmd, err_f, cpu=cpu, cwd=merge_dir)
            if rc != 0:
                raise RuntimeError(f"gcc failed on {name} (rc={rc}): {err[-1200:]}")
            o_sz = obj_o.stat().st_size
            # Immediately remove intermediate .c file to keep peak disk <= 150 MiB
            if name.startswith("mod"):
                src_c.unlink(missing_ok=True)
            return {"unit": name, "wall_s": round(dt, 2), "rss_mib": round(rss, 1), "o_bytes": o_sz}
        finally:
            gcc_q.put(cpu)

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.gcc_jobs) as ex:
        gcc_results = list(ex.map(compile_one, compile_jobs))
    s4_s = time.perf_counter() - t4
    gcc_peak_rss = max(r["rss_mib"] for r in gcc_results)
    print(f"[Stage 4] PCH ({dt_pch:.2f}s) + parallel gcc ({args.gcc_jobs} workers): {s4_s:.2f}s (max worker RSS {gcc_peak_rss:.0f} MiB)", flush=True)

    # Stage 5: Link stage0_seed
    t5 = time.perf_counter()
    objs = [str(merge_dir / "rt_main.o")] + [str(merge_dir / f"mod{idx:02d}.o") for idx in range(16)]
    args.out_bin.parent.mkdir(parents=True, exist_ok=True)
    rc, dt_link, rss_link, err_link = run_wait4(
        [GCC, *objs, "-lpthread", "-lm", "-o", str(args.out_bin)],
        logs_dir / "gcc_link.err", cpu=0, cwd=merge_dir,
    )
    if rc != 0:
        raise RuntimeError(f"link failed (rc={rc}): {err_link[-1200:]}")
    s5_s = time.perf_counter() - t5
    total_s = time.perf_counter() - t_total0
    bin_bytes = args.out_bin.stat().st_size
    print(f"[Stage 5] Link: {s5_s:.2f}s -> {args.out_bin} ({bin_bytes/1048576:.2f} MiB)", flush=True)
    print(f"=== TOTAL STAGE 0 WALL TIME: {total_s:.2f}s ===", flush=True)

    summary = {
        "total_wall_s": round(total_s, 2),
        "stage1_stubs_s": round(s1_s, 2),
        "stage2_bun_emit_s": round(s2_s, 2),
        "stage3_merge_s": round(s3_s, 2),
        "stage4_gcc_s": round(s4_s, 2),
        "stage4_pch_s": round(dt_pch, 2),
        "stage5_link_s": round(s5_s, 2),
        "bun_jobs": args.bun_jobs,
        "gcc_jobs": args.gcc_jobs,
        "bun_max_worker_rss_mib": round(bun_peak_rss, 1),
        "gcc_max_worker_rss_mib": round(gcc_peak_rss, 1),
        "bin_bytes": bin_bytes,
        "merge_info": merge_info,
        "bun_modules": bun_results,
        "gcc_units": gcc_results,
    }
    if args.report_json:
        args.report_json.parent.mkdir(parents=True, exist_ok=True)
        args.report_json.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
