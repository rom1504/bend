import Base
# k3_soa_particle_acc: Struct-of-Arrays (SoA) 4-array F32 particle integrator
# Fresh non-suite kernel 3: N = 16384 particles, 200 timesteps.

type SoA is Type:
  P4{px: Array<F32>, py: Array<F32>, vx: Array<F32>, vy: Array<F32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fl(n: U32, d: U32) -> F32:
  F32.div(U32.to_f32(n), U32.to_f32(d))

def fill_f32(+n: Nat, +i: U32, +seed: U32, r: Array<F32> & F32) -> Array<F32>:
  match n:
    case 0n:
      (a, old) = r
      a
    case 1n+p:
      (a, old) = r
      +q = U32.and(prng(U32.add(U32.mul(U32.inc(i), 2654435761), seed)), 1023)
      +v = F32.sub(fl(q, 512), fl(1, 1))
      fill_f32(p, U32.inc(i), seed, Array.swap(F32, a, i, v))

def step_vy(+i: U32, +gx: F32, +gy: F32, +x: F32, +y: F32, +ux: F32, px: Array<F32>, py: Array<F32>, vx: Array<F32>, rvy: Array<F32> & F32) -> SoA:
  (vy, +uy) = rvy
  +dt = fl(1, 32)
  +damp = fl(255, 256)
  +k = fl(1, 16)
  +nvx = F32.add(F32.mul(ux, damp), F32.mul(F32.sub(gx, F32.mul(k, x)), dt))
  +nvy = F32.add(F32.mul(uy, damp), F32.mul(F32.sub(gy, F32.mul(k, y)), dt))
  +npx = F32.add(x, F32.mul(nvx, dt))
  +npy = F32.add(y, F32.mul(nvy, dt))
  P4{Array.set(F32, px, i, npx), Array.set(F32, py, i, npy), Array.set(F32, vx, i, nvx), Array.set(F32, vy, i, nvy)}

def step_vx(+i: U32, +gx: F32, +gy: F32, +x: F32, +y: F32, px: Array<F32>, py: Array<F32>, rvx: Array<F32> & F32, vy: Array<F32>) -> SoA:
  (vx, +ux) = rvx
  step_vy(i, gx, gy, x, y, ux, px, py, vx, Array.get(F32, vy, i))

def step_py(+i: U32, +gx: F32, +gy: F32, +x: F32, px: Array<F32>, rpy: Array<F32> & F32, vx: Array<F32>, vy: Array<F32>) -> SoA:
  (py, +y) = rpy
  step_vx(i, gx, gy, x, y, px, py, Array.get(F32, vx, i), vy)

def step_px(+i: U32, +gx: F32, +gy: F32, rpx: Array<F32> & F32, py: Array<F32>, vx: Array<F32>, vy: Array<F32>) -> SoA:
  (px, +x) = rpx
  step_py(i, gx, gy, x, px, Array.get(F32, py, i), vx, vy)

def integrate(+rem: Nat, +i: U32, +gx: F32, +gy: F32, st: SoA) -> SoA:
  match rem:
    case 0n:
      st
    case 1n+p:
      P4{px, py, vx, vy} = st
      integrate(p, U32.inc(i), gx, gy, step_px(i, gx, gy, Array.get(F32, px, i), py, vx, vy))

def run_steps(+rem: Nat, +t: U32, st: SoA) -> SoA:
  match rem:
    case 0n:
      st
    case 1n+p:
      +gx = fl(U32.and(t, 7), 32)
      +gy = fl(U32.and(U32.add(t, 3), 7), 32)
      run_steps(p, U32.inc(t), integrate(16384n, 0, gx, gy, st))

type ChkSt is Type:
  CRes{px: Array<F32>, py: Array<F32>, h: U32}

def checksum_y(+h: U32, +x: F32, px: Array<F32>, rpy: Array<F32> & F32) -> ChkSt:
  (py, +y) = rpy
  +qx = F32.to_u32(F32.mul(F32.add(x, U32.to_f32(32)), U32.to_f32(1024)))
  +qy = F32.to_u32(F32.mul(F32.add(y, U32.to_f32(32)), U32.to_f32(1024)))
  +nh = U32.xor(U32.mul(U32.xor(U32.mul(h, 2654435761), qx), 16777619), qy)
  CRes{px, py, nh}

def checksum_x(+i: U32, +h: U32, rpx: Array<F32> & F32, py: Array<F32>) -> ChkSt:
  (px, +x) = rpx
  checksum_y(h, x, px, Array.get(F32, py, i))

def checksum(+n: Nat, +i: U32, cs: ChkSt) -> U32:
  match n:
    case 0n:
      CRes{px, py, +h} = cs
      h
    case 1n+p:
      CRes{px, py, +h} = cs
      checksum(p, U32.inc(i), checksum_x(i, h, Array.get(F32, px, i), py))

def finish(st: SoA) -> U32:
  P4{pxf, pyf, vxf, vyf} = st
  checksum(16384n, 0, CRes{pxf, pyf, 2166136261})

def main() -> U32:
  px = fill_f32(16384n, 0, 11, (Array.new(F32, 14n, U32.to_f32(0)), U32.to_f32(0)))
  py = fill_f32(16384n, 0, 23, (Array.new(F32, 14n, U32.to_f32(0)), U32.to_f32(0)))
  vx = fill_f32(16384n, 0, 37, (Array.new(F32, 14n, U32.to_f32(0)), U32.to_f32(0)))
  vy = fill_f32(16384n, 0, 53, (Array.new(F32, 14n, U32.to_f32(0)), U32.to_f32(0)))
  finish(run_steps(200n, 0, P4{px, py, vx, vy}))
