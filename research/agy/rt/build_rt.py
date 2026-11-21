#!/usr/bin/env python3
"""Build baseline (runtime-base.o) and optimized (runtime-opt.o) ABI-11102 runtimes,
verify exported symbols and full ABI + live-descriptor probe suite."""
import argparse
import importlib.util
import subprocess
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
RUNTIME_DIR = ROOT / "selfhost/src/runtime/qbe"
SCAN_C = ROOT / "research/phase199/scan-runtime/scan.c"
REF_RT = ROOT / "selfhost/build/agy/bootstrap/runtime-live-scan.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
LD = "/usr/bin/x86_64-linux-gnu-ld.bfd"

def run(cmd, timeout=30):
    p = subprocess.run(list(map(str, cmd)), capture_output=True, text=True, timeout=timeout)
    if p.returncode != 0:
        raise RuntimeError(f"Command failed ({p.returncode}): {cmd}\nSTDOUT:\n{p.stdout}\nSTDERR:\n{p.stderr}")
    return p.stdout

def exported(obj):
    lines = run(["nm", "-g", "--defined-only", obj]).splitlines()
    return sorted(" ".join(line.split()[1:]) for line in lines if line.strip())

def load_mod(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

def replace_once(text, before, after):
    n = text.count(before)
    assert n == 1, f"Expected 1 occurrence, got {n} for:\n{before[:200]}"
    return text.replace(before, after)

def make_live_base(orig_text):
    facts = load_mod("facts", ROOT / "research/phase198/runtime/bind-facts.py")
    live = load_mod("live", ROOT / "research/phase198/runtime-broad/live.py")
    split = facts.variant(orig_text, "split")
    return live.variant(orig_text, split)

def make_opt(orig_text):
    text = orig_text

    # 1. Cache physical HEAP_OFF at p111_bind (corpus layout boundary established once at boot).
    #    Constructor metadata (cid_hot, cid_arity, constructor_count, capabilities) stays live!
    text = replace_once(
        text,
        "#define HEAP_OFF (STAT_OFF + PAGE_UP(STAT_LEN))",
        "static u64 p111_heap_off;\n#define HEAP_OFF p111_heap_off",
    )
    text = replace_once(
        text,
        "  p111_program_active = program;",
        "  p111_program_active = program;\n  p111_heap_off = STAT_OFF + PAGE_UP(program->static_words);",
    )

    # 2. Likely/unlikely hints on heap_alloc, heap_free, spare_free
    text = replace_once(
        text,
        """INLINE Loc heap_alloc(Env e, Cls cls) {
  Loc h = ALC_AT(e, cls);
  if (h) {
    ALC_AT(e, cls)   = e.mem[h];
    ALC_LEN(e, cls) -= 1ull << cls;
    return h;
  }
  return heap_alloc_miss(e, cls);
}

INLINE void heap_free(Env e, Cls cls, Loc loc) {
  if (err_seen(e.mem)) {
    return;
  }
  e.mem[loc]       = ALC_AT(e, cls);
  ALC_AT(e, cls)   = loc;
  ALC_LEN(e, cls) += 1ull << cls;
  if (!DEVICE && ALC_LEN(e, cls) >= KEEP_WORDS) {
    heap_hand(e, cls);
  }
}

// Spare
// =====

INLINE void spare_free(Env e, Cls cls, Loc loc) {
  if (loc >= HEAP_OFF) {
    heap_free(e, cls, loc);
  }
}""",
        """INLINE Loc heap_alloc(Env e, Cls cls) {
  Loc h = ALC_AT(e, cls);
  if (__builtin_expect(h != 0, 1)) {
    ALC_AT(e, cls)   = e.mem[h];
    ALC_LEN(e, cls) -= 1ull << cls;
    return h;
  }
  return heap_alloc_miss(e, cls);
}

INLINE void heap_free(Env e, Cls cls, Loc loc) {
  if (err_seen(e.mem)) {
    return;
  }
  e.mem[loc]       = ALC_AT(e, cls);
  ALC_AT(e, cls)   = loc;
  ALC_LEN(e, cls) += 1ull << cls;
  if (!DEVICE && __builtin_expect(ALC_LEN(e, cls) >= KEEP_WORDS, 0)) {
    heap_hand(e, cls);
  }
}

// Spare
// =====

INLINE void spare_free(Env e, Cls cls, Loc loc) {
  if (__builtin_expect(loc >= HEAP_OFF, 1)) {
    heap_free(e, cls, loc);
  }
}""",
    )

    # 3. Inline rfc_seal / fast rfc_wrap + single-mutator rfc_view
    text = replace_once(
        text,
        """OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {
  if (term_tag(t) == TAG_CLO || term_tag(t) == TAG_TSK) {
    err_post(e.mem, ERR_RFCS);
    return t;
  }
  Loc r = heap_alloc(e, 0);
  e.mem[r] = ((u64)term_loc(t) << 24) | cnt;
  return (t & ~LOC_MASK) | RFC_BIT | r;
}

INLINE Term rfc_seal(Env e, Term t) {
  if (term_tag(t) != TAG_CTR || term_rfc(t)) {
    return t;
  }
  return rfc_wrap(e, t, 1);
}

INLINE u64 rfc_view(Env e, Loc r) {
  DEV u32* w = a32_at(e.mem, r);
  u64 cell = ((u64)a32_load(w + 1) << 32) | a32_load(w);
  if ((cell & RFC_CNT) == 1) {
    a32_acq(w);
  }
  return cell;
}""",
        """OUTLINE Term rfc_wrap_err(Env e, Term t) {
  err_post(e.mem, ERR_RFCS);
  return t;
}

INLINE Term rfc_wrap_ctr(Env e, Term t, u32 cnt) {
  Loc r = heap_alloc(e, 0);
  e.mem[r] = ((u64)term_loc(t) << 24) | cnt;
  return (t & ~LOC_MASK) | RFC_BIT | r;
}

INLINE Term rfc_wrap(Env e, Term t, u32 cnt) {
  u64 tag = term_tag(t);
  if (__builtin_expect(tag == TAG_CLO || tag == TAG_TSK, 0)) {
    return rfc_wrap_err(e, t);
  }
  return rfc_wrap_ctr(e, t, cnt);
}

INLINE Term rfc_seal(Env e, Term t) {
  if ((t >> 56) != TAG_CTR) {
    return t;
  }
  return rfc_wrap_ctr(e, t, 1);
}

INLINE u64 rfc_view(Env e, Loc r) {
#if P144_SINGLE_MUTATOR_RFC
  return e.mem[r];
#else
  DEV u32* w = a32_at(e.mem, r);
  u64 cell = ((u64)a32_load(w + 1) << 32) | a32_load(w);
  if ((cell & RFC_CNT) == 1) {
    a32_acq(w);
  }
  return cell;
#endif
}""",
    )

    # 4. Single-mutator rfc_bump
    text = replace_once(
        text,
        """INLINE void rfc_bump(Env e, Loc r, u32 k) {
  u32 c = p144_rfc_add(a32_at(e.mem, r), k);
  if ((c & RFC_CNT) >= RFC_CNT - k) {
    err_post(e.mem, ERR_RFCS);
  }
}""",
        """INLINE void rfc_bump(Env e, Loc r, u32 k) {
#if P144_SINGLE_MUTATOR_RFC
  u64 cell = e.mem[r];
  if (__builtin_expect((u32)(cell & RFC_CNT) >= RFC_CNT - k, 0)) {
    err_post(e.mem, ERR_RFCS);
  }
  e.mem[r] = cell + k;
#else
  u32 c = p144_rfc_add(a32_at(e.mem, r), k);
  if (__builtin_expect((c & RFC_CNT) >= RFC_CNT - k, 0)) {
    err_post(e.mem, ERR_RFCS);
  }
#endif
}""",
    )

    # 5. Single-mutator fast RFC drop in term_drop
    text = replace_once(
        text,
        """    if (!term_triv(t) && term_rfc(t)) {
      Loc      r = term_loc(t);
      DEV u32* p = a32_at(H, r);
      if ((p144_rfc_sub(p, 1) & RFC_CNT) != 1) {
        t = 0;
      } else {
        a32_acq(p);
        t = (t & ~(RFC_BIT | LOC_MASK)) | (H[r] >> 24);
        heap_free(e, 0, r);
      }
    }""",
        """    if (!term_triv(t) && term_rfc(t)) {
      Loc r = term_loc(t);
#if P144_SINGLE_MUTATOR_RFC
      u64 cell = H[r];
      if ((cell & RFC_CNT) != 1) {
        H[r] = cell - 1;
        if (cur == 0) {
          return;
        }
        t = 0;
      } else {
        t = (t & ~(RFC_BIT | LOC_MASK)) | (cell >> 24);
        heap_free(e, 0, r);
      }
#else
      DEV u32* p = a32_at(H, r);
      if ((p144_rfc_sub(p, 1) & RFC_CNT) != 1) {
        t = 0;
      } else {
        a32_acq(p);
        t = (t & ~(RFC_BIT | LOC_MASK)) | (H[r] >> 24);
        heap_free(e, 0, r);
      }
#endif
    }""",
    )

    # 6. Leaf fast path for p111_rt_sink on shared RFC (cnt > 1)
    text = replace_once(
        text,
        "uint64_t p111_rt_sink(P111State *state, uint64_t term) { term_sink(state->e, term); return 0; }",
        """uint64_t p111_rt_sink(P111State *state, uint64_t term) {
  if (__builtin_expect(!term_triv(term), 1)) {
#if P144_SINGLE_MUTATOR_RFC
    if (term_rfc(term)) {
      Env e = state->e;
      Loc r = term_loc(term);
      u64 cell = e.mem[r];
      if ((cell & RFC_CNT) != 1) {
        e.mem[r] = cell - 1;
        return 0;
      }
    }
#endif
    term_drop(state->e, term);
  }
  return 0;
}""",
    )

    # 7. Specialized, unrolled, leaf-fast p125_rt_ctor1/2/3/4 and p125_rt_take1/2/3/4
    old_p125 = """#define P125_VERIFIED(N) \\
uint64_t p125_rt_ctor##N(P111State *state, uint32_t cid, const uint64_t *fields) { \\
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N)); \\
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \\
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = fields[i]; \\
  } else { \\
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \\
  } \\
  return term_ctr(cid, at); \\
} \\
uint64_t p125_rt_take##N(P111State *state, uint64_t term, uint64_t *out) { \\
  u32 cid = (u32)term_aux(term); \\
  p111_require(cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: take arity mismatch"); \\
  if (N == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term); \\
  else { \\
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected constructor owner"); \\
    spare_free(state->e, cls_fit(N), ctr_take(state->e, term, N, out)); \\
  } \\
  return N; \\
}"""

    new_p125 = """OUTLINE uint64_t p198_hand_ret(Env e, Cls cls, uint64_t ret) {
  heap_hand(e, cls);
  return ret;
}

OUTLINE uint64_t p198_rfc_free_slow(Env e, Loc r, Cls cls, Loc src, uint64_t ret) {
  heap_free(e, 0, r);
  spare_free(e, cls, src);
  return ret;
}

OUTLINE uint64_t p198_fade_ret(Env e, Term term, Loc src, u32 n) {
  span_fade(e, term, src, n);
  return n;
}

#define P198_COPY_1(dst, src) do { (dst)[0] = (src)[0]; } while (0)
#define P198_COPY_2(dst, src) do { (dst)[0] = (src)[0]; (dst)[1] = (src)[1]; } while (0)
#define P198_COPY_3(dst, src) do { (dst)[0] = (src)[0]; (dst)[1] = (src)[1]; (dst)[2] = (src)[2]; } while (0)
#define P198_COPY_4(dst, src) do { (dst)[0] = (src)[0]; (dst)[1] = (src)[1]; (dst)[2] = (src)[2]; (dst)[3] = (src)[3]; } while (0)

#define P198_SEAL_ONE(mem, h0, used0, f, dst_slot) do { \\
  Term _f = (f); \\
  if ((_f >> 56) == TAG_CTR) { \\
    Loc _r = (h0); \\
    (h0) = (mem)[_r]; \\
    (used0) += 1; \\
    (mem)[_r] = ((u64)(_f & LOC_MASK) << 24) | 1u; \\
    _f = (_f & ~LOC_MASK) | RFC_BIT | _r; \\
  } \\
  (dst_slot) = _f; \\
} while (0)

#define P198_SEAL_1(mem, h0, used0, dst, src) do { \\
  P198_SEAL_ONE(mem, h0, used0, (src)[0], (dst)[0]); \\
} while (0)
#define P198_SEAL_2(mem, h0, used0, dst, src) do { \\
  P198_SEAL_ONE(mem, h0, used0, (src)[0], (dst)[0]); \\
  P198_SEAL_ONE(mem, h0, used0, (src)[1], (dst)[1]); \\
} while (0)
#define P198_SEAL_3(mem, h0, used0, dst, src) do { \\
  P198_SEAL_ONE(mem, h0, used0, (src)[0], (dst)[0]); \\
  P198_SEAL_ONE(mem, h0, used0, (src)[1], (dst)[1]); \\
  P198_SEAL_ONE(mem, h0, used0, (src)[2], (dst)[2]); \\
} while (0)
#define P198_SEAL_4(mem, h0, used0, dst, src) do { \\
  P198_SEAL_ONE(mem, h0, used0, (src)[0], (dst)[0]); \\
  P198_SEAL_ONE(mem, h0, used0, (src)[1], (dst)[1]); \\
  P198_SEAL_ONE(mem, h0, used0, (src)[2], (dst)[2]); \\
  P198_SEAL_ONE(mem, h0, used0, (src)[3], (dst)[3]); \\
} while (0)

#define P125_VERIFIED(N) \\
OUTLINE uint64_t p198_slow_ctor##N(P111State *state, uint32_t cid, const uint64_t *fields) { \\
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N)); \\
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \\
    P198_COPY_##N(e.mem + at, fields); \\
  } else { \\
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \\
  } \\
  return term_ctr(cid, at); \\
} \\
OUTLINE uint64_t p198_slow_take##N(P111State *state, uint64_t term, uint64_t *out) { \\
  u32 cid = (u32)term_aux(term); \\
  p111_require(cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: take arity mismatch"); \\
  if (N == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term); \\
  else { \\
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected constructor owner"); \\
    spare_free(state->e, cls_fit(N), ctr_take(state->e, term, N, out)); \\
  } \\
  return N; \\
} \\
uint64_t p125_rt_ctor##N(P111State *s, uint32_t cid, const uint64_t *fields) { \\
  Env e = s->e; \\
  Cls cls = cls_fit(N); \\
  const P111Program *prog = p111_program_active; \\
  if (cid < prog->constructor_count && (prog->capabilities & UINT64_C(8)) && !prog->cid_hot[cid]) { \\
    Loc at = ALC_AT(e, cls); \\
    if (__builtin_expect(at != 0, 1)) { \\
      ALC_AT(e, cls) = e.mem[at]; \\
      ALC_LEN(e, cls) -= 1ull << cls; \\
      P198_COPY_##N(e.mem + at, fields); \\
      return term_ctr(cid, at); \\
    } \\
    return p198_slow_ctor##N(s, cid, fields); \\
  } \\
  if (N == 1) { \\
    if (__builtin_expect(ALC_LEN(e, 0) >= 2, 1)) { \\
      Loc at = ALC_AT(e, 0); \\
      Loc h0 = e.mem[at]; \\
      u64 used0 = 1; \\
      P198_SEAL_1(e.mem, h0, used0, e.mem + at, fields); \\
      ALC_AT(e, 0) = h0; \\
      ALC_LEN(e, 0) -= used0; \\
      return term_ctr(cid, at); \\
    } \\
  } else { \\
    Loc at = ALC_AT(e, cls); \\
    if (__builtin_expect(at != 0 && ALC_LEN(e, 0) >= N, 1)) { \\
      ALC_AT(e, cls) = e.mem[at]; \\
      ALC_LEN(e, cls) -= 1ull << cls; \\
      Loc h0 = ALC_AT(e, 0); \\
      u64 used0 = 0; \\
      P198_SEAL_##N(e.mem, h0, used0, e.mem + at, fields); \\
      ALC_AT(e, 0) = h0; \\
      ALC_LEN(e, 0) -= used0; \\
      return term_ctr(cid, at); \\
    } \\
  } \\
  return p198_slow_ctor##N(s, cid, fields); \\
} \\
static __attribute__((noinline)) uint64_t p198_rfc_take##N(P111State *s, uint64_t term, uint64_t *out) { \\
  Env e = s->e; \\
  Loc r = term_loc(term); \\
  u64 cell = rfc_view(e, r); \\
  Loc src = cell >> 24; \\
  P198_COPY_##N(out, e.mem + src); \\
  if (__builtin_expect((cell & RFC_CNT) == 1, 1)) { \\
    Cls cls = cls_fit(N); \\
    u64 len0 = ALC_LEN(e, 0) + 1; \\
    if (__builtin_expect(len0 >= KEEP_WORDS, 0)) { \\
      return p198_rfc_free_slow(e, r, cls, src, N); \\
    } \\
    e.mem[r] = ALC_AT(e, 0); \\
    ALC_AT(e, 0) = r; \\
    ALC_LEN(e, 0) = len0; \\
    if (__builtin_expect(src >= HEAP_OFF, 1)) { \\
      e.mem[src] = ALC_AT(e, cls); \\
      ALC_AT(e, cls) = src; \\
      u64 len = ALC_LEN(e, cls) + (1ull << cls); \\
      ALC_LEN(e, cls) = len; \\
      if (__builtin_expect(len >= KEEP_WORDS, 0)) { \\
        return p198_hand_ret(e, cls, N); \\
      } \\
    } \\
    return N; \\
  } \\
  return p198_fade_ret(e, term, src, N); \\
} \\
uint64_t p125_rt_take##N(P111State *s, uint64_t term, uint64_t *out) { \\
  u32 cid = (u32)term_aux(term); \\
  const P111Program *prog = p111_program_active; \\
  if (__builtin_expect(cid >= prog->constructor_count || prog->cid_arity[cid] != N, 0)) { \\
    return p198_slow_take##N(s, term, out); \\
  } \\
  u64 top = term >> 56; \\
  if (top == TAG_CTR) { \\
    Env e = s->e; \\
    Loc at = term_loc(term); \\
    P198_COPY_##N(out, e.mem + at); \\
    if (__builtin_expect(at >= HEAP_OFF, 1)) { \\
      Cls cls = cls_fit(N); \\
      e.mem[at] = ALC_AT(e, cls); \\
      ALC_AT(e, cls) = at; \\
      u64 len = ALC_LEN(e, cls) + (1ull << cls); \\
      ALC_LEN(e, cls) = len; \\
      if (__builtin_expect(len >= KEEP_WORDS, 0)) { \\
        return p198_hand_ret(e, cls, N); \\
      } \\
    } \\
    return N; \\
  } \\
  if (__builtin_expect(top == (0x80u | TAG_CTR), 1)) { \\
    return p198_rfc_take##N(s, term, out); \\
  } \\
  if (N == 1 && (top & 0x7fu) == TAG_PAK) { \\
    out[0] = term_loc(term); \\
    return 1; \\
  } \\
  return p198_slow_take##N(s, term, out); \\
}"""

    text = replace_once(text, old_p125, new_p125)
    return text

def build_bundle(c_path, obj_path, scan_obj, opt_flag="-O2"):
    core_obj = obj_path.with_suffix(".core.o")
    run([CC, opt_flag, "-std=gnu11", "-ffp-contract=off", "-DP144_SINGLE_MUTATOR_RFC=1",
         "-I", RUNTIME_DIR, "-c", c_path, "-o", core_obj])
    run([LD, "-m", "elf_x86_64", "-r", core_obj, scan_obj, "-o", obj_path])
    core_obj.unlink()

def run_abi_probes(out_dir, rt_obj, label):
    elf = out_dir / f"abi-probe-{label}"
    run([CC, "-std=gnu11", "-Wall", "-Wextra", "-Werror", "-O2", "-I", RUNTIME_DIR,
         "-no-pie", ROOT / "research/phase198/runtime-broad/observer.c",
         ROOT / "selfhost/tests/phase183/abi-contract.c", rt_obj, "-pthread", "-lm", "-o", elf])
    invalid = {
        "bad-cap": "unsupported capabilities",
        "zero-count": "program identifier capacity exceeded",
        "over-count": "program identifier capacity exceeded",
        "bad-hot": "invalid constructor metadata",
        "bad-name": "invalid constructor metadata",
        "no-arity": "missing program tables",
        "no-static": "static image exceeds initial corpus",
        "bad-abi": "descriptor ABI mismatch",
        "bad-size": "descriptor ABI mismatch",
        "bad-core": "missing core constructor identity",
        "rebind": "one program per process",
        "bad-take-id": "take arity mismatch",
        "bad-arity": "take arity mismatch",
        "max-arity": "take arity mismatch",
        "bad-owner": "expected constructor owner",
        "bad-checked-ctor": "constructor arity mismatch",
    }
    cases = [
        ("valid", cap, 65536 if cap in (1, 15) else 26, static,
         "checks " + ("35" if static >= 4 else "33") + "\n", "", 0)
        for cap in range(1, 16, 2) for static in (0, 129, 257)
    ]
    for name, msg in invalid.items():
        prefix = "phase118" if name in ("bad-arity", "bad-take-id", "max-arity", "bad-owner") else "phase111"
        cases.append((name, 16 if name == "bad-cap" else 9, 65536 if name == "max-arity" else 26, 4,
                      "", f"bend: {prefix}: {msg}\n", 1))
    cases += [(name, 15, 26, 4, "", "bend: Phase111 ABI v1 requires --threads 1 --gpu off\n", 1)
              for name in ("two-threads", "gpu-on")]
    cases += [("bad-cap", cap, 26, 4, "", "bend: phase111: unsupported capabilities\n", 1)
              for cap in (0, 2)]
    for name, cap, count, words, stdout, stderr, status in cases:
        p = subprocess.run([str(elf), name, str(cap), str(count), str(words)], capture_output=True, text=True, timeout=5)
        got = (p.stdout, p.stderr, p.returncode)
        assert got == (stdout, stderr, status), (label, name, cap, count, words, got, (stdout, stderr, status))
    for name in ("owner-hot", "owner-cap"):
        p = subprocess.run([str(elf), name, "15", "26", "4"], capture_output=True, text=True, timeout=5)
        assert (p.stdout, p.stderr, p.returncode) == ("sealed 1 field 13\n", "", 0), (label, name, p)
    elf.unlink()
    print(f"[{label}] ABI + live mutable metadata probes PASSED ({len(cases)} + 2 cases)")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, default=ROOT / "selfhost/build/agy/rt")
    ap.add_argument("--opt-flag", default="-O2")
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)

    scan_obj = a.out / "scan.o"
    run([CC, "-std=c11", "-O3", "-msse2", "-mno-avx", "-c", SCAN_C, "-o", scan_obj])

    orig_text = (RUNTIME_DIR / "runtime.c").read_text()

    base_c = a.out / "runtime-base.c"
    base_o = a.out / "runtime-base.o"
    base_c.write_text(make_live_base(orig_text))
    build_bundle(base_c, base_o, scan_obj, "-O2")

    opt_c = a.out / "runtime-opt.c"
    opt_o = a.out / "runtime-opt.o"
    opt_c.write_text(make_opt(orig_text))
    build_bundle(opt_c, opt_o, scan_obj, a.opt_flag)

    ref_syms = exported(REF_RT)
    assert exported(base_o) == ref_syms, "runtime-base.o exported symbols mismatch!"
    assert exported(opt_o) == ref_syms, "runtime-opt.o exported symbols mismatch!"
    print(f"Exported symbols match reference ({len(ref_syms)} symbols)")

    run_abi_probes(a.out, base_o, "base")
    run_abi_probes(a.out, opt_o, "opt")
    print(f"Built:\n  base: {base_o} ({base_o.stat().st_size} bytes)\n  opt:  {opt_o} ({opt_o.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
