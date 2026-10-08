#!/usr/bin/env python3
"""Isolated current-Base blocking native effect ABI repair, no target execution."""
from pathlib import Path
import json,hashlib,difflib
ROOT=Path(__file__).resolve().parents[5]
OUT=Path(__file__).with_name('native-effects-v1')
def pin(p):return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size}
def replace(s,a,b,n=1):
 assert s.count(a)==n,(a,s.count(a),n);return s.replace(a,b)
def main():
 assert not OUT.exists();OUT.mkdir();rows=[];patch=[]
 files=['runtime.c','effs/chan.c','effs/chan_send.c','effs/chan_recv.c','effs/tcp_recv.c','effs/tcp_send.c','effs/udp_send_to.c','effs/udp_recv_from.c']
 for name in files:
  live=ROOT/'selfhost/src/runtime/native'/name
  before=Path(__file__).with_name('native-abi-v1')/'after.c' if name=='runtime.c' else live
  old=before.read_text();new=old
  if name=='runtime.c':
   new=replace(new,'static Term io_fail(Env e, u32 code, const char* text) {\n  const char* s = text != NULL ? text : strerror((int)code);\n  Term t = io_tup(e, code, io_str(e, s, strlen(s)));\n  return io_box(e, CID_FAIL, t);\n}', 'static Term io_err(Env e, u32 code, const char* text) {\n  const char* s = text != NULL ? text : strerror((int)code);\n  return io_tup(e, code, io_str(e, s, strlen(s)));\n}\n\nstatic Term io_fail(Env e, u32 code, const char* text) {\n  return io_box(e, CID_FAIL, io_err(e, code, text));\n}')
   new=replace(new,'#define chan_bool(b)    term_pak((b) ? CID_TRUE : CID_FALSE, 0)','#define chan_done(e)    io_done(e, term_pak(CID_UNIT, 0))')
   new=replace(new,'static Term chan_take(ChanRow* row) {','static Term chan_take(Env e, ChanRow* row) {')
   new=replace(new,'chan_wake(row, chan_bool(true))','chan_wake(row, chan_done(e))')
   new=replace(new,'    bool rcv = row->wait.head->item == TERM_HOLE;\n    Term x = rcv ? term_pak(CID_NONE, 0) : chan_bool(false);\n    term_sink(e, chan_wake(row, x));','    Term item = row->wait.head->item;\n    Term x = item == TERM_HOLE ? term_pak(CID_NONE, 0)\n      : io_box(e, CID_FAIL, item);\n    chan_wake(row, x);')
   names=['Chan.try_send','Chan.try_recv','TCP.try_accept','TCP.try_send','TCP.try_send_bytes','TCP.try_recv','TCP.try_recv_bytes','UDP.try_send_to','UDP.try_send_bytes_to','UDP.try_recv_from','UDP.try_recv_bytes_from','UDP.send_bytes_to','UDP.recv_bytes_from']
   guard='// Current Base additions not yet implemented by this retained scheduler.\n// Refuse on actual dispatch, before consuming any payload.\nstatic const char* io_unavailable(u32 cid) {\n  switch (cid) {\n'
   for n in names:
    cid='CID_'+n.upper().replace('.','_');guard+=f'#ifdef {cid}\n    case {cid}: return "native {n} is not implemented by the retained IO runtime";\n#endif\n'
   guard+='    default: return "an alien request";\n  }\n}\n\n'
   new=replace(new,'// The continuation applied to the item is the next request.\nstatic int io_step',guard+'// The continuation applied to the item is the next request.\nstatic int io_step')
   new=replace(new,'      err_fail("an alien request");','      err_fail(io_unavailable(c));')
  if name in ['effs/chan.c','effs/chan_send.c']:
   new=replace(new,'    term_drop(e, f[1]);\n    return chan_bool(false);','    return io_box(e, CID_FAIL, f[1]);')
   new=replace(new,'return chan_bool(true);','return chan_done(e);',2)
  if name in ['effs/chan.c','effs/chan_recv.c']:
   new=replace(new,'chan_take(row)','chan_take(e, row)')
   new=replace(new,'chan_wake(row, chan_bool(true))','chan_wake(row, chan_done(e))')
  if name=='effs/tcp_recv.c':
   new=replace(new,': io_done(e, read(e, w->data, w->size));',': io_done(e, w->size == 0 ? term_pak(CID_NONE, 0)\n      : io_box(e, CID_SOME, read(e, w->data, w->size)));')
  if name=='effs/tcp_send.c':
   new=replace(new,'static Term tcp_send_more(Env e, IoWork* w) {','static Term tcp_send_with(Env e, IoWork* w, IoPack more,\n  Term (*make)(Env, const char*, u64)) {')
   new=replace(new,'io_wait_on(w, fd, POLLOUT, 0, tcp_send_more)','io_wait_on(w, fd, POLLOUT, 0, more)')
   new=replace(new,'  Term r = w->code != 0 ? io_fail(e, w->code, NULL)\n    : io_done(e, term_pak(CID_UNIT, 0));','  Term r = w->code != 0 ? io_box(e, CID_FAIL, io_tup(e,\n      io_err(e, w->code, NULL), make(e, w->data + w->made, w->size - (u64)w->made)))\n    : io_done(e, term_pak(CID_UNIT, 0));')
   new=replace(new,'#ifdef CID_TCP_SEND\n','static Term tcp_send_more(Env e, IoWork* w) {\n  return tcp_send_with(e, w, tcp_send_more, io_str);\n}\n\n#ifdef CID_TCP_SEND\n')
   new=replace(new,'// A value past 255 fails with EINVAL before any byte is sent.','static Term tcp_send_bytes_more(Env e, IoWork* w) {\n  return tcp_send_with(e, w, tcp_send_bytes_more, io_list);\n}\n\n// Validate before consuming: failure must return the exact original list.')
   new=replace(new,'  w->data = io_cbuf(e, f[1], &w->size, CID_CON);','  for (Term s = f[1]; term_aux(s) == CID_CON;) {\n    Loc at = term_peek(e, s);\n    if (e.mem[at] > 255) {\n      return io_tup(e, f[0], io_box(e, CID_FAIL,\n        io_tup(e, io_err(e, EINVAL, NULL), f[1])));\n    }\n    s = e.mem[at + 1];\n  }\n  w->data = io_cbuf(e, f[1], &w->size, CID_CON);')
   new=replace(new,'  w->code = w->data == NULL ? EINVAL : 0;\n  return tcp_send_more(e, w);','  w->code = 0;\n  return tcp_send_bytes_more(e, w);')
  if name=='effs/udp_send_to.c':
   new=replace(new,'  Term r = w->code != 0 ? io_fail(e, w->code, NULL)\n    : io_done(e, term_pak(CID_UNIT, 0));','  Term r = w->code != 0 ? io_box(e, CID_FAIL, io_tup(e,\n      io_err(e, w->code, NULL), io_str(e, w->data, w->size)))\n    : io_done(e, term_pak(CID_UNIT, 0));')
   new=replace(new,'    free(w->text);\n    free(w->data);\n    return io_tup(e, io_hand(w->hand), io_fail(e, EINVAL, NULL));','    Term r = io_box(e, CID_FAIL, io_tup(e, io_err(e, EINVAL, NULL),\n      io_str(e, w->data, w->size)));\n    free(w->text);\n    free(w->data);\n    return io_tup(e, io_hand(w->hand), r);')
  if name=='effs/udp_recv_from.c':
   new=replace(new,'  w->hand = (intptr_t)io_hand_v(f[0]);\n  w->made = f[1] < INT32_MAX ? (intptr_t)f[1] : INT32_MAX;','  w->hand = (intptr_t)io_hand_v(f[0]);\n  if (f[1] == 0) {\n    return io_tup(e, io_hand(w->hand), io_fail(e, EINVAL, NULL));\n  }\n  w->made = f[1] < INT32_MAX ? (intptr_t)f[1] : INT32_MAX;')
   new=replace(new,'io_eff(CID_UDP_RECV_FROM, udp_recv_from_run, IO_READ);','io_eff(CID_UDP_RECV_FROM, udp_recv_from_run, 0);')
   new=replace(new,'// The loop parked the request until the socket was readable; a recv that\n// still finds no datagram (the socket is non-blocking) parks again.','// A zero max refuses immediately; a non-blocking recv with no datagram\n// parks until readable, preserving an empty datagram as valid data.')
  assert new!=old,name
  if name!='runtime.c':new='// Phase66: current Base blocking result ABI on the retained IoAct scheduler.\n'+new
  b=OUT/'before'/name;a=OUT/'after'/name;b.parent.mkdir(parents=True,exist_ok=True);a.parent.mkdir(parents=True,exist_ok=True);b.write_text(old);a.write_text(new)
  rel='selfhost/src/runtime/native/'+name;patch.extend(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile=rel,tofile=rel));rows.append({'relative':rel,'before':pin(b),'after':pin(a),'liveSource':pin(live),'physicalLineDelta':len(new.splitlines())-len(old.splitlines())})
 (OUT/'candidate.patch').write_text(''.join(patch));m={'kind':'phase66-native-blocking-effects-candidate','version':1,'targetExecuted':False,'producer':pin(Path(__file__)),'prerequisite':pin(Path(__file__).with_name('native-abi-v1')/'candidate.json'),'patch':pin(OUT/'candidate.patch'),'files':rows,'scope':'Current Base ordinary blocking API ABI. No scheduler rewrite, Bend code, B1 image, or direct/legacy JS changes. New11 try_ and2 UDP byte methods get explicit refusal only when actually dispatched; no support claim.'};(OUT/'candidate.json').write_text(json.dumps(m,indent=2)+'\n');print(json.dumps({'candidate':pin(OUT/'candidate.json'),'patch':m['patch'],'lines':sum(x['physicalLineDelta'] for x in rows)}))
if __name__=='__main__':main()
