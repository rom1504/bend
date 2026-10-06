# Exact saved compiler bodies

Data-only extraction; these fragments were never evaluated.

## rawChecked: String.eq

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 856; body `9879c7a2170260e74e4db58931ccf0dfac67a5d8246d6614372e6f95d22a695b`.

```javascript
function $String$eq$(_a_0, _b_0) {
  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));
}
```

## rawChecked: kc

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 840; body `aa06d94d00588b5f7695a5477c5f6b58013b338ba1704f593d2bee37c4dc079c`.

```javascript
function $kc$(_b_0, _yes_0, _no_0) {
  if (_b_0) {
    return run_tail(_yes_0, {$: "Unit"});
  } else {
    return run_tail(_no_0, {$: "Unit"});
  }
}
```

## rawChecked: terms_at

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 1852; body `31ffd16a8f52eaa00ced5f73bc486091cccc7099ce564c21e835bb8670bd05cb`.

```javascript
function $terms_at$(_ts_0, _n_0) {
  if (_ts_0.$ === "Nil") {
    return $atom$("Absent");
  } else {
    const _h_0 = _ts_0["head"];
    const _t_0 = _ts_0["tail"];
    return $kc$((_n_0 === 0), run_clo((_x_0) => {
  return _h_0;
}), run_clo((_x_1) => {
  return $terms_at$(_t_0, ((_n_0 - 1) >>> 0));
}));
  }
}
```

## rawChecked: kid

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 2452; body `c40726b401f55fbcc6b790a283016872124850223679389219db6b8d500b5a37`.

```javascript
function $kid$(_t_0, _n_0) {
  return $terms_at$(($ks$(_t_0)), _n_0);
}
```

## rawChecked: index_hash

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 3524; body `5dadb40331078bc94f2cdda1d6790a773b135418232ca3f6d1e15b690cd214c9`.

```javascript
function $index_hash$($0, $1) {
  for (;;) {
    {
      const _name_0 = $0;
      const _acc_0 = $1;
      if (_name_0 === "") {
        return _acc_0;
      } else {
        const _h_0 = (_name_0.codePointAt(0) > 0xFFFF ? _name_0.slice(0, 2) : _name_0[0]);
        const _rest_0 = (_name_0.codePointAt(0) > 0xFFFF ? _name_0.slice(2) : _name_0.slice(1));
        const _x_0 = ($Char$to_u32$(_h_0));
        const _x_1 = ((_acc_0 ^ _x_0) >>> 0);
        $0 = _rest_0;
        $1 = (Math.imul(_x_1, 16777619) >>> 0);
        continue;
      }
    }
  }
}
```

## rawChecked: index_find

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 6896; body `4da7204d08832bb88f15cf2f3757d198b9e71e09aba738ec9f1338a4e76430b1`.

```javascript
function $index_find$($0, $1, $2, $3, $4) {
  let $pc = 0;
  for (;;) switch ($pc) {
    case 0: {
      const _tree_0 = $0;
      const _name_0 = $1;
      const _hash_0 = $2;
      const _bits_0 = $3;
      $0 = _tree_0;
      $1 = _name_0;
      $2 = _hash_0;
      $3 = _bits_0;
      $4 = ($String$eq$(($dk$(_tree_0)), "Absent"));
      $pc = 1; continue;
    }
    case 1: {
      const _tree_0 = $0;
      const _name_0 = $1;
      const _hash_0 = $2;
      const _bits_0 = $3;
      const _absent_0 = $4;
      if (_absent_0) {
        return $missing$();
      } else {
        const _x_0 = ($dx$(_tree_0));
        $0 = _tree_0;
        $1 = _name_0;
        $2 = _hash_0;
        $3 = _bits_0;
        $4 = (_x_0 === 0);
        $pc = 2; continue;
      }
    }
    case 2: {
      const _tree_0 = $0;
      const _name_0 = $1;
      const _hash_0 = $2;
      const _bits_0 = $3;
      const _leaf_0 = $4;
      if (_leaf_0) {
        const _x_0 = ($da$(_tree_0));
        return $index_find_hash$(_tree_0, _name_0, (_x_0 === _hash_0));
      } else {
        const _x_1 = ($dx$(_tree_0));
        const _x_2 = ((_hash_0 & _x_1) >>> 0);
        $0 = ($index_child$(_tree_0, ($Bool$not$((_x_2 === 0)))));
        $1 = _name_0;
        $2 = _hash_0;
        $3 = _bits_0;
        $pc = 0; continue;
      }
    }
  }
}
```

## rawChecked: index_remove

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 5274; body `812d59ad92d6128cd9df0e4f4876adb9c752ee4ed9f84582ebfc2a4962683cff`.

```javascript
function $index_remove$($0, $1, $2, $3) {
  let $pc = 0;
  for (;;) switch ($pc) {
    case 0: {
      const _ds_0 = $0;
      const _name_0 = $1;
      if (_ds_0.$ === "Nil") {
        return {$: "Nil"};
      } else {
        const _h_0 = _ds_0["head"];
        const _rest_0 = _ds_0["tail"];
        $0 = _h_0;
        $1 = _rest_0;
        $2 = _name_0;
        $3 = ($String$eq$(($dn$(_h_0)), _name_0));
        $pc = 1; continue;
      }
    }
    case 1: {
      const _h_0 = $0;
      const _rest_0 = $1;
      const _name_0 = $2;
      const _same_0 = $3;
      if (_same_0) {
        $0 = _rest_0;
        $1 = _name_0;
        $pc = 0; continue;
      } else {
        return {$: "Con", "head": _h_0, "tail": ($index_remove$(_rest_0, _name_0))};
      }
    }
  }
}
```

## rawChecked: subst

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 8590; body `59ba433a49eadafd4fccc120081bf5b7be38b359769076ee973a5616950b75ae`.

```javascript
function $subst$(_t_0, _id_0, _v_0) {
  return $kc$(($String$eq$(($tg$(_t_0)), "Var")), run_clo((_x_0) => {
  const _x_1 = ($ix$(_t_0));
  return $kc$((_x_1 === _id_0), run_clo((_x_2) => {
  return _v_0;
}), run_clo((_x_3) => {
  return _t_0;
}));
}), run_clo((_x_4) => {
  return $subst_node$(_t_0, _id_0, _v_0);
}));
}
```

## rawChecked: subst_terms

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 14657; body `0eddfe582d5b44aba7a261489b45d57afbef62fe4d03b0f274e64b633bb4baae`.

```javascript
function $subst_terms$(_ts_0, _id_0, _v_0) {
  if (_ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _h_0 = _ts_0["head"];
    const _t_0 = _ts_0["tail"];
    return {$: "Con", "head": run_loop($subst$(_h_0, _id_0, _v_0)), "tail": ($subst_terms$(_t_0, _id_0, _v_0))};
  }
}
```

## rawChecked: norm_eval

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 2460; body `6dad3b5a8d683045fbf31a683e02d214e4d0206026dcfd3e344dd3ea5be74120`.

```javascript
function $norm_eval$(_book_0, _t_0, _args_0, _left_0, _fallback_0) {
  return $kc$(($String$eq$(($tg$(_t_0)), "Var")), run_clo((_x_0) => {
  return $norm_var$(_book_0, _t_0, ($ks$(_t_0)), _args_0, _left_0, _fallback_0);
}), run_clo((_x_1) => {
  return $norm_eval_node$(_book_0, _t_0, _args_0, _left_0, _fallback_0);
}));
}
```

## rawChecked: check_node

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 16866; body `0c3a3c0272e13ae4b47fc1011974368dac37d5764bd351f568898216f6f56058`.

```javascript
function $check_node$(_e_0, _ctx_0, _t_0, _dem_0, _ty_0) {
  return $kc$(($core_literal$(_t_0)), run_clo((_x_0) => {
  return $kc$(($core_literal_type$(($cb$(_e_0)), _t_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)))), run_clo((_x_1) => {
  return $ok$(($cw$(_e_0)), _t_0, _ty_0, {$: "Nil"});
}), run_clo((_x_2) => {
  return $check$(_e_0, _ctx_0, run_loop($core_literal_step$(_t_0)), _dem_0, _ty_0);
}));
}), run_clo((_x_3) => {
  return $kc$(($String$eq$(($tg$(_t_0)), "Lam")), run_clo((_x_4) => {
  return $check_lam$(_e_0, _ctx_0, _t_0, _dem_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}), run_clo((_x_5) => {
  return $kc$(($String$eq$(($tg$(_t_0)), "Ctr")), run_clo((_x_6) => {
  return $check_ctr$(_e_0, _ctx_0, _t_0, _dem_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}), run_clo((_x_7) => {
  const _x_8 = ($String$eq$(($tg$(_t_0)), "Mat"));
  const _x_9 = ($String$eq$(($tg$(_t_0)), "Efq"));
  return $kc$((_x_8 || _x_9), run_clo((_x_10) => {
  return $check_mat$(_e_0, _ctx_0, _t_0, _dem_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}), run_clo((_x_11) => {
  return $kc$(($String$eq$(($tg$(_t_0)), "Rfl")), run_clo((_x_12) => {
  return $check_rfl$(_e_0, _t_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}), run_clo((_x_13) => {
  return $kc$(($String$eq$(($tg$(_t_0)), "Hol")), run_clo((_x_14) => {
  return $kc$(($String$eq$(($nm$(_t_0)), "TODO")), run_clo((_x_15) => {
  return $ok$(($cw$(_e_0)), _t_0, _ty_0, {$: "Nil"});
}), run_clo((_x_16) => {
  return $bad$(($cw$(_e_0)), "unresolved hole");
}));
}), run_clo((_x_17) => {
  return $kc$(($String$eq$(($tg$(_t_0)), "Let")), run_clo((_x_18) => {
  return $check_let$(_e_0, _ctx_0, _ctx_0, ($ks$(_t_0)), _dem_0, _ty_0, {$: "Nil"}, {$: "Nil"}, _t_0, {$: "Nil"});
}), run_clo((_x_19) => {
  return $kc$(($String$eq$(($tg$(_t_0)), "Rwt")), run_clo((_x_20) => {
  return $check_rwt$(_e_0, _ctx_0, _t_0, _dem_0, _ty_0, run_loop($infer$(_e_0, _ctx_0, run_loop($kid$(_t_0, 0)), _dem_0, {$: "Nil"})));
}), run_clo((_x_21) => {
  return $check_fits$(_e_0, run_loop($infer$(_e_0, _ctx_0, _t_0, _dem_0, {$: "Nil"})), _ty_0);
}));
}));
}));
}));
}));
}));
}));
}));
}
```

## rawChecked: jd_host_exports

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 6745; body `c06f69dc1889340e6b6cfce7668bb7b92451c4e7b8476c7e839855877fa1c01b`.

```javascript
function $jd_host_exports$(_book_0, _defs_0) {
  if (_defs_0.$ === "Nil") {
    return "";
  } else {
    const _d_0 = _defs_0["head"];
    const _rest_0 = _defs_0["tail"];
    const _x_0 = ($dx$(_d_0));
    const _x_5 = run_loop($kc$(($Bool$and$(($Bool$and$(($Bool$and$(($Bool$and$(($String$eq$(($dk$(_d_0)), "Def")), (_x_0 === 0))), ($Bool$not$(($db$(_d_0)))))), ($Bool$not$(($String$eq$(($tg$(run_loop($j_strip$(($dv$(_d_0)))))), "Absent")))))), ($Bool$not$(($String$eq$(($tg$(run_loop($j_strip$(($dv$(_d_0)))))), "Foreign")))))), run_clo((_x_1) => {
  return $jd_host_export$(_book_0, _d_0, run_loop($kc$(run_loop($j_io_type$(_book_0, ($dt$(_d_0)))), run_clo((_x_2) => {
  return 1;
}), run_clo((_x_3) => {
  return 0;
}))));
}), run_clo((_x_4) => {
  return "";
})));
    const _x_6 = ($jd_host_exports$(_book_0, _rest_0));
    return (_x_5 + _x_6);
  }
}
```

## derivedB1: String.eq

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 870; body `06dac77763ed25b6682876b4ce672d7039f1832f7b6e242dfce1211f7b6ba7a7`.

```javascript
function $String$eq$(_a_0, _b_0) {
  if (typeof _a_0 === "string" && typeof _b_0 === "string") return _a_0 === _b_0;
  return $Cmp$is_eq$(($String$order$(_a_0, _b_0)));
}
```

## derivedB1: kc

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 854; body `aa06d94d00588b5f7695a5477c5f6b58013b338ba1704f593d2bee37c4dc079c`.

```javascript
function $kc$(_b_0, _yes_0, _no_0) {
  if (_b_0) {
    return run_tail(_yes_0, {$: "Unit"});
  } else {
    return run_tail(_no_0, {$: "Unit"});
  }
}
```

## derivedB1: terms_at

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 1883; body `11c7fbc6d37e6f28f2d85167e9a2d970134dd54aedc7754dbac1855fcfa9e012`.

```javascript
function $terms_at$(_ts_0, _n_0) {
  if (_ts_0.$ === "Nil") {
    return $atom$("Absent");
  } else {
    const _h_0 = _ts_0["head"];
    const _t_0 = _ts_0["tail"];
    if (((_n_0 === 0))) {
const _x_0 = {$: "Unit"};
return _h_0;
} else {
const _x_1 = {$: "Unit"};
return {$: "$JMP", f: $terms_at$, x: [_t_0, ((_n_0 - 1) >>> 0)]};
}
  }
}
```

## derivedB1: kid

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 2493; body `c40726b401f55fbcc6b790a283016872124850223679389219db6b8d500b5a37`.

```javascript
function $kid$(_t_0, _n_0) {
  return $terms_at$(($ks$(_t_0)), _n_0);
}
```

## derivedB1: index_hash

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 3581; body `5dadb40331078bc94f2cdda1d6790a773b135418232ca3f6d1e15b690cd214c9`.

```javascript
function $index_hash$($0, $1) {
  for (;;) {
    {
      const _name_0 = $0;
      const _acc_0 = $1;
      if (_name_0 === "") {
        return _acc_0;
      } else {
        const _h_0 = (_name_0.codePointAt(0) > 0xFFFF ? _name_0.slice(0, 2) : _name_0[0]);
        const _rest_0 = (_name_0.codePointAt(0) > 0xFFFF ? _name_0.slice(2) : _name_0.slice(1));
        const _x_0 = ($Char$to_u32$(_h_0));
        const _x_1 = ((_acc_0 ^ _x_0) >>> 0);
        $0 = _rest_0;
        $1 = (Math.imul(_x_1, 16777619) >>> 0);
        continue;
      }
    }
  }
}
```

## derivedB1: index_find

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 7021; body `4da7204d08832bb88f15cf2f3757d198b9e71e09aba738ec9f1338a4e76430b1`.

```javascript
function $index_find$($0, $1, $2, $3, $4) {
  let $pc = 0;
  for (;;) switch ($pc) {
    case 0: {
      const _tree_0 = $0;
      const _name_0 = $1;
      const _hash_0 = $2;
      const _bits_0 = $3;
      $0 = _tree_0;
      $1 = _name_0;
      $2 = _hash_0;
      $3 = _bits_0;
      $4 = ($String$eq$(($dk$(_tree_0)), "Absent"));
      $pc = 1; continue;
    }
    case 1: {
      const _tree_0 = $0;
      const _name_0 = $1;
      const _hash_0 = $2;
      const _bits_0 = $3;
      const _absent_0 = $4;
      if (_absent_0) {
        return $missing$();
      } else {
        const _x_0 = ($dx$(_tree_0));
        $0 = _tree_0;
        $1 = _name_0;
        $2 = _hash_0;
        $3 = _bits_0;
        $4 = (_x_0 === 0);
        $pc = 2; continue;
      }
    }
    case 2: {
      const _tree_0 = $0;
      const _name_0 = $1;
      const _hash_0 = $2;
      const _bits_0 = $3;
      const _leaf_0 = $4;
      if (_leaf_0) {
        const _x_0 = ($da$(_tree_0));
        return $index_find_hash$(_tree_0, _name_0, (_x_0 === _hash_0));
      } else {
        const _x_1 = ($dx$(_tree_0));
        const _x_2 = ((_hash_0 & _x_1) >>> 0);
        $0 = ($index_child$(_tree_0, ($Bool$not$((_x_2 === 0)))));
        $1 = _name_0;
        $2 = _hash_0;
        $3 = _bits_0;
        $pc = 0; continue;
      }
    }
  }
}
```

## derivedB1: index_remove

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 5363; body `812d59ad92d6128cd9df0e4f4876adb9c752ee4ed9f84582ebfc2a4962683cff`.

```javascript
function $index_remove$($0, $1, $2, $3) {
  let $pc = 0;
  for (;;) switch ($pc) {
    case 0: {
      const _ds_0 = $0;
      const _name_0 = $1;
      if (_ds_0.$ === "Nil") {
        return {$: "Nil"};
      } else {
        const _h_0 = _ds_0["head"];
        const _rest_0 = _ds_0["tail"];
        $0 = _h_0;
        $1 = _rest_0;
        $2 = _name_0;
        $3 = ($String$eq$(($dn$(_h_0)), _name_0));
        $pc = 1; continue;
      }
    }
    case 1: {
      const _h_0 = $0;
      const _rest_0 = $1;
      const _name_0 = $2;
      const _same_0 = $3;
      if (_same_0) {
        $0 = _rest_0;
        $1 = _name_0;
        $pc = 0; continue;
      } else {
        return {$: "Con", "head": _h_0, "tail": ($index_remove$(_rest_0, _name_0))};
      }
    }
  }
}
```

## derivedB1: subst

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 8737; body `14914599e88ac7c80d64004cd754b774c2e75add6e1a8050c3f8c44ff6ba6b86`.

```javascript
function $subst$(_t_0, _id_0, _v_0) {
  return run_tail((($String$eq$(($tg$(_t_0)), "Var"))) ? ((_x_0) => {
  const _x_1 = ($ix$(_t_0));
  if (((_x_1 === _id_0))) {
const _x_2 = {$: "Unit"};
return _v_0;
} else {
const _x_3 = {$: "Unit"};
return _t_0;
}
}) : ((_x_4) => {
  return $subst_node$(_t_0, _id_0, _v_0);
}), {$: "Unit"});
}
```

## derivedB1: subst_terms

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 14896; body `0eddfe582d5b44aba7a261489b45d57afbef62fe4d03b0f274e64b633bb4baae`.

```javascript
function $subst_terms$(_ts_0, _id_0, _v_0) {
  if (_ts_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _h_0 = _ts_0["head"];
    const _t_0 = _ts_0["tail"];
    return {$: "Con", "head": run_loop($subst$(_h_0, _id_0, _v_0)), "tail": ($subst_terms$(_t_0, _id_0, _v_0))};
  }
}
```

## derivedB1: norm_eval

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 2501; body `3d246f117f532f79d96e5172dc04ee8855f30918fde94b46c11fc764d68da16d`.

```javascript
function $norm_eval$(_book_0, _t_0, _args_0, _left_0, _fallback_0) {
  return run_tail((($String$eq$(($tg$(_t_0)), "Var"))) ? ((_x_0) => {
  return $norm_var$(_book_0, _t_0, ($ks$(_t_0)), _args_0, _left_0, _fallback_0);
}) : ((_x_1) => {
  return $norm_eval_node$(_book_0, _t_0, _args_0, _left_0, _fallback_0);
}), {$: "Unit"});
}
```

## derivedB1: check_node

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 17147; body `462ba954c0b0cf69cf8821cc3e4aed5a9e54ed8488e24bd0aa0248427e5d9ff1`.

```javascript
function $check_node$(_e_0, _ctx_0, _t_0, _dem_0, _ty_0) {
  return run_tail((($core_literal$(_t_0))) ? ((_x_0) => {
  return run_tail((($core_literal_type$(($cb$(_e_0)), _t_0, run_loop($wnf$(($cb$(_e_0)), _ty_0))))) ? ((_x_1) => {
  return $ok$(($cw$(_e_0)), _t_0, _ty_0, {$: "Nil"});
}) : ((_x_2) => {
  return $check$(_e_0, _ctx_0, run_loop($core_literal_step$(_t_0)), _dem_0, _ty_0);
}), {$: "Unit"});
}) : ((_x_3) => {
  return run_tail((($String$eq$(($tg$(_t_0)), "Lam"))) ? ((_x_4) => {
  return $check_lam$(_e_0, _ctx_0, _t_0, _dem_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}) : ((_x_5) => {
  return run_tail((($String$eq$(($tg$(_t_0)), "Ctr"))) ? ((_x_6) => {
  return $check_ctr$(_e_0, _ctx_0, _t_0, _dem_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}) : ((_x_7) => {
  const _x_8 = ($String$eq$(($tg$(_t_0)), "Mat"));
  const _x_9 = ($String$eq$(($tg$(_t_0)), "Efq"));
  return run_tail(((_x_8 || _x_9)) ? ((_x_10) => {
  return $check_mat$(_e_0, _ctx_0, _t_0, _dem_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}) : ((_x_11) => {
  return run_tail((($String$eq$(($tg$(_t_0)), "Rfl"))) ? ((_x_12) => {
  return $check_rfl$(_e_0, _t_0, run_loop($wnf$(($cb$(_e_0)), _ty_0)));
}) : ((_x_13) => {
  return run_tail((($String$eq$(($tg$(_t_0)), "Hol"))) ? ((_x_14) => {
  return run_tail((($String$eq$(($nm$(_t_0)), "TODO"))) ? ((_x_15) => {
  return $ok$(($cw$(_e_0)), _t_0, _ty_0, {$: "Nil"});
}) : ((_x_16) => {
  return $bad$(($cw$(_e_0)), "unresolved hole");
}), {$: "Unit"});
}) : ((_x_17) => {
  return run_tail((($String$eq$(($tg$(_t_0)), "Let"))) ? ((_x_18) => {
  return $check_let$(_e_0, _ctx_0, _ctx_0, ($ks$(_t_0)), _dem_0, _ty_0, {$: "Nil"}, {$: "Nil"}, _t_0, {$: "Nil"});
}) : ((_x_19) => {
  return run_tail((($String$eq$(($tg$(_t_0)), "Rwt"))) ? ((_x_20) => {
  return $check_rwt$(_e_0, _ctx_0, _t_0, _dem_0, _ty_0, run_loop($infer$(_e_0, _ctx_0, run_loop($kid$(_t_0, 0)), _dem_0, {$: "Nil"})));
}) : ((_x_21) => {
  return $check_fits$(_e_0, run_loop($infer$(_e_0, _ctx_0, _t_0, _dem_0, {$: "Nil"})), _ty_0);
}), {$: "Unit"});
}), {$: "Unit"});
}), {$: "Unit"});
}), {$: "Unit"});
}), {$: "Unit"});
}), {$: "Unit"});
}), {$: "Unit"});
}), {$: "Unit"});
}
```

## derivedB1: jd_host_exports

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 6868; body `4d5cc5471ed6c45b6e399bcc27ab5473edf3017b2efb7316ba162316fbb31708`.

```javascript
function $jd_host_exports$(_book_0, _defs_0) {
  if (_defs_0.$ === "Nil") {
    return "";
  } else {
    const _d_0 = _defs_0["head"];
    const _rest_0 = _defs_0["tail"];
    const _x_0 = ($dx$(_d_0));
    const _x_5 = run_loop(run_tail((($Bool$and$(($Bool$and$(($Bool$and$(($Bool$and$(($String$eq$(($dk$(_d_0)), "Def")), (_x_0 === 0))), ($Bool$not$(($db$(_d_0)))))), ($Bool$not$(($String$eq$(($tg$(run_loop($j_strip$(($dv$(_d_0)))))), "Absent")))))), ($Bool$not$(($String$eq$(($tg$(run_loop($j_strip$(($dv$(_d_0)))))), "Foreign"))))))) ? ((_x_1) => {
  return $jd_host_export$(_book_0, _d_0, run_loop(run_tail((run_loop($j_io_type$(_book_0, ($dt$(_d_0))))) ? ((_x_2) => {
  return 1;
}) : ((_x_3) => {
  return 0;
}), {$: "Unit"})));
}) : ((_x_4) => {
  return "";
}), {$: "Unit"}));
    const _x_6 = ($jd_host_exports$(_book_0, _rest_0));
    return (_x_5 + _x_6);
  }
}
```

## directB2: String.eq

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 561; body `0e5dc1231a55716218ad4af75d27bfe4853b16370b3605d5e51bab697ce2fa13`.

```javascript
function $jd$String_46_eq($a0,$a1){return ($a0 === $a1);}
```

## directB2: kc

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 771; body `8a0c9870bc2eb8c0bbda6ebb2c5ebce380301aa101f54dac85d5706d996a046f`.

```javascript
function $jd$kc($a0,$a1,$a2){for(;;){const $x5945=null;{const $match2=$a0;if($match2){const $x5946=$a1;return run_tail((
/*JD_USE:5946*/$x5946),({$:"Unit"}));}else{{const $match3=$match2;const $x5949=$a2;return run_tail((
/*JD_USE:5949*/$x5949),({$:"Unit"}));}}}}}
```

## directB2: terms_at

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 801; body `9ac5f11e1471ab34bc5a2d74f5266ef67a728fd21d911f4641615973bad7b777`.

```javascript
function $jd$terms_95_at($a0,$a1){for(;;){{const $match1=$a0;if($match1.$==="Nil"){return (
/*JD_REF:$jd$atom*/$jd$atom("Absent"));}else{{const $match2=$match1;const $x6097=$match2["head"];const $x6098=$match2["tail"];const $x6099=$a1;return (
/*JD_REF:$jd$kc*/$jd$kc((((
/*JD_USE:6099*/$x6099) === 0)),jd_clo(($arg)=>{return (
/*JD_USE:6097*/$x6097);}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$terms_95_at*/$jd$terms_95_at((
/*JD_USE:6098*/$x6098),((((
/*JD_USE:6099*/$x6099) - 1) >>> 0))));})));}}}}}
```

## directB2: kid

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 809; body `c64ea83970206cdfb09f162a0162074310aada3a953d9b8e9aa5252d0d26f82f`.

```javascript
function $jd$kid($a0,$a1){for(;;){const $x6104=$a0;const $x6105=$a1;return (
/*JD_REF:$jd$terms_95_at*/$jd$terms_95_at((
/*JD_REF:$jd$ks*/$jd$ks((
/*JD_USE:6104*/$x6104))),(
/*JD_USE:6105*/$x6105)));}}
```

## directB2: index_hash

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 1405; body `9d00357e8702759ea5bd788b7577442e43a90933131ebf7485241f60be17634f`.

```javascript
function $jd$index_95_hash($a0,$a1){for(;;){{const $match1=$a0;if($match1===""){const $x6771=$a1;return (
/*JD_USE:6771*/$x6771);}else{{const $match2=$match1;const $x6772=($match2.codePointAt(0)>0xFFFF?$match2.slice(0,2):$match2[0]);const $x6773=($match2.codePointAt(0)>0xFFFF?$match2.slice(2):$match2.slice(1));const $x6774=$a1;{const $ord0=(
/*JD_REF:$jd$Char_46_to_95_u32*/$jd$Char_46_to_95_u32((
/*JD_USE:6772*/$x6772)));const $ord1=((((
/*JD_USE:6774*/$x6774) ^ $ord0) >>> 0));{
/*JD_REF:$jd$index_95_hash*/const $next0=(
/*JD_USE:6773*/$x6773);const $next1=((Math.imul($ord1, 16777619) >>> 0));$a0=$next0;$a1=$next1;continue;}}}}}}}
```

## directB2: index_find

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 1425; body `aa4927b74fac097ed6b81ca7d81ccddaa8177d62aefb0415f493130dc1d6a659`.

```javascript
function $jd$index_95_find($a0,$a1,$a2,$a3,$a4){let $pc=0;for(;;)switch($pc){case 0:{const $x6791=$a0;const $x6792=$a1;const $x6793=$a2;const $x6794=$a3;{
/*JD_REF:$jd$index_95_find_95_absent*/const $next0=(
/*JD_USE:6791*/$x6791);const $next1=(
/*JD_USE:6792*/$x6792);const $next2=(
/*JD_USE:6793*/$x6793);const $next3=(
/*JD_USE:6794*/$x6794);const $next4=(
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$dk*/$jd$dk((
/*JD_USE:6791*/$x6791))),"Absent"));$a0=$next0;$a1=$next1;$a2=$next2;$a3=$next3;$a4=$next4;$pc=1;continue;}}case 1:{const $x6800=$a0;const $x6801=$a1;const $x6802=$a2;const $x6803=$a3;{const $match5=$a4;if($match5){return (
/*JD_REF:$jd$missing*/$jd$missing());}else{{const $match6=$match5;{const $ord0=(
/*JD_REF:$jd$dx*/$jd$dx((
/*JD_USE:6800*/$x6800)));{
/*JD_REF:$jd$index_95_find_95_leaf*/const $next0=(
/*JD_USE:6800*/$x6800);const $next1=(
/*JD_USE:6801*/$x6801);const $next2=(
/*JD_USE:6802*/$x6802);const $next3=(
/*JD_USE:6803*/$x6803);const $next4=(($ord0 === 0));$a0=$next0;$a1=$next1;$a2=$next2;$a3=$next3;$a4=$next4;$pc=2;continue;}}}}}}case 2:{const $x6809=$a0;const $x6810=$a1;const $x6811=$a2;const $x6812=$a3;{const $match5=$a4;if($match5){{const $ord0=(
/*JD_REF:$jd$da*/$jd$da((
/*JD_USE:6809*/$x6809)));return (
/*JD_REF:$jd$index_95_find_95_hash*/$jd$index_95_find_95_hash((
/*JD_USE:6809*/$x6809),(
/*JD_USE:6810*/$x6810),(($ord0 === (
/*JD_USE:6811*/$x6811)))));}}else{{const $match6=$match5;{const $ord0=(
/*JD_REF:$jd$dx*/$jd$dx((
/*JD_USE:6809*/$x6809)));const $ord1=((((
/*JD_USE:6811*/$x6811) & $ord0) >>> 0));{
/*JD_REF:$jd$index_95_find*/const $next0=(
/*JD_REF:$jd$index_95_child*/$jd$index_95_child((
/*JD_USE:6809*/$x6809),(
/*JD_REF:$jd$Bool_46_not*/$jd$Bool_46_not((($ord1 === 0))))));const $next1=(
/*JD_USE:6810*/$x6810);const $next2=(
/*JD_USE:6811*/$x6811);const $next3=(
/*JD_USE:6812*/$x6812);$a0=$next0;$a1=$next1;$a2=$next2;$a3=$next3;$pc=0;continue;}}}}}}}}
```

## directB2: index_remove

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 1541; body `0821c37d1b260e455b110b51b376f54d761be9abb6e16c91be256df4c032157e`.

```javascript
function $jd$index_95_remove($a0,$a1,$a2,$a3){let $pc=0;for(;;)switch($pc){case 0:{{const $match1=$a0;if($match1.$==="Nil"){return ({$:"Nil"});}else{{const $match2=$match1;const $x6829=$match2["head"];const $x6830=$match2["tail"];const $x6831=$a1;{
/*JD_REF:$jd$index_95_remove_95_step*/const $next0=(
/*JD_USE:6829*/$x6829);const $next1=(
/*JD_USE:6830*/$x6830);const $next2=(
/*JD_USE:6831*/$x6831);const $next3=(
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$dn*/$jd$dn((
/*JD_USE:6829*/$x6829))),(
/*JD_USE:6831*/$x6831)));$a0=$next0;$a1=$next1;$a2=$next2;$a3=$next3;$pc=1;continue;}}}}}case 1:{const $x6836=$a0;const $x6837=$a1;const $x6838=$a2;{const $match4=$a3;if($match4){{
/*JD_REF:$jd$index_95_remove*/const $next0=(
/*JD_USE:6837*/$x6837);const $next1=(
/*JD_USE:6838*/$x6838);$a0=$next0;$a1=$next1;$pc=0;continue;}}else{{const $match5=$match4;return ({$:"Con",["head"]:(
/*JD_USE:6836*/$x6836),["tail"]:(
/*JD_REF:$jd$index_95_remove*/$jd$index_95_remove((
/*JD_USE:6837*/$x6837),(
/*JD_USE:6838*/$x6838)))});}}}}}}
```

## directB2: subst

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 955; body `5714cbe25fb91a06f636c51ba076e98da18fe44ded525e7c64c435de2cdc5f54`.

```javascript
function $jd$subst($a0,$a1,$a2){for(;;){const $x6257=$a0;const $x6258=$a1;const $x6259=$a2;return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:6257*/$x6257))),"Var")),jd_clo(($arg)=>{{const $ord0=(
/*JD_REF:$jd$ix*/$jd$ix((
/*JD_USE:6257*/$x6257)));return (
/*JD_REF:$jd$kc*/$jd$kc((($ord0 === (
/*JD_USE:6258*/$x6258))),jd_clo(($arg)=>{return (
/*JD_USE:6259*/$x6259);}),jd_clo(($arg)=>{return (
/*JD_USE:6257*/$x6257);})));}}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$subst_95_node*/$jd$subst_95_node((
/*JD_USE:6257*/$x6257),(
/*JD_USE:6258*/$x6258),(
/*JD_USE:6259*/$x6259)));})));}}
```

## directB2: subst_terms

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 1000; body `972d4824093e01f3fc27b88aa2874a34cc8e3c835437869fa0855596521611e2`.

```javascript
function $jd$subst_95_terms($a0,$a1,$a2){for(;;){{const $match1=$a0;if($match1.$==="Nil"){return ({$:"Nil"});}else{{const $match2=$match1;const $x6299=$match2["head"];const $x6300=$match2["tail"];const $x6301=$a1;const $x6302=$a2;return ({$:"Con",["head"]:(
/*JD_REF:$jd$subst*/jd_run($jd$subst((
/*JD_USE:6299*/$x6299),(
/*JD_USE:6301*/$x6301),(
/*JD_USE:6302*/$x6302)))),["tail"]:(
/*JD_REF:$jd$subst_95_terms*/$jd$subst_95_terms((
/*JD_USE:6300*/$x6300),(
/*JD_USE:6301*/$x6301),(
/*JD_USE:6302*/$x6302)))});}}}}}
```

## directB2: norm_eval

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 2383; body `7ce30d729f11ad9ba45fbb03208929619a3082fea74f668382ae04deead50d56`.

```javascript
function $jd$norm_95_eval($a0,$a1,$a2,$a3,$a4){for(;;){const $x7261=$a0;const $x7262=$a1;const $x7263=$a2;const $x7264=$a3;const $x7265=$a4;return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:7262*/$x7262))),"Var")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$norm_95_var*/$jd$norm_95_var((
/*JD_USE:7261*/$x7261),(
/*JD_USE:7262*/$x7262),(
/*JD_REF:$jd$ks*/$jd$ks((
/*JD_USE:7262*/$x7262))),(
/*JD_USE:7263*/$x7263),(
/*JD_USE:7264*/$x7264),(
/*JD_USE:7265*/$x7265)));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$norm_95_eval_95_node*/$jd$norm_95_eval_95_node((
/*JD_USE:7261*/$x7261),(
/*JD_USE:7262*/$x7262),(
/*JD_USE:7263*/$x7263),(
/*JD_USE:7264*/$x7264),(
/*JD_USE:7265*/$x7265)));})));}}
```

## directB2: check_node

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 6456; body `6ba591e29137329a889b98c11f0f7e270d23441222e3c7cdeb83f7e94d195d71`.

```javascript
function $jd$check_95_node($a0,$a1,$a2,$a3,$a4){for(;;){const $x9289=$a0;const $x9290=$a1;const $x9291=$a2;const $x9292=$a3;const $x9293=$a4;return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$core_95_literal*/$jd$core_95_literal((
/*JD_USE:9291*/$x9291))),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$core_95_literal_95_type*/$jd$core_95_literal_95_type((
/*JD_REF:$jd$cb*/$jd$cb((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9291*/$x9291),(
/*JD_REF:$jd$wnf*/jd_run($jd$wnf((
/*JD_REF:$jd$cb*/$jd$cb((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9293*/$x9293)))))),jd_clo(($arg)=>{return (
/*JD_REF:$jd$ok*/$jd$ok((
/*JD_REF:$jd$cw*/$jd$cw((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9291*/$x9291),(
/*JD_USE:9293*/$x9293),({$:"Nil"})));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check*/$jd$check((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_REF:$jd$core_95_literal_95_step*/jd_run($jd$core_95_literal_95_step((
/*JD_USE:9291*/$x9291)))),(
/*JD_USE:9292*/$x9292),(
/*JD_USE:9293*/$x9293)));})));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Lam")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check_95_lam*/$jd$check_95_lam((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_USE:9291*/$x9291),(
/*JD_USE:9292*/$x9292),(
/*JD_REF:$jd$wnf*/jd_run($jd$wnf((
/*JD_REF:$jd$cb*/$jd$cb((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9293*/$x9293))))));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Ctr")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check_95_ctr*/$jd$check_95_ctr((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_USE:9291*/$x9291),(
/*JD_USE:9292*/$x9292),(
/*JD_REF:$jd$wnf*/jd_run($jd$wnf((
/*JD_REF:$jd$cb*/$jd$cb((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9293*/$x9293))))));}),jd_clo(($arg)=>{{const $ord0=(
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Mat"));const $ord1=(
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Efq"));return (
/*JD_REF:$jd$kc*/$jd$kc((($ord0 || $ord1)),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check_95_mat*/$jd$check_95_mat((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_USE:9291*/$x9291),(
/*JD_USE:9292*/$x9292),(
/*JD_REF:$jd$wnf*/jd_run($jd$wnf((
/*JD_REF:$jd$cb*/$jd$cb((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9293*/$x9293))))));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Rfl")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check_95_rfl*/$jd$check_95_rfl((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9291*/$x9291),(
/*JD_REF:$jd$wnf*/jd_run($jd$wnf((
/*JD_REF:$jd$cb*/$jd$cb((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9293*/$x9293))))));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Hol")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$nm*/$jd$nm((
/*JD_USE:9291*/$x9291))),"TODO")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$ok*/$jd$ok((
/*JD_REF:$jd$cw*/$jd$cw((
/*JD_USE:9289*/$x9289))),(
/*JD_USE:9291*/$x9291),(
/*JD_USE:9293*/$x9293),({$:"Nil"})));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$bad*/$jd$bad((
/*JD_REF:$jd$cw*/$jd$cw((
/*JD_USE:9289*/$x9289))),"unresolved hole"));})));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Let")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check_95_let*/$jd$check_95_let((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_USE:9290*/$x9290),(
/*JD_REF:$jd$ks*/$jd$ks((
/*JD_USE:9291*/$x9291))),(
/*JD_USE:9292*/$x9292),(
/*JD_USE:9293*/$x9293),({$:"Nil"}),({$:"Nil"}),(
/*JD_USE:9291*/$x9291),({$:"Nil"})));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_USE:9291*/$x9291))),"Rwt")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check_95_rwt*/$jd$check_95_rwt((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_USE:9291*/$x9291),(
/*JD_USE:9292*/$x9292),(
/*JD_USE:9293*/$x9293),(
/*JD_REF:$jd$infer*/jd_run($jd$infer((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_REF:$jd$kid*/jd_run($jd$kid((
/*JD_USE:9291*/$x9291),0))),(
/*JD_USE:9292*/$x9292),({$:"Nil"}))))));}),jd_clo(($arg)=>{return (
/*JD_REF:$jd$check_95_fits*/$jd$check_95_fits((
/*JD_USE:9289*/$x9289),(
/*JD_REF:$jd$infer*/jd_run($jd$infer((
/*JD_USE:9289*/$x9289),(
/*JD_USE:9290*/$x9290),(
/*JD_USE:9291*/$x9291),(
/*JD_USE:9292*/$x9292),({$:"Nil"})))),(
/*JD_USE:9293*/$x9293)));})));})));})));})));})));}})));})));})));}}
```

## directB2: jd_host_exports

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 57317; body `21346709292b75f62b95a428ca4dc4097686cb1befda868e3fbb0632d4c7fb75`.

```javascript
function $jd$jd_95_host_95_exports($a0,$a1){for(;;){const $x34743=$a0;{const $match2=$a1;if($match2.$==="Nil"){return "";}else{{const $match3=$match2;const $x34744=$match3["head"];const $x34745=$match3["tail"];{const $ord0=(
/*JD_REF:$jd$dx*/$jd$dx((
/*JD_USE:34744*/$x34744)));const $ord1=(
/*JD_REF:$jd$kc*/jd_run($jd$kc((
/*JD_REF:$jd$Bool_46_and*/$jd$Bool_46_and((
/*JD_REF:$jd$Bool_46_and*/$jd$Bool_46_and((
/*JD_REF:$jd$Bool_46_and*/$jd$Bool_46_and((
/*JD_REF:$jd$Bool_46_and*/$jd$Bool_46_and((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$dk*/$jd$dk((
/*JD_USE:34744*/$x34744))),"Def")),(($ord0 === 0)))),(
/*JD_REF:$jd$Bool_46_not*/$jd$Bool_46_not((
/*JD_REF:$jd$db*/$jd$db((
/*JD_USE:34744*/$x34744))))))),(
/*JD_REF:$jd$Bool_46_not*/$jd$Bool_46_not((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_REF:$jd$j_95_strip*/jd_run($jd$j_95_strip((
/*JD_REF:$jd$dv*/$jd$dv((
/*JD_USE:34744*/$x34744)))))))),"Absent")))))),(
/*JD_REF:$jd$Bool_46_not*/$jd$Bool_46_not((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$tg*/$jd$tg((
/*JD_REF:$jd$j_95_strip*/jd_run($jd$j_95_strip((
/*JD_REF:$jd$dv*/$jd$dv((
/*JD_USE:34744*/$x34744)))))))),"Foreign")))))),jd_clo(($arg)=>{return (
/*JD_REF:$jd$jd_95_host_95_export*/$jd$jd_95_host_95_export((
/*JD_USE:34743*/$x34743),(
/*JD_USE:34744*/$x34744),(
/*JD_REF:$jd$kc*/jd_run($jd$kc((
/*JD_REF:$jd$j_95_io_95_type*/jd_run($jd$j_95_io_95_type((
/*JD_USE:34743*/$x34743),(
/*JD_REF:$jd$dt*/$jd$dt((
/*JD_USE:34744*/$x34744)))))),jd_clo(($arg)=>{return 1;}),jd_clo(($arg)=>{return 0;}))))));}),jd_clo(($arg)=>{return "";}))));const $ord2=(
/*JD_REF:$jd$jd_95_host_95_exports*/$jd$jd_95_host_95_exports((
/*JD_USE:34743*/$x34743),(
/*JD_USE:34745*/$x34745)));return (($ord1 + $ord2));}}}}}}
```
