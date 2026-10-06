# Exact CPU-hot body comparison

Saved-source extraction only; no generated code was evaluated.

## rawChecked — kt

Parent `1498f6758c1ce713225209cc6ad9e0c27a0d5aee2ed674c4ae35990cf945cf52`, line 3256; body `f7d73891cefa7edb199ed71b14331ff06003c60484a28623056e8538f848499d`.

```javascript
function $kt$(_tag_0, _name_0, _id_0, _quant_0, _kids_0) {
  return {$: "KTerm", "tag": _tag_0, "name": _name_0, "id": _id_0, "quant": _quant_0, "kids": _kids_0, "removed": {$: "Nil"}, "originBegin": 0, "originEnd": 0};
}
```

### run_loop

Line 136; SHA256 `b1f937dcb68edc1033b01d5a6055938ec2e34103bacd41b68c36f2ea66bd1c8f`.

```javascript
function run_loop(r) {
  while (r !== null && typeof r === "object" && r.$ === "$JMP") {
    r = r.f(...r.x);
  }
  return r;
}
```

### run_tail

Line 125; SHA256 `72aa8e5b23785a67a6b6a2fb3ad46a94bf9b77764c4c3b8296033031eed62ff6`.

```javascript
function run_tail(f, x) {
  return {$: "$JMP", f: f.j?.f === f ? f.j : f, x: [x]};
}
```

### run_clo

Line 129; SHA256 `23d2a048610410013d7c84561a9111e39fe7a5380568c0fb021d9485ef1a05e6`.

```javascript
function run_clo(j) {
  const f = (x) => run_loop(j(x));
  f.j = j;
  j.f = f;
  return f;
}
```

## derivedB1 — kt

Parent `128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea`, line 3309; body `f7d73891cefa7edb199ed71b14331ff06003c60484a28623056e8538f848499d`.

```javascript
function $kt$(_tag_0, _name_0, _id_0, _quant_0, _kids_0) {
  return {$: "KTerm", "tag": _tag_0, "name": _name_0, "id": _id_0, "quant": _quant_0, "kids": _kids_0, "removed": {$: "Nil"}, "originBegin": 0, "originEnd": 0};
}
```

### run_loop

Line 136; SHA256 `b1f937dcb68edc1033b01d5a6055938ec2e34103bacd41b68c36f2ea66bd1c8f`.

```javascript
function run_loop(r) {
  while (r !== null && typeof r === "object" && r.$ === "$JMP") {
    r = r.f(...r.x);
  }
  return r;
}
```

### run_tail

Line 125; SHA256 `72aa8e5b23785a67a6b6a2fb3ad46a94bf9b77764c4c3b8296033031eed62ff6`.

```javascript
function run_tail(f, x) {
  return {$: "$JMP", f: f.j?.f === f ? f.j : f, x: [x]};
}
```

### run_clo

Line 129; SHA256 `23d2a048610410013d7c84561a9111e39fe7a5380568c0fb021d9485ef1a05e6`.

```javascript
function run_clo(j) {
  const f = (x) => run_loop(j(x));
  f.j = j;
  j.f = f;
  return f;
}
```

## directB2 — kt

Parent `3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e`, line 774; body `0f0cc6971c0e96ee2eb3f6cce251041df6e47f1994008619dd4b8c0127eee4b5`.

```javascript
function $jd$kt($a0,$a1,$a2,$a3,$a4){for(;;){const $x5955=$a0;const $x5956=$a1;const $x5957=$a2;const $x5958=$a3;const $x5959=$a4;return ({$:"KTerm",["tag"]:(
/*JD_USE:5955*/$x5955),["name"]:(
/*JD_USE:5956*/$x5956),["id"]:(
/*JD_USE:5957*/$x5957),["quant"]:(
/*JD_USE:5958*/$x5958),["kids"]:(
/*JD_USE:5959*/$x5959),["removed"]:({$:"Nil"}),["originBegin"]:0,["originEnd"]:0});}}
```

### run_loop

Line 149; SHA256 `b1f937dcb68edc1033b01d5a6055938ec2e34103bacd41b68c36f2ea66bd1c8f`.

```javascript
function run_loop(r) {
  while (r !== null && typeof r === "object" && r.$ === "$JMP") {
    r = r.f(...r.x);
  }
  return r;
}
```

### run_tail

Line 138; SHA256 `72aa8e5b23785a67a6b6a2fb3ad46a94bf9b77764c4c3b8296033031eed62ff6`.

```javascript
function run_tail(f, x) {
  return {$: "$JMP", f: f.j?.f === f ? f.j : f, x: [x]};
}
```

### run_clo

Line 142; SHA256 `23d2a048610410013d7c84561a9111e39fe7a5380568c0fb021d9485ef1a05e6`.

```javascript
function run_clo(j) {
  const f = (x) => run_loop(j(x));
  f.j = j;
  j.f = f;
  return f;
}
```
