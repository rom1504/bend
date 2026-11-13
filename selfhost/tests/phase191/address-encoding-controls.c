#include <stdint.h>
#include <stdio.h>
#include <string.h>
static unsigned checks, failures;
static void check(int good){checks++;if(!good) failures++;}
extern const unsigned char p191ac_bytes_0[];
extern const unsigned char p191ac_bytes_1[];
extern const unsigned char p191ac_bytes_2[];
extern const unsigned char p191ac_bytes_3[];
extern const unsigned char p191ac_bytes_4[];
extern const unsigned char p191ac_bytes_5[];
extern const unsigned char p191ac_bytes_6[];
extern const unsigned char p191ac_bytes_7[];
extern const unsigned char p191ac_bytes_8[];
extern const unsigned char p191ac_bytes_9[];
extern const unsigned char p191ac_bytes_10[];
extern const unsigned char p191ac_bytes_11[];
extern const unsigned char p191ac_bytes_12[];
extern const unsigned char p191ac_bytes_13[];
extern const unsigned char p191ac_bytes_14[];
extern const unsigned char p191ac_bytes_15[];
extern const unsigned char p191ac_bytes_16[];
extern const unsigned char p191ac_bytes_17[];
extern const unsigned char p191ac_bytes_18[];
extern const unsigned char p191ac_bytes_19[];
extern const unsigned char p191ac_bytes_20[];
extern const unsigned char p191ac_bytes_21[];
extern const unsigned char p191ac_bytes_22[];
extern const unsigned char p191ac_bytes_23[];
extern const unsigned char p191ac_bytes_24[];
extern const unsigned char p191ac_bytes_25[];
extern const unsigned char p191ac_bytes_26[];
extern uint64_t p191ac_load64(const uint64_t*,uint64_t),p191ac_load32(const uint32_t*,uint64_t),p191ac_load8(const unsigned char*,uint64_t),p191ac_load_r12(const uint64_t*,uint64_t);
extern void p191ac_store64(uint64_t*,uint64_t,uint64_t);
int main(void){
  {const unsigned char expected[] = {72,139,20,8};check(memcmp(p191ac_bytes_0,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {72,139,20,72};check(memcmp(p191ac_bytes_1,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {72,139,20,136};check(memcmp(p191ac_bytes_2,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {72,139,20,200};check(memcmp(p191ac_bytes_3,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {72,139,20,204};check(memcmp(p191ac_bytes_4,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {72,139,84,205,0};check(memcmp(p191ac_bytes_5,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {79,139,124,229,0};check(memcmp(p191ac_bytes_6,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {74,139,4,160};check(memcmp(p191ac_bytes_7,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {65,139,4,76};check(memcmp(p191ac_bytes_8,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {68,139,68,183,127};check(memcmp(p191ac_bytes_9,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {68,139,132,183,128,0,0,0};check(memcmp(p191ac_bytes_10,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {68,139,68,183,128};check(memcmp(p191ac_bytes_11,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {68,139,132,183,127,255,255,255};check(memcmp(p191ac_bytes_12,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {68,139,132,183,0,0,0,128};check(memcmp(p191ac_bytes_13,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {68,139,132,183,255,255,255,127};check(memcmp(p191ac_bytes_14,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {64,136,52,15};check(memcmp(p191ac_bytes_15,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {64,138,60,8};check(memcmp(p191ac_bytes_16,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {71,136,124,108,8};check(memcmp(p191ac_bytes_17,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {71,15,182,4,108};check(memcmp(p191ac_bytes_18,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {102,71,15,126,12,172};check(memcmp(p191ac_bytes_19,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {243,71,15,88,12,172};check(memcmp(p191ac_bytes_20,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {79,141,84,229,0};check(memcmp(p191ac_bytes_21,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {79,15,175,84,229,248};check(memcmp(p191ac_bytes_22,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {3,4,183};check(memcmp(p191ac_bytes_23,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {67,199,132,172,128,0,0,0,120,86,52,18};check(memcmp(p191ac_bytes_24,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {67,15,149,68,37,0};check(memcmp(p191ac_bytes_25,expected,sizeof expected)==0);}
  {const unsigned char expected[] = {77,139,12,36};check(memcmp(p191ac_bytes_26,expected,sizeof expected)==0);}
  uint64_t a[12]; uint32_t b[12]; unsigned char d[12];
  for(unsigned i=0;i<12;i++){a[i]=UINT64_C(0xfedcba9800000000)+i;b[i]=UINT32_C(0x80000000)+i;d[i]=(unsigned char)(128+i);}
  for(unsigned i=1;i<10;i++){check(p191ac_load64(a,i)==a[i-1]);check(p191ac_load32(b,i)==b[i+1]);check(p191ac_load8(d,i)==d[i]);check(p191ac_load_r12(a,i)==a[i]);}
  for(unsigned i=1;i<10;i++){uint64_t before=a[i-1],after=a[i+1];p191ac_store64(a,i,UINT64_MAX-i);check(a[i]==UINT64_MAX-i&&a[i-1]==before&&a[i+1]==after);}
  printf("phase191 indexed controls: checks=%u failures=%u\n",checks,failures);return failures?1:0;
}
