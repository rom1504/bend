000000000040ac50 <p113d_FID_36_100_105_114_101_99_116_46_99_111_108_102_46_112_120_>:
  40ac50:	f3 0f 1e fa          	endbr64 
  40ac54:	55                   	push   %rbp
  40ac55:	48 89 e5             	mov    %rsp,%rbp
  40ac58:	48 89 c8             	mov    %rcx,%rax
  40ac5b:	4c 89 c1             	mov    %r8,%rcx
  40ac5e:	4d 89 c8             	mov    %r9,%r8
  40ac61:	41 89 f1             	mov    %esi,%r9d
  40ac64:	89 c0                	mov    %eax,%eax
  40ac66:	49 39 c1             	cmp    %rax,%r9
  40ac69:	0f 92 c0             	setb   %al
  40ac6c:	0f b6 c0             	movzbl %al,%eax
  40ac6f:	83 f0 01             	xor    $0x1,%eax
  40ac72:	75 07                	jne    40ac7b <p113d_FID_36_100_105_114_101_99_116_46_99_111_108_102_46_112_120_+0x2b>
  40ac74:	e8 a7 ef ff ff       	callq  409c20 <p113d_FID_36_100_105_114_101_99_116_46_112_105_120_101_108_>
  40ac79:	eb 05                	jmp    40ac80 <p113d_FID_36_100_105_114_101_99_116_46_99_111_108_102_46_112_120_+0x30>
  40ac7b:	b8 00 00 00 00       	mov    $0x0,%eax
  40ac80:	c9                   	leaveq 
  40ac81:	c3                   	retq   
  40ac82:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 nopw %cs:0x0(%rax,%rax,1)
  40ac8d:	0f 1f 00             	nopl   (%rax)

