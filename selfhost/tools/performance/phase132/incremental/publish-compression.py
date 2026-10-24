"""Lossless publication compression of the already closed evidence capsule."""
import gzip
import hashlib
import json
import lzma
from pathlib import Path
import tarfile
import time

ROOT = Path(__file__).resolve().parents[5]
PUB = ROOT / 'implementation/phase132/incremental-evidence'
RAW = ROOT / 'selfhost/build/phase132/object-publication-compression01'

def pin(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''): h.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())

def require(condition, message):
    if not condition: raise RuntimeError(message)

started = time.monotonic()
original = PUB / 'evidence.tar.gz'
output = PUB / 'evidence.tar.xz'
receipt_path = PUB / 'receipt.json'
inventory_path = PUB / 'inventory.json'
receipt_pin = pin(receipt_path)
inventory_pin = pin(inventory_path)
receipt = json.loads(receipt_path.read_text())
inventory = json.loads(inventory_path.read_text())
original_pin = pin(original)
require(original_pin in receipt['outputs'] and inventory_pin in receipt['outputs'], 'Original receipt identity differs')
require(receipt['complete'] and inventory['complete'] and receipt['everyMemberReopened'], 'Original evidence not closed')
require(not output.exists() and not RAW.exists(), 'Fresh output required')
tar_hash = hashlib.sha256()
tar_bytes = 0
filters = [dict(id=lzma.FILTER_LZMA2, preset=6, dict_size=64 * 1024 * 1024)]
with gzip.open(original, 'rb') as source, output.open('xb') as raw:
    with lzma.LZMAFile(raw, 'wb', format=lzma.FORMAT_XZ, check=lzma.CHECK_CRC64, filters=filters) as sink:
        for chunk in iter(lambda: source.read(1024 * 1024), b''):
            tar_hash.update(chunk); tar_bytes += len(chunk); sink.write(chunk)
reopened = hashlib.sha256()
reopened_bytes = 0
with lzma.open(output, 'rb') as source:
    for chunk in iter(lambda: source.read(1024 * 1024), b''):
        reopened.update(chunk); reopened_bytes += len(chunk)
require(reopened.digest() == tar_hash.digest() and reopened_bytes == tar_bytes, 'Raw tar stream differs')
with tarfile.open(output, 'r:xz') as archive:
    members = archive.getmembers()
    expected = inventory['members']
    require([m.name for m in members] == [r['member'] for r in expected], 'Member order differs')
    for member, row in zip(members, expected):
        require(member.isfile() and member.size == row['bytes'], 'Member shape differs')
        require(hashlib.sha256(archive.extractfile(member).read()).hexdigest() == row['sha256'], 'Member bytes differ')
require(pin(original) == original_pin and pin(receipt_path) == receipt_pin, 'Original evidence changed')
RAW.mkdir()
preserved = RAW / original.name
original.rename(preserved)
preserved_pin = pin(preserved)
require({k:preserved_pin[k] for k in ['bytes','sha256']} == {k:original_pin[k] for k in ['bytes','sha256']}, 'Preserved gzip differs')
result = dict(complete=True, targetsRun=False, method=pin(Path(__file__)), originalReceipt=receipt_pin,
    originalInventory=inventory_pin, originalArchive=original_pin, preservedOriginalArchive=preserved_pin,
    publishedArchive=pin(output), compression=dict(format='xz', preset=6, dictionaryBytes=64*1024*1024, check='CRC64'),
    exactTarStream=dict(bytes=tar_bytes, sha256=tar_hash.hexdigest()), members=len(members),
    everyMemberReopened=True, originalReceiptUnchanged=True, seconds=time.monotonic()-started,
    scope='Lossless publication encoding only. Same ordered members and exact raw tar bytes; no new semantic or compiler qualification.')
destination = PUB / 'publication-compression.json'
with destination.open('x') as f: json.dump(result, f, indent=2); f.write('\n')
print(json.dumps(dict(archive=result['publishedArchive'], receipt=pin(destination), members=len(members), seconds=result['seconds'])))
