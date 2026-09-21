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

function $f_load_graph$(main_0, sources_0) {
  return run_jump($f_graph_result$, [run_loop($f_graph_load$(main_0, "", sources_0, {$: "FGraph", ["book"]: {$: "Nil"}, ["error"]: "", ["done"]: {$: "Nil"}}, {$: "Nil"}))]);
}

function $check_book$(book_0) {
  return run_jump($check_events$, [book_0, {$: "Con", ["head"]: {$: "KDef", ["name"]: "$kernel.max-id", ["kind"]: "BookBound", ["arity"]: run_loop($norm_max_book$(book_0)), ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: true, ["unsafe"]: false}, ["tail"]: {$: "Nil"}}]);
}

function $check_from_exact_prefix$(book_0, validated_0) {
  return run_jump($kc$, [run_loop($exact_prefix$(book_0, validated_0)), run_clo((x_0) => {
  return run_jump($check_prefix_seed$, [book_0, validated_0, {$: "Con", ["head"]: {$: "KDef", ["name"]: "$kernel.max-id", ["kind"]: "BookBound", ["arity"]: run_loop($norm_max_book$(book_0)), ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: true, ["unsafe"]: false}, ["tail"]: {$: "Nil"}}]);
}), run_clo((x_1) => {
  return run_jump($check_book$, [book_0]);
})]);
}

function $f_graph_result$(g_0) {
  const book_0 = g_0["book"];
  const err_0 = g_0["error"];
  const done_0 = g_0["done"];
  return run_jump($f_fresh_result$, [run_loop($f_validate_result$({$: "FResult", ["book"]: book_0, ["error"]: err_0, ["imports"]: {$: "Nil"}}))]);
}

function $f_graph_load$(path_0, ns_0, sources_0, g_0, stack_0) {
  return run_jump($f_graph_source_load$, [run_loop($f_graph_source$(path_0, sources_0)), ns_0, sources_0, g_0, stack_0]);
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

function $atom$(tag_0) {
  return run_jump($kt$, [tag_0, "", 0, 0, {$: "Nil"}]);
}

function $kc$(b_0, yes_0, no_0) {
  if (b_0) {
    return run_tail(yes_0, {$: "Unit"});
  } else {
    return run_tail(no_0, {$: "Unit"});
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

function $check_prefix_seed$(book_0, validated_0, done_0) {
  if (validated_0.$ === "Nil") {
    return run_jump($check_events$, [book_0, done_0]);
  } else {
    const h_0 = validated_0["head"];
    const rest_0 = validated_0["tail"];
    return run_jump($check_prefix_step$, [book_0, h_0, rest_0, done_0]);
  }
}

function $f_fresh_result$(r_0) {
  const book_0 = r_0["book"];
  const err_0 = r_0["error"];
  const imports_0 = r_0["imports"];
  return run_jump($f_fresh_result_end$, [run_loop($f_fresh_defs$(book_0, 1)), err_0, imports_0]);
}

function $f_validate_result$(r_0) {
  const book_0 = r_0["book"];
  const err_0 = r_0["error"];
  const imports_0 = r_0["imports"];
  return {$: "FResult", ["book"]: book_0, ["error"]: run_loop($f_choose$(run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($f_error_defs$, [book_0]);
}), run_clo((x_1) => {
  return err_0;
}))), ["imports"]: imports_0};
}

function $f_graph_source_load$(s_0, ns_0, sources_0, g_0, stack_0) {
  const book_0 = g_0["book"];
  const err_0 = g_0["error"];
  const done_0 = g_0["done"];
  return run_jump($f_choose$, [run_loop($Bool$not$(run_loop($String$is_empty$(err_0)))), run_clo((x_0) => {
  return {$: "FGraph", ["book"]: book_0, ["error"]: err_0, ["done"]: done_0};
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($String$is_empty$(run_loop($f_source_path$(s_0)))), run_clo((x_2) => {
  return {$: "FGraph", ["book"]: book_0, ["error"]: "module source was not supplied", ["done"]: done_0};
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($has_name$(stack_0, run_loop($f_source_path$(s_0)))), run_clo((x_4) => {
  const x_5 = run_loop($f_source_path$(s_0));
  return {$: "FGraph", ["book"]: book_0, ["error"]: ("cyclic import through " + x_5), ["done"]: done_0};
}), run_clo((x_6) => {
  return run_jump($f_graph_cached$, [s_0, ns_0, sources_0, {$: "FGraph", ["book"]: book_0, ["error"]: err_0, ["done"]: done_0}, stack_0, run_loop($f_env$(run_loop($f_source_path$(s_0)), done_0))]);
})]);
})]);
})]);
}

function $f_graph_source$(path_0, sources_0) {
  if (sources_0.$ === "Nil") {
    return {$: "FSource", ["name"]: "", ["path"]: "", ["text"]: ""};
  } else {
    const s_0 = sources_0["head"];
    const rest_0 = sources_0["tail"];
    const x_0 = run_loop($f_eq$(path_0, run_loop($f_source_name$(s_0))));
    const x_1 = run_loop($f_eq$(path_0, run_loop($f_source_path$(s_0))));
    return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
    return s_0;
}), run_clo((x_3) => {
    return run_jump($f_graph_source$, [path_0, rest_0]);
})]);
  }
}

function $check_open$(book_0) {
  return run_jump($check_open_message$, [run_loop($count_open$(book_0))]);
}

function $check_event_guard$(rest_0, done_0, d_0, err_0) {
  return run_jump($kc$, [run_loop($String$eq$(err_0, "")), run_clo((x_0) => {
  return run_jump($check_event_done$, [rest_0, done_0, d_0, run_loop($check_definition$({$: "Con", ["head"]: run_loop($declared$(d_0)), ["tail"]: run_loop($book_without$(done_0, run_loop($dn$(d_0))))}, d_0))]);
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

function $lookup$(book_0, name_0) {
  if (book_0.$ === "Nil") {
    return run_jump($missing$, []);
  } else {
    const d_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dn$(d_0)), name_0)), run_clo((x_0) => {
    return d_0;
}), run_clo((x_1) => {
    return run_jump($lookup$, [rest_0, name_0]);
})]);
  }
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

function $kt$(tag_0, name_0, id_0, quant_0, kids_0) {
  return {$: "KTerm", ["tag"]: tag_0, ["name"]: name_0, ["id"]: id_0, ["quant"]: quant_0, ["kids"]: kids_0, ["removed"]: {$: "Nil"}};
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

function $check_prefix_step$(book_0, h_0, rest_0, done_0) {
  if (book_0.$ === "Nil") {
    return "invalid validated prefix";
  } else {
    const x_0 = book_0["head"];
    const xs_0 = book_0["tail"];
    return run_jump($check_prefix_seed$, [xs_0, rest_0, {$: "Con", ["head"]: h_0, ["tail"]: run_loop($book_without$(done_0, run_loop($dn$(h_0))))}]);
  }
}

function $f_fresh_result_end$(r_0, err_0, imports_0) {
  const book_0 = r_0["defs"];
  const next_0 = r_0["next"];
  return {$: "FResult", ["book"]: book_0, ["error"]: err_0, ["imports"]: imports_0};
}

function $f_fresh_defs$(ds_0, next_0) {
  if (ds_0.$ === "Nil") {
    return {$: "FFreshDefs", ["defs"]: {$: "Nil"}, ["next"]: next_0};
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return run_jump($f_fresh_def_type$, [d_0, rest_0, run_loop($f_fresh_term$(run_loop($dt$(d_0)), {$: "Nil"}, next_0))]);
  }
}

function $f_choose$(b_0, yes_0, no_0) {
  if (b_0) {
    return run_tail(yes_0, {$: "Unit"});
  } else {
    return run_tail(no_0, {$: "Unit"});
  }
}

function $String$is_empty$(s_0) {
  if (s_0 === "") {
    return true;
  } else {
    const h_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(0, 2) : s_0[0]);
    const t_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(2) : s_0.slice(1));
    return false;
  }
}

function $f_error_defs$(ds_0) {
  if (ds_0.$ === "Nil") {
    return "";
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return run_jump($f_error_def_next$, [run_loop($f_error_terms$({$: "Con", ["head"]: run_loop($dt$(d_0)), ["tail"]: {$: "Con", ["head"]: run_loop($dv$(d_0)), ["tail"]: {$: "Nil"}}})), run_loop($dc$(d_0)), rest_0]);
  }
}

function $Bool$not$(b_0) {
  if (!b_0) {
    return true;
  } else {
    return false;
  }
}

function $f_source_path$(source_0) {
  const name_0 = source_0["name"];
  const path_0 = source_0["path"];
  const text_0 = source_0["text"];
  return path_0;
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

function $f_graph_cached$(s_0, ns_0, sources_0, g_0, stack_0, entry_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(entry_0)), "Absent")), run_clo((x_0) => {
  return run_jump($f_graph_parsed$, [s_0, ns_0, sources_0, g_0, {$: "Con", ["head"]: run_loop($f_source_path$(s_0)), ["tail"]: stack_0}, run_loop($f_parse$(run_loop($f_source_text$(s_0))))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($nm$(run_loop($kid$(entry_0, 0)))), ns_0)), run_clo((x_2) => {
  return g_0;
}), run_clo((x_3) => {
  const x_4 = run_loop($f_source_path$(s_0));
  return run_jump($f_graph_error$, [g_0, ("one namespace per source file: " + x_4)]);
})]);
})]);
}

function $f_env$(name_0, env_0) {
  if (env_0.$ === "Nil") {
    return run_jump($atom$, ["Absent"]);
  } else {
    const x_0 = env_0["head"];
    const xs_0 = env_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(name_0, run_loop($nm$(x_0)))), run_clo((x_1) => {
    return x_0;
}), run_clo((x_2) => {
    return run_jump($f_env$, [name_0, xs_0]);
})]);
  }
}

function $f_eq$(a_0, b_0) {
  return run_jump($String$eq$, [a_0, b_0]);
}

function $f_source_name$(source_0) {
  const name_0 = source_0["name"];
  const path_0 = source_0["path"];
  const text_0 = source_0["text"];
  return name_0;
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

function $String$eq$(a_0, b_0) {
  return run_jump($String$eq$fin$, [run_loop($String$cmp$(a_0, b_0))]);
}

function $check_event_done$(rest_0, done_0, d_0, err_0) {
  return run_jump($kc$, [run_loop($String$eq$(err_0, "")), run_clo((x_0) => {
  return run_jump($check_events$, [rest_0, {$: "Con", ["head"]: d_0, ["tail"]: run_loop($book_without$(done_0, run_loop($dn$(d_0))))}]);
}), run_clo((x_1) => {
  const x_2 = run_loop($dn$(d_0));
  const x_3 = (": " + err_0);
  return (x_2 + x_3);
})]);
}

function $check_definition$(book_0, d_0) {
  return run_jump($check_definition_type$, [book_0, d_0, {$: "KEnv", ["book"]: book_0, ["name"]: run_loop($dn$(d_0)), ["lhs"]: run_loop($ref$(run_loop($dn$(d_0)))), ["pending"]: 0, ["quantities"]: {$: "Nil"}, ["unsafe"]: run_loop($du$(d_0))}, run_loop($check$({$: "KEnv", ["book"]: book_0, ["name"]: run_loop($dn$(d_0)), ["lhs"]: run_loop($ref$(run_loop($dn$(d_0)))), ["pending"]: 0, ["quantities"]: {$: "Nil"}, ["unsafe"]: run_loop($du$(d_0))}, {$: "Nil"}, run_loop($dt$(d_0)), 0, run_loop($typ$(1))))]);
}

function $declared$(d_0) {
  return {$: "KDef", ["name"]: run_loop($dn$(d_0)), ["kind"]: run_loop($dk$(d_0)), ["arity"]: run_loop($da$(d_0)), ["templates"]: run_loop($dx$(d_0)), ["typ"]: run_loop($dt$(d_0)), ["value"]: run_loop($atom$("Absent")), ["ctors"]: run_loop($dc$(d_0)), ["native"]: run_loop($db$(d_0)), ["unsafe"]: run_loop($du$(d_0))};
}

function $book_without$(book_0, name_0) {
  if (book_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const h_0 = book_0["head"];
    const t_0 = book_0["tail"];
    return run_jump($kc$, [run_loop($String$eq$(run_loop($dn$(h_0)), name_0)), run_clo((x_0) => {
    return run_jump($book_without$, [t_0, name_0]);
}), run_clo((x_1) => {
    return {$: "Con", ["head"]: h_0, ["tail"]: run_loop($book_without$(t_0, name_0))};
})]);
  }
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

function $Bool$and$(a_0, b_0) {
  if (!a_0) {
    return false;
  } else {
    return b_0;
  }
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

function $missing$() {
  return {$: "KDef", ["name"]: "", ["kind"]: "Absent", ["arity"]: 0, ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: false, ["unsafe"]: false};
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

function $norm_max_terms$(ts_0) {
  if (ts_0.$ === "Nil") {
    return 0;
  } else {
    const h_0 = ts_0["head"];
    const t_0 = ts_0["tail"];
    return run_jump($norm_max$, [run_loop($norm_max_term$(h_0)), run_loop($norm_max_terms$(t_0))]);
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

function $f_fresh_def_type$(d_0, rest_0, r_0) {
  const ty_0 = r_0["term"];
  const next_0 = r_0["next"];
  return run_jump($f_fresh_def_value$, [d_0, rest_0, ty_0, run_loop($f_fresh_term$(run_loop($dv$(d_0)), {$: "Nil"}, next_0))]);
}

function $f_fresh_term$(t_0, env_0, next_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Var")), run_clo((x_0) => {
  return {$: "FFresh", ["term"]: run_loop($f_rename_var$(t_0, env_0)), ["next"]: next_0};
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "All")), run_clo((x_2) => {
  return run_jump($f_fresh_all$, [t_0, env_0, next_0, run_loop($f_fresh_term$(run_loop($kid$(t_0, 0)), env_0, ((next_0 + 1) >>> 0)))]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Lam")), run_clo((x_4) => {
  return run_jump($f_fresh_lam$, [t_0, next_0, run_loop($f_fresh_term$(run_loop($kid$(t_0, 0)), {$: "Con", ["head"]: run_loop($kt$("Map", "", run_loop($ix$(t_0)), 0, {$: "Con", ["head"]: run_loop($var$(run_loop($nm$(t_0)), next_0)), ["tail"]: {$: "Nil"}})), ["tail"]: env_0}, ((next_0 + 1) >>> 0)))]);
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Let")), run_clo((x_6) => {
  return run_jump($f_fresh_let$, [t_0, env_0, env_0, next_0, run_loop($ks$(t_0)), {$: "Nil"}]);
}), run_clo((x_7) => {
  return run_jump($f_fresh_generic$, [t_0, run_loop($f_fresh_terms$(run_loop($ks$(t_0)), env_0, next_0))]);
})]);
})]);
})]);
})]);
}

function $f_error_def_next$(err_0, ctors_0, rest_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($f_error_defs_more$, [run_loop($f_error_defs$(ctors_0)), rest_0]);
}), run_clo((x_1) => {
  return err_0;
})]);
}

function $f_error_terms$(ts_0) {
  if (ts_0.$ === "Nil") {
    return "";
  } else {
    const t_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return run_jump($f_error_more$, [run_loop($f_error_term$(t_0)), rest_0]);
  }
}

function $f_graph_parsed$(s_0, ns_0, sources_0, g_0, stack_0, r_0) {
  const book_0 = r_0["book"];
  const err_0 = r_0["error"];
  const imports_0 = r_0["imports"];
  return run_jump($f_choose$, [run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($f_graph_imports$, [s_0, ns_0, book_0, imports_0, imports_0, sources_0, g_0, stack_0]);
}), run_clo((x_1) => {
  return run_jump($f_graph_error$, [g_0, err_0]);
})]);
}

function $f_parse$(source_0) {
  return run_jump($f_tops$, [run_loop($f_lex$(source_0, 1, 0, 0, {$: "Nil"})), {$: "Nil"}, {$: "Nil"}, false]);
}

function $f_source_text$(source_0) {
  const name_0 = source_0["name"];
  const path_0 = source_0["path"];
  const text_0 = source_0["text"];
  return text_0;
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

function $kid$(t_0, n_0) {
  return run_jump($terms_at$, [run_loop($ks$(t_0)), n_0]);
}

function $f_graph_error$(g_0, err_0) {
  const book_0 = g_0["book"];
  const old_0 = g_0["error"];
  const done_0 = g_0["done"];
  return {$: "FGraph", ["book"]: book_0, ["error"]: err_0, ["done"]: done_0};
}

function $U32$show$(a_0) {
  const b_0 = a_0;
  return run_jump($U32$show$if$, [b_0, (b_0 === 0)]);
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

function $check$(e_0, ctx_0, t_0, dem_0, ty_0) {
  return run_jump($check_node$, [e_0, ctx_0, run_loop($core_beta$(t_0)), dem_0, ty_0]);
}

function $typ$(q_0) {
  return run_jump($kt$, ["Typ", "", 0, 0, {$: "Con", ["head"]: run_loop($qua$(q_0)), ["tail"]: {$: "Nil"}}]);
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
  return run_jump($norm_bound_found$, [book_0, run_loop($lookup$(book_0, "$kernel.max-id"))]);
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

function $f_fresh_def_value$(d_0, rest_0, ty_0, r_0) {
  const value_0 = r_0["term"];
  const next_0 = r_0["next"];
  return run_jump($f_fresh_def_ctors$, [d_0, rest_0, ty_0, value_0, run_loop($f_fresh_defs$(run_loop($dc$(d_0)), next_0))]);
}

function $f_rename_var$(t_0, env_0) {
  if (env_0.$ === "Nil") {
    return t_0;
  } else {
    const m_0 = env_0["head"];
    const ms_0 = env_0["tail"];
    const x_0 = run_loop($ix$(t_0));
    const x_1 = run_loop($ix$(m_0));
    return run_jump($f_choose$, [(x_0 === x_1), run_clo((x_2) => {
    return run_jump($kt$, ["Var", run_loop($nm$(t_0)), run_loop($ix$(run_loop($kid$(m_0, 0)))), run_loop($qt$(t_0)), {$: "Nil"}]);
}), run_clo((x_3) => {
    return run_jump($f_rename_var$, [t_0, ms_0]);
})]);
  }
}

function $f_fresh_all$(t_0, env_0, id_0, r_0) {
  const a_0 = r_0["term"];
  const next_0 = r_0["next"];
  return run_jump($f_fresh_all_body$, [t_0, id_0, a_0, run_loop($f_fresh_term$(run_loop($kid$(t_0, 1)), {$: "Con", ["head"]: run_loop($kt$("Map", "", run_loop($ix$(t_0)), 0, {$: "Con", ["head"]: run_loop($var$(run_loop($nm$(t_0)), id_0)), ["tail"]: {$: "Nil"}})), ["tail"]: env_0}, next_0))]);
}

function $f_fresh_lam$(t_0, id_0, r_0) {
  const b_0 = r_0["term"];
  const next_0 = r_0["next"];
  return {$: "FFresh", ["term"]: run_loop($kt$("Lam", run_loop($nm$(t_0)), id_0, run_loop($qt$(t_0)), {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}})), ["next"]: next_0};
}

function $var$(name_0, id_0) {
  return run_jump($kt$, ["Var", name_0, id_0, 0, {$: "Nil"}]);
}

function $f_fresh_let$(t_0, env_0, bodyenv_0, next_0, items_0, acc_0) {
  if (items_0.$ === "Nil") {
    return {$: "FFresh", ["term"]: run_loop($kt$("Error", "empty core let", 0, 0, {$: "Nil"})), ["next"]: next_0};
  } else {
    const x_0 = items_0["head"];
    const xs_0 = items_0["tail"];
    const x_1 = run_loop($f_len$(xs_0));
    return run_jump($f_choose$, [(x_1 === 0), run_clo((x_2) => {
    return run_jump($f_fresh_let_body$, [acc_0, run_loop($f_fresh_term$(x_0, bodyenv_0, next_0))]);
}), run_clo((x_3) => {
    return run_jump($f_fresh_let_value$, [t_0, env_0, bodyenv_0, next_0, x_0, xs_0, acc_0, run_loop($f_fresh_term$(run_loop($kid$(x_0, 0)), env_0, ((next_0 + 1) >>> 0)))]);
})]);
  }
}

function $f_fresh_generic$(t_0, r_0) {
  const ts_0 = r_0["terms"];
  const next_0 = r_0["next"];
  return {$: "FFresh", ["term"]: {$: "KTerm", ["tag"]: run_loop($tg$(t_0)), ["name"]: run_loop($nm$(t_0)), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: ts_0, ["removed"]: run_loop($rm$(t_0))}, ["next"]: next_0};
}

function $f_fresh_terms$(ts_0, env_0, next_0) {
  if (ts_0.$ === "Nil") {
    return {$: "FFreshTerms", ["terms"]: {$: "Nil"}, ["next"]: next_0};
  } else {
    const t_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return run_jump($f_fresh_cons$, [run_loop($f_fresh_term$(t_0, env_0, next_0)), rest_0, env_0]);
  }
}

function $f_error_defs_more$(err_0, rest_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($f_error_defs$, [rest_0]);
}), run_clo((x_1) => {
  return err_0;
})]);
}

function $f_error_more$(err_0, rest_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($f_error_terms$, [rest_0]);
}), run_clo((x_1) => {
  return err_0;
})]);
}

function $f_error_term$(t_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Error")), run_clo((x_0) => {
  return run_jump($nm$, [t_0]);
}), run_clo((x_1) => {
  return run_jump($f_error_terms$, [run_loop($ks$(t_0))]);
})]);
}

function $f_graph_imports$(s_0, ns_0, book_0, allimports_0, imports_0, sources_0, g_0, stack_0) {
  if (imports_0.$ === "Nil") {
    return run_jump($f_graph_finish$, [s_0, ns_0, book_0, run_loop($f_graph_aliases$(allimports_0, ns_0)), g_0]);
  } else {
    const im_0 = imports_0["head"];
    const rest_0 = imports_0["tail"];
    return run_jump($f_graph_imports$, [s_0, ns_0, book_0, allimports_0, rest_0, sources_0, run_loop($f_graph_load$(run_loop($f_import_pathname$(im_0, s_0, sources_0)), run_loop($f_import_namespace$(im_0, ns_0)), sources_0, g_0, stack_0)), stack_0]);
  }
}

function $f_tops$(ts0_0, book_0, imports_0, unsafe_0) {
  return run_jump($f_top$, [run_loop($f_skip$(ts0_0)), book_0, imports_0, unsafe_0]);
}

function $f_lex$(s_0, l_0, c_0, d_0, acc_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_0) => {
  return run_jump($List$reverse$, [acc_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\n")), run_clo((x_2) => {
  return run_jump($f_lex$, [run_loop($f_tail$(s_0)), ((l_0 + 1) >>> 0), 0, d_0, run_loop($f_choose$((d_0 === 0), run_clo((x_3) => {
  return {$: "Con", ["head"]: {$: "FToken", ["text"]: "\n", ["f_line"]: l_0, ["f_col"]: c_0, ["f_kind"]: 0}, ["tail"]: acc_0};
}), run_clo((x_4) => {
  return acc_0;
})))]);
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($Char$is_space$(run_loop($f_head$(s_0)))), run_clo((x_6) => {
  return run_jump($f_lex$, [run_loop($f_tail$(s_0)), l_0, ((c_0 + 1) >>> 0), d_0, acc_0]);
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "#")), run_clo((x_8) => {
  return run_jump($f_lex$, [run_loop($f_scan_comment$(s_0)), l_0, c_0, d_0, acc_0]);
}), run_clo((x_9) => {
  const x_10 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\""));
  const x_11 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "'"));
  return run_jump($f_choose$, [(x_10 || x_11), run_clo((x_12) => {
  return run_jump($f_lex_scanned$, [run_loop($f_scan_quote$(run_loop($f_tail$(s_0)), run_loop($f_head$(s_0)), (run_loop($f_head$(s_0)) + ""), 1)), l_0, c_0, d_0, 2, acc_0]);
}), run_clo((x_13) => {
  return run_jump($f_choose$, [run_loop($f_triple_op$(s_0)), run_clo((x_14) => {
  return run_jump($f_lex$, [run_loop($f_tail$(run_loop($f_tail$(run_loop($f_tail$(s_0)))))), l_0, ((c_0 + 3) >>> 0), d_0, {$: "Con", ["head"]: {$: "FToken", ["text"]: run_loop($f_three$(s_0)), ["f_line"]: l_0, ["f_col"]: c_0, ["f_kind"]: 0}, ["tail"]: acc_0}]);
}), run_clo((x_15) => {
  return run_jump($f_choose$, [run_loop($f_ident$(run_loop($f_head$(s_0)))), run_clo((x_16) => {
  return run_jump($f_lex_scanned$, [run_loop($f_scan_word$(s_0, "", 0)), l_0, c_0, d_0, 1, acc_0]);
}), run_clo((x_17) => {
  return run_jump($f_lex_symbol$, [s_0, l_0, c_0, d_0, acc_0]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
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

function $U32$show$if$(a_0, z_0) {
  if (z_0) {
    return "0";
  } else {
    return run_jump($U32$show$go$, [10n, a_0, ""]);
  }
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

function $good$(r_0) {
  return run_jump($String$eq$, [run_loop($ce$(r_0)), ""]);
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

function $ce$(r_0) {
  const term_0 = r_0["term"];
  const typ_0 = r_0["typ"];
  const uses_0 = r_0["uses"];
  const error_0 = r_0["error"];
  return error_0;
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

function $qua$(q_0) {
  return run_jump($kt$, ["Qua", "", 0, q_0, {$: "Nil"}]);
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

function $wnf$(book_0, t_0) {
  return run_jump($norm_eval$, [book_0, t_0, {$: "Nil"}, 0, run_loop($atom$("Absent"))]);
}

function $norm_bound_found$(book_0, stamp_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($dk$(stamp_0)), "BookBound")), run_clo((x_0) => {
  return run_jump($da$, [stamp_0]);
}), run_clo((x_1) => {
  return run_jump($norm_max_book$, [book_0]);
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

function $rm$(t_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const id_0 = t_0["id"];
  const quant_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return removed_0;
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

function $f_fresh_def_ctors$(d_0, rest_0, ty_0, value_0, r_0) {
  const ctors_0 = r_0["defs"];
  const next_0 = r_0["next"];
  return run_jump($f_fresh_defs_prepend$, [{$: "KDef", ["name"]: run_loop($dn$(d_0)), ["kind"]: run_loop($dk$(d_0)), ["arity"]: run_loop($da$(d_0)), ["templates"]: run_loop($dx$(d_0)), ["typ"]: ty_0, ["value"]: value_0, ["ctors"]: ctors_0, ["native"]: run_loop($db$(d_0)), ["unsafe"]: run_loop($du$(d_0))}, run_loop($f_fresh_defs$(rest_0, next_0))]);
}

function $f_fresh_all_body$(t_0, id_0, a_0, r_0) {
  const b_0 = r_0["term"];
  const next_0 = r_0["next"];
  return {$: "FFresh", ["term"]: run_loop($kt$("All", run_loop($nm$(t_0)), id_0, run_loop($qt$(t_0)), {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}})), ["next"]: next_0};
}

function $f_len$(xs_0) {
  if (xs_0.$ === "Nil") {
    return 0;
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    const x_1 = run_loop($f_len$(xt_0));
    return ((1 + x_1) >>> 0);
  }
}

function $f_fresh_let_body$(acc_0, r_0) {
  const body_0 = r_0["term"];
  const next_0 = r_0["next"];
  return {$: "FFresh", ["term"]: run_loop($kt$("Let", "", 0, 1, run_loop($f_concat$(run_loop($List$reverse$(acc_0)), {$: "Con", ["head"]: body_0, ["tail"]: {$: "Nil"}})))), ["next"]: next_0};
}

function $f_fresh_let_value$(t_0, env_0, bodyenv_0, id_0, binding_0, rest_0, acc_0, r_0) {
  const value_0 = r_0["term"];
  const next_0 = r_0["next"];
  return run_jump($f_fresh_let$, [t_0, env_0, {$: "Con", ["head"]: run_loop($kt$("Map", "", run_loop($ix$(binding_0)), 0, {$: "Con", ["head"]: run_loop($var$(run_loop($nm$(binding_0)), id_0)), ["tail"]: {$: "Nil"}})), ["tail"]: bodyenv_0}, next_0, rest_0, {$: "Con", ["head"]: run_loop($kt$("Bind", run_loop($nm$(binding_0)), id_0, run_loop($qt$(binding_0)), {$: "Con", ["head"]: value_0, ["tail"]: {$: "Nil"}})), ["tail"]: acc_0}]);
}

function $f_fresh_cons$(r_0, rest_0, env_0) {
  const t_0 = r_0["term"];
  const next_0 = r_0["next"];
  return run_jump($f_fresh_prepend$, [t_0, run_loop($f_fresh_terms$(rest_0, env_0, next_0))]);
}

function $f_graph_finish$(s_0, ns_0, book_0, imports_0, g_0) {
  const prior_0 = g_0["book"];
  const err_0 = g_0["error"];
  const done_0 = g_0["done"];
  return run_jump($f_graph_finish_alias$, [s_0, ns_0, run_loop($f_alias_defs$(book_0, imports_0)), imports_0, prior_0, err_0, done_0]);
}

function $f_graph_aliases$(imports_0, ns_0) {
  if (imports_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const im_0 = imports_0["head"];
    const rest_0 = imports_0["tail"];
    return {$: "Con", ["head"]: run_loop($kt$("Import", run_loop($f_import_namespace$(im_0, ns_0)), 0, 0, run_loop($ks$(im_0)))), ["tail"]: run_loop($f_graph_aliases$(rest_0, ns_0))};
  }
}

function $f_import_pathname$(im_0, s_0, sources_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($nm$(im_0)), "Base")), run_clo((x_0) => {
  return run_jump($f_source_path$, [run_loop($f_source$("Base", sources_0))]);
}), run_clo((x_1) => {
  return run_jump($f_path_normal$, [run_loop($f_path_join$(run_loop($f_path_dir$(run_loop($f_source_path$(s_0)))), run_loop($nm$(im_0))))]);
})]);
}

function $f_import_namespace$(im_0, ns_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($nm$(im_0)), "Base")), run_clo((x_0) => {
  return "";
}), run_clo((x_1) => {
  return run_jump($f_strip_bend$, [run_loop($f_path_normal$(run_loop($f_path_join$(run_loop($f_path_dir$(ns_0)), run_loop($nm$(im_0))))))]);
})]);
}

function $f_top$(ts_0, book_0, imports_0, unsafe_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<eof>")), run_clo((x_0) => {
  return run_jump($f_result$, [book_0, "", imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "@")), run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), "unsafe")))), run_clo((x_2) => {
  return run_jump($f_tops$, [run_loop($f_tl$(run_loop($f_tl$(ts_0)))), book_0, imports_0, true]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "import")), run_clo((x_4) => {
  return run_jump($f_import$, [run_loop($f_tl$(ts_0)), book_0, imports_0]);
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "law")), run_clo((x_6) => {
  return run_jump($f_law$, [run_loop($f_tx$(run_loop($f_tl$(ts_0)))), run_loop($f_skip$(run_loop($f_tl$(run_loop($f_tl$(run_loop($f_tl$(ts_0)))))))), book_0, imports_0, {$: "Nil"}]);
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "def")), run_clo((x_8) => {
  return run_jump($f_def$, [run_loop($f_tx$(run_loop($f_tl$(ts_0)))), run_loop($f_tele$(run_loop($f_tl$(run_loop($f_tl$(run_loop($f_tl$(ts_0)))))), ")", {$: "Nil"})), book_0, imports_0, unsafe_0]);
}), run_clo((x_9) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "type")), run_clo((x_10) => {
  return run_jump($f_type$, [run_loop($f_tx$(run_loop($f_tl$(ts_0)))), run_loop($f_tl$(run_loop($f_tl$(ts_0)))), book_0, imports_0]);
}), run_clo((x_11) => {
  return run_jump($f_result$, [book_0, run_loop($nm$(run_loop($f_pn$(run_loop($f_err$(ts_0, "expected def, law, type or import")))))), imports_0]);
})]);
})]);
})]);
})]);
})]);
})]);
}

function $f_skip$(ts_0) {
  const x_0 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "\n"));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), ";"));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return run_jump($f_skip$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_3) => {
  return ts_0;
})]);
}

function $List$reverse$(xs_0) {
  return run_jump($List$reverse$go$, [xs_0, {$: "Nil"}]);
}

function $Char$is_eq$(a_0, b_0) {
  const x_0 = a_0.codePointAt(0);
  const y_0 = b_0.codePointAt(0);
  return (x_0 === y_0);
}

function $f_head$(s_0) {
  if (s_0 === "") {
    return "\u0000";
  } else {
    const h_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(0, 2) : s_0[0]);
    const t_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(2) : s_0.slice(1));
    return h_0;
  }
}

function $f_tail$(s_0) {
  if (s_0 === "") {
    return "";
  } else {
    const h_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(0, 2) : s_0[0]);
    const t_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(2) : s_0.slice(1));
    return t_0;
  }
}

function $Char$is_space$(c_0) {
  const x_0 = c_0.codePointAt(0);
  const x_1 = (x_0 === 32);
  const x_2 = run_loop($Bool$and$((x_0 >= 9), (x_0 <= 13)));
  return (x_1 || x_2);
}

function $f_scan_comment$(s_0) {
  const x_0 = run_loop($String$is_empty$(s_0));
  const x_1 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\n"));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return s_0;
}), run_clo((x_3) => {
  return run_jump($f_scan_comment$, [run_loop($f_tail$(s_0))]);
})]);
}

function $f_lex_scanned$(sc_0, l_0, c_0, d_0, k_0, acc_0) {
  const word_0 = sc_0["word"];
  const rest_0 = sc_0["rest"];
  const size_0 = sc_0["size"];
  return run_jump($f_choose$, [(size_0 === 0), run_clo((x_0) => {
  return run_jump($List$reverse$, [{$: "Con", ["head"]: {$: "FToken", ["text"]: "unterminated string", ["f_line"]: l_0, ["f_col"]: c_0, ["f_kind"]: 3}, ["tail"]: acc_0}]);
}), run_clo((x_1) => {
  return run_jump($f_lex$, [rest_0, l_0, ((c_0 + size_0) >>> 0), d_0, {$: "Con", ["head"]: {$: "FToken", ["text"]: word_0, ["f_line"]: l_0, ["f_col"]: c_0, ["f_kind"]: k_0}, ["tail"]: acc_0}]);
})]);
}

function $f_scan_quote$(s_0, quote_0, acc_0, n_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_0) => {
  return {$: "FScanned", ["word"]: "", ["rest"]: "", ["size"]: 0};
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), quote_0)), run_clo((x_2) => {
  return {$: "FScanned", ["word"]: run_loop($String$reverse$((quote_0 + acc_0))), ["rest"]: run_loop($f_tail$(s_0)), ["size"]: ((n_0 + 1) >>> 0)};
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\\")), run_clo((x_4) => {
  return run_jump($f_scan_quote$, [run_loop($f_tail$(run_loop($f_tail$(s_0)))), quote_0, (run_loop($f_head$(run_loop($f_tail$(s_0)))) + ("\\" + acc_0)), ((n_0 + 2) >>> 0)]);
}), run_clo((x_5) => {
  return run_jump($f_scan_quote$, [run_loop($f_tail$(s_0)), quote_0, (run_loop($f_head$(s_0)) + acc_0), ((n_0 + 1) >>> 0)]);
})]);
})]);
})]);
}

function $f_triple_op$(s_0) {
  const x_0 = run_loop($f_eq$(run_loop($f_three$(s_0)), ".&."));
  const x_1 = run_loop($f_eq$(run_loop($f_three$(s_0)), ".|."));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($f_eq$(run_loop($f_three$(s_0)), ".^."));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($f_eq$(run_loop($f_three$(s_0)), "<&>"));
  return (x_4 || x_5);
}

function $f_three$(s_0) {
  return (run_loop($f_head$(s_0)) + (run_loop($f_head$(run_loop($f_tail$(s_0)))) + (run_loop($f_head$(run_loop($f_tail$(run_loop($f_tail$(s_0)))))) + "")));
}

function $f_ident$(c_0) {
  const x_0 = run_loop($Char$is_alpha$(c_0));
  const x_1 = run_loop($Char$is_digit$(c_0));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($Char$is_eq$(c_0, "_"));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($Char$is_eq$(c_0, "."));
  return (x_4 || x_5);
}

function $f_scan_word$(s_0, acc_0, n_0) {
  const x_0 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "+"));
  const x_1 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "-"));
  const x_2 = run_loop($Char$is_eq$(run_loop($f_head$(acc_0)), "e"));
  const x_3 = run_loop($Char$is_eq$(run_loop($f_head$(acc_0)), "E"));
  const x_4 = run_loop($f_ident$(run_loop($f_head$(s_0))));
  const x_5 = run_loop($Bool$and$(run_loop($Bool$and$((x_0 || x_1), (x_2 || x_3))), run_loop($Char$is_digit$(run_loop($f_head$(run_loop($f_tail$(s_0))))))));
  return run_jump($f_choose$, [(x_4 || x_5), run_clo((x_6) => {
  return run_jump($f_scan_word$, [run_loop($f_tail$(s_0)), (run_loop($f_head$(s_0)) + acc_0), ((n_0 + 1) >>> 0)]);
}), run_clo((x_7) => {
  return {$: "FScanned", ["word"]: run_loop($String$reverse$(acc_0)), ["rest"]: s_0, ["size"]: n_0};
})]);
}

function $f_lex_symbol$(s_0, l_0, c_0, d_0, acc_0) {
  return run_jump($f_choose$, [run_loop($f_pair_op$(run_loop($f_two$(s_0)))), run_clo((x_0) => {
  const x_1 = run_loop($f_tx$(acc_0));
  const x_2 = BigInt([...x_1].length);
  const x_3 = run_loop($f_col$(acc_0));
  const x_4 = Number(x_2 & 0xFFFFFFFFn);
  const x_5 = ((x_3 + x_4) >>> 0);
  return run_jump($f_lex$, [run_loop($f_tail$(run_loop($f_tail$(s_0)))), l_0, ((c_0 + 2) >>> 0), d_0, {$: "Con", ["head"]: {$: "FToken", ["text"]: run_loop($f_choose$(run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_two$(s_0)), ">>")), (c_0 > x_5))), run_clo((x_6) => {
  return ">>op";
}), run_clo((x_7) => {
  return run_jump($f_two$, [s_0]);
}))), ["f_line"]: l_0, ["f_col"]: c_0, ["f_kind"]: 0}, ["tail"]: acc_0}]);
}), run_clo((x_8) => {
  const x_9 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "("));
  const x_10 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "["));
  const x_11 = (x_9 || x_10);
  const x_12 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "{"));
  return run_jump($f_lex$, [run_loop($f_tail$(s_0)), l_0, ((c_0 + 1) >>> 0), run_loop($f_choose$((x_11 || x_12), run_clo((x_13) => {
  return ((d_0 + 1) >>> 0);
}), run_clo((x_14) => {
  const x_15 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), ")"));
  const x_16 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "]"));
  const x_17 = (x_15 || x_16);
  const x_18 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "}"));
  return run_jump($f_choose$, [(x_17 || x_18), run_clo((x_19) => {
  return ((d_0 - 1) >>> 0);
}), run_clo((x_20) => {
  return d_0;
})]);
}))), {$: "Con", ["head"]: {$: "FToken", ["text"]: run_loop($f_symbol_text$(s_0, c_0, acc_0)), ["f_line"]: l_0, ["f_col"]: c_0, ["f_kind"]: 0}, ["tail"]: acc_0}]);
})]);
}

function $U32$show$go$(f_0, n_0, acc_0) {
  if (f_0 === 0n) {
    return acc_0;
  } else {
    const g_0 = (f_0 - 1n);
    return run_jump($U32$show$fin$, [g_0, acc_0, n_0, (n_0 === 0)]);
  }
}

function $String$cmp$rec$(h1b_0, h2b_0, rr_0) {
  const _t_0 = rr_0["fst"];
  const t1b_0 = _t_0["fst"];
  const t2b_0 = _t_0["snd"];
  const r_0 = rr_0["snd"];
  return {$: "Tuple", ["fst"]: {$: "Tuple", ["fst"]: (h1b_0 + t1b_0), ["snd"]: (h2b_0 + t2b_0)}, ["snd"]: r_0};
}

function $tele_tip$(book_0, t_0) {
  return run_jump($tele_tip_head$, [book_0, run_loop($wnf$(book_0, t_0))]);
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

function $check_rwt$(e_0, ctx_0, t_0, dem_0, ty_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($check_rwt_type$, [e_0, ctx_0, t_0, dem_0, ty_0, r_0, run_loop($wnf$(run_loop($cb$(e_0)), run_loop($cy$(r_0))))]);
}), run_clo((x_1) => {
  return r_0;
})]);
}

function $infer$(e_0, ctx_0, t_0, dem_0, sp_0) {
  return run_jump($infer_node$, [e_0, ctx_0, run_loop($core_beta$(t_0)), dem_0, sp_0]);
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

function $app$(f_0, x_0) {
  return run_jump($kt$, ["App", "", 0, 0, {$: "Con", ["head"]: f_0, ["tail"]: {$: "Con", ["head"]: x_0, ["tail"]: {$: "Nil"}}}]);
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

function $norm_eval$(book_0, t_0, args_0, left_0, fallback_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "Var")), run_clo((x_0) => {
  return run_jump($norm_var$, [book_0, t_0, run_loop($ks$(t_0)), args_0, left_0, fallback_0]);
}), run_clo((x_1) => {
  return run_jump($norm_eval_node$, [book_0, t_0, args_0, left_0, fallback_0]);
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

function $f_fresh_defs_prepend$(d_0, r_0) {
  const ds_0 = r_0["defs"];
  const next_0 = r_0["next"];
  return {$: "FFreshDefs", ["defs"]: {$: "Con", ["head"]: d_0, ["tail"]: ds_0}, ["next"]: next_0};
}

function $f_concat$(xs_0, ys_0) {
  if (xs_0.$ === "Nil") {
    return ys_0;
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return {$: "Con", ["head"]: x_0, ["tail"]: run_loop($f_concat$(xt_0, ys_0))};
  }
}

function $f_fresh_prepend$(t_0, r_0) {
  const ts_0 = r_0["terms"];
  const next_0 = r_0["next"];
  return {$: "FFreshTerms", ["terms"]: {$: "Con", ["head"]: t_0, ["tail"]: ts_0}, ["next"]: next_0};
}

function $f_graph_finish_alias$(s_0, ns_0, book_0, imports_0, prior_0, err_0, done_0) {
  return {$: "FGraph", ["book"]: run_loop($f_defs_append$(prior_0, run_loop($f_path_defs$(run_loop($f_qual_optional$(run_loop($f_elab_defs$(book_0, run_loop($f_family_book$(run_loop($f_defs_append$(book_0, prior_0)))))), book_0, ns_0, imports_0)), run_loop($f_path_dir$(run_loop($f_source_path$(s_0)))), run_loop($f_eq$(run_loop($f_source_name$(s_0)), "Base")))))), ["error"]: err_0, ["done"]: {$: "Con", ["head"]: run_loop($kt$("Loaded", run_loop($f_source_path$(s_0)), 0, 0, {$: "Con", ["head"]: run_loop($ref$(ns_0)), ["tail"]: {$: "Nil"}})), ["tail"]: done_0}};
}

function $f_alias_defs$(ds_0, imports_0) {
  if (ds_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return {$: "Con", ["head"]: {$: "KDef", ["name"]: run_loop($dn$(d_0)), ["kind"]: run_loop($dk$(d_0)), ["arity"]: run_loop($da$(d_0)), ["templates"]: run_loop($dx$(d_0)), ["typ"]: run_loop($f_alias_term$(run_loop($dt$(d_0)), imports_0)), ["value"]: run_loop($f_alias_term$(run_loop($dv$(d_0)), imports_0)), ["ctors"]: run_loop($f_alias_defs$(run_loop($dc$(d_0)), imports_0)), ["native"]: run_loop($db$(d_0)), ["unsafe"]: run_loop($du$(d_0))}, ["tail"]: run_loop($f_alias_defs$(rest_0, imports_0))};
  }
}

function $f_source$(name_0, sources_0) {
  if (sources_0.$ === "Nil") {
    return {$: "FSource", ["name"]: "", ["path"]: "", ["text"]: ""};
  } else {
    const source_0 = sources_0["head"];
    const rest_0 = sources_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(name_0, run_loop($f_source_name$(source_0)))), run_clo((x_0) => {
    return source_0;
}), run_clo((x_1) => {
    return run_jump($f_source$, [name_0, rest_0]);
})]);
  }
}

function $f_path_normal$(s_0) {
  return run_jump($f_path_parts$, [s_0, "", {$: "Nil"}, run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "/"))]);
}

function $f_path_join$(dir_0, path_0) {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(path_0)), "/")), run_clo((x_0) => {
  return path_0;
}), run_clo((x_1) => {
  return (dir_0 + path_0);
})]);
}

function $f_path_dir$(path_0) {
  return run_jump($f_path_scan$, [path_0, "", ""]);
}

function $f_strip_bend$(s_0) {
  return run_jump($String$reverse$, [run_loop($f_drop_chars$(run_loop($String$reverse$(s_0)), 5))]);
}

function $f_tx$(ts_0) {
  if (ts_0.$ === "Nil") {
    return "<eof>";
  } else {
    const _t_0 = ts_0["head"];
    const t_0 = _t_0["text"];
    const l_0 = _t_0["f_line"];
    const c_0 = _t_0["f_col"];
    const k_0 = _t_0["f_kind"];
    const rest_0 = ts_0["tail"];
    return t_0;
  }
}

function $f_result$(book_0, err_0, imports_0) {
  return {$: "FResult", ["book"]: run_loop($List$reverse$(book_0)), ["error"]: err_0, ["imports"]: run_loop($List$reverse$(imports_0))};
}

function $f_tl$(ts_0) {
  if (ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const t_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return rest_0;
  }
}

function $f_import$(ts_0, book_0, imports_0) {
  return run_jump($f_import_path$, [ts_0, "", book_0, imports_0]);
}

function $f_law$(name_0, ts_0, book_0, imports_0, clauses_0) {
  const x_0 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "for"));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "exs"));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return run_jump($f_law_clause$, [name_0, run_loop($f_eq$(run_loop($f_tx$(ts_0)), "exs")), run_loop($f_tl$(ts_0)), book_0, imports_0, clauses_0]);
}), run_clo((x_3) => {
  return run_jump($f_law_end$, [name_0, run_loop($f_expr$(ts_0, 0)), book_0, imports_0, run_loop($List$reverse$(clauses_0))]);
})]);
}

function $f_def$(name_0, p_0, book_0, imports_0, unsafe_0) {
  return run_jump($f_choose$, [run_loop($f_reserved$(name_0)), run_clo((x_0) => {
  return run_jump($f_result$, [book_0, ("reserved definition name: " + name_0), imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_def_base$, [name_0, p_0, book_0, imports_0, unsafe_0]);
})]);
}

function $f_tele$(ts0_0, end_0, acc_0) {
  return run_jump($f_tele_at$, [run_loop($f_skip$(ts0_0)), end_0, acc_0]);
}

function $f_type$(name_0, ts_0, book_0, imports_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<>")), run_clo((x_0) => {
  return run_jump($f_type_params$, [name_0, {$: "FParsed", ["term"]: run_loop($kt$("Tele", "", 0, 0, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))}, book_0, imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_type_base$, [name_0, ts_0, book_0, imports_0]);
})]);
}

function $f_pn$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return n_0;
}

function $f_err$(ts_0, msg_0) {
  const x_0 = run_loop($f_tx$(ts_0));
  const x_1 = ("; got " + x_0);
  const x_2 = (msg_0 + x_1);
  const x_3 = run_loop($U32$show$(run_loop($f_col$(ts_0))));
  const x_4 = (": " + x_2);
  const x_5 = (x_3 + x_4);
  const x_6 = run_loop($U32$show$(run_loop($f_line$(ts_0))));
  const x_7 = (":" + x_5);
  const x_8 = (x_6 + x_7);
  return {$: "FParsed", ["term"]: run_loop($kt$("Error", ("line " + x_8), 0, 0, {$: "Nil"})), ["rest"]: {$: "Nil"}};
}

function $List$reverse$go$(xs_0, acc_0) {
  if (xs_0.$ === "Nil") {
    return acc_0;
  } else {
    const h_0 = xs_0["head"];
    const t_0 = xs_0["tail"];
    return run_jump($List$reverse$go$, [t_0, {$: "Con", ["head"]: h_0, ["tail"]: acc_0}]);
  }
}

function $String$reverse$(s_0) {
  return run_jump($String$reverse$go$, [s_0, ""]);
}

function $Char$is_alpha$(c_0) {
  const x_0 = run_loop($Char$is_upper$(c_0));
  const x_1 = run_loop($Char$is_lower$(c_0));
  return (x_0 || x_1);
}

function $Char$is_digit$(c_0) {
  const x_0 = c_0.codePointAt(0);
  return run_jump($Bool$and$, [(x_0 >= 48), (x_0 <= 57)]);
}

function $f_pair_op$(s_0) {
  const x_0 = run_loop($f_eq$(s_0, "->"));
  const x_1 = run_loop($f_eq$(s_0, "=>"));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($f_eq$(s_0, "<-"));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($f_eq$(s_0, "++"));
  const x_6 = (x_4 || x_5);
  const x_7 = run_loop($f_eq$(s_0, "<>"));
  const x_8 = (x_6 || x_7);
  const x_9 = run_loop($f_eq$(s_0, "=="));
  const x_10 = (x_8 || x_9);
  const x_11 = run_loop($f_eq$(s_0, "!="));
  const x_12 = (x_10 || x_11);
  const x_13 = run_loop($f_eq$(s_0, "<="));
  const x_14 = (x_12 || x_13);
  const x_15 = run_loop($f_eq$(s_0, ">="));
  const x_16 = (x_14 || x_15);
  const x_17 = run_loop($f_eq$(s_0, "&&"));
  const x_18 = (x_16 || x_17);
  const x_19 = run_loop($f_eq$(s_0, "||"));
  const x_20 = (x_18 || x_19);
  const x_21 = run_loop($f_eq$(s_0, "<<"));
  const x_22 = (x_20 || x_21);
  const x_23 = run_loop($f_eq$(s_0, ">>"));
  return (x_22 || x_23);
}

function $f_two$(s_0) {
  return (run_loop($f_head$(s_0)) + (run_loop($f_head$(run_loop($f_tail$(s_0)))) + ""));
}

function $f_col$(ts_0) {
  if (ts_0.$ === "Nil") {
    return 0;
  } else {
    const _t_0 = ts_0["head"];
    const t_0 = _t_0["text"];
    const l_0 = _t_0["f_line"];
    const c_0 = _t_0["f_col"];
    const k_0 = _t_0["f_kind"];
    const rest_0 = ts_0["tail"];
    return c_0;
  }
}

function $f_symbol_text$(s_0, c_0, acc_0) {
  const x_0 = run_loop($f_tx$(acc_0));
  const x_1 = BigInt([...x_0].length);
  const x_2 = run_loop($f_col$(acc_0));
  const x_3 = Number(x_1 & 0xFFFFFFFFn);
  const x_4 = ((x_2 + x_3) >>> 0);
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "+")), run_loop($Char$is_alpha$(run_loop($f_head$(run_loop($f_tail$(s_0)))))))), run_loop($Bool$not$(run_loop($Bool$and$(run_loop($String$ends_with$(run_loop($f_tx$(acc_0)), "n")), (x_4 === c_0))))))), run_clo((x_5) => {
  return "+bind";
}), run_clo((x_6) => {
  const x_7 = run_loop($f_tx$(acc_0));
  const x_8 = BigInt([...x_7].length);
  const x_9 = run_loop($f_col$(acc_0));
  const x_10 = Number(x_8 & 0xFFFFFFFFn);
  const x_11 = ((x_9 + x_10) >>> 0);
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Char$is_eq$(run_loop($f_head$(s_0)), ">")), (c_0 > x_11))), run_clo((x_12) => {
  return ">op";
}), run_clo((x_13) => {
  return (run_loop($f_head$(s_0)) + "");
})]);
})]);
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

function $strip$(t_0) {
  return run_jump($core_force$, [t_0]);
}

function $tele_quantities_head$(book_0, ty_0, n_0) {
  return {$: "Con", ["head"]: run_loop($qua$(run_loop($kc$(run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
  return run_jump($qt$, [ty_0]);
}), run_clo((x_1) => {
  return 1;
}))))), ["tail"]: run_loop($tele_quantities$(book_0, run_loop($kid$(ty_0, 1)), ((n_0 - 1) >>> 0)))};
}

function $check_template_open$(book_0, d_0, ty_0, body_0, lhs_0, n_0, name_0) {
  return run_jump($check_template_definition$, [{$: "Con", ["head"]: {$: "KDef", ["name"]: name_0, ["kind"]: "Def", ["arity"]: 0, ["templates"]: 0, ["typ"]: run_loop($kid$(ty_0, 0)), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: true, ["unsafe"]: false}, ["tail"]: book_0}, d_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), run_loop($ref$(name_0)))), run_loop($kapply$(body_0, run_loop($ref$(name_0)))), run_loop($app$(lhs_0, run_loop($ref$(name_0)))), ((n_0 - 1) >>> 0)]);
}

function $check_lam_q$(e_0, ctx_0, t_0, dem_0, ty_0, q_0) {
  return run_jump($check_lam_done$, [t_0, ty_0, q_0, run_loop($both$(run_loop($check$(e_0, ctx_0, run_loop($kid$(ty_0, 0)), 0, run_loop($typ$(run_loop($kindq$(e_0, q_0)))))), run_loop($check$(run_loop($lhs_step$(e_0, run_loop($var$(run_loop($nm$(t_0)), run_loop($ix$(t_0)))))), run_loop($ctx_bind$(ctx_0, run_loop($ix$(t_0)), q_0, run_loop($nm$(t_0)), run_loop($kid$(ty_0, 0)))), run_loop($kid$(t_0, 0)), dem_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), run_loop($var$(run_loop($nm$(t_0)), run_loop($ix$(t_0)))))))), t_0, ty_0, false))]);
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

function $ok$(t_0, ty_0, us_0) {
  return {$: "KChecked", ["term"]: t_0, ["typ"]: ty_0, ["uses"]: us_0, ["error"]: ""};
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

function $checked$(r_0, t_0, ty_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($ok$, [t_0, ty_0, run_loop($cs$(r_0))]);
}), run_clo((x_1) => {
  return r_0;
})]);
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

function $f_defs_append$(xs_0, ys_0) {
  if (xs_0.$ === "Nil") {
    return ys_0;
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return {$: "Con", ["head"]: x_0, ["tail"]: run_loop($f_defs_append$(xt_0, ys_0))};
  }
}

function $f_path_defs$(ds_0, dir_0, native_0) {
  if (ds_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    const x_2 = run_loop($db$(d_0));
    return {$: "Con", ["head"]: {$: "KDef", ["name"]: run_loop($dn$(d_0)), ["kind"]: run_loop($dk$(d_0)), ["arity"]: run_loop($da$(d_0)), ["templates"]: run_loop($dx$(d_0)), ["typ"]: run_loop($dt$(d_0)), ["value"]: run_loop($f_choose$(run_loop($f_eq$(run_loop($tg$(run_loop($dv$(d_0)))), "Foreign")), run_clo((x_0) => {
    return run_jump($f_path_term$, [run_loop($dv$(d_0)), dir_0]);
}), run_clo((x_1) => {
    return run_jump($dv$, [d_0]);
}))), ["ctors"]: run_loop($f_path_defs$(run_loop($dc$(d_0)), dir_0, native_0)), ["native"]: (native_0 || x_2), ["unsafe"]: run_loop($du$(d_0))}, ["tail"]: run_loop($f_path_defs$(rest_0, dir_0, native_0))};
  }
}

function $f_qual_optional$(defs_0, book_0, ns_0, imports_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(ns_0)), run_clo((x_0) => {
  return defs_0;
}), run_clo((x_1) => {
  return run_jump($f_qual_defs$, [defs_0, book_0, ns_0, imports_0]);
})]);
}

function $f_elab_defs$(ds_0, book_0) {
  if (ds_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_elab_def$(d_0, book_0)), ["tail"]: run_loop($f_elab_defs$(rest_0, book_0))};
  }
}

function $f_family_book$(book_0) {
  if (book_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const d_0 = book_0["head"];
    const rest_0 = book_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(run_loop($dk$(d_0)), "ADT")), run_clo((x_0) => {
    return {$: "Con", ["head"]: d_0, ["tail"]: run_loop($f_family_book$(rest_0))};
}), run_clo((x_1) => {
    return run_jump($f_family_book$, [rest_0]);
})]);
  }
}

function $f_alias_term$(t_0, imports_0) {
  const x_0 = run_loop($f_eq$(run_loop($tg$(t_0)), "Ref"));
  const x_1 = run_loop($f_eq$(run_loop($tg$(t_0)), "ADT"));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($f_eq$(run_loop($tg$(t_0)), "Ctr"));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($f_eq$(run_loop($tg$(t_0)), "Mat"));
  return {$: "KTerm", ["tag"]: run_loop($tg$(t_0)), ["name"]: run_loop($f_choose$((x_4 || x_5), run_clo((x_6) => {
  return run_jump($f_alias$, [run_loop($nm$(t_0)), imports_0]);
}), run_clo((x_7) => {
  return run_jump($nm$, [t_0]);
}))), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: run_loop($f_alias_terms$(run_loop($ks$(t_0)), imports_0)), ["removed"]: run_loop($rm$(t_0))};
}

function $f_path_parts$(s_0, part_0, parts_0, abs_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_0) => {
  return run_jump($f_path_join_parts$, [run_loop($List$reverse$(run_loop($f_path_push$(part_0, parts_0)))), run_loop($f_choose$(abs_0, run_clo((x_1) => {
  return "/";
}), run_clo((x_2) => {
  return "";
})))]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "/")), run_clo((x_4) => {
  return run_jump($f_path_parts$, [run_loop($f_tail$(s_0)), "", run_loop($f_path_push$(part_0, parts_0)), abs_0]);
}), run_clo((x_5) => {
  const x_6 = (run_loop($f_head$(s_0)) + "");
  return run_jump($f_path_parts$, [run_loop($f_tail$(s_0)), (part_0 + x_6), parts_0, abs_0]);
})]);
})]);
}

function $f_path_scan$(path_0, acc_0, dir_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(path_0)), run_clo((x_0) => {
  return dir_0;
}), run_clo((x_1) => {
  const x_2 = (run_loop($f_head$(path_0)) + "");
  return run_jump($f_path_scan$, [run_loop($f_tail$(path_0)), (acc_0 + x_2), run_loop($f_choose$(run_loop($Char$is_eq$(run_loop($f_head$(path_0)), "/")), run_clo((x_3) => {
  return (acc_0 + "/");
}), run_clo((x_4) => {
  return dir_0;
})))]);
})]);
}

function $f_drop_chars$(s_0, n_0) {
  return run_jump($f_choose$, [(n_0 === 0), run_clo((x_0) => {
  return s_0;
}), run_clo((x_1) => {
  return run_jump($f_drop_chars$, [run_loop($f_tail$(s_0)), ((n_0 - 1) >>> 0)]);
})]);
}

function $f_import_path$(ts_0, path_0, book_0, imports_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "as")), run_clo((x_0) => {
  return run_jump($f_import_alias$, [ts_0, path_0, book_0, imports_0]);
}), run_clo((x_1) => {
  const x_2 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "\n"));
  const x_3 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<eof>"));
  return run_jump($f_choose$, [(x_2 || x_3), run_clo((x_4) => {
  return run_jump($f_choose$, [run_loop($f_eq$(path_0, "Base")), run_clo((x_5) => {
  return run_jump($f_tops$, [ts_0, book_0, {$: "Con", ["head"]: run_loop($kt$("Import", path_0, 0, 0, {$: "Nil"})), ["tail"]: imports_0}, false]);
}), run_clo((x_6) => {
  return run_jump($f_result$, [book_0, "a module import requires as followed by an alias", imports_0]);
})]);
}), run_clo((x_7) => {
  const x_8 = run_loop($f_tx$(ts_0));
  return run_jump($f_import_path$, [run_loop($f_tl$(ts_0)), (path_0 + x_8), book_0, imports_0]);
})]);
})]);
}

function $f_law_clause$(name_0, exi_0, ts_0, book_0, imports_0, clauses_0) {
  return run_jump($f_law_type$, [name_0, run_loop($kt$(run_loop($f_choose$(exi_0, run_clo((x_0) => {
  return "Exists";
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "~")), run_clo((x_2) => {
  return "Template";
}), run_clo((x_3) => {
  return "Bind";
})]);
}))), run_loop($f_tx$(run_loop($f_unmark$(ts_0)))), run_loop($f_atid$(ts_0)), run_loop($f_quant$(ts_0)), {$: "Nil"})), run_loop($f_expr$(run_loop($f_tl$(run_loop($f_tl$(run_loop($f_unmark$(ts_0)))))), 0)), book_0, imports_0, clauses_0]);
}

function $f_law_end$(name_0, p_0, book_0, imports_0, clauses_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(ty_0)), "Error")), run_clo((x_0) => {
  return run_jump($f_result$, [book_0, run_loop($nm$(ty_0)), imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_tops$, [ts_0, {$: "Con", ["head"]: {$: "KDef", ["name"]: name_0, ["kind"]: "Def", ["arity"]: run_loop($f_len$(clauses_0)), ["templates"]: run_loop($f_templates$(clauses_0)), ["typ"]: run_loop($f_law_bind$(clauses_0, ty_0)), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: false, ["unsafe"]: false}, ["tail"]: book_0}, imports_0, false]);
})]);
}

function $f_expr$(ts_0, min_0) {
  return run_jump($f_grow$, [run_loop($f_atom$(run_loop($f_skip$(ts_0)))), min_0]);
}

function $f_reserved$(s_0) {
  const x_0 = run_loop($f_eq$(s_0, "def"));
  const x_1 = run_loop($f_eq$(s_0, "type"));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($f_eq$(s_0, "law"));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($f_eq$(s_0, "match"));
  const x_6 = (x_4 || x_5);
  const x_7 = run_loop($f_eq$(s_0, "case"));
  const x_8 = (x_6 || x_7);
  const x_9 = run_loop($f_eq$(s_0, "do"));
  const x_10 = (x_8 || x_9);
  const x_11 = run_loop($f_eq$(s_0, "return"));
  const x_12 = (x_10 || x_11);
  const x_13 = run_loop($f_eq$(s_0, "for"));
  const x_14 = (x_12 || x_13);
  const x_15 = run_loop($f_eq$(s_0, "exs"));
  const x_16 = (x_14 || x_15);
  const x_17 = run_loop($f_eq$(s_0, "where"));
  const x_18 = (x_16 || x_17);
  const x_19 = run_loop($f_eq$(s_0, "is"));
  const x_20 = (x_18 || x_19);
  const x_21 = run_loop($f_eq$(s_0, "import"));
  const x_22 = (x_20 || x_21);
  const x_23 = run_loop($f_eq$(s_0, "Type"));
  const x_24 = (x_22 || x_23);
  const x_25 = run_loop($f_eq$(s_0, "Data"));
  const x_26 = (x_24 || x_25);
  const x_27 = run_loop($f_eq$(s_0, "Kind"));
  const x_28 = (x_26 || x_27);
  const x_29 = run_loop($f_eq$(s_0, "Quant"));
  return (x_28 || x_29);
}

function $f_def_base$(name_0, p_0, book_0, imports_0, unsafe_0) {
  const pars_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(pars_0)), "Error")), run_clo((x_0) => {
  return run_jump($f_result$, [book_0, run_loop($nm$(pars_0)), imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "->")), run_clo((x_2) => {
  return run_jump($f_def_type$, [name_0, run_loop($ks$(pars_0)), run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), book_0, imports_0, unsafe_0]);
}), run_clo((x_3) => {
  return run_jump($f_def_type$, [name_0, run_loop($ks$(pars_0)), {$: "FParsed", ["term"]: run_loop($f_dt$(run_loop($f_find$(name_0, book_0)))), ["rest"]: ts_0}, book_0, imports_0, unsafe_0]);
})]);
})]);
}

function $f_tele_at$(ts_0, end_0, acc_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), end_0)), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Tele", "", 0, 0, run_loop($List$reverse$(acc_0)))), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_1) => {
  return run_jump($f_validate_param$, [ts_0, end_0, acc_0]);
})]);
}

function $f_type_params$(name_0, p_0, book_0, imports_0) {
  const pars_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_type_kind$, [name_0, run_loop($ks$(pars_0)), run_loop($f_expect$(run_loop($f_expr$(run_loop($f_pr$(run_loop($f_expect$({$: "FParsed", ["term"]: pars_0, ["rest"]: ts_0}, "is")))), 0)), ":")), book_0, imports_0]);
}

function $f_type_base$(name_0, ts_0, book_0, imports_0) {
  const x_0 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<"));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<-"));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return run_jump($f_type_params$, [name_0, run_loop($f_tele$(run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<-")), run_clo((x_3) => {
  const x_4 = run_loop($f_col$(ts_0));
  return {$: "Con", ["head"]: {$: "FToken", ["text"]: "-", ["f_line"]: run_loop($f_line$(ts_0)), ["f_col"]: ((x_4 + 1) >>> 0), ["f_kind"]: 0}, ["tail"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_5) => {
  return run_jump($f_tl$, [ts_0]);
}))), ">", {$: "Nil"})), book_0, imports_0]);
}), run_clo((x_6) => {
  return run_jump($f_type_params$, [name_0, {$: "FParsed", ["term"]: run_loop($kt$("Tele", "", 0, 0, {$: "Nil"})), ["rest"]: ts_0}, book_0, imports_0]);
})]);
}

function $f_line$(ts_0) {
  if (ts_0.$ === "Nil") {
    return 0;
  } else {
    const _t_0 = ts_0["head"];
    const t_0 = _t_0["text"];
    const l_0 = _t_0["f_line"];
    const c_0 = _t_0["f_col"];
    const k_0 = _t_0["f_kind"];
    const rest_0 = ts_0["tail"];
    return l_0;
  }
}

function $String$reverse$go$(s_0, acc_0) {
  if (s_0 === "") {
    return acc_0;
  } else {
    const h_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(0, 2) : s_0[0]);
    const t_0 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(2) : s_0.slice(1));
    return run_jump($String$reverse$go$, [t_0, (h_0 + acc_0)]);
  }
}

function $Char$is_upper$(c_0) {
  const x_0 = c_0.codePointAt(0);
  return run_jump($Bool$and$, [(x_0 >= 65), (x_0 <= 90)]);
}

function $Char$is_lower$(c_0) {
  const x_0 = c_0.codePointAt(0);
  return run_jump($Bool$and$, [(x_0 >= 97), (x_0 <= 122)]);
}

function $String$ends_with$(s_0, p_0) {
  return run_jump($String$starts_with$, [run_loop($String$reverse$(s_0)), run_loop($String$reverse$(p_0))]);
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

function $kapply$(fn_0, x_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(run_loop($strip$(fn_0)))), "Lam")), run_clo((x_1) => {
  return run_jump($subst$, [run_loop($kid$(run_loop($strip$(fn_0)), 0)), run_loop($ix$(run_loop($strip$(fn_0)))), x_0]);
}), run_clo((x_2) => {
  return run_jump($app$, [fn_0, x_0]);
})]);
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

function $lhs_step$(e_0, x_0) {
  const x_1 = run_loop($cp$(e_0));
  return run_jump($kc$, [(x_1 === 0), run_clo((x_2) => {
  return e_0;
}), run_clo((x_3) => {
  const x_4 = run_loop($cp$(e_0));
  return {$: "KEnv", ["book"]: run_loop($cb$(e_0)), ["name"]: run_loop($cn$(e_0)), ["lhs"]: run_loop($kapply$(run_loop($cl$(e_0)), x_0)), ["pending"]: ((x_4 - 1) >>> 0), ["quantities"]: run_loop($cq$(e_0)), ["unsafe"]: run_loop($cu$(e_0))};
})]);
}

function $ctx_bind$(ctx_0, id_0, q_0, name_0, ty_0) {
  return {$: "Con", ["head"]: run_loop($kt$("Bind", name_0, id_0, q_0, {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}})), ["tail"]: ctx_0};
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

function $cs$(r_0) {
  const term_0 = r_0["term"];
  const typ_0 = r_0["typ"];
  const uses_0 = r_0["uses"];
  const error_0 = r_0["error"];
  return uses_0;
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

function $check_rwt_goal$(e_0, ctx_0, t_0, dem_0, ty_0, r_0, eq_0, fresh_0) {
  return run_jump($kc$, [run_loop($compare$(run_loop($cb$(e_0)), run_loop($kapply$(run_loop($kapply$(run_loop($kid$(t_0, 1)), run_loop($kid$(eq_0, 1)))), run_loop($kid$(t_0, 0)))), ty_0, true)), run_clo((x_0) => {
  return run_jump($both$, [r_0, run_loop($both$(run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), 0, run_loop($all$(1, "_", fresh_0, run_loop($kid$(eq_0, 2)), run_loop($all$(1, "e", ((fresh_0 + 1) >>> 0), run_loop($kt$("Eql", "", 0, 0, {$: "Con", ["head"]: run_loop($kid$(eq_0, 0)), ["tail"]: {$: "Con", ["head"]: run_loop($var$("_", fresh_0)), ["tail"]: {$: "Con", ["head"]: run_loop($kid$(eq_0, 2)), ["tail"]: {$: "Nil"}}}})), run_loop($typ$(1)))))))), run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 2)), dem_0, run_loop($kapply$(run_loop($kapply$(run_loop($kid$(t_0, 1)), run_loop($kid$(eq_0, 0)))), run_loop($atom$("Rfl")))))), t_0, ty_0, false)), t_0, ty_0, false]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["rewrite motive does not fit goal"]);
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

function $subst_node$(t_0, id_0, v_0) {
  const tag_0 = t_0["tag"];
  const name_0 = t_0["name"];
  const n_0 = t_0["id"];
  const q_0 = t_0["quant"];
  const kids_0 = t_0["kids"];
  const removed_0 = t_0["removed"];
  return run_jump($core_rebuild$, [{$: "KTerm", ["tag"]: tag_0, ["name"]: name_0, ["id"]: n_0, ["quant"]: q_0, ["kids"]: run_loop($subst_terms$(kids_0, id_0, v_0)), ["removed"]: removed_0}]);
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

function $f_path_term$(t_0, dir_0) {
  return {$: "KTerm", ["tag"]: run_loop($tg$(t_0)), ["name"]: run_loop($f_choose$(run_loop($f_eq$(run_loop($tg$(t_0)), "Path")), run_clo((x_0) => {
  return run_jump($f_path_join$, [dir_0, run_loop($nm$(t_0))]);
}), run_clo((x_1) => {
  return run_jump($nm$, [t_0]);
}))), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: run_loop($f_path_terms$(run_loop($ks$(t_0)), dir_0)), ["removed"]: run_loop($rm$(t_0))};
}

function $f_qual_defs$(ds_0, book_0, ns_0, imports_0) {
  if (ds_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const d_0 = ds_0["head"];
    const rest_0 = ds_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_qual_def$(d_0, book_0, ns_0, imports_0)), ["tail"]: run_loop($f_qual_defs$(rest_0, book_0, ns_0, imports_0))};
  }
}

function $f_elab_def$(d_0, book_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const ty_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return {$: "KDef", ["name"]: name_0, ["kind"]: kind_0, ["arity"]: arity_0, ["templates"]: templates_0, ["typ"]: run_loop($f_scope$(ty_0, {$: "Nil"}, book_0)), ["value"]: run_loop($f_scope$(value_0, {$: "Nil"}, book_0)), ["ctors"]: run_loop($f_elab_defs$(ctors_0, book_0)), ["native"]: native_0, ["unsafe"]: unsafe_0};
}

function $f_alias$(name_0, imports_0) {
  if (imports_0.$ === "Nil") {
    return name_0;
  } else {
    const im_0 = imports_0["head"];
    const rest_0 = imports_0["tail"];
    const x_0 = run_loop($f_len$(run_loop($ks$(im_0))));
    const x_1 = run_loop($nm$(run_loop($kid$(im_0, 0))));
    return run_jump($f_choose$, [run_loop($Bool$and$((x_0 > 0), run_loop($f_prefix$(name_0, (x_1 + "."))))), run_clo((x_2) => {
    const x_3 = run_loop($nm$(run_loop($kid$(im_0, 0))));
    const x_4 = run_loop($f_drop_prefix$(name_0, (x_3 + ".")));
    const x_5 = run_loop($nm$(im_0));
    const x_6 = ("." + x_4);
    return (x_5 + x_6);
}), run_clo((x_7) => {
    return run_jump($f_alias$, [name_0, rest_0]);
})]);
  }
}

function $f_alias_terms$(ts_0, imports_0) {
  if (ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const t_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_alias_term$(t_0, imports_0)), ["tail"]: run_loop($f_alias_terms$(rest_0, imports_0))};
  }
}

function $f_path_join_parts$(parts_0, acc_0) {
  if (parts_0.$ === "Nil") {
    return acc_0;
  } else {
    const part_0 = parts_0["head"];
    const rest_0 = parts_0["tail"];
    const x_0 = run_loop($String$is_empty$(acc_0));
    const x_1 = run_loop($f_eq$(acc_0, "/"));
    const x_4 = run_loop($f_choose$((x_0 || x_1), run_clo((x_2) => {
    return "";
}), run_clo((x_3) => {
    return "/";
})));
    const x_5 = (x_4 + part_0);
    return run_jump($f_path_join_parts$, [rest_0, (acc_0 + x_5)]);
  }
}

function $f_path_push$(part_0, parts_0) {
  const x_0 = run_loop($String$is_empty$(part_0));
  const x_1 = run_loop($f_eq$(part_0, "."));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return parts_0;
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(part_0, "..")), run_clo((x_4) => {
  return run_jump($f_path_parent$, [parts_0]);
}), run_clo((x_5) => {
  return {$: "Con", ["head"]: part_0, ["tail"]: parts_0};
})]);
})]);
}

function $f_import_alias$(ts_0, path_0, book_0, imports_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($String$ends_with$(path_0, ".bend")), run_loop($f_alias_valid$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))))))), run_clo((x_0) => {
  return run_jump($f_tops$, [run_loop($f_tl$(run_loop($f_tl$(ts_0)))), book_0, {$: "Con", ["head"]: run_loop($kt$("Import", path_0, 0, 0, {$: "Con", ["head"]: run_loop($kt$("Alias", run_loop($f_tx$(run_loop($f_tl$(ts_0)))), 0, 0, {$: "Nil"})), ["tail"]: {$: "Nil"}})), ["tail"]: imports_0}, false]);
}), run_clo((x_1) => {
  return run_jump($f_result$, [book_0, "an import requires a .bend path and a valid alias", imports_0]);
})]);
}

function $f_law_type$(name_0, binder_0, p_0, book_0, imports_0, clauses_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(ty_0)), "Error")), run_clo((x_0) => {
  return run_jump($f_result$, [book_0, run_loop($nm$(ty_0)), imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(run_loop($f_skip$(ts_0)))), "where")), run_clo((x_2) => {
  return run_jump($f_law_where$, [name_0, binder_0, ty_0, run_loop($f_expr$(run_loop($f_tl$(run_loop($f_skip$(ts_0)))), 0)), book_0, imports_0, clauses_0]);
}), run_clo((x_3) => {
  return run_jump($f_law$, [name_0, run_loop($f_skip$(ts_0)), book_0, imports_0, {$: "Con", ["head"]: run_loop($kt$(run_loop($tg$(binder_0)), run_loop($nm$(binder_0)), run_loop($ix$(binder_0)), run_loop($qt$(binder_0)), {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}})), ["tail"]: clauses_0}]);
})]);
})]);
}

function $f_unmark$(ts_0) {
  const x_0 = run_loop($f_quant$(ts_0));
  return run_jump($f_choose$, [(x_0 === 1), run_clo((x_1) => {
  return ts_0;
}), run_clo((x_2) => {
  return run_jump($f_tl$, [ts_0]);
})]);
}

function $f_atid$(ts_0) {
  const x_0 = run_loop($f_line$(ts_0));
  const x_1 = (Math.imul(x_0, 65536) >>> 0);
  const x_2 = run_loop($f_col$(ts_0));
  return ((x_1 + x_2) >>> 0);
}

function $f_quant$(ts_0) {
  const x_0 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "-"));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "~"));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return 0;
}), run_clo((x_3) => {
  const x_4 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "+"));
  const x_5 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "+bind"));
  return run_jump($f_choose$, [(x_4 || x_5), run_clo((x_6) => {
  return 2;
}), run_clo((x_7) => {
  return 1;
})]);
})]);
}

function $f_templates$(pars_0) {
  if (pars_0.$ === "Nil") {
    return 0;
  } else {
    const p_0 = pars_0["head"];
    const ps_0 = pars_0["tail"];
    const x_2 = run_loop($f_choose$(run_loop($f_eq$(run_loop($tg$(p_0)), "Template")), run_clo((x_0) => {
    return 1;
}), run_clo((x_1) => {
    return 0;
})));
    const x_3 = run_loop($f_templates$(ps_0));
    return ((x_2 + x_3) >>> 0);
  }
}

function $f_law_bind$(clauses_0, ty_0) {
  if (clauses_0.$ === "Nil") {
    return ty_0;
  } else {
    const c_0 = clauses_0["head"];
    const cs_0 = clauses_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(c_0)), "Exists")), run_clo((x_0) => {
    return run_jump($f_app$, [run_loop($kt$("Ref", "Exists", 0, 1, {$: "Nil"})), {$: "Con", ["head"]: run_loop($kid$(c_0, 0)), ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Lam", run_loop($nm$(c_0)), run_loop($ix$(c_0)), 1, {$: "Con", ["head"]: run_loop($f_law_bind$(cs_0, ty_0)), ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_1) => {
    return run_jump($kt$, ["All", run_loop($nm$(c_0)), run_loop($ix$(c_0)), run_loop($qt$(c_0)), {$: "Con", ["head"]: run_loop($kid$(c_0, 0)), ["tail"]: {$: "Con", ["head"]: run_loop($f_law_bind$(cs_0, ty_0)), ["tail"]: {$: "Nil"}}}]);
})]);
  }
}

function $f_grow$(p_0, min_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  const x_0 = run_loop($f_prec$(run_loop($f_tx$(run_loop($f_skip$(ts_0))))));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_skip$(ts_0)))), "%"));
  const x_2 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_skip$(ts_0)))), "-"));
  const x_3 = run_loop($f_col$(run_loop($f_skip$(ts_0))));
  const x_4 = run_loop($f_col$(run_loop($f_tl$(run_loop($f_skip$(ts_0))))));
  const x_5 = ((x_3 + 1) >>> 0);
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "\n")), (x_0 > 0))), run_loop($Bool$not$(run_loop($Bool$and$((x_1 || x_2), (x_4 === x_5))))))), run_clo((x_6) => {
  return run_jump($f_grow_base$, [{$: "FParsed", ["term"]: n_0, ["rest"]: run_loop($f_skip$(ts_0))}, min_0]);
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "!")), run_clo((x_8) => {
  return run_jump($f_grow$, [{$: "FParsed", ["term"]: run_loop($kt$(run_loop($tg$(n_0)), run_loop($nm$(n_0)), run_loop($ix$(n_0)), 3, run_loop($ks$(n_0)))), ["rest"]: run_loop($f_tl$(ts_0))}, min_0]);
}), run_clo((x_9) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "[")), run_clo((x_10) => {
  return run_jump($f_index$, [n_0, run_loop($f_expect$(run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), "]")), min_0]);
}), run_clo((x_11) => {
  return run_jump($f_grow_base$, [{$: "FParsed", ["term"]: n_0, ["rest"]: ts_0}, min_0]);
})]);
})]);
})]);
}

function $f_atom$(ts_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "~")), run_clo((x_0) => {
  return run_jump($f_atom$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "do")), run_clo((x_2) => {
  return run_jump($f_do_start$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "%")), run_clo((x_4) => {
  return run_jump($f_rewrite$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_5) => {
  return run_jump($f_atom_base$, [ts_0]);
})]);
})]);
})]);
}

function $f_def_type$(name_0, pars_0, p_0, book_0, imports_0, unsafe_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(ty_0)), "Absent")), run_clo((x_0) => {
  return run_jump($f_result$, [book_0, ("definition without return type needs a law: " + name_0), imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(run_loop($f_skip$(run_loop($f_tl$(ts_0)))))), "import")), run_clo((x_2) => {
  return run_jump($f_foreign$, [name_0, pars_0, run_loop($f_def_signature$(name_0, pars_0, ty_0, book_0)), run_loop($f_skip$(run_loop($f_tl$(ts_0)))), book_0, imports_0, unsafe_0, {$: "Nil"}]);
}), run_clo((x_3) => {
  return run_jump($f_def_body$, [name_0, pars_0, run_loop($f_def_signature$(name_0, pars_0, ty_0, book_0)), run_loop($f_body$(run_loop($f_pr$(run_loop($f_expect$({$: "FParsed", ["term"]: ty_0, ["rest"]: ts_0}, ":")))))), book_0, imports_0, unsafe_0]);
})]);
})]);
}

function $f_dt$(d_0) {
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

function $f_find$(name_0, book_0) {
  if (book_0.$ === "Nil") {
    return {$: "KDef", ["name"]: name_0, ["kind"]: "Missing", ["arity"]: 0, ["templates"]: 0, ["typ"]: run_loop($atom$("Absent")), ["value"]: run_loop($atom$("Absent")), ["ctors"]: {$: "Nil"}, ["native"]: false, ["unsafe"]: false};
  } else {
    const d_0 = book_0["head"];
    const ds_0 = book_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(name_0, run_loop($f_dn$(d_0)))), run_clo((x_0) => {
    return d_0;
}), run_clo((x_1) => {
    return run_jump($f_find$, [name_0, ds_0]);
})]);
  }
}

function $f_validate_param$(ts_0, end_0, acc_0) {
  return run_jump($f_choose$, [run_loop($f_reserved$(run_loop($f_tx$(run_loop($f_unmark$(ts_0)))))), run_clo((x_0) => {
  return run_jump($f_err$, [ts_0, "reserved parameter name"]);
}), run_clo((x_1) => {
  const x_2 = run_loop($f_templates$(acc_0));
  const x_3 = run_loop($f_len$(acc_0));
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "~")), (x_2 < x_3))), run_clo((x_4) => {
  return run_jump($f_err$, [ts_0, "only leading parameters may use ~"]);
}), run_clo((x_5) => {
  return run_jump($f_tele_binder$, [run_loop($f_tx$(run_loop($f_unmark$(ts_0)))), run_loop($f_atid$(ts_0)), run_loop($f_quant$(ts_0)), run_loop($f_eq$(run_loop($f_tx$(ts_0)), "~")), run_loop($f_tl$(run_loop($f_unmark$(ts_0)))), end_0, acc_0]);
})]);
})]);
}

function $f_type_kind$(name_0, pars_0, p_0, book_0, imports_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_type_ctors$, [name_0, pars_0, ty_0, run_loop($f_skip$(ts_0)), book_0, imports_0, {$: "Nil"}]);
}

function $f_expect$(p_0, s_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  const x_0 = run_loop($f_eq$(run_loop($tg$(n_0)), "Error"));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), s_0));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_3) => {
  return run_jump($f_err$, [ts_0, ("expected " + s_0)]);
})]);
}

function $f_pr$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return ts_0;
}

function $String$starts_with$(s_0, p_0) {
  if (s_0 === "") {
    if (p_0 === "") {
      return true;
    } else {
      const h_0 = (p_0.codePointAt(0) > 0xFFFF ? p_0.slice(0, 2) : p_0[0]);
      const t_0 = (p_0.codePointAt(0) > 0xFFFF ? p_0.slice(2) : p_0.slice(1));
      return false;
    }
  } else {
    const h_1 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(0, 2) : s_0[0]);
    const t_1 = (s_0.codePointAt(0) > 0xFFFF ? s_0.slice(2) : s_0.slice(1));
    if (p_0 === "") {
      return true;
    } else {
      const y_0 = (p_0.codePointAt(0) > 0xFFFF ? p_0.slice(0, 2) : p_0[0]);
      const yt_0 = (p_0.codePointAt(0) > 0xFFFF ? p_0.slice(2) : p_0.slice(1));
      return run_jump($String$starts_with$if$, [t_1, yt_0, run_loop($Char$is_eq$(h_1, y_0))]);
    }
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

function $cu$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return unsafe_0;
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

function $cn$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return name_0;
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

function $cq$(e_0) {
  const book_0 = e_0["book"];
  const name_0 = e_0["name"];
  const lhs_0 = e_0["lhs"];
  const pending_0 = e_0["pending"];
  const quantities_0 = e_0["quantities"];
  const unsafe_0 = e_0["unsafe"];
  return quantities_0;
}

function $tele_check_head$(e_0, ctx_0, tel_0, h_0, rest_0, dem_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(tel_0)), "All")), run_clo((x_0) => {
  return run_jump($tele_check_done$, [run_loop($check$(e_0, ctx_0, h_0, run_loop($qdem$(run_loop($qt$(tel_0)), dem_0)), run_loop($kid$(tel_0, 0)))), run_loop($tele_check$(e_0, ctx_0, run_loop($subst$(run_loop($kid$(tel_0, 1)), run_loop($ix$(tel_0)), h_0)), rest_0, dem_0))]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["too many telescope arguments"]);
})]);
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

function $descend_spine$(qs_0, args_0, cols_0) {
  if (cols_0.$ === "Nil") {
    return false;
  } else {
    const h_0 = cols_0["head"];
    const t_0 = cols_0["tail"];
    return run_jump($descend_step$, [run_loop($descend$(run_loop($qt$(run_loop($terms_at$(qs_0, 0)))), run_loop($terms_at$(args_0, 0)), h_0)), run_loop($terms_tail$(qs_0)), run_loop($terms_tail$(args_0)), t_0]);
  }
}

function $unargs$(t_0, acc_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(t_0)), "App")), run_clo((x_0) => {
  return run_jump($unargs$, [run_loop($kid$(t_0, 0)), {$: "Con", ["head"]: run_loop($kid$(t_0, 1)), ["tail"]: acc_0}]);
}), run_clo((x_1) => {
  return acc_0;
})]);
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

function $infer_app_type$(e_0, ctx_0, t_0, dem_0, r_0, ty_0) {
  return run_jump($kc$, [run_loop($String$eq$(run_loop($tg$(ty_0)), "All")), run_clo((x_0) => {
  return run_jump($both$, [r_0, run_loop($check$(e_0, ctx_0, run_loop($kid$(t_0, 1)), run_loop($qdem$(run_loop($qt$(ty_0)), dem_0)), run_loop($kid$(ty_0, 0)))), t_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), run_loop($kid$(t_0, 1)))), false]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["application requires a function type"]);
})]);
}

function $infer_adt_done$(t_0, r_0) {
  return run_jump($checked$, [r_0, t_0, run_loop($cy$(r_0))]);
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

function $f_path_terms$(ts_0, dir_0) {
  if (ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const t_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_path_term$(t_0, dir_0)), ["tail"]: run_loop($f_path_terms$(rest_0, dir_0))};
  }
}

function $f_qual_def$(d_0, book_0, ns_0, imports_0) {
  const name_0 = d_0["name"];
  const kind_0 = d_0["kind"];
  const arity_0 = d_0["arity"];
  const templates_0 = d_0["templates"];
  const ty_0 = d_0["typ"];
  const value_0 = d_0["value"];
  const ctors_0 = d_0["ctors"];
  const native_0 = d_0["native"];
  const unsafe_0 = d_0["unsafe"];
  return {$: "KDef", ["name"]: run_loop($f_qual_name$(name_0, ns_0)), ["kind"]: kind_0, ["arity"]: arity_0, ["templates"]: templates_0, ["typ"]: run_loop($f_qual_term$(ty_0, book_0, ns_0, imports_0)), ["value"]: run_loop($f_qual_term$(value_0, book_0, ns_0, imports_0)), ["ctors"]: run_loop($f_qual_defs$(ctors_0, book_0, ns_0, imports_0)), ["native"]: native_0, ["unsafe"]: unsafe_0};
}

function $f_scope$(t_0, env_0, book_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Write")), run_clo((x_0) => {
  return run_jump($f_scope$, [run_loop($kid$(t_0, 0)), env_0, book_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "ADT")), run_clo((x_2) => {
  return run_jump($f_adt$, [t_0, run_loop($f_scope_terms$(run_loop($ks$(t_0)), env_0, book_0)), run_loop($f_find$(run_loop($nm$(t_0)), book_0))]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "App")), run_clo((x_4) => {
  return run_jump($f_scope_app$, [run_loop($f_scope$(run_loop($kid$(t_0, 0)), env_0, book_0)), run_loop($f_scope$(run_loop($kid$(t_0, 1)), env_0, book_0))]);
}), run_clo((x_5) => {
  return run_jump($f_scope_base$, [t_0, env_0, book_0]);
})]);
})]);
})]);
}

function $f_prefix$(s_0, prefix_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(prefix_0)), run_clo((x_0) => {
  return true;
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_2) => {
  return false;
}), run_clo((x_3) => {
  return run_jump($Bool$and$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), run_loop($f_head$(prefix_0)))), run_loop($f_prefix$(run_loop($f_tail$(s_0)), run_loop($f_tail$(prefix_0))))]);
})]);
})]);
}

function $f_drop_prefix$(s_0, prefix_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(prefix_0)), run_clo((x_0) => {
  return s_0;
}), run_clo((x_1) => {
  return run_jump($f_drop_prefix$, [run_loop($f_tail$(s_0)), run_loop($f_tail$(prefix_0))]);
})]);
}

function $f_path_parent$(parts_0) {
  if (parts_0.$ === "Nil") {
    return {$: "Con", ["head"]: "..", ["tail"]: {$: "Nil"}};
  } else {
    const p_0 = parts_0["head"];
    const rest_0 = parts_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(p_0, "..")), run_clo((x_0) => {
    return {$: "Con", ["head"]: "..", ["tail"]: {$: "Con", ["head"]: p_0, ["tail"]: rest_0}};
}), run_clo((x_1) => {
    return rest_0;
})]);
  }
}

function $f_alias_valid$(s_0) {
  const x_0 = run_loop($Char$is_alpha$(run_loop($f_head$(s_0))));
  const x_1 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "_"));
  return run_jump($Bool$and$, [run_loop($Bool$and$((x_0 || x_1), run_loop($f_alias_chars$(s_0)))), run_loop($Bool$not$(run_loop($f_reserved$(s_0))))]);
}

function $f_law_where$(name_0, binder_0, ty_0, p_0, book_0, imports_0, clauses_0) {
  const predicate_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_law_type$, [name_0, binder_0, {$: "FParsed", ["term"]: run_loop($f_app$(run_loop($ref$("Exists")), {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Lam", run_loop($nm$(binder_0)), run_loop($ix$(binder_0)), 1, {$: "Con", ["head"]: predicate_0, ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Nil"}}})), ["rest"]: ts_0}, book_0, imports_0, clauses_0]);
}

function $f_app$(f_0, xs_0) {
  if (xs_0.$ === "Nil") {
    return f_0;
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return run_jump($f_app$, [run_loop($kt$("App", "", 0, 1, {$: "Con", ["head"]: f_0, ["tail"]: {$: "Con", ["head"]: x_0, ["tail"]: {$: "Nil"}}})), xt_0]);
  }
}

function $f_prec$(s_0) {
  const x_0 = run_loop($f_eq$(s_0, "=>"));
  const x_1 = run_loop($f_eq$(s_0, "->"));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return 1;
}), run_clo((x_3) => {
  const x_4 = run_loop($f_eq$(s_0, "&"));
  const x_5 = run_loop($f_eq$(s_0, "|"));
  return run_jump($f_choose$, [(x_4 || x_5), run_clo((x_6) => {
  return 2;
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "||")), run_clo((x_8) => {
  return 3;
}), run_clo((x_9) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "&&")), run_clo((x_10) => {
  return 4;
}), run_clo((x_11) => {
  const x_12 = run_loop($f_eq$(s_0, "<"));
  const x_13 = run_loop($f_eq$(s_0, ">op"));
  const x_14 = (x_12 || x_13);
  const x_15 = run_loop($f_eq$(s_0, "<="));
  const x_16 = (x_14 || x_15);
  const x_17 = run_loop($f_eq$(s_0, ">="));
  return run_jump($f_choose$, [(x_16 || x_17), run_clo((x_18) => {
  return 5;
}), run_clo((x_19) => {
  const x_20 = run_loop($f_eq$(s_0, "<>"));
  const x_21 = run_loop($f_eq$(s_0, "++"));
  const x_22 = (x_20 || x_21);
  const x_23 = run_loop($f_eq$(s_0, "<&>"));
  return run_jump($f_choose$, [(x_22 || x_23), run_clo((x_24) => {
  return 6;
}), run_clo((x_25) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ".|.")), run_clo((x_26) => {
  return 7;
}), run_clo((x_27) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ".^.")), run_clo((x_28) => {
  return 8;
}), run_clo((x_29) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ".&.")), run_clo((x_30) => {
  return 9;
}), run_clo((x_31) => {
  const x_32 = run_loop($f_eq$(s_0, "<<"));
  const x_33 = run_loop($f_eq$(s_0, ">>op"));
  return run_jump($f_choose$, [(x_32 || x_33), run_clo((x_34) => {
  return 10;
}), run_clo((x_35) => {
  const x_36 = run_loop($f_eq$(s_0, "+"));
  const x_37 = run_loop($f_eq$(s_0, "-"));
  return run_jump($f_choose$, [(x_36 || x_37), run_clo((x_38) => {
  return 11;
}), run_clo((x_39) => {
  const x_40 = run_loop($f_eq$(s_0, "*"));
  const x_41 = run_loop($f_eq$(s_0, "/"));
  const x_42 = (x_40 || x_41);
  const x_43 = run_loop($f_eq$(s_0, "%"));
  return run_jump($f_choose$, [(x_42 || x_43), run_clo((x_44) => {
  return 12;
}), run_clo((x_45) => {
  return 0;
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
})]);
}

function $f_grow_base$(p_0, min_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(n_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  const x_2 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "("));
  const x_3 = run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "{")), run_loop($f_eq$(run_loop($tg$(n_0)), "Ref"))));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<")), run_loop($Char$is_upper$(run_loop($f_head$(run_loop($nm$(n_0))))))));
  return run_jump($f_choose$, [(x_4 || x_5), run_clo((x_6) => {
  return run_jump($f_grow_args$, [n_0, run_loop($f_tx$(ts_0)), min_0, run_loop($f_args$(run_loop($f_tl$(ts_0)), run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "(")), run_clo((x_7) => {
  return ")";
}), run_clo((x_8) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "{")), run_clo((x_9) => {
  return "}";
}), run_clo((x_10) => {
  return ">";
})]);
}))), {$: "Nil"}))]);
}), run_clo((x_11) => {
  const x_12 = run_loop($f_prec$(run_loop($f_tx$(ts_0))));
  const x_13 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "%"));
  const x_14 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "-"));
  const x_15 = run_loop($f_col$(ts_0));
  const x_16 = run_loop($f_col$(run_loop($f_tl$(ts_0))));
  const x_17 = ((x_15 + 1) >>> 0);
  const x_18 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), ")"));
  const x_19 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), "}"));
  const x_20 = (x_18 || x_19);
  const x_21 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), ","));
  const x_22 = (x_20 || x_21);
  const x_23 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), ":"));
  const x_24 = (x_22 || x_23);
  const x_25 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), ">"));
  const x_26 = (x_24 || x_25);
  const x_27 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), "\n"));
  const x_28 = (x_26 || x_27);
  const x_29 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), "->"));
  const x_30 = (x_28 || x_29);
  const x_31 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), "<eof>"));
  const x_32 = (x_30 || x_31);
  const x_33 = run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), "]"));
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($Bool$and$((x_12 > min_0), run_loop($Bool$not$(run_loop($Bool$and$(run_loop($Bool$and$((x_13 || x_14), (x_16 === x_17))), run_loop($Char$is_alpha$(run_loop($f_head$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))))))))))))), run_loop($Bool$not$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), ">")))))), run_loop($Bool$not$(run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), ">>")), (x_32 || x_33))))))), run_clo((x_34) => {
  const x_35 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "=>"));
  const x_36 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "->"));
  const x_37 = (x_35 || x_36);
  const x_38 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<>"));
  const x_39 = (x_37 || x_38);
  const x_40 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "&"));
  const x_41 = (x_39 || x_40);
  const x_42 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "|"));
  return run_jump($f_binary$, [n_0, run_loop($f_tx$(ts_0)), min_0, run_loop($f_rhs$(run_loop($f_tl$(ts_0)), run_loop($f_tx$(ts_0)), run_loop($f_choose$((x_41 || x_42), run_clo((x_43) => {
  const x_44 = run_loop($f_prec$(run_loop($f_tx$(ts_0))));
  return ((x_44 - 1) >>> 0);
}), run_clo((x_45) => {
  return run_jump($f_prec$, [run_loop($f_tx$(ts_0))]);
})))))]);
}), run_clo((x_46) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
})]);
})]);
})]);
}

function $f_index$(n_0, p_0, min_0) {
  const idx_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<-")), run_clo((x_0) => {
  return run_jump($f_index_value$, [n_0, idx_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 2)), min_0]);
}), run_clo((x_1) => {
  return run_jump($f_grow$, [{$: "FParsed", ["term"]: run_loop($f_app$(run_loop($ref$("Array.get")), {$: "Con", ["head"]: run_loop($ref$("U32")), ["tail"]: {$: "Con", ["head"]: n_0, ["tail"]: {$: "Con", ["head"]: idx_0, ["tail"]: {$: "Nil"}}}})), ["rest"]: ts_0}, min_0]);
})]);
}

function $f_do_start$(ts_0) {
  return run_jump($f_do_types$, [run_loop($f_tx$(ts_0)), run_loop($f_args$(run_loop($f_tl$(run_loop($f_tl$(ts_0)))), ">", {$: "Nil"}))]);
}

function $f_rewrite$(ts_0) {
  return run_jump($f_rewrite_head$, [run_loop($f_expr$(ts_0, 0))]);
}

function $f_atom_base$(ts_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "(")), run_clo((x_0) => {
  return run_jump($f_group$, [run_loop($f_body$(run_loop($f_tl$(ts_0))))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "{")), run_clo((x_2) => {
  return run_jump($f_brace$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "[")), run_clo((x_4) => {
  return run_jump($f_array$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "@")), run_clo((x_6) => {
  return run_jump($f_all$, [run_loop($f_tl$(ts_0)), false]);
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "&")), run_clo((x_8) => {
  return run_jump($f_grade$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_9) => {
  const x_10 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "+"));
  const x_11 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "+bind"));
  return run_jump($f_choose$, [(x_10 || x_11), run_clo((x_12) => {
  return run_jump($f_mark$, [run_loop($f_atom$(run_loop($f_tl$(ts_0)))), 2]);
}), run_clo((x_13) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "?")), run_clo((x_14) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Hol", run_loop($f_tx$(run_loop($f_tl$(ts_0)))), 0, 0, {$: "Nil"})), ["rest"]: run_loop($f_tl$(run_loop($f_tl$(ts_0))))};
}), run_clo((x_15) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "\\")), run_clo((x_16) => {
  return run_jump($f_matcher$, [run_loop($f_tl$(run_loop($f_tl$(ts_0))))]);
}), run_clo((x_17) => {
  const x_18 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "Type"));
  const x_19 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "Data"));
  return run_jump($f_choose$, [(x_18 || x_19), run_clo((x_20) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Typ", "", 0, 0, {$: "Con", ["head"]: run_loop($kt$("Qua", "", 0, run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "Data")), run_clo((x_21) => {
  return 2;
}), run_clo((x_22) => {
  return 1;
}))), {$: "Nil"})), ["tail"]: {$: "Nil"}})), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_23) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "Quant")), run_clo((x_24) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Qnt", "", 0, 0, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_25) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "Kind")), run_clo((x_26) => {
  return run_jump($f_kind_wrap$, [run_loop($f_expect$(run_loop($f_expr$(run_loop($f_tl$(run_loop($f_tl$(ts_0)))), 0)), ")"))]);
}), run_clo((x_27) => {
  const x_28 = run_loop($f_kind_token$(ts_0));
  return run_jump($f_choose$, [(x_28 === 2), run_clo((x_29) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Literal", run_loop($f_tx$(ts_0)), 0, 1, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_30) => {
  const x_31 = run_loop($f_kind_token$(ts_0));
  return run_jump($f_choose$, [run_loop($Bool$and$((x_31 === 1), run_loop($Bool$not$(run_loop($f_reserved$(run_loop($f_tx$(ts_0)))))))), run_clo((x_32) => {
  return {$: "FParsed", ["term"]: run_loop($kt$(run_loop($f_choose$(run_loop($Char$is_digit$(run_loop($f_head$(run_loop($f_tx$(ts_0)))))), run_clo((x_33) => {
  return "Literal";
}), run_clo((x_34) => {
  return "Ref";
}))), run_loop($f_tx$(ts_0)), run_loop($f_atid$(ts_0)), 1, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_35) => {
  return run_jump($f_err$, [ts_0, "expected term"]);
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
})]);
})]);
}

function $f_foreign$(name_0, pars_0, ty_0, ts_0, book_0, imports_0, unsafe_0, paths_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "import")), run_clo((x_0) => {
  return run_jump($f_foreign$, [name_0, pars_0, ty_0, run_loop($f_skip$(run_loop($f_tl$(run_loop($f_tl$(ts_0)))))), book_0, imports_0, unsafe_0, {$: "Con", ["head"]: run_loop($kt$("Path", run_loop($f_unquote$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))))), 0, 0, {$: "Nil"})), ["tail"]: paths_0}]);
}), run_clo((x_1) => {
  return run_jump($f_tops$, [ts_0, run_loop($f_put$({$: "KDef", ["name"]: name_0, ["kind"]: "Def", ["arity"]: run_loop($f_len$(pars_0)), ["templates"]: 0, ["typ"]: ty_0, ["value"]: run_loop($kt$("Foreign", name_0, 0, 0, run_loop($List$reverse$(paths_0)))), ["ctors"]: {$: "Nil"}, ["native"]: true, ["unsafe"]: unsafe_0}, book_0)), imports_0, false]);
})]);
}

function $f_def_signature$(name_0, pars_0, ty_0, book_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_dk$(run_loop($f_find$(name_0, book_0)))), "Missing")), run_clo((x_0) => {
  return run_jump($f_tbind$, [pars_0, ty_0]);
}), run_clo((x_1) => {
  return ty_0;
})]);
}

function $f_def_body$(name_0, pars_0, ty_0, p_0, book_0, imports_0, unsafe_0) {
  const body_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(body_0)), "Error")), run_clo((x_0) => {
  return run_jump($f_result$, [book_0, run_loop($nm$(body_0)), imports_0]);
}), run_clo((x_1) => {
  return run_jump($f_tops$, [ts_0, run_loop($f_put$({$: "KDef", ["name"]: name_0, ["kind"]: "Def", ["arity"]: run_loop($f_len$(pars_0)), ["templates"]: run_loop($f_templates$(pars_0)), ["typ"]: ty_0, ["value"]: run_loop($kt$("Body", "", 0, 0, {$: "Con", ["head"]: run_loop($kt$("Params", "", 0, 0, pars_0)), ["tail"]: {$: "Con", ["head"]: body_0, ["tail"]: {$: "Nil"}}})), ["ctors"]: {$: "Nil"}, ["native"]: false, ["unsafe"]: unsafe_0}, book_0)), imports_0, false]);
})]);
}

function $f_body$(ts_0) {
  return run_jump($f_body_context$, [ts_0, 0]);
}

function $f_dn$(d_0) {
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

function $f_tele_binder$(name_0, id_0, q_0, temp_0, ts_0, end_0, acc_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_0) => {
  return run_jump($f_tele_type$, [name_0, id_0, q_0, temp_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), end_0, acc_0]);
}), run_clo((x_1) => {
  return run_jump($f_tele_type$, [name_0, id_0, 0, temp_0, {$: "FParsed", ["term"]: run_loop($atom$("Qnt")), ["rest"]: ts_0}, end_0, acc_0]);
})]);
}

function $f_type_ctors$(name_0, pars_0, ty_0, ts_0, book_0, imports_0, ctors_0) {
  const x_0 = run_loop($f_col$(ts_0));
  return run_jump($f_choose$, [run_loop($Bool$and$((x_0 > 0), run_loop($f_eq$(run_loop($f_tx$(run_loop($f_tl$(ts_0)))), "{")))), run_clo((x_1) => {
  return run_jump($f_type_ctor$, [name_0, pars_0, ty_0, run_loop($f_tx$(ts_0)), run_loop($f_tele$(run_loop($f_tl$(run_loop($f_tl$(ts_0)))), "}", {$: "Nil"})), book_0, imports_0, ctors_0]);
}), run_clo((x_2) => {
  return run_jump($f_tops$, [ts_0, {$: "Con", ["head"]: {$: "KDef", ["name"]: name_0, ["kind"]: "ADT", ["arity"]: run_loop($f_len$(pars_0)), ["templates"]: 0, ["typ"]: run_loop($f_tbind$(pars_0, ty_0)), ["value"]: run_loop($atom$("Absent")), ["ctors"]: run_loop($List$reverse$(ctors_0)), ["native"]: false, ["unsafe"]: false}, ["tail"]: book_0}, imports_0, false]);
})]);
}

function $String$starts_with$if$(t_0, pt_0, same_0) {
  if (!same_0) {
    return false;
  } else {
    return run_jump($String$starts_with$, [t_0, pt_0]);
  }
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

function $tele_check_done$(a_0, b_0) {
  return run_jump($both$, [a_0, b_0, run_loop($ct$(b_0)), run_loop($cy$(b_0)), false]);
}

function $lhs_ext$(lhs_0, name_0, tel_0, n_0, xs_0) {
  return run_jump($kc$, [(n_0 === 0), run_clo((x_0) => {
  return run_jump($kapply$, [lhs_0, run_loop($kt$("Ctr", name_0, 0, 0, xs_0))]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Lam", run_loop($nm$(tel_0)), run_loop($ix$(tel_0)), run_loop($qt$(tel_0)), {$: "Con", ["head"]: run_loop($lhs_ext$(lhs_0, name_0, run_loop($kid$(tel_0, 1)), ((n_0 - 1) >>> 0), run_loop($norm_join$(xs_0, {$: "Con", ["head"]: run_loop($var$(run_loop($nm$(tel_0)), run_loop($ix$(tel_0)))), ["tail"]: {$: "Nil"}})))), ["tail"]: {$: "Nil"}}]);
})]);
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

function $f_qual_name$(name_0, ns_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(ns_0)), run_clo((x_0) => {
  return name_0;
}), run_clo((x_1) => {
  const x_2 = ("." + name_0);
  return (ns_0 + x_2);
})]);
}

function $f_qual_term$(t_0, book_0, ns_0, imports_0) {
  const x_0 = run_loop($f_eq$(run_loop($tg$(t_0)), "Ref"));
  const x_1 = run_loop($f_eq$(run_loop($tg$(t_0)), "ADT"));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($f_eq$(run_loop($tg$(t_0)), "Ctr"));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($f_eq$(run_loop($tg$(t_0)), "Mat"));
  return {$: "KTerm", ["tag"]: run_loop($tg$(t_0)), ["name"]: run_loop($f_choose$((x_4 || x_5), run_clo((x_6) => {
  return run_jump($f_resolve_name$, [run_loop($nm$(t_0)), book_0, ns_0, imports_0]);
}), run_clo((x_7) => {
  return run_jump($nm$, [t_0]);
}))), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: run_loop($f_qual_terms$(run_loop($ks$(t_0)), book_0, ns_0, imports_0)), ["removed"]: run_loop($rm$(t_0))};
}

function $f_adt$(t_0, args_0, d_0) {
  return run_jump($f_adt_fill$, [t_0, args_0, run_loop($da$(d_0)), run_loop($f_leading_quants$(run_loop($dt$(d_0))))]);
}

function $f_scope_terms$(xs_0, env_0, book_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_scope$(x_0, env_0, book_0)), ["tail"]: run_loop($f_scope_terms$(xt_0, env_0, book_0))};
  }
}

function $f_scope_app$(f_0, x_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(f_0)), "Lam")), run_clo((x_1) => {
  return run_jump($f_sub$, [run_loop($kid$(f_0, 0)), run_loop($ix$(f_0)), x_0]);
}), run_clo((x_2) => {
  return run_jump($app$, [f_0, x_0]);
})]);
}

function $f_scope_base$(t_0, env_0, book_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Ref")), run_clo((x_0) => {
  return run_jump($f_scope_ref$, [t_0, run_loop($f_env$(run_loop($nm$(t_0)), env_0)), book_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Literal")), run_clo((x_2) => {
  return run_jump($f_literal$, [run_loop($nm$(t_0))]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "All")), run_clo((x_4) => {
  return run_jump($kt$, ["All", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), {$: "Con", ["head"]: run_loop($f_scope$(run_loop($kid$(t_0, 0)), env_0, book_0)), ["tail"]: {$: "Con", ["head"]: run_loop($f_scope$(run_loop($kid$(t_0, 1)), {$: "Con", ["head"]: run_loop($kt$("Var", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), {$: "Nil"})), ["tail"]: env_0}, book_0)), ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Lam")), run_clo((x_6) => {
  return run_jump($kt$, ["Lam", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), {$: "Con", ["head"]: run_loop($f_scope$(run_loop($kid$(t_0, 0)), {$: "Con", ["head"]: run_loop($kt$("Var", run_loop($nm$(t_0)), run_loop($ix$(t_0)), run_loop($qt$(t_0)), {$: "Nil"})), ["tail"]: env_0}, book_0)), ["tail"]: {$: "Nil"}}]);
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Body")), run_clo((x_8) => {
  return run_jump($f_flat$, [run_loop($f_scope_body$(run_loop($kid$(t_0, 1)), run_loop($f_concat$(run_loop($f_vars$(run_loop($ks$(run_loop($kid$(t_0, 0)))))), env_0)), book_0)), run_loop($f_vars$(run_loop($ks$(run_loop($kid$(t_0, 0))))))]);
}), run_clo((x_9) => {
  const x_10 = run_loop($f_eq$(run_loop($tg$(t_0)), "Local"));
  const x_11 = run_loop($f_eq$(run_loop($tg$(t_0)), "Match"));
  return run_jump($f_choose$, [(x_10 || x_11), run_clo((x_12) => {
  return run_jump($f_flat$, [run_loop($f_scope_body$(t_0, env_0, book_0)), {$: "Nil"}]);
}), run_clo((x_13) => {
  return {$: "KTerm", ["tag"]: run_loop($tg$(t_0)), ["name"]: run_loop($nm$(t_0)), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: run_loop($f_scope_terms$(run_loop($ks$(t_0)), env_0, book_0)), ["removed"]: run_loop($rm$(t_0))};
})]);
})]);
})]);
})]);
})]);
})]);
}

function $f_alias_chars$(s_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_0) => {
  return true;
}), run_clo((x_1) => {
  const x_2 = run_loop($Char$is_alpha$(run_loop($f_head$(s_0))));
  const x_3 = run_loop($Char$is_digit$(run_loop($f_head$(s_0))));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "_"));
  return run_jump($Bool$and$, [(x_4 || x_5), run_loop($f_alias_chars$(run_loop($f_tail$(s_0))))]);
})]);
}

function $f_grow_args$(n_0, op_0, min_0, p_0) {
  const args_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(args_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: args_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  return run_jump($f_grow$, [{$: "FParsed", ["term"]: run_loop($f_choose$(run_loop($f_eq$(op_0, "(")), run_clo((x_2) => {
  return run_jump($f_app$, [n_0, run_loop($ks$(args_0))]);
}), run_clo((x_3) => {
  return run_jump($kt$, [run_loop($f_choose$(run_loop($f_eq$(op_0, "{")), run_clo((x_4) => {
  return "Ctr";
}), run_clo((x_5) => {
  return "ADT";
}))), run_loop($nm$(n_0)), run_loop($ix$(n_0)), run_loop($qt$(n_0)), run_loop($ks$(args_0))]);
}))), ["rest"]: ts_0}, min_0]);
})]);
}

function $f_args$(ts_0, end_0, acc_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(end_0, ">")), run_loop($f_eq$(run_loop($f_tx$(ts_0)), ">>")))), run_clo((x_0) => {
  const x_1 = run_loop($f_col$(ts_0));
  return {$: "FParsed", ["term"]: run_loop($kt$("Args", "", 0, 1, run_loop($List$reverse$(acc_0)))), ["rest"]: {$: "Con", ["head"]: {$: "FToken", ["text"]: ">", ["f_line"]: run_loop($f_line$(ts_0)), ["f_col"]: ((x_1 + 1) >>> 0), ["f_kind"]: 0}, ["tail"]: run_loop($f_tl$(ts_0))}};
}), run_clo((x_2) => {
  return run_jump($f_args_base$, [ts_0, end_0, acc_0]);
})]);
}

function $f_binary$(a_0, op_0, min_0, p_0) {
  const b_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_grow$, [{$: "FParsed", ["term"]: run_loop($f_binary_node$(a_0, op_0, b_0)), ["rest"]: ts_0}, min_0]);
}

function $f_rhs$(ts_0, op_0, min_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(op_0, "=>")), run_clo((x_0) => {
  return run_jump($f_body$, [ts_0]);
}), run_clo((x_1) => {
  return run_jump($f_expr$, [ts_0, min_0]);
})]);
}

function $f_index_value$(n_0, idx_0, p_0, min_0) {
  const v_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_grow$, [{$: "FParsed", ["term"]: run_loop($kt$("Write", run_loop($nm$(n_0)), run_loop($ix$(n_0)), 1, {$: "Con", ["head"]: run_loop($f_app$(run_loop($ref$("Array.set")), {$: "Con", ["head"]: run_loop($ref$("U32")), ["tail"]: {$: "Con", ["head"]: n_0, ["tail"]: {$: "Con", ["head"]: idx_0, ["tail"]: {$: "Con", ["head"]: v_0, ["tail"]: {$: "Nil"}}}}})), ["tail"]: {$: "Nil"}})), ["rest"]: ts_0}, min_0]);
}

function $f_do_types$(monad_0, p_0) {
  const types_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_do$, [monad_0, run_loop($ks$(types_0)), run_loop($f_skip$(run_loop($f_pr$(run_loop($f_expect$({$: "FParsed", ["term"]: types_0, ["rest"]: ts_0}, ":")))))), run_loop($f_col$(run_loop($f_skip$(run_loop($f_tl$(ts_0))))))]);
}

function $f_rewrite_head$(p_0) {
  const e_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "@")), run_clo((x_0) => {
  return run_jump($f_rewrite_proof$, [run_loop($nm$(e_0)), run_loop($ix$(e_0)), run_loop($f_expect$(run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), ":"))]);
}), run_clo((x_1) => {
  return run_jump($f_rewrite_proof$, ["", run_loop($ix$(e_0)), run_loop($f_expect$({$: "FParsed", ["term"]: e_0, ["rest"]: ts_0}, ":"))]);
})]);
}

function $f_group$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ",")), run_clo((x_0) => {
  return run_jump($f_tuple$, [n_0, run_loop($f_group$(run_loop($f_body$(run_loop($f_tl$(ts_0))))))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_2) => {
  return run_jump($f_group_ann$, [n_0, run_loop($f_expect$(run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), ")"))]);
}), run_clo((x_3) => {
  return run_jump($f_expect$, [{$: "FParsed", ["term"]: n_0, ["rest"]: ts_0}, ")"]);
})]);
})]);
}

function $f_brace$(ts_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "==")), run_clo((x_0) => {
  return run_jump($f_expect$, [{$: "FParsed", ["term"]: run_loop($kt$("Rfl", "", 0, 1, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))}, "}"]);
}), run_clo((x_1) => {
  return run_jump($f_brace_left$, [run_loop($f_expr$(ts_0, 0))]);
})]);
}

function $f_array$(ts_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "]")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Ctr", "Nil", 0, 1, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_1) => {
  return run_jump($f_array_first$, [run_loop($f_expr$(ts_0, 0))]);
})]);
}

function $f_all$(ts_0, exi_0) {
  return run_jump($f_all_domain$, [run_loop($f_tx$(run_loop($f_unmark$(ts_0)))), run_loop($f_atid$(ts_0)), run_loop($f_quant$(ts_0)), exi_0, run_loop($f_expect$(run_loop($f_expr$(run_loop($f_tl$(run_loop($f_tl$(run_loop($f_unmark$(ts_0)))))), 1)), "->"))]);
}

function $f_grade$(ts_0) {
  const x_0 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "0"));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "1"));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "2"));
  return run_jump($f_choose$, [(x_2 || x_3), run_clo((x_4) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Qua", "", 0, run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "0")), run_clo((x_5) => {
  return 0;
}), run_clo((x_6) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "1")), run_clo((x_7) => {
  return 1;
}), run_clo((x_8) => {
  return 2;
})]);
}))), {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_9) => {
  return run_jump($f_all$, [ts_0, true]);
})]);
}

function $f_mark$(p_0, q_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$(run_loop($tg$(n_0)), run_loop($nm$(n_0)), run_loop($ix$(n_0)), q_0, run_loop($ks$(n_0)))), ["rest"]: ts_0};
}

function $f_matcher$(ts_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "}")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Efq", "", 0, 1, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))};
}), run_clo((x_1) => {
  return run_jump($f_matcher_head$, [run_loop($f_expr$(ts_0, 0))]);
})]);
}

function $f_kind_wrap$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Typ", "", 0, 0, {$: "Con", ["head"]: n_0, ["tail"]: {$: "Nil"}})), ["rest"]: ts_0};
}

function $f_kind_token$(ts_0) {
  return run_jump($f_kind$, [ts_0]);
}

function $f_unquote$(s_0) {
  return run_jump($f_unquote_chars$, [run_loop($f_tail$(s_0))]);
}

function $f_put$(d_0, book_0) {
  return {$: "Con", ["head"]: d_0, ["tail"]: book_0};
}

function $f_dk$(d_0) {
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

function $f_tbind$(pars_0, result_0) {
  if (pars_0.$ === "Nil") {
    return result_0;
  } else {
    const p_0 = pars_0["head"];
    const ps_0 = pars_0["tail"];
    return run_jump($kt$, ["All", run_loop($nm$(p_0)), run_loop($ix$(p_0)), run_loop($qt$(p_0)), {$: "Con", ["head"]: run_loop($kid$(p_0, 0)), ["tail"]: {$: "Con", ["head"]: run_loop($f_tbind$(ps_0, result_0)), ["tail"]: {$: "Nil"}}}]);
  }
}

function $f_body_context$(ts_0, outer_0) {
  return run_jump($f_body_context_at$, [run_loop($f_skip$(ts_0)), outer_0]);
}

function $f_tele_type$(name_0, id_0, q_0, temp_0, p_0, end_0, acc_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(ty_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: ty_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  return run_jump($f_tele$, [run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), ",")), run_clo((x_2) => {
  return run_jump($f_tl$, [ts_0]);
}), run_clo((x_3) => {
  return ts_0;
}))), end_0, {$: "Con", ["head"]: run_loop($kt$(run_loop($f_choose$(temp_0, run_clo((x_4) => {
  return "Template";
}), run_clo((x_5) => {
  return "Bind";
}))), name_0, id_0, q_0, {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}})), ["tail"]: acc_0}]);
})]);
}

function $f_type_ctor$(name_0, pars_0, ty_0, ctor_0, p_0, book_0, imports_0, ctors_0) {
  const fields_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_type_ctors$, [name_0, pars_0, ty_0, run_loop($f_skip$(ts_0)), book_0, imports_0, {$: "Con", ["head"]: {$: "KDef", ["name"]: ctor_0, ["kind"]: "Ctr", ["arity"]: run_loop($f_len$(run_loop($ks$(fields_0)))), ["templates"]: 0, ["typ"]: run_loop($f_tbind$(pars_0, run_loop($f_tbind$(run_loop($ks$(fields_0)), run_loop($kt$("ADT", name_0, 0, 1, run_loop($f_param_refs$(pars_0)))))))), ["value"]: run_loop($kt$("Absent", ctor_0, 0, 0, {$: "Nil"})), ["ctors"]: {$: "Nil"}, ["native"]: false, ["unsafe"]: false}, ["tail"]: ctors_0}]);
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

function $f_resolve_name$(name_0, book_0, ns_0, imports_0) {
  return run_jump($f_choose$, [run_loop($f_declared$(name_0, book_0)), run_clo((x_0) => {
  return run_jump($f_qual_name$, [name_0, ns_0]);
}), run_clo((x_1) => {
  return run_jump($f_alias$, [name_0, imports_0]);
})]);
}

function $f_qual_terms$(ts_0, book_0, ns_0, imports_0) {
  if (ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const t_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_qual_term$(t_0, book_0, ns_0, imports_0)), ["tail"]: run_loop($f_qual_terms$(rest_0, book_0, ns_0, imports_0))};
  }
}

function $f_adt_fill$(t_0, args_0, arity_0, g_0) {
  const x_0 = run_loop($f_len$(args_0));
  const x_1 = ((x_0 + g_0) >>> 0);
  return run_jump($f_choose$, [(x_1 === arity_0), run_clo((x_2) => {
  const x_3 = run_loop($qt$(t_0));
  return {$: "KTerm", ["tag"]: "ADT", ["name"]: run_loop($nm$(t_0)), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: run_loop($f_concat$(run_loop($f_quants$(g_0, run_loop($f_choose$((x_3 === 2), run_clo((x_4) => {
  return 2;
}), run_clo((x_5) => {
  return 1;
}))))), args_0)), ["removed"]: run_loop($rm$(t_0))};
}), run_clo((x_6) => {
  const x_7 = run_loop($qt$(t_0));
  return {$: "KTerm", ["tag"]: "ADT", ["name"]: run_loop($nm$(t_0)), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: run_loop($f_choose$((x_7 === 2), run_clo((x_8) => {
  return run_jump($f_concat$, [run_loop($f_quants$(g_0, 2)), run_loop($f_drop_terms$(args_0, g_0))]);
}), run_clo((x_9) => {
  return args_0;
}))), ["removed"]: run_loop($rm$(t_0))};
})]);
}

function $f_leading_quants$(ty_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(ty_0)), "All")), run_loop($f_eq$(run_loop($tg$(run_loop($kid$(ty_0, 0)))), "Qnt")))), run_clo((x_0) => {
  const x_1 = run_loop($f_leading_quants$(run_loop($kid$(ty_0, 1))));
  return ((1 + x_1) >>> 0);
}), run_clo((x_2) => {
  return 0;
})]);
}

function $f_sub$(t_0, id_0, v_0) {
  const x_0 = run_loop($ix$(t_0));
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(t_0)), "Var")), (x_0 === id_0))), run_clo((x_1) => {
  return v_0;
}), run_clo((x_2) => {
  return {$: "KTerm", ["tag"]: run_loop($tg$(t_0)), ["name"]: run_loop($nm$(t_0)), ["id"]: run_loop($ix$(t_0)), ["quant"]: run_loop($qt$(t_0)), ["kids"]: run_loop($f_subs$(run_loop($ks$(t_0)), id_0, v_0)), ["removed"]: run_loop($rm$(t_0))};
})]);
}

function $f_scope_ref$(t_0, bound_0, book_0) {
  return run_jump($f_choose$, [run_loop($Bool$not$(run_loop($f_eq$(run_loop($tg$(bound_0)), "Absent")))), run_clo((x_0) => {
  return bound_0;
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_dk$(run_loop($f_find$(run_loop($nm$(t_0)), book_0)))), "ADT")), run_clo((x_2) => {
  return run_jump($f_adt$, [t_0, {$: "Nil"}, run_loop($f_find$(run_loop($nm$(t_0)), book_0))]);
}), run_clo((x_3) => {
  return t_0;
})]);
})]);
}

function $f_literal$(s_0) {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\"")), run_clo((x_0) => {
  return run_jump($f_string$, [run_loop($f_tail$(s_0))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "'")), run_clo((x_2) => {
  return run_jump($f_char_literal$, [run_loop($f_tail$(s_0))]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_contains$(s_0, ".")), run_clo((x_4) => {
  return run_jump($f_float$, [s_0]);
}), run_clo((x_5) => {
  return run_jump($f_number$, [s_0, 0]);
})]);
})]);
})]);
}

function $f_flat$(t_0, vars_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Parallel")), run_clo((x_0) => {
  return run_jump($f_flat_parallel$, [t_0, vars_0]);
}), run_clo((x_1) => {
  return run_jump($f_flat_base$, [t_0, vars_0]);
})]);
}

function $f_scope_body$(t_0, env_0, book_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Parallel")), run_clo((x_0) => {
  return run_jump($f_scope_parallel$, [t_0, env_0, book_0]);
}), run_clo((x_1) => {
  return run_jump($f_scope_body_base$, [t_0, env_0, book_0]);
})]);
}

function $f_vars$(xs_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return {$: "Con", ["head"]: run_loop($kt$("Var", run_loop($nm$(x_0)), run_loop($ix$(x_0)), 1, {$: "Nil"})), ["tail"]: run_loop($f_vars$(xt_0))};
  }
}

function $f_args_base$(ts_0, end_0, acc_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(run_loop($f_skip$(ts_0)))), end_0)), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Args", "", 0, 1, run_loop($List$reverse$(acc_0)))), ["rest"]: run_loop($f_tl$(run_loop($f_skip$(ts_0))))};
}), run_clo((x_1) => {
  return run_jump($f_arg_next$, [run_loop($f_expr$(run_loop($f_skip$(ts_0)), 0)), end_0, acc_0]);
})]);
}

function $f_binary_node$(a_0, op_0, b_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($f_eq$(op_0, "+")), run_loop($f_eq$(run_loop($tg$(a_0)), "Literal")))), run_loop($f_ends_nat$(run_loop($nm$(a_0)))))), run_clo((x_0) => {
  return run_jump($f_nat_plus$, [a_0, b_0]);
}), run_clo((x_1) => {
  return run_jump($f_binary_plain$, [a_0, op_0, b_0]);
})]);
}

function $f_do$(monad_0, types_0, ts_0, indent_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "return")), run_clo((x_0) => {
  return run_jump($f_do_return$, [monad_0, types_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0))]);
}), run_clo((x_1) => {
  return run_jump($f_do_statement$, [monad_0, types_0, run_loop($f_expr$(ts_0, 0)), indent_0]);
})]);
}

function $f_rewrite_proof$(name_0, id_0, p_0) {
  const e_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_rewrite_motive$, [name_0, id_0, e_0, run_loop($f_expr$(ts_0, 0))]);
}

function $f_tuple$(n_0, p_0) {
  const m_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Ctr", "Tuple", 0, 1, {$: "Con", ["head"]: n_0, ["tail"]: {$: "Con", ["head"]: m_0, ["tail"]: {$: "Nil"}}})), ["rest"]: ts_0};
}

function $f_group_ann$(n_0, p_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Ann", "", 0, 1, {$: "Con", ["head"]: run_loop($f_namespace$(n_0, ty_0)), ["tail"]: {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}}})), ["rest"]: ts_0};
}

function $f_brace_left$(p_0) {
  const a_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  const x_0 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "=="));
  const x_1 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "!="));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return run_jump($f_equation$, [a_0, run_loop($f_eq$(run_loop($f_tx$(ts_0)), "!=")), run_loop($f_expect$(run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), ":"))]);
}), run_clo((x_3) => {
  return run_jump($f_group_ann$, [a_0, run_loop($f_expect$(run_loop($f_expr$(run_loop($f_pr$(run_loop($f_expect$({$: "FParsed", ["term"]: a_0, ["rest"]: ts_0}, ":")))), 0)), "}"))]);
})]);
}

function $f_array_first$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_0) => {
  return run_jump($f_array_type$, [n_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 12))]);
}), run_clo((x_1) => {
  return run_jump($f_list$, [run_loop($f_args$(run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), ",")), run_clo((x_2) => {
  return run_jump($f_tl$, [ts_0]);
}), run_clo((x_3) => {
  return ts_0;
}))), "]", {$: "Con", ["head"]: n_0, ["tail"]: {$: "Nil"}}))]);
})]);
}

function $f_all_domain$(name_0, id_0, q_0, exi_0, p_0) {
  const a_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_all_body$, [name_0, id_0, q_0, exi_0, a_0, run_loop($f_expr$(ts_0, 0))]);
}

function $f_matcher_head$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_0) => {
  return run_jump($f_matcher_arm$, [run_loop($nm$(n_0)), run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0))]);
}), run_clo((x_1) => {
  return run_jump($f_expect$, [{$: "FParsed", ["term"]: n_0, ["rest"]: ts_0}, "}"]);
})]);
}

function $f_kind$(ts_0) {
  if (ts_0.$ === "Nil") {
    return 0;
  } else {
    const _t_0 = ts_0["head"];
    const t_0 = _t_0["text"];
    const l_0 = _t_0["f_line"];
    const c_0 = _t_0["f_col"];
    const k_0 = _t_0["f_kind"];
    const rest_0 = ts_0["tail"];
    return k_0;
  }
}

function $f_unquote_chars$(s_0) {
  const x_0 = run_loop($String$is_empty$(s_0));
  const x_1 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\""));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return "";
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\\")), run_clo((x_4) => {
  return (char_new(run_loop($f_escape_code$(run_loop($f_head$(run_loop($f_tail$(s_0))))))) + run_loop($f_unquote_chars$(run_loop($f_tail$(run_loop($f_tail$(s_0)))))));
}), run_clo((x_5) => {
  return (run_loop($f_head$(s_0)) + run_loop($f_unquote_chars$(run_loop($f_tail$(s_0)))));
})]);
})]);
}

function $f_body_context_at$(ts_0, outer_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "match")), run_clo((x_0) => {
  return run_jump($f_match_heads$, [run_loop($f_tl$(ts_0)), outer_0, {$: "Nil"}]);
}), run_clo((x_1) => {
  return run_jump($f_body_at$, [ts_0]);
})]);
}

function $f_param_refs$(pars_0) {
  if (pars_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const p_0 = pars_0["head"];
    const ps_0 = pars_0["tail"];
    return {$: "Con", ["head"]: run_loop($kt$("Ref", run_loop($nm$(p_0)), run_loop($ix$(p_0)), run_loop($qt$(p_0)), {$: "Nil"})), ["tail"]: run_loop($f_param_refs$(ps_0))};
  }
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

function $template_arg_done$(e_0, ty_0, h_0, rest_0, n_0, r_0) {
  return run_jump($kc$, [run_loop($good$(r_0)), run_clo((x_0) => {
  return run_jump($template_args$, [e_0, run_loop($subst$(run_loop($kid$(ty_0, 1)), run_loop($ix$(ty_0)), h_0)), rest_0, ((n_0 - 1) >>> 0)]);
}), run_clo((x_1) => {
  return run_jump($bad$, ["template argument is open or ill-typed"]);
})]);
}

function $f_declared$(name_0, book_0) {
  if (book_0.$ === "Nil") {
    return false;
  } else {
    const d_0 = book_0["head"];
    const ds_0 = book_0["tail"];
    const x_0 = run_loop($f_eq$(name_0, run_loop($f_dn$(d_0))));
    const x_1 = run_loop($f_declared$(name_0, run_loop($dc$(d_0))));
    const x_2 = (x_0 || x_1);
    const x_3 = run_loop($f_declared$(name_0, ds_0));
    return (x_2 || x_3);
  }
}

function $f_quants$(n_0, q_0) {
  return run_jump($f_choose$, [(n_0 === 0), run_clo((x_0) => {
  return {$: "Nil"};
}), run_clo((x_1) => {
  return {$: "Con", ["head"]: run_loop($qua$(q_0)), ["tail"]: run_loop($f_quants$(((n_0 - 1) >>> 0), q_0))};
})]);
}

function $f_drop_terms$(ts_0, n_0) {
  return run_jump($f_choose$, [(n_0 === 0), run_clo((x_0) => {
  return ts_0;
}), run_clo((x_1) => {
  return run_jump($f_drop_terms$, [run_loop($f_tail_terms$(ts_0)), ((n_0 - 1) >>> 0)]);
})]);
}

function $f_subs$(ts_0, id_0, v_0) {
  if (ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const t_0 = ts_0["head"];
    const rest_0 = ts_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_sub$(t_0, id_0, v_0)), ["tail"]: run_loop($f_subs$(rest_0, id_0, v_0))};
  }
}

function $f_string$(s_0) {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\"")), run_clo((x_0) => {
  return run_jump($kt$, ["Ctr", "SNil", 0, 1, {$: "Nil"}]);
}), run_clo((x_1) => {
  return run_jump($f_string_decoded$, [run_loop($f_decode_char$(s_0))]);
})]);
}

function $f_char_literal$(s_0) {
  return run_jump($f_char_decoded$, [run_loop($f_decode_char$(s_0))]);
}

function $f_contains$(s_0, c_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_0) => {
  return false;
}), run_clo((x_1) => {
  const x_2 = run_loop($Char$is_eq$(run_loop($f_head$(s_0)), c_0));
  const x_3 = run_loop($f_contains$(run_loop($f_tail$(s_0)), c_0));
  return (x_2 || x_3);
})]);
}

function $f_float$(s_0) {
  return run_jump($f_float_read$, [f32_read(s_0)]);
}

function $f_number$(s_0, acc_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_0) => {
  return run_jump($f_u32$, [acc_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "n")), run_clo((x_2) => {
  return run_jump($f_nat$, [acc_0]);
}), run_clo((x_3) => {
  const x_4 = run_loop($Char$to_u32$(run_loop($f_head$(s_0))));
  const x_5 = (acc_0 < 429496729);
  const x_6 = run_loop($Bool$and$((acc_0 === 429496729), (x_4 <= 53)));
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Char$is_digit$(run_loop($f_head$(s_0)))), (x_5 || x_6))), run_clo((x_7) => {
  const x_8 = run_loop($Char$to_u32$(run_loop($f_head$(s_0))));
  const x_9 = (Math.imul(acc_0, 10) >>> 0);
  const x_10 = ((x_8 - 48) >>> 0);
  return run_jump($f_number$, [run_loop($f_tail$(s_0)), ((x_9 + x_10) >>> 0)]);
}), run_clo((x_11) => {
  return run_jump($kt$, ["Error", "invalid or unsupported numeric literal", 0, 0, {$: "Nil"}]);
})]);
})]);
})]);
}

function $f_flat_parallel$(t_0, vars_0) {
  return run_jump($f_lbind$, [vars_0, run_loop($kt$("Let", "", 0, 1, run_loop($f_concat$(run_loop($f_parallel_binds$(run_loop($ks$(run_loop($kid$(t_0, 0)))), run_loop($ks$(run_loop($kid$(t_0, 1)))))), {$: "Con", ["head"]: run_loop($f_unlamb$(run_loop($f_flat$(run_loop($kid$(t_0, 2)), run_loop($ks$(run_loop($kid$(t_0, 0)))))), run_loop($f_len$(run_loop($ks$(run_loop($kid$(t_0, 0)))))))), ["tail"]: {$: "Nil"}}))))]);
}

function $f_flat_base$(t_0, vars_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Match")), run_clo((x_0) => {
  return run_jump($f_flat_match$, [run_loop($ks$(run_loop($kid$(t_0, 0)))), run_loop($f_tail_terms$(run_loop($ks$(t_0)))), vars_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Local")), run_clo((x_2) => {
  return run_jump($f_flat_local$, [t_0, vars_0]);
}), run_clo((x_3) => {
  return run_jump($f_lbind$, [vars_0, t_0]);
})]);
})]);
}

function $f_scope_parallel$(t_0, env_0, book_0) {
  return run_jump($f_scope_parallel_pats$, [t_0, run_loop($f_patterns$(run_loop($ks$(run_loop($kid$(t_0, 0)))))), env_0, book_0]);
}

function $f_scope_body_base$(t_0, env_0, book_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Local")), run_clo((x_0) => {
  return run_jump($f_scope_local$, [t_0, run_loop($f_patterns$({$: "Con", ["head"]: run_loop($kid$(t_0, 0)), ["tail"]: {$: "Nil"}})), env_0, book_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "Match")), run_clo((x_2) => {
  return run_jump($kt$, ["Match", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Heads", "", 0, 1, run_loop($f_scope_terms$(run_loop($ks$(run_loop($kid$(t_0, 0)))), env_0, book_0)))), ["tail"]: run_loop($f_scope_rows$(run_loop($f_tail_terms$(run_loop($ks$(t_0)))), env_0, book_0))}]);
}), run_clo((x_3) => {
  return run_jump($f_scope$, [t_0, env_0, book_0]);
})]);
})]);
}

function $f_arg_next$(p_0, end_0, acc_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(n_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  return run_jump($f_args$, [run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), ",")), run_clo((x_2) => {
  return run_jump($f_tl$, [ts_0]);
}), run_clo((x_3) => {
  return ts_0;
}))), end_0, {$: "Con", ["head"]: n_0, ["tail"]: acc_0}]);
})]);
}

function $f_ends_nat$(s_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(run_loop($f_tail$(s_0)))), run_clo((x_0) => {
  return run_jump($f_eq$, [s_0, "n"]);
}), run_clo((x_1) => {
  return run_jump($f_ends_nat$, [run_loop($f_tail$(s_0))]);
})]);
}

function $f_nat_plus$(lit_0, b_0) {
  return run_jump($f_nat_extend$, [run_loop($f_literal$(run_loop($nm$(lit_0)))), b_0]);
}

function $f_binary_plain$(a_0, op_0, b_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(op_0, "=>")), run_clo((x_0) => {
  return run_jump($f_lambda_valid$, [a_0, b_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(op_0, "->")), run_clo((x_2) => {
  return run_jump($kt$, ["All", "_", run_loop($ix$(a_0)), 1, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(op_0, "<>")), run_clo((x_4) => {
  return run_jump($kt$, ["Ctr", "Con", 0, 1, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($f_eq$(op_0, "<&>")), run_clo((x_6) => {
  return run_jump($kt$, ["Min", "", 0, 1, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_7) => {
  return run_jump($f_app$, [run_loop($kt$("Ref", run_loop($f_operator$(op_0)), 0, 1, {$: "Nil"})), {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
})]);
})]);
})]);
})]);
}

function $f_do_return$(monad_0, types_0, p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($f_app$(run_loop($ref$((monad_0 + ".pure"))), run_loop($f_concat$(types_0, {$: "Con", ["head"]: n_0, ["tail"]: {$: "Nil"}})))), ["rest"]: ts_0};
}

function $f_do_statement$(monad_0, types_0, p_0, indent_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_0) => {
  return run_jump($f_do_annotated$, [monad_0, types_0, n_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 1)), indent_0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "<-")), run_clo((x_2) => {
  return run_jump($f_do_value$, [monad_0, types_0, run_loop($kt$("Ref", "_", run_loop($ix$(n_0)), 1, {$: "Nil"})), n_0, false, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), indent_0]);
}), run_clo((x_3) => {
  const x_4 = run_loop($f_col$(run_loop($f_skip$(ts_0))));
  const x_5 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), ";"));
  const x_6 = (x_4 === indent_0);
  return run_jump($f_choose$, [run_loop($Bool$and$((x_5 || x_6), run_loop($Bool$not$(run_loop($f_eq$(run_loop($f_tx$(run_loop($f_skip$(ts_0)))), "<eof>")))))), run_clo((x_7) => {
  return run_jump($f_do_value$, [monad_0, types_0, run_loop($kt$("Ref", "_", run_loop($ix$(n_0)), 1, {$: "Nil"})), run_loop($ref$("Unit")), false, {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0}, indent_0]);
}), run_clo((x_8) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
})]);
})]);
})]);
}

function $f_rewrite_motive$(name_0, id_0, e_0, p_0) {
  const motive_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_rewrite_body$, [e_0, run_loop($kt$("Lam", "_", ((id_0 + 2147483648) >>> 0), 1, {$: "Con", ["head"]: run_loop($kt$("Lam", name_0, id_0, 1, {$: "Con", ["head"]: motive_0, ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Nil"}})), run_loop($f_body$(ts_0))]);
}

function $f_namespace$(t_0, ty_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(t_0)), "App")), run_clo((x_0) => {
  return run_jump($kt$, ["App", "", 0, run_loop($qt$(t_0)), {$: "Con", ["head"]: run_loop($f_namespace$(run_loop($kid$(t_0, 0)), ty_0)), ["tail"]: {$: "Con", ["head"]: run_loop($f_namespace$(run_loop($kid$(t_0, 1)), ty_0)), ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(t_0)), "Ref")), run_loop($Char$is_eq$(run_loop($f_head$(run_loop($nm$(t_0)))), ".")))), run_clo((x_2) => {
  const x_3 = run_loop($nm$(ty_0));
  const x_4 = run_loop($nm$(t_0));
  return run_jump($ref$, [(x_3 + x_4)]);
}), run_clo((x_5) => {
  return t_0;
})]);
})]);
}

function $f_equation$(a_0, neg_0, p_0) {
  const b_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_equation_type$, [a_0, b_0, neg_0, run_loop($f_expect$(run_loop($f_expr$(ts_0, 0)), "}"))]);
}

function $f_array_type$(n_0, p_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_array_size$, [n_0, ty_0, run_loop($f_eq$(run_loop($f_tx$(ts_0)), "*")), run_loop($f_expect$(run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), "]"))]);
}

function $f_list$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($f_list_nodes$(run_loop($ks$(n_0)))), ["rest"]: ts_0};
}

function $f_all_body$(name_0, id_0, q_0, exi_0, a_0, p_0) {
  const b_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($f_choose$(exi_0, run_clo((x_0) => {
  return run_jump($f_app$, [run_loop($kt$("Ref", "Exists", 0, 1, {$: "Nil"})), {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Lam", name_0, id_0, q_0, {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["All", name_0, id_0, q_0, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
}))), ["rest"]: ts_0};
}

function $f_matcher_arm$(name_0, p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_matcher_tail$, [name_0, n_0, run_loop($f_matcher$(run_loop($f_skip$(ts_0))))]);
}

function $f_escape_code$(c_0) {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(c_0, "n")), run_clo((x_0) => {
  return 10;
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(c_0, "t")), run_clo((x_2) => {
  return 9;
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(c_0, "r")), run_clo((x_4) => {
  return 13;
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(c_0, "0")), run_clo((x_6) => {
  return 0;
}), run_clo((x_7) => {
  return run_jump($Char$to_u32$, [c_0]);
})]);
})]);
})]);
})]);
}

function $f_match_heads$(ts_0, indent_0, acc_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_0) => {
  return run_jump($f_match_begin$, [run_loop($f_skip$(run_loop($f_tl$(ts_0)))), indent_0, run_loop($List$reverse$(acc_0))]);
}), run_clo((x_1) => {
  return run_jump($f_match_head$, [run_loop($f_expr$(run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), ",")), run_clo((x_2) => {
  return run_jump($f_tl$, [ts_0]);
}), run_clo((x_3) => {
  return ts_0;
}))), 0)), indent_0, acc_0]);
})]);
}

function $f_body_at$(ts_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "-")), run_clo((x_0) => {
  return run_jump($f_erased_local$, [run_loop($f_tl$(ts_0))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "match")), run_clo((x_2) => {
  return run_jump($f_match_heads$, [run_loop($f_tl$(ts_0)), run_loop($f_col$(ts_0)), {$: "Nil"}]);
}), run_clo((x_3) => {
  return run_jump($f_statement$, [run_loop($f_expr$(ts_0, 0))]);
})]);
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

function $f_tail_terms$(xs_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return xt_0;
  }
}

function $f_string_decoded$(d_0) {
  const code_0 = d_0["code"];
  const rest_0 = d_0["rest"];
  const err_0 = d_0["error"];
  return run_jump($f_choose$, [run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($kt$, ["Ctr", "SCon", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Ctr", "Chr", 0, 1, {$: "Con", ["head"]: run_loop($f_u32$(code_0)), ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Con", ["head"]: run_loop($f_string$(rest_0)), ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Error", err_0, 0, 0, {$: "Nil"}]);
})]);
}

function $f_decode_char$(s_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(s_0)), run_clo((x_0) => {
  return {$: "FDecoded", ["code"]: 0, ["rest"]: "", ["error"]: "expected character"};
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "\\")), run_clo((x_2) => {
  return run_jump($f_decode_escape$, [run_loop($f_tail$(s_0))]);
}), run_clo((x_3) => {
  return {$: "FDecoded", ["code"]: run_loop($Char$to_u32$(run_loop($f_head$(s_0)))), ["rest"]: run_loop($f_tail$(s_0)), ["error"]: ""};
})]);
})]);
}

function $f_char_decoded$(d_0) {
  const code_0 = d_0["code"];
  const rest_0 = d_0["rest"];
  const err_0 = d_0["error"];
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($String$is_empty$(err_0)), run_loop($f_eq$(rest_0, "'")))), run_clo((x_0) => {
  return run_jump($kt$, ["Ctr", "Chr", 0, 1, {$: "Con", ["head"]: run_loop($f_u32$(code_0)), ["tail"]: {$: "Nil"}}]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Error", "character literal requires one character and a closing quote", 0, 0, {$: "Nil"}]);
})]);
}

function $f_float_read$(m_0) {
  if (m_0.$ === "None") {
    return run_jump($kt$, ["Error", "invalid f32 literal", 0, 0, {$: "Nil"}]);
  } else {
    const v_0 = m_0["value"];
    return run_jump($f_float_bits$, [f32_bits(v_0)]);
  }
}

function $f_u32$(n_0) {
  return run_jump($kt$, ["Ctr", "U32", 0, 1, {$: "Con", ["head"]: run_loop($f_word$(n_0, 32)), ["tail"]: {$: "Nil"}}]);
}

function $f_nat$(n_0) {
  return run_jump($f_choose$, [(n_0 > 256), run_clo((x_0) => {
  return run_jump($app$, [run_loop($ref$("U32.to_nat")), run_loop($f_u32$(n_0))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [(n_0 === 0), run_clo((x_2) => {
  return run_jump($kt$, ["Ctr", "Zero", 0, 1, {$: "Nil"}]);
}), run_clo((x_3) => {
  return run_jump($kt$, ["Ctr", "Succ", 0, 1, {$: "Con", ["head"]: run_loop($f_nat$(((n_0 - 1) >>> 0))), ["tail"]: {$: "Nil"}}]);
})]);
})]);
}

function $Char$to_u32$(c_0) {
  const x_0 = c_0.codePointAt(0);
  return x_0;
}

function $f_lbind$(pars_0, body_0) {
  if (pars_0.$ === "Nil") {
    return body_0;
  } else {
    const p_0 = pars_0["head"];
    const ps_0 = pars_0["tail"];
    return run_jump($kt$, ["Lam", run_loop($nm$(p_0)), run_loop($ix$(p_0)), run_loop($qt$(p_0)), {$: "Con", ["head"]: run_loop($f_lbind$(ps_0, body_0)), ["tail"]: {$: "Nil"}}]);
  }
}

function $f_parallel_binds$(pats_0, vals_0) {
  if (pats_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const p_0 = pats_0["head"];
    const ps_0 = pats_0["tail"];
    return {$: "Con", ["head"]: run_loop($kt$("Bind", run_loop($nm$(p_0)), run_loop($ix$(p_0)), run_loop($qt$(p_0)), {$: "Con", ["head"]: run_loop($terms_at$(vals_0, 0)), ["tail"]: {$: "Nil"}})), ["tail"]: run_loop($f_parallel_binds$(ps_0, run_loop($f_tail_terms$(vals_0))))};
  }
}

function $f_unlamb$(body_0, n_0) {
  return run_jump($f_choose$, [(n_0 === 0), run_clo((x_0) => {
  return body_0;
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(body_0)), "Lam")), run_clo((x_2) => {
  return run_jump($f_unlamb$, [run_loop($kid$(body_0, 0)), ((n_0 - 1) >>> 0)]);
}), run_clo((x_3) => {
  return run_jump($kt$, ["Error", "cannot match a parallel let binding", 0, 0, {$: "Nil"}]);
})]);
})]);
}

function $f_flat_match$(heads_0, rows_0, vars_0) {
  if (heads_0.$ === "Nil") {
    const x_0 = run_loop($f_len$(rows_0));
    return run_jump($f_choose$, [(x_0 === 0), run_clo((x_1) => {
    return run_jump($atom$, ["Efq"]);
}), run_clo((x_2) => {
    return run_jump($f_flat$, [run_loop($kid$(run_loop($terms_at$(rows_0, 0)), 1)), vars_0]);
})]);
  } else {
    const h_0 = heads_0["head"];
    const hs_0 = heads_0["tail"];
    const x_3 = run_loop($f_len$(rows_0));
    return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(run_loop($f_first_ctor$(rows_0)))), "Absent")), (x_3 > 0))), run_loop($f_has_id$(vars_0, run_loop($ix$(h_0)))))), run_clo((x_4) => {
    return run_jump($f_flat_match$, [hs_0, run_loop($f_var_rows$(rows_0, h_0)), run_loop($f_mark_vars$(vars_0, run_loop($ix$(h_0)), run_loop($f_mark_rows$(rows_0, run_loop($qt$(h_0))))))]);
}), run_clo((x_5) => {
    return run_jump($f_flat_column$, [h_0, hs_0, rows_0, vars_0]);
})]);
  }
}

function $f_flat_local$(t_0, vars_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(run_loop($kid$(t_0, 0)))), "Ctr")), run_clo((x_0) => {
  return run_jump($f_flat_match$, [{$: "Con", ["head"]: run_loop($kid$(t_0, 1)), ["tail"]: {$: "Nil"}}, {$: "Con", ["head"]: run_loop($kt$("Row", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, {$: "Con", ["head"]: run_loop($kid$(t_0, 0)), ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Con", ["head"]: run_loop($kid$(t_0, 2)), ["tail"]: {$: "Nil"}}})), ["tail"]: {$: "Nil"}}, vars_0]);
}), run_clo((x_1) => {
  return run_jump($f_flat_let$, [t_0, vars_0, run_loop($f_flat$(run_loop($kid$(t_0, 2)), {$: "Con", ["head"]: run_loop($kid$(t_0, 0)), ["tail"]: {$: "Nil"}}))]);
})]);
}

function $f_scope_parallel_pats$(t_0, pats_0, env_0, book_0) {
  return run_jump($kt$, ["Parallel", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, pats_0)), ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Values", "", 0, 1, run_loop($f_scope_terms$(run_loop($ks$(run_loop($kid$(t_0, 1)))), env_0, book_0)))), ["tail"]: {$: "Con", ["head"]: run_loop($f_scope_body$(run_loop($kid$(t_0, 2)), run_loop($f_concat$(run_loop($f_penv$(pats_0)), env_0)), book_0)), ["tail"]: {$: "Nil"}}}}]);
}

function $f_patterns$(xs_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_choose$(run_loop($f_eq$(run_loop($tg$(x_0)), "Ref")), run_clo((x_1) => {
    return run_jump($kt$, ["Var", run_loop($nm$(x_0)), run_loop($ix$(x_0)), run_loop($qt$(x_0)), {$: "Nil"}]);
}), run_clo((x_2) => {
    return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(x_0)), "Literal")), run_clo((x_3) => {
    return run_jump($f_literal$, [run_loop($nm$(x_0))]);
}), run_clo((x_4) => {
    return run_jump($kt$, [run_loop($tg$(x_0)), run_loop($nm$(x_0)), run_loop($ix$(x_0)), run_loop($qt$(x_0)), run_loop($f_patterns$(run_loop($ks$(x_0))))]);
})]);
}))), ["tail"]: run_loop($f_patterns$(xt_0))};
  }
}

function $f_scope_local$(t_0, pats_0, env_0, book_0) {
  return run_jump($kt$, ["Local", "", 0, run_loop($qt$(t_0)), {$: "Con", ["head"]: run_loop($terms_at$(pats_0, 0)), ["tail"]: {$: "Con", ["head"]: run_loop($f_scope$(run_loop($kid$(t_0, 1)), env_0, book_0)), ["tail"]: {$: "Con", ["head"]: run_loop($f_scope_body$(run_loop($kid$(t_0, 2)), run_loop($f_concat$(run_loop($f_penv$(pats_0)), env_0)), book_0)), ["tail"]: {$: "Nil"}}}}]);
}

function $f_scope_rows$(rows_0, env_0, book_0) {
  if (rows_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const r_0 = rows_0["head"];
    const rs_0 = rows_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_scope_row$(r_0, run_loop($f_patterns$(run_loop($ks$(run_loop($kid$(r_0, 0)))))), env_0, book_0)), ["tail"]: run_loop($f_scope_rows$(rs_0, env_0, book_0))};
  }
}

function $f_nat_extend$(a_0, b_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(a_0)), "Ctr")), run_loop($f_eq$(run_loop($nm$(a_0)), "Zero")))), run_clo((x_0) => {
  return b_0;
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(a_0)), "Ctr")), run_loop($f_eq$(run_loop($nm$(a_0)), "Succ")))), run_clo((x_2) => {
  return run_jump($kt$, ["Ctr", "Succ", 0, 1, {$: "Con", ["head"]: run_loop($f_nat_extend$(run_loop($kid$(a_0, 0)), b_0)), ["tail"]: {$: "Nil"}}]);
}), run_clo((x_3) => {
  return run_jump($f_app$, [run_loop($ref$("Nat.add")), {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}]);
})]);
})]);
}

function $f_lambda_valid$(a_0, body_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(a_0)), "Ref")), run_loop($Bool$not$(run_loop($f_reserved$(run_loop($nm$(a_0)))))))), run_clo((x_0) => {
  return run_jump($kt$, ["Lam", run_loop($nm$(a_0)), run_loop($ix$(a_0)), run_loop($qt$(a_0)), {$: "Con", ["head"]: body_0, ["tail"]: {$: "Nil"}}]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Error", "a lambda binder must be a non-reserved name", 0, 0, {$: "Nil"}]);
})]);
}

function $f_operator$(s_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "&")), run_clo((x_0) => {
  return "Pair";
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "|")), run_clo((x_2) => {
  return "Or";
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "++")), run_clo((x_4) => {
  return "String.append";
}), run_clo((x_5) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "||")), run_clo((x_6) => {
  return "Bool.or";
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "&&")), run_clo((x_8) => {
  return "Bool.and";
}), run_clo((x_9) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "+")), run_clo((x_10) => {
  return ".add";
}), run_clo((x_11) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "-")), run_clo((x_12) => {
  return ".sub";
}), run_clo((x_13) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "*")), run_clo((x_14) => {
  return ".mul";
}), run_clo((x_15) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "/")), run_clo((x_16) => {
  return ".div";
}), run_clo((x_17) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "%")), run_clo((x_18) => {
  return ".mod";
}), run_clo((x_19) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "<")), run_clo((x_20) => {
  return ".is_lt";
}), run_clo((x_21) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ">op")), run_clo((x_22) => {
  return ".is_gt";
}), run_clo((x_23) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "<=")), run_clo((x_24) => {
  return ".is_le";
}), run_clo((x_25) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ">=")), run_clo((x_26) => {
  return ".is_ge";
}), run_clo((x_27) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, "<<")), run_clo((x_28) => {
  return ".shln";
}), run_clo((x_29) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ">>op")), run_clo((x_30) => {
  return ".shrn";
}), run_clo((x_31) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ".&.")), run_clo((x_32) => {
  return ".and";
}), run_clo((x_33) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ".|.")), run_clo((x_34) => {
  return ".or";
}), run_clo((x_35) => {
  return run_jump($f_choose$, [run_loop($f_eq$(s_0, ".^.")), run_clo((x_36) => {
  return ".xor";
}), run_clo((x_37) => {
  return s_0;
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
})]);
})]);
})]);
})]);
})]);
})]);
})]);
})]);
}

function $f_do_annotated$(monad_0, types_0, binder_0, p_0, indent_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_do_value$, [monad_0, types_0, binder_0, ty_0, run_loop($f_eq$(run_loop($f_tx$(ts_0)), "=")), run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0)), indent_0]);
}

function $f_do_value$(monad_0, types_0, binder_0, ty_0, pure_0, p_0, indent_0) {
  const v_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_do_tail$, [monad_0, types_0, binder_0, ty_0, pure_0, v_0, run_loop($f_do$(monad_0, types_0, run_loop($f_skip$(ts_0)), indent_0))]);
}

function $f_rewrite_body$(e_0, motive_0, p_0) {
  const body_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Rwt", "", 0, 1, {$: "Con", ["head"]: e_0, ["tail"]: {$: "Con", ["head"]: motive_0, ["tail"]: {$: "Con", ["head"]: body_0, ["tail"]: {$: "Nil"}}}})), ["rest"]: ts_0};
}

function $f_equation_type$(a_0, b_0, neg_0, p_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($f_choose$(neg_0, run_clo((x_0) => {
  return run_jump($kt$, ["All", "_", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Eql", "", 0, 1, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}}}})), ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Ref", "Empty", 0, 1, {$: "Nil"})), ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Eql", "", 0, 1, {$: "Con", ["head"]: a_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}}}}]);
}))), ["rest"]: ts_0};
}

function $f_array_size$(n_0, ty_0, count_0, p_0) {
  const size_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($f_app$(run_loop($ref$("Array.new")), {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Con", ["head"]: run_loop($f_choose$(count_0, run_clo((x_0) => {
  return run_jump($f_array_depth$, [size_0]);
}), run_clo((x_1) => {
  return size_0;
}))), ["tail"]: {$: "Con", ["head"]: n_0, ["tail"]: {$: "Nil"}}}})), ["rest"]: ts_0};
}

function $f_list_nodes$(xs_0) {
  if (xs_0.$ === "Nil") {
    return run_jump($kt$, ["Ctr", "Nil", 0, 1, {$: "Nil"}]);
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return run_jump($kt$, ["Ctr", "Con", 0, 1, {$: "Con", ["head"]: x_0, ["tail"]: {$: "Con", ["head"]: run_loop($f_list_nodes$(xt_0)), ["tail"]: {$: "Nil"}}}]);
  }
}

function $f_matcher_tail$(name_0, n_0, p_0) {
  const m_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Mat", name_0, 0, 1, {$: "Con", ["head"]: n_0, ["tail"]: {$: "Con", ["head"]: m_0, ["tail"]: {$: "Nil"}}})), ["rest"]: ts_0};
}

function $f_match_begin$(ts_0, outer_0, heads_0) {
  const x_0 = run_loop($f_col$(ts_0));
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "case")), (x_0 > outer_0))), run_clo((x_1) => {
  const x_2 = run_loop($f_col$(ts_0));
  return run_jump($f_match_cases$, [ts_0, ((x_2 - 1) >>> 0), heads_0, {$: "Nil"}]);
}), run_clo((x_3) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Match", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Heads", "", 0, 1, heads_0)), ["tail"]: {$: "Nil"}})), ["rest"]: ts_0};
})]);
}

function $f_match_head$(p_0, indent_0, acc_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(n_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  return run_jump($f_match_heads$, [ts_0, indent_0, {$: "Con", ["head"]: n_0, ["tail"]: acc_0}]);
})]);
}

function $f_erased_local$(ts_0) {
  return run_jump($f_statement$, [{$: "FParsed", ["term"]: run_loop($kt$("Ref", run_loop($f_tx$(ts_0)), run_loop($f_atid$(ts_0)), 0, {$: "Nil"})), ["rest"]: run_loop($f_tl$(ts_0))}]);
}

function $f_statement$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "=")), run_clo((x_0) => {
  return run_jump($f_let_value$, [n_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0))]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_2) => {
  return run_jump($f_typed_let_try$, [n_0, ts_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0))]);
}), run_clo((x_3) => {
  return run_jump($f_statement_more$, [{$: "FParsed", ["term"]: n_0, ["rest"]: ts_0}]);
})]);
})]);
}

function $f_decode_escape$(s_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "u")), run_loop($Char$is_eq$(run_loop($f_head$(run_loop($f_tail$(s_0)))), "{")))), run_clo((x_0) => {
  return run_jump($f_decode_unicode$, [run_loop($f_tail$(run_loop($f_tail$(s_0)))), 0, 0]);
}), run_clo((x_1) => {
  return run_jump($f_choose$, [run_loop($f_escape_valid$(run_loop($f_head$(s_0)))), run_clo((x_2) => {
  return {$: "FDecoded", ["code"]: run_loop($f_escape_code$(run_loop($f_head$(s_0)))), ["rest"]: run_loop($f_tail$(s_0)), ["error"]: ""};
}), run_clo((x_3) => {
  return {$: "FDecoded", ["code"]: 0, ["rest"]: s_0, ["error"]: "invalid character escape"};
})]);
})]);
}

function $f_float_bits$(bits_0) {
  const x_0 = ((bits_0 & 2139095040) >>> 0);
  return run_jump($f_choose$, [(x_0 === 2139095040), run_clo((x_1) => {
  return run_jump($kt$, ["Error", "float literal must be finite", 0, 0, {$: "Nil"}]);
}), run_clo((x_2) => {
  return run_jump($kt$, ["Ctr", "F32", 0, 1, {$: "Con", ["head"]: run_loop($f_word$(bits_0, 32)), ["tail"]: {$: "Nil"}}]);
})]);
}

function $f_word$(n_0, bits_0) {
  return run_jump($f_choose$, [(bits_0 === 0), run_clo((x_0) => {
  return run_jump($kt$, ["Ctr", "WNil", 0, 1, {$: "Nil"}]);
}), run_clo((x_1) => {
  const x_2 = ((n_0 & 1) >>> 0);
  return run_jump($kt$, ["Ctr", "WCon", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Ctr", run_loop($f_choose$((x_2 === 0), run_clo((x_3) => {
  return "False";
}), run_clo((x_4) => {
  return "True";
}))), 0, 1, {$: "Nil"})), ["tail"]: {$: "Con", ["head"]: run_loop($f_word$((1n >= 32n ? 0 : (n_0 >>> Number(1n)) >>> 0), ((bits_0 - 1) >>> 0))), ["tail"]: {$: "Nil"}}}]);
})]);
}

function $f_first_ctor$(rows_0) {
  if (rows_0.$ === "Nil") {
    return run_jump($atom$, ["Absent"]);
  } else {
    const r_0 = rows_0["head"];
    const rs_0 = rows_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(run_loop($f_rowpat$(r_0)))), "Ctr")), run_clo((x_0) => {
    return run_jump($f_rowpat$, [r_0]);
}), run_clo((x_1) => {
    return run_jump($f_first_ctor$, [rs_0]);
})]);
  }
}

function $f_has_id$(vars_0, id_0) {
  if (vars_0.$ === "Nil") {
    return false;
  } else {
    const v_0 = vars_0["head"];
    const vs_0 = vars_0["tail"];
    const x_0 = run_loop($ix$(v_0));
    const x_1 = (x_0 === id_0);
    const x_2 = run_loop($f_has_id$(vs_0, id_0));
    return (x_1 || x_2);
  }
}

function $f_var_rows$(rows_0, v_0) {
  if (rows_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const r_0 = rows_0["head"];
    const rs_0 = rows_0["tail"];
    return {$: "Con", ["head"]: run_loop($kt$("Row", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, run_loop($f_tail_terms$(run_loop($ks$(run_loop($kid$(r_0, 0)))))))), ["tail"]: {$: "Con", ["head"]: run_loop($f_sub$(run_loop($kid$(r_0, 1)), run_loop($ix$(run_loop($f_rowpat$(r_0)))), v_0)), ["tail"]: {$: "Nil"}}})), ["tail"]: run_loop($f_var_rows$(rs_0, v_0))};
  }
}

function $f_mark_vars$(vars_0, id_0, q_0) {
  if (vars_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const v_0 = vars_0["head"];
    const vs_0 = vars_0["tail"];
    const x_0 = run_loop($ix$(v_0));
    return {$: "Con", ["head"]: run_loop($f_choose$((x_0 === id_0), run_clo((x_1) => {
    return run_jump($kt$, ["Var", run_loop($nm$(v_0)), run_loop($ix$(v_0)), q_0, {$: "Nil"}]);
}), run_clo((x_2) => {
    return v_0;
}))), ["tail"]: run_loop($f_mark_vars$(vs_0, id_0, q_0))};
  }
}

function $f_mark_rows$(rows_0, q_0) {
  if (rows_0.$ === "Nil") {
    return q_0;
  } else {
    const r_0 = rows_0["head"];
    const rs_0 = rows_0["tail"];
    const x_0 = run_loop($qt$(run_loop($f_rowpat$(r_0))));
    return run_jump($f_mark_rows$, [rs_0, run_loop($f_choose$(run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(run_loop($f_rowpat$(r_0)))), "Var")), (x_0 === 2))), run_clo((x_1) => {
    return 2;
}), run_clo((x_2) => {
    return q_0;
})))]);
  }
}

function $f_flat_column$(h_0, hs_0, rows_0, vars_0) {
  if (vars_0.$ === "Nil") {
    return run_jump($kt$, ["Error", "match requires an unconsumed parameter or constructor field", 0, 0, {$: "Nil"}]);
  } else {
    const v_0 = vars_0["head"];
    const vs_0 = vars_0["tail"];
    const x_0 = run_loop($ix$(h_0));
    const x_1 = run_loop($ix$(v_0));
    return run_jump($f_choose$, [(x_0 === x_1), run_clo((x_2) => {
    return run_jump($f_flat_split$, [h_0, hs_0, rows_0, v_0, vs_0, run_loop($f_first_ctor$(rows_0))]);
}), run_clo((x_3) => {
    return run_jump($kt$, ["Lam", run_loop($nm$(v_0)), run_loop($ix$(v_0)), run_loop($qt$(v_0)), {$: "Con", ["head"]: run_loop($f_flat_match$({$: "Con", ["head"]: h_0, ["tail"]: hs_0}, rows_0, vs_0)), ["tail"]: {$: "Nil"}}]);
})]);
  }
}

function $f_flat_let$(t_0, vars_0, body_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(body_0)), "Lam")), run_clo((x_0) => {
  return run_jump($f_lbind$, [vars_0, run_loop($kt$("Let", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Bind", run_loop($nm$(run_loop($kid$(t_0, 0)))), run_loop($ix$(run_loop($kid$(t_0, 0)))), run_loop($qt$(run_loop($kid$(t_0, 0)))), {$: "Con", ["head"]: run_loop($kid$(t_0, 1)), ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Con", ["head"]: run_loop($kid$(body_0, 0)), ["tail"]: {$: "Nil"}}}))]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Error", "a match cannot scrutinize a local binding", 0, 0, {$: "Nil"}]);
})]);
}

function $f_penv$(xs_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(x_0)), "Var")), run_clo((x_1) => {
    return {$: "Con", ["head"]: x_0, ["tail"]: run_loop($f_penv$(xt_0))};
}), run_clo((x_2) => {
    return run_jump($f_concat$, [run_loop($f_penv$(run_loop($ks$(x_0)))), run_loop($f_penv$(xt_0))]);
})]);
  }
}

function $f_scope_row$(r_0, pats_0, env_0, book_0) {
  return run_jump($f_scope_row_valid$, [r_0, pats_0, env_0, book_0, run_loop($f_valid_patterns$(pats_0, book_0))]);
}

function $f_do_tail$(monad_0, types_0, binder_0, ty_0, pure_0, v_0, p_0) {
  const body_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($f_choose$(pure_0, run_clo((x_0) => {
  return run_jump($kt$, ["Local", "", 0, 1, {$: "Con", ["head"]: binder_0, ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Ann", "", 0, 1, {$: "Con", ["head"]: v_0, ["tail"]: {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}}})), ["tail"]: {$: "Con", ["head"]: body_0, ["tail"]: {$: "Nil"}}}}]);
}), run_clo((x_1) => {
  return run_jump($f_app$, [run_loop($ref$((monad_0 + ".bind"))), run_loop($f_concat$(run_loop($f_init$(types_0)), {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Con", ["head"]: run_loop($f_last$(types_0)), ["tail"]: {$: "Con", ["head"]: v_0, ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Lam", run_loop($nm$(binder_0)), run_loop($ix$(binder_0)), run_loop($qt$(binder_0)), {$: "Con", ["head"]: body_0, ["tail"]: {$: "Nil"}})), ["tail"]: {$: "Nil"}}}}}))]);
}))), ["rest"]: ts_0};
}

function $f_array_depth$(size_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(size_0)), "Literal")), run_clo((x_0) => {
  return run_jump($f_power_depth$, [run_loop($nm$(size_0)), 0]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Error", "array count must be a literal power of two", 0, 0, {$: "Nil"}]);
})]);
}

function $f_match_cases$(ts_0, indent_0, heads_0, rows_0) {
  const x_0 = run_loop($f_col$(ts_0));
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), "case")), (x_0 > indent_0))), run_clo((x_1) => {
  return run_jump($f_case_pats$, [run_loop($f_tl$(ts_0)), indent_0, heads_0, rows_0, {$: "Nil"}]);
}), run_clo((x_2) => {
  return {$: "FParsed", ["term"]: run_loop($kt$("Match", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Heads", "", 0, 1, heads_0)), ["tail"]: run_loop($List$reverse$(rows_0))})), ["rest"]: ts_0};
})]);
}

function $f_let_value$(pat_0, p_0) {
  const v_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_let_body$, [pat_0, v_0, run_loop($f_body$(ts_0))]);
}

function $f_typed_let_try$(n_0, old_0, p_0) {
  const ty_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "=")), run_clo((x_0) => {
  return run_jump($f_let_value$, [n_0, run_loop($f_let_ann$(ty_0, run_loop($f_expr$(run_loop($f_tl$(ts_0)), 0))))]);
}), run_clo((x_1) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: old_0};
})]);
}

function $f_statement_more$(p_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(n_0)), "Write")), run_clo((x_0) => {
  return run_jump($f_write_statement$, [n_0, ts_0]);
}), run_clo((x_1) => {
  const x_2 = run_loop($f_kind$(ts_0));
  const x_3 = (x_2 === 1);
  const x_4 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), "+bind"));
  return run_jump($f_choose$, [(x_3 || x_4), run_clo((x_5) => {
  return run_jump($f_parallel$, [ts_0, {$: "Con", ["head"]: n_0, ["tail"]: {$: "Nil"}}]);
}), run_clo((x_6) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
})]);
})]);
}

function $f_decode_unicode$(s_0, code_0, count_0) {
  return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($Char$is_eq$(run_loop($f_head$(s_0)), "}")), (count_0 > 0))), run_clo((x_0) => {
  return {$: "FDecoded", ["code"]: code_0, ["rest"]: run_loop($f_tail$(s_0)), ["error"]: ""};
}), run_clo((x_1) => {
  const x_2 = run_loop($f_hex$(run_loop($f_head$(s_0))));
  return run_jump($f_choose$, [run_loop($Bool$and$((x_2 < 16), (count_0 < 6))), run_clo((x_3) => {
  const x_4 = (Math.imul(code_0, 16) >>> 0);
  const x_5 = run_loop($f_hex$(run_loop($f_head$(s_0))));
  return run_jump($f_decode_unicode$, [run_loop($f_tail$(s_0)), ((x_4 + x_5) >>> 0), ((count_0 + 1) >>> 0)]);
}), run_clo((x_6) => {
  return {$: "FDecoded", ["code"]: 0, ["rest"]: s_0, ["error"]: "invalid Unicode escape"};
})]);
})]);
}

function $f_escape_valid$(c_0) {
  const x_0 = run_loop($Char$is_eq$(c_0, "n"));
  const x_1 = run_loop($Char$is_eq$(c_0, "t"));
  const x_2 = (x_0 || x_1);
  const x_3 = run_loop($Char$is_eq$(c_0, "r"));
  const x_4 = (x_2 || x_3);
  const x_5 = run_loop($Char$is_eq$(c_0, "0"));
  const x_6 = (x_4 || x_5);
  const x_7 = run_loop($Char$is_eq$(c_0, "\\"));
  const x_8 = (x_6 || x_7);
  const x_9 = run_loop($Char$is_eq$(c_0, "'"));
  const x_10 = (x_8 || x_9);
  const x_11 = run_loop($Char$is_eq$(c_0, "\""));
  return (x_10 || x_11);
}

function $f_rowpat$(r_0) {
  return run_jump($kid$, [run_loop($kid$(r_0, 0)), 0]);
}

function $f_flat_split$(h_0, hs_0, rows_0, v_0, vs_0, c_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(c_0)), "Absent")), run_clo((x_0) => {
  return run_jump($atom$, ["Efq"]);
}), run_clo((x_1) => {
  const x_2 = run_loop($ix$(c_0));
  return run_jump($f_flat_fields$, [h_0, hs_0, rows_0, v_0, vs_0, c_0, run_loop($f_mark_fields$(run_loop($f_fresh_fields$(run_loop($ks$(c_0)), ((2147483648 + x_2) >>> 0))), run_loop($f_mark_rows$(rows_0, run_loop($qt$(v_0))))))]);
})]);
}

function $f_scope_row_valid$(r_0, pats_0, env_0, book_0, err_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($kt$, ["Row", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, pats_0)), ["tail"]: {$: "Con", ["head"]: run_loop($f_scope_body$(run_loop($kid$(r_0, 1)), run_loop($f_concat$(run_loop($f_penv$(pats_0)), env_0)), book_0)), ["tail"]: {$: "Nil"}}}]);
}), run_clo((x_1) => {
  return run_jump($kt$, ["Row", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, pats_0)), ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Error", err_0, 0, 0, {$: "Nil"})), ["tail"]: {$: "Nil"}}}]);
})]);
}

function $f_valid_patterns$(ps_0, book_0) {
  if (ps_0.$ === "Nil") {
    return "";
  } else {
    const p_0 = ps_0["head"];
    const rest_0 = ps_0["tail"];
    return run_jump($f_valid_patterns_next$, [run_loop($f_valid_pattern$(p_0, book_0)), rest_0, book_0]);
  }
}

function $f_init$(xs_0) {
  if (xs_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    const x_1 = run_loop($f_len$(xt_0));
    return run_jump($f_choose$, [(x_1 === 0), run_clo((x_2) => {
    return {$: "Nil"};
}), run_clo((x_3) => {
    return {$: "Con", ["head"]: x_0, ["tail"]: run_loop($f_init$(xt_0))};
})]);
  }
}

function $f_last$(xs_0) {
  if (xs_0.$ === "Nil") {
    return run_jump($atom$, ["Absent"]);
  } else {
    const x_0 = xs_0["head"];
    const xt_0 = xs_0["tail"];
    const x_1 = run_loop($f_len$(xt_0));
    return run_jump($f_choose$, [(x_1 === 0), run_clo((x_2) => {
    return x_0;
}), run_clo((x_3) => {
    return run_jump($f_last$, [xt_0]);
})]);
  }
}

function $f_power_depth$(s_0, n_0) {
  const x_0 = run_loop($String$is_empty$(s_0));
  const x_1 = run_loop($f_eq$(s_0, "n"));
  return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
  return run_jump($f_power_bits$, [n_0, 0]);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($Char$is_digit$(run_loop($f_head$(s_0)))), run_clo((x_4) => {
  const x_5 = run_loop($Char$to_u32$(run_loop($f_head$(s_0))));
  const x_6 = (Math.imul(n_0, 10) >>> 0);
  const x_7 = ((x_5 - 48) >>> 0);
  return run_jump($f_power_depth$, [run_loop($f_tail$(s_0)), ((x_6 + x_7) >>> 0)]);
}), run_clo((x_8) => {
  return run_jump($kt$, ["Error", "array count must be a literal power of two", 0, 0, {$: "Nil"}]);
})]);
})]);
}

function $f_case_pats$(ts_0, indent_0, heads_0, rows_0, pats_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), ":")), run_clo((x_0) => {
  return run_jump($f_case_body$, [run_loop($f_body_context$(run_loop($f_tl$(ts_0)), ((indent_0 + 1) >>> 0))), indent_0, heads_0, rows_0, run_loop($List$reverse$(pats_0))]);
}), run_clo((x_1) => {
  return run_jump($f_case_pat$, [run_loop($f_expr$(run_loop($f_choose$(run_loop($f_eq$(run_loop($f_tx$(ts_0)), ",")), run_clo((x_2) => {
  return run_jump($f_tl$, [ts_0]);
}), run_clo((x_3) => {
  return ts_0;
}))), 0)), indent_0, heads_0, rows_0, pats_0]);
})]);
}

function $f_let_body$(pat_0, v_0, p_0) {
  const b_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Local", "", 0, 1, {$: "Con", ["head"]: pat_0, ["tail"]: {$: "Con", ["head"]: v_0, ["tail"]: {$: "Con", ["head"]: b_0, ["tail"]: {$: "Nil"}}}})), ["rest"]: ts_0};
}

function $f_let_ann$(ty_0, p_0) {
  const v_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Ann", "", 0, 1, {$: "Con", ["head"]: v_0, ["tail"]: {$: "Con", ["head"]: ty_0, ["tail"]: {$: "Nil"}}})), ["rest"]: ts_0};
}

function $f_write_statement$(n_0, ts_0) {
  const x_0 = run_loop($ix$(n_0));
  const x_1 = run_loop($f_col$(run_loop($f_skip$(ts_0))));
  const x_2 = ((x_0 & 65535) >>> 0);
  const x_3 = run_loop($f_eq$(run_loop($f_tx$(ts_0)), ";"));
  const x_4 = (x_1 === x_2);
  return run_jump($f_choose$, [run_loop($Bool$and$((x_3 || x_4), run_loop($Bool$not$(run_loop($f_eq$(run_loop($f_tx$(run_loop($f_skip$(ts_0)))), "<eof>")))))), run_clo((x_5) => {
  return run_jump($f_let_value$, [run_loop($kt$("Ref", run_loop($nm$(n_0)), run_loop($ix$(n_0)), 1, {$: "Nil"})), {$: "FParsed", ["term"]: run_loop($kid$(n_0, 0)), ["rest"]: ts_0}]);
}), run_clo((x_6) => {
  return {$: "FParsed", ["term"]: run_loop($kid$(n_0, 0)), ["rest"]: ts_0};
})]);
}

function $f_parallel$(ts_0, pats_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($f_tx$(ts_0)), "=")), run_clo((x_0) => {
  return run_jump($f_parallel_values$, [run_loop($f_tl$(ts_0)), run_loop($List$reverse$(pats_0)), run_loop($f_len$(pats_0)), {$: "Nil"}]);
}), run_clo((x_1) => {
  return run_jump($f_parallel_pat$, [run_loop($f_expr$(ts_0, 0)), pats_0]);
})]);
}

function $f_hex$(c_0) {
  return run_jump($f_choose$, [run_loop($Char$is_digit$(c_0)), run_clo((x_0) => {
  const x_1 = run_loop($Char$to_u32$(c_0));
  return ((x_1 - 48) >>> 0);
}), run_clo((x_2) => {
  const x_3 = run_loop($Char$to_u32$(run_loop($Char$to_lower$(c_0))));
  const x_4 = run_loop($Char$to_u32$(run_loop($Char$to_lower$(c_0))));
  return run_jump($f_choose$, [run_loop($Bool$and$((x_3 >= 97), (x_4 <= 102))), run_clo((x_5) => {
  const x_6 = run_loop($Char$to_u32$(run_loop($Char$to_lower$(c_0))));
  return ((x_6 - 87) >>> 0);
}), run_clo((x_7) => {
  return 16;
})]);
})]);
}

function $f_flat_fields$(h_0, hs_0, rows_0, v_0, vs_0, c_0, fields_0) {
  return run_jump($kt$, ["Mat", run_loop($nm$(c_0)), 0, 1, {$: "Con", ["head"]: run_loop($f_flat_match$(run_loop($f_concat$(fields_0, hs_0)), run_loop($f_hit_rows$(rows_0, c_0, fields_0, v_0)), run_loop($f_concat$(fields_0, vs_0)))), ["tail"]: {$: "Con", ["head"]: run_loop($f_flat_match$({$: "Con", ["head"]: h_0, ["tail"]: hs_0}, run_loop($f_miss_rows$(rows_0, run_loop($nm$(c_0)))), {$: "Con", ["head"]: v_0, ["tail"]: vs_0})), ["tail"]: {$: "Nil"}}}]);
}

function $f_mark_fields$(vars_0, q_0) {
  if (vars_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const v_0 = vars_0["head"];
    const vs_0 = vars_0["tail"];
    return {$: "Con", ["head"]: run_loop($kt$("Var", run_loop($nm$(v_0)), run_loop($ix$(v_0)), run_loop($f_choose$((q_0 === 2), run_clo((x_0) => {
    return 2;
}), run_clo((x_1) => {
    return run_jump($qt$, [v_0]);
}))), {$: "Nil"})), ["tail"]: run_loop($f_mark_fields$(vs_0, q_0))};
  }
}

function $f_fresh_fields$(ps_0, id_0) {
  if (ps_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const p_0 = ps_0["head"];
    const rest_0 = ps_0["tail"];
    return {$: "Con", ["head"]: run_loop($f_choose$(run_loop($f_eq$(run_loop($tg$(p_0)), "Var")), run_clo((x_0) => {
    return p_0;
}), run_clo((x_1) => {
    return run_jump($kt$, ["Var", "_field", id_0, 1, {$: "Nil"}]);
}))), ["tail"]: run_loop($f_fresh_fields$(rest_0, ((id_0 + 1) >>> 0)))};
  }
}

function $f_valid_patterns_next$(err_0, ps_0, book_0) {
  return run_jump($f_choose$, [run_loop($String$is_empty$(err_0)), run_clo((x_0) => {
  return run_jump($f_valid_patterns$, [ps_0, book_0]);
}), run_clo((x_1) => {
  return err_0;
})]);
}

function $f_valid_pattern$(p_0, book_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(p_0)), "Var")), run_clo((x_0) => {
  return run_jump($f_choose$, [run_loop($f_reserved$(run_loop($nm$(p_0)))), run_clo((x_1) => {
  const x_2 = run_loop($nm$(p_0));
  return ("reserved pattern binder: " + x_2);
}), run_clo((x_3) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($dk$(run_loop($f_ctor_lookup$(run_loop($nm$(p_0)), book_0)))), "Missing")), run_clo((x_4) => {
  return "";
}), run_clo((x_5) => {
  const x_6 = run_loop($nm$(p_0));
  return ("a constructor pattern requires braces: " + x_6);
})]);
})]);
}), run_clo((x_7) => {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(p_0)), "Ctr")), run_clo((x_8) => {
  return run_jump($f_valid_ctor_pattern$, [p_0, run_loop($f_ctor_lookup$(run_loop($nm$(p_0)), book_0)), book_0]);
}), run_clo((x_9) => {
  return "expected a binder or constructor pattern";
})]);
})]);
}

function $f_power_bits$(n_0, d_0) {
  return run_jump($f_choose$, [(n_0 === 1), run_clo((x_0) => {
  return run_jump($f_nat$, [d_0]);
}), run_clo((x_1) => {
  const x_2 = ((n_0 & 1) >>> 0);
  const x_3 = (n_0 === 0);
  const x_4 = (x_2 === 1);
  return run_jump($f_choose$, [(x_3 || x_4), run_clo((x_5) => {
  return run_jump($kt$, ["Error", "array count must be a positive power of two", 0, 0, {$: "Nil"}]);
}), run_clo((x_6) => {
  return run_jump($f_power_bits$, [(1n >= 32n ? 0 : (n_0 >>> Number(1n)) >>> 0), ((d_0 + 1) >>> 0)]);
})]);
})]);
}

function $f_case_body$(p_0, indent_0, heads_0, rows_0, pats_0) {
  return run_jump($f_case_checked$, [p_0, indent_0, heads_0, rows_0, pats_0]);
}

function $f_case_pat$(p_0, indent_0, heads_0, rows_0, pats_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(n_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  return run_jump($f_case_pats$, [ts_0, indent_0, heads_0, rows_0, {$: "Con", ["head"]: n_0, ["tail"]: pats_0}]);
})]);
}

function $f_parallel_values$(ts_0, pats_0, left_0, vals_0) {
  return run_jump($f_choose$, [(left_0 === 0), run_clo((x_0) => {
  return run_jump($f_parallel_body$, [pats_0, run_loop($List$reverse$(vals_0)), run_loop($f_body$(ts_0))]);
}), run_clo((x_1) => {
  return run_jump($f_parallel_value$, [run_loop($f_expr$(ts_0, 0)), pats_0, left_0, vals_0]);
})]);
}

function $f_parallel_pat$(p_0, pats_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(n_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  return run_jump($f_parallel$, [ts_0, {$: "Con", ["head"]: n_0, ["tail"]: pats_0}]);
})]);
}

function $Char$to_lower$(c_0) {
  const x_0 = run_loop($Bool$to_u32$(run_loop($Char$is_upper$(c_0))));
  const x_1 = run_loop($Char$to_u32$(c_0));
  const x_2 = (Math.imul(x_0, 32) >>> 0);
  return char_new(((x_1 + x_2) >>> 0));
}

function $f_hit_rows$(rows_0, c_0, fields_0, v_0) {
  if (rows_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const r_0 = rows_0["head"];
    const rs_0 = rows_0["tail"];
    const x_0 = run_loop($f_eq$(run_loop($tg$(run_loop($f_rowpat$(r_0)))), "Var"));
    const x_1 = run_loop($f_eq$(run_loop($nm$(run_loop($f_rowpat$(r_0)))), run_loop($nm$(c_0))));
    return run_jump($f_choose$, [(x_0 || x_1), run_clo((x_2) => {
    return {$: "Con", ["head"]: run_loop($f_hit_row$(r_0, c_0, fields_0, v_0)), ["tail"]: run_loop($f_hit_rows$(rs_0, c_0, fields_0, v_0))};
}), run_clo((x_3) => {
    return run_jump($f_hit_rows$, [rs_0, c_0, fields_0, v_0]);
})]);
  }
}

function $f_miss_rows$(rows_0, name_0) {
  if (rows_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const r_0 = rows_0["head"];
    const rs_0 = rows_0["tail"];
    return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($tg$(run_loop($f_rowpat$(r_0)))), "Ctr")), run_loop($f_eq$(run_loop($nm$(run_loop($f_rowpat$(r_0)))), name_0)))), run_clo((x_0) => {
    return run_jump($f_miss_rows$, [rs_0, name_0]);
}), run_clo((x_1) => {
    return {$: "Con", ["head"]: r_0, ["tail"]: run_loop($f_miss_rows$(rs_0, name_0))};
})]);
  }
}

function $f_ctor_lookup$(name_0, book_0) {
  if (book_0.$ === "Nil") {
    return run_jump($f_find$, [name_0, {$: "Nil"}]);
  } else {
    const d_0 = book_0["head"];
    const ds_0 = book_0["tail"];
    return run_jump($f_choose$, [run_loop($Bool$and$(run_loop($f_eq$(run_loop($dk$(d_0)), "Ctr")), run_loop($f_eq$(run_loop($dn$(d_0)), name_0)))), run_clo((x_0) => {
    return d_0;
}), run_clo((x_1) => {
    return run_jump($f_ctor_more$, [name_0, run_loop($f_ctor_lookup$(name_0, run_loop($dc$(d_0)))), ds_0]);
})]);
  }
}

function $f_valid_ctor_pattern$(p_0, ctr_0, book_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($dk$(ctr_0)), "Missing")), run_clo((x_0) => {
  const x_1 = run_loop($nm$(p_0));
  return ("unknown constructor pattern: " + x_1);
}), run_clo((x_2) => {
  const x_3 = run_loop($da$(ctr_0));
  const x_4 = run_loop($f_len$(run_loop($ks$(p_0))));
  return run_jump($f_choose$, [(x_3 === x_4), run_clo((x_5) => {
  return run_jump($f_valid_patterns$, [run_loop($ks$(p_0)), book_0]);
}), run_clo((x_6) => {
  const x_7 = run_loop($nm$(p_0));
  return ("constructor pattern field count differs: " + x_7);
})]);
})]);
}

function $f_case_checked$(p_0, indent_0, heads_0, rows_0, pats_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  const x_0 = run_loop($f_len$(pats_0));
  const x_1 = run_loop($f_len$(heads_0));
  return run_jump($f_choose$, [(x_0 === x_1), run_clo((x_2) => {
  return run_jump($f_match_cases$, [run_loop($f_skip$(ts_0)), indent_0, heads_0, {$: "Con", ["head"]: run_loop($kt$("Row", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, pats_0)), ["tail"]: {$: "Con", ["head"]: n_0, ["tail"]: {$: "Nil"}}})), ["tail"]: rows_0}]);
}), run_clo((x_3) => {
  return run_jump($f_err$, [ts_0, "one pattern is required per match scrutinee"]);
})]);
}

function $f_parallel_body$(pats_0, vals_0, p_0) {
  const body_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return {$: "FParsed", ["term"]: run_loop($kt$("Parallel", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, pats_0)), ["tail"]: {$: "Con", ["head"]: run_loop($kt$("Values", "", 0, 1, vals_0)), ["tail"]: {$: "Con", ["head"]: body_0, ["tail"]: {$: "Nil"}}}})), ["rest"]: ts_0};
}

function $f_parallel_value$(p_0, pats_0, left_0, vals_0) {
  const n_0 = p_0["term"];
  const ts_0 = p_0["rest"];
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($tg$(n_0)), "Error")), run_clo((x_0) => {
  return {$: "FParsed", ["term"]: n_0, ["rest"]: ts_0};
}), run_clo((x_1) => {
  return run_jump($f_parallel_values$, [ts_0, pats_0, ((left_0 - 1) >>> 0), {$: "Con", ["head"]: n_0, ["tail"]: vals_0}]);
})]);
}

function $Bool$to_u32$(b_0) {
  if (!b_0) {
    return 0;
  } else {
    return 1;
  }
}

function $f_hit_row$(r_0, c_0, fields_0, v_0) {
  return run_jump($kt$, ["Row", "", 0, 1, {$: "Con", ["head"]: run_loop($kt$("Patterns", "", 0, 1, run_loop($f_concat$(run_loop($f_choose$(run_loop($f_eq$(run_loop($tg$(run_loop($f_rowpat$(r_0)))), "Var")), run_clo((x_0) => {
  return fields_0;
}), run_clo((x_1) => {
  return run_jump($ks$, [run_loop($f_rowpat$(r_0))]);
}))), run_loop($f_tail_terms$(run_loop($ks$(run_loop($kid$(r_0, 0)))))))))), ["tail"]: {$: "Con", ["head"]: run_loop($f_sub$(run_loop($f_choose$(run_loop($f_eq$(run_loop($tg$(run_loop($f_rowpat$(r_0)))), "Var")), run_clo((x_2) => {
  return run_jump($f_sub$, [run_loop($kid$(r_0, 1)), run_loop($ix$(run_loop($f_rowpat$(r_0)))), v_0]);
}), run_clo((x_3) => {
  return run_jump($kid$, [r_0, 1]);
}))), run_loop($ix$(v_0)), run_loop($kt$("Ctr", run_loop($nm$(c_0)), 0, 1, fields_0)))), ["tail"]: {$: "Nil"}}}]);
}

function $f_ctor_more$(name_0, found_0, rest_0) {
  return run_jump($f_choose$, [run_loop($f_eq$(run_loop($dk$(found_0)), "Missing")), run_clo((x_0) => {
  return run_jump($f_ctor_lookup$, [name_0, rest_0]);
}), run_clo((x_1) => {
  return found_0;
})]);
}
export default {
  "f_load_graph": run_lib($f_load_graph$, 2),
  "check_book": run_lib($check_book$, 1),
  "check_from_exact_prefix": run_lib($check_from_exact_prefix$, 2),
};
