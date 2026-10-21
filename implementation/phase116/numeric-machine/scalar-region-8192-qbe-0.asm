
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p114-final-screen01-scalar-region-8192-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000405070 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_>:
  405070:	f3 0f 1e fa          	endbr64 
  405074:	55                   	push   rbp
  405075:	48 89 e5             	mov    rbp,rsp
  405078:	48 83 ec 08          	sub    rsp,0x8
  40507c:	53                   	push   rbx
  40507d:	41 54                	push   r12
  40507f:	41 55                	push   r13
  405081:	41 56                	push   r14
  405083:	41 57                	push   r15
  405085:	4c 8b 5d 18          	mov    r11,QWORD PTR [rbp+0x18]
  405089:	4c 8b 55 10          	mov    r10,QWORD PTR [rbp+0x10]
  40508d:	48 89 c8             	mov    rax,rcx
  405090:	48 89 d1             	mov    rcx,rdx
  405093:	4c 89 c2             	mov    rdx,r8
  405096:	48 89 f7             	mov    rdi,rsi
  405099:	4c 89 ce             	mov    rsi,r9
  40509c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  4050a0:	48 83 ff 00          	cmp    rdi,0x0
  4050a4:	0f 84 5c 01 00 00    	je     405206 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_+0x196>
  4050aa:	41 89 d0             	mov    r8d,edx
  4050ad:	45 89 c1             	mov    r9d,r8d
  4050b0:	45 0f af c8          	imul   r9d,r8d
  4050b4:	44 89 cb             	mov    ebx,r9d
  4050b7:	49 89 d9             	mov    r9,rbx
  4050ba:	49 c1 e9 1f          	shr    r9,0x1f
  4050be:	49 83 f9 00          	cmp    r9,0x0
  4050c2:	41 0f 94 c1          	sete   r9b
  4050c6:	45 0f b6 c9          	movzx  r9d,r9b
  4050ca:	45 89 c9             	mov    r9d,r9d
  4050cd:	49 83 f9 01          	cmp    r9,0x1
  4050d1:	41 bc 00 00 00 ff    	mov    r12d,0xff000000
  4050d7:	41 b9 00 00 00 00    	mov    r9d,0x0
  4050dd:	4d 0f 44 e1          	cmove  r12,r9
  4050e1:	41 89 f1             	mov    r9d,esi
  4050e4:	45 89 cd             	mov    r13d,r9d
  4050e7:	45 0f af e9          	imul   r13d,r9d
  4050eb:	45 89 ed             	mov    r13d,r13d
  4050ee:	4d 89 ee             	mov    r14,r13
  4050f1:	49 c1 ee 1f          	shr    r14,0x1f
  4050f5:	49 83 fe 00          	cmp    r14,0x0
  4050f9:	41 0f 94 c6          	sete   r14b
  4050fd:	45 0f b6 f6          	movzx  r14d,r14b
  405101:	45 89 f6             	mov    r14d,r14d
  405104:	49 83 fe 01          	cmp    r14,0x1
  405108:	41 bf 00 00 00 ff    	mov    r15d,0xff000000
  40510e:	41 be 00 00 00 00    	mov    r14d,0x0
  405114:	4d 0f 45 f7          	cmovne r14,r15
  405118:	49 c1 ed 08          	shr    r13,0x8
  40511c:	4d 09 f5             	or     r13,r14
  40511f:	48 c1 eb 08          	shr    rbx,0x8
  405123:	49 89 de             	mov    r14,rbx
  405126:	4d 09 e6             	or     r14,r12
  405129:	44 89 f3             	mov    ebx,r14d
  40512c:	44 01 eb             	add    ebx,r13d
  40512f:	89 db                	mov    ebx,ebx
  405131:	48 81 fb 00 04 00 00 	cmp    rbx,0x400
  405138:	0f 97 c3             	seta   bl
  40513b:	0f b6 db             	movzx  ebx,bl
  40513e:	89 db                	mov    ebx,ebx
  405140:	48 83 fb 01          	cmp    rbx,0x1
  405144:	0f 94 c3             	sete   bl
  405147:	0f b6 db             	movzx  ebx,bl
  40514a:	83 f3 01             	xor    ebx,0x1
  40514d:	bb 01 00 00 00       	mov    ebx,0x1
  405152:	4d 89 d4             	mov    r12,r10
  405155:	41 ba 00 00 00 00    	mov    r10d,0x0
  40515b:	4c 0f 44 d3          	cmove  r10,rbx
  40515f:	45 0f af c1          	imul   r8d,r9d
  405163:	45 89 c0             	mov    r8d,r8d
  405166:	45 6b c0 02          	imul   r8d,r8d,0x2
  40516a:	45 89 c1             	mov    r9d,r8d
  40516d:	4d 89 c8             	mov    r8,r9
  405170:	49 c1 e8 1f          	shr    r8,0x1f
  405174:	49 83 f8 00          	cmp    r8,0x0
  405178:	41 0f 94 c0          	sete   r8b
  40517c:	45 0f b6 c0          	movzx  r8d,r8b
  405180:	45 89 c0             	mov    r8d,r8d
  405183:	49 83 f8 01          	cmp    r8,0x1
  405187:	bb 00 00 00 ff       	mov    ebx,0xff000000
  40518c:	41 b8 00 00 00 00    	mov    r8d,0x0
  405192:	49 0f 44 d8          	cmove  rbx,r8
  405196:	45 89 e0             	mov    r8d,r12d
  405199:	4d 09 c2             	or     r10,r8
  40519c:	49 83 fa 00          	cmp    r10,0x0
  4051a0:	41 0f 94 c0          	sete   r8b
  4051a4:	45 0f b6 c0          	movzx  r8d,r8b
  4051a8:	45 89 c4             	mov    r12d,r8d
  4051ab:	49 83 fc 01          	cmp    r12,0x1
  4051af:	41 0f 94 c0          	sete   r8b
  4051b3:	45 0f b6 c0          	movzx  r8d,r8b
  4051b7:	75 13                	jne    4051cc <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_+0x15c>
  4051b9:	4c 89 f2             	mov    rdx,r14
  4051bc:	41 f7 dd             	neg    r13d
  4051bf:	41 01 d5             	add    r13d,edx
  4051c2:	89 ca                	mov    edx,ecx
  4051c4:	45 89 ed             	mov    r13d,r13d
  4051c7:	44 01 ea             	add    edx,r13d
  4051ca:	89 d2                	mov    edx,edx
  4051cc:	49 83 fc 01          	cmp    r12,0x1
  4051d0:	75 0e                	jne    4051e0 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_+0x170>
  4051d2:	89 c6                	mov    esi,eax
  4051d4:	49 c1 e9 08          	shr    r9,0x8
  4051d8:	49 09 d9             	or     r9,rbx
  4051db:	44 01 ce             	add    esi,r9d
  4051de:	89 f6                	mov    esi,esi
  4051e0:	41 83 f0 01          	xor    r8d,0x1
  4051e4:	41 b9 01 00 00 00    	mov    r9d,0x1
  4051ea:	41 b8 00 00 00 00    	mov    r8d,0x0
  4051f0:	4d 0f 45 c8          	cmovne r9,r8
  4051f4:	45 89 d8             	mov    r8d,r11d
  4051f7:	45 01 c8             	add    r8d,r9d
  4051fa:	45 89 c3             	mov    r11d,r8d
  4051fd:	48 83 ef 01          	sub    rdi,0x1
  405201:	e9 9a fe ff ff       	jmp    4050a0 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_+0x30>
  405206:	4c 89 d8             	mov    rax,r11
  405209:	41 5f                	pop    r15
  40520b:	41 5e                	pop    r14
  40520d:	41 5d                	pop    r13
  40520f:	41 5c                	pop    r12
  405211:	5b                   	pop    rbx
  405212:	c9                   	leave  
  405213:	c3                   	ret    

Disassembly of section .fini:
