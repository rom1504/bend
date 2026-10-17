// Linux host effects. Compiler policy and expected asset identities stay in Bend.
// read/path: Result<U32 & String, String>; publish: Result<U32 & String, Unit>.
// io_cstr consumes arguments; only the IO loop touches Bend values. Helpers own
// malloc buffers until pack. Read rejects invalid UTF-8 so io_str is lossless.
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/random.h>
#include <sys/stat.h>
#include <unistd.h>

typedef struct {
  char *path, *hash, *data;
  uint64_t size;
  uint32_t limit;
  const char *error;
} NativeHostWork;

static uint32_t nh_rotr(uint32_t x, unsigned n) {
  return (x >> n) | (x << (32 - n));
}

static void nh_sha_block(uint32_t h[8], const unsigned char *p) {
  static const uint32_t k[64] = {
    0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
  };
  uint32_t s[64];
  for (unsigned i = 0; i < 16; ++i)
    s[i] = (uint32_t)p[4*i]<<24 | (uint32_t)p[4*i+1]<<16 |
           (uint32_t)p[4*i+2]<<8 | p[4*i+3];
  for (unsigned i = 16; i < 64; ++i) {
    uint32_t x = s[i-15], y = s[i-2];
    s[i] = s[i-16] + (nh_rotr(x,7)^nh_rotr(x,18)^(x>>3)) + s[i-7] +
           (nh_rotr(y,17)^nh_rotr(y,19)^(y>>10));
  }
  uint32_t a=h[0],b=h[1],c=h[2],d=h[3],e=h[4],f=h[5],g=h[6],v=h[7];
  for (unsigned i = 0; i < 64; ++i) {
    uint32_t t = v + (nh_rotr(e,6)^nh_rotr(e,11)^nh_rotr(e,25)) +
                 ((e&f)^(~e&g)) + k[i] + s[i];
    uint32_t u = (nh_rotr(a,2)^nh_rotr(a,13)^nh_rotr(a,22)) + ((a&b)^(a&c)^(b&c));
    v=g; g=f; f=e; e=d+t; d=c; c=b; b=a; a=t+u;
  }
  h[0]+=a; h[1]+=b; h[2]+=c; h[3]+=d; h[4]+=e; h[5]+=f; h[6]+=g; h[7]+=v;
}

static void nh_sha256(const char *data, size_t size, char out[65]) {
  uint32_t h[8] = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
                   0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19};
  size_t full = size & ~(size_t)63, rest = size - full;
  for (size_t i = 0; i < full; i += 64) nh_sha_block(h, (const unsigned char *)data+i);
  unsigned char tail[128] = {0};
  memcpy(tail, data+full, rest); tail[rest] = 0x80;
  size_t width = rest < 56 ? 64 : 128;
  uint64_t bits = (uint64_t)size * 8;
  for (unsigned i = 0; i < 8; ++i) tail[width-1-i] = (unsigned char)(bits >> (8*i));
  nh_sha_block(h, tail);
  if (width == 128) nh_sha_block(h, tail+64);
  static const char hex[] = "0123456789abcdef";
  for (unsigned i = 0; i < 64; ++i) out[i] = hex[(h[i/8] >> (28-4*(i%8))) & 15];
  out[64] = 0;
}

static int nh_utf8(const char *text, size_t size) {
  unsigned need=0, lo=0x80, hi=0xbf;
  for (size_t i=0; i<size; ++i) {
    unsigned b=(unsigned char)text[i];
    if (need) { if (b<lo || b>hi) return 0; --need; lo=0x80; hi=0xbf; }
    else if (b>=0x80) {
      if (b<0xc2 || b>0xf4) return 0;
      need=b<0xe0 ? 1 : b<0xf0 ? 2 : 3;
      lo=b==0xe0 ? 0xa0 : b==0xf0 ? 0x90 : 0x80;
      hi=b==0xed ? 0x9f : b==0xf4 ? 0x8f : 0xbf;
    }
  }
  return need==0;
}

static Term nh_pack(Env e, IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  Term result=w->code ? io_fail(e,w->code,x->error) :
    io_done(e,w->word==2 ? term_pak(CID(Unit),0) : io_str(e,x->data,x->size));
  free(x->path); free(x->hash); free(x->data); free(x);
  return result;
}

static NativeHostWork *nh_begin(Env e, Term path, IoWork *w, uint32_t op) {
  NativeHostWork *x=io_mem(calloc(1,sizeof *x));
  uint64_t size=0;
  x->path=io_cstr(e,path,&size);
  w->data=(char *)x; w->word=op; w->code=io_nul(x->path,size) ? EILSEQ : 0;
  return x;
}

static void nh_read_call(IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  int fd=open(x->path,O_RDONLY|O_CLOEXEC|O_NOFOLLOW|O_NONBLOCK);
  if (fd<0) { w->code=errno; return; }
  struct stat before,after;
  if (fstat(fd,&before)<0) w->code=errno;
  else if (!S_ISREG(before.st_mode)) w->code=EINVAL;
  else if (before.st_size<0 || (uint64_t)before.st_size>x->limit ||
           (uint64_t)before.st_size>=SIZE_MAX) w->code=EFBIG;
  if (!w->code) {
    size_t size=(size_t)before.st_size, at=0;
    x->data=malloc(size+1);
    if (!x->data) w->code=ENOMEM;
    while (!w->code && at<size) {
      size_t count=size-at; if (count>1048576) count=1048576;
      ssize_t n=read(fd,x->data+at,count);
      if (n<0 && errno==EINTR) continue;
      if (n<=0) w->code=n<0 ? errno : EIO; else at+=(size_t)n;
    }
    if (!w->code) {
      char extra; ssize_t n;
      do { n=read(fd,&extra,1); } while (n<0 && errno==EINTR);
      if (n!=0) w->code=n<0 ? errno : EFBIG;
      else if (fstat(fd,&after)<0) w->code=errno;
      else if (before.st_size!=after.st_size ||
        before.st_mtim.tv_sec!=after.st_mtim.tv_sec || before.st_mtim.tv_nsec!=after.st_mtim.tv_nsec ||
        before.st_ctim.tv_sec!=after.st_ctim.tv_sec || before.st_ctim.tv_nsec!=after.st_ctim.tv_nsec) w->code=ESTALE;
      x->size=size; x->data[size]=0;
    }
  }
  if (close(fd)<0 && !w->code) w->code=errno; // Do not retry close on Linux.
  if (!w->code && x->hash[0]) {
    char actual[65]; nh_sha256(x->data,(size_t)x->size,actual);
    if (memcmp(actual,x->hash,64)) { w->code=EBADMSG; x->error="SHA-256 mismatch"; }
  }
  if (!w->code && !nh_utf8(x->data,(size_t)x->size)) w->code=EILSEQ;
}

Term native_host_read_run(Env e, Term *f, IoWork *w) {
  NativeHostWork *x=nh_begin(e,f[0],w,0);
  uint64_t n=0; x->hash=io_cstr(e,f[1],&n); x->limit=(uint32_t)f[2];
  if (n!=0 && n!=64) w->code=EINVAL;
  for (uint64_t i=0; i<n && !w->code; ++i)
    if (!((x->hash[i]>='0' && x->hash[i]<='9') || (x->hash[i]>='a' && x->hash[i]<='f'))) w->code=EINVAL;
  return w->code ? nh_pack(e,w) : io_work(w,nh_read_call,nh_pack);
}

static void nh_path_call(IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  if (x->path[0]) x->data=realpath(x->path,NULL);
  else {
    x->data=malloc(PATH_MAX+1);
    if (!x->data) { w->code=ENOMEM; return; }
    ssize_t n=readlink("/proc/self/exe",x->data,PATH_MAX);
    if (n<0) { w->code=errno; return; }
    if (n==PATH_MAX) { w->code=ENAMETOOLONG; return; }
    x->data[n]=0;
    char *slash=strrchr(x->data,'/');
    if (!slash) { w->code=EINVAL; return; }
    slash[slash==x->data ? 1 : 0]=0;
  }
  if (!x->data) { w->code=errno; return; }
  x->size=strlen(x->data);
  if (!nh_utf8(x->data,(size_t)x->size)) w->code=EILSEQ;
}

Term native_host_path_run(Env e, Term *f, IoWork *w) {
  nh_begin(e,f[0],w,1);
  return w->code ? nh_pack(e,w) : io_work(w,nh_path_call,nh_pack);
}

static void nh_publish_call(IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  char *slash=strrchr(x->path,'/'), *name=slash ? slash+1 : x->path;
  if (!*name) { w->code=EINVAL; return; }
  const char *dir=".";
  if (slash) { *slash=0; dir=slash==x->path ? "/" : x->path; }
  int parent=open(dir,O_RDONLY|O_DIRECTORY|O_CLOEXEC);
  if (parent<0) { w->code=errno; return; }
  int fd=-1; char temp[64]={0};
  for (unsigned attempt=0; attempt<64; ++attempt) {
    uint64_t random; size_t at=0;
    while (at<sizeof random) {
      ssize_t n=getrandom((char *)&random+at,sizeof random-at,0);
      if (n<0 && errno==EINTR) continue;
      if (n<=0) { w->code=n<0 ? errno : EIO; break; } at+=(size_t)n;
    }
    if (w->code) break;
    snprintf(temp,sizeof temp,".bend-native-%ld-%016llx",(long)getpid(),(unsigned long long)random);
    if (strcmp(temp,name)==0) continue;
    fd=openat(parent,temp,O_WRONLY|O_CREAT|O_EXCL|O_CLOEXEC,0600);
    if (fd>=0) break;
    if (errno!=EEXIST) { w->code=errno; break; }
  }
  if (fd<0) { if (!w->code) w->code=EEXIST; close(parent); return; }
  struct stat made;
  int known=fstat(fd,&made)==0;
  if (!known) w->code=errno;
  for (uint64_t at=0; !w->code && at<x->size;) {
    size_t count=(size_t)(x->size-at); if (count>1048576) count=1048576;
    ssize_t n=write(fd,x->data+at,count);
    if (n<0 && errno==EINTR) continue;
    if (n<=0) w->code=n<0 ? errno : EIO; else at+=(uint64_t)n;
  }
  if (!w->code && fsync(fd)<0) w->code=errno;
  // Keep the inode, not its mutable directory entry, through writer close.
  char proc[64]; int held=-1, published=0;
  if (!w->code) {
    snprintf(proc,sizeof proc,"/proc/self/fd/%d",fd);
    held=open(proc,O_PATH|O_CLOEXEC);
    if (held<0) w->code=errno;
  }
  if (close(fd)<0 && !w->code) w->code=errno;
  if (!w->code) {
    snprintf(proc,sizeof proc,"/proc/self/fd/%d",held);
    if (linkat(AT_FDCWD,proc,parent,name,AT_SYMLINK_FOLLOW)<0) w->code=errno;
    else published=1;
  }
  if (held>=0 && close(held)<0 && !w->code) w->code=errno;
  struct stat current;
  int cleanup=0;
  if (fstatat(parent,temp,&current,AT_SYMLINK_NOFOLLOW)<0) {
    if (errno!=ENOENT) cleanup=errno;
  } else if (!known || current.st_dev!=made.st_dev || current.st_ino!=made.st_ino) cleanup=ESTALE;
  else if (unlinkat(parent,temp,0)<0) cleanup=errno;
  if (!w->code) w->code=cleanup;
  if (close(parent)<0 && !w->code) w->code=errno;
  if (published && w->code) x->error="output published; temporary cleanup failed";
}

Term native_host_publish_run(Env e, Term *f, IoWork *w) {
  NativeHostWork *x=nh_begin(e,f[0],w,2);
  x->data=io_cstr(e,f[1],&x->size);
  if (x->size>67108864) w->code=EFBIG;
  return w->code ? nh_pack(e,w) : io_work(w,nh_publish_call,nh_pack);
}

static void __attribute__((constructor)) native_host_use(void) {
  io_eff(CID(NativeHost.read),native_host_read_run);
  io_eff(CID(NativeHost.path),native_host_path_run);
  io_eff(CID(NativeHost.publish),native_host_publish_run);
}
