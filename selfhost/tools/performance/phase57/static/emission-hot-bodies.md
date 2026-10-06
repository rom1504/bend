# Exact emission-hot constructor and lookup bodies

Data-only saved-source extraction. Existing CPU-hot extracts remain unchanged.

## rawChecked — missing

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 2480; body `2592886fd098faecb1d149fe03836c35da86ca10bd59c41e7cdc9ed8e5a0f7aa`.

```javascript
function $missing$() {
  return {$: "KDef", "name": "", "kind": "Absent", "arity": 0, "templates": 0, "typ": ($atom$("Absent")), "value": ($atom$("Absent")), "ctors": {$: "Nil"}, "native": false, "unsafe": false};
}
```

## rawChecked — atom

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 1608; body `78e924119345a2a85feaf8a7137b3a56fbbf605f7892347ad8d9589e9b56bb42`.

```javascript
function $atom$(_tag_0) {
  return $kt$(_tag_0, "", 0, 0, {$: "Nil"});
}
```

## rawChecked — j_found_ctor

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 5213; body `275ec77068f0e3244cb819fb714af47bae78bb426ef6ce1ddea0aa2a10b4051e`.

```javascript
function $j_found_ctor$(_found_0, _rest_0, _name_0) {
  return $kc$(($String$eq$(($dk$(_found_0)), "Absent")), run_clo((_x_0) => {
  return $j_find_ctor$(_rest_0, _name_0);
}), run_clo((_x_1) => {
  return _found_0;
}));
}
```

## rawChecked — j_find_ctor

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 2672; body `2b78f4ea56bf6556fb86b646be3b933ea5aaa2cab2f6da3f09677dc6db75417f`.

```javascript
function $j_find_ctor$(_book_0, _name_0) {
  if (_book_0.$ === "Nil") {
    return $missing$();
  } else {
    const _d_0 = _book_0["head"];
    const _rest_0 = _book_0["tail"];
    return $j_found_ctor$(run_loop($lookup$(($dc$(_d_0)), _name_0)), _rest_0, _name_0);
  }
}
```

## derivedB1 — missing

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 2521; body `2592886fd098faecb1d149fe03836c35da86ca10bd59c41e7cdc9ed8e5a0f7aa`.

```javascript
function $missing$() {
  return {$: "KDef", "name": "", "kind": "Absent", "arity": 0, "templates": 0, "typ": ($atom$("Absent")), "value": ($atom$("Absent")), "ctors": {$: "Nil"}, "native": false, "unsafe": false};
}
```

## derivedB1 — atom

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 1633; body `78e924119345a2a85feaf8a7137b3a56fbbf605f7892347ad8d9589e9b56bb42`.

```javascript
function $atom$(_tag_0) {
  return $kt$(_tag_0, "", 0, 0, {$: "Nil"});
}
```

## derivedB1 — j_found_ctor

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 5298; body `b3d4cdee44419e7a7e7796c26d05ad75a351ba14a4c69279339cc2498656614b`.

```javascript
function $j_found_ctor$(_found_0, _rest_0, _name_0) {
  if ((($String$eq$(($dk$(_found_0)), "Absent")))) {
const _x_0 = {$: "Unit"};
return {$: "$JMP", f: $j_find_ctor$, x: [_rest_0, _name_0]};
} else {
const _x_1 = {$: "Unit"};
return _found_0;
}
}
```

## derivedB1 — j_find_ctor

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 2713; body `2b78f4ea56bf6556fb86b646be3b933ea5aaa2cab2f6da3f09677dc6db75417f`.

```javascript
function $j_find_ctor$(_book_0, _name_0) {
  if (_book_0.$ === "Nil") {
    return $missing$();
  } else {
    const _d_0 = _book_0["head"];
    const _rest_0 = _book_0["tail"];
    return $j_found_ctor$(run_loop($lookup$(($dc$(_d_0)), _name_0)), _rest_0, _name_0);
  }
}
```

## directB2 — missing

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 857; body `d31e44f2fb4c97f23bade3c358f0a8e0a00d5b8cfcafcc627b6dffa63ae74dc3`.

```javascript
function $jd$missing(){for(;;){return ({$:"KDef",["name"]:"",["kind"]:"Absent",["arity"]:0,["templates"]:0,["typ"]:(
/*JD_REF:$jd$atom*/$jd$atom("Absent")),["value"]:(
/*JD_REF:$jd$atom*/$jd$atom("Absent")),["ctors"]:({$:"Nil"}),["native"]:false,["unsafe"]:false});}}
```

## directB2 — atom

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 780; body `a1bfc4baedfb998aa6bdf04d0ab25c43ef6ef9ebd280ba7c285ccd083c0db4bc`.

```javascript
function $jd$atom($a0){for(;;){const $x5961=$a0;return (
/*JD_REF:$jd$kt*/$jd$kt((
/*JD_USE:5961*/$x5961),"",0,0,({$:"Nil"})));}}
```

## directB2 — j_found_ctor

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 25288; body `3c35a4c03e9c46a200d1c762dcfad712eb527986adfb0d7d980f1ff89a010f9e`.

```javascript
function $jd$j_95_found_95_ctor($a0,$a1,$a2){for(;;){const $x21151=$a0;const $x21152=$a1;const $x21153=$a2;return (
/*JD_REF:$jd$kc*/$jd$kc((
/*JD_REF:$jd$String_46_eq*/$jd$String_46_eq((
/*JD_REF:$jd$dk*/$jd$dk((
/*JD_USE:21151*/$x21151))),"Absent")),jd_clo(($arg)=>{return (
/*JD_REF:$jd$j_95_find_95_ctor*/$jd$j_95_find_95_ctor((
/*JD_USE:21152*/$x21152),(
/*JD_USE:21153*/$x21153)));}),jd_clo(($arg)=>{return (
/*JD_USE:21151*/$x21151);})));}}
```

## directB2 — j_find_ctor

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 25279; body `c32bc4cc4183842cafb9798b4415375644fe5fb2a19e5cfe99869e130c63efba`.

```javascript
function $jd$j_95_find_95_ctor($a0,$a1){for(;;){{const $match1=$a0;if($match1.$==="Nil"){return (
/*JD_REF:$jd$missing*/$jd$missing());}else{{const $match2=$match1;const $x21145=$match2["head"];const $x21146=$match2["tail"];const $x21147=$a1;return (
/*JD_REF:$jd$j_95_found_95_ctor*/$jd$j_95_found_95_ctor((
/*JD_REF:$jd$lookup*/jd_run($jd$lookup((
/*JD_REF:$jd$dc*/$jd$dc((
/*JD_USE:21145*/$x21145))),(
/*JD_USE:21147*/$x21147)))),(
/*JD_USE:21146*/$x21146),(
/*JD_USE:21147*/$x21147)));}}}}}
```
