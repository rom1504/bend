#!/usr/bin/env python3
"""Build Wave 3 self-compile-optimized ABI-11102 runtime (runtime-opt-w3.o),
verify exported symbols, 44/44 abi-contract.c + 2/2 observer.c probes."""
import argparse
import importlib.util
import subprocess
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
RUNTIME_DIR = ROOT / "selfhost/src/runtime/qbe"
SCAN_C = ROOT / "research/phase199/scan-runtime/scan.c"
SQRT_S = ROOT / "research/phase200/ray/sqrt-keep.s"
SQRT_CHK_C = ROOT / "research/phase200/ray/sqrt-check.c"
SQRT_REG_S = ROOT / "research/phase200/ray/register-check.s"
REF_RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
LD = "/usr/bin/x86_64-linux-gnu-ld.bfd"

def load_mod(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

base_rt = load_mod("build_rt", ROOT / "research/agy/rt/build_rt.py")
replace_once = base_rt.replace_once
run = base_rt.run
exported = base_rt.exported
build_bundle = base_rt.build_bundle
run_abi_probes = base_rt.run_abi_probes


def make_opt_w3(orig_text: str) -> str:
    # Start from Wave 1/2 runtime-agy.o optimizations
    text = base_rt.make_opt(orig_text)

    # W3-1: Fast span_fade in single-mutator mode (avoid full term_drop call when cnt > 1)
    text = replace_once(
        text,
        """OUTLINE void span_fade(Env e, Term t, Loc src, u32 n) {
  for (u32 j = 0; j < n; j += 1) {
    Term f = e.mem[src + j];
    if (term_rfc(f)) {
      rfc_bump(e, term_loc(f), 1);
    } else if (!term_triv(f)) {
      err_post(e.mem, ERR_RFCS);
    }
  }
  term_drop(e, t);
}""",
        """OUTLINE void span_fade(Env e, Term t, Loc src, u32 n) {
  Corpus H = e.mem;
  for (u32 j = 0; j < n; j += 1) {
    Term f = H[src + j];
    if (term_rfc(f)) {
      rfc_bump(e, term_loc(f), 1);
    } else if (__builtin_expect(!term_triv(f), 0)) {
      err_post(H, ERR_RFCS);
    }
  }
#if P144_SINGLE_MUTATOR_RFC
  if (__builtin_expect(term_rfc(t), 1)) {
    Loc r = term_loc(t);
    u64 cell = H[r];
    if (__builtin_expect((cell & RFC_CNT) > 1, 1)) {
      H[r] = cell - 1;
      return;
    }
  }
#endif
  term_drop(e, t);
}""",
    )

    # W3-2: Inline shared-RFC fade directly in p198_rfc_take1..4 (eliminates p198_fade_ret -> span_fade -> term_drop)
    text = replace_once(
        text,
        """#define P198_COPY_4(dst, src) do { (dst)[0] = (src)[0]; (dst)[1] = (src)[1]; (dst)[2] = (src)[2]; (dst)[3] = (src)[3]; } while (0)""",
        """#define P198_COPY_4(dst, src) do { (dst)[0] = (src)[0]; (dst)[1] = (src)[1]; (dst)[2] = (src)[2]; (dst)[3] = (src)[3]; } while (0)
#define P198_BUMP_ONE(e, f) do { \\
  Term _bf = (f); \\
  if (term_rfc(_bf)) { \\
    rfc_bump((e), term_loc(_bf), 1); \\
  } else if (__builtin_expect(!term_triv(_bf), 0)) { \\
    err_post((e).mem, ERR_RFCS); \\
  } \\
} while (0)
#define P198_BUMP_1(e, arr) do { P198_BUMP_ONE(e, (arr)[0]); } while (0)
#define P198_BUMP_2(e, arr) do { P198_BUMP_ONE(e, (arr)[0]); P198_BUMP_ONE(e, (arr)[1]); } while (0)
#define P198_BUMP_3(e, arr) do { P198_BUMP_ONE(e, (arr)[0]); P198_BUMP_ONE(e, (arr)[1]); P198_BUMP_ONE(e, (arr)[2]); } while (0)
#define P198_BUMP_4(e, arr) do { P198_BUMP_ONE(e, (arr)[0]); P198_BUMP_ONE(e, (arr)[1]); P198_BUMP_ONE(e, (arr)[2]); P198_BUMP_ONE(e, (arr)[3]); } while (0)
#if P144_SINGLE_MUTATOR_RFC
#define P198_FADE_INLINE(e, term, r, cell, src, out, N) do { \\
  P198_BUMP_##N(e, out); \\
  (e).mem[r] = (cell) - 1; \\
  return (N); \\
} while (0)
#else
#define P198_FADE_INLINE(e, term, r, cell, src, out, N) return p198_fade_ret((e), (term), (src), (N))
#endif""",
    )
    text = replace_once(
        text,
        """  return p198_fade_ret(e, term, src, N); \\
} \\""",
        """  P198_FADE_INLINE(e, term, r, cell, src, out, N); \\
} \\""",
    )

    # W3-3: Tail-drop + shared-child fast path in term_drop for TAG_CTR (eliminates pointer reversal for strings/lists/shallow ASTs)
    text = replace_once(
        text,
        """        } else {
          u32 ar;
          if (tag == TAG_CTR) {
            ar = cid_arity(aux);
          } else if (tag == TAG_CLO) {
            ar = fid_arity(aux) - 1;
          } else {
            ar = fid_arity(aux);
          }
          n   = ar;
          cls = cls_fit(tag == TAG_TSK ? ar + 2 : ar);
        }
        c0 = H[loc];
        H[loc] = cur;
        cur = loc | ((u64)n << 48) | ((u64)cls << 56);
      }
    }""",
        """        } else {
#if P144_SINGLE_MUTATOR_RFC
          if (__builtin_expect(tag == TAG_CTR, 1)) {
            u32 ar = cid_arity(aux);
            cls = cls_fit(ar);
            if (ar == 2) {
              Term f0 = H[loc];
              Term f1 = H[loc + 1];
              bool d0 = term_triv(f0);
              if (!d0 && term_rfc(f0)) {
                Loc rf0 = term_loc(f0);
                u64 fc0 = H[rf0];
                if ((fc0 & RFC_CNT) != 1) { H[rf0] = fc0 - 1; d0 = true; }
              }
              bool d1 = term_triv(f1);
              if (!d1 && term_rfc(f1)) {
                Loc rf1 = term_loc(f1);
                u64 fc1 = H[rf1];
                if ((fc1 & RFC_CNT) != 1) { H[rf1] = fc1 - 1; d1 = true; }
              }
              if (d0 & d1) {
                heap_free(e, 1, loc);
                if (cur == 0) return;
                goto w3_unwind;
              }
              if (d0) {
                heap_free(e, 1, loc);
                t = f1;
                if (err_spun(H, &step)) return;
                continue;
              }
              if (d1) {
                heap_free(e, 1, loc);
                t = f0;
                if (err_spun(H, &step)) return;
                continue;
              }
              n = 2;
            } else if (ar == 1) {
              Term f0 = H[loc];
              heap_free(e, 0, loc);
              if (!term_triv(f0)) {
                t = f0;
                if (err_spun(H, &step)) return;
                continue;
              }
              if (cur == 0) return;
              goto w3_unwind;
            } else {
              Term tail = 0;
              u32 need = 0;
              for (u32 j = 0; j < ar; j += 1) {
                Term f = H[loc + j];
                if (term_triv(f)) continue;
                if (term_rfc(f)) {
                  Loc rf = term_loc(f);
                  u64 fcell = H[rf];
                  if ((fcell & RFC_CNT) != 1) {
                    H[rf] = fcell - 1;
                    H[loc + j] = 0;
                    continue;
                  }
                }
                tail = f;
                need += 1;
                if (need >= 2) break;
              }
              if (need == 0) {
                heap_free(e, cls, loc);
                if (cur == 0) return;
                goto w3_unwind;
              }
              if (need == 1) {
                heap_free(e, cls, loc);
                t = tail;
                if (err_spun(H, &step)) return;
                continue;
              }
              n = ar;
            }
          } else
#endif
          {
            u32 ar;
            if (tag == TAG_CTR) {
              ar = cid_arity(aux);
            } else if (tag == TAG_CLO) {
              ar = fid_arity(aux) - 1;
            } else {
              ar = fid_arity(aux);
            }
            n   = ar;
            cls = cls_fit(tag == TAG_TSK ? ar + 2 : ar);
          }
        }
        c0 = H[loc];
        H[loc] = cur;
        cur = loc | ((u64)n << 48) | ((u64)cls << 56);
      }
    }
    w3_unwind:""",
    )

    # W3-4: Fast-path p111_rt_keep, p111_rt_ctor, p111_rt_take
    text = replace_once(
        text,
        """uint64_t p111_rt_keep(P111State *state, uint64_t term) { return term_keep(state->e, term); }""",
        """uint64_t p111_rt_keep(P111State *state, uint64_t term) {
#if P144_SINGLE_MUTATOR_RFC
  if (__builtin_expect(term_rfc(term), 1)) {
    Env e = state->e;
    Loc r = term_loc(term);
    u64 cell = e.mem[r];
    if (__builtin_expect((u32)(cell & RFC_CNT) < RFC_CNT - 1, 1)) {
      e.mem[r] = cell + 1;
      return term;
    }
  }
#endif
  return term_keep(state->e, term);
}""",
    )

    text = replace_once(
        text,
        """uint64_t p111_rt_ctor(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: constructor arity mismatch");
  if (!count) return term_pak(cid, 0);
  p111_require(fields != NULL, "phase111: missing constructor fields");
  Env e = state->e;
  Loc at = heap_alloc(e, cls_fit(count));
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = fields[i];
  } else {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, fields[i]);
  }
  return term_ctr(cid, at);
}

uint64_t p111_rt_take(P111State *state, uint64_t term, uint64_t *out, uint32_t count) {
  u32 cid = (u32)term_aux(term);
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: take arity mismatch");
  if (!count) return 0;
  p111_require(out != NULL, "phase111: missing take outputs");
  if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
  else {
    p111_require(term_tag(term) == TAG_CTR, "phase111: expected constructor owner");
    spare_free(state->e, cls_fit(count), ctr_take(state->e, term, count, out));
  }
  return count;
}""",
        """OUTLINE uint64_t w3_rt_ctor_slow(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: constructor arity mismatch");
  if (!count) return term_pak(cid, 0);
  p111_require(fields != NULL, "phase111: missing constructor fields");
  Env e = state->e;
  Loc at = heap_alloc(e, cls_fit(count));
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = fields[i];
  } else {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, fields[i]);
  }
  return term_ctr(cid, at);
}

uint64_t p111_rt_ctor(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) {
  const P111Program *prog = p111_program_active;
  if (__builtin_expect(cid >= prog->constructor_count || prog->cid_arity[cid] != count, 0)) {
    return w3_rt_ctor_slow(state, cid, fields, count);
  }
  if (__builtin_expect(count == 0, 0)) return term_pak(cid, 0);
  if (__builtin_expect(fields == NULL, 0)) return w3_rt_ctor_slow(state, cid, fields, count);
  Env e = state->e;
  Cls cls = cls_fit(count);
  Loc at = ALC_AT(e, cls);
  if ((prog->capabilities & UINT64_C(8)) && !prog->cid_hot[cid]) {
    if (__builtin_expect(at != 0, 1)) {
      ALC_AT(e, cls) = e.mem[at];
      ALC_LEN(e, cls) -= 1ull << cls;
      for (u32 i = 0; i < count; ++i) e.mem[at + i] = fields[i];
      return term_ctr(cid, at);
    }
    return w3_rt_ctor_slow(state, cid, fields, count);
  }
  if (__builtin_expect(at != 0 && ALC_LEN(e, 0) >= count + (cls == 0 ? 1u : 0u), 1)) {
    ALC_AT(e, cls) = e.mem[at];
    ALC_LEN(e, cls) -= 1ull << cls;
    Loc h0 = ALC_AT(e, 0);
    u64 used0 = 0;
    for (u32 i = 0; i < count; ++i) {
      Term _f = fields[i];
      if ((_f >> 56) == TAG_CTR) {
        Loc _r = h0;
        h0 = e.mem[_r];
        used0 += 1;
        e.mem[_r] = ((u64)(_f & LOC_MASK) << 24) | 1u;
        _f = (_f & ~LOC_MASK) | RFC_BIT | _r;
      }
      e.mem[at + i] = _f;
    }
    ALC_AT(e, 0) = h0;
    ALC_LEN(e, 0) -= used0;
    return term_ctr(cid, at);
  }
  return w3_rt_ctor_slow(state, cid, fields, count);
}

OUTLINE uint64_t w3_rt_take_slow(P111State *state, uint64_t term, uint64_t *out, uint32_t count) {
  u32 cid = (u32)term_aux(term);
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: take arity mismatch");
  if (!count) return 0;
  p111_require(out != NULL, "phase111: missing take outputs");
  if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
  else {
    p111_require(term_tag(term) == TAG_CTR, "phase111: expected constructor owner");
    spare_free(state->e, cls_fit(count), ctr_take(state->e, term, count, out));
  }
  return count;
}

uint64_t p111_rt_take(P111State *state, uint64_t term, uint64_t *out, uint32_t count) {
  u32 cid = (u32)term_aux(term);
  const P111Program *prog = p111_program_active;
  if (__builtin_expect(cid >= prog->constructor_count || prog->cid_arity[cid] != count, 0)) {
    return w3_rt_take_slow(state, term, out, count);
  }
  if (__builtin_expect(count == 0, 0)) return 0;
  if (__builtin_expect(out == NULL, 0)) return w3_rt_take_slow(state, term, out, count);
  u64 top = term >> 56;
  Env e = state->e;
  Corpus H = e.mem;
#if P144_SINGLE_MUTATOR_RFC
  if (__builtin_expect(top == (0x80u | TAG_CTR), 1)) {
    Loc r = term_loc(term);
    u64 cell = H[r];
    Loc src = cell >> 24;
    if ((cell & RFC_CNT) != 1) {
      for (u32 i = 0; i < count; ++i) {
        Term f = H[src + i];
        out[i] = f;
        if (term_rfc(f)) {
          rfc_bump(e, term_loc(f), 1);
        } else if (__builtin_expect(!term_triv(f), 0)) {
          err_post(H, ERR_RFCS);
        }
      }
      H[r] = cell - 1;
      return count;
    }
    for (u32 i = 0; i < count; ++i) out[i] = H[src + i];
    Cls cls = cls_fit(count);
    u64 len0 = ALC_LEN(e, 0) + 1;
    if (__builtin_expect(len0 >= KEEP_WORDS, 0)) {
      heap_free(e, 0, r);
      spare_free(e, cls, src);
      return count;
    }
    H[r] = ALC_AT(e, 0);
    ALC_AT(e, 0) = r;
    ALC_LEN(e, 0) = len0;
    if (__builtin_expect(src >= HEAP_OFF, 1)) {
      H[src] = ALC_AT(e, cls);
      ALC_AT(e, cls) = src;
      u64 len = ALC_LEN(e, cls) + (1ull << cls);
      ALC_LEN(e, cls) = len;
      if (__builtin_expect(len >= KEEP_WORDS, 0)) {
        heap_hand(e, cls);
      }
    }
    return count;
  }
#endif
  if (top == TAG_CTR) {
    Loc at = term_loc(term);
    for (u32 i = 0; i < count; ++i) out[i] = H[at + i];
    if (__builtin_expect(at >= HEAP_OFF, 1)) {
      Cls cls = cls_fit(count);
      H[at] = ALC_AT(e, cls);
      ALC_AT(e, cls) = at;
      u64 len = ALC_LEN(e, cls) + (1ull << cls);
      ALC_LEN(e, cls) = len;
      if (__builtin_expect(len >= KEEP_WORDS, 0)) {
        heap_hand(e, cls);
      }
    }
    return count;
  }
  return w3_rt_take_slow(state, term, out, count);
}""",
    )

    # W3-5: Inline p111_set_regs for count <= 4 (eliminates glibc memmove PLT overhead)
    text = replace_once(
        text,
        """static void p111_set_regs(P111State *state, const uint64_t *values, uint32_t count) {
  p111_require(count <= p111_transport_words && (!count || values), "phase111: invalid register transfer");
  if (count) memmove(state->regs, values, count * sizeof(uint64_t));
  if (!(p111_program_active->capabilities & UINT64_C(4))) memset(state->regs + count, 0, (p111_transport_words - count) * sizeof(uint64_t));
}""",
        """INLINE void p111_set_regs(P111State *state, const uint64_t *values, uint32_t count) {
  p111_require(count <= p111_transport_words && (!count || values), "phase111: invalid register transfer");
  if (__builtin_expect((p111_program_active->capabilities & UINT64_C(4)) != 0, 1)) {
    if (count == 1) {
      state->regs[0] = values[0];
      return;
    }
    if (count == 2) {
      u64 a = values[0], b = values[1];
      state->regs[0] = a; state->regs[1] = b;
      return;
    }
    if (count == 3) {
      u64 a = values[0], b = values[1], c = values[2];
      state->regs[0] = a; state->regs[1] = b; state->regs[2] = c;
      return;
    }
    if (count == 4) {
      u64 a = values[0], b = values[1], c = values[2], d = values[3];
      state->regs[0] = a; state->regs[1] = b; state->regs[2] = c; state->regs[3] = d;
      return;
    }
    if (count) memmove(state->regs, values, count * sizeof(uint64_t));
    return;
  }
  if (count) memmove(state->regs, values, count * sizeof(uint64_t));
  memset(state->regs + count, 0, (p111_transport_words - count) * sizeof(uint64_t));
}""",
    )

    # W3-6: Leaf fast path for p111_rt_special_ctor (FALSE=1, TRUE=2, ZERO=3)
    text = replace_once(
        text,
        """uint64_t p111_rt_special_ctor(P111State *state, uint32_t kind,
                             const uint64_t *args, uint32_t count) {
  Env e = state->e;
  p111_primitive_arity(count, p111_special_arity(kind));""",
        """uint64_t p111_rt_special_ctor(P111State *state, uint32_t kind,
                             const uint64_t *args, uint32_t count) {
  if (__builtin_expect(count == 0 && kind >= P111_SPECIAL_FALSE && kind <= P111_SPECIAL_ZERO, 1)) {
    return kind == P111_SPECIAL_TRUE;
  }
  Env e = state->e;
  p111_primitive_arity(count, p111_special_arity(kind));""",
    )

    # W3-7: Fast single-mutator path for p118_rt_borrow_scalar_safe
    text = replace_once(
        text,
        """uint64_t p118_rt_borrow_scalar_safe(P111State *state, Term first, Term second,
                                  uint32_t count) {
  p111_require(count == 1 || count == 2, "phase118: scalar root count");
  Env e = state->e;
  if (count == 2 && !term_triv(first) && !term_triv(second) &&
      term_rfc(first) && term_rfc(second) &&
      term_loc(first) == term_loc(second)) return 0;
  if (!term_triv(first) &&
      (!term_rfc(first) || (rfc_view(e, term_loc(first)) & RFC_CNT) <= 1)) return 0;
  if (count == 2 && !term_triv(second) &&
      (!term_rfc(second) || (rfc_view(e, term_loc(second)) & RFC_CNT) <= 1)) return 0;
  return 1;
}""",
        """uint64_t p118_rt_borrow_scalar_safe(P111State *state, Term first, Term second,
                                  uint32_t count) {
  if (__builtin_expect(count != 1 && count != 2, 0)) {
    err_fail("phase118: scalar root count");
  }
  Env e = state->e;
  bool t1 = term_triv(first);
  if (!t1) {
    if (!term_rfc(first)) return 0;
    if ((rfc_view(e, term_loc(first)) & RFC_CNT) <= 1) return 0;
  }
  if (count == 2) {
    bool t2 = term_triv(second);
    if (!t2) {
      if (!term_rfc(second)) return 0;
      if (!t1 && term_loc(first) == term_loc(second)) return 0;
      if ((rfc_view(e, term_loc(second)) & RFC_CNT) <= 1) return 0;
    }
  }
  return 1;
}""",
    )

    return text


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, default=ROOT / "selfhost/build/agy/wave3_sc_hot")
    ap.add_argument("--opt-flag", default="-O2")
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)

    scan_obj = a.out / "scan.o"
    run([CC, "-std=c11", "-O3", "-msse2", "-mno-avx", "-c", SCAN_C, "-o", scan_obj])
    sqrt_obj = a.out / "sqrt-keep.o"
    run([CC, "-c", SQRT_S, "-o", sqrt_obj])

    orig_text = (RUNTIME_DIR / "runtime.c").read_text()
    w3_c = a.out / "runtime-opt-w3.c"
    w3_o = a.out / "runtime-opt-w3.o"
    w3_c.write_text(make_opt_w3(orig_text))
    core_obj = w3_o.with_suffix(".core.o")
    run([CC, a.opt_flag, "-std=gnu11", "-ffp-contract=off", "-DP144_SINGLE_MUTATOR_RFC=1",
         "-I", RUNTIME_DIR, "-c", w3_c, "-o", core_obj])
    run([LD, "-m", "elf_x86_64", "-r", core_obj, scan_obj, sqrt_obj, "-o", w3_o])
    core_obj.unlink()

    ref_syms = exported(REF_RT)
    assert exported(w3_o) == ref_syms, "runtime-opt-w3.o exported symbols mismatch!"
    print(f"Exported symbols match reference ({len(ref_syms)} symbols)")

    run_abi_probes(a.out, w3_o, "opt-w3")
    # 65,888 sqrt checks
    sqrt_chk = a.out / "sqrt-check"
    run([CC, "-O2", "-no-pie", SQRT_CHK_C, SQRT_REG_S, w3_o, "-lm", "-pthread", "-o", sqrt_chk])
    out = run([sqrt_chk])
    sqrt_chk.unlink()
    print(f"[opt-w3] sqrt checks PASSED: {out.strip()}")
    print(f"Built: {w3_o} ({w3_o.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
