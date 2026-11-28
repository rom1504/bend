import Base
# s5_embench_edn: Port of Embench-IoT edn (libedn.c) DSP filterbank
# 1200 rounds: vec_mpy1, mac, fir, fir_no_red_ld, latsynth, iir1, jpegdct.

def sext16(+x: U32) -> U32:
  +lo = U32.and(x, 65535)
  Bool.pick(U32, U32.is_ne(U32.and(lo, 32768), 0), U32.or(lo, 4294901760), lo)

def sar15(+x: U32) -> U32:
  +sh = U32.shrn(x, 15n)
  Bool.pick(U32, U32.is_ne(U32.and(x, 2147483648), 0), U32.or(sh, 4294836224), sh)

def sar16(+x: U32) -> U32:
  +sh = U32.shrn(x, 16n)
  Bool.pick(U32, U32.is_ne(U32.and(x, 2147483648), 0), U32.or(sh, 4294901760), sh)

def sar13(+x: U32) -> U32:
  +sh = U32.shrn(x, 13n)
  Bool.pick(U32, U32.is_ne(U32.and(x, 2147483648), 0), U32.or(sh, 4294443008), sh)

def sar3(+x: U32) -> U32:
  +sh = U32.shrn(x, 3n)
  Bool.pick(U32, U32.is_ne(U32.and(x, 2147483648), 0), U32.or(sh, 3758096384), sh)

type AbPair is Type:
  AB{a: Array<U32>, b: Array<U32>}

type AboTri is Type:
  ABO{a: Array<U32>, b: Array<U32>, o: Array<U32>}

def init_ab_chunk(+rem: Nat, +base: U32, st: AbPair) -> AbPair:
  match rem:
    case 0n:
      st
    case 1n+p:
      AB{a, b} = st
      a = Array.set(U32, a, U32.add(base, 0), 0)
      b = Array.set(U32, b, U32.add(base, 0), 3168)
      a = Array.set(U32, a, U32.add(base, 1), 2047)
      b = Array.set(U32, b, U32.add(base, 1), 3136)
      a = Array.set(U32, a, U32.add(base, 2), 3072)
      b = Array.set(U32, b, U32.add(base, 2), 3104)
      a = Array.set(U32, a, U32.add(base, 3), 2048)
      b = Array.set(U32, b, U32.add(base, 3), 3072)
      a = Array.set(U32, a, U32.add(base, 4), 512)
      b = Array.set(U32, b, U32.add(base, 4), 4294964736)
      a = Array.set(U32, a, U32.add(base, 5), 4294965248)
      b = Array.set(U32, b, U32.add(base, 5), 4294964224)
      a = Array.set(U32, a, U32.add(base, 6), 4294963968)
      b = Array.set(U32, b, U32.add(base, 6), 4294963712)
      a = Array.set(U32, a, U32.add(base, 7), 1024)
      b = Array.set(U32, b, U32.add(base, 7), 4294963200)
      init_ab_chunk(p, U32.add(base, 8), AB{a, b})

# 1. vec_mpy1: y[i] += (scaler * x[i]) >> 15 for i = 0..149
def vmpy_2(+i: U32, +sc: U32, +xi: U32, b1: Array<U32>, ra: Array<U32> & U32) -> AbPair:
  (a1, +yi) = ra
  +nv = sext16(U32.add(yi, sar15(U32.mul(sc, xi))))
  AB{Array.set(U32, a1, i, nv), b1}

def vmpy_1(+i: U32, +sc: U32, a: Array<U32>, rb: Array<U32> & U32) -> AbPair:
  (b1, +xi) = rb
  vmpy_2(i, sc, xi, b1, Array.get(U32, a, i))

def vec_mpy1(+rem: Nat, +i: U32, +sc: U32, st: AbPair) -> AbPair:
  match rem:
    case 0n:
      st
    case 1n+p:
      AB{a, b} = st
      vec_mpy1(p, U32.inc(i), sc, vmpy_1(i, sc, a, Array.get(U32, b, i)))

# 2. mac: dotp += b[i]*a[i], sqr += b[i]*b[i] for i = 0..149
type MacSt is Type:
  MS{a: Array<U32>, b: Array<U32>, sqr: U32, dotp: U32}

def mac_2(+sqr: U32, +dotp: U32, +ai: U32, a1: Array<U32>, rb: Array<U32> & U32) -> MacSt:
  (b1, +bi) = rb
  MS{a1, b1, U32.add(sqr, U32.mul(bi, bi)), U32.add(dotp, U32.mul(bi, ai))}

def mac_1(+i: U32, +sqr: U32, +dotp: U32, b: Array<U32>, ra: Array<U32> & U32) -> MacSt:
  (a1, +ai) = ra
  mac_2(sqr, dotp, ai, a1, Array.get(U32, b, i))

def mac_loop(+rem: Nat, +i: U32, st: MacSt) -> MacSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      MS{a, b, +sqr, +dotp} = st
      mac_loop(p, U32.inc(i), mac_1(i, sqr, dotp, b, Array.get(U32, a, i)))

# 3. fir: for i=0..49: sum = sum_{j=0..49} a[i+j]*b[j]; o[i] = sum >> 15
type SumSt is Type:
  SS{a: Array<U32>, b: Array<U32>, sum: U32}

def fir_j2(+sum: U32, +av: U32, a1: Array<U32>, rb: Array<U32> & U32) -> SumSt:
  (b1, +bv) = rb
  SS{a1, b1, U32.add(sum, U32.mul(av, bv))}

def fir_j1(+j: U32, +sum: U32, b: Array<U32>, ra: Array<U32> & U32) -> SumSt:
  (a1, +av) = ra
  fir_j2(sum, av, a1, Array.get(U32, b, j))

def fir_j(+rem: Nat, +i: U32, +j: U32, st: SumSt) -> SumSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      SS{a, b, +sum} = st
      fir_j(p, i, U32.inc(j), fir_j1(j, sum, b, Array.get(U32, a, U32.add(i, j))))

def fir_store(+i: U32, o: Array<U32>, ss: SumSt) -> AboTri:
  SS{a, b, +sum} = ss
  ABO{a, b, Array.set(U32, o, i, sar15(sum))}

def fir_i(+rem: Nat, +i: U32, st: AboTri) -> AboTri:
  match rem:
    case 0n:
      st
    case 1n+p:
      ABO{a, b, o} = st
      fir_i(p, U32.inc(i), fir_store(i, o, fir_j(50n, i, 0, SS{a, b, 0})))

# 4. fir_no_red_ld: for j=0..98 step 2: i=0..30 step 2
type Fir2St is Type:
  F2{a: Array<U32>, b: Array<U32>, x0: U32, s0: U32, s1: U32}

def fnr_i4(+x0: U32, +x1: U32, +x2: U32, +h0: U32, +s0: U32, +s1: U32, a2: Array<U32>, rb2: Array<U32> & U32) -> Fir2St:
  (b2, +h1) = rb2
  +ns0 = U32.add(U32.add(s0, U32.mul(x0, h0)), U32.mul(x1, h1))
  +ns1 = U32.add(U32.add(s1, U32.mul(x1, h0)), U32.mul(x2, h1))
  F2{a2, b2, x2, ns0, ns1}

def fnr_i3(+i: U32, +x0: U32, +x1: U32, +h0: U32, +s0: U32, +s1: U32, b1: Array<U32>, ra2: Array<U32> & U32) -> Fir2St:
  (a2, +x2) = ra2
  fnr_i4(x0, x1, x2, h0, s0, s1, a2, Array.get(U32, b1, U32.inc(i)))

def fnr_i2(+j: U32, +i: U32, +x0: U32, +x1: U32, +s0: U32, +s1: U32, a1: Array<U32>, rb1: Array<U32> & U32) -> Fir2St:
  (b1, +h0) = rb1
  fnr_i3(i, x0, x1, h0, s0, s1, b1, Array.get(U32, a1, U32.add(U32.add(j, i), 2)))

def fnr_i1(+j: U32, +i: U32, +x0: U32, +s0: U32, +s1: U32, b: Array<U32>, ra1: Array<U32> & U32) -> Fir2St:
  (a1, +x1) = ra1
  fnr_i2(j, i, x0, x1, s0, s1, a1, Array.get(U32, b, i))

def fnr_i(+rem: Nat, +j: U32, +i: U32, st: Fir2St) -> Fir2St:
  match rem:
    case 0n:
      st
    case 1n+p:
      F2{a, b, +x0, +s0, +s1} = st
      fnr_i(p, j, U32.add(i, 2), fnr_i1(j, i, x0, s0, s1, b, Array.get(U32, a, U32.add(U32.add(j, i), 1))))

def fnr_store(+j: U32, o: Array<U32>, f2: Fir2St) -> AboTri:
  F2{a, b, +x0, +s0, +s1} = f2
  o1 = Array.set(U32, o, j, sar15(s0))
  ABO{a, b, Array.set(U32, o1, U32.inc(j), sar15(s1))}

def fnr_j1(+j: U32, b: Array<U32>, o: Array<U32>, ra: Array<U32> & U32) -> AboTri:
  (a1, +x0) = ra
  fnr_store(j, o, fnr_i(16n, j, 0, F2{a1, b, x0, 0, 0}))

def fir_no_red(+rem: Nat, +j: U32, st: AboTri) -> AboTri:
  match rem:
    case 0n:
      st
    case 1n+p:
      ABO{a, b, o} = st
      fir_no_red(p, U32.add(j, 2), fnr_j1(j, b, o, Array.get(U32, a, j)))

# 5. latsynth(a, b, 100, d)
type LatSt is Type:
  LS{a: Array<U32>, b: Array<U32>, f: U32}

def lat_step2(+i: U32, +f: U32, +bi: U32, a1: Array<U32>, rb: Array<U32> & U32) -> LatSt:
  (b1, +ki) = rb
  +f1 = U32.sub(f, U32.mul(bi, ki))
  +nv = sext16(U32.add(bi, sar16(U32.mul(ki, sar16(f1)))))
  LS{Array.set(U32, a1, U32.inc(i), nv), b1, f1}

def lat_step1(+i: U32, +f: U32, b: Array<U32>, ra: Array<U32> & U32) -> LatSt:
  (a1, +bi) = ra
  lat_step2(i, f, bi, a1, Array.get(U32, b, i))

def lat_loop(+rem: Nat, +i: U32, st: LatSt) -> LatSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      LS{a, b, +f} = st
      lat_loop(p, U32.sub(i, 1), lat_step1(i, f, b, Array.get(U32, a, i)))

def lat_fin(ls: LatSt) -> LatSt:
  LS{a, b, +f} = ls
  LS{Array.set(U32, a, 0, sext16(sar16(f))), b, f}

def lat_init2(+f: U32, +b99: U32, a1: Array<U32>, rb: Array<U32> & U32) -> LatSt:
  (b1, +k99) = rb
  lat_fin(lat_loop(99n, 98, LS{a1, b1, U32.sub(f, U32.mul(b99, k99))}))

def lat_init1(+f: U32, b: Array<U32>, ra: Array<U32> & U32) -> LatSt:
  (a1, +b99) = ra
  lat_init2(f, b99, a1, Array.get(U32, b, 99))

def latsynth(a: Array<U32>, b: Array<U32>, +f: U32) -> LatSt:
  lat_init1(f, b, Array.get(U32, a, 99))

# 6. iir1(a, b, &output[100], output)
type IirSt is Type:
  IS{a: Array<U32>, o: Array<U32>, x: U32}

def iir_6(+si: U32, +x: U32, +c0: U32, +c1: U32, +c2: U32, +c3: U32, +s0: U32, a4: Array<U32>, ro2: Array<U32> & U32) -> IirSt:
  (o2, +s1) = ro2
  +t = U32.add(x, sar15(U32.add(U32.mul(c2, s0), U32.mul(c3, s1))))
  +nx = U32.add(t, sar15(U32.add(U32.mul(c0, s0), U32.mul(c1, s1))))
  o3 = Array.set(U32, o2, U32.inc(si), s0)
  IS{a4, Array.set(U32, o3, si, t), nx}

def iir_5(+si: U32, +x: U32, +c0: U32, +c1: U32, +c2: U32, +c3: U32, a4: Array<U32>, ro1: Array<U32> & U32) -> IirSt:
  (o1, +s0) = ro1
  iir_6(si, x, c0, c1, c2, c3, s0, a4, Array.get(U32, o1, U32.inc(si)))

def iir_4(+si: U32, +x: U32, +c0: U32, +c1: U32, +c2: U32, o: Array<U32>, ra4: Array<U32> & U32) -> IirSt:
  (a4, +c3) = ra4
  iir_5(si, x, c0, c1, c2, c3, a4, Array.get(U32, o, si))

def iir_3(+ci: U32, +si: U32, +x: U32, +c0: U32, +c1: U32, o: Array<U32>, ra3: Array<U32> & U32) -> IirSt:
  (a3, +c2) = ra3
  iir_4(si, x, c0, c1, c2, o, Array.get(U32, a3, U32.add(ci, 3)))

def iir_2(+ci: U32, +si: U32, +x: U32, +c0: U32, o: Array<U32>, ra2: Array<U32> & U32) -> IirSt:
  (a2, +c1) = ra2
  iir_3(ci, si, x, c0, c1, o, Array.get(U32, a2, U32.add(ci, 2)))

def iir_1(+ci: U32, +si: U32, +x: U32, o: Array<U32>, ra1: Array<U32> & U32) -> IirSt:
  (a1, +c0) = ra1
  iir_2(ci, si, x, c0, o, Array.get(U32, a1, U32.inc(ci)))

def iir_loop(+rem: Nat, +ci: U32, +si: U32, st: IirSt) -> IirSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      IS{a, o, +x} = st
      iir_loop(p, U32.add(ci, 4), U32.add(si, 2), iir_1(ci, si, x, o, Array.get(U32, a, ci)))

def iir_fin(b1: Array<U32>, st: IirSt) -> AboTri:
  IS{a1, o1, +x} = st
  ABO{a1, b1, Array.set(U32, o1, 100, x)}

def iir_start(a: Array<U32>, o: Array<U32>, rb: Array<U32> & U32) -> AboTri:
  (b1, +x0) = rb
  iir_fin(b1, iir_loop(50n, 0, 0, IS{a, o, x0}))

# 7. jpegdct(a, b) (2 passes x 8 lines)
type DctRow is Type:
  DR{d: Array<U32>, r: Array<U32>, v0: U32, v1: U32, v2: U32, v3: U32, v4: U32, v5: U32, v6: U32, v7: U32}

def dct_g7(+v0: U32, +v1: U32, +v2: U32, +v3: U32, +v4: U32, +v5: U32, +v6: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d8, +v7) = rd
  DR{d8, r, v0, v1, v2, v3, v4, v5, v6, v7}

def dct_g6(+base: U32, +k: U32, +v0: U32, +v1: U32, +v2: U32, +v3: U32, +v4: U32, +v5: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d7, +v6) = rd
  dct_g7(v0, v1, v2, v3, v4, v5, v6, r, Array.get(U32, d7, U32.add(base, U32.mul(7, k))))

def dct_g5(+base: U32, +k: U32, +v0: U32, +v1: U32, +v2: U32, +v3: U32, +v4: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d6, +v5) = rd
  dct_g6(base, k, v0, v1, v2, v3, v4, v5, r, Array.get(U32, d6, U32.add(base, U32.mul(6, k))))

def dct_g4(+base: U32, +k: U32, +v0: U32, +v1: U32, +v2: U32, +v3: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d5, +v4) = rd
  dct_g5(base, k, v0, v1, v2, v3, v4, r, Array.get(U32, d5, U32.add(base, U32.mul(5, k))))

def dct_g3(+base: U32, +k: U32, +v0: U32, +v1: U32, +v2: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d4, +v3) = rd
  dct_g4(base, k, v0, v1, v2, v3, r, Array.get(U32, d4, U32.add(base, U32.mul(4, k))))

def dct_g2(+base: U32, +k: U32, +v0: U32, +v1: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d3, +v2) = rd
  dct_g3(base, k, v0, v1, v2, r, Array.get(U32, d3, U32.add(base, U32.mul(3, k))))

def dct_g1(+base: U32, +k: U32, +v0: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d2, +v1) = rd
  dct_g2(base, k, v0, v1, r, Array.get(U32, d2, U32.add(base, U32.mul(2, k))))

def dct_g0(+base: U32, +k: U32, r: Array<U32>, rd: Array<U32> & U32) -> DctRow:
  (d1, +v0) = rd
  dct_g1(base, k, v0, r, Array.get(U32, d1, U32.add(base, k)))

def dct_apply(+pass2: Bool, +base: U32, +k: U32, dr: DctRow) -> AbPair:
  DR{d, r, +v0, +v1, +v2, +v3, +v4, +v5, +v6, +v7} = dr
  +t0 = U32.add(v0, v7)
  +t7 = U32.sub(v0, v7)
  +t1 = U32.add(v1, v6)
  +t6 = U32.sub(v1, v6)
  +t2 = U32.add(v2, v5)
  +t5 = U32.sub(v2, v5)
  +t3 = U32.add(v3, v4)
  +t4 = U32.sub(v3, v4)
  +t8 = U32.add(t0, t3)
  +t9 = U32.sub(t0, t3)
  +t10 = U32.add(t1, t2)
  +t11 = U32.sub(t1, t2)
  +d0 = sext16(Bool.pick(U32, pass2, sar3(U32.add(t8, t10)), U32.add(t8, t10)))
  +d4 = sext16(Bool.pick(U32, pass2, sar3(U32.sub(t8, t10)), U32.sub(t8, t10)))
  d = Array.set(U32, d, base, d0)
  d = Array.set(U32, d, U32.add(base, U32.mul(4, k)), d4)
  AB{d, r}

def dct_pass(+rem: Nat, +base: U32, +k: U32, +step: U32, +pass2: Bool, st: AbPair) -> AbPair:
  match rem:
    case 0n:
      st
    case 1n+p:
      AB{d, r} = st
      dct_pass(p, U32.add(base, step), k, step, pass2, dct_apply(pass2, base, k, dct_g0(base, k, r, Array.get(U32, d, base))))

type EdnSt is Type:
  ES{a: Array<U32>, b: Array<U32>, o: Array<U32>, acc: U32}

def rd_fin(+c_val: U32, +d_val: U32, +acc: U32, a: Array<U32>, b: Array<U32>, ro: Array<U32> & U32) -> EdnSt:
  (o1, +ov) = ro
  +a1 = U32.mul(U32.xor(acc, c_val), 16777619)
  +a2 = U32.mul(U32.xor(a1, d_val), 16777619)
  +a3 = U32.mul(U32.xor(a2, d_val), 16777619)
  +a4 = U32.mul(U32.xor(a3, ov), 16777619)
  ES{a, b, o1, a4}

def rd_after_dct(+r: U32, +c_val: U32, +d_val: U32, +acc: U32, o: Array<U32>, ab: AbPair) -> EdnSt:
  AB{a1, b1} = ab
  rd_fin(c_val, d_val, acc, a1, b1, Array.get(U32, o, U32.mod(r, 101)))

def rd_after_iir(+r: U32, +c_val: U32, +d_val: U32, +acc: U32, st: AboTri) -> EdnSt:
  ABO{a, b, o} = st
  rd_after_dct(r, c_val, d_val, acc, o, dct_pass(8n, 0, 8, 1, True{}, dct_pass(8n, 0, 1, 8, False{}, AB{a, b})))

def rd_after_lat(+r: U32, +c_val: U32, +acc: U32, o: Array<U32>, ls: LatSt) -> EdnSt:
  LS{a, b, +d_val} = ls
  rd_after_iir(r, c_val, d_val, acc, iir_start(a, o, Array.get(U32, b, 0)))

def rd_after_fnr(+r: U32, +c_val: U32, +acc: U32, st: AboTri) -> EdnSt:
  ABO{a, b, o} = st
  rd_after_lat(r, c_val, acc, o, latsynth(a, b, 43690))

def rd_after_mac(+r: U32, +acc: U32, o: Array<U32>, ms: MacSt) -> EdnSt:
  MS{a, b, +sqr, +dotp} = ms
  +c_val = sext16(sqr)
  o1 = Array.set(U32, o, 0, dotp)
  st1 = fir_i(50n, 0, ABO{a, b, o1})
  rd_after_fnr(r, c_val, acc, fir_no_red(50n, 0, st1))

def rd_after_vmpy(+r: U32, +acc: U32, o: Array<U32>, ab: AbPair) -> EdnSt:
  AB{a, b} = ab
  rd_after_mac(r, acc, o, mac_loop(150n, 0, MS{a, b, 3, 0}))

def rd_after_o0(+r: U32, +acc: U32, a: Array<U32>, b: Array<U32>, ro: Array<U32> & U32) -> EdnSt:
  (o1, +o0) = ro
  rd_after_mac(r, acc, o1, mac_loop(150n, 0, MS{a, b, 3, o0}))

def rd_after_vmpy2(+r: U32, +acc: U32, o: Array<U32>, ab: AbPair) -> EdnSt:
  AB{a, b} = ab
  rd_after_o0(r, acc, a, b, Array.get(U32, o, 0))

def run_rounds(+rem: Nat, +r: U32, st: EdnSt) -> EdnSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      ES{a, b, o, +acc} = st
      ab0 = init_ab_chunk(25n, 0, AB{a, b})
      ab1 = vec_mpy1(150n, 0, 3, ab0)
      run_rounds(p, U32.inc(r), rd_after_vmpy2(r, acc, o, ab1))

type HashSt is Type:
  HS{arr: Array<U32>, acc: U32}

def hash_step(+acc: U32, r: Array<U32> & U32) -> HashSt:
  (arr1, +v) = r
  HS{arr1, U32.mul(U32.xor(acc, v), 16777619)}

def hash_o(+rem: Nat, +idx: U32, st: HashSt) -> U32:
  match rem:
    case 0n:
      HS{arr, +acc} = st
      acc
    case 1n+p:
      HS{arr, +acc} = st
      hash_o(p, U32.inc(idx), hash_step(acc, Array.get(U32, arr, idx)))

def finish_edn(st: EdnSt) -> U32:
  ES{a, b, o, +acc} = st
  hash_o(101n, 0, HS{o, acc})

def main() -> U32:
  a = Array.new(U32, 8n, 0)
  b = Array.new(U32, 8n, 0)
  o = Array.new(U32, 8n, 0)
  finish_edn(run_rounds(1200n, 0, ES{a, b, o, 2166136261}))
