// Disk transport only: public object/span validation stays in typed-driver.mjs.
import crypto from 'node:crypto';
const FORMAT='bend-base-cache-frame-1';
const digest=bytes=>crypto.createHash('sha256').update(bytes).digest('hex');
export function encodeBaseCacheFrame(cached,bookJson=JSON.stringify(cached.book)) {
  if(typeof bookJson!=='string')throw Error('Invalid source-aware Base cache');
  const payload=Buffer.from(bookJson,'utf8');
  if(cached.bookSha256!==digest(payload))throw Error('Invalid source-aware Base cache');
  const {book,...metadata}=cached;
  return Buffer.concat([Buffer.from(JSON.stringify({...metadata,format:FORMAT})+'\n'),payload]);
}
export function decodeBaseCacheFrame(bytes) {
  const cut=bytes.indexOf(10);
  if(cut<0)throw new SyntaxError('Malformed Base cache frame');
  const header=JSON.parse(bytes.subarray(0,cut).toString('utf8'));
  if(header===null||typeof header!=='object'||Array.isArray(header)||header.format!==FORMAT||Object.hasOwn(header,'book'))throw Error('Invalid source-aware Base cache');
  const payload=bytes.subarray(cut+1);
  if(typeof header.bookSha256!=='string'||header.bookSha256!==digest(payload))throw Error('Invalid source-aware Base cache');
  const {format,...cached}=header;
  return {...cached,book:JSON.parse(payload.toString('utf8'))};
}
