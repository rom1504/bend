import Base
import ./candidate.bend as H

# Support over the actual worker/code types and exact prepend helper.
# Arbitrary payloads are retained, including code errors, calls and term metadata.
law redirect_worker_choice:
  for hit: Bool
  for +name: String
  for +params: List<&2, H.N_Param>
  for +code: H.NC_Code
  for +deps: List<&2, String>
  for +shape: H.KTerm
  for +redirect: String
  for +adapter: String
  {H.NF_Worker{name, params, H.nt_choose(H.NC_Code, hit, u => H.nc_prepend(redirect, code), u => code), H.nt_choose(List<&2, String>, hit, u => Con{adapter, deps}, u => deps), shape} == H.nt_choose(H.NF_Worker, hit, u => H.NF_Worker{name, params, H.nc_prepend(redirect, code), Con{adapter, deps}, shape}, u => H.NF_Worker{name, params, code, deps, shape}) : H.NF_Worker}

def redirect_worker_choice(hit, name, params, code, deps, shape, redirect, adapter):
  match hit:
    case False{}: {==}
    case True{}: {==}

# Support: complete list construction respects both proven full-value equalities.
law redirect_list_cons:
  for +a: H.NF_Worker
  for +b: H.NF_Worker
  for +xs: List<&2, H.NF_Worker>
  for +ys: List<&2, H.NF_Worker>
  for head_equal: {a == b : H.NF_Worker}
  for tail_equal: {xs == ys : List<&2, H.NF_Worker>}
  {Con{a, xs} == Con{b, ys} : List<&2, H.NF_Worker>}

def redirect_list_cons(a, b, xs, ys, head_equal, tail_equal):
  %head_equal : {Con{a, xs} == Con{_, ys} : List<&2, H.NF_Worker>}
  %tail_equal : {Con{a, xs} == Con{a, _} : List<&2, H.NF_Worker>}
  {==}

# Public: the exact new function preserves the complete ordered worker list.
# All matching duplicates are still rewritten, and every nonmatching worker's
# full value is unchanged. The executable reference is the original function.
law redirect_workers_preserves:
  for workers: List<&2, H.NF_Worker>
  for +owner: String
  for +roots: List<&2, U32>
  {H.no_scalar_redirect_reference(workers, owner, roots) == H.no_scalar_redirect(workers, owner, roots) : List<&2, H.NF_Worker>}

def redirect_workers_preserves(workers, owner, roots):
  match workers:
    case Nil{}: {==}
    case Con{H.NF_Worker{+name, +params, +code, +deps, +shape}, +rest}:
      +redirect = "if (" ++ H.no_shared_roots(params, roots, 0) ++ ") { return " ++ H.nf_name(H.no_adapter_name(owner)) ++ "(e, seq, nf_out" ++ H.nf_arg_c(H.nf_segment_args(params)) ++ "); }\n"
      +adapter = H.no_adapter_name(owner)
      redirect_list_cons(
        H.NF_Worker{name, params, H.nt_choose(H.NC_Code, H.p88_string_eq(name, owner), u => H.nc_prepend(redirect, code), u => code), H.nt_choose(List<&2, String>, H.p88_string_eq(name, owner), u => Con{adapter, deps}, u => deps), shape},
        H.nt_choose(H.NF_Worker, H.p88_string_eq(name, owner), u => H.NF_Worker{name, params, H.nc_prepend(redirect, code), Con{adapter, deps}, shape}, u => H.NF_Worker{name, params, code, deps, shape}),
        H.no_scalar_redirect_reference(rest, owner, roots), H.no_scalar_redirect(rest, owner, roots),
        redirect_worker_choice(H.p88_string_eq(name, owner), name, params, code, deps, shape, redirect, adapter),
        redirect_workers_preserves(rest, owner, roots))

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
