import fs from 'node:fs';
import {parentPort, workerData} from 'node:worker_threads';
import {pathToFileURL} from 'node:url';

const tImp0 = performance.now();
const api = (await import(pathToFileURL(workerData.apiPath))).default;
const importMs = +(performance.now() - tImp0).toFixed(1);

parentPort.postMessage({type: 'ready', workerId: workerData.workerId, importMs});

function bytesListToBuffer(list) {
  const bytes = [];
  let cur = list;
  while (cur?.$ === 'Con') {
    bytes.push(cur.head);
    cur = cur.tail;
  }
  if (cur?.$ !== 'Nil') {
    throw Error('invalid ELF byte list');
  }
  return Buffer.from(bytes);
}

parentPort.on('message', (msg) => {
  if (msg.type === 'shutdown') {
    process.exit(0);
  }
  if (msg.type === 'emit') {
    try {
      const t0 = performance.now();
      let obj;
      if (msg.mode === 'presliced') {
        obj = api.agy_parcg_emit_presliced(msg.ready, Boolean(msg.isMain));
      } else {
        obj = api.agy_parcg_emit_shard(msg.ready, msg.shard, msg.shards);
      }
      const emitMs = +(performance.now() - t0).toFixed(1);
      if (obj.error !== '') {
        parentPort.postMessage({type: 'done', id: msg.id, shard: msg.shard, ok: false, error: obj.error, emitMs});
        return;
      }
      const buf = bytesListToBuffer(obj.bytes);
      fs.writeFileSync(msg.outObjPath, buf);
      const totalMs = +(performance.now() - t0).toFixed(1);
      parentPort.postMessage({
        type: 'done',
        id: msg.id,
        shard: msg.shard,
        ok: true,
        bytes: buf.length,
        emitMs,
        totalMs,
        outObjPath: msg.outObjPath,
      });
    } catch (e) {
      parentPort.postMessage({
        type: 'done',
        id: msg.id,
        shard: msg.shard,
        ok: false,
        error: String(e?.stack || e),
      });
    }
  }
});
