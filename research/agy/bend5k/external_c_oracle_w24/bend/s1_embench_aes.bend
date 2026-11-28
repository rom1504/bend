import Base
# s1_embench_aes: Port of Embench-IoT nettle-aes (nettle-aes.c)
# AES-256 ECB (14 rounds, 4x256 T-tables), 3000 rounds x 16 blocks (256 bytes).

type AesTables is Type:
  AT{sbox: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk: Array<U32>}

type Block4 is Type:
  B4{s0: U32, s1: U32, s2: U32, s3: U32}

type EncSt is Type:
  ES{tab: AesTables, buf: Array<U32>}

type RndSt is Type:
  RS{tab: AesTables, b: Block4}

def xtime(+x: U32) -> U32:
  +s = U32.and(U32.shln(x, 1n), 255)
  Bool.pick(U32, U32.is_ne(U32.and(x, 128), 0), U32.xor(s, 27), s)

def gf_mul_step(+rem: Nat, +a: U32, +b: U32, +p: U32) -> U32:
  match rem:
    case 0n:
      p
    case 1n+q:
      +p1 = Bool.pick(U32, U32.is_ne(U32.and(b, 1), 0), U32.xor(p, a), p)
      gf_mul_step(q, xtime(a), U32.shrn(b, 1n), p1)

def gf_mul(+a: U32, +b: U32) -> U32:
  gf_mul_step(8n, a, b, 0)

def gf_pow_step(+rem: Nat, +base: U32, +exp: U32, +res: U32) -> U32:
  match rem:
    case 0n:
      res
    case 1n+q:
      +res1 = Bool.pick(U32, U32.is_ne(U32.and(exp, 1), 0), gf_mul(res, base), res)
      gf_pow_step(q, gf_mul(base, base), U32.shrn(exp, 1n), res1)

def rotl8(+x: U32, +n: Nat, +m: Nat) -> U32:
  U32.and(U32.or(U32.shln(x, n), U32.shrn(x, m)), 255)

def sbox_val(+x: U32) -> U32:
  +inv = gf_pow_step(8n, x, 254, 1)
  +y = Bool.pick(U32, U32.is_eq(x, 0), 0, inv)
  +r1 = rotl8(y, 1n, 7n)
  +r2 = rotl8(y, 2n, 6n)
  +r3 = rotl8(y, 3n, 5n)
  +r4 = rotl8(y, 4n, 4n)
  U32.xor(U32.xor(U32.xor(y, r1), U32.xor(r2, r3)), U32.xor(r4, 99))

def build_tables(+rem: Nat, +i: U32, tab: AesTables) -> AesTables:
  match rem:
    case 0n:
      tab
    case 1n+p:
      AT{sb, t0, t1, t2, t3, rk} = tab
      +s = sbox_val(i)
      +s2 = xtime(s)
      +s3 = U32.xor(s2, s)
      +w0 = U32.or(U32.or(U32.shln(s2, 24n), U32.shln(s, 16n)), U32.or(U32.shln(s, 8n), s3))
      +w1 = U32.or(U32.shrn(w0, 8n), U32.shln(w0, 24n))
      +w2 = U32.or(U32.shrn(w0, 16n), U32.shln(w0, 16n))
      +w3 = U32.or(U32.shrn(w0, 24n), U32.shln(w0, 8n))
      build_tables(p, U32.inc(i), AT{Array.set(U32, sb, i, s), Array.set(U32, t0, i, w0), Array.set(U32, t1, i, w1), Array.set(U32, t2, i, w2), Array.set(U32, t3, i, w3), rk})

def sub_word4(+b0: U32, +b1: U32, +b2: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (sb4, +b3) = r
  (sb4, U32.or(U32.or(U32.shln(b0, 24n), U32.shln(b1, 16n)), U32.or(U32.shln(b2, 8n), b3)))

def sub_word3(+w: U32, +b0: U32, +b1: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (sb3, +b2) = r
  sub_word4(b0, b1, b2, Array.get(U32, sb3, U32.and(w, 255)))

def sub_word2(+w: U32, +b0: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (sb2, +b1) = r
  sub_word3(w, b0, b1, Array.get(U32, sb2, U32.and(U32.shrn(w, 8n), 255)))

def sub_word1(+w: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (sb1, +b0) = r
  sub_word2(w, b0, Array.get(U32, sb1, U32.and(U32.shrn(w, 16n), 255)))

def sub_word(sb: Array<U32>, +w: U32) -> Array<U32> & U32:
  sub_word1(w, Array.get(U32, sb, U32.and(U32.shrn(w, 24n), 255)))

type EkSt is Type:
  EK{tab: AesTables, rcon: U32}

def ek_sub0(+i: U32, +rcon: U32, +prev8: U32, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk2: Array<U32>, rs: Array<U32> & U32) -> EkSt:
  (sb1, +sw) = rs
  +nw = U32.xor(U32.xor(prev8, sw), U32.shln(rcon, 24n))
  EK{AT{sb1, t0, t1, t2, t3, Array.set(U32, rk2, i, nw)}, xtime(rcon)}

def ek_sub4(+i: U32, +rcon: U32, +prev8: U32, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk2: Array<U32>, rs: Array<U32> & U32) -> EkSt:
  (sb1, +sw) = rs
  +nw = U32.xor(prev8, sw)
  EK{AT{sb1, t0, t1, t2, t3, Array.set(U32, rk2, i, nw)}, rcon}

def ek_br4(is4: Bool, +i: U32, +rcon: U32, +prev: U32, +prev8: U32, sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk2: Array<U32>) -> EkSt:
  match is4:
    case True{}:
      ek_sub4(i, rcon, prev8, t0, t1, t2, t3, rk2, sub_word(sb, prev))
    case False{}:
      EK{AT{sb, t0, t1, t2, t3, Array.set(U32, rk2, i, U32.xor(prev8, prev))}, rcon}

def ek_br0(is0: Bool, +i: U32, +rcon: U32, +prev: U32, +prev8: U32, sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk2: Array<U32>) -> EkSt:
  match is0:
    case True{}:
      +rot = U32.or(U32.shln(prev, 8n), U32.shrn(prev, 24n))
      ek_sub0(i, rcon, prev8, t0, t1, t2, t3, rk2, sub_word(sb, rot))
    case False{}:
      ek_br4(U32.is_eq(U32.and(i, 7), 4), i, rcon, prev, prev8, sb, t0, t1, t2, t3, rk2)

def ek_get2(+i: U32, +rcon: U32, +prev: U32, sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, r: Array<U32> & U32) -> EkSt:
  (rk2, +prev8) = r
  ek_br0(U32.is_eq(U32.and(i, 7), 0), i, rcon, prev, prev8, sb, t0, t1, t2, t3, rk2)

def ek_get1(+i: U32, +rcon: U32, sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, r: Array<U32> & U32) -> EkSt:
  (rk1, +prev) = r
  ek_get2(i, rcon, prev, sb, t0, t1, t2, t3, Array.get(U32, rk1, U32.sub(i, 8)))

def expand_key_loop(+rem: Nat, +i: U32, st: EkSt) -> AesTables:
  match rem:
    case 0n:
      EK{tab, +rcon} = st
      tab
    case 1n+p:
      EK{AT{sb, t0, t1, t2, t3, rk}, +rcon} = st
      expand_key_loop(p, U32.inc(i), ek_get1(i, rcon, sb, t0, t1, t2, t3, Array.get(U32, rk, U32.sub(i, 1))))

def init_key(tab: AesTables) -> AesTables:
  AT{sb, t0, t1, t2, t3, rk} = tab
  rk = Array.set(U32, rk, 0, 3382007089)
  rk = Array.set(U32, rk, 1, 2790314324)
  rk = Array.set(U32, rk, 2, 2077803946)
  rk = Array.set(U32, rk, 3, 2762259884)
  rk = Array.set(U32, rk, 4, 1558844103)
  rk = Array.set(U32, rk, 5, 4169389752)
  rk = Array.set(U32, rk, 6, 1574358829)
  rk = Array.set(U32, rk, 7, 1623762416)
  expand_key_loop(52n, 8, EK{AT{sb, t0, t1, t2, t3, rk}, 1})

# Helper: lookup T0[a], T1[b], T2[c], T3[d], rk[ki] and XOR them
type LaneRes is Type:
  LR{tab: AesTables, val: U32}

def lane5(sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, +acc: U32, r: Array<U32> & U32) -> LaneRes:
  (rk1, +kv) = r
  LR{AT{sb, t0, t1, t2, t3, rk1}, U32.xor(acc, kv)}

def lane4(sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, rk: Array<U32>, +ki: U32, +acc: U32, r: Array<U32> & U32) -> LaneRes:
  (t3a, +v3) = r
  lane5(sb, t0, t1, t2, t3a, U32.xor(acc, v3), Array.get(U32, rk, ki))

def lane3(sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t3: Array<U32>, rk: Array<U32>, +i3: U32, +ki: U32, +acc: U32, r: Array<U32> & U32) -> LaneRes:
  (t2a, +v2) = r
  lane4(sb, t0, t1, t2a, rk, ki, U32.xor(acc, v2), Array.get(U32, t3, i3))

def lane2(sb: Array<U32>, t0: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk: Array<U32>, +i2: U32, +i3: U32, +ki: U32, +v0: U32, r: Array<U32> & U32) -> LaneRes:
  (t1a, +v1) = r
  lane3(sb, t0, t1a, t3, rk, i3, ki, U32.xor(v0, v1), Array.get(U32, t2, i2))

def lane1(sb: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk: Array<U32>, +i1: U32, +i2: U32, +i3: U32, +ki: U32, r: Array<U32> & U32) -> LaneRes:
  (t0a, +v0) = r
  lane2(sb, t0a, t2, t3, rk, i2, i3, ki, v0, Array.get(U32, t1, i1))

def t_lane(tab: AesTables, +s0: U32, +s1: U32, +s2: U32, +s3: U32, +ki: U32) -> LaneRes:
  AT{sb, t0, t1, t2, t3, rk} = tab
  lane1(sb, t1, t2, t3, rk, U32.and(U32.shrn(s1, 16n), 255), U32.and(U32.shrn(s2, 8n), 255), U32.and(s3, 255), ki, Array.get(U32, t0, U32.and(U32.shrn(s0, 24n), 255)))

def rnd_l3(+n0: U32, +n1: U32, +n2: U32, lr: LaneRes) -> RndSt:
  LR{tab, +n3} = lr
  RS{tab, B4{n0, n1, n2, n3}}

def rnd_l2(+rki: U32, +s0: U32, +s1: U32, +s2: U32, +s3: U32, +n0: U32, +n1: U32, lr: LaneRes) -> RndSt:
  LR{tab, +n2} = lr
  rnd_l3(n0, n1, n2, t_lane(tab, s3, s0, s1, s2, U32.add(rki, 3)))

def rnd_l1(+rki: U32, +s0: U32, +s1: U32, +s2: U32, +s3: U32, +n0: U32, lr: LaneRes) -> RndSt:
  LR{tab, +n1} = lr
  rnd_l2(rki, s0, s1, s2, s3, n0, n1, t_lane(tab, s2, s3, s0, s1, U32.add(rki, 2)))

def rnd_l0(+rki: U32, +s0: U32, +s1: U32, +s2: U32, +s3: U32, lr: LaneRes) -> RndSt:
  LR{tab, +n0} = lr
  rnd_l1(rki, s0, s1, s2, s3, n0, t_lane(tab, s1, s2, s3, s0, U32.add(rki, 1)))

def aes_round(+rem: Nat, +rki: U32, st: RndSt) -> RndSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      RS{tab, B4{+s0, +s1, +s2, +s3}} = st
      aes_round(p, U32.add(rki, 4), rnd_l0(rki, s0, s1, s2, s3, t_lane(tab, s0, s1, s2, s3, rki)))

# Final round lane using sbox
def flane5(t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, sb: Array<U32>, +w: U32, r: Array<U32> & U32) -> LaneRes:
  (rk1, +kv) = r
  LR{AT{sb, t0, t1, t2, t3, rk1}, U32.xor(w, kv)}

def flane4(t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk: Array<U32>, +ki: U32, +b0: U32, +b1: U32, +b2: U32, r: Array<U32> & U32) -> LaneRes:
  (sb4, +b3) = r
  +w = U32.or(U32.or(U32.shln(b0, 24n), U32.shln(b1, 16n)), U32.or(U32.shln(b2, 8n), b3))
  flane5(t0, t1, t2, t3, sb4, w, Array.get(U32, rk, ki))

def flane3(t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk: Array<U32>, +i3: U32, +ki: U32, +b0: U32, +b1: U32, r: Array<U32> & U32) -> LaneRes:
  (sb3, +b2) = r
  flane4(t0, t1, t2, t3, rk, ki, b0, b1, b2, Array.get(U32, sb3, i3))

def flane2(t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk: Array<U32>, +i2: U32, +i3: U32, +ki: U32, +b0: U32, r: Array<U32> & U32) -> LaneRes:
  (sb2, +b1) = r
  flane3(t0, t1, t2, t3, rk, i3, ki, b0, b1, Array.get(U32, sb2, i2))

def flane1(t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, rk: Array<U32>, +i1: U32, +i2: U32, +i3: U32, +ki: U32, r: Array<U32> & U32) -> LaneRes:
  (sb1, +b0) = r
  flane2(t0, t1, t2, t3, rk, i2, i3, ki, b0, Array.get(U32, sb1, i1))

def f_lane(tab: AesTables, +s0: U32, +s1: U32, +s2: U32, +s3: U32, +ki: U32) -> LaneRes:
  AT{sb, t0, t1, t2, t3, rk} = tab
  flane1(t0, t1, t2, t3, rk, U32.and(U32.shrn(s1, 16n), 255), U32.and(U32.shrn(s2, 8n), 255), U32.and(s3, 255), ki, Array.get(U32, sb, U32.and(U32.shrn(s0, 24n), 255)))

def fin_l3(+o0: U32, +o1: U32, +o2: U32, lr: LaneRes) -> RndSt:
  LR{tab, +o3} = lr
  RS{tab, B4{o0, o1, o2, o3}}

def fin_l2(+s0: U32, +s1: U32, +s2: U32, +s3: U32, +o0: U32, +o1: U32, lr: LaneRes) -> RndSt:
  LR{tab, +o2} = lr
  fin_l3(o0, o1, o2, f_lane(tab, s3, s0, s1, s2, 59))

def fin_l1(+s0: U32, +s1: U32, +s2: U32, +s3: U32, +o0: U32, lr: LaneRes) -> RndSt:
  LR{tab, +o1} = lr
  fin_l2(s0, s1, s2, s3, o0, o1, f_lane(tab, s2, s3, s0, s1, 58))

def fin_l0(+s0: U32, +s1: U32, +s2: U32, +s3: U32, lr: LaneRes) -> RndSt:
  LR{tab, +o0} = lr
  fin_l1(s0, s1, s2, s3, o0, f_lane(tab, s1, s2, s3, s0, 57))

def after_13(rs: RndSt) -> RndSt:
  RS{tab, B4{+s0, +s1, +s2, +s3}} = rs
  fin_l0(s0, s1, s2, s3, f_lane(tab, s0, s1, s2, s3, 56))

def blk_k3(sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, +x0: U32, +x1: U32, +x2: U32, +x3: U32, r: Array<U32> & U32) -> RndSt:
  (rk4, +k3) = r
  after_13(aes_round(13n, 4, RS{AT{sb, t0, t1, t2, t3, rk4}, B4{x0, x1, x2, U32.xor(x3, k3)}}))

def blk_k2(sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, +x0: U32, +x1: U32, +x2: U32, +x3: U32, r: Array<U32> & U32) -> RndSt:
  (rk3, +k2) = r
  blk_k3(sb, t0, t1, t2, t3, x0, x1, U32.xor(x2, k2), x3, Array.get(U32, rk3, 3))

def blk_k1(sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, +x0: U32, +x1: U32, +x2: U32, +x3: U32, r: Array<U32> & U32) -> RndSt:
  (rk2, +k1) = r
  blk_k2(sb, t0, t1, t2, t3, x0, U32.xor(x1, k1), x2, x3, Array.get(U32, rk2, 2))

def blk_k0(sb: Array<U32>, t0: Array<U32>, t1: Array<U32>, t2: Array<U32>, t3: Array<U32>, +x0: U32, +x1: U32, +x2: U32, +x3: U32, r: Array<U32> & U32) -> RndSt:
  (rk1, +k0) = r
  blk_k1(sb, t0, t1, t2, t3, U32.xor(x0, k0), x1, x2, x3, Array.get(U32, rk1, 1))

def aes_block(tab: AesTables, b: Block4) -> RndSt:
  AT{sb, t0, t1, t2, t3, rk} = tab
  B4{+x0, +x1, +x2, +x3} = b
  blk_k0(sb, t0, t1, t2, t3, x0, x1, x2, x3, Array.get(U32, rk, 0))

def enc_store(+idx: U32, buf4: Array<U32>, rs: RndSt) -> EncSt:
  RS{tab1, B4{+o0, +o1, +o2, +o3}} = rs
  buf5 = Array.set(U32, buf4, idx, o0)
  buf6 = Array.set(U32, buf5, U32.add(idx, 1), o1)
  buf7 = Array.set(U32, buf6, U32.add(idx, 2), o2)
  buf8 = Array.set(U32, buf7, U32.add(idx, 3), o3)
  ES{tab1, buf8}

def enc_g3(+idx: U32, tab: AesTables, +w0: U32, +w1: U32, +w2: U32, r: Array<U32> & U32) -> EncSt:
  (buf4, +w3) = r
  enc_store(idx, buf4, aes_block(tab, B4{w0, w1, w2, w3}))

def enc_g2(+idx: U32, tab: AesTables, +w0: U32, +w1: U32, r: Array<U32> & U32) -> EncSt:
  (buf3, +w2) = r
  enc_g3(idx, tab, w0, w1, w2, Array.get(U32, buf3, U32.add(idx, 3)))

def enc_g1(+idx: U32, tab: AesTables, +w0: U32, r: Array<U32> & U32) -> EncSt:
  (buf2, +w1) = r
  enc_g2(idx, tab, w0, w1, Array.get(U32, buf2, U32.add(idx, 2)))

def enc_g0(+idx: U32, tab: AesTables, r: Array<U32> & U32) -> EncSt:
  (buf1, +w0) = r
  enc_g1(idx, tab, w0, Array.get(U32, buf1, U32.add(idx, 1)))

def enc_blocks(+rem: Nat, +idx: U32, st: EncSt) -> EncSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      ES{tab, buf} = st
      enc_blocks(p, U32.add(idx, 4), enc_g0(idx, tab, Array.get(U32, buf, idx)))

def run_rounds(+rem: Nat, st: EncSt) -> EncSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      run_rounds(p, enc_blocks(16n, 0, st))

def init_pt(buf: Array<U32>) -> Array<U32>:
  buf = Array.set(U32, buf, 0, 3615470476)
  buf = Array.set(U32, buf, 1, 572900463)
  buf = Array.set(U32, buf, 2, 3117795608)
  buf = Array.set(U32, buf, 3, 3230846984)
  buf = Array.set(U32, buf, 4, 2234184552)
  buf = Array.set(U32, buf, 5, 3179589618)
  buf = Array.set(U32, buf, 6, 210498846)
  buf = Array.set(U32, buf, 7, 1366312560)
  buf = Array.set(U32, buf, 8, 2659966689)
  buf = Array.set(U32, buf, 9, 2258761933)
  buf = Array.set(U32, buf, 10, 1895997345)
  buf = Array.set(U32, buf, 11, 2068099202)
  buf = Array.set(U32, buf, 12, 1082117812)
  buf = Array.set(U32, buf, 13, 3193814158)
  buf = Array.set(U32, buf, 14, 423824186)
  buf = Array.set(U32, buf, 15, 1181327564)
  buf = Array.set(U32, buf, 16, 3981402543)
  buf = Array.set(U32, buf, 17, 2796116807)
  buf = Array.set(U32, buf, 18, 1766970624)
  buf = Array.set(U32, buf, 19, 2004803118)
  buf = Array.set(U32, buf, 20, 2124823776)
  buf = Array.set(U32, buf, 21, 870313280)
  buf = Array.set(U32, buf, 22, 1058719712)
  buf = Array.set(U32, buf, 23, 3343311675)
  buf = Array.set(U32, buf, 24, 2421056597)
  buf = Array.set(U32, buf, 25, 781006395)
  buf = Array.set(U32, buf, 26, 2459666287)
  buf = Array.set(U32, buf, 27, 2928950538)
  buf = Array.set(U32, buf, 28, 3366080127)
  buf = Array.set(U32, buf, 29, 1518595096)
  buf = Array.set(U32, buf, 30, 4253177032)
  buf = Array.set(U32, buf, 31, 3639418450)
  buf = Array.set(U32, buf, 32, 2110443339)
  buf = Array.set(U32, buf, 33, 3123800249)
  buf = Array.set(U32, buf, 34, 2024000078)
  buf = Array.set(U32, buf, 35, 1921430067)
  buf = Array.set(U32, buf, 36, 2043399590)
  buf = Array.set(U32, buf, 37, 1134796026)
  buf = Array.set(U32, buf, 38, 3995774523)
  buf = Array.set(U32, buf, 39, 1925596722)
  buf = Array.set(U32, buf, 40, 2778285458)
  buf = Array.set(U32, buf, 41, 1182391523)
  buf = Array.set(U32, buf, 42, 1051298321)
  buf = Array.set(U32, buf, 43, 927565284)
  buf = Array.set(U32, buf, 44, 1478106990)
  buf = Array.set(U32, buf, 45, 3618301450)
  buf = Array.set(U32, buf, 46, 3290955078)
  buf = Array.set(U32, buf, 47, 1550626856)
  buf = Array.set(U32, buf, 48, 778798133)
  buf = Array.set(U32, buf, 49, 2417651000)
  buf = Array.set(U32, buf, 50, 4066986684)
  buf = Array.set(U32, buf, 51, 2532104022)
  buf = Array.set(U32, buf, 52, 1697115814)
  buf = Array.set(U32, buf, 53, 2959055984)
  buf = Array.set(U32, buf, 54, 1906650092)
  buf = Array.set(U32, buf, 55, 2473006785)
  buf = Array.set(U32, buf, 56, 3300082544)
  buf = Array.set(U32, buf, 57, 3043863957)
  buf = Array.set(U32, buf, 58, 1106248444)
  buf = Array.set(U32, buf, 59, 2371391137)
  buf = Array.set(U32, buf, 60, 1177695336)
  buf = Array.set(U32, buf, 61, 294433594)
  buf = Array.set(U32, buf, 62, 3679764026)
  buf = Array.set(U32, buf, 63, 3006803580)
  buf

def fold_be32(+acc: U32, +w: U32) -> U32:
  +b0 = U32.and(U32.shrn(w, 24n), 255)
  +b1 = U32.and(U32.shrn(w, 16n), 255)
  +b2 = U32.and(U32.shrn(w, 8n), 255)
  +b3 = U32.and(w, 255)
  +a1 = U32.mul(U32.xor(acc, b0), 16777619)
  +a2 = U32.mul(U32.xor(a1, b1), 16777619)
  +a3 = U32.mul(U32.xor(a2, b2), 16777619)
  U32.mul(U32.xor(a3, b3), 16777619)

type FoldSt is Type:
  FS{buf: Array<U32>, acc: U32}

def fold_step(+acc: U32, r: Array<U32> & U32) -> FoldSt:
  (buf1, +w) = r
  FS{buf1, fold_be32(acc, w)}

def fold_buf(+rem: Nat, +i: U32, st: FoldSt) -> U32:
  match rem:
    case 0n:
      FS{buf, +acc} = st
      acc
    case 1n+p:
      FS{buf, +acc} = st
      fold_buf(p, U32.inc(i), fold_step(acc, Array.get(U32, buf, i)))

def finish_main(st: EncSt) -> U32:
  ES{tab2, buf1} = st
  fold_buf(64n, 0, FS{buf1, 2166136261})

def main() -> U32:
  tab1 = init_key(build_tables(256n, 0, AT{Array.new(U32, 8n, 0), Array.new(U32, 8n, 0), Array.new(U32, 8n, 0), Array.new(U32, 8n, 0), Array.new(U32, 8n, 0), Array.new(U32, 6n, 0)}))
  buf0 = init_pt(Array.new(U32, 6n, 0))
  finish_main(run_rounds(3000n, ES{tab1, buf0}))
