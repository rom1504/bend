
/home/ai/bend2/build/publish/bend/selfhost/build/phase126/runtime-divmod01/runtime.o:     file format elf64-x86-64


Disassembly of section .text:

000000000000a720 <p126_rt_nat_divmod>:
    a720:	48 85 c9             	test   %rcx,%rcx
    a723:	74 23                	je     a748 <p126_rt_nat_divmod+0x28>
    a725:	48 89 f7             	mov    %rsi,%rdi
    a728:	48 89 d6             	mov    %rdx,%rsi
    a72b:	48 85 d2             	test   %rdx,%rdx
    a72e:	74 0e                	je     a73e <p126_rt_nat_divmod+0x1e>
    a730:	48 89 f8             	mov    %rdi,%rax
    a733:	31 d2                	xor    %edx,%edx
    a735:	48 f7 f6             	div    %rsi
    a738:	48 89 d7             	mov    %rdx,%rdi
    a73b:	48 89 c6             	mov    %rax,%rsi
    a73e:	48 89 31             	mov    %rsi,(%rcx)
    a741:	31 c0                	xor    %eax,%eax
    a743:	48 89 79 08          	mov    %rdi,0x8(%rcx)
    a747:	c3                   	retq   
    a748:	50                   	push   %rax
    a749:	48 8d 3d 00 00 00 00 	lea    0x0(%rip),%rdi        # a750 <p126_rt_nat_divmod+0x30>
    a750:	e8 0b 5c ff ff       	callq  360 <err_fail>

Disassembly of section .text.unlikely:
