#include <stdint.h>
#include <stdio.h>
/* Independent unsigned-word and masked-array oracle; no compiler execution. */
int main(void) {
  uint32_t a[8], index=UINT32_C(4294967289), key=123;
  for (unsigned j=0; j<8; ++j) a[j]=17;
  for (unsigned j=0; j<37; ++j) {
    uint32_t next=(a[index&7]*UINT32_C(17))^key;
    a[index&7]=next;
    key=next^(key+UINT32_C(23));
    index+=3;
  }
  printf("%u\n",key);
}
