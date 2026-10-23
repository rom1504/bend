
/home/ai/bend2/build/publish/bend/selfhost/build/phase93/broad01/coverage-record-aggregation-256/upstream.program:     file format elf64-x86-64


Disassembly of section .text:

0000000000011cb0 <WL_FID_MAP_BIT>:
   11cb0:	48 89 d1             	mov    %rdx,%rcx
   11cb3:	48 ba e1 83 0f 3e f8 	movabs $0xf83e0f83e0f83e1,%rdx
   11cba:	e0 83 0f 
   11cbd:	48 89 c8             	mov    %rcx,%rax
   11cc0:	48 f7 e2             	mul    %rdx
   11cc3:	48 d1 ea             	shr    %rdx
   11cc6:	48 89 d0             	mov    %rdx,%rax
   11cc9:	48 c1 e0 05          	shl    $0x5,%rax
   11ccd:	48 01 d0             	add    %rdx,%rax
   11cd0:	48 29 c1             	sub    %rax,%rcx
   11cd3:	45 85 ff             	test   %r15d,%r15d
   11cd6:	0f 85 f4 cd ff ff    	jne    ead0 <WL_FID_MAP_BIT_GO>
   11cdc:	4d 8b 4e e8          	mov    -0x18(%r14),%r9
   11ce0:	4d 8b 46 f0          	mov    -0x10(%r14),%r8
   11ce4:	49 8b 45 18          	mov    0x18(%r13),%rax
   11ce8:	48 85 c0             	test   %rax,%rax
   11ceb:	74 3d                	je     11d2a <WL_FID_MAP_BIT+0x7a>
   11ced:	49 8b 3c c4          	mov    (%r12,%rax,8),%rdi
   11cf1:	49 89 7d 18          	mov    %rdi,0x18(%r13)
   11cf5:	49 83 85 18 01 00 00 	addq   $0xfffffffffffffff8,0x118(%r13)
   11cfc:	f8 
   11cfd:	4d 89 4c c4 18       	mov    %r9,0x18(%r12,%rax,8)
   11d02:	49 c1 e0 20          	shl    $0x20,%r8
   11d06:	4d 89 44 c4 20       	mov    %r8,0x20(%r12,%rax,8)
   11d0b:	49 89 34 c4          	mov    %rsi,(%r12,%rax,8)
   11d0f:	49 89 54 c4 08       	mov    %rdx,0x8(%r12,%rax,8)
   11d14:	49 89 4c c4 10       	mov    %rcx,0x10(%r12,%rax,8)
   11d19:	48 b9 00 00 00 00 00 	movabs $0x5002b0000000000,%rcx
   11d20:	2b 00 05 
   11d23:	48 09 c1             	or     %rax,%rcx
   11d26:	48 89 c8             	mov    %rcx,%rax
   11d29:	c3                   	retq   
   11d2a:	50                   	push   %rax
   11d2b:	4c 89 e7             	mov    %r12,%rdi
   11d2e:	49 89 f2             	mov    %rsi,%r10
   11d31:	4c 89 ee             	mov    %r13,%rsi
   11d34:	48 89 d3             	mov    %rdx,%rbx
   11d37:	ba 03 00 00 00       	mov    $0x3,%edx
   11d3c:	e8 e5 b5 00 00       	callq  1d326 <heap_alloc_miss>
   11d41:	48 89 da             	mov    %rbx,%rdx
   11d44:	4c 89 d6             	mov    %r10,%rsi
   11d47:	48 83 c4 08          	add    $0x8,%rsp
   11d4b:	eb b0                	jmp    11cfd <WL_FID_MAP_BIT+0x4d>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
