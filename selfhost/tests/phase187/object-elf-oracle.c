#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern uintptr_t p187elf_value(void);
extern uint64_t p187elf_read(void);
extern uint64_t p187elf_call(uint64_t);
extern uint64_t p187elf_jump(void);
extern uint64_t p187elf_data[2];
extern uint64_t *p187elf_pointer;
extern uint64_t (*p187elf_function)(uint64_t);
extern const unsigned char p187elf_rodata[16];

uint64_t p187elf_external(uint64_t value) {
  return value ^ UINT64_C(0xfedcba9876543210);
}

int main(void) {
  unsigned checks = 0, failures = 0;
#define CHECK(value) do { ++checks; if (!(value)) ++failures; } while (0)
  CHECK(p187elf_value() == (uintptr_t)p187elf_data);
  CHECK(p187elf_read() == UINT64_C(0x1122334455667788));
  CHECK(p187elf_data[1] == UINT64_C(0xffeeddccbbaa0099));
  CHECK(p187elf_pointer == &p187elf_data[1]);
  CHECK(*p187elf_pointer == UINT64_C(0xffeeddccbbaa0099));
  CHECK(p187elf_function == p187elf_call);
  CHECK(p187elf_jump() == 37);
  for (unsigned i = 0; i < 8; ++i) CHECK(p187elf_rodata[i] == i * 2 + 1);
  uintptr_t pointer;
  memcpy(&pointer, p187elf_rodata + 8, sizeof pointer);
  CHECK(pointer == (uintptr_t)&p187elf_data[1]);
  const uint64_t values[] = {0, 1, UINT64_MAX, UINT64_C(0x8000000000000000),
    UINT64_C(0x0123456789abcdef)};
  for (unsigned i = 0; i < sizeof values / sizeof values[0]; ++i) {
    CHECK(p187elf_call(values[i]) == (values[i] ^ UINT64_C(0xfedcba9876543210)));
    CHECK(p187elf_function(values[i]) == (values[i] ^ UINT64_C(0xfedcba9876543210)));
  }
  p187elf_data[0] = UINT64_C(0x8877665544332211);
  CHECK(p187elf_read() == UINT64_C(0x8877665544332211));
  printf("phase187 ELF oracle: checks=%u failures=%u\n", checks, failures);
  return failures != 0;
}
