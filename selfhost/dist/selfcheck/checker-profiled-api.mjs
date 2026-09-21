function word_to_u32(w) {
  let x = 0;
  for (let i = 0; w.$ === "WCon"; i++) {
    x |= Number(w.head) << i;
    w = w.tail;
  }
  return x >>> 0;
}

function u32_to_word(x) {
  let w = {$: "WNil"};
  for (let i = 31; i >= 0; i--) {
    w = {$: "WCon", head: ((x >>> i) & 1) === 1, tail: w};
  }
  return w;
}

function cmp_new(a, b) {
  return {$: a < b ? "LT"
    : a === b ? "EQ" : "GT"};
}

function nat_divmod(a, b) {
  return b === 0n ? {$: "Tuple", fst: 0n, snd: a}
    : {$: "Tuple", fst: a / b, snd: a % b};
}

function nat_chk(n) {
  if (n > 281474976710655n) {
    throw "bend: a Nat past the largest immediate 2^48-1";
  }
  return n;
}

function f32_show(x) {
  if (x !== x) {
    return "nan";
  }
  if (!Number.isFinite(x) || Object.is(x, -0)) {
    return x < 0 ? "-inf"
      : x === 0 ? "-0" : "inf";
  }
  let s = "x";
  for (let p = 1; p <= 9 && Math.fround(Number(s)) !== x; p += 1) {
    s = String(Number(x.toExponential(p - 1)));
  }
  return s;
}

function f32_bits(x) {
  return new Uint32Array(new Float32Array([x]).buffer)[0];
}

function f32_from_bits(u) {
  return new Float32Array(new Uint32Array([u]).buffer)[0];
}

function f32_read(s) {
  const re = /^\s*[+-]?((\d+\.?\d*|\.\d+)(e[+-]?\d+)?|inf(inity)?|nan)$/i;
  const v = Number(s.replace(/inf\w*/i, "Infinity"));
  return re.test(s) ? {$: "Some", value: Math.fround(v)} : {$: "None"};
}

function char_new(code) {
  if (code > 0x10FFFF || (code >= 0xD800 && code <= 0xDFFF)) {
    throw "bend: " + code + " is not a Unicode scalar value";
  }
  return String.fromCodePoint(code);
}

// Array
// =====

function array_new(d, v) {
  if (d > 31n) {
    throw "bend: an array past the deepest block class 31";
  }
  return Array(2 ** Number(d)).fill(v);
}

// An unbalanced tree fails, as in C.
function array_node(a, b) {
  if (a.length !== b.length) {
    throw "bend: runtime fail-stop";
  }
  return a.concat(b);
}

function array_swap(a, i, v) {
  const at = i % a.length;
  const old = a[at];
  a[at] = v;
  return {$: "Tuple", fst: a, snd: old};
}

// Run
// ===

function run_jump(f, x) {
  return {$: "$JMP", f: f, x: x};
}

function run_tail(f, x) {
  return {$: "$JMP", f: f.j?.f === f ? f.j : f, x: [x]};
}

function run_clo(j) {
  const f = (x) => run_loop(j(x));
  f.j = j;
  j.f = f;
  return f;
}

function run_loop(r) {
  while (r !== null && typeof r === "object" && r.$ === "$JMP") {
    r = r.f(...r.x);
  }
  return r;
}

function run_lib(f, n) {
  return (...a) => a.length < n ? run_lib((...b) => f(...a, ...b), n - a.length)
    : run_loop(f(...a));
}
// Program
// =======

function $check_book$(book_0) {
  return run_jump($check_events$, [book_0, run_loop($book_cached$({$: "Nil"}, run_loop($norm_max_book$(book_0))))]);
}

function $check$(e_0, ctx_0, t_0, dem_0, ty_0) {
  return run_jump($check_node$, [e_0, ctx_0, run_loop($core_beta$(t_0)), dem_0, ty_0]);
}

function $infer$(e_0, ctx_0, t_0, dem_0, sp_0) {
  return run_jump($infer_node$, [e_0, ctx_0, run_loop($core_beta$(t_0)), dem_0, sp_0]);
}

function $annotate_book$(book_0) {
  return run_jump($ka_defs$, [run_loop($book_cached$(book_0, run_loop($norm_max_book$(book_0)))), book_0]);
}

function $annotate_except$(book_0, stops_0) {
  return run_jump($ka_defs_except$, [run_loop($book_cached$(book_0, run_loop($norm_max_book$(book_0)))), book_0, stops_0]);
}

function $annotate_selected$(book_0, selected_0, stops_0) {
  return run_jump($ka_defs_except$, [run_loop($book_cached$(book_0, run_loop($norm_max_book$(book_0)))), selected_0, stops_0]);
}

function $lookup$(book_0, name_0) {
  if (book_0.$ === "Nil") {
    return run_jump($missing$, []);
  } else {
    const d_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(d_0)), "BookCache")), run_clo((x_0) => {
    return run_jump($index_lookup$, [d_0, name_0]);
}), run_clo((x_1) => {
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dn$(d_0)), name_0)), run_clo((x_2) => {
    return d_0;
}), run_clo((x_3) => {
    return run_jump($lookup$, [rest_0, name_0]);
})]);
})]);
  }
}

function $book_cached$(book_0, bound_0) {
  return {$: "Con", ["head"]: {$: "KDef", ["name"]: "$kernel.cache", ["kind"]: "BookCache", ["arity"]: bound_0, ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Con", ["head"]: run_loop($index_build$(book_0)), ["tail"]: {$: "Nil"}}, ["native"]: true, ["unsafe"]: false}, ["tail"]: book_0};
}

function $book_put$(book_0, d_0) {
  if (book_0.$ === "Nil") {
    return {$: "Con", ["head"]: d_0, ["tail"]: {$: "Nil"}};
  } else {
    const h_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(h_0)), "BookCache")), run_clo((x_0) => {
    return {$: "Con", ["head"]: {$: "KDef", ["name"]: run_loop($dn$(h_0)), ["kind"]: run_loop($dk$(h_0)), ["arity"]: run_loop($da$(h_0)), ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Con", ["head"]: run_loop($index_set$(run_loop($index_first$(run_loop($dc$(h_0)))), d_0, run_loop($index_hash$(run_loop($dn$(d_0)), 2166136261)), 32)), ["tail"]: {$: "Nil"}}, ["native"]: true, ["unsafe"]: false}, ["tail"]: {$: "Con", ["head"]: d_0, ["tail"]: run_loop($index_remove$(rest_0, run_loop($dn$(d_0))))}};
}), run_clo((x_1) => {
    return {$: "Con", ["head"]: d_0, ["tail"]: run_loop($index_remove$({$: "Con", ["head"]: h_0, ["tail"]: rest_0}, run_loop($dn$(d_0))))};
})]);
  }
}

function $exact_prefix$(book_0, prefix_0) {
  if (prefix_0.$ === "Nil") {
    return true;
  } else {
    const h_0 = prefix_0["head"];
    const rest_0 = prefix_0["tail"];
    return run_jump($exact_prefix_head$, [book_0, h_0, rest_0]);
  }
}

function $check_from_exact_prefix$(book_0, validated_0) {
  return run_jump($kc$, [run_loop($exact_prefix$(book_0, validated_0)), run_clo((x_0) => {
  return run_jump($check_prefix_seed$, [book_0, validated_0, run_loop($book_cached$({$: "Nil"}, run_loop($norm_max_book$(book_0))))]);
}), run_clo((x_1) => {
  return run_jump($check_book$, [book_0]);
})]);
}

function $check_events$(todo_0, done_0) {
  if (todo_0.$ === "Nil") {
    return run_jump($check_open$, [done_0]);
  } else {
    const d_0 = todo_0["head"];
    const rest_0 = todo_0["tail"];
    return run_jump($check_event_guard$, [rest_0, done_0, d_0, run_loop($event_error$(done_0, d_0, run_loop($lookup$(done_0, run_loop($dn$(d_0))))))]);
  }
}

function $norm_max_book$(book_0) {
  if (book_0.$ === "Nil") {
    return 0;
  } else {
    const d_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    return run_jump($norm_max$, [run_loop($norm_max$(run_loop($norm_max_term$(run_loop($dt$(d_0)))), run_loop($norm_max_term$(run_loop($dv$(d_0)))))), run_loop($norm_max$(run_loop($norm_max_book$(run_loop($dc$(d_0)))), run_loop($norm_max_book$(rest_0))))]);
  }
}

function $check_node$(e_0, ctx_0, t_0, dem_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Lam")), run_clo((x_0) => {
  return run_jump($check_lam$, [e_0, ctx_0, t_0, dem_0, run_loop($wnf$(run_loop($cb$(e_0)), ty_0))]);
}), run_clo((x_1) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ctr")), run_clo((x_2) => {
  return run_jump($check_ctr$, [e_0, ctx_0, t_0, dem_0, run_loop($wnf$(run_loop($cb$(e_0)), ty_0))]);
}), run_clo((x_3) => {
  const x_4 = run_loop($String$eq$(run_loop($tg$(t_0)), "Mat"));
  const x_5 = run_loop($String$eq$(run_loop($tg$(t_0)), "Efq"));
  return run_jump($kc$, [(x_4 || x_5), run_clo((x_6) => {
  return run_jump($check_mat$, [e_0, ctx_0, t_0, dem_0, run_loop($wnf$(run_loop($cb$(e_0)), ty_0))]);
}), run_clo((x_7) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Rfl")), run_clo((x_8) => {
  return run_jump($check_rfl$, [e_0, t_0, run_loop($wnf$(run_loop($cb$(e_0)), ty_0))]);
}), run_clo((x_9) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Hol")), run_clo((x_10) => {
  return run_jump($bad$, ["unresolved hole"]);
}), run_clo((x_11) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Let")), run_clo((x_12) => {
  return run_jump($check_let$, [e_0, ctx_0, ctx_0, run_loop($ks$(t_0)), dem_0, ty_0, {$: "Nil"}, {$: "Nil"}]);
}), run_clo((x_13) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Rwt")), run_clo((x_14) => {
  return run_jump($check_rwt$, [e_0, ctx_0, t_0, dem_0, ty_0, run_loop($infer$(e_0, ctx_0, run_loop($kid$(t_0, 0)), dem_0, {$: "Nil"}))]);
}), run_clo((x_15) => {
  return run_jump($check_fits$, [e_0, run_loop($infer$(e_0, ctx_0, t_0, dem_0, {$: "Nil"})), ty_0]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
}

function $core_beta$(t_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_0) => {
  return run_jump($core_apply$, [run_loop($core_beta$(run_loop($kid$(t_0, 0)))), run_loop($kid$(t_0, 1))]);
}), run_clo((x_1) => {
  return t_0;
})]);
}

function $infer_node$(e_0, ctx_0, t_0, dem_0, sp_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Var")), run_clo((x_0) => {
  return run_jump($infer_var$, [ctx_0, t_0, dem_0]);
}), run_clo((x_1) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ref")), run_clo((x_2) => {
  return run_jump($infer_ref$, [e_0, t_0, dem_0, sp_0, run_loop($lookup$(run_loop($cb$(e_0)), run_loop($nm$(t_0))))]);
}), run_clo((x_3) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Typ")), run_clo((x_4) => {
  return run_jump($checked$, [run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 0)), 0, run_loop($atom$("Qnt")))), t_0, run_loop($typ$(1))]);
}), run_clo((x_5) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Qnt")), run_clo((x_6) => {
  return run_jump($ok$, [t_0, run_loop($typ$(1)), {$: "Nil"}]);
}), run_clo((x_7) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Qua")), run_clo((x_8) => {
  return run_jump($ok$, [t_0, run_loop($atom$("Qnt")), {$: "Nil"}]);
}), run_clo((x_9) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Min")), run_clo((x_10) => {
  return run_jump($both$, [run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 0)), dem_0, run_loop($atom$("Qnt")))), run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), dem_0, run_loop($atom$("Qnt")))), t_0, run_loop($atom$("Qnt")), false]);
}), run_clo((x_11) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "All")), run_clo((x_12) => {
  return run_jump($both$, [run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 0)), 0, run_loop($typ$(run_loop($kindq$(e_0, run_loop($qt$(t_0)))))))), run_loop($check$(e_0, run_loop($ctx_bind$(ctx_0, run_loop($ix$(t_0)), run_loop($qt$(t_0)), run_loop($nm$(t_0)), run_loop($kid$(t_0, 0)))), run_loop($kid$(t_0, 1)), 0, run_loop($typ$(1)))), t_0, run_loop($typ$(1)), false]);
}), run_clo((x_13) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_14) => {
  return run_jump($infer_app$, [e_0, ctx_0, t_0, dem_0, run_loop($infer$(e_0, ctx_0, run_loop($kid$(t_0, 0)), dem_0, {$: "Con", ["head"]: run_loop($kid$(t_0, 1)), ["tail"]: sp_0}))]);
}), run_clo((x_15) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "ADT")), run_clo((x_16) => {
  return run_jump($infer_adt$, [e_0, ctx_0, t_0, dem_0, run_loop($lookup$(run_loop($cb$(e_0)), run_loop($nm$(t_0))))]);
}), run_clo((x_17) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Eql")), run_clo((x_18) => {
  return run_jump($both$, [run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 2)), 0, run_loop($typ$(1)))), run_loop($both$(run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 0)), 0, run_loop($kid$(t_0, 2)))), run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), 0, run_loop($kid$(t_0, 2)))), t_0, run_loop($typ$(2)), false)), t_0, run_loop($typ$(2)), false]);
}), run_clo((x_19) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ann")), run_clo((x_20) => {
  return run_jump($both$, [run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), 0, run_loop($typ$(1)))), run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 0)), dem_0, run_loop($kid$(t_0, 1)))), run_loop($kid$(t_0, 0)), run_loop($kid$(t_0, 1)), false]);
}), run_clo((x_21) => {
  return run_jump($bad$, ["cannot infer: annotation required"]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
}

function $ka_defs$(book_0, ds_0) {
  if (ds_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return {$: "Con", ["head"]: run_loop($ka_def$(book_0, d_0)), ["tail"]: run_loop($ka_defs$(book_0, rest_0))};
  }
}

function $ka_defs_except$(book_0, ds_0, stops_0) {
  if (ds_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return {$: "Con", ["head"]: run_loop($kc$(run_loop($has_name$(stops_0, run_loop($dn$(d_0)))), run_clo((x_0) => {
    return d_0;
}), run_clo((x_1) => {
    return run_jump($ka_def$, [book_0, d_0]);
}))), ["tail"]: run_loop($ka_defs_except$(book_0, rest_0, stops_0))};
  }
}

function $missing$() {
  return {$: "KDef", ["name"]: "", ["kind"]: "Absent", ["arity"]: 0, ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: false, ["unsafe"]: false};
}

function $kc$(b_0, yes_0, no_0) {
  if (b_0) {
    return run_tail(yes_0, {$: "Unit"});
  } else {
    return run_tail(no_0, {$: "Unit"});
  }
}

function $String$eq$(a_0, b_0) {
  return run_jump($String$eq$fin$, [run_loop($String$cmp$(a_0, b_0))]);
}

function $dk$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return kind_0;
}

function $index_lookup$(cache_0, name_0) {
  return run_jump($index_find$, [run_loop($index_first$(run_loop($dc$(cache_0)))), name_0, run_loop($index_hash$(name_0, 2166136261)), 32]);
}

function $dn$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return name_0;
}

function $atom$(tag_0) {
  return run_jump($kt$, [tag_0, "", 0, 0, {$: "Nil"}]);
}

function $index_build$(book_0) {
  if (book_0.$ === "Nil") {
    return run_jump($missing$, []);
  } else {
    const h_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    return run_jump($index_set$, [run_loop($index_build$(rest_0)), h_0, run_loop($index_hash$(run_loop($dn$(h_0)), 2166136261)), 32]);
  }
}

function $da$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return arity_0;
}

function $index_set$(tree_0, d_0, hash_0, bits_0) {
  return run_jump($kc$, [(bits_0 === 0), run_clo((x_0) => {
  return {$: "KDef", ["name"]: "", ["kind"]: "IndexLeaf", ["arity"]: 0, ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Con", ["head"]: d_0, ["tail"]: run_loop($index_remove$(run_loop($dc$(tree_0)), run_loop($dn$(d_0))))}, ["native"]: true, ["unsafe"]: false};
}), run_clo((x_1) => {
  const x_2 = ((hash_0 & 1) >>> 0);
  return run_jump($index_set_node$, [tree_0, d_0, hash_0, bits_0, run_loop($Bool$not$((x_2 === 0)))]);
})]);
}

function $index_first$(ds_0) {
  if (ds_0.$ === "Nil") {
    return run_jump($missing$, []);
  } else {
    const h_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return h_0;
  }
}

function $dc$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return ctors_0;
}

function $index_hash$(name_0, acc_0) {
  if (name_0 === "") {
    return acc_0;
  } else {
    const h_0 = (name_0.codePointAt(0) > 0xFFFF ? name_0.slice(0, 2) : name_0[0]);
    const rest_0 = (name_0.codePointAt(0) > 0xFFFF ? name_0.slice(2) : name_0.slice(1));
    const x_0 = run_loop($Char$to_u32$(h_0));
    const x_1 = ((acc_0 ^ x_0) >>> 0);
    return run_jump($index_hash$, [rest_0, (Math.imul(x_1, 16777619) >>> 0)]);
  }
}

function $index_remove$(ds_0, name_0) {
  if (ds_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dn$(h_0)), name_0)), run_clo((x_0) => {
    return run_jump($index_remove$, [rest_0, name_0]);
}), run_clo((x_1) => {
    return {$: "Con", ["head"]: h_0, ["tail"]: run_loop($index_remove$(rest_0, name_0))};
})]);
  }
}

function $exact_prefix_head$(book_0, h_0, rest_0) {
  if (book_0.$ === "Nil") {
    return false;
  } else {
    const x_0 = book_0["head"];
    const xs_0 = book_0["tail"];
    return run_jump($Bool$and$, [run_loop($exact_def$(x_0, h_0)), run_loop($exact_prefix$(xs_0, rest_0))]);
  }
}

function $check_prefix_seed$(book_0, validated_0, done_0) {
  if (validated_0.$ === "Nil") {
    return run_jump($check_events$, [book_0, done_0]);
  } else {
    const h_0 = validated_0["head"];
    const rest_0 = validated_0["tail"];
    return run_jump($check_prefix_step$, [book_0, h_0, rest_0, done_0]);
  }
}

function $check_open$(book_0) {
  return run_jump($check_open_message$, [run_loop($count_open$(book_0))]);
}

function $check_event_guard$(rest_0, done_0, d_0, err_0) {
  return run_jump($kc$, [run_loop($String$eq$(err_0, "")), run_clo((x_0) => {
  return run_jump($check_event_done$, [rest_0, done_0, d_0, run_loop($check_definition$(run_loop($book_put$(done_0, run_loop($declared$(d_0)))), d_0))]);
}), run_clo((x_1) => {
  const x_2 = run_loop($dn$(d_0));
  const x_3 = (": " + err_0);
  return (x_2 + x_3);
})]);
}

function $event_error$(done_0, d_0, old_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(old_0)), "Absent")), run_clo((x_0) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(d_0)), "ADT")), run_clo((x_1) => {
  return run_jump($constructor_names$, [done_0, run_loop($dc$(d_0)), {$: "Nil"}]);
}), run_clo((x_2) => {
  return "";
})]);
}), run_clo((x_3) => {
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($String$eq$(run_loop($dk$(old_0)), "Def")), run_loop($String$eq$(run_loop($dk$(d_0)), "Def")))), run_loop($String$eq$(run_loop($tg$(run_loop($dv$(old_0)))), "Absent")))), run_loop($Bool$not$(run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Absent")))))), run_clo((x_4) => {
  const x_5 = run_loop($dx$(old_0));
  const x_6 = run_loop($dx$(d_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($compare$(done_0, run_loop($dt$(old_0)), run_loop($dt$(d_0)), false)), (x_5 === x_6))), run_clo((x_7) => {
  return "";
}), run_clo((x_8) => {
  return "definition does not match prior law signature";
})]);
}), run_clo((x_9) => {
  return "duplicate declaration";
})]);
})]);
}

function $norm_max$(a_0, b_0) {
  return run_jump($kc$, [(a_0 <= b_0), run_clo((x_0) => {
  return b_0;
}), run_clo((x_1) => {
  return a_0;
})]);
}

function $norm_max_term$(t_0) {
  return run_jump($norm_max$, [run_loop($ix$(t_0)), run_loop($norm_max_terms$(run_loop($ks$(t_0))))]);
}

function $dt$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return typ_0;
}

function $dv$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return value_0;
}

function $tg$(t_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const id_0 = t_0["id"];
  const quant_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return tag_0;
}

function $check_lam$(e_0, ctx_0, t_0, dem_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
  const x_1 = run_loop($qt$(t_0));
  const x_2 = run_loop($qt$(ty_0));
  return run_jump($check_lam_q$, [e_0, ctx_0, t_0, dem_0, ty_0, run_loop($kc$(run_loop($Bool$and$((x_1 === 2), (x_2 === 1))), run_clo((x_3) => {
  return 2;
}), run_clo((x_4) => {
  return run_jump($qt$, [ty_0]);
})))]);
}), run_clo((x_5) => {
  return run_jump($bad$, ["lambda requires a function type"]);
})]);
}

function $wnf$(book_0, t_0) {
  return run_jump($norm_eval$, [book_0, t_0, {$: "Nil"}, 0, run_loop($atom$("Absent"))]);
}

function $cb$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return book_0;
}

function $check_ctr$(e_0, ctx_0, t_0, dem_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "ADT")), run_clo((x_0) => {
  return run_jump($check_ctr_found$, [e_0, ctx_0, t_0, dem_0, ty_0, run_loop($lookup$(run_loop($dc$(run_loop($lookup$(run_loop($cb$(e_0)), run_loop($nm$(ty_0)))))), run_loop($nm$(t_0))))]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["constructor requires a datatype goal"]);
})]);
}

function $check_mat$(e_0, ctx_0, t_0, dem_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
  const x_1 = run_loop($qt$(ty_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($Bool$not$((dem_0 === 0))), (x_1 === 0))), run_clo((x_2) => {
  return run_jump($bad$, ["erased scrutinee in live match"]);
}), run_clo((x_3) => {
  return run_jump($check_mat_type$, [e_0, ctx_0, t_0, dem_0, ty_0, run_loop($wnf$(run_loop($cb$(e_0)), run_loop($kid$(ty_0, 0))))]);
})]);
}), run_clo((x_4) => {
  return run_jump($bad$, ["matcher requires a function type"]);
})]);
}

function $check_rfl$(e_0, t_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "Eql")), run_clo((x_0) => {
  return run_jump($kc$, [run_loop($compare$(run_loop($cb$(e_0)), run_loop($kid$(ty_0, 0)), run_loop($kid$(ty_0, 1)), false)), run_clo((x_1) => {
  return run_jump($ok$, [t_0, ty_0, {$: "Nil"}]);
}), run_clo((x_2) => {
  return run_jump($bad$, ["reflexivity endpoints differ"]);
})]);
}), run_clo((x_3) => {
  return run_jump($bad$, ["reflexivity requires equality goal"]);
})]);
}

function $bad$(msg_0) {
  return {$: "KChecked", ["term"]: run_loop($atom$("Error")), ["typ"]: run_loop($atom$("Error")), ["uses"]: {$: "Nil"}, ["error"]: msg_0};
}

function $check_let$(e_0, outer_0, ctx_0, xs_0, dem_0, ty_0, bindings_0, us_0) {
  if (xs_0.$ === "Nil") {
    return run_jump($bad$, ["let has no body"]);
  } else {
    const h_0 = xs_0["head"];
    const rest_0 = xs_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(h_0)), "Bind")), run_clo((x_0) => {
    return run_jump($check_let_value$, [e_0, outer_0, ctx_0, h_0, rest_0, dem_0, ty_0, bindings_0, us_0, run_loop($infer$(e_0, outer_0, run_loop($kid$(h_0, 0)), run_loop($qdem$(run_loop($qt$(h_0)), dem_0)), {$: "Nil"}))]);
}), run_clo((x_1) => {
    return run_jump($check_let_done$, [run_loop($check$(e_0, ctx_0, run_loop($let_cells$(h_0, bindings_0)), dem_0, ty_0)), bindings_0, us_0]);
})]);
  }
}

function $ks$(t_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const id_0 = t_0["id"];
  const quant_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return kids_0;
}

function $check_rwt$(e_0, ctx_0, t_0, dem_0, ty_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($check_rwt_type$, [e_0, ctx_0, t_0, dem_0, ty_0, r_0, run_loop($wnf$(run_loop($cb$(e_0)), run_loop($cy$(r_0))))]);
}), run_clo((x_1) => {
  return r_0;
})]);
}

function $kid$(t_0, n_0) {
  return run_jump($terms_at$, [run_loop($ks$(t_0)), n_0]);
}

function $check_fits$(e_0, r_0, ty_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($kc$, [run_loop($compare$(run_loop($cb$(e_0)), run_loop($cy$(r_0)), ty_0, true)), run_clo((x_1) => {
  return run_jump($checked$, [r_0, run_loop($ct$(r_0)), ty_0]);
}), run_clo((x_2) => {
  return run_jump($bad$, ["type mismatch"]);
})]);
}), run_clo((x_3) => {
  return r_0;
})]);
}

function $core_apply$(f_0, x_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(f_0)), "Lam")), run_clo((x_1) => {
  return run_jump($subst$, [run_loop($kid$(f_0, 0)), run_loop($ix$(f_0)), x_0]);
}), run_clo((x_2) => {
  return run_jump($app$, [f_0, x_0]);
})]);
}

function $infer_var$(ctx_0, t_0, dem_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($ctx_get$(ctx_0, run_loop($ix$(t_0)))))), "Absent")), run_clo((x_0) => {
  return run_jump($bad$, ["unbound variable"]);
}), run_clo((x_1) => {
  return run_jump($ok$, [t_0, run_loop($kid$(run_loop($ctx_get$(ctx_0, run_loop($ix$(t_0)))), 0)), {$: "Con", ["head"]: run_loop($kt$("Use", "", run_loop($ix$(t_0)), dem_0, {$: "Nil"})), ["tail"]: {$: "Nil"}}]);
})]);
}

function $infer_ref$(e_0, t_0, dem_0, sp_0, d_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(d_0)), "Absent")), run_clo((x_0) => {
  return run_jump($bad$, ["undefined name"]);
}), run_clo((x_1) => {
  const x_2 = run_loop($da$(d_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($dk$(d_0)), "ADT")), (x_2 > 0))), run_clo((x_3) => {
  return run_jump($bad$, ["a family requires angle-bracket parameters"]);
}), run_clo((x_4) => {
  return run_jump($kc$, [(dem_0 === 0), run_clo((x_5) => {
  return run_jump($ok$, [t_0, run_loop($dt$(d_0)), {$: "Nil"}]);
}), run_clo((x_6) => {
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($String$eq$(run_loop($nm$(t_0)), run_loop($cn$(e_0)))), run_loop($Bool$not$(run_loop($cu$(e_0)))))), run_loop($Bool$not$(run_loop($descend_spine$(run_loop($cq$(e_0)), sp_0, run_loop($unargs$(run_loop($cl$(e_0)), {$: "Nil"})))))))), run_clo((x_7) => {
  return run_jump($bad$, ["nondecreasing self-call"]);
}), run_clo((x_8) => {
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Absent")), run_loop($Bool$not$(run_loop($db$(d_0)))))), run_loop($Bool$not$(run_loop($cu$(e_0)))))), run_loop($Bool$not$(run_loop($String$eq$(run_loop($nm$(t_0)), run_loop($cn$(e_0)))))))), run_clo((x_9) => {
  return run_jump($bad$, ["live use of an unfilled law"]);
}), run_clo((x_10) => {
  return run_jump($infer_template$, [e_0, t_0, dem_0, sp_0, d_0]);
})]);
})]);
})]);
})]);
})]);
}

function $nm$(t_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const id_0 = t_0["id"];
  const quant_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return name_0;
}

function $checked$(r_0, t_0, ty_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($ok$, [t_0, ty_0, run_loop($cs$(r_0))]);
}), run_clo((x_1) => {
  return r_0;
})]);
}

function $typ$(q_0) {
  return run_jump($kt$, ["Typ", "", 0, 0, {$: "Con", ["head"]: run_loop($qua$(q_0)), ["tail"]: {$: "Nil"}}]);
}

function $ok$(t_0, ty_0, us_0) {
  return {$: "KChecked", ["term"]: t_0, ["typ"]: ty_0, ["uses"]: us_0, ["error"]: ""};
}

function $both$(a_0, b_0, t_0, ty_0, join_0) {
  return run_jump($kc$, [run_loop($good$(a_0)), run_clo((x_0) => {
  return run_jump($kc$, [run_loop($good$(b_0)), run_clo((x_1) => {
  return run_jump($ok$, [t_0, ty_0, run_loop($uses_merge$(run_loop($cs$(a_0)), run_loop($cs$(b_0)), join_0))]);
}), run_clo((x_2) => {
  return b_0;
})]);
}), run_clo((x_3) => {
  return a_0;
})]);
}

function $kindq$(e_0, q_0) {
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($cu$(e_0)), (q_0 === 2))), run_clo((x_0) => {
  return 1;
}), run_clo((x_1) => {
  return q_0;
})]);
}

function $qt$(t_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const id_0 = t_0["id"];
  const quant_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return quant_0;
}

function $ctx_bind$(ctx_0, id_0, q_0, name_0, ty_0) {
  return {$: "Con", ["head"]: run_loop($kt$("Bind", name_0, id_0, q_0, {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}})), ["tail"]: ctx_0};
}

function $ix$(t_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const id_0 = t_0["id"];
  const quant_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return id_0;
}

function $infer_app$(e_0, ctx_0, t_0, dem_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($infer_app_type$, [e_0, ctx_0, t_0, dem_0, r_0, run_loop($wnf$(run_loop($cb$(e_0)), run_loop($cy$(r_0))))]);
}), run_clo((x_1) => {
  return r_0;
})]);
}

function $infer_adt$(e_0, ctx_0, t_0, dem_0, d_0) {
  const x_0 = run_loop($terms_len$(run_loop($ks$(t_0))));
  const x_1 = run_loop($da$(d_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($dk$(d_0)), "ADT")), (x_0 === x_1))), run_clo((x_2) => {
  return run_jump($infer_adt_done$, [t_0, run_loop($tele_check$(e_0, ctx_0, run_loop($dt$(d_0)), run_loop($ks$(t_0)), dem_0))]);
}), run_clo((x_3) => {
  return run_jump($bad$, ["unknown family or wrong parameter count"]);
})]);
}

function $ka_def$(book_0, d_0) {
  const x_0 = run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Absent"));
  const x_1 = run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Foreign"));
  const x_2 = run_loop($dx$(d_0));
  const x_3 = (x_0 || x_1);
  const x_4 = (x_2 > 0);
  return {$: "KDef", ["name"]: run_loop($dn$(d_0)), ["kind"]: run_loop($dk$(d_0)), ["arity"]: run_loop($da$(d_0)), ["templates"]: run_loop($dx$(d_0)), ["typ"]: run_loop($dt$(d_0)), ["value"]: run_loop($kc$((x_3 || x_4), run_clo((x_5) => {
  return run_jump($dv$, [d_0]);
}), run_clo((x_6) => {
  return run_jump($annotate$, [{$: "KEnv", ["book"]: book_0, ["name"]: run_loop($dn$(d_0)), ["lhs"]: run_loop($ref$(run_loop($dn$(d_0)))), ["pending"]: 0, ["quantities"]: {$: "Nil"}, ["unsafe"]: run_loop($du$(d_0))}, {$: "Nil"}, run_loop($dv$(d_0)), run_loop($dt$(d_0))]);
}))), ["ctors"]: run_loop($dc$(d_0)), ["native"]: run_loop($db$(d_0)), ["unsafe"]: run_loop($du$(d_0))};
}

function $has_name$(ns_0, name_0) {
  if (ns_0.$ === "Nil") {
    return false;
  } else {
    const h_0 = ns_0["head"];
    const t_0 = ns_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(h_0, name_0)), run_clo((x_0) => {
    return true;
}), run_clo((x_1) => {
    return run_jump($has_name$, [t_0, name_0]);
})]);
  }
}

function $String$eq$fin$(r_0) {
  const _t_0 = r_0["fst"];
  const a2_0 = _t_0["fst"];
  const b2_0 = _t_0["snd"];
  const c_0 = r_0["snd"];
  return run_jump($Cmp$is_eq$, [c_0]);
}

function $String$cmp$(a_0, b_0) {
  if (a_0 === "") {
    if (b_0 === "") {
      return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: "", ["snd"]: ""}, ["snd"]: {$: "EQ"}};
    } else {
      const h_0 = (b_0.codePointAt(0) > 0xFFFF ? b_0.slice(0, 2) : b_0[0]);
      const t_0 = (b_0.codePointAt(0) > 0xFFFF ? b_0.slice(2) : b_0.slice(1));
      return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: "", ["snd"]: (h_0 + t_0)}, ["snd"]: {$: "LT"}};
    }
  } else {
    const h_1 = (a_0.codePointAt(0) > 0xFFFF ? a_0.slice(0, 2) : a_0[0]);
    const t_1 = (a_0.codePointAt(0) > 0xFFFF ? a_0.slice(2) : a_0.slice(1));
    if (b_0 === "") {
      return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: (h_1 + t_1), ["snd"]: ""}, ["snd"]: {$: "GT"}};
    } else {
      const h2_0 = (b_0.codePointAt(0) > 0xFFFF ? b_0.slice(0, 2) : b_0[0]);
      const t2_0 = (b_0.codePointAt(0) > 0xFFFF ? b_0.slice(2) : b_0.slice(1));
      return run_jump($String$cmp$fin$, [t_1, t2_0, run_loop($Char$cmp$(h_1, h2_0))]);
    }
  }
}

function $index_find$(tree_0, name_0, hash_0, bits_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(tree_0)), "Absent")), run_clo((x_0) => {
  return run_jump($missing$, []);
}), run_clo((x_1) => {
  return run_jump($kc$, [(bits_0 === 0), run_clo((x_2) => {
  return run_jump($index_bucket$, [run_loop($dc$(tree_0)), name_0]);
}), run_clo((x_3) => {
  const x_4 = ((hash_0 & 1) >>> 0);
  return run_jump($index_find$, [run_loop($index_child$(tree_0, run_loop($Bool$not$((x_4 === 0))))), name_0, ((hash_0 >>> 1) >>> 0), ((bits_0 - 1) >>> 0)]);
})]);
})]);
}

function $kt$(tag_0, name_0, id_0, quant_0, kids_0) {
  return {$: "KTerm", ["tag"]: tag_0, ["name"]: name_0, ["id"]: id_0, ["quant"]: quant_0, ["kids"]: kids_0, ["removed"]: {$: "Nil"}};
}

function $index_set_node$(tree_0, d_0, hash_0, bits_0, right_0) {
  return {$: "KDef", ["name"]: "", ["kind"]: "IndexNode", ["arity"]: 0, ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Con", ["head"]: run_loop($kc$(right_0, run_clo((x_0) => {
  return run_jump($index_child$, [tree_0, false]);
}), run_clo((x_1) => {
  return run_jump($index_set$, [run_loop($index_child$(tree_0, false)), d_0, ((hash_0 >>> 1) >>> 0), ((bits_0 - 1) >>> 0)]);
}))), ["tail"]: {$: "Con", ["head"]: run_loop($kc$(right_0, run_clo((x_2) => {
  return run_jump($index_set$, [run_loop($index_child$(tree_0, true)), d_0, ((hash_0 >>> 1) >>> 0), ((bits_0 - 1) >>> 0)]);
}), run_clo((x_3) => {
  return run_jump($index_child$, [tree_0, true]);
}))), ["tail"]: {$: "Nil"}}}, ["native"]: true, ["unsafe"]: false};
}

function $Bool$not$(b_0) {
  if (!b_0) {
    return true;
  } else {
    return false;
  }
}

function $Char$to_u32$(c_0) {
  const x_0 = c_0.codePointAt(0);
  return x_0;
}

function $Bool$and$(a_0, b_0) {
  if (!a_0) {
    return false;
  } else {
    return b_0;
  }
}

function $exact_def$(a_0, b_0) {
  const x_0 = run_loop($da$(a_0));
  const x_1 = run_loop($da$(b_0));
  const x_2 = run_loop($dx$(a_0));
  const x_3 = run_loop($dx$(b_0));
  const x_4 = run_loop($db$(a_0));
  const x_5 = run_loop($db$(b_0));
  const x_6 = run_loop($du$(a_0));
  const x_7 = run_loop($du$(b_0));
  return run_jump($Bool$and$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($String$eq$(run_loop($dn$(a_0)), run_loop($dn$(b_0)))), run_loop($String$eq$(run_loop($dk$(a_0)), run_loop($dk$(b_0)))))), (x_0 === x_1))), (x_2 === x_3))), run_loop($Bool$not$((x_4 !== x_5))))), run_loop($Bool$not$((x_6 !== x_7))))), run_loop($exact_term$(run_loop($dt$(a_0)), run_loop($dt$(b_0)))))), run_loop($exact_term$(run_loop($dv$(a_0)), run_loop($dv$(b_0)))))), run_loop($exact_defs$(run_loop($dc$(a_0)), run_loop($dc$(b_0))))]);
}

function $check_prefix_step$(book_0, h_0, rest_0, done_0) {
  if (book_0.$ === "Nil") {
    return "invalid validated prefix";
  } else {
    const x_0 = book_0["head"];
    const xs_0 = book_0["tail"];
    return run_jump($check_prefix_seed$, [xs_0, rest_0, run_loop($book_put$(done_0, h_0))]);
  }
}

function $check_open_message$(n_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  return "";
}), run_clo((x_1) => {
  const x_4 = run_loop($kc$((n_0 === 1), run_clo((x_2) => {
  return "";
}), run_clo((x_3) => {
  return "s";
})));
  const x_5 = (x_4 + " found.\nThe code is incomplete, and not a valid proof yet.");
  const x_6 = run_loop($U32$show$(n_0));
  const x_7 = (" TODO" + x_5);
  return (x_6 + x_7);
})]);
}

function $count_open$(book_0) {
  if (book_0.$ === "Nil") {
    return 0;
  } else {
    const d_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    const x_2 = run_loop($kc$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($String$eq$(run_loop($dk$(d_0)), "Def")), run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Absent")))), run_loop($Bool$not$(run_loop($db$(d_0)))))), run_clo((x_0) => {
    return 1;
}), run_clo((x_1) => {
    return 0;
})));
    const x_3 = run_loop($count_open$(rest_0));
    return ((x_2 + x_3) >>> 0);
  }
}

function $check_event_done$(rest_0, done_0, d_0, err_0) {
  return run_jump($kc$, [run_loop($String$eq$(err_0, "")), run_clo((x_0) => {
  return run_jump($check_events$, [rest_0, run_loop($book_put$(done_0, d_0))]);
}), run_clo((x_1) => {
  const x_2 = run_loop($dn$(d_0));
  const x_3 = (": " + err_0);
  return (x_2 + x_3);
})]);
}

function $check_definition$(book_0, d_0) {
process.stderr.write("CHECK "+d_0.name+"\n");
  return run_jump($check_definition_type$, [book_0, d_0, {$: "KEnv", ["book"]: book_0, ["name"]: run_loop($dn$(d_0)), ["lhs"]: run_loop($ref$(run_loop($dn$(d_0)))), ["pending"]: 0, ["quantities"]: {$: "Nil"}, ["unsafe"]: run_loop($du$(d_0))}, run_loop($check$({$: "KEnv", ["book"]: book_0, ["name"]: run_loop($dn$(d_0)), ["lhs"]: run_loop($ref$(run_loop($dn$(d_0)))), ["pending"]: 0, ["quantities"]: {$: "Nil"}, ["unsafe"]: run_loop($du$(d_0))}, {$: "Nil"}, run_loop($dt$(d_0)), 0, run_loop($typ$(1))))]);
}

function $declared$(d_0) {
  return {$: "KDef", ["name"]: run_loop($dn$(d_0)), ["kind"]: run_loop($dk$(d_0)), ["arity"]: run_loop($da$(d_0)), ["templates"]: run_loop($dx$(d_0)), ["typ"]: run_loop($dt$(d_0)), ["value"]: run_loop($atom$("Absent")), ["ctors"]: run_loop($dc$(d_0)), ["native"]: run_loop($db$(d_0)), ["unsafe"]: run_loop($du$(d_0))};
}

function $constructor_names$(done_0, ctrs_0, names_0) {
  if (ctrs_0.$ === "Nil") {
    return "";
  } else {
    const h_0 = ctrs_0["head"];
    const rest_0 = ctrs_0["tail"];
    const x_0 = run_loop($has_name$(names_0, run_loop($dn$(h_0))));
    const x_1 = run_loop($constructor_exists$(done_0, run_loop($dn$(h_0))));
    return run_jump($kc$, [(x_0 || x_1), run_clo((x_2) => {
    return "duplicate constructor name";
}), run_clo((x_3) => {
    return run_jump($constructor_names$, [done_0, rest_0, {$: "Con", ["head"]: run_loop($dn$(h_0)), ["tail"]: names_0}]);
})]);
  }
}

function $compare$(book_0, a_0, b_0, le_0) {
  const x_0 = run_loop($norm_max$(run_loop($norm_book_bound$(book_0)), run_loop($norm_max$(run_loop($norm_max_term$(a_0)), run_loop($norm_max_term$(b_0))))));
  return run_jump($norm_compare$, [book_0, a_0, b_0, le_0, ((1 + x_0) >>> 0)]);
}

function $dx$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return templates_0;
}

function $norm_max_terms$(ts_0) {
  if (ts_0.$ === "Nil") {
    return 0;
  } else {
    const h_0 = ts_0["head"];
    const t_0 = ts_0["tail"];
    return run_jump($norm_max$, [run_loop($norm_max_term$(h_0)), run_loop($norm_max_terms$(t_0))]);
  }
}

function $check_lam_q$(e_0, ctx_0, t_0, dem_0, ty_0, q_0) {
  return run_jump($check_lam_done$, [t_0, ty_0, q_0, run_loop($both$(run_loop($check$(e_0, ctx_0, run_loop($kid$(ty_0, 0)), 0, run_loop($typ$(run_loop($kindq$(e_0, q_0)))))), run_loop($check$(run_loop($lhs_step$(e_0, run_loop($var$(run_loop($nm$(t_0)), run_loop($ix$(t_0)))))), run_loop($ctx_bind$(ctx_0, run_loop($ix$(t_0)), q_0, run_loop($nm$(t_0)), run_loop($kid$(ty_0, 0)))), run_loop($kid$(t_0, 0)), dem_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), run_loop($var$(run_loop($nm$(t_0)), run_loop($ix$(t_0)))))))), t_0, ty_0, false))]);
}

function $norm_eval$(book_0, t_0, args_0, left_0, fallback_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Var")), run_clo((x_0) => {
  return run_jump($norm_var$, [book_0, t_0, run_loop($ks$(t_0)), args_0, left_0, fallback_0]);
}), run_clo((x_1) => {
  return run_jump($norm_eval_node$, [book_0, t_0, args_0, left_0, fallback_0]);
})]);
}

function $check_ctr_found$(e_0, ctx_0, t_0, dem_0, ty_0, ctr_0) {
  const x_0 = run_loop($da$(ctr_0));
  const x_1 = run_loop($terms_len$(run_loop($ks$(t_0))));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$not$(run_loop($String$eq$(run_loop($dk$(ctr_0)), "Absent")))), run_loop($Bool$not$(run_loop($has_name$(run_loop($rm$(ty_0)), run_loop($nm$(t_0)))))))), (x_0 === x_1))), run_clo((x_2) => {
  return run_jump($checked$, [run_loop($tele_check$(e_0, ctx_0, run_loop($tele_fill$(run_loop($cb$(e_0)), run_loop($dt$(ctr_0)), run_loop($ks$(ty_0)))), run_loop($ks$(t_0)), dem_0)), t_0, ty_0]);
}), run_clo((x_3) => {
  return run_jump($bad$, ["constructor does not belong to goal or field count differs"]);
})]);
}

function $check_mat_type$(e_0, ctx_0, t_0, dem_0, ty_0, a_0) {
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(a_0)), "ADT")), run_loop($String$eq$(run_loop($dk$(run_loop($lookup$(run_loop($cb$(e_0)), run_loop($nm$(a_0)))))), "ADT")))), run_clo((x_0) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Efq")), run_clo((x_1) => {
  const x_2 = run_loop($dead_type$(run_loop($cb$(e_0)), a_0));
  const x_3 = run_loop($ctx_dead$(run_loop($cb$(e_0)), ctx_0));
  return run_jump($kc$, [(x_2 || x_3), run_clo((x_4) => {
  return run_jump($ok$, [t_0, ty_0, {$: "Nil"}]);
}), run_clo((x_5) => {
  return run_jump($bad$, ["nonexhaustive match"]);
})]);
}), run_clo((x_6) => {
  return run_jump($check_mat_ctr$, [e_0, ctx_0, t_0, dem_0, ty_0, a_0, run_loop($lookup$(run_loop($remaining$(run_loop($dc$(run_loop($lookup$(run_loop($cb$(e_0)), run_loop($nm$(a_0)))))), run_loop($rm$(a_0)))), run_loop($nm$(t_0))))]);
})]);
}), run_clo((x_7) => {
  return run_jump($bad$, ["match scrutinee requires a datatype"]);
})]);
}

function $check_let_value$(e_0, outer_0, ctx_0, h_0, rest_0, dem_0, ty_0, bindings_0, us_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($check_let_kind$, [e_0, outer_0, ctx_0, h_0, rest_0, dem_0, ty_0, bindings_0, us_0, r_0, run_loop($check$(e_0, outer_0, run_loop($cy$(r_0)), 0, run_loop($typ$(run_loop($kindq$(e_0, run_loop($qt$(h_0))))))))]);
}), run_clo((x_1) => {
  return r_0;
})]);
}

function $qdem$(q_0, d_0) {
  return run_jump($kc$, [(q_0 === 0), run_clo((x_0) => {
  return 0;
}), run_clo((x_1) => {
  return d_0;
})]);
}

function $check_let_done$(r_0, bs_0, us_0) {
  if (bs_0.$ === "Nil") {
    return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
    return run_jump($ok$, [run_loop($ct$(r_0)), run_loop($cy$(r_0)), run_loop($uses_merge$(us_0, run_loop($cs$(r_0)), false))]);
}), run_clo((x_1) => {
    return r_0;
})]);
  } else {
    const h_0 = bs_0["head"];
    const t_0 = bs_0["tail"];
    const x_2 = run_loop($uses_get$(run_loop($cs$(r_0)), run_loop($ix$(h_0))));
    const x_3 = run_loop($qt$(h_0));
    return run_jump($kc$, [(x_2 > x_3), run_clo((x_4) => {
    return run_jump($bad$, ["let binder consumed more than allowed"]);
}), run_clo((x_5) => {
    return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_6) => {
    return run_jump($check_let_done$, [run_loop($ok$(run_loop($ct$(r_0)), run_loop($cy$(r_0)), run_loop($uses_del$(run_loop($cs$(r_0)), run_loop($ix$(h_0)))))), t_0, us_0]);
}), run_clo((x_7) => {
    return r_0;
})]);
})]);
  }
}

function $let_cells$(body_0, bs_0) {
  if (bs_0.$ === "Nil") {
    return body_0;
  } else {
    const h_0 = bs_0["head"];
    const t_0 = bs_0["tail"];
    return run_jump($let_cells$, [run_loop($subst$(body_0, run_loop($ix$(h_0)), run_loop($kt$("Var", run_loop($nm$(h_0)), run_loop($ix$(h_0)), 0, {$: "Con", ["head"]: run_loop($kid$(h_0, 0)), ["tail"]: {$: "Nil"}})))), t_0]);
  }
}

function $good$(r_0) {
  return run_jump($String$eq$, [run_loop($ce$(r_0)), ""]);
}

function $check_rwt_type$(e_0, ctx_0, t_0, dem_0, ty_0, r_0, eq_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(eq_0)), "Eql")), run_clo((x_0) => {
  const x_1 = run_loop($norm_max_term$(t_0));
  const x_2 = run_loop($norm_max_book$(run_loop($cb$(e_0))));
  const x_3 = ((x_1 + 1) >>> 0);
  return run_jump($check_rwt_goal$, [e_0, ctx_0, t_0, dem_0, ty_0, r_0, eq_0, ((x_2 + x_3) >>> 0)]);
}), run_clo((x_4) => {
  return run_jump($bad$, ["rewrite requires equality evidence"]);
})]);
}

function $cy$(r_0) {
  const term_0 = r_0["term"];
  const typ_0 = r_0["typ"];
  const uses_0 = r_0["uses"];
  const error_0 = r_0["error"];
  return typ_0;
}

function $terms_at$(ts_0, n_0) {
  if (ts_0.$ === "Nil") {
    return run_jump($atom$, ["Absent"]);
  } else {
    const h_0 = ts_0["head"];
    const t_0 = ts_0["tail"];
    return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
    return h_0;
}), run_clo((x_1) => {
    return run_jump($terms_at$, [t_0, ((n_0 - 1) >>> 0)]);
})]);
  }
}

function $ct$(r_0) {
  const term_0 = r_0["term"];
  const typ_0 = r_0["typ"];
  const uses_0 = r_0["uses"];
  const error_0 = r_0["error"];
  return term_0;
}

function $subst$(t_0, id_0, v_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Var")), run_clo((x_0) => {
  const x_1 = run_loop($ix$(t_0));
  return run_jump($kc$, [(x_1 === id_0), run_clo((x_2) => {
  return v_0;
}), run_clo((x_3) => {
  return t_0;
})]);
}), run_clo((x_4) => {
  return run_jump($subst_node$, [t_0, id_0, v_0]);
})]);
}

function $app$(f_0, x_0) {
  return run_jump($kt$, ["App", "", 0, 0, {$: "Con", ["head"]: f_0, ["tail"]: {$: "Con", ["head"]: x_0, ["tail"]: {$: "Nil"}}}]);
}

function $ctx_get$(ctx_0, id_0) {
  if (ctx_0.$ === "Nil") {
    return run_jump($atom$, ["Absent"]);
  } else {
    const h_0 = ctx_0["head"];
    const t_0 = ctx_0["tail"];
    const x_0 = run_loop($ix$(h_0));
    return run_jump($kc$, [(x_0 === id_0), run_clo((x_1) => {
    return h_0;
}), run_clo((x_2) => {
    return run_jump($ctx_get$, [t_0, id_0]);
})]);
  }
}

function $cn$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return name_0;
}

function $cu$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return unsafe_0;
}

function $descend_spine$(qs_0, args_0, cols_0) {
  if (cols_0.$ === "Nil") {
    return false;
  } else {
    const h_0 = cols_0["head"];
    const t_0 = cols_0["tail"];
    return run_jump($descend_step$, [run_loop($descend$(run_loop($qt$(run_loop($terms_at$(qs_0, 0)))), run_loop($terms_at$(args_0, 0)), h_0)), run_loop($terms_tail$(qs_0)), run_loop($terms_tail$(args_0)), t_0]);
  }
}

function $cq$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return quantities_0;
}

function $unargs$(t_0, acc_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_0) => {
  return run_jump($unargs$, [run_loop($kid$(t_0, 0)), {$: "Con", ["head"]: run_loop($kid$(t_0, 1)), ["tail"]: acc_0}]);
}), run_clo((x_1) => {
  return acc_0;
})]);
}

function $cl$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return lhs_0;
}

function $db$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return native_0;
}

function $infer_template$(e_0, t_0, dem_0, sp_0, d_0) {
  const x_0 = run_loop($dx$(d_0));
  const x_1 = run_loop($dx$(run_loop($lookup$(run_loop($cb$(e_0)), run_loop($cn$(e_0))))));
  const x_2 = (x_0 === 0);
  const x_3 = (x_1 > 0);
  return run_jump($kc$, [(x_2 || x_3), run_clo((x_4) => {
  return run_jump($ok$, [t_0, run_loop($dt$(d_0)), {$: "Nil"}]);
}), run_clo((x_5) => {
  return run_jump($checked$, [run_loop($template_args$(e_0, run_loop($dt$(d_0)), sp_0, run_loop($dx$(d_0)))), t_0, run_loop($dt$(d_0))]);
})]);
}

function $cs$(r_0) {
  const term_0 = r_0["term"];
  const typ_0 = r_0["typ"];
  const uses_0 = r_0["uses"];
  const error_0 = r_0["error"];
  return uses_0;
}

function $qua$(q_0) {
  return run_jump($kt$, ["Qua", "", 0, q_0, {$: "Nil"}]);
}

function $uses_merge$(a_0, b_0, join_0) {
  if (a_0.$ === "Nil") {
    return b_0;
  } else {
    const h_0 = a_0["head"];
    const t_0 = a_0["tail"];
    return {$: "Con", ["head"]: run_loop($kt$("Use", "", run_loop($ix$(h_0)), run_loop($kc$(join_0, run_clo((x_0) => {
    return run_jump($qjoin$, [run_loop($qt$(h_0)), run_loop($uses_get$(b_0, run_loop($ix$(h_0))))]);
}), run_clo((x_1) => {
    return run_jump($qadd$, [run_loop($qt$(h_0)), run_loop($uses_get$(b_0, run_loop($ix$(h_0))))]);
}))), {$: "Nil"})), ["tail"]: run_loop($uses_merge$(t_0, run_loop($uses_del$(b_0, run_loop($ix$(h_0)))), join_0))};
  }
}

function $infer_app_type$(e_0, ctx_0, t_0, dem_0, r_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
  return run_jump($both$, [r_0, run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), run_loop($qdem$(run_loop($qt$(ty_0)), dem_0)), run_loop($kid$(ty_0, 0)))), t_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), run_loop($kid$(t_0, 1)))), false]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["application requires a function type"]);
})]);
}

function $terms_len$(ts_0) {
  if (ts_0.$ === "Nil") {
    return 0;
  } else {
    const h_0 = ts_0["head"];
    const t_0 = ts_0["tail"];
    const x_0 = run_loop($terms_len$(t_0));
    return ((1 + x_0) >>> 0);
  }
}

function $infer_adt_done$(t_0, r_0) {
  return run_jump($checked$, [r_0, t_0, run_loop($cy$(r_0))]);
}

function $tele_check$(e_0, ctx_0, tel_0, args_0, dem_0) {
  if (args_0.$ === "Nil") {
    return run_jump($ok$, [run_loop($atom$("Args")), tel_0, {$: "Nil"}]);
  } else {
    const h_0 = args_0["head"];
    const t_0 = args_0["tail"];
    return run_jump($tele_check_head$, [e_0, ctx_0, run_loop($wnf$(run_loop($cb$(e_0)), tel_0)), h_0, t_0, dem_0]);
  }
}

function $annotate$(e_0, ctx_0, t_0, ty_0) {
  return run_jump($ka_wrap$, [run_loop($ka_node$(e_0, ctx_0, run_loop($core_beta$(t_0)), run_loop($wnf$(run_loop($cb$(e_0)), ty_0)))), ty_0]);
}

function $ref$(name_0) {
  return run_jump($kt$, ["Ref", name_0, 0, 0, {$: "Nil"}]);
}

function $du$(d_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const typ_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return unsafe_0;
}

function $Cmp$is_eq$(c_0) {
  if (c_0.$ === "LT") {
    return false;
  } else if (c_0.$ === "EQ") {
    return true;
  } else {
    return false;
  }
}

function $String$cmp$fin$(t1_0, t2_0, hc_0) {
  const _t_0 = hc_0["fst"];
  const h1b_0 = _t_0["fst"];
  const h2b_0 = _t_0["snd"];
  const _t_1 = hc_0["snd"];
  if (_t_1.$ === "LT") {
    return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: (h1b_0 + t1_0), ["snd"]: (h2b_0 + t2_0)}, ["snd"]: {$: "LT"}};
  } else if (_t_1.$ === "EQ") {
    return run_jump($String$cmp$rec$, [h1b_0, h2b_0, run_loop($String$cmp$(t1_0, t2_0))]);
  } else {
    return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: (h1b_0 + t1_0), ["snd"]: (h2b_0 + t2_0)}, ["snd"]: {$: "GT"}};
  }
}

function $Char$cmp$(a_0, b_0) {
  const x_0 = a_0.codePointAt(0);
  const y_0 = b_0.codePointAt(0);
  return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: char_new(x_0), ["snd"]: char_new(y_0)}, ["snd"]: cmp_new(x_0, y_0)};
}

function $index_bucket$(ds_0, name_0) {
  if (ds_0.$ === "Nil") {
    return run_jump($missing$, []);
  } else {
    const h_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dn$(h_0)), name_0)), run_clo((x_0) => {
    return h_0;
}), run_clo((x_1) => {
    return run_jump($index_bucket$, [rest_0, name_0]);
})]);
  }
}

function $index_child$(tree_0, right_0) {
  return run_jump($index_child_list$, [run_loop($dc$(tree_0)), right_0]);
}

function $exact_term$(a_0, b_0) {
  const x_0 = run_loop($ix$(a_0));
  const x_1 = run_loop($ix$(b_0));
  const x_2 = run_loop($qt$(a_0));
  const x_3 = run_loop($qt$(b_0));
  return run_jump($Bool$and$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(a_0)), run_loop($tg$(b_0)))), run_loop($String$eq$(run_loop($nm$(a_0)), run_loop($nm$(b_0)))))), (x_0 === x_1))), (x_2 === x_3))), run_loop($exact_terms$(run_loop($ks$(a_0)), run_loop($ks$(b_0)))))), run_loop($exact_names$(run_loop($rm$(a_0)), run_loop($rm$(b_0))))]);
}

function $exact_defs$(a_0, b_0) {
  if (a_0.$ === "Nil") {
    return run_jump($defs_empty$, [b_0]);
  } else {
    const h_0 = a_0["head"];
    const rest_0 = a_0["tail"];
    return run_jump($exact_defs_head$, [h_0, rest_0, b_0]);
  }
}

function $U32$show$(a_0) {
  const b_0 = a_0;
  return run_jump($U32$show$if$, [b_0, (b_0 === 0)]);
}

function $check_definition_type$(book_0, d_0, e_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(d_0)), "ADT")), run_clo((x_1) => {
  return run_jump($check_adt_declaration$, [e_0, d_0]);
}), run_clo((x_2) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Absent")), run_clo((x_3) => {
  return "";
}), run_clo((x_4) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Foreign")), run_clo((x_5) => {
  return run_jump($check_foreign$, [book_0, d_0]);
}), run_clo((x_6) => {
  return run_jump($check_template_definition$, [book_0, d_0, run_loop($dt$(d_0)), run_loop($dv$(d_0)), run_loop($ref$(run_loop($dn$(d_0)))), run_loop($dx$(d_0))]);
})]);
})]);
})]);
}), run_clo((x_7) => {
  return run_jump($ce$, [r_0]);
})]);
}

function $constructor_exists$(ds_0, name_0) {
  if (ds_0.$ === "Nil") {
    return false;
  } else {
    const h_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    const x_0 = run_loop($Bool$not$(run_loop($String$eq$(run_loop($dk$(run_loop($lookup$(run_loop($dc$(h_0)), name_0)))), "Absent"))));
    const x_1 = run_loop($constructor_exists$(rest_0, name_0));
    return (x_0 || x_1);
  }
}

function $norm_compare$(book_0, a_0, b_0, le_0, fresh_0) {
  return run_jump($norm_compare_heads$, [book_0, run_loop($wnf$(book_0, a_0)), run_loop($wnf$(book_0, b_0)), le_0, fresh_0]);
}

function $norm_book_bound$(book_0) {
  if (book_0.$ === "Nil") {
    return 0;
  } else {
    const h_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(h_0)), "BookCache")), run_clo((x_0) => {
    return run_jump($da$, [h_0]);
}), run_clo((x_1) => {
    return run_jump($norm_bound_found$, [{$: "Con", ["head"]: h_0, ["tail"]: rest_0}, run_loop($lookup$({$: "Con", ["head"]: h_0, ["tail"]: rest_0}, "$kernel.max-id"))]);
})]);
  }
}

function $check_lam_done$(t_0, ty_0, q_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  const x_1 = run_loop($uses_get$(run_loop($cs$(r_0)), run_loop($ix$(t_0))));
  return run_jump($kc$, [(x_1 > q_0), run_clo((x_2) => {
  return run_jump($bad$, ["affine variable consumed more than allowed"]);
}), run_clo((x_3) => {
  return run_jump($ok$, [t_0, ty_0, run_loop($uses_del$(run_loop($cs$(r_0)), run_loop($ix$(t_0))))]);
})]);
}), run_clo((x_4) => {
  return r_0;
})]);
}

function $lhs_step$(e_0, x_0) {
  const x_1 = run_loop($cp$(e_0));
  return run_jump($kc$, [(x_1 === 0), run_clo((x_2) => {
  return e_0;
}), run_clo((x_3) => {
  const x_4 = run_loop($cp$(e_0));
  return {$: "KEnv", ["book"]: run_loop($cb$(e_0)), ["name"]: run_loop($cn$(e_0)), ["lhs"]: run_loop($kapply$(run_loop($cl$(e_0)), x_0)), ["pending"]: ((x_4 - 1) >>> 0), ["quantities"]: run_loop($cq$(e_0)), ["unsafe"]: run_loop($cu$(e_0))};
})]);
}

function $var$(name_0, id_0) {
  return run_jump($kt$, ["Var", name_0, id_0, 0, {$: "Nil"}]);
}

function $norm_var$(book_0, t_0, values_0, args_0, left_0, fallback_0) {
  if (values_0.$ === "Nil") {
    return run_jump($norm_apply$, [t_0, args_0]);
  } else {
    const h_0 = values_0["head"];
    const rest_0 = values_0["tail"];
    return run_jump($norm_eval$, [book_0, h_0, args_0, left_0, fallback_0]);
  }
}

function $norm_eval_node$(book_0, t_0, args_0, left_0, fallback_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_0) => {
  return run_jump($norm_eval$, [book_0, run_loop($kid$(t_0, 0)), {$: "Con", ["head"]: run_loop($kid$(t_0, 1)), ["tail"]: args_0}, left_0, fallback_0]);
}), run_clo((x_1) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ann")), run_clo((x_2) => {
  return run_jump($norm_eval$, [book_0, run_loop($kid$(t_0, 0)), args_0, left_0, fallback_0]);
}), run_clo((x_3) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Let")), run_clo((x_4) => {
  return run_jump($norm_eval$, [book_0, run_loop($norm_let$(run_loop($ks$(t_0)))), args_0, left_0, fallback_0]);
}), run_clo((x_5) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ref")), run_clo((x_6) => {
  return run_jump($norm_ref$, [book_0, t_0, args_0, run_loop($lookup$(book_0, run_loop($nm$(t_0))))]);
}), run_clo((x_7) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Min")), run_clo((x_8) => {
  return run_jump($norm_apply$, [run_loop($norm_min$(book_0, run_loop($kid$(t_0, 0)), run_loop($kid$(t_0, 1)))), args_0]);
}), run_clo((x_9) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Rwt")), run_clo((x_10) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($wnf$(book_0, run_loop($kid$(t_0, 0)))))), "Rfl")), run_clo((x_11) => {
  return run_jump($norm_eval$, [book_0, run_loop($kid$(t_0, 2)), args_0, left_0, fallback_0]);
}), run_clo((x_12) => {
  return run_jump($norm_apply$, [t_0, args_0]);
})]);
}), run_clo((x_13) => {
  return run_jump($norm_args$, [book_0, t_0, args_0, left_0, fallback_0]);
})]);
})]);
})]);
})]);
})]);
})]);
}

function $rm$(t_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const id_0 = t_0["id"];
  const quant_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return removed_0;
}

function $tele_fill$(book_0, tel_0, args_0) {
  if (args_0.$ === "Nil") {
    return tel_0;
  } else {
    const h_0 = args_0["head"];
    const t_0 = args_0["tail"];
    return run_jump($tele_fill_head$, [book_0, run_loop($wnf$(book_0, tel_0)), h_0, t_0]);
  }
}

function $dead_type$(book_0, ty_0) {
  return run_jump($Bool$and$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(ty_0)), "ADT")), run_loop($String$eq$(run_loop($dk$(run_loop($lookup$(book_0, run_loop($nm$(ty_0)))))), "ADT")))), run_loop($defs_empty$(run_loop($remaining$(run_loop($dc$(run_loop($lookup$(book_0, run_loop($nm$(ty_0)))))), run_loop($rm$(ty_0))))))]);
}

function $ctx_dead$(book_0, ctx_0) {
  if (ctx_0.$ === "Nil") {
    return false;
  } else {
    const h_0 = ctx_0["head"];
    const t_0 = ctx_0["tail"];
    const x_0 = run_loop($qt$(h_0));
    return run_jump($kc$, [(x_0 === 0), run_clo((x_1) => {
    return run_jump($ctx_dead$, [book_0, t_0]);
}), run_clo((x_2) => {
    const x_3 = run_loop($dead_type$(book_0, run_loop($wnf$(book_0, run_loop($kid$(h_0, 0))))));
    const x_4 = run_loop($ctx_dead$(book_0, t_0));
    return (x_3 || x_4);
})]);
  }
}

function $check_mat_ctr$(e_0, ctx_0, t_0, dem_0, ty_0, a_0, ctr_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(ctr_0)), "Absent")), run_clo((x_0) => {
  return run_jump($bad$, ["unknown or duplicate match constructor"]);
}), run_clo((x_1) => {
  return run_jump($both$, [run_loop($check$(run_loop($mat_lhs$(e_0, run_loop($nm$(t_0)), run_loop($tele_fill$(run_loop($cb$(e_0)), run_loop($dt$(ctr_0)), run_loop($ks$(a_0)))), run_loop($da$(ctr_0)))), ctx_0, run_loop($kid$(t_0, 0)), dem_0, run_loop($mat_goal$(run_loop($cb$(e_0)), ty_0, run_loop($tele_fill$(run_loop($cb$(e_0)), run_loop($dt$(ctr_0)), run_loop($ks$(a_0)))), run_loop($da$(ctr_0)), run_loop($nm$(t_0)), {$: "Nil"})))), run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), dem_0, run_loop($all$(run_loop($qt$(ty_0)), run_loop($nm$(ty_0)), run_loop($ix$(ty_0)), {$: "KTerm", ["tag"]: run_loop($tg$(a_0)), ["name"]: run_loop($nm$(a_0)), ["id"]: run_loop($ix$(a_0)), ["quant"]: run_loop($qt$(a_0)), ["kids"]: run_loop($ks$(a_0)), ["removed"]: {$: "Con", ["head"]: run_loop($nm$(t_0)), ["tail"]: run_loop($rm$(a_0))}}, run_loop($kid$(ty_0, 1)))))), t_0, ty_0, true]);
})]);
}

function $remaining$(cs_0, removed_0) {
  if (cs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = cs_0["head"];
    const t_0 = cs_0["tail"];
    return run_jump($kc$, [run_loop($has_name$(removed_0, run_loop($dn$(h_0)))), run_clo((x_0) => {
    return run_jump($remaining$, [t_0, removed_0]);
}), run_clo((x_1) => {
    return {$: "Con", ["head"]: h_0, ["tail"]: run_loop($remaining$(t_0, removed_0))};
})]);
  }
}

function $check_let_kind$(e_0, outer_0, ctx_0, h_0, rest_0, dem_0, ty_0, bindings_0, us_0, r_0, k_0) {
  return run_jump($kc$, [run_loop($good$(k_0)), run_clo((x_0) => {
  return run_jump($check_let$, [e_0, outer_0, run_loop($ctx_bind$(ctx_0, run_loop($ix$(h_0)), run_loop($qt$(h_0)), run_loop($nm$(h_0)), run_loop($cy$(r_0)))), rest_0, dem_0, ty_0, {$: "Con", ["head"]: h_0, ["tail"]: bindings_0}, run_loop($uses_merge$(us_0, run_loop($cs$(r_0)), false))]);
}), run_clo((x_1) => {
  return k_0;
})]);
}

function $uses_get$(xs_0, id_0) {
  if (xs_0.$ === "Nil") {
    return 0;
  } else {
    const h_0 = xs_0["head"];
    const t_0 = xs_0["tail"];
    const x_0 = run_loop($ix$(h_0));
    return run_jump($kc$, [(x_0 === id_0), run_clo((x_1) => {
    return run_jump($qt$, [h_0]);
}), run_clo((x_2) => {
    return run_jump($uses_get$, [t_0, id_0]);
})]);
  }
}

function $uses_del$(xs_0, id_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = xs_0["head"];
    const t_0 = xs_0["tail"];
    const x_0 = run_loop($ix$(h_0));
    return run_jump($kc$, [(x_0 === id_0), run_clo((x_1) => {
    return run_jump($uses_del$, [t_0, id_0]);
}), run_clo((x_2) => {
    return {$: "Con", ["head"]: h_0, ["tail"]: run_loop($uses_del$(t_0, id_0))};
})]);
  }
}

function $ce$(r_0) {
  const term_0 = r_0["term"];
  const typ_0 = r_0["typ"];
  const uses_0 = r_0["uses"];
  const error_0 = r_0["error"];
  return error_0;
}

function $check_rwt_goal$(e_0, ctx_0, t_0, dem_0, ty_0, r_0, eq_0, fresh_0) {
  return run_jump($kc$, [run_loop($compare$(run_loop($cb$(e_0)), run_loop($kapply$(run_loop($kapply$(run_loop($kid$(t_0, 1)), run_loop($kid$(eq_0, 1)))), run_loop($kid$(t_0, 0)))), ty_0, true)), run_clo((x_0) => {
  return run_jump($both$, [r_0, run_loop($both$(run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), 0, run_loop($all$(1, "_", fresh_0, run_loop($kid$(eq_0, 2)), run_loop($all$(1, "e", ((fresh_0 + 1) >>> 0), run_loop($kt$("Eql", "", 0, 0, {$: "Con", ["head"]: run_loop($kid$(eq_0, 0)), ["tail"]: {$: "Con", ["head"]: run_loop($var$("_", fresh_0)), ["tail"]: {$: "Con", ["head"]: run_loop($kid$(eq_0, 2)), ["tail"]: {$: "Nil"}}}})), run_loop($typ$(1)))))))), run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 2)), dem_0, run_loop($kapply$(run_loop($kapply$(run_loop($kid$(t_0, 1)), run_loop($kid$(eq_0, 0)))), run_loop($atom$("Rfl")))))), t_0, ty_0, false)), t_0, ty_0, false]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["rewrite motive does not fit goal"]);
})]);
}

function $subst_node$(t_0, id_0, v_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const n_0 = t_0["id"];
  const q_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return run_jump($core_rebuild$, [{$: "KTerm", ["tag"]: tag_0, ["name"]: name_0, ["id"]: n_0, ["quant"]: q_0, ["kids"]: run_loop($subst_terms$(kids_0, id_0, v_0)), ["removed"]: removed_0}]);
}

function $descend_step$(ord_0, qs_0, args_0, cols_0) {
  return run_jump($kc$, [(ord_0 === 0), run_clo((x_0) => {
  return true;
}), run_clo((x_1) => {
  return run_jump($kc$, [(ord_0 === 1), run_clo((x_2) => {
  return run_jump($descend_spine$, [qs_0, args_0, cols_0]);
}), run_clo((x_3) => {
  return false;
})]);
})]);
}

function $descend$(q_0, a_0, p_0) {
  return run_jump($kc$, [(q_0 === 0), run_clo((x_0) => {
  return 1;
}), run_clo((x_1) => {
  return run_jump($descend_go$, [run_loop($strip$(a_0)), run_loop($strip$(p_0))]);
})]);
}

function $terms_tail$(ts_0) {
  if (ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = ts_0["head"];
    const t_0 = ts_0["tail"];
    return t_0;
  }
}

function $template_args$(e_0, ty_0, sp_0, n_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  return run_jump($ok$, [run_loop($atom$("Args")), ty_0, {$: "Nil"}]);
}), run_clo((x_1) => {
  return run_jump($template_arg_head$, [e_0, run_loop($wnf$(run_loop($cb$(e_0)), ty_0)), sp_0, n_0]);
})]);
}

function $qjoin$(a_0, b_0) {
  return run_jump($kc$, [(a_0 > b_0), run_clo((x_0) => {
  return a_0;
}), run_clo((x_1) => {
  return b_0;
})]);
}

function $qadd$(a_0, b_0) {
  return run_jump($kc$, [(a_0 === 0), run_clo((x_0) => {
  return b_0;
}), run_clo((x_1) => {
  return run_jump($kc$, [(b_0 === 0), run_clo((x_2) => {
  return a_0;
}), run_clo((x_3) => {
  return 2;
})]);
})]);
}

function $tele_check_head$(e_0, ctx_0, tel_0, h_0, rest_0, dem_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(tel_0)), "All")), run_clo((x_0) => {
  return run_jump($tele_check_done$, [run_loop($check$(e_0, ctx_0, h_0, run_loop($qdem$(run_loop($qt$(tel_0)), dem_0)), run_loop($kid$(tel_0, 0)))), run_loop($tele_check$(e_0, ctx_0, run_loop($subst$(run_loop($kid$(tel_0, 1)), run_loop($ix$(tel_0)), h_0)), rest_0, dem_0))]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["too many telescope arguments"]);
})]);
}

function $ka_wrap$(t_0, ty_0) {
  return run_jump($kt$, ["Ann", "", 0, 0, {$: "Con", ["head"]: t_0, ["tail"]: {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}}}]);
}

function $ka_node$(e_0, ctx_0, t_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ann")), run_clo((x_0) => {
  return run_jump($ka_node$, [e_0, ctx_0, run_loop($kid$(t_0, 0)), run_loop($kid$(t_0, 1))]);
}), run_clo((x_1) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Lam")), run_clo((x_2) => {
  return run_jump($ka_lam$, [e_0, ctx_0, t_0, ty_0]);
}), run_clo((x_3) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_4) => {
  return run_jump($ka_app$, [e_0, ctx_0, t_0, run_loop($wnf$(run_loop($cb$(e_0)), run_loop($cy$(run_loop($infer$(e_0, ctx_0, run_loop($kid$(t_0, 0)), 0, {$: "Nil"}))))))]);
}), run_clo((x_5) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ctr")), run_clo((x_6) => {
  return run_jump($kt$, ["Ctr", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), run_loop($ka_args$(e_0, ctx_0, run_loop($tele_fill$(run_loop($cb$(e_0)), run_loop($dt$(run_loop($lookup$(run_loop($dc$(run_loop($lookup$(run_loop($cb$(e_0)), run_loop($nm$(ty_0)))))), run_loop($nm$(t_0)))))), run_loop($ks$(ty_0)))), run_loop($ks$(t_0))))]);
}), run_clo((x_7) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Mat")), run_clo((x_8) => {
  return run_jump($ka_mat$, [e_0, ctx_0, t_0, ty_0, run_loop($wnf$(run_loop($cb$(e_0)), run_loop($kid$(ty_0, 0))))]);
}), run_clo((x_9) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Let")), run_clo((x_10) => {
  return run_jump($kt$, ["Let", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), run_loop($ka_let$(e_0, ctx_0, ctx_0, run_loop($ks$(t_0)), ty_0))]);
}), run_clo((x_11) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Rwt")), run_clo((x_12) => {
  return run_jump($ka_rwt$, [e_0, ctx_0, t_0, run_loop($wnf$(run_loop($cb$(e_0)), run_loop($cy$(run_loop($infer$(e_0, ctx_0, run_loop($kid$(t_0, 0)), 0, {$: "Nil"}))))))]);
}), run_clo((x_13) => {
  return t_0;
})]);
})]);
})]);
})]);
})]);
})]);
})]);
}

function $String$cmp$rec$(h1b_0, h2b_0, rr_0) {
  const _t_0 = rr_0["fst"];
  const t1b_0 = _t_0["fst"];
  const t2b_0 = _t_0["snd"];
  const r_0 = rr_0["snd"];
  return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: (h1b_0 + t1b_0), ["snd"]: (h2b_0 + t2b_0)}, ["snd"]: r_0};
}

function $index_child_list$(ds_0, right_0) {
  if (ds_0.$ === "Nil") {
    return run_jump($missing$, []);
  } else {
    const h_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return run_jump($kc$, [right_0, run_clo((x_0) => {
    return run_jump($index_first$, [rest_0]);
}), run_clo((x_1) => {
    return h_0;
})]);
  }
}

function $exact_terms$(a_0, b_0) {
  if (a_0.$ === "Nil") {
    const x_0 = run_loop($terms_len$(b_0));
    return (x_0 === 0);
  } else {
    const h_0 = a_0["head"];
    const rest_0 = a_0["tail"];
    return run_jump($exact_terms_head$, [h_0, rest_0, b_0]);
  }
}

function $exact_names$(a_0, b_0) {
  if (a_0.$ === "Nil") {
    return run_jump($exact_names_empty$, [b_0]);
  } else {
    const h_0 = a_0["head"];
    const rest_0 = a_0["tail"];
    return run_jump($exact_names_head$, [h_0, rest_0, b_0]);
  }
}

function $defs_empty$(ds_0) {
  if (ds_0.$ === "Nil") {
    return true;
  } else {
    const h_0 = ds_0["head"];
    const t_0 = ds_0["tail"];
    return false;
  }
}

function $exact_defs_head$(h_0, rest_0, b_0) {
  if (b_0.$ === "Nil") {
    return false;
  } else {
    const x_0 = b_0["head"];
    const xs_0 = b_0["tail"];
    return run_jump($Bool$and$, [run_loop($exact_def$(h_0, x_0)), run_loop($exact_defs$(rest_0, xs_0))]);
  }
}

function $U32$show$if$(a_0, z_0) {
  if (z_0) {
    return "0";
  } else {
    return run_jump($U32$show$go$, [10n, a_0, ""]);
  }
}

function $check_adt_declaration$(e_0, d_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($tele_tip$(run_loop($cb$(e_0)), run_loop($dt$(d_0)))))), "Typ")), run_clo((x_0) => {
  return run_jump($check_ctors$, [e_0, d_0, run_loop($dc$(d_0)), run_loop($dt$(d_0))]);
}), run_clo((x_1) => {
  return "datatype declaration must return a kind";
})]);
}

function $check_foreign$(book_0, d_0) {
  const x_0 = run_loop($dx$(d_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$((x_0 === 0), run_loop($String$eq$(run_loop($tg$(run_loop($foreign_head$(run_loop($foreign_tip$(run_loop($dt$(d_0)))))))), "Ref")))), run_loop($String$eq$(run_loop($nm$(run_loop($foreign_head$(run_loop($foreign_tip$(run_loop($dt$(d_0)))))))), "IO")))), run_loop($String$eq$(run_loop($dk$(run_loop($lookup$(book_0, "IO")))), "Def")))), run_loop($db$(run_loop($lookup$(book_0, "IO")))))), run_clo((x_1) => {
  return "";
}), run_clo((x_2) => {
  return "foreign definition must return base IO directly";
})]);
}

function $check_template_definition$(book_0, d_0, ty_0, body_0, lhs_0, n_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  const x_1 = run_loop($da$(d_0));
  const x_2 = run_loop($dx$(d_0));
  return run_jump($ce$, [run_loop($check$({$: "KEnv", ["book"]: book_0, ["name"]: run_loop($dn$(d_0)), ["lhs"]: lhs_0, ["pending"]: ((x_1 - x_2) >>> 0), ["quantities"]: run_loop($tele_quantities$(book_0, run_loop($dt$(d_0)), run_loop($da$(d_0)))), ["unsafe"]: run_loop($du$(d_0))}, {$: "Nil"}, body_0, 1, ty_0))]);
}), run_clo((x_3) => {
  return run_jump($check_template_binder$, [book_0, d_0, run_loop($wnf$(book_0, ty_0)), body_0, lhs_0, n_0]);
})]);
}

function $norm_compare_heads$(book_0, a_0, b_0, le_0, fresh_0) {
  const x_0 = run_loop($String$eq$(run_loop($tg$(a_0)), "Lam"));
  const x_1 = run_loop($String$eq$(run_loop($tg$(b_0)), "Lam"));
  return run_jump($kc$, [(x_0 || x_1), run_clo((x_2) => {
  return run_jump($norm_compare$, [book_0, run_loop($app$(a_0, run_loop($var$("_", fresh_0)))), run_loop($app$(b_0, run_loop($var$("_", fresh_0)))), le_0, ((fresh_0 + 1) >>> 0)]);
}), run_clo((x_3) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(a_0)), run_loop($tg$(b_0)))), run_clo((x_4) => {
  return run_jump($norm_compare_same$, [book_0, a_0, b_0, le_0, fresh_0]);
}), run_clo((x_5) => {
  return false;
})]);
})]);
}

function $norm_bound_found$(book_0, stamp_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(stamp_0)), "BookBound")), run_clo((x_0) => {
  return run_jump($da$, [stamp_0]);
}), run_clo((x_1) => {
  return run_jump($norm_max_book$, [book_0]);
})]);
}

function $cp$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return pending_0;
}

function $kapply$(fn_0, x_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($strip$(fn_0)))), "Lam")), run_clo((x_1) => {
  return run_jump($subst$, [run_loop($kid$(run_loop($strip$(fn_0)), 0)), run_loop($ix$(run_loop($strip$(fn_0)))), x_0]);
}), run_clo((x_2) => {
  return run_jump($app$, [fn_0, x_0]);
})]);
}

function $norm_apply$(t_0, args_0) {
  if (args_0.$ === "Nil") {
    return t_0;
  } else {
    const h_0 = args_0["head"];
    const rest_0 = args_0["tail"];
    return run_jump($norm_apply$, [run_loop($app$(t_0, h_0)), rest_0]);
  }
}

function $norm_let$(ts_0) {
  if (ts_0.$ === "Nil") {
    return run_jump($atom$, ["Absent"]);
  } else {
    const h_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return run_jump($norm_let_tail$, [h_0, rest_0]);
  }
}

function $norm_ref$(book_0, t_0, args_0, d_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(d_0)), "ADT")), run_clo((x_0) => {
  const x_1 = run_loop($da$(d_0));
  return run_jump($kc$, [(x_1 === 0), run_clo((x_2) => {
  return run_jump($norm_apply$, [run_loop($kt$("ADT", run_loop($nm$(t_0)), 0, 0, {$: "Nil"})), args_0]);
}), run_clo((x_3) => {
  return run_jump($norm_apply$, [t_0, args_0]);
})]);
}), run_clo((x_4) => {
  const x_5 = run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Absent"));
  const x_6 = run_loop($String$eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Foreign"));
  const x_7 = run_loop($da$(d_0));
  const x_8 = run_loop($terms_len$(args_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($Bool$not$((x_5 || x_6))), (x_7 <= x_8))), run_clo((x_9) => {
  return run_jump($norm_eval$, [book_0, run_loop($dv$(d_0)), args_0, run_loop($da$(d_0)), run_loop($norm_apply$(t_0, args_0))]);
}), run_clo((x_10) => {
  return run_jump($norm_apply$, [t_0, args_0]);
})]);
})]);
}

function $norm_min$(book_0, a_0, b_0) {
  return run_jump($norm_min_left$, [book_0, run_loop($wnf$(book_0, a_0)), b_0]);
}

function $norm_args$(book_0, t_0, args_0, left_0, fallback_0) {
  if (args_0.$ === "Nil") {
    return t_0;
  } else {
    const x_0 = args_0["head"];
    const rest_0 = args_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Lam")), run_clo((x_1) => {
    return run_jump($norm_eval$, [book_0, run_loop($subst$(run_loop($kid$(t_0, 0)), run_loop($ix$(t_0)), x_0)), rest_0, run_loop($norm_dec$(left_0)), fallback_0]);
}), run_clo((x_2) => {
    return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Mat")), run_clo((x_3) => {
    return run_jump($norm_match$, [book_0, t_0, t_0, x_0, run_loop($wnf$(book_0, x_0)), rest_0, left_0, fallback_0]);
}), run_clo((x_4) => {
    return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(t_0)), "Efq")), run_loop($Bool$not$((left_0 === 0))))), run_clo((x_5) => {
    return fallback_0;
}), run_clo((x_6) => {
    return run_jump($norm_apply$, [t_0, {$: "Con", ["head"]: x_0, ["tail"]: rest_0}]);
})]);
})]);
})]);
  }
}

function $tele_fill_head$(book_0, tel_0, h_0, rest_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(tel_0)), "All")), run_clo((x_0) => {
  return run_jump($tele_fill$, [book_0, run_loop($subst$(run_loop($kid$(tel_0, 1)), run_loop($ix$(tel_0)), h_0)), rest_0]);
}), run_clo((x_1) => {
  return run_jump($atom$, ["Error"]);
})]);
}

function $mat_lhs$(e_0, name_0, tel_0, n_0) {
  const x_0 = run_loop($cp$(e_0));
  return run_jump($kc$, [(x_0 === 0), run_clo((x_1) => {
  return e_0;
}), run_clo((x_2) => {
  const x_3 = run_loop($cp$(e_0));
  const x_4 = ((x_3 - 1) >>> 0);
  return {$: "KEnv", ["book"]: run_loop($cb$(e_0)), ["name"]: run_loop($cn$(e_0)), ["lhs"]: run_loop($lhs_ext$(run_loop($cl$(e_0)), name_0, tel_0, n_0, {$: "Nil"})), ["pending"]: ((x_4 + n_0) >>> 0), ["quantities"]: run_loop($cq$(e_0)), ["unsafe"]: run_loop($cu$(e_0))};
})]);
}

function $mat_goal$(book_0, goal_0, tel_0, n_0, name_0, xs_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  return run_jump($subst$, [run_loop($kid$(goal_0, 1)), run_loop($ix$(goal_0)), run_loop($kt$("Ctr", name_0, 0, 0, run_loop($norm_join$(xs_0, {$: "Nil"}))))]);
}), run_clo((x_1) => {
  return run_jump($mat_goal_head$, [book_0, goal_0, run_loop($wnf$(book_0, tel_0)), n_0, name_0, xs_0]);
})]);
}

function $all$(q_0, name_0, id_0, a_0, b_0) {
  return run_jump($kt$, ["All", name_0, id_0, q_0, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
}

function $core_rebuild$(t_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_0) => {
  return run_jump($core_apply$, [run_loop($kid$(t_0, 0)), run_loop($kid$(t_0, 1))]);
}), run_clo((x_1) => {
  return t_0;
})]);
}

function $subst_terms$(ts_0, id_0, v_0) {
  if (ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = ts_0["head"];
    const t_0 = ts_0["tail"];
    return {$: "Con", ["head"]: run_loop($subst$(h_0, id_0, v_0)), ["tail"]: run_loop($subst_terms$(t_0, id_0, v_0))};
  }
}

function $descend_go$(a_0, p_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(p_0)), "Var")), run_clo((x_0) => {
  const x_1 = run_loop($ix$(a_0));
  const x_2 = run_loop($ix$(p_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(a_0)), "Var")), (x_1 === x_2))), run_clo((x_3) => {
  return 1;
}), run_clo((x_4) => {
  return 2;
})]);
}), run_clo((x_5) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(p_0)), "Ctr")), run_clo((x_6) => {
  const x_7 = run_loop($terms_len$(run_loop($ks$(a_0))));
  const x_8 = run_loop($terms_len$(run_loop($ks$(p_0))));
  return run_jump($descend_ctr$, [a_0, p_0, run_loop($kc$(run_loop($Bool$and$(run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(a_0)), "Ctr")), run_loop($String$eq$(run_loop($nm$(a_0)), run_loop($nm$(p_0)))))), (x_7 === x_8))), run_clo((x_9) => {
  return run_jump($descend_fields$, [run_loop($ks$(a_0)), run_loop($ks$(p_0)), 1]);
}), run_clo((x_10) => {
  return 2;
})))]);
}), run_clo((x_11) => {
  return 2;
})]);
})]);
}

function $strip$(t_0) {
  return run_jump($core_force$, [t_0]);
}

function $template_arg_head$(e_0, ty_0, sp_0, n_0) {
  if (sp_0.$ === "Nil") {
    return run_jump($bad$, ["template requires all closed comptime arguments"]);
  } else {
    const h_0 = sp_0["head"];
    const t_0 = sp_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
    return run_jump($template_arg_done$, [e_0, ty_0, h_0, t_0, n_0, run_loop($check$(e_0, {$: "Nil"}, h_0, 0, run_loop($kid$(ty_0, 0))))]);
}), run_clo((x_1) => {
    return run_jump($bad$, ["invalid template telescope"]);
})]);
  }
}

function $tele_check_done$(a_0, b_0) {
  return run_jump($both$, [a_0, b_0, run_loop($ct$(b_0)), run_loop($cy$(b_0)), false]);
}

function $ka_lam$(e_0, ctx_0, t_0, ty_0) {
  const x_0 = run_loop($qt$(t_0));
  const x_1 = run_loop($qt$(ty_0));
  return run_jump($kt$, ["Lam", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($kc$(run_loop($Bool$and$((x_0 === 2), (x_1 === 1))), run_clo((x_2) => {
  return 2;
}), run_clo((x_3) => {
  return run_jump($qt$, [ty_0]);
}))), {$: "Con", ["head"]: run_loop($annotate$(e_0, run_loop($ctx_bind$(ctx_0, run_loop($ix$(t_0)), run_loop($qt$(ty_0)), run_loop($nm$(t_0)), run_loop($kid$(ty_0, 0)))), run_loop($kid$(t_0, 0)), run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), run_loop($var$(run_loop($nm$(t_0)), run_loop($ix$(t_0)))))))), ["tail"]: {$: "Nil"}}]);
}

function $ka_app$(e_0, ctx_0, t_0, fty_0) {
  return run_jump($app$, [run_loop($annotate$(e_0, ctx_0, run_loop($kid$(t_0, 0)), fty_0)), run_loop($annotate$(e_0, ctx_0, run_loop($kid$(t_0, 1)), run_loop($kid$(fty_0, 0))))]);
}

function $ka_args$(e_0, ctx_0, tel_0, xs_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = xs_0["head"];
    const rest_0 = xs_0["tail"];
    return run_jump($ka_args_head$, [e_0, ctx_0, run_loop($wnf$(run_loop($cb$(e_0)), tel_0)), h_0, rest_0]);
  }
}

function $ka_mat$(e_0, ctx_0, t_0, ty_0, a_0) {
  return run_jump($ka_mat_ctr$, [e_0, ctx_0, t_0, ty_0, a_0, run_loop($lookup$(run_loop($dc$(run_loop($lookup$(run_loop($cb$(e_0)), run_loop($nm$(a_0)))))), run_loop($nm$(t_0))))]);
}

function $ka_let$(e_0, outer_0, ctx_0, xs_0, ty_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = xs_0["head"];
    const rest_0 = xs_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(h_0)), "Bind")), run_clo((x_0) => {
    return run_jump($ka_let_head$, [e_0, outer_0, ctx_0, h_0, rest_0, ty_0, run_loop($cy$(run_loop($infer$(e_0, outer_0, run_loop($kid$(h_0, 0)), 0, {$: "Nil"}))))]);
}), run_clo((x_1) => {
    return {$: "Con", ["head"]: run_loop($annotate$(e_0, ctx_0, h_0, ty_0)), ["tail"]: {$: "Nil"}};
})]);
  }
}

function $ka_rwt$(e_0, ctx_0, t_0, eq_0) {
  return run_jump($kt$, ["Rwt", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), {$: "Con", ["head"]: run_loop($annotate$(e_0, ctx_0, run_loop($kid$(t_0, 0)), eq_0)), ["tail"]: {$: "Con", ["head"]: run_loop($kid$(t_0, 1)), ["tail"]: {$: "Con", ["head"]: run_loop($annotate$(e_0, ctx_0, run_loop($kid$(t_0, 2)), run_loop($kapply$(run_loop($kapply$(run_loop($kid$(t_0, 1)), run_loop($kid$(eq_0, 0)))), run_loop($atom$("Rfl")))))), ["tail"]: {$: "Nil"}}}}]);
}

function $exact_terms_head$(h_0, rest_0, b_0) {
  if (b_0.$ === "Nil") {
    return false;
  } else {
    const x_0 = b_0["head"];
    const xs_0 = b_0["tail"];
    return run_jump($Bool$and$, [run_loop($exact_term$(h_0, x_0)), run_loop($exact_terms$(rest_0, xs_0))]);
  }
}

function $exact_names_empty$(b_0) {
  if (b_0.$ === "Nil") {
    return true;
  } else {
    const h_0 = b_0["head"];
    const rest_0 = b_0["tail"];
    return false;
  }
}

function $exact_names_head$(h_0, rest_0, b_0) {
  if (b_0.$ === "Nil") {
    return false;
  } else {
    const x_0 = b_0["head"];
    const xs_0 = b_0["tail"];
    return run_jump($Bool$and$, [run_loop($String$eq$(h_0, x_0)), run_loop($exact_names$(rest_0, xs_0))]);
  }
}

function $U32$show$go$(f_0, n_0, acc_0) {
  if (f_0 === 0n) {
    return acc_0;
  } else {
    const g_0 = (f_0 - 1n);
    return run_jump($U32$show$fin$, [g_0, acc_0, n_0, (n_0 === 0)]);
  }
}

function $tele_tip$(book_0, t_0) {
  return run_jump($tele_tip_head$, [book_0, run_loop($wnf$(book_0, t_0))]);
}

function $check_ctors$(e_0, d_0, ctrs_0, kind_0) {
  if (ctrs_0.$ === "Nil") {
    return "";
  } else {
    const h_0 = ctrs_0["head"];
    const t_0 = ctrs_0["tail"];
    return run_jump($check_ctors_next$, [e_0, d_0, t_0, kind_0, run_loop($check_ctor_tel$(e_0, d_0, run_loop($dt$(h_0)), kind_0, run_loop($da$(d_0)), run_loop($da$(h_0)), {$: "Nil"}, {$: "Nil"}))]);
  }
}

function $foreign_head$(t_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_0) => {
  return run_jump($foreign_head$, [run_loop($kid$(t_0, 0))]);
}), run_clo((x_1) => {
  return t_0;
})]);
}

function $foreign_tip$(t_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($strip$(t_0)))), "All")), run_clo((x_0) => {
  return run_jump($foreign_tip$, [run_loop($kid$(run_loop($strip$(t_0)), 1))]);
}), run_clo((x_1) => {
  return run_jump($strip$, [t_0]);
})]);
}

function $tele_quantities$(book_0, ty_0, n_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  return {$: "Nil"};
}), run_clo((x_1) => {
  return run_jump($tele_quantities_head$, [book_0, run_loop($wnf$(book_0, ty_0)), n_0]);
})]);
}

function $check_template_binder$(book_0, d_0, ty_0, body_0, lhs_0, n_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
  const x_1 = run_loop($nm$(ty_0));
  const x_2 = run_loop($U32$show$(run_loop($ix$(ty_0))));
  const x_3 = (x_1 + x_2);
  const x_4 = run_loop($dn$(d_0));
  const x_5 = ("~" + x_3);
  return run_jump($check_template_open$, [book_0, d_0, ty_0, body_0, lhs_0, n_0, (x_4 + x_5)]);
}), run_clo((x_6) => {
  return "template telescope is too short";
})]);
}

function $norm_compare_same$(book_0, a_0, b_0, le_0, fresh_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(a_0)), "Var")), run_clo((x_0) => {
  const x_1 = run_loop($ix$(a_0));
  const x_2 = run_loop($ix$(b_0));
  return (x_1 === x_2);
}), run_clo((x_3) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(a_0)), "Typ")), run_clo((x_4) => {
  return run_jump($kc$, [le_0, run_clo((x_5) => {
  return run_jump($norm_kind$, [book_0, a_0, b_0, run_loop($wnf$(book_0, run_loop($kid$(a_0, 0)))), run_loop($wnf$(book_0, run_loop($kid$(b_0, 0)))), fresh_0]);
}), run_clo((x_6) => {
  return run_jump($norm_compare$, [book_0, run_loop($kid$(a_0, 0)), run_loop($kid$(b_0, 0)), false, fresh_0]);
})]);
}), run_clo((x_7) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(a_0)), "All")), run_clo((x_8) => {
  const x_9 = run_loop($qt$(a_0));
  const x_10 = run_loop($qt$(b_0));
  return run_jump($Bool$and$, [(x_9 === x_10), run_loop($Bool$and$(run_loop($norm_compare$(book_0, run_loop($kid$(b_0, 0)), run_loop($kid$(a_0, 0)), le_0, fresh_0)), run_loop($norm_compare$(book_0, run_loop($subst$(run_loop($kid$(a_0, 1)), run_loop($ix$(a_0)), run_loop($var$("_", fresh_0)))), run_loop($subst$(run_loop($kid$(b_0, 1)), run_loop($ix$(b_0)), run_loop($var$("_", fresh_0)))), le_0, ((fresh_0 + 1) >>> 0)))))]);
}), run_clo((x_11) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(a_0)), "ADT")), run_clo((x_12) => {
  return run_jump($Bool$and$, [run_loop($String$eq$(run_loop($nm$(a_0)), run_loop($nm$(b_0)))), run_loop($Bool$and$(run_loop($norm_removed$(run_loop($rm$(a_0)), run_loop($rm$(b_0)), le_0)), run_loop($norm_compare_terms$(book_0, run_loop($ks$(a_0)), run_loop($ks$(b_0)), fresh_0))))]);
}), run_clo((x_13) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(a_0)), "Qua")), run_clo((x_14) => {
  const x_15 = run_loop($qt$(a_0));
  const x_16 = run_loop($qt$(b_0));
  return (x_15 === x_16);
}), run_clo((x_17) => {
  return run_jump($norm_compare_plain$, [book_0, a_0, b_0, fresh_0]);
})]);
})]);
})]);
})]);
})]);
}

function $norm_let_tail$(h_0, rest_0) {
  if (rest_0.$ === "Nil") {
    return h_0;
  } else {
    const x_0 = rest_0["head"];
    const xs_0 = rest_0["tail"];
    return run_jump($subst$, [run_loop($norm_let$({$: "Con", ["head"]: x_0, ["tail"]: xs_0})), run_loop($ix$(h_0)), run_loop($kid$(h_0, 0))]);
  }
}

function $norm_min_left$(book_0, a_0, b_0) {
  const x_0 = run_loop($qt$(a_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(a_0)), "Qua")), (x_0 === 2))), run_clo((x_1) => {
  return run_jump($wnf$, [book_0, b_0]);
}), run_clo((x_2) => {
  const x_3 = run_loop($qt$(a_0));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(a_0)), "Qua")), (x_3 === 0))), run_clo((x_4) => {
  return a_0;
}), run_clo((x_5) => {
  return run_jump($norm_min_right$, [a_0, run_loop($wnf$(book_0, b_0))]);
})]);
})]);
}

function $norm_dec$(n_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  return 0;
}), run_clo((x_1) => {
  return ((n_0 - 1) >>> 0);
})]);
}

function $norm_match$(book_0, arm_0, original_0, raw_0, x_0, args_0, left_0, fallback_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(x_0)), "Ctr")), run_clo((x_1) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(arm_0)), "Ann")), run_clo((x_2) => {
  return run_jump($norm_match$, [book_0, run_loop($kid$(arm_0, 0)), original_0, raw_0, x_0, args_0, left_0, fallback_0]);
}), run_clo((x_3) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(arm_0)), "Mat")), run_clo((x_4) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($nm$(arm_0)), run_loop($nm$(x_0)))), run_clo((x_5) => {
  return run_jump($kc$, [(left_0 === 0), run_clo((x_6) => {
  return run_jump($norm_eval$, [book_0, run_loop($kid$(arm_0, 0)), run_loop($norm_join$(run_loop($ks$(x_0)), args_0)), 0, fallback_0]);
}), run_clo((x_7) => {
  const x_8 = run_loop($norm_dec$(left_0));
  const x_9 = run_loop($terms_len$(run_loop($ks$(x_0))));
  return run_jump($norm_eval$, [book_0, run_loop($kid$(arm_0, 0)), run_loop($norm_join$(run_loop($ks$(x_0)), args_0)), ((x_8 + x_9) >>> 0), fallback_0]);
})]);
}), run_clo((x_10) => {
  return run_jump($norm_match$, [book_0, run_loop($kid$(arm_0, 1)), original_0, raw_0, x_0, args_0, left_0, fallback_0]);
})]);
}), run_clo((x_11) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(arm_0)), "Efq")), run_clo((x_12) => {
  return run_jump($norm_stuck$, [original_0, raw_0, args_0, left_0, fallback_0]);
}), run_clo((x_13) => {
  return run_jump($norm_eval$, [book_0, arm_0, {$: "Con", ["head"]: x_0, ["tail"]: args_0}, left_0, fallback_0]);
})]);
})]);
})]);
}), run_clo((x_14) => {
  return run_jump($norm_stuck$, [original_0, raw_0, args_0, left_0, fallback_0]);
})]);
}

function $lhs_ext$(lhs_0, name_0, tel_0, n_0, xs_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  return run_jump($kapply$, [lhs_0, run_loop($kt$("Ctr", name_0, 0, 0, xs_0))]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Lam", run_loop($nm$(tel_0)), run_loop($ix$(tel_0)), run_loop($qt$(tel_0)), {$: "Con", ["head"]: run_loop($lhs_ext$(lhs_0, name_0, run_loop($kid$(tel_0, 1)), ((n_0 - 1) >>> 0), run_loop($norm_join$(xs_0, {$: "Con", ["head"]: run_loop($var$(run_loop($nm$(tel_0)), run_loop($ix$(tel_0)))), ["tail"]: {$: "Nil"}})))), ["tail"]: {$: "Nil"}}]);
})]);
}

function $norm_join$(a_0, b_0) {
  if (a_0.$ === "Nil") {
    return b_0;
  } else {
    const h_0 = a_0["head"];
    const t_0 = a_0["tail"];
    return {$: "Con", ["head"]: h_0, ["tail"]: run_loop($norm_join$(t_0, b_0))};
  }
}

function $mat_goal_head$(book_0, goal_0, tel_0, n_0, name_0, xs_0) {
  const x_0 = run_loop($qt$(tel_0));
  return run_jump($all$, [run_loop($kc$((x_0 === 0), run_clo((x_1) => {
  return 0;
}), run_clo((x_2) => {
  const x_3 = run_loop($qt$(tel_0));
  return run_jump($kc$, [(x_3 === 1), run_clo((x_4) => {
  return run_jump($qt$, [goal_0]);
}), run_clo((x_5) => {
  return run_jump($qadd$, [run_loop($qt$(goal_0)), run_loop($qt$(goal_0))]);
})]);
}))), run_loop($nm$(tel_0)), run_loop($ix$(tel_0)), run_loop($kid$(tel_0, 0)), run_loop($mat_goal$(book_0, goal_0, run_loop($kid$(tel_0, 1)), ((n_0 - 1) >>> 0), name_0, run_loop($norm_join$(xs_0, {$: "Con", ["head"]: run_loop($var$(run_loop($nm$(tel_0)), run_loop($ix$(tel_0)))), ["tail"]: {$: "Nil"}}))))]);
}

function $descend_ctr$(a_0, p_0, ord_0) {
  return run_jump($kc$, [(ord_0 === 2), run_clo((x_0) => {
  return run_jump($descend_sub$, [a_0, run_loop($ks$(p_0))]);
}), run_clo((x_1) => {
  return ord_0;
})]);
}

function $descend_fields$(a_0, p_0, ord_0) {
  if (a_0.$ === "Nil") {
    return ord_0;
  } else {
    const h_0 = a_0["head"];
    const t_0 = a_0["tail"];
    return run_jump($kc$, [(ord_0 === 2), run_clo((x_0) => {
    return 2;
}), run_clo((x_1) => {
    const x_2 = run_loop($descend$(1, h_0, run_loop($terms_at$(p_0, 0))));
    return run_jump($descend_fields$, [t_0, run_loop($terms_tail$(p_0)), run_loop($kc$((x_2 === 1), run_clo((x_3) => {
    return ord_0;
}), run_clo((x_4) => {
    return run_jump($descend$, [1, h_0, run_loop($terms_at$(p_0, 0))]);
})))]);
})]);
  }
}

function $core_force$(t_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Ann")), run_clo((x_0) => {
  return run_jump($core_force$, [run_loop($kid$(t_0, 0))]);
}), run_clo((x_1) => {
  const x_2 = run_loop($terms_len$(run_loop($ks$(t_0))));
  return run_jump($kc$, [run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(t_0)), "Var")), (x_2 > 0))), run_clo((x_3) => {
  return run_jump($core_force$, [run_loop($kid$(t_0, 0))]);
}), run_clo((x_4) => {
  return t_0;
})]);
})]);
}

function $template_arg_done$(e_0, ty_0, h_0, rest_0, n_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($template_args$, [e_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), h_0)), rest_0, ((n_0 - 1) >>> 0)]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["template argument is open or ill-typed"]);
})]);
}

function $ka_args_head$(e_0, ctx_0, tel_0, h_0, rest_0) {
  return {$: "Con", ["head"]: run_loop($annotate$(e_0, ctx_0, h_0, run_loop($kid$(tel_0, 0)))), ["tail"]: run_loop($ka_args$(e_0, ctx_0, run_loop($subst$(run_loop($kid$(tel_0, 1)), run_loop($ix$(tel_0)), h_0)), rest_0))};
}

function $ka_mat_ctr$(e_0, ctx_0, t_0, ty_0, a_0, c_0) {
  return run_jump($kt$, ["Mat", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), {$: "Con", ["head"]: run_loop($annotate$(e_0, ctx_0, run_loop($kid$(t_0, 0)), run_loop($mat_goal$(run_loop($cb$(e_0)), ty_0, run_loop($tele_fill$(run_loop($cb$(e_0)), run_loop($dt$(c_0)), run_loop($ks$(a_0)))), run_loop($da$(c_0)), run_loop($nm$(t_0)), {$: "Nil"})))), ["tail"]: {$: "Con", ["head"]: run_loop($annotate$(e_0, ctx_0, run_loop($kid$(t_0, 1)), run_loop($all$(run_loop($qt$(ty_0)), run_loop($nm$(ty_0)), run_loop($ix$(ty_0)), {$: "KTerm", ["tag"]: run_loop($tg$(a_0)), ["name"]: run_loop($nm$(a_0)), ["id"]: run_loop($ix$(a_0)), ["quant"]: run_loop($qt$(a_0)), ["kids"]: run_loop($ks$(a_0)), ["removed"]: {$: "Con", ["head"]: run_loop($nm$(t_0)), ["tail"]: run_loop($rm$(a_0))}}, run_loop($kid$(ty_0, 1)))))), ["tail"]: {$: "Nil"}}}]);
}

function $ka_let_head$(e_0, outer_0, ctx_0, h_0, rest_0, ty_0, vty_0) {
  return {$: "Con", ["head"]: run_loop($kt$("Bind", run_loop($nm$(h_0)), run_loop($ix$(h_0)), run_loop($qt$(h_0)), {$: "Con", ["head"]: run_loop($annotate$(e_0, outer_0, run_loop($kid$(h_0, 0)), vty_0)), ["tail"]: {$: "Nil"}})), ["tail"]: run_loop($ka_let$(e_0, outer_0, run_loop($ctx_bind$(ctx_0, run_loop($ix$(h_0)), run_loop($qt$(h_0)), run_loop($nm$(h_0)), vty_0)), run_loop($subst_terms$(rest_0, run_loop($ix$(h_0)), run_loop($kt$("Var", run_loop($nm$(h_0)), run_loop($ix$(h_0)), 0, {$: "Con", ["head"]: run_loop($kid$(h_0, 0)), ["tail"]: {$: "Nil"}})))), ty_0))};
}

function $U32$show$fin$(g_0, acc_0, n_0, z_0) {
  if (z_0) {
    return acc_0;
  } else {
    const x_0 = (10 === 0 ? n_0 : n_0 % 10);
    return run_jump($U32$show$go$, [g_0, (10 === 0 ? 0 : (n_0 / 10) >>> 0), (char_new(((48 + x_0) >>> 0)) + acc_0)]);
  }
}

function $tele_tip_head$(book_0, t_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "All")), run_clo((x_0) => {
  return run_jump($tele_tip$, [book_0, run_loop($kid$(t_0, 1))]);
}), run_clo((x_1) => {
  return t_0;
})]);
}

function $check_ctors_next$(e_0, d_0, rest_0, kind_0, err_0) {
  return run_jump($kc$, [run_loop($String$eq$(err_0, "")), run_clo((x_0) => {
  return run_jump($check_ctors$, [e_0, d_0, rest_0, kind_0]);
}), run_clo((x_1) => {
  return err_0;
})]);
}

function $check_ctor_tel$(e_0, d_0, tel_0, kind_0, params_0, fields_0, ctx_0, args_0) {
  const x_0 = ((params_0 + fields_0) >>> 0);
  return run_jump($kc$, [(x_0 === 0), run_clo((x_1) => {
  return run_jump($kc$, [run_loop($compare$(run_loop($cb$(e_0)), tel_0, run_loop($kt$("ADT", run_loop($dn$(d_0)), 0, 0, args_0)), false)), run_clo((x_2) => {
  return "";
}), run_clo((x_3) => {
  return "constructor result must apply family to its parameters";
})]);
}), run_clo((x_4) => {
  return run_jump($check_ctor_head$, [e_0, d_0, run_loop($wnf$(run_loop($cb$(e_0)), tel_0)), kind_0, params_0, fields_0, ctx_0, args_0]);
})]);
}

function $tele_quantities_head$(book_0, ty_0, n_0) {
  return {$: "Con", ["head"]: run_loop($qua$(run_loop($kc$(run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
  return run_jump($qt$, [ty_0]);
}), run_clo((x_1) => {
  return 1;
}))))), ["tail"]: run_loop($tele_quantities$(book_0, run_loop($kid$(ty_0, 1)), ((n_0 - 1) >>> 0)))};
}

function $check_template_open$(book_0, d_0, ty_0, body_0, lhs_0, n_0, name_0) {
  return run_jump($check_template_definition$, [run_loop($book_put$(book_0, {$: "KDef", ["name"]: name_0, ["kind"]: "Def", ["arity"]: 0, ["templates"]: 0, ["typ"]: run_loop($kid$(ty_0, 0)), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: true, ["unsafe"]: false})), d_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), run_loop($ref$(name_0)))), run_loop($kapply$(body_0, run_loop($ref$(name_0)))), run_loop($app$(lhs_0, run_loop($ref$(name_0)))), ((n_0 - 1) >>> 0)]);
}

function $norm_kind$(book_0, a_0, b_0, g_0, h_0, fresh_0) {
  const x_0 = run_loop($qt$(g_0));
  const x_1 = run_loop($qt$(h_0));
  const x_2 = run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(g_0)), "Qua")), (x_0 === 2)));
  const x_3 = run_loop($Bool$and$(run_loop($String$eq$(run_loop($tg$(h_0)), "Qua")), run_loop($Bool$not$((x_1 === 2)))));
  return run_jump($kc$, [(x_2 || x_3), run_clo((x_4) => {
  return true;
}), run_clo((x_5) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(g_0)), "Min")), run_clo((x_6) => {
  return run_jump($Bool$and$, [run_loop($norm_compare$(book_0, run_loop($kt$("Typ", "", 0, 0, {$: "Con", ["head"]: run_loop($kid$(g_0, 0)), ["tail"]: {$: "Nil"}})), b_0, true, fresh_0)), run_loop($norm_compare$(book_0, run_loop($kt$("Typ", "", 0, 0, {$: "Con", ["head"]: run_loop($kid$(g_0, 1)), ["tail"]: {$: "Nil"}})), b_0, true, fresh_0))]);
}), run_clo((x_7) => {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(h_0)), "Min")), run_clo((x_8) => {
  const x_9 = run_loop($norm_compare$(book_0, a_0, run_loop($kt$("Typ", "", 0, 0, {$: "Con", ["head"]: run_loop($kid$(h_0, 0)), ["tail"]: {$: "Nil"}})), true, fresh_0));
  const x_10 = run_loop($norm_compare$(book_0, a_0, run_loop($kt$("Typ", "", 0, 0, {$: "Con", ["head"]: run_loop($kid$(h_0, 1)), ["tail"]: {$: "Nil"}})), true, fresh_0));
  return (x_9 || x_10);
}), run_clo((x_11) => {
  return run_jump($norm_compare$, [book_0, g_0, h_0, true, fresh_0]);
})]);
})]);
})]);
}

function $norm_removed$(as_0, bs_0, le_0) {
  return run_jump($kc$, [le_0, run_clo((x_0) => {
  return run_jump($norm_subset$, [as_0, bs_0]);
}), run_clo((x_1) => {
  const x_2 = run_loop($norm_names_len$(as_0));
  const x_3 = run_loop($norm_names_len$(bs_0));
  return run_jump($Bool$and$, [(x_2 === x_3), run_loop($norm_subset$(as_0, bs_0))]);
})]);
}

function $norm_compare_terms$(book_0, as_0, bs_0, fresh_0) {
  if (as_0.$ === "Nil") {
    if (bs_0.$ === "Nil") {
      return true;
    } else {
      const h_0 = bs_0["head"];
      const t_0 = bs_0["tail"];
      return false;
    }
  } else {
    const ah_0 = as_0["head"];
    const at_0 = as_0["tail"];
    if (bs_0.$ === "Nil") {
      return false;
    } else {
      const bh_0 = bs_0["head"];
      const bt_0 = bs_0["tail"];
      return run_jump($Bool$and$, [run_loop($norm_compare$(book_0, ah_0, bh_0, false, fresh_0)), run_loop($norm_compare_terms$(book_0, at_0, bt_0, fresh_0))]);
    }
  }
}

function $norm_compare_plain$(book_0, a_0, b_0, fresh_0) {
  const x_0 = run_loop($String$eq$(run_loop($tg$(a_0)), "Ref"));
  const x_1 = run_loop($String$eq$(run_loop($tg$(a_0)), "Hol"));
  return run_jump($kc$, [(x_0 || x_1), run_clo((x_2) => {
  return run_jump($String$eq$, [run_loop($nm$(a_0)), run_loop($nm$(b_0))]);
}), run_clo((x_3) => {
  const x_4 = run_loop($String$eq$(run_loop($tg$(a_0)), "Ctr"));
  const x_5 = run_loop($String$eq$(run_loop($tg$(a_0)), "Mat"));
  return run_jump($kc$, [(x_4 || x_5), run_clo((x_6) => {
  return run_jump($Bool$and$, [run_loop($String$eq$(run_loop($nm$(a_0)), run_loop($nm$(b_0)))), run_loop($norm_compare_terms$(book_0, run_loop($ks$(a_0)), run_loop($ks$(b_0)), fresh_0))]);
}), run_clo((x_7) => {
  const x_8 = run_loop($String$eq$(run_loop($tg$(a_0)), "App"));
  const x_9 = run_loop($String$eq$(run_loop($tg$(a_0)), "Min"));
  const x_10 = run_loop($String$eq$(run_loop($tg$(a_0)), "Eql"));
  const x_11 = run_loop($String$eq$(run_loop($tg$(a_0)), "Rwt"));
  const x_12 = (x_8 || x_9);
  const x_13 = (x_10 || x_11);
  return run_jump($kc$, [(x_12 || x_13), run_clo((x_14) => {
  return run_jump($norm_compare_terms$, [book_0, run_loop($ks$(a_0)), run_loop($ks$(b_0)), fresh_0]);
}), run_clo((x_15) => {
  const x_16 = run_loop($String$eq$(run_loop($tg$(a_0)), "Rfl"));
  const x_17 = run_loop($String$eq$(run_loop($tg$(a_0)), "Efq"));
  const x_18 = run_loop($String$eq$(run_loop($tg$(a_0)), "Qnt"));
  const x_19 = (x_16 || x_17);
  return (x_18 || x_19);
})]);
})]);
})]);
}

function $norm_min_right$(a_0, b_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(b_0)), "Qua")), run_clo((x_0) => {
  const x_1 = run_loop($qt$(b_0));
  return run_jump($kc$, [(x_1 === 2), run_clo((x_2) => {
  return a_0;
}), run_clo((x_3) => {
  const x_4 = run_loop($qt$(b_0));
  return run_jump($kc$, [run_loop($Bool$and$((x_4 === 1), run_loop($Bool$not$(run_loop($String$eq$(run_loop($tg$(a_0)), "Qua")))))), run_clo((x_5) => {
  return run_jump($kt$, ["Min", "", 0, 0, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_6) => {
  return b_0;
})]);
})]);
}), run_clo((x_7) => {
  return run_jump($kt$, ["Min", "", 0, 0, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
})]);
}

function $norm_stuck$(t_0, x_0, args_0, left_0, fallback_0) {
  return run_jump($kc$, [(left_0 === 0), run_clo((x_1) => {
  return run_jump($norm_apply$, [run_loop($app$(t_0, x_0)), args_0]);
}), run_clo((x_2) => {
  return fallback_0;
})]);
}

function $descend_sub$(a_0, ps_0) {
  if (ps_0.$ === "Nil") {
    return 2;
  } else {
    const h_0 = ps_0["head"];
    const t_0 = ps_0["tail"];
    const x_0 = run_loop($descend$(1, a_0, h_0));
    return run_jump($kc$, [(x_0 === 2), run_clo((x_1) => {
    return run_jump($descend_sub$, [a_0, t_0]);
}), run_clo((x_2) => {
    return 0;
})]);
  }
}

function $check_ctor_head$(e_0, d_0, tel_0, kind_0, params_0, fields_0, ctx_0, args_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(tel_0)), "All")), run_clo((x_0) => {
  const x_1 = run_loop($qt$(tel_0));
  return run_jump($check_ctor_domain$, [e_0, d_0, tel_0, kind_0, params_0, fields_0, ctx_0, args_0, run_loop($check$(e_0, ctx_0, run_loop($kid$(tel_0, 0)), 0, run_loop($kc$(run_loop($Bool$and$((params_0 === 0), (x_1 === 1))), run_clo((x_2) => {
  return kind_0;
}), run_clo((x_3) => {
  return run_jump($typ$, [run_loop($qt$(tel_0))]);
})))))]);
}), run_clo((x_4) => {
  return "constructor telescope missing a binder";
})]);
}

function $norm_subset$(as_0, bs_0) {
  if (bs_0.$ === "Nil") {
    return true;
  } else {
    const h_0 = bs_0["head"];
    const t_0 = bs_0["tail"];
    return run_jump($Bool$and$, [run_loop($has_name$(as_0, h_0)), run_loop($norm_subset$(as_0, t_0))]);
  }
}

function $norm_names_len$(names_0) {
  if (names_0.$ === "Nil") {
    return 0;
  } else {
    const h_0 = names_0["head"];
    const rest_0 = names_0["tail"];
    const x_0 = run_loop($norm_names_len$(rest_0));
    return ((1 + x_0) >>> 0);
  }
}

function $check_ctor_domain$(e_0, d_0, tel_0, kind_0, params_0, fields_0, ctx_0, args_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($check_ctor_tel$, [e_0, d_0, run_loop($kid$(tel_0, 1)), run_loop($kc$((params_0 === 0), run_clo((x_1) => {
  return kind_0;
}), run_clo((x_2) => {
  return run_jump($subst$, [run_loop($kid$(run_loop($wnf$(run_loop($cb$(e_0)), kind_0)), 1)), run_loop($ix$(run_loop($wnf$(run_loop($cb$(e_0)), kind_0)))), run_loop($var$(run_loop($nm$(tel_0)), run_loop($ix$(tel_0))))]);
}))), run_loop($kc$((params_0 === 0), run_clo((x_3) => {
  return 0;
}), run_clo((x_4) => {
  return ((params_0 - 1) >>> 0);
}))), run_loop($kc$((params_0 === 0), run_clo((x_5) => {
  return ((fields_0 - 1) >>> 0);
}), run_clo((x_6) => {
  return fields_0;
}))), run_loop($ctx_bind$(ctx_0, run_loop($ix$(tel_0)), run_loop($qt$(tel_0)), run_loop($nm$(tel_0)), run_loop($kid$(tel_0, 0)))), run_loop($kc$((params_0 === 0), run_clo((x_7) => {
  return args_0;
}), run_clo((x_8) => {
  return run_jump($norm_join$, [args_0, {$: "Con", ["head"]: run_loop($var$(run_loop($nm$(tel_0)), run_loop($ix$(tel_0)))), ["tail"]: {$: "Nil"}}]);
})))]);
}), run_clo((x_9) => {
  return run_jump($ce$, [r_0]);
})]);
}
export default {
  "check_book": run_lib($check_book$, 1),
  "check": run_lib($check$, 5),
  "infer": run_lib($infer$, 5),
  "annotate_book": run_lib($annotate_book$, 1),
  "annotate_except": run_lib($annotate_except$, 2),
  "annotate_selected": run_lib($annotate_selected$, 3),
  "lookup": run_lib($lookup$, 2),
  "book_cached": run_lib($book_cached$, 2),
  "book_put": run_lib($book_put$, 2),
  "exact_prefix": run_lib($exact_prefix$, 2),
  "check_from_exact_prefix": run_lib($check_from_exact_prefix$, 2),
};
