
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a1010113          	addi	sp,sp,-1520 # 80008a10 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000024:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000028:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037961b          	slliw	a2,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	963a                	add	a2,a2,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f46b7          	lui	a3,0xf4
    80000040:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9736                	add	a4,a4,a3
    80000046:	e218                	sd	a4,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00279713          	slli	a4,a5,0x2
    8000004c:	973e                	add	a4,a4,a5
    8000004e:	070e                	slli	a4,a4,0x3
    80000050:	00009797          	auipc	a5,0x9
    80000054:	88078793          	addi	a5,a5,-1920 # 800088d0 <timer_scratch>
    80000058:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000005c:	f394                	sd	a3,32(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	ede78793          	addi	a5,a5,-290 # 80005f40 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	60a2                	ld	ra,8(sp)
    80000088:	6402                	ld	s0,0(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc6bf>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e6078793          	addi	a5,a5,-416 # 80000f0e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	711d                	addi	sp,sp,-96
    80000104:	ec86                	sd	ra,88(sp)
    80000106:	e8a2                	sd	s0,80(sp)
    80000108:	e0ca                	sd	s2,64(sp)
    8000010a:	1080                	addi	s0,sp,96
  int i;

  for(i = 0; i < n; i++){
    8000010c:	04c05b63          	blez	a2,80000162 <consolewrite+0x60>
    80000110:	e4a6                	sd	s1,72(sp)
    80000112:	fc4e                	sd	s3,56(sp)
    80000114:	f852                	sd	s4,48(sp)
    80000116:	f456                	sd	s5,40(sp)
    80000118:	f05a                	sd	s6,32(sp)
    8000011a:	ec5e                	sd	s7,24(sp)
    8000011c:	8a2a                	mv	s4,a0
    8000011e:	84ae                	mv	s1,a1
    80000120:	89b2                	mv	s3,a2
    80000122:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000124:	faf40b93          	addi	s7,s0,-81
    80000128:	4b05                	li	s6,1
    8000012a:	5afd                	li	s5,-1
    8000012c:	86da                	mv	a3,s6
    8000012e:	8626                	mv	a2,s1
    80000130:	85d2                	mv	a1,s4
    80000132:	855e                	mv	a0,s7
    80000134:	00002097          	auipc	ra,0x2
    80000138:	56a080e7          	jalr	1386(ra) # 8000269e <either_copyin>
    8000013c:	03550563          	beq	a0,s5,80000166 <consolewrite+0x64>
      break;
    uartputc(c);
    80000140:	faf44503          	lbu	a0,-81(s0)
    80000144:	00000097          	auipc	ra,0x0
    80000148:	7d8080e7          	jalr	2008(ra) # 8000091c <uartputc>
  for(i = 0; i < n; i++){
    8000014c:	2905                	addiw	s2,s2,1
    8000014e:	0485                	addi	s1,s1,1
    80000150:	fd299ee3          	bne	s3,s2,8000012c <consolewrite+0x2a>
    80000154:	64a6                	ld	s1,72(sp)
    80000156:	79e2                	ld	s3,56(sp)
    80000158:	7a42                	ld	s4,48(sp)
    8000015a:	7aa2                	ld	s5,40(sp)
    8000015c:	7b02                	ld	s6,32(sp)
    8000015e:	6be2                	ld	s7,24(sp)
    80000160:	a809                	j	80000172 <consolewrite+0x70>
    80000162:	4901                	li	s2,0
    80000164:	a039                	j	80000172 <consolewrite+0x70>
    80000166:	64a6                	ld	s1,72(sp)
    80000168:	79e2                	ld	s3,56(sp)
    8000016a:	7a42                	ld	s4,48(sp)
    8000016c:	7aa2                	ld	s5,40(sp)
    8000016e:	7b02                	ld	s6,32(sp)
    80000170:	6be2                	ld	s7,24(sp)
  }

  return i;
}
    80000172:	854a                	mv	a0,s2
    80000174:	60e6                	ld	ra,88(sp)
    80000176:	6446                	ld	s0,80(sp)
    80000178:	6906                	ld	s2,64(sp)
    8000017a:	6125                	addi	sp,sp,96
    8000017c:	8082                	ret

000000008000017e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000017e:	711d                	addi	sp,sp,-96
    80000180:	ec86                	sd	ra,88(sp)
    80000182:	e8a2                	sd	s0,80(sp)
    80000184:	e4a6                	sd	s1,72(sp)
    80000186:	e0ca                	sd	s2,64(sp)
    80000188:	fc4e                	sd	s3,56(sp)
    8000018a:	f852                	sd	s4,48(sp)
    8000018c:	f05a                	sd	s6,32(sp)
    8000018e:	ec5e                	sd	s7,24(sp)
    80000190:	1080                	addi	s0,sp,96
    80000192:	8b2a                	mv	s6,a0
    80000194:	8a2e                	mv	s4,a1
    80000196:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000198:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    8000019a:	00011517          	auipc	a0,0x11
    8000019e:	87650513          	addi	a0,a0,-1930 # 80010a10 <cons>
    800001a2:	00001097          	auipc	ra,0x1
    800001a6:	aba080e7          	jalr	-1350(ra) # 80000c5c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001aa:	00011497          	auipc	s1,0x11
    800001ae:	86648493          	addi	s1,s1,-1946 # 80010a10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b2:	00011917          	auipc	s2,0x11
    800001b6:	8f690913          	addi	s2,s2,-1802 # 80010aa8 <cons+0x98>
  while(n > 0){
    800001ba:	0d305563          	blez	s3,80000284 <consoleread+0x106>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	0af71a63          	bne	a4,a5,8000027a <consoleread+0xfc>
      if(killed(myproc())){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	936080e7          	jalr	-1738(ra) # 80001b00 <myproc>
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	31c080e7          	jalr	796(ra) # 800024ee <killed>
    800001da:	e52d                	bnez	a0,80000244 <consoleread+0xc6>
      sleep(&cons.r, &cons.lock);
    800001dc:	85a6                	mv	a1,s1
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	046080e7          	jalr	70(ra) # 80002226 <sleep>
    while(cons.r == cons.w){
    800001e8:	0984a783          	lw	a5,152(s1)
    800001ec:	09c4a703          	lw	a4,156(s1)
    800001f0:	fcf70de3          	beq	a4,a5,800001ca <consoleread+0x4c>
    800001f4:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f6:	00011717          	auipc	a4,0x11
    800001fa:	81a70713          	addi	a4,a4,-2022 # 80010a10 <cons>
    800001fe:	0017869b          	addiw	a3,a5,1
    80000202:	08d72c23          	sw	a3,152(a4)
    80000206:	07f7f693          	andi	a3,a5,127
    8000020a:	9736                	add	a4,a4,a3
    8000020c:	01874703          	lbu	a4,24(a4)
    80000210:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    80000214:	4691                	li	a3,4
    80000216:	04da8a63          	beq	s5,a3,8000026a <consoleread+0xec>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000021a:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000021e:	4685                	li	a3,1
    80000220:	faf40613          	addi	a2,s0,-81
    80000224:	85d2                	mv	a1,s4
    80000226:	855a                	mv	a0,s6
    80000228:	00002097          	auipc	ra,0x2
    8000022c:	420080e7          	jalr	1056(ra) # 80002648 <either_copyout>
    80000230:	57fd                	li	a5,-1
    80000232:	04f50863          	beq	a0,a5,80000282 <consoleread+0x104>
      break;

    dst++;
    80000236:	0a05                	addi	s4,s4,1
    --n;
    80000238:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000023a:	47a9                	li	a5,10
    8000023c:	04fa8f63          	beq	s5,a5,8000029a <consoleread+0x11c>
    80000240:	7aa2                	ld	s5,40(sp)
    80000242:	bfa5                	j	800001ba <consoleread+0x3c>
        release(&cons.lock);
    80000244:	00010517          	auipc	a0,0x10
    80000248:	7cc50513          	addi	a0,a0,1996 # 80010a10 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	ac0080e7          	jalr	-1344(ra) # 80000d0c <release>
        return -1;
    80000254:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000256:	60e6                	ld	ra,88(sp)
    80000258:	6446                	ld	s0,80(sp)
    8000025a:	64a6                	ld	s1,72(sp)
    8000025c:	6906                	ld	s2,64(sp)
    8000025e:	79e2                	ld	s3,56(sp)
    80000260:	7a42                	ld	s4,48(sp)
    80000262:	7b02                	ld	s6,32(sp)
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	6125                	addi	sp,sp,96
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0179fa63          	bgeu	s3,s7,8000027e <consoleread+0x100>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	82f72d23          	sw	a5,-1990(a4) # 80010aa8 <cons+0x98>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	a031                	j	80000284 <consoleread+0x106>
    8000027a:	f456                	sd	s5,40(sp)
    8000027c:	bfad                	j	800001f6 <consoleread+0x78>
    8000027e:	7aa2                	ld	s5,40(sp)
    80000280:	a011                	j	80000284 <consoleread+0x106>
    80000282:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000284:	00010517          	auipc	a0,0x10
    80000288:	78c50513          	addi	a0,a0,1932 # 80010a10 <cons>
    8000028c:	00001097          	auipc	ra,0x1
    80000290:	a80080e7          	jalr	-1408(ra) # 80000d0c <release>
  return target - n;
    80000294:	413b853b          	subw	a0,s7,s3
    80000298:	bf7d                	j	80000256 <consoleread+0xd8>
    8000029a:	7aa2                	ld	s5,40(sp)
    8000029c:	b7e5                	j	80000284 <consoleread+0x106>

000000008000029e <consputc>:
{
    8000029e:	1141                	addi	sp,sp,-16
    800002a0:	e406                	sd	ra,8(sp)
    800002a2:	e022                	sd	s0,0(sp)
    800002a4:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a6:	10000793          	li	a5,256
    800002aa:	00f50a63          	beq	a0,a5,800002be <consputc+0x20>
    uartputc_sync(c);
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	590080e7          	jalr	1424(ra) # 8000083e <uartputc_sync>
}
    800002b6:	60a2                	ld	ra,8(sp)
    800002b8:	6402                	ld	s0,0(sp)
    800002ba:	0141                	addi	sp,sp,16
    800002bc:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002be:	4521                	li	a0,8
    800002c0:	00000097          	auipc	ra,0x0
    800002c4:	57e080e7          	jalr	1406(ra) # 8000083e <uartputc_sync>
    800002c8:	02000513          	li	a0,32
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	572080e7          	jalr	1394(ra) # 8000083e <uartputc_sync>
    800002d4:	4521                	li	a0,8
    800002d6:	00000097          	auipc	ra,0x0
    800002da:	568080e7          	jalr	1384(ra) # 8000083e <uartputc_sync>
    800002de:	bfe1                	j	800002b6 <consputc+0x18>

00000000800002e0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002e0:	1101                	addi	sp,sp,-32
    800002e2:	ec06                	sd	ra,24(sp)
    800002e4:	e822                	sd	s0,16(sp)
    800002e6:	e426                	sd	s1,8(sp)
    800002e8:	1000                	addi	s0,sp,32
    800002ea:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002ec:	00010517          	auipc	a0,0x10
    800002f0:	72450513          	addi	a0,a0,1828 # 80010a10 <cons>
    800002f4:	00001097          	auipc	ra,0x1
    800002f8:	968080e7          	jalr	-1688(ra) # 80000c5c <acquire>

  switch(c){
    800002fc:	47d5                	li	a5,21
    800002fe:	0af48363          	beq	s1,a5,800003a4 <consoleintr+0xc4>
    80000302:	0297c963          	blt	a5,s1,80000334 <consoleintr+0x54>
    80000306:	47a1                	li	a5,8
    80000308:	0ef48a63          	beq	s1,a5,800003fc <consoleintr+0x11c>
    8000030c:	47c1                	li	a5,16
    8000030e:	10f49d63          	bne	s1,a5,80000428 <consoleintr+0x148>
  case C('P'):  // Print process list.
    procdump();
    80000312:	00002097          	auipc	ra,0x2
    80000316:	3e2080e7          	jalr	994(ra) # 800026f4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000031a:	00010517          	auipc	a0,0x10
    8000031e:	6f650513          	addi	a0,a0,1782 # 80010a10 <cons>
    80000322:	00001097          	auipc	ra,0x1
    80000326:	9ea080e7          	jalr	-1558(ra) # 80000d0c <release>
}
    8000032a:	60e2                	ld	ra,24(sp)
    8000032c:	6442                	ld	s0,16(sp)
    8000032e:	64a2                	ld	s1,8(sp)
    80000330:	6105                	addi	sp,sp,32
    80000332:	8082                	ret
  switch(c){
    80000334:	07f00793          	li	a5,127
    80000338:	0cf48263          	beq	s1,a5,800003fc <consoleintr+0x11c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000033c:	00010717          	auipc	a4,0x10
    80000340:	6d470713          	addi	a4,a4,1748 # 80010a10 <cons>
    80000344:	0a072783          	lw	a5,160(a4)
    80000348:	09872703          	lw	a4,152(a4)
    8000034c:	9f99                	subw	a5,a5,a4
    8000034e:	07f00713          	li	a4,127
    80000352:	fcf764e3          	bltu	a4,a5,8000031a <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000356:	47b5                	li	a5,13
    80000358:	0cf48b63          	beq	s1,a5,8000042e <consoleintr+0x14e>
      consputc(c);
    8000035c:	8526                	mv	a0,s1
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	f40080e7          	jalr	-192(ra) # 8000029e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000366:	00010717          	auipc	a4,0x10
    8000036a:	6aa70713          	addi	a4,a4,1706 # 80010a10 <cons>
    8000036e:	0a072683          	lw	a3,160(a4)
    80000372:	0016879b          	addiw	a5,a3,1
    80000376:	863e                	mv	a2,a5
    80000378:	0af72023          	sw	a5,160(a4)
    8000037c:	07f6f693          	andi	a3,a3,127
    80000380:	9736                	add	a4,a4,a3
    80000382:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000386:	ff648713          	addi	a4,s1,-10
    8000038a:	cb61                	beqz	a4,8000045a <consoleintr+0x17a>
    8000038c:	14f1                	addi	s1,s1,-4
    8000038e:	c4f1                	beqz	s1,8000045a <consoleintr+0x17a>
    80000390:	00010717          	auipc	a4,0x10
    80000394:	71872703          	lw	a4,1816(a4) # 80010aa8 <cons+0x98>
    80000398:	9f99                	subw	a5,a5,a4
    8000039a:	08000713          	li	a4,128
    8000039e:	f6e79ee3          	bne	a5,a4,8000031a <consoleintr+0x3a>
    800003a2:	a865                	j	8000045a <consoleintr+0x17a>
    800003a4:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a6:	00010717          	auipc	a4,0x10
    800003aa:	66a70713          	addi	a4,a4,1642 # 80010a10 <cons>
    800003ae:	0a072783          	lw	a5,160(a4)
    800003b2:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b6:	00010497          	auipc	s1,0x10
    800003ba:	65a48493          	addi	s1,s1,1626 # 80010a10 <cons>
    while(cons.e != cons.w &&
    800003be:	4929                	li	s2,10
    800003c0:	02f70a63          	beq	a4,a5,800003f4 <consoleintr+0x114>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003c4:	37fd                	addiw	a5,a5,-1
    800003c6:	07f7f713          	andi	a4,a5,127
    800003ca:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003cc:	01874703          	lbu	a4,24(a4)
    800003d0:	03270463          	beq	a4,s2,800003f8 <consoleintr+0x118>
      cons.e--;
    800003d4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d8:	10000513          	li	a0,256
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	ec2080e7          	jalr	-318(ra) # 8000029e <consputc>
    while(cons.e != cons.w &&
    800003e4:	0a04a783          	lw	a5,160(s1)
    800003e8:	09c4a703          	lw	a4,156(s1)
    800003ec:	fcf71ce3          	bne	a4,a5,800003c4 <consoleintr+0xe4>
    800003f0:	6902                	ld	s2,0(sp)
    800003f2:	b725                	j	8000031a <consoleintr+0x3a>
    800003f4:	6902                	ld	s2,0(sp)
    800003f6:	b715                	j	8000031a <consoleintr+0x3a>
    800003f8:	6902                	ld	s2,0(sp)
    800003fa:	b705                	j	8000031a <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003fc:	00010717          	auipc	a4,0x10
    80000400:	61470713          	addi	a4,a4,1556 # 80010a10 <cons>
    80000404:	0a072783          	lw	a5,160(a4)
    80000408:	09c72703          	lw	a4,156(a4)
    8000040c:	f0f707e3          	beq	a4,a5,8000031a <consoleintr+0x3a>
      cons.e--;
    80000410:	37fd                	addiw	a5,a5,-1
    80000412:	00010717          	auipc	a4,0x10
    80000416:	68f72f23          	sw	a5,1694(a4) # 80010ab0 <cons+0xa0>
      consputc(BACKSPACE);
    8000041a:	10000513          	li	a0,256
    8000041e:	00000097          	auipc	ra,0x0
    80000422:	e80080e7          	jalr	-384(ra) # 8000029e <consputc>
    80000426:	bdd5                	j	8000031a <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000428:	ee0489e3          	beqz	s1,8000031a <consoleintr+0x3a>
    8000042c:	bf01                	j	8000033c <consoleintr+0x5c>
      consputc(c);
    8000042e:	4529                	li	a0,10
    80000430:	00000097          	auipc	ra,0x0
    80000434:	e6e080e7          	jalr	-402(ra) # 8000029e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000438:	00010797          	auipc	a5,0x10
    8000043c:	5d878793          	addi	a5,a5,1496 # 80010a10 <cons>
    80000440:	0a07a703          	lw	a4,160(a5)
    80000444:	0017069b          	addiw	a3,a4,1
    80000448:	8636                	mv	a2,a3
    8000044a:	0ad7a023          	sw	a3,160(a5)
    8000044e:	07f77713          	andi	a4,a4,127
    80000452:	97ba                	add	a5,a5,a4
    80000454:	4729                	li	a4,10
    80000456:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000045a:	00010797          	auipc	a5,0x10
    8000045e:	64c7a923          	sw	a2,1618(a5) # 80010aac <cons+0x9c>
        wakeup(&cons.r);
    80000462:	00010517          	auipc	a0,0x10
    80000466:	64650513          	addi	a0,a0,1606 # 80010aa8 <cons+0x98>
    8000046a:	00002097          	auipc	ra,0x2
    8000046e:	e20080e7          	jalr	-480(ra) # 8000228a <wakeup>
    80000472:	b565                	j	8000031a <consoleintr+0x3a>

0000000080000474 <consoleinit>:

void
consoleinit(void)
{
    80000474:	1141                	addi	sp,sp,-16
    80000476:	e406                	sd	ra,8(sp)
    80000478:	e022                	sd	s0,0(sp)
    8000047a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000047c:	00008597          	auipc	a1,0x8
    80000480:	b8458593          	addi	a1,a1,-1148 # 80008000 <etext>
    80000484:	00010517          	auipc	a0,0x10
    80000488:	58c50513          	addi	a0,a0,1420 # 80010a10 <cons>
    8000048c:	00000097          	auipc	ra,0x0
    80000490:	736080e7          	jalr	1846(ra) # 80000bc2 <initlock>

  uartinit();
    80000494:	00000097          	auipc	ra,0x0
    80000498:	350080e7          	jalr	848(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000049c:	00021797          	auipc	a5,0x21
    800004a0:	b0c78793          	addi	a5,a5,-1268 # 80020fa8 <devsw>
    800004a4:	00000717          	auipc	a4,0x0
    800004a8:	cda70713          	addi	a4,a4,-806 # 8000017e <consoleread>
    800004ac:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004ae:	00000717          	auipc	a4,0x0
    800004b2:	c5470713          	addi	a4,a4,-940 # 80000102 <consolewrite>
    800004b6:	ef98                	sd	a4,24(a5)
}
    800004b8:	60a2                	ld	ra,8(sp)
    800004ba:	6402                	ld	s0,0(sp)
    800004bc:	0141                	addi	sp,sp,16
    800004be:	8082                	ret

00000000800004c0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004c0:	7179                	addi	sp,sp,-48
    800004c2:	f406                	sd	ra,40(sp)
    800004c4:	f022                	sd	s0,32(sp)
    800004c6:	e84a                	sd	s2,16(sp)
    800004c8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ca:	c219                	beqz	a2,800004d0 <printint+0x10>
    800004cc:	08054563          	bltz	a0,80000556 <printint+0x96>
    x = -xx;
  else
    x = xx;
    800004d0:	4301                	li	t1,0

  i = 0;
    800004d2:	fd040913          	addi	s2,s0,-48
    x = xx;
    800004d6:	86ca                	mv	a3,s2
  i = 0;
    800004d8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004da:	00008817          	auipc	a6,0x8
    800004de:	24e80813          	addi	a6,a6,590 # 80008728 <digits>
    800004e2:	88ba                	mv	a7,a4
    800004e4:	0017061b          	addiw	a2,a4,1
    800004e8:	8732                	mv	a4,a2
    800004ea:	02b577bb          	remuw	a5,a0,a1
    800004ee:	1782                	slli	a5,a5,0x20
    800004f0:	9381                	srli	a5,a5,0x20
    800004f2:	97c2                	add	a5,a5,a6
    800004f4:	0007c783          	lbu	a5,0(a5)
    800004f8:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004fc:	87aa                	mv	a5,a0
    800004fe:	02b5553b          	divuw	a0,a0,a1
    80000502:	0685                	addi	a3,a3,1
    80000504:	fcb7ffe3          	bgeu	a5,a1,800004e2 <printint+0x22>

  if(sign)
    80000508:	00030c63          	beqz	t1,80000520 <printint+0x60>
    buf[i++] = '-';
    8000050c:	fe060793          	addi	a5,a2,-32
    80000510:	00878633          	add	a2,a5,s0
    80000514:	02d00793          	li	a5,45
    80000518:	fef60823          	sb	a5,-16(a2)
    8000051c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    80000520:	02e05663          	blez	a4,8000054c <printint+0x8c>
    80000524:	ec26                	sd	s1,24(sp)
    80000526:	377d                	addiw	a4,a4,-1
    80000528:	00e904b3          	add	s1,s2,a4
    8000052c:	197d                	addi	s2,s2,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	1702                	slli	a4,a4,0x20
    80000532:	9301                	srli	a4,a4,0x20
    80000534:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000538:	0004c503          	lbu	a0,0(s1)
    8000053c:	00000097          	auipc	ra,0x0
    80000540:	d62080e7          	jalr	-670(ra) # 8000029e <consputc>
  while(--i >= 0)
    80000544:	14fd                	addi	s1,s1,-1
    80000546:	ff2499e3          	bne	s1,s2,80000538 <printint+0x78>
    8000054a:	64e2                	ld	s1,24(sp)
}
    8000054c:	70a2                	ld	ra,40(sp)
    8000054e:	7402                	ld	s0,32(sp)
    80000550:	6942                	ld	s2,16(sp)
    80000552:	6145                	addi	sp,sp,48
    80000554:	8082                	ret
    x = -xx;
    80000556:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055a:	4305                	li	t1,1
    x = -xx;
    8000055c:	bf9d                	j	800004d2 <printint+0x12>

000000008000055e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000055e:	1101                	addi	sp,sp,-32
    80000560:	ec06                	sd	ra,24(sp)
    80000562:	e822                	sd	s0,16(sp)
    80000564:	e426                	sd	s1,8(sp)
    80000566:	1000                	addi	s0,sp,32
    80000568:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056a:	00010797          	auipc	a5,0x10
    8000056e:	5607a323          	sw	zero,1382(a5) # 80010ad0 <pr+0x18>
  printf("panic: ");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	a9650513          	addi	a0,a0,-1386 # 80008008 <etext+0x8>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	02e080e7          	jalr	46(ra) # 800005a8 <printf>
  printf(s);
    80000582:	8526                	mv	a0,s1
    80000584:	00000097          	auipc	ra,0x0
    80000588:	024080e7          	jalr	36(ra) # 800005a8 <printf>
  printf("\n");
    8000058c:	00008517          	auipc	a0,0x8
    80000590:	a8450513          	addi	a0,a0,-1404 # 80008010 <etext+0x10>
    80000594:	00000097          	auipc	ra,0x0
    80000598:	014080e7          	jalr	20(ra) # 800005a8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059c:	4785                	li	a5,1
    8000059e:	00008717          	auipc	a4,0x8
    800005a2:	2ef72923          	sw	a5,754(a4) # 80008890 <panicked>
  for(;;)
    800005a6:	a001                	j	800005a6 <panic+0x48>

00000000800005a8 <printf>:
{
    800005a8:	7131                	addi	sp,sp,-192
    800005aa:	fc86                	sd	ra,120(sp)
    800005ac:	f8a2                	sd	s0,112(sp)
    800005ae:	e8d2                	sd	s4,80(sp)
    800005b0:	ec6e                	sd	s11,24(sp)
    800005b2:	0100                	addi	s0,sp,128
    800005b4:	8a2a                	mv	s4,a0
    800005b6:	e40c                	sd	a1,8(s0)
    800005b8:	e810                	sd	a2,16(s0)
    800005ba:	ec14                	sd	a3,24(s0)
    800005bc:	f018                	sd	a4,32(s0)
    800005be:	f41c                	sd	a5,40(s0)
    800005c0:	03043823          	sd	a6,48(s0)
    800005c4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c8:	00010d97          	auipc	s11,0x10
    800005cc:	508dad83          	lw	s11,1288(s11) # 80010ad0 <pr+0x18>
  if(locking)
    800005d0:	040d9463          	bnez	s11,80000618 <printf+0x70>
  if (fmt == 0)
    800005d4:	040a0b63          	beqz	s4,8000062a <printf+0x82>
  va_start(ap, fmt);
    800005d8:	00840793          	addi	a5,s0,8
    800005dc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e0:	000a4503          	lbu	a0,0(s4)
    800005e4:	18050c63          	beqz	a0,8000077c <printf+0x1d4>
    800005e8:	f4a6                	sd	s1,104(sp)
    800005ea:	f0ca                	sd	s2,96(sp)
    800005ec:	ecce                	sd	s3,88(sp)
    800005ee:	e4d6                	sd	s5,72(sp)
    800005f0:	e0da                	sd	s6,64(sp)
    800005f2:	fc5e                	sd	s7,56(sp)
    800005f4:	f862                	sd	s8,48(sp)
    800005f6:	f466                	sd	s9,40(sp)
    800005f8:	f06a                	sd	s10,32(sp)
    800005fa:	4981                	li	s3,0
    if(c != '%'){
    800005fc:	02500b13          	li	s6,37
    switch(c){
    80000600:	07000b93          	li	s7,112
  consputc('x');
    80000604:	07800c93          	li	s9,120
    80000608:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000060a:	00008a97          	auipc	s5,0x8
    8000060e:	11ea8a93          	addi	s5,s5,286 # 80008728 <digits>
    switch(c){
    80000612:	07300c13          	li	s8,115
    80000616:	a0b9                	j	80000664 <printf+0xbc>
    acquire(&pr.lock);
    80000618:	00010517          	auipc	a0,0x10
    8000061c:	4a050513          	addi	a0,a0,1184 # 80010ab8 <pr>
    80000620:	00000097          	auipc	ra,0x0
    80000624:	63c080e7          	jalr	1596(ra) # 80000c5c <acquire>
    80000628:	b775                	j	800005d4 <printf+0x2c>
    8000062a:	f4a6                	sd	s1,104(sp)
    8000062c:	f0ca                	sd	s2,96(sp)
    8000062e:	ecce                	sd	s3,88(sp)
    80000630:	e4d6                	sd	s5,72(sp)
    80000632:	e0da                	sd	s6,64(sp)
    80000634:	fc5e                	sd	s7,56(sp)
    80000636:	f862                	sd	s8,48(sp)
    80000638:	f466                	sd	s9,40(sp)
    8000063a:	f06a                	sd	s10,32(sp)
    panic("null fmt");
    8000063c:	00008517          	auipc	a0,0x8
    80000640:	9e450513          	addi	a0,a0,-1564 # 80008020 <etext+0x20>
    80000644:	00000097          	auipc	ra,0x0
    80000648:	f1a080e7          	jalr	-230(ra) # 8000055e <panic>
      consputc(c);
    8000064c:	00000097          	auipc	ra,0x0
    80000650:	c52080e7          	jalr	-942(ra) # 8000029e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000654:	0019879b          	addiw	a5,s3,1
    80000658:	89be                	mv	s3,a5
    8000065a:	97d2                	add	a5,a5,s4
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c2>
    if(c != '%'){
    80000664:	ff6514e3          	bne	a0,s6,8000064c <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	0019879b          	addiw	a5,s3,1
    8000066c:	89be                	mv	s3,a5
    8000066e:	97d2                	add	a5,a5,s4
    80000670:	0007c783          	lbu	a5,0(a5)
    80000674:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000678:	10078a63          	beqz	a5,8000078c <printf+0x1e4>
    switch(c){
    8000067c:	05778a63          	beq	a5,s7,800006d0 <printf+0x128>
    80000680:	02fbf463          	bgeu	s7,a5,800006a8 <printf+0x100>
    80000684:	09878763          	beq	a5,s8,80000712 <printf+0x16a>
    80000688:	0d979663          	bne	a5,s9,80000754 <printf+0x1ac>
      printint(va_arg(ap, int), 16, 1);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4605                	li	a2,1
    8000069a:	85ea                	mv	a1,s10
    8000069c:	4388                	lw	a0,0(a5)
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	e22080e7          	jalr	-478(ra) # 800004c0 <printint>
      break;
    800006a6:	b77d                	j	80000654 <printf+0xac>
    switch(c){
    800006a8:	0b678063          	beq	a5,s6,80000748 <printf+0x1a0>
    800006ac:	06400713          	li	a4,100
    800006b0:	0ae79263          	bne	a5,a4,80000754 <printf+0x1ac>
      printint(va_arg(ap, int), 10, 1);
    800006b4:	f8843783          	ld	a5,-120(s0)
    800006b8:	00878713          	addi	a4,a5,8
    800006bc:	f8e43423          	sd	a4,-120(s0)
    800006c0:	4605                	li	a2,1
    800006c2:	45a9                	li	a1,10
    800006c4:	4388                	lw	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	dfa080e7          	jalr	-518(ra) # 800004c0 <printint>
      break;
    800006ce:	b759                	j	80000654 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006d0:	f8843783          	ld	a5,-120(s0)
    800006d4:	00878713          	addi	a4,a5,8
    800006d8:	f8e43423          	sd	a4,-120(s0)
    800006dc:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006e0:	03000513          	li	a0,48
    800006e4:	00000097          	auipc	ra,0x0
    800006e8:	bba080e7          	jalr	-1094(ra) # 8000029e <consputc>
  consputc('x');
    800006ec:	8566                	mv	a0,s9
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	bb0080e7          	jalr	-1104(ra) # 8000029e <consputc>
    800006f6:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srli	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b9c080e7          	jalr	-1124(ra) # 8000029e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	slli	s2,s2,0x4
    8000070c:	34fd                	addiw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x150>
    80000710:	b791                	j	80000654 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	addi	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x192>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d51d                	beqz	a0,80000654 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b76080e7          	jalr	-1162(ra) # 8000029e <consputc>
      for(; *s; s++)
    80000730:	0485                	addi	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x180>
    80000738:	bf31                	j	80000654 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	addi	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x180>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b54080e7          	jalr	-1196(ra) # 8000029e <consputc>
      break;
    80000752:	b709                	j	80000654 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b48080e7          	jalr	-1208(ra) # 8000029e <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b3e080e7          	jalr	-1218(ra) # 8000029e <consputc>
      break;
    80000768:	b5f5                	j	80000654 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	7d02                	ld	s10,32(sp)
  if(locking)
    8000077c:	020d9263          	bnez	s11,800007a0 <printf+0x1f8>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	6de2                	ld	s11,24(sp)
    80000788:	6129                	addi	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	7d02                	ld	s10,32(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d4>
    release(&pr.lock);
    800007a0:	00010517          	auipc	a0,0x10
    800007a4:	31850513          	addi	a0,a0,792 # 80010ab8 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	564080e7          	jalr	1380(ra) # 80000d0c <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d8>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1141                	addi	sp,sp,-16
    800007b4:	e406                	sd	ra,8(sp)
    800007b6:	e022                	sd	s0,0(sp)
    800007b8:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    800007ba:	00008597          	auipc	a1,0x8
    800007be:	87658593          	addi	a1,a1,-1930 # 80008030 <etext+0x30>
    800007c2:	00010517          	auipc	a0,0x10
    800007c6:	2f650513          	addi	a0,a0,758 # 80010ab8 <pr>
    800007ca:	00000097          	auipc	ra,0x0
    800007ce:	3f8080e7          	jalr	1016(ra) # 80000bc2 <initlock>
  pr.locking = 1;
    800007d2:	4785                	li	a5,1
    800007d4:	00010717          	auipc	a4,0x10
    800007d8:	2ef72e23          	sw	a5,764(a4) # 80010ad0 <pr+0x18>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	addi	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	8732                	mv	a4,a2
    80000814:	461d                	li	a2,7
    80000816:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081a:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000081e:	00008597          	auipc	a1,0x8
    80000822:	81a58593          	addi	a1,a1,-2022 # 80008038 <etext+0x38>
    80000826:	00010517          	auipc	a0,0x10
    8000082a:	2b250513          	addi	a0,a0,690 # 80010ad8 <uart_tx_lock>
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	394080e7          	jalr	916(ra) # 80000bc2 <initlock>
}
    80000836:	60a2                	ld	ra,8(sp)
    80000838:	6402                	ld	s0,0(sp)
    8000083a:	0141                	addi	sp,sp,16
    8000083c:	8082                	ret

000000008000083e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000083e:	1101                	addi	sp,sp,-32
    80000840:	ec06                	sd	ra,24(sp)
    80000842:	e822                	sd	s0,16(sp)
    80000844:	e426                	sd	s1,8(sp)
    80000846:	1000                	addi	s0,sp,32
    80000848:	84aa                	mv	s1,a0
  push_off();
    8000084a:	00000097          	auipc	ra,0x0
    8000084e:	3c2080e7          	jalr	962(ra) # 80000c0c <push_off>

  if(panicked){
    80000852:	00008797          	auipc	a5,0x8
    80000856:	03e7a783          	lw	a5,62(a5) # 80008890 <panicked>
    8000085a:	eb85                	bnez	a5,8000088a <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085c:	10000737          	lui	a4,0x10000
    80000860:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000862:	00074783          	lbu	a5,0(a4)
    80000866:	0207f793          	andi	a5,a5,32
    8000086a:	dfe5                	beqz	a5,80000862 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086c:	0ff4f513          	zext.b	a0,s1
    80000870:	100007b7          	lui	a5,0x10000
    80000874:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000878:	00000097          	auipc	ra,0x0
    8000087c:	438080e7          	jalr	1080(ra) # 80000cb0 <pop_off>
}
    80000880:	60e2                	ld	ra,24(sp)
    80000882:	6442                	ld	s0,16(sp)
    80000884:	64a2                	ld	s1,8(sp)
    80000886:	6105                	addi	sp,sp,32
    80000888:	8082                	ret
    for(;;)
    8000088a:	a001                	j	8000088a <uartputc_sync+0x4c>

000000008000088c <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088c:	00008797          	auipc	a5,0x8
    80000890:	00c7b783          	ld	a5,12(a5) # 80008898 <uart_tx_r>
    80000894:	00008717          	auipc	a4,0x8
    80000898:	00c73703          	ld	a4,12(a4) # 800088a0 <uart_tx_w>
    8000089c:	06f70f63          	beq	a4,a5,8000091a <uartstart+0x8e>
{
    800008a0:	7139                	addi	sp,sp,-64
    800008a2:	fc06                	sd	ra,56(sp)
    800008a4:	f822                	sd	s0,48(sp)
    800008a6:	f426                	sd	s1,40(sp)
    800008a8:	f04a                	sd	s2,32(sp)
    800008aa:	ec4e                	sd	s3,24(sp)
    800008ac:	e852                	sd	s4,16(sp)
    800008ae:	e456                	sd	s5,8(sp)
    800008b0:	e05a                	sd	s6,0(sp)
    800008b2:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b4:	10000937          	lui	s2,0x10000
    800008b8:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ba:	00010a97          	auipc	s5,0x10
    800008be:	21ea8a93          	addi	s5,s5,542 # 80010ad8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c2:	00008497          	auipc	s1,0x8
    800008c6:	fd648493          	addi	s1,s1,-42 # 80008898 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008ca:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ce:	00008997          	auipc	s3,0x8
    800008d2:	fd298993          	addi	s3,s3,-46 # 800088a0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d6:	00094703          	lbu	a4,0(s2)
    800008da:	02077713          	andi	a4,a4,32
    800008de:	c705                	beqz	a4,80000906 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e0:	01f7f713          	andi	a4,a5,31
    800008e4:	9756                	add	a4,a4,s5
    800008e6:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ea:	0785                	addi	a5,a5,1
    800008ec:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008ee:	8526                	mv	a0,s1
    800008f0:	00002097          	auipc	ra,0x2
    800008f4:	99a080e7          	jalr	-1638(ra) # 8000228a <wakeup>
    WriteReg(THR, c);
    800008f8:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fc:	609c                	ld	a5,0(s1)
    800008fe:	0009b703          	ld	a4,0(s3)
    80000902:	fcf71ae3          	bne	a4,a5,800008d6 <uartstart+0x4a>
  }
}
    80000906:	70e2                	ld	ra,56(sp)
    80000908:	7442                	ld	s0,48(sp)
    8000090a:	74a2                	ld	s1,40(sp)
    8000090c:	7902                	ld	s2,32(sp)
    8000090e:	69e2                	ld	s3,24(sp)
    80000910:	6a42                	ld	s4,16(sp)
    80000912:	6aa2                	ld	s5,8(sp)
    80000914:	6b02                	ld	s6,0(sp)
    80000916:	6121                	addi	sp,sp,64
    80000918:	8082                	ret
    8000091a:	8082                	ret

000000008000091c <uartputc>:
{
    8000091c:	7179                	addi	sp,sp,-48
    8000091e:	f406                	sd	ra,40(sp)
    80000920:	f022                	sd	s0,32(sp)
    80000922:	ec26                	sd	s1,24(sp)
    80000924:	e84a                	sd	s2,16(sp)
    80000926:	e44e                	sd	s3,8(sp)
    80000928:	e052                	sd	s4,0(sp)
    8000092a:	1800                	addi	s0,sp,48
    8000092c:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000092e:	00010517          	auipc	a0,0x10
    80000932:	1aa50513          	addi	a0,a0,426 # 80010ad8 <uart_tx_lock>
    80000936:	00000097          	auipc	ra,0x0
    8000093a:	326080e7          	jalr	806(ra) # 80000c5c <acquire>
  if(panicked){
    8000093e:	00008797          	auipc	a5,0x8
    80000942:	f527a783          	lw	a5,-174(a5) # 80008890 <panicked>
    80000946:	ebc1                	bnez	a5,800009d6 <uartputc+0xba>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000948:	00008717          	auipc	a4,0x8
    8000094c:	f5873703          	ld	a4,-168(a4) # 800088a0 <uart_tx_w>
    80000950:	00008797          	auipc	a5,0x8
    80000954:	f487b783          	ld	a5,-184(a5) # 80008898 <uart_tx_r>
    80000958:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095c:	00010997          	auipc	s3,0x10
    80000960:	17c98993          	addi	s3,s3,380 # 80010ad8 <uart_tx_lock>
    80000964:	00008497          	auipc	s1,0x8
    80000968:	f3448493          	addi	s1,s1,-204 # 80008898 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096c:	00008917          	auipc	s2,0x8
    80000970:	f3490913          	addi	s2,s2,-204 # 800088a0 <uart_tx_w>
    80000974:	00e79f63          	bne	a5,a4,80000992 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000978:	85ce                	mv	a1,s3
    8000097a:	8526                	mv	a0,s1
    8000097c:	00002097          	auipc	ra,0x2
    80000980:	8aa080e7          	jalr	-1878(ra) # 80002226 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000984:	00093703          	ld	a4,0(s2)
    80000988:	609c                	ld	a5,0(s1)
    8000098a:	02078793          	addi	a5,a5,32
    8000098e:	fee785e3          	beq	a5,a4,80000978 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000992:	01f77693          	andi	a3,a4,31
    80000996:	00010797          	auipc	a5,0x10
    8000099a:	14278793          	addi	a5,a5,322 # 80010ad8 <uart_tx_lock>
    8000099e:	97b6                	add	a5,a5,a3
    800009a0:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a4:	0705                	addi	a4,a4,1
    800009a6:	00008797          	auipc	a5,0x8
    800009aa:	eee7bd23          	sd	a4,-262(a5) # 800088a0 <uart_tx_w>
  uartstart();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	ede080e7          	jalr	-290(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    800009b6:	00010517          	auipc	a0,0x10
    800009ba:	12250513          	addi	a0,a0,290 # 80010ad8 <uart_tx_lock>
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	34e080e7          	jalr	846(ra) # 80000d0c <release>
}
    800009c6:	70a2                	ld	ra,40(sp)
    800009c8:	7402                	ld	s0,32(sp)
    800009ca:	64e2                	ld	s1,24(sp)
    800009cc:	6942                	ld	s2,16(sp)
    800009ce:	69a2                	ld	s3,8(sp)
    800009d0:	6a02                	ld	s4,0(sp)
    800009d2:	6145                	addi	sp,sp,48
    800009d4:	8082                	ret
    for(;;)
    800009d6:	a001                	j	800009d6 <uartputc+0xba>

00000000800009d8 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d8:	1141                	addi	sp,sp,-16
    800009da:	e406                	sd	ra,8(sp)
    800009dc:	e022                	sd	s0,0(sp)
    800009de:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009e8:	8b85                	andi	a5,a5,1
    800009ea:	cb89                	beqz	a5,800009fc <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f4:	60a2                	ld	ra,8(sp)
    800009f6:	6402                	ld	s0,0(sp)
    800009f8:	0141                	addi	sp,sp,16
    800009fa:	8082                	ret
    return -1;
    800009fc:	557d                	li	a0,-1
    800009fe:	bfdd                	j	800009f4 <uartgetc+0x1c>

0000000080000a00 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a00:	1101                	addi	sp,sp,-32
    80000a02:	ec06                	sd	ra,24(sp)
    80000a04:	e822                	sd	s0,16(sp)
    80000a06:	e426                	sd	s1,8(sp)
    80000a08:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a0a:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a0c:	00000097          	auipc	ra,0x0
    80000a10:	fcc080e7          	jalr	-52(ra) # 800009d8 <uartgetc>
    if(c == -1)
    80000a14:	00950763          	beq	a0,s1,80000a22 <uartintr+0x22>
      break;
    consoleintr(c);
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	8c8080e7          	jalr	-1848(ra) # 800002e0 <consoleintr>
  while(1){
    80000a20:	b7f5                	j	80000a0c <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a22:	00010517          	auipc	a0,0x10
    80000a26:	0b650513          	addi	a0,a0,182 # 80010ad8 <uart_tx_lock>
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	232080e7          	jalr	562(ra) # 80000c5c <acquire>
  uartstart();
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	e5a080e7          	jalr	-422(ra) # 8000088c <uartstart>
  release(&uart_tx_lock);
    80000a3a:	00010517          	auipc	a0,0x10
    80000a3e:	09e50513          	addi	a0,a0,158 # 80010ad8 <uart_tx_lock>
    80000a42:	00000097          	auipc	ra,0x0
    80000a46:	2ca080e7          	jalr	714(ra) # 80000d0c <release>
}
    80000a4a:	60e2                	ld	ra,24(sp)
    80000a4c:	6442                	ld	s0,16(sp)
    80000a4e:	64a2                	ld	s1,8(sp)
    80000a50:	6105                	addi	sp,sp,32
    80000a52:	8082                	ret

0000000080000a54 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a54:	1101                	addi	sp,sp,-32
    80000a56:	ec06                	sd	ra,24(sp)
    80000a58:	e822                	sd	s0,16(sp)
    80000a5a:	e426                	sd	s1,8(sp)
    80000a5c:	e04a                	sd	s2,0(sp)
    80000a5e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a60:	00021797          	auipc	a5,0x21
    80000a64:	6e078793          	addi	a5,a5,1760 # 80022140 <end>
    80000a68:	00f53733          	sltu	a4,a0,a5
    80000a6c:	47c5                	li	a5,17
    80000a6e:	07ee                	slli	a5,a5,0x1b
    80000a70:	17fd                	addi	a5,a5,-1
    80000a72:	00a7b7b3          	sltu	a5,a5,a0
    80000a76:	8fd9                	or	a5,a5,a4
    80000a78:	e7a1                	bnez	a5,80000ac0 <kfree+0x6c>
    80000a7a:	84aa                	mv	s1,a0
    80000a7c:	03451793          	slli	a5,a0,0x34
    80000a80:	e3a1                	bnez	a5,80000ac0 <kfree+0x6c>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a82:	6605                	lui	a2,0x1
    80000a84:	4585                	li	a1,1
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	2ce080e7          	jalr	718(ra) # 80000d54 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a8e:	00010917          	auipc	s2,0x10
    80000a92:	08290913          	addi	s2,s2,130 # 80010b10 <kmem>
    80000a96:	854a                	mv	a0,s2
    80000a98:	00000097          	auipc	ra,0x0
    80000a9c:	1c4080e7          	jalr	452(ra) # 80000c5c <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	260080e7          	jalr	608(ra) # 80000d0c <release>
}
    80000ab4:	60e2                	ld	ra,24(sp)
    80000ab6:	6442                	ld	s0,16(sp)
    80000ab8:	64a2                	ld	s1,8(sp)
    80000aba:	6902                	ld	s2,0(sp)
    80000abc:	6105                	addi	sp,sp,32
    80000abe:	8082                	ret
    panic("kfree");
    80000ac0:	00007517          	auipc	a0,0x7
    80000ac4:	58050513          	addi	a0,a0,1408 # 80008040 <etext+0x40>
    80000ac8:	00000097          	auipc	ra,0x0
    80000acc:	a96080e7          	jalr	-1386(ra) # 8000055e <panic>

0000000080000ad0 <freerange>:
{
    80000ad0:	7179                	addi	sp,sp,-48
    80000ad2:	f406                	sd	ra,40(sp)
    80000ad4:	f022                	sd	s0,32(sp)
    80000ad6:	ec26                	sd	s1,24(sp)
    80000ad8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ada:	6785                	lui	a5,0x1
    80000adc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae0:	00e504b3          	add	s1,a0,a4
    80000ae4:	777d                	lui	a4,0xfffff
    80000ae6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	94be                	add	s1,s1,a5
    80000aea:	0295e463          	bltu	a1,s1,80000b12 <freerange+0x42>
    80000aee:	e84a                	sd	s2,16(sp)
    80000af0:	e44e                	sd	s3,8(sp)
    80000af2:	e052                	sd	s4,0(sp)
    80000af4:	892e                	mv	s2,a1
    kfree(p);
    80000af6:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af8:	89be                	mv	s3,a5
    kfree(p);
    80000afa:	01448533          	add	a0,s1,s4
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f56080e7          	jalr	-170(ra) # 80000a54 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b06:	94ce                	add	s1,s1,s3
    80000b08:	fe9979e3          	bgeu	s2,s1,80000afa <freerange+0x2a>
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
}
    80000b12:	70a2                	ld	ra,40(sp)
    80000b14:	7402                	ld	s0,32(sp)
    80000b16:	64e2                	ld	s1,24(sp)
    80000b18:	6145                	addi	sp,sp,48
    80000b1a:	8082                	ret

0000000080000b1c <kinit>:
{
    80000b1c:	1141                	addi	sp,sp,-16
    80000b1e:	e406                	sd	ra,8(sp)
    80000b20:	e022                	sd	s0,0(sp)
    80000b22:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b24:	00007597          	auipc	a1,0x7
    80000b28:	52458593          	addi	a1,a1,1316 # 80008048 <etext+0x48>
    80000b2c:	00010517          	auipc	a0,0x10
    80000b30:	fe450513          	addi	a0,a0,-28 # 80010b10 <kmem>
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	08e080e7          	jalr	142(ra) # 80000bc2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b3c:	45c5                	li	a1,17
    80000b3e:	05ee                	slli	a1,a1,0x1b
    80000b40:	00021517          	auipc	a0,0x21
    80000b44:	60050513          	addi	a0,a0,1536 # 80022140 <end>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	f88080e7          	jalr	-120(ra) # 80000ad0 <freerange>
}
    80000b50:	60a2                	ld	ra,8(sp)
    80000b52:	6402                	ld	s0,0(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b58:	1101                	addi	sp,sp,-32
    80000b5a:	ec06                	sd	ra,24(sp)
    80000b5c:	e822                	sd	s0,16(sp)
    80000b5e:	e426                	sd	s1,8(sp)
    80000b60:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b62:	00010517          	auipc	a0,0x10
    80000b66:	fae50513          	addi	a0,a0,-82 # 80010b10 <kmem>
    80000b6a:	00000097          	auipc	ra,0x0
    80000b6e:	0f2080e7          	jalr	242(ra) # 80000c5c <acquire>
  r = kmem.freelist;
    80000b72:	00010497          	auipc	s1,0x10
    80000b76:	fb64b483          	ld	s1,-74(s1) # 80010b28 <kmem+0x18>
  if(r)
    80000b7a:	c89d                	beqz	s1,80000bb0 <kalloc+0x58>
    kmem.freelist = r->next;
    80000b7c:	609c                	ld	a5,0(s1)
    80000b7e:	00010717          	auipc	a4,0x10
    80000b82:	faf73523          	sd	a5,-86(a4) # 80010b28 <kmem+0x18>
  release(&kmem.lock);
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	f8a50513          	addi	a0,a0,-118 # 80010b10 <kmem>
    80000b8e:	00000097          	auipc	ra,0x0
    80000b92:	17e080e7          	jalr	382(ra) # 80000d0c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b96:	6605                	lui	a2,0x1
    80000b98:	4595                	li	a1,5
    80000b9a:	8526                	mv	a0,s1
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	1b8080e7          	jalr	440(ra) # 80000d54 <memset>
  return (void*)r;
}
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	60e2                	ld	ra,24(sp)
    80000ba8:	6442                	ld	s0,16(sp)
    80000baa:	64a2                	ld	s1,8(sp)
    80000bac:	6105                	addi	sp,sp,32
    80000bae:	8082                	ret
  release(&kmem.lock);
    80000bb0:	00010517          	auipc	a0,0x10
    80000bb4:	f6050513          	addi	a0,a0,-160 # 80010b10 <kmem>
    80000bb8:	00000097          	auipc	ra,0x0
    80000bbc:	154080e7          	jalr	340(ra) # 80000d0c <release>
  if(r)
    80000bc0:	b7d5                	j	80000ba4 <kalloc+0x4c>

0000000080000bc2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bc2:	1141                	addi	sp,sp,-16
    80000bc4:	e406                	sd	ra,8(sp)
    80000bc6:	e022                	sd	s0,0(sp)
    80000bc8:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bca:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bcc:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bd0:	00053823          	sd	zero,16(a0)
}
    80000bd4:	60a2                	ld	ra,8(sp)
    80000bd6:	6402                	ld	s0,0(sp)
    80000bd8:	0141                	addi	sp,sp,16
    80000bda:	8082                	ret

0000000080000bdc <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bdc:	411c                	lw	a5,0(a0)
    80000bde:	e399                	bnez	a5,80000be4 <holding+0x8>
    80000be0:	4501                	li	a0,0
  return r;
}
    80000be2:	8082                	ret
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bee:	691c                	ld	a5,16(a0)
    80000bf0:	84be                	mv	s1,a5
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	eee080e7          	jalr	-274(ra) # 80001ae0 <mycpu>
    80000bfa:	40a48533          	sub	a0,s1,a0
    80000bfe:	00153513          	seqz	a0,a0
}
    80000c02:	60e2                	ld	ra,24(sp)
    80000c04:	6442                	ld	s0,16(sp)
    80000c06:	64a2                	ld	s1,8(sp)
    80000c08:	6105                	addi	sp,sp,32
    80000c0a:	8082                	ret

0000000080000c0c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c0c:	1101                	addi	sp,sp,-32
    80000c0e:	ec06                	sd	ra,24(sp)
    80000c10:	e822                	sd	s0,16(sp)
    80000c12:	e426                	sd	s1,8(sp)
    80000c14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c16:	100027f3          	csrr	a5,sstatus
    80000c1a:	84be                	mv	s1,a5
    80000c1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c22:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c26:	00001097          	auipc	ra,0x1
    80000c2a:	eba080e7          	jalr	-326(ra) # 80001ae0 <mycpu>
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	cf89                	beqz	a5,80000c4a <push_off+0x3e>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	eae080e7          	jalr	-338(ra) # 80001ae0 <mycpu>
    80000c3a:	5d3c                	lw	a5,120(a0)
    80000c3c:	2785                	addiw	a5,a5,1
    80000c3e:	dd3c                	sw	a5,120(a0)
}
    80000c40:	60e2                	ld	ra,24(sp)
    80000c42:	6442                	ld	s0,16(sp)
    80000c44:	64a2                	ld	s1,8(sp)
    80000c46:	6105                	addi	sp,sp,32
    80000c48:	8082                	ret
    mycpu()->intena = old;
    80000c4a:	00001097          	auipc	ra,0x1
    80000c4e:	e96080e7          	jalr	-362(ra) # 80001ae0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c52:	0014d793          	srli	a5,s1,0x1
    80000c56:	8b85                	andi	a5,a5,1
    80000c58:	dd7c                	sw	a5,124(a0)
    80000c5a:	bfe1                	j	80000c32 <push_off+0x26>

0000000080000c5c <acquire>:
{
    80000c5c:	1101                	addi	sp,sp,-32
    80000c5e:	ec06                	sd	ra,24(sp)
    80000c60:	e822                	sd	s0,16(sp)
    80000c62:	e426                	sd	s1,8(sp)
    80000c64:	1000                	addi	s0,sp,32
    80000c66:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c68:	00000097          	auipc	ra,0x0
    80000c6c:	fa4080e7          	jalr	-92(ra) # 80000c0c <push_off>
  if(holding(lk))
    80000c70:	8526                	mv	a0,s1
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	f6a080e7          	jalr	-150(ra) # 80000bdc <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7a:	4705                	li	a4,1
  if(holding(lk))
    80000c7c:	e115                	bnez	a0,80000ca0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7e:	87ba                	mv	a5,a4
    80000c80:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c84:	2781                	sext.w	a5,a5
    80000c86:	ffe5                	bnez	a5,80000c7e <acquire+0x22>
  __sync_synchronize();
    80000c88:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c8c:	00001097          	auipc	ra,0x1
    80000c90:	e54080e7          	jalr	-428(ra) # 80001ae0 <mycpu>
    80000c94:	e888                	sd	a0,16(s1)
}
    80000c96:	60e2                	ld	ra,24(sp)
    80000c98:	6442                	ld	s0,16(sp)
    80000c9a:	64a2                	ld	s1,8(sp)
    80000c9c:	6105                	addi	sp,sp,32
    80000c9e:	8082                	ret
    panic("acquire");
    80000ca0:	00007517          	auipc	a0,0x7
    80000ca4:	3b050513          	addi	a0,a0,944 # 80008050 <etext+0x50>
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	8b6080e7          	jalr	-1866(ra) # 8000055e <panic>

0000000080000cb0 <pop_off>:

void
pop_off(void)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e406                	sd	ra,8(sp)
    80000cb4:	e022                	sd	s0,0(sp)
    80000cb6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb8:	00001097          	auipc	ra,0x1
    80000cbc:	e28080e7          	jalr	-472(ra) # 80001ae0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cc4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cc6:	e39d                	bnez	a5,80000cec <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc8:	5d3c                	lw	a5,120(a0)
    80000cca:	02f05963          	blez	a5,80000cfc <pop_off+0x4c>
    panic("pop_off");
  c->noff -= 1;
    80000cce:	37fd                	addiw	a5,a5,-1
    80000cd0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cd2:	eb89                	bnez	a5,80000ce4 <pop_off+0x34>
    80000cd4:	5d7c                	lw	a5,124(a0)
    80000cd6:	c799                	beqz	a5,80000ce4 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cdc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ce0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ce4:	60a2                	ld	ra,8(sp)
    80000ce6:	6402                	ld	s0,0(sp)
    80000ce8:	0141                	addi	sp,sp,16
    80000cea:	8082                	ret
    panic("pop_off - interruptible");
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	36c50513          	addi	a0,a0,876 # 80008058 <etext+0x58>
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	86a080e7          	jalr	-1942(ra) # 8000055e <panic>
    panic("pop_off");
    80000cfc:	00007517          	auipc	a0,0x7
    80000d00:	37450513          	addi	a0,a0,884 # 80008070 <etext+0x70>
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	85a080e7          	jalr	-1958(ra) # 8000055e <panic>

0000000080000d0c <release>:
{
    80000d0c:	1101                	addi	sp,sp,-32
    80000d0e:	ec06                	sd	ra,24(sp)
    80000d10:	e822                	sd	s0,16(sp)
    80000d12:	e426                	sd	s1,8(sp)
    80000d14:	1000                	addi	s0,sp,32
    80000d16:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d18:	00000097          	auipc	ra,0x0
    80000d1c:	ec4080e7          	jalr	-316(ra) # 80000bdc <holding>
    80000d20:	c115                	beqz	a0,80000d44 <release+0x38>
  lk->cpu = 0;
    80000d22:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d26:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d2a:	0310000f          	fence	rw,w
    80000d2e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d32:	00000097          	auipc	ra,0x0
    80000d36:	f7e080e7          	jalr	-130(ra) # 80000cb0 <pop_off>
}
    80000d3a:	60e2                	ld	ra,24(sp)
    80000d3c:	6442                	ld	s0,16(sp)
    80000d3e:	64a2                	ld	s1,8(sp)
    80000d40:	6105                	addi	sp,sp,32
    80000d42:	8082                	ret
    panic("release");
    80000d44:	00007517          	auipc	a0,0x7
    80000d48:	33450513          	addi	a0,a0,820 # 80008078 <etext+0x78>
    80000d4c:	00000097          	auipc	ra,0x0
    80000d50:	812080e7          	jalr	-2030(ra) # 8000055e <panic>

0000000080000d54 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d54:	1141                	addi	sp,sp,-16
    80000d56:	e406                	sd	ra,8(sp)
    80000d58:	e022                	sd	s0,0(sp)
    80000d5a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d5c:	ca19                	beqz	a2,80000d72 <memset+0x1e>
    80000d5e:	87aa                	mv	a5,a0
    80000d60:	1602                	slli	a2,a2,0x20
    80000d62:	9201                	srli	a2,a2,0x20
    80000d64:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d68:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d6c:	0785                	addi	a5,a5,1
    80000d6e:	fee79de3          	bne	a5,a4,80000d68 <memset+0x14>
  }
  return dst;
}
    80000d72:	60a2                	ld	ra,8(sp)
    80000d74:	6402                	ld	s0,0(sp)
    80000d76:	0141                	addi	sp,sp,16
    80000d78:	8082                	ret

0000000080000d7a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d7a:	1141                	addi	sp,sp,-16
    80000d7c:	e406                	sd	ra,8(sp)
    80000d7e:	e022                	sd	s0,0(sp)
    80000d80:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d82:	c61d                	beqz	a2,80000db0 <memcmp+0x36>
    80000d84:	1602                	slli	a2,a2,0x20
    80000d86:	9201                	srli	a2,a2,0x20
    80000d88:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d8c:	00054783          	lbu	a5,0(a0)
    80000d90:	0005c703          	lbu	a4,0(a1)
    80000d94:	00e79863          	bne	a5,a4,80000da4 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d98:	0505                	addi	a0,a0,1
    80000d9a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d9c:	fed518e3          	bne	a0,a3,80000d8c <memcmp+0x12>
  }

  return 0;
    80000da0:	4501                	li	a0,0
    80000da2:	a019                	j	80000da8 <memcmp+0x2e>
      return *s1 - *s2;
    80000da4:	40e7853b          	subw	a0,a5,a4
}
    80000da8:	60a2                	ld	ra,8(sp)
    80000daa:	6402                	ld	s0,0(sp)
    80000dac:	0141                	addi	sp,sp,16
    80000dae:	8082                	ret
  return 0;
    80000db0:	4501                	li	a0,0
    80000db2:	bfdd                	j	80000da8 <memcmp+0x2e>

0000000080000db4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e406                	sd	ra,8(sp)
    80000db8:	e022                	sd	s0,0(sp)
    80000dba:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000dbc:	c205                	beqz	a2,80000ddc <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dbe:	02a5e363          	bltu	a1,a0,80000de4 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dc2:	1602                	slli	a2,a2,0x20
    80000dc4:	9201                	srli	a2,a2,0x20
    80000dc6:	00c587b3          	add	a5,a1,a2
{
    80000dca:	872a                	mv	a4,a0
      *d++ = *s++;
    80000dcc:	0585                	addi	a1,a1,1
    80000dce:	0705                	addi	a4,a4,1
    80000dd0:	fff5c683          	lbu	a3,-1(a1)
    80000dd4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dd8:	feb79ae3          	bne	a5,a1,80000dcc <memmove+0x18>

  return dst;
}
    80000ddc:	60a2                	ld	ra,8(sp)
    80000dde:	6402                	ld	s0,0(sp)
    80000de0:	0141                	addi	sp,sp,16
    80000de2:	8082                	ret
  if(s < d && s + n > d){
    80000de4:	02061693          	slli	a3,a2,0x20
    80000de8:	9281                	srli	a3,a3,0x20
    80000dea:	00d58733          	add	a4,a1,a3
    80000dee:	fce57ae3          	bgeu	a0,a4,80000dc2 <memmove+0xe>
    d += n;
    80000df2:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000df4:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000df8:	1782                	slli	a5,a5,0x20
    80000dfa:	9381                	srli	a5,a5,0x20
    80000dfc:	fff7c793          	not	a5,a5
    80000e00:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e02:	177d                	addi	a4,a4,-1
    80000e04:	16fd                	addi	a3,a3,-1
    80000e06:	00074603          	lbu	a2,0(a4)
    80000e0a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e0e:	fee79ae3          	bne	a5,a4,80000e02 <memmove+0x4e>
    80000e12:	b7e9                	j	80000ddc <memmove+0x28>

0000000080000e14 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e406                	sd	ra,8(sp)
    80000e18:	e022                	sd	s0,0(sp)
    80000e1a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e1c:	00000097          	auipc	ra,0x0
    80000e20:	f98080e7          	jalr	-104(ra) # 80000db4 <memmove>
}
    80000e24:	60a2                	ld	ra,8(sp)
    80000e26:	6402                	ld	s0,0(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret

0000000080000e2c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e406                	sd	ra,8(sp)
    80000e30:	e022                	sd	s0,0(sp)
    80000e32:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e34:	ce11                	beqz	a2,80000e50 <strncmp+0x24>
    80000e36:	00054783          	lbu	a5,0(a0)
    80000e3a:	cf89                	beqz	a5,80000e54 <strncmp+0x28>
    80000e3c:	0005c703          	lbu	a4,0(a1)
    80000e40:	00f71a63          	bne	a4,a5,80000e54 <strncmp+0x28>
    n--, p++, q++;
    80000e44:	367d                	addiw	a2,a2,-1
    80000e46:	0505                	addi	a0,a0,1
    80000e48:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e4a:	f675                	bnez	a2,80000e36 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e4c:	4501                	li	a0,0
    80000e4e:	a801                	j	80000e5e <strncmp+0x32>
    80000e50:	4501                	li	a0,0
    80000e52:	a031                	j	80000e5e <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e54:	00054503          	lbu	a0,0(a0)
    80000e58:	0005c783          	lbu	a5,0(a1)
    80000e5c:	9d1d                	subw	a0,a0,a5
}
    80000e5e:	60a2                	ld	ra,8(sp)
    80000e60:	6402                	ld	s0,0(sp)
    80000e62:	0141                	addi	sp,sp,16
    80000e64:	8082                	ret

0000000080000e66 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e66:	1141                	addi	sp,sp,-16
    80000e68:	e406                	sd	ra,8(sp)
    80000e6a:	e022                	sd	s0,0(sp)
    80000e6c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e6e:	87aa                	mv	a5,a0
    80000e70:	a011                	j	80000e74 <strncpy+0xe>
    80000e72:	8636                	mv	a2,a3
    80000e74:	02c05863          	blez	a2,80000ea4 <strncpy+0x3e>
    80000e78:	fff6069b          	addiw	a3,a2,-1
    80000e7c:	8836                	mv	a6,a3
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	0005c703          	lbu	a4,0(a1)
    80000e84:	fee78fa3          	sb	a4,-1(a5)
    80000e88:	0585                	addi	a1,a1,1
    80000e8a:	f765                	bnez	a4,80000e72 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e8c:	873e                	mv	a4,a5
    80000e8e:	01005b63          	blez	a6,80000ea4 <strncpy+0x3e>
    80000e92:	9fb1                	addw	a5,a5,a2
    80000e94:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e96:	0705                	addi	a4,a4,1
    80000e98:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e9c:	40e786bb          	subw	a3,a5,a4
    80000ea0:	fed04be3          	bgtz	a3,80000e96 <strncpy+0x30>
  return os;
}
    80000ea4:	60a2                	ld	ra,8(sp)
    80000ea6:	6402                	ld	s0,0(sp)
    80000ea8:	0141                	addi	sp,sp,16
    80000eaa:	8082                	ret

0000000080000eac <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eac:	1141                	addi	sp,sp,-16
    80000eae:	e406                	sd	ra,8(sp)
    80000eb0:	e022                	sd	s0,0(sp)
    80000eb2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eb4:	02c05363          	blez	a2,80000eda <safestrcpy+0x2e>
    80000eb8:	fff6069b          	addiw	a3,a2,-1
    80000ebc:	1682                	slli	a3,a3,0x20
    80000ebe:	9281                	srli	a3,a3,0x20
    80000ec0:	96ae                	add	a3,a3,a1
    80000ec2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ec4:	00d58963          	beq	a1,a3,80000ed6 <safestrcpy+0x2a>
    80000ec8:	0585                	addi	a1,a1,1
    80000eca:	0785                	addi	a5,a5,1
    80000ecc:	fff5c703          	lbu	a4,-1(a1)
    80000ed0:	fee78fa3          	sb	a4,-1(a5)
    80000ed4:	fb65                	bnez	a4,80000ec4 <safestrcpy+0x18>
    ;
  *s = 0;
    80000ed6:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eda:	60a2                	ld	ra,8(sp)
    80000edc:	6402                	ld	s0,0(sp)
    80000ede:	0141                	addi	sp,sp,16
    80000ee0:	8082                	ret

0000000080000ee2 <strlen>:

int
strlen(const char *s)
{
    80000ee2:	1141                	addi	sp,sp,-16
    80000ee4:	e406                	sd	ra,8(sp)
    80000ee6:	e022                	sd	s0,0(sp)
    80000ee8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eea:	00054783          	lbu	a5,0(a0)
    80000eee:	cf91                	beqz	a5,80000f0a <strlen+0x28>
    80000ef0:	00150793          	addi	a5,a0,1
    80000ef4:	86be                	mv	a3,a5
    80000ef6:	0785                	addi	a5,a5,1
    80000ef8:	fff7c703          	lbu	a4,-1(a5)
    80000efc:	ff65                	bnez	a4,80000ef4 <strlen+0x12>
    80000efe:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000f02:	60a2                	ld	ra,8(sp)
    80000f04:	6402                	ld	s0,0(sp)
    80000f06:	0141                	addi	sp,sp,16
    80000f08:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f0a:	4501                	li	a0,0
    80000f0c:	bfdd                	j	80000f02 <strlen+0x20>

0000000080000f0e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f0e:	1141                	addi	sp,sp,-16
    80000f10:	e406                	sd	ra,8(sp)
    80000f12:	e022                	sd	s0,0(sp)
    80000f14:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f16:	00001097          	auipc	ra,0x1
    80000f1a:	bb6080e7          	jalr	-1098(ra) # 80001acc <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f1e:	00008717          	auipc	a4,0x8
    80000f22:	98a70713          	addi	a4,a4,-1654 # 800088a8 <started>
  if(cpuid() == 0){
    80000f26:	c139                	beqz	a0,80000f6c <main+0x5e>
    while(started == 0)
    80000f28:	431c                	lw	a5,0(a4)
    80000f2a:	2781                	sext.w	a5,a5
    80000f2c:	dff5                	beqz	a5,80000f28 <main+0x1a>
      ;
    __sync_synchronize();
    80000f2e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f32:	00001097          	auipc	ra,0x1
    80000f36:	b9a080e7          	jalr	-1126(ra) # 80001acc <cpuid>
    80000f3a:	85aa                	mv	a1,a0
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	15c50513          	addi	a0,a0,348 # 80008098 <etext+0x98>
    80000f44:	fffff097          	auipc	ra,0xfffff
    80000f48:	664080e7          	jalr	1636(ra) # 800005a8 <printf>
    kvminithart();    // turn on paging
    80000f4c:	00000097          	auipc	ra,0x0
    80000f50:	0d8080e7          	jalr	216(ra) # 80001024 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	8e2080e7          	jalr	-1822(ra) # 80002836 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	028080e7          	jalr	40(ra) # 80005f84 <plicinithart>
  }

  scheduler();        
    80000f64:	00001097          	auipc	ra,0x1
    80000f68:	0c8080e7          	jalr	200(ra) # 8000202c <scheduler>
    consoleinit();
    80000f6c:	fffff097          	auipc	ra,0xfffff
    80000f70:	508080e7          	jalr	1288(ra) # 80000474 <consoleinit>
    printfinit();
    80000f74:	00000097          	auipc	ra,0x0
    80000f78:	83e080e7          	jalr	-1986(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f7c:	00007517          	auipc	a0,0x7
    80000f80:	09450513          	addi	a0,a0,148 # 80008010 <etext+0x10>
    80000f84:	fffff097          	auipc	ra,0xfffff
    80000f88:	624080e7          	jalr	1572(ra) # 800005a8 <printf>
    printf("xv6 kernel is booting\n");
    80000f8c:	00007517          	auipc	a0,0x7
    80000f90:	0f450513          	addi	a0,a0,244 # 80008080 <etext+0x80>
    80000f94:	fffff097          	auipc	ra,0xfffff
    80000f98:	614080e7          	jalr	1556(ra) # 800005a8 <printf>
    printf("\n");
    80000f9c:	00007517          	auipc	a0,0x7
    80000fa0:	07450513          	addi	a0,a0,116 # 80008010 <etext+0x10>
    80000fa4:	fffff097          	auipc	ra,0xfffff
    80000fa8:	604080e7          	jalr	1540(ra) # 800005a8 <printf>
    kinit();         // physical page allocator
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	b70080e7          	jalr	-1168(ra) # 80000b1c <kinit>
    kvminit();       // create kernel page table
    80000fb4:	00000097          	auipc	ra,0x0
    80000fb8:	324080e7          	jalr	804(ra) # 800012d8 <kvminit>
    kvminithart();   // turn on paging
    80000fbc:	00000097          	auipc	ra,0x0
    80000fc0:	068080e7          	jalr	104(ra) # 80001024 <kvminithart>
    procinit();      // process table
    80000fc4:	00001097          	auipc	ra,0x1
    80000fc8:	a4c080e7          	jalr	-1460(ra) # 80001a10 <procinit>
    trapinit();      // trap vectors
    80000fcc:	00002097          	auipc	ra,0x2
    80000fd0:	842080e7          	jalr	-1982(ra) # 8000280e <trapinit>
    trapinithart();  // install kernel trap vector
    80000fd4:	00002097          	auipc	ra,0x2
    80000fd8:	862080e7          	jalr	-1950(ra) # 80002836 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	f8e080e7          	jalr	-114(ra) # 80005f6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fe4:	00005097          	auipc	ra,0x5
    80000fe8:	fa0080e7          	jalr	-96(ra) # 80005f84 <plicinithart>
    binit();         // buffer cache
    80000fec:	00002097          	auipc	ra,0x2
    80000ff0:	016080e7          	jalr	22(ra) # 80003002 <binit>
    iinit();         // inode table
    80000ff4:	00002097          	auipc	ra,0x2
    80000ff8:	696080e7          	jalr	1686(ra) # 8000368a <iinit>
    fileinit();      // file table
    80000ffc:	00003097          	auipc	ra,0x3
    80001000:	680080e7          	jalr	1664(ra) # 8000467c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001004:	00005097          	auipc	ra,0x5
    80001008:	088080e7          	jalr	136(ra) # 8000608c <virtio_disk_init>
    userinit();      // first user process
    8000100c:	00001097          	auipc	ra,0x1
    80001010:	e00080e7          	jalr	-512(ra) # 80001e0c <userinit>
    __sync_synchronize();
    80001014:	0330000f          	fence	rw,rw
    started = 1;
    80001018:	4785                	li	a5,1
    8000101a:	00008717          	auipc	a4,0x8
    8000101e:	88f72723          	sw	a5,-1906(a4) # 800088a8 <started>
    80001022:	b789                	j	80000f64 <main+0x56>

0000000080001024 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001024:	1141                	addi	sp,sp,-16
    80001026:	e406                	sd	ra,8(sp)
    80001028:	e022                	sd	s0,0(sp)
    8000102a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000102c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001030:	00008797          	auipc	a5,0x8
    80001034:	8807b783          	ld	a5,-1920(a5) # 800088b0 <kernel_pagetable>
    80001038:	83b1                	srli	a5,a5,0xc
    8000103a:	577d                	li	a4,-1
    8000103c:	177e                	slli	a4,a4,0x3f
    8000103e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001040:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001044:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001048:	60a2                	ld	ra,8(sp)
    8000104a:	6402                	ld	s0,0(sp)
    8000104c:	0141                	addi	sp,sp,16
    8000104e:	8082                	ret

0000000080001050 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001050:	7139                	addi	sp,sp,-64
    80001052:	fc06                	sd	ra,56(sp)
    80001054:	f822                	sd	s0,48(sp)
    80001056:	f426                	sd	s1,40(sp)
    80001058:	f04a                	sd	s2,32(sp)
    8000105a:	ec4e                	sd	s3,24(sp)
    8000105c:	e852                	sd	s4,16(sp)
    8000105e:	e456                	sd	s5,8(sp)
    80001060:	e05a                	sd	s6,0(sp)
    80001062:	0080                	addi	s0,sp,64
    80001064:	84aa                	mv	s1,a0
    80001066:	89ae                	mv	s3,a1
    80001068:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    8000106a:	57fd                	li	a5,-1
    8000106c:	83e9                	srli	a5,a5,0x1a
    8000106e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001070:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001072:	04b7e263          	bltu	a5,a1,800010b6 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	andi	s2,s2,511
    8000107e:	090e                	slli	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	andi	a5,s1,1
    8000108a:	cf95                	beqz	a5,800010c6 <walk+0x76>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srli	s1,s1,0xa
    8000108e:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001090:	3a5d                	addiw	s4,s4,-9
    80001092:	ff5a12e3          	bne	s4,s5,80001076 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001096:	00c9d513          	srli	a0,s3,0xc
    8000109a:	1ff57513          	andi	a0,a0,511
    8000109e:	050e                	slli	a0,a0,0x3
    800010a0:	9526                	add	a0,a0,s1
}
    800010a2:	70e2                	ld	ra,56(sp)
    800010a4:	7442                	ld	s0,48(sp)
    800010a6:	74a2                	ld	s1,40(sp)
    800010a8:	7902                	ld	s2,32(sp)
    800010aa:	69e2                	ld	s3,24(sp)
    800010ac:	6a42                	ld	s4,16(sp)
    800010ae:	6aa2                	ld	s5,8(sp)
    800010b0:	6b02                	ld	s6,0(sp)
    800010b2:	6121                	addi	sp,sp,64
    800010b4:	8082                	ret
    panic("walk");
    800010b6:	00007517          	auipc	a0,0x7
    800010ba:	ffa50513          	addi	a0,a0,-6 # 800080b0 <etext+0xb0>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	4a0080e7          	jalr	1184(ra) # 8000055e <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010c6:	020b0663          	beqz	s6,800010f2 <walk+0xa2>
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	a8e080e7          	jalr	-1394(ra) # 80000b58 <kalloc>
    800010d2:	84aa                	mv	s1,a0
    800010d4:	d579                	beqz	a0,800010a2 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    800010d6:	6605                	lui	a2,0x1
    800010d8:	4581                	li	a1,0
    800010da:	00000097          	auipc	ra,0x0
    800010de:	c7a080e7          	jalr	-902(ra) # 80000d54 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010e2:	00c4d793          	srli	a5,s1,0xc
    800010e6:	07aa                	slli	a5,a5,0xa
    800010e8:	0017e793          	ori	a5,a5,1
    800010ec:	00f93023          	sd	a5,0(s2)
    800010f0:	b745                	j	80001090 <walk+0x40>
        return 0;
    800010f2:	4501                	li	a0,0
    800010f4:	b77d                	j	800010a2 <walk+0x52>

00000000800010f6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010f6:	57fd                	li	a5,-1
    800010f8:	83e9                	srli	a5,a5,0x1a
    800010fa:	00b7f463          	bgeu	a5,a1,80001102 <walkaddr+0xc>
    return 0;
    800010fe:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001100:	8082                	ret
{
    80001102:	1141                	addi	sp,sp,-16
    80001104:	e406                	sd	ra,8(sp)
    80001106:	e022                	sd	s0,0(sp)
    80001108:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000110a:	4601                	li	a2,0
    8000110c:	00000097          	auipc	ra,0x0
    80001110:	f44080e7          	jalr	-188(ra) # 80001050 <walk>
  if(pte == 0)
    80001114:	c901                	beqz	a0,80001124 <walkaddr+0x2e>
  if((*pte & PTE_V) == 0)
    80001116:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001118:	0117f693          	andi	a3,a5,17
    8000111c:	4745                	li	a4,17
    return 0;
    8000111e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001120:	00e68663          	beq	a3,a4,8000112c <walkaddr+0x36>
}
    80001124:	60a2                	ld	ra,8(sp)
    80001126:	6402                	ld	s0,0(sp)
    80001128:	0141                	addi	sp,sp,16
    8000112a:	8082                	ret
  pa = PTE2PA(*pte);
    8000112c:	83a9                	srli	a5,a5,0xa
    8000112e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001132:	bfcd                	j	80001124 <walkaddr+0x2e>

0000000080001134 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001134:	715d                	addi	sp,sp,-80
    80001136:	e486                	sd	ra,72(sp)
    80001138:	e0a2                	sd	s0,64(sp)
    8000113a:	fc26                	sd	s1,56(sp)
    8000113c:	f84a                	sd	s2,48(sp)
    8000113e:	f44e                	sd	s3,40(sp)
    80001140:	f052                	sd	s4,32(sp)
    80001142:	ec56                	sd	s5,24(sp)
    80001144:	e85a                	sd	s6,16(sp)
    80001146:	e45e                	sd	s7,8(sp)
    80001148:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000114a:	ca21                	beqz	a2,8000119a <mappages+0x66>
    8000114c:	8a2a                	mv	s4,a0
    8000114e:	8aba                	mv	s5,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001150:	777d                	lui	a4,0xfffff
    80001152:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001156:	fff58913          	addi	s2,a1,-1
    8000115a:	9932                	add	s2,s2,a2
    8000115c:	00e97933          	and	s2,s2,a4
  a = PGROUNDDOWN(va);
    80001160:	84be                	mv	s1,a5
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001162:	4b05                	li	s6,1
    80001164:	40f689b3          	sub	s3,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001168:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000116a:	865a                	mv	a2,s6
    8000116c:	85a6                	mv	a1,s1
    8000116e:	8552                	mv	a0,s4
    80001170:	00000097          	auipc	ra,0x0
    80001174:	ee0080e7          	jalr	-288(ra) # 80001050 <walk>
    80001178:	c129                	beqz	a0,800011ba <mappages+0x86>
    if(*pte & PTE_V)
    8000117a:	611c                	ld	a5,0(a0)
    8000117c:	8b85                	andi	a5,a5,1
    8000117e:	e795                	bnez	a5,800011aa <mappages+0x76>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001180:	013487b3          	add	a5,s1,s3
    80001184:	83b1                	srli	a5,a5,0xc
    80001186:	07aa                	slli	a5,a5,0xa
    80001188:	0157e7b3          	or	a5,a5,s5
    8000118c:	0017e793          	ori	a5,a5,1
    80001190:	e11c                	sd	a5,0(a0)
    if(a == last)
    80001192:	05248063          	beq	s1,s2,800011d2 <mappages+0x9e>
    a += PGSIZE;
    80001196:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001198:	bfc9                	j	8000116a <mappages+0x36>
    panic("mappages: size");
    8000119a:	00007517          	auipc	a0,0x7
    8000119e:	f1e50513          	addi	a0,a0,-226 # 800080b8 <etext+0xb8>
    800011a2:	fffff097          	auipc	ra,0xfffff
    800011a6:	3bc080e7          	jalr	956(ra) # 8000055e <panic>
      panic("mappages: remap");
    800011aa:	00007517          	auipc	a0,0x7
    800011ae:	f1e50513          	addi	a0,a0,-226 # 800080c8 <etext+0xc8>
    800011b2:	fffff097          	auipc	ra,0xfffff
    800011b6:	3ac080e7          	jalr	940(ra) # 8000055e <panic>
      return -1;
    800011ba:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011bc:	60a6                	ld	ra,72(sp)
    800011be:	6406                	ld	s0,64(sp)
    800011c0:	74e2                	ld	s1,56(sp)
    800011c2:	7942                	ld	s2,48(sp)
    800011c4:	79a2                	ld	s3,40(sp)
    800011c6:	7a02                	ld	s4,32(sp)
    800011c8:	6ae2                	ld	s5,24(sp)
    800011ca:	6b42                	ld	s6,16(sp)
    800011cc:	6ba2                	ld	s7,8(sp)
    800011ce:	6161                	addi	sp,sp,80
    800011d0:	8082                	ret
  return 0;
    800011d2:	4501                	li	a0,0
    800011d4:	b7e5                	j	800011bc <mappages+0x88>

00000000800011d6 <kvmmap>:
{
    800011d6:	1141                	addi	sp,sp,-16
    800011d8:	e406                	sd	ra,8(sp)
    800011da:	e022                	sd	s0,0(sp)
    800011dc:	0800                	addi	s0,sp,16
    800011de:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011e0:	86b2                	mv	a3,a2
    800011e2:	863e                	mv	a2,a5
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f50080e7          	jalr	-176(ra) # 80001134 <mappages>
    800011ec:	e509                	bnez	a0,800011f6 <kvmmap+0x20>
}
    800011ee:	60a2                	ld	ra,8(sp)
    800011f0:	6402                	ld	s0,0(sp)
    800011f2:	0141                	addi	sp,sp,16
    800011f4:	8082                	ret
    panic("kvmmap");
    800011f6:	00007517          	auipc	a0,0x7
    800011fa:	ee250513          	addi	a0,a0,-286 # 800080d8 <etext+0xd8>
    800011fe:	fffff097          	auipc	ra,0xfffff
    80001202:	360080e7          	jalr	864(ra) # 8000055e <panic>

0000000080001206 <kvmmake>:
{
    80001206:	1101                	addi	sp,sp,-32
    80001208:	ec06                	sd	ra,24(sp)
    8000120a:	e822                	sd	s0,16(sp)
    8000120c:	e426                	sd	s1,8(sp)
    8000120e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001210:	00000097          	auipc	ra,0x0
    80001214:	948080e7          	jalr	-1720(ra) # 80000b58 <kalloc>
    80001218:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	b36080e7          	jalr	-1226(ra) # 80000d54 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001226:	4719                	li	a4,6
    80001228:	6685                	lui	a3,0x1
    8000122a:	10000637          	lui	a2,0x10000
    8000122e:	85b2                	mv	a1,a2
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	fa4080e7          	jalr	-92(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000123a:	4719                	li	a4,6
    8000123c:	6685                	lui	a3,0x1
    8000123e:	10001637          	lui	a2,0x10001
    80001242:	85b2                	mv	a1,a2
    80001244:	8526                	mv	a0,s1
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f90080e7          	jalr	-112(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000124e:	4719                	li	a4,6
    80001250:	004006b7          	lui	a3,0x400
    80001254:	0c000637          	lui	a2,0xc000
    80001258:	85b2                	mv	a1,a2
    8000125a:	8526                	mv	a0,s1
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	f7a080e7          	jalr	-134(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001264:	4729                	li	a4,10
    80001266:	80007697          	auipc	a3,0x80007
    8000126a:	d9a68693          	addi	a3,a3,-614 # 8000 <_entry-0x7fff8000>
    8000126e:	4605                	li	a2,1
    80001270:	067e                	slli	a2,a2,0x1f
    80001272:	85b2                	mv	a1,a2
    80001274:	8526                	mv	a0,s1
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	f60080e7          	jalr	-160(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000127e:	4719                	li	a4,6
    80001280:	00007697          	auipc	a3,0x7
    80001284:	d8068693          	addi	a3,a3,-640 # 80008000 <etext>
    80001288:	47c5                	li	a5,17
    8000128a:	07ee                	slli	a5,a5,0x1b
    8000128c:	40d786b3          	sub	a3,a5,a3
    80001290:	00007617          	auipc	a2,0x7
    80001294:	d7060613          	addi	a2,a2,-656 # 80008000 <etext>
    80001298:	85b2                	mv	a1,a2
    8000129a:	8526                	mv	a0,s1
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f3a080e7          	jalr	-198(ra) # 800011d6 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012a4:	4729                	li	a4,10
    800012a6:	6685                	lui	a3,0x1
    800012a8:	00006617          	auipc	a2,0x6
    800012ac:	d5860613          	addi	a2,a2,-680 # 80007000 <_trampoline>
    800012b0:	040005b7          	lui	a1,0x4000
    800012b4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012b6:	05b2                	slli	a1,a1,0xc
    800012b8:	8526                	mv	a0,s1
    800012ba:	00000097          	auipc	ra,0x0
    800012be:	f1c080e7          	jalr	-228(ra) # 800011d6 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012c2:	8526                	mv	a0,s1
    800012c4:	00000097          	auipc	ra,0x0
    800012c8:	6a2080e7          	jalr	1698(ra) # 80001966 <proc_mapstacks>
}
    800012cc:	8526                	mv	a0,s1
    800012ce:	60e2                	ld	ra,24(sp)
    800012d0:	6442                	ld	s0,16(sp)
    800012d2:	64a2                	ld	s1,8(sp)
    800012d4:	6105                	addi	sp,sp,32
    800012d6:	8082                	ret

00000000800012d8 <kvminit>:
{
    800012d8:	1141                	addi	sp,sp,-16
    800012da:	e406                	sd	ra,8(sp)
    800012dc:	e022                	sd	s0,0(sp)
    800012de:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	f26080e7          	jalr	-218(ra) # 80001206 <kvmmake>
    800012e8:	00007797          	auipc	a5,0x7
    800012ec:	5ca7b423          	sd	a0,1480(a5) # 800088b0 <kernel_pagetable>
}
    800012f0:	60a2                	ld	ra,8(sp)
    800012f2:	6402                	ld	s0,0(sp)
    800012f4:	0141                	addi	sp,sp,16
    800012f6:	8082                	ret

00000000800012f8 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012f8:	715d                	addi	sp,sp,-80
    800012fa:	e486                	sd	ra,72(sp)
    800012fc:	e0a2                	sd	s0,64(sp)
    800012fe:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001300:	03459793          	slli	a5,a1,0x34
    80001304:	e39d                	bnez	a5,8000132a <uvmunmap+0x32>
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f44e                	sd	s3,40(sp)
    8000130a:	f052                	sd	s4,32(sp)
    8000130c:	ec56                	sd	s5,24(sp)
    8000130e:	e85a                	sd	s6,16(sp)
    80001310:	e45e                	sd	s7,8(sp)
    80001312:	8a2a                	mv	s4,a0
    80001314:	892e                	mv	s2,a1
    80001316:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001318:	0632                	slli	a2,a2,0xc
    8000131a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000131e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001320:	6b05                	lui	s6,0x1
    80001322:	0935fb63          	bgeu	a1,s3,800013b8 <uvmunmap+0xc0>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	a8a9                	j	80001382 <uvmunmap+0x8a>
    8000132a:	fc26                	sd	s1,56(sp)
    8000132c:	f84a                	sd	s2,48(sp)
    8000132e:	f44e                	sd	s3,40(sp)
    80001330:	f052                	sd	s4,32(sp)
    80001332:	ec56                	sd	s5,24(sp)
    80001334:	e85a                	sd	s6,16(sp)
    80001336:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	da850513          	addi	a0,a0,-600 # 800080e0 <etext+0xe0>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	21e080e7          	jalr	542(ra) # 8000055e <panic>
      panic("uvmunmap: walk");
    80001348:	00007517          	auipc	a0,0x7
    8000134c:	db050513          	addi	a0,a0,-592 # 800080f8 <etext+0xf8>
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	20e080e7          	jalr	526(ra) # 8000055e <panic>
      panic("uvmunmap: not mapped");
    80001358:	00007517          	auipc	a0,0x7
    8000135c:	db050513          	addi	a0,a0,-592 # 80008108 <etext+0x108>
    80001360:	fffff097          	auipc	ra,0xfffff
    80001364:	1fe080e7          	jalr	510(ra) # 8000055e <panic>
      panic("uvmunmap: not a leaf");
    80001368:	00007517          	auipc	a0,0x7
    8000136c:	db850513          	addi	a0,a0,-584 # 80008120 <etext+0x120>
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	1ee080e7          	jalr	494(ra) # 8000055e <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001378:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000137c:	995a                	add	s2,s2,s6
    8000137e:	03397c63          	bgeu	s2,s3,800013b6 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001382:	4601                	li	a2,0
    80001384:	85ca                	mv	a1,s2
    80001386:	8552                	mv	a0,s4
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	cc8080e7          	jalr	-824(ra) # 80001050 <walk>
    80001390:	84aa                	mv	s1,a0
    80001392:	d95d                	beqz	a0,80001348 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001394:	6108                	ld	a0,0(a0)
    80001396:	00157793          	andi	a5,a0,1
    8000139a:	dfdd                	beqz	a5,80001358 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000139c:	3ff57793          	andi	a5,a0,1023
    800013a0:	fd7784e3          	beq	a5,s7,80001368 <uvmunmap+0x70>
    if(do_free){
    800013a4:	fc0a8ae3          	beqz	s5,80001378 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    800013a8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013aa:	0532                	slli	a0,a0,0xc
    800013ac:	fffff097          	auipc	ra,0xfffff
    800013b0:	6a8080e7          	jalr	1704(ra) # 80000a54 <kfree>
    800013b4:	b7d1                	j	80001378 <uvmunmap+0x80>
    800013b6:	74e2                	ld	s1,56(sp)
    800013b8:	7942                	ld	s2,48(sp)
    800013ba:	79a2                	ld	s3,40(sp)
    800013bc:	7a02                	ld	s4,32(sp)
    800013be:	6ae2                	ld	s5,24(sp)
    800013c0:	6b42                	ld	s6,16(sp)
    800013c2:	6ba2                	ld	s7,8(sp)
  }
}
    800013c4:	60a6                	ld	ra,72(sp)
    800013c6:	6406                	ld	s0,64(sp)
    800013c8:	6161                	addi	sp,sp,80
    800013ca:	8082                	ret

00000000800013cc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013cc:	1101                	addi	sp,sp,-32
    800013ce:	ec06                	sd	ra,24(sp)
    800013d0:	e822                	sd	s0,16(sp)
    800013d2:	e426                	sd	s1,8(sp)
    800013d4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013d6:	fffff097          	auipc	ra,0xfffff
    800013da:	782080e7          	jalr	1922(ra) # 80000b58 <kalloc>
    800013de:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013e0:	c519                	beqz	a0,800013ee <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013e2:	6605                	lui	a2,0x1
    800013e4:	4581                	li	a1,0
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	96e080e7          	jalr	-1682(ra) # 80000d54 <memset>
  return pagetable;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret

00000000800013fa <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013fa:	7179                	addi	sp,sp,-48
    800013fc:	f406                	sd	ra,40(sp)
    800013fe:	f022                	sd	s0,32(sp)
    80001400:	ec26                	sd	s1,24(sp)
    80001402:	e84a                	sd	s2,16(sp)
    80001404:	e44e                	sd	s3,8(sp)
    80001406:	e052                	sd	s4,0(sp)
    80001408:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000140a:	6785                	lui	a5,0x1
    8000140c:	04f67863          	bgeu	a2,a5,8000145c <uvmfirst+0x62>
    80001410:	89aa                	mv	s3,a0
    80001412:	8a2e                	mv	s4,a1
    80001414:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001416:	fffff097          	auipc	ra,0xfffff
    8000141a:	742080e7          	jalr	1858(ra) # 80000b58 <kalloc>
    8000141e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001420:	6605                	lui	a2,0x1
    80001422:	4581                	li	a1,0
    80001424:	00000097          	auipc	ra,0x0
    80001428:	930080e7          	jalr	-1744(ra) # 80000d54 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000142c:	4779                	li	a4,30
    8000142e:	86ca                	mv	a3,s2
    80001430:	6605                	lui	a2,0x1
    80001432:	4581                	li	a1,0
    80001434:	854e                	mv	a0,s3
    80001436:	00000097          	auipc	ra,0x0
    8000143a:	cfe080e7          	jalr	-770(ra) # 80001134 <mappages>
  memmove(mem, src, sz);
    8000143e:	8626                	mv	a2,s1
    80001440:	85d2                	mv	a1,s4
    80001442:	854a                	mv	a0,s2
    80001444:	00000097          	auipc	ra,0x0
    80001448:	970080e7          	jalr	-1680(ra) # 80000db4 <memmove>
}
    8000144c:	70a2                	ld	ra,40(sp)
    8000144e:	7402                	ld	s0,32(sp)
    80001450:	64e2                	ld	s1,24(sp)
    80001452:	6942                	ld	s2,16(sp)
    80001454:	69a2                	ld	s3,8(sp)
    80001456:	6a02                	ld	s4,0(sp)
    80001458:	6145                	addi	sp,sp,48
    8000145a:	8082                	ret
    panic("uvmfirst: more than a page");
    8000145c:	00007517          	auipc	a0,0x7
    80001460:	cdc50513          	addi	a0,a0,-804 # 80008138 <etext+0x138>
    80001464:	fffff097          	auipc	ra,0xfffff
    80001468:	0fa080e7          	jalr	250(ra) # 8000055e <panic>

000000008000146c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000146c:	1101                	addi	sp,sp,-32
    8000146e:	ec06                	sd	ra,24(sp)
    80001470:	e822                	sd	s0,16(sp)
    80001472:	e426                	sd	s1,8(sp)
    80001474:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001476:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001478:	00b67d63          	bgeu	a2,a1,80001492 <uvmdealloc+0x26>
    8000147c:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000147e:	6785                	lui	a5,0x1
    80001480:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001482:	00f60733          	add	a4,a2,a5
    80001486:	76fd                	lui	a3,0xfffff
    80001488:	8f75                	and	a4,a4,a3
    8000148a:	97ae                	add	a5,a5,a1
    8000148c:	8ff5                	and	a5,a5,a3
    8000148e:	00f76863          	bltu	a4,a5,8000149e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001492:	8526                	mv	a0,s1
    80001494:	60e2                	ld	ra,24(sp)
    80001496:	6442                	ld	s0,16(sp)
    80001498:	64a2                	ld	s1,8(sp)
    8000149a:	6105                	addi	sp,sp,32
    8000149c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000149e:	8f99                	sub	a5,a5,a4
    800014a0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014a2:	4685                	li	a3,1
    800014a4:	0007861b          	sext.w	a2,a5
    800014a8:	85ba                	mv	a1,a4
    800014aa:	00000097          	auipc	ra,0x0
    800014ae:	e4e080e7          	jalr	-434(ra) # 800012f8 <uvmunmap>
    800014b2:	b7c5                	j	80001492 <uvmdealloc+0x26>

00000000800014b4 <uvmalloc>:
  if(newsz < oldsz)
    800014b4:	0ab66d63          	bltu	a2,a1,8000156e <uvmalloc+0xba>
{
    800014b8:	715d                	addi	sp,sp,-80
    800014ba:	e486                	sd	ra,72(sp)
    800014bc:	e0a2                	sd	s0,64(sp)
    800014be:	f84a                	sd	s2,48(sp)
    800014c0:	f052                	sd	s4,32(sp)
    800014c2:	ec56                	sd	s5,24(sp)
    800014c4:	e45e                	sd	s7,8(sp)
    800014c6:	0880                	addi	s0,sp,80
    800014c8:	8aaa                	mv	s5,a0
    800014ca:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014cc:	6785                	lui	a5,0x1
    800014ce:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014d0:	95be                	add	a1,a1,a5
    800014d2:	77fd                	lui	a5,0xfffff
    800014d4:	00f5f933          	and	s2,a1,a5
    800014d8:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014da:	08c97c63          	bgeu	s2,a2,80001572 <uvmalloc+0xbe>
    800014de:	fc26                	sd	s1,56(sp)
    800014e0:	f44e                	sd	s3,40(sp)
    800014e2:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    800014e4:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014e6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	66e080e7          	jalr	1646(ra) # 80000b58 <kalloc>
    800014f2:	84aa                	mv	s1,a0
    if(mem == 0){
    800014f4:	c90d                	beqz	a0,80001526 <uvmalloc+0x72>
    memset(mem, 0, PGSIZE);
    800014f6:	864e                	mv	a2,s3
    800014f8:	4581                	li	a1,0
    800014fa:	00000097          	auipc	ra,0x0
    800014fe:	85a080e7          	jalr	-1958(ra) # 80000d54 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001502:	875a                	mv	a4,s6
    80001504:	86a6                	mv	a3,s1
    80001506:	864e                	mv	a2,s3
    80001508:	85ca                	mv	a1,s2
    8000150a:	8556                	mv	a0,s5
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	c28080e7          	jalr	-984(ra) # 80001134 <mappages>
    80001514:	ed05                	bnez	a0,8000154c <uvmalloc+0x98>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001516:	994e                	add	s2,s2,s3
    80001518:	fd4969e3          	bltu	s2,s4,800014ea <uvmalloc+0x36>
  return newsz;
    8000151c:	8552                	mv	a0,s4
    8000151e:	74e2                	ld	s1,56(sp)
    80001520:	79a2                	ld	s3,40(sp)
    80001522:	6b42                	ld	s6,16(sp)
    80001524:	a821                	j	8000153c <uvmalloc+0x88>
      uvmdealloc(pagetable, a, oldsz);
    80001526:	865e                	mv	a2,s7
    80001528:	85ca                	mv	a1,s2
    8000152a:	8556                	mv	a0,s5
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	f40080e7          	jalr	-192(ra) # 8000146c <uvmdealloc>
      return 0;
    80001534:	4501                	li	a0,0
    80001536:	74e2                	ld	s1,56(sp)
    80001538:	79a2                	ld	s3,40(sp)
    8000153a:	6b42                	ld	s6,16(sp)
}
    8000153c:	60a6                	ld	ra,72(sp)
    8000153e:	6406                	ld	s0,64(sp)
    80001540:	7942                	ld	s2,48(sp)
    80001542:	7a02                	ld	s4,32(sp)
    80001544:	6ae2                	ld	s5,24(sp)
    80001546:	6ba2                	ld	s7,8(sp)
    80001548:	6161                	addi	sp,sp,80
    8000154a:	8082                	ret
      kfree(mem);
    8000154c:	8526                	mv	a0,s1
    8000154e:	fffff097          	auipc	ra,0xfffff
    80001552:	506080e7          	jalr	1286(ra) # 80000a54 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001556:	865e                	mv	a2,s7
    80001558:	85ca                	mv	a1,s2
    8000155a:	8556                	mv	a0,s5
    8000155c:	00000097          	auipc	ra,0x0
    80001560:	f10080e7          	jalr	-240(ra) # 8000146c <uvmdealloc>
      return 0;
    80001564:	4501                	li	a0,0
    80001566:	74e2                	ld	s1,56(sp)
    80001568:	79a2                	ld	s3,40(sp)
    8000156a:	6b42                	ld	s6,16(sp)
    8000156c:	bfc1                	j	8000153c <uvmalloc+0x88>
    return oldsz;
    8000156e:	852e                	mv	a0,a1
}
    80001570:	8082                	ret
  return newsz;
    80001572:	8532                	mv	a0,a2
    80001574:	b7e1                	j	8000153c <uvmalloc+0x88>

0000000080001576 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001576:	7179                	addi	sp,sp,-48
    80001578:	f406                	sd	ra,40(sp)
    8000157a:	f022                	sd	s0,32(sp)
    8000157c:	ec26                	sd	s1,24(sp)
    8000157e:	e84a                	sd	s2,16(sp)
    80001580:	e44e                	sd	s3,8(sp)
    80001582:	1800                	addi	s0,sp,48
    80001584:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001586:	84aa                	mv	s1,a0
    80001588:	6905                	lui	s2,0x1
    8000158a:	992a                	add	s2,s2,a0
    8000158c:	a821                	j	800015a4 <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    8000158e:	00007517          	auipc	a0,0x7
    80001592:	bca50513          	addi	a0,a0,-1078 # 80008158 <etext+0x158>
    80001596:	fffff097          	auipc	ra,0xfffff
    8000159a:	fc8080e7          	jalr	-56(ra) # 8000055e <panic>
  for(int i = 0; i < 512; i++){
    8000159e:	04a1                	addi	s1,s1,8
    800015a0:	03248363          	beq	s1,s2,800015c6 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015a4:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a6:	0017f713          	andi	a4,a5,1
    800015aa:	db75                	beqz	a4,8000159e <freewalk+0x28>
    800015ac:	00e7f713          	andi	a4,a5,14
    800015b0:	ff79                	bnez	a4,8000158e <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800015b2:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015b4:	00c79513          	slli	a0,a5,0xc
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	fbe080e7          	jalr	-66(ra) # 80001576 <freewalk>
      pagetable[i] = 0;
    800015c0:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015c4:	bfe9                	j	8000159e <freewalk+0x28>
    }
  }
  kfree((void*)pagetable);
    800015c6:	854e                	mv	a0,s3
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	48c080e7          	jalr	1164(ra) # 80000a54 <kfree>
}
    800015d0:	70a2                	ld	ra,40(sp)
    800015d2:	7402                	ld	s0,32(sp)
    800015d4:	64e2                	ld	s1,24(sp)
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	69a2                	ld	s3,8(sp)
    800015da:	6145                	addi	sp,sp,48
    800015dc:	8082                	ret

00000000800015de <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015de:	1101                	addi	sp,sp,-32
    800015e0:	ec06                	sd	ra,24(sp)
    800015e2:	e822                	sd	s0,16(sp)
    800015e4:	e426                	sd	s1,8(sp)
    800015e6:	1000                	addi	s0,sp,32
    800015e8:	84aa                	mv	s1,a0
  if(sz > 0)
    800015ea:	e999                	bnez	a1,80001600 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015ec:	8526                	mv	a0,s1
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	f88080e7          	jalr	-120(ra) # 80001576 <freewalk>
}
    800015f6:	60e2                	ld	ra,24(sp)
    800015f8:	6442                	ld	s0,16(sp)
    800015fa:	64a2                	ld	s1,8(sp)
    800015fc:	6105                	addi	sp,sp,32
    800015fe:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001600:	6785                	lui	a5,0x1
    80001602:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001604:	95be                	add	a1,a1,a5
    80001606:	4685                	li	a3,1
    80001608:	00c5d613          	srli	a2,a1,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	cea080e7          	jalr	-790(ra) # 800012f8 <uvmunmap>
    80001616:	bfd9                	j	800015ec <uvmfree+0xe>

0000000080001618 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001618:	c669                	beqz	a2,800016e2 <uvmcopy+0xca>
{
    8000161a:	715d                	addi	sp,sp,-80
    8000161c:	e486                	sd	ra,72(sp)
    8000161e:	e0a2                	sd	s0,64(sp)
    80001620:	fc26                	sd	s1,56(sp)
    80001622:	f84a                	sd	s2,48(sp)
    80001624:	f44e                	sd	s3,40(sp)
    80001626:	f052                	sd	s4,32(sp)
    80001628:	ec56                	sd	s5,24(sp)
    8000162a:	e85a                	sd	s6,16(sp)
    8000162c:	e45e                	sd	s7,8(sp)
    8000162e:	0880                	addi	s0,sp,80
    80001630:	8b2a                	mv	s6,a0
    80001632:	8aae                	mv	s5,a1
    80001634:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001636:	4901                	li	s2,0
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001638:	6985                	lui	s3,0x1
    if((pte = walk(old, i, 0)) == 0)
    8000163a:	4601                	li	a2,0
    8000163c:	85ca                	mv	a1,s2
    8000163e:	855a                	mv	a0,s6
    80001640:	00000097          	auipc	ra,0x0
    80001644:	a10080e7          	jalr	-1520(ra) # 80001050 <walk>
    80001648:	c139                	beqz	a0,8000168e <uvmcopy+0x76>
    if((*pte & PTE_V) == 0)
    8000164a:	00053b83          	ld	s7,0(a0)
    8000164e:	001bf793          	andi	a5,s7,1
    80001652:	c7b1                	beqz	a5,8000169e <uvmcopy+0x86>
    if((mem = kalloc()) == 0)
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	504080e7          	jalr	1284(ra) # 80000b58 <kalloc>
    8000165c:	84aa                	mv	s1,a0
    8000165e:	cd29                	beqz	a0,800016b8 <uvmcopy+0xa0>
    pa = PTE2PA(*pte);
    80001660:	00abd593          	srli	a1,s7,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001664:	864e                	mv	a2,s3
    80001666:	05b2                	slli	a1,a1,0xc
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	74c080e7          	jalr	1868(ra) # 80000db4 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001670:	3ffbf713          	andi	a4,s7,1023
    80001674:	86a6                	mv	a3,s1
    80001676:	864e                	mv	a2,s3
    80001678:	85ca                	mv	a1,s2
    8000167a:	8556                	mv	a0,s5
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	ab8080e7          	jalr	-1352(ra) # 80001134 <mappages>
    80001684:	e50d                	bnez	a0,800016ae <uvmcopy+0x96>
  for(i = 0; i < sz; i += PGSIZE){
    80001686:	994e                	add	s2,s2,s3
    80001688:	fb4969e3          	bltu	s2,s4,8000163a <uvmcopy+0x22>
    8000168c:	a081                	j	800016cc <uvmcopy+0xb4>
      panic("uvmcopy: pte should exist");
    8000168e:	00007517          	auipc	a0,0x7
    80001692:	ada50513          	addi	a0,a0,-1318 # 80008168 <etext+0x168>
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	ec8080e7          	jalr	-312(ra) # 8000055e <panic>
      panic("uvmcopy: page not present");
    8000169e:	00007517          	auipc	a0,0x7
    800016a2:	aea50513          	addi	a0,a0,-1302 # 80008188 <etext+0x188>
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	eb8080e7          	jalr	-328(ra) # 8000055e <panic>
      kfree(mem);
    800016ae:	8526                	mv	a0,s1
    800016b0:	fffff097          	auipc	ra,0xfffff
    800016b4:	3a4080e7          	jalr	932(ra) # 80000a54 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016b8:	4685                	li	a3,1
    800016ba:	00c95613          	srli	a2,s2,0xc
    800016be:	4581                	li	a1,0
    800016c0:	8556                	mv	a0,s5
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	c36080e7          	jalr	-970(ra) # 800012f8 <uvmunmap>
  return -1;
    800016ca:	557d                	li	a0,-1
}
    800016cc:	60a6                	ld	ra,72(sp)
    800016ce:	6406                	ld	s0,64(sp)
    800016d0:	74e2                	ld	s1,56(sp)
    800016d2:	7942                	ld	s2,48(sp)
    800016d4:	79a2                	ld	s3,40(sp)
    800016d6:	7a02                	ld	s4,32(sp)
    800016d8:	6ae2                	ld	s5,24(sp)
    800016da:	6b42                	ld	s6,16(sp)
    800016dc:	6ba2                	ld	s7,8(sp)
    800016de:	6161                	addi	sp,sp,80
    800016e0:	8082                	ret
  return 0;
    800016e2:	4501                	li	a0,0
}
    800016e4:	8082                	ret

00000000800016e6 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016e6:	1141                	addi	sp,sp,-16
    800016e8:	e406                	sd	ra,8(sp)
    800016ea:	e022                	sd	s0,0(sp)
    800016ec:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016ee:	4601                	li	a2,0
    800016f0:	00000097          	auipc	ra,0x0
    800016f4:	960080e7          	jalr	-1696(ra) # 80001050 <walk>
  if(pte == 0)
    800016f8:	c901                	beqz	a0,80001708 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016fa:	611c                	ld	a5,0(a0)
    800016fc:	9bbd                	andi	a5,a5,-17
    800016fe:	e11c                	sd	a5,0(a0)
}
    80001700:	60a2                	ld	ra,8(sp)
    80001702:	6402                	ld	s0,0(sp)
    80001704:	0141                	addi	sp,sp,16
    80001706:	8082                	ret
    panic("uvmclear");
    80001708:	00007517          	auipc	a0,0x7
    8000170c:	aa050513          	addi	a0,a0,-1376 # 800081a8 <etext+0x1a8>
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	e4e080e7          	jalr	-434(ra) # 8000055e <panic>

0000000080001718 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001718:	c6bd                	beqz	a3,80001786 <copyout+0x6e>
{
    8000171a:	715d                	addi	sp,sp,-80
    8000171c:	e486                	sd	ra,72(sp)
    8000171e:	e0a2                	sd	s0,64(sp)
    80001720:	fc26                	sd	s1,56(sp)
    80001722:	f84a                	sd	s2,48(sp)
    80001724:	f44e                	sd	s3,40(sp)
    80001726:	f052                	sd	s4,32(sp)
    80001728:	ec56                	sd	s5,24(sp)
    8000172a:	e85a                	sd	s6,16(sp)
    8000172c:	e45e                	sd	s7,8(sp)
    8000172e:	e062                	sd	s8,0(sp)
    80001730:	0880                	addi	s0,sp,80
    80001732:	8b2a                	mv	s6,a0
    80001734:	8c2e                	mv	s8,a1
    80001736:	8a32                	mv	s4,a2
    80001738:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000173a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000173c:	6a85                	lui	s5,0x1
    8000173e:	a015                	j	80001762 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001740:	9562                	add	a0,a0,s8
    80001742:	0004861b          	sext.w	a2,s1
    80001746:	85d2                	mv	a1,s4
    80001748:	41250533          	sub	a0,a0,s2
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	668080e7          	jalr	1640(ra) # 80000db4 <memmove>

    len -= n;
    80001754:	409989b3          	sub	s3,s3,s1
    src += n;
    80001758:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000175a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175e:	02098263          	beqz	s3,80001782 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001762:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001766:	85ca                	mv	a1,s2
    80001768:	855a                	mv	a0,s6
    8000176a:	00000097          	auipc	ra,0x0
    8000176e:	98c080e7          	jalr	-1652(ra) # 800010f6 <walkaddr>
    if(pa0 == 0)
    80001772:	cd01                	beqz	a0,8000178a <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001774:	418904b3          	sub	s1,s2,s8
    80001778:	94d6                	add	s1,s1,s5
    if(n > len)
    8000177a:	fc99f3e3          	bgeu	s3,s1,80001740 <copyout+0x28>
    8000177e:	84ce                	mv	s1,s3
    80001780:	b7c1                	j	80001740 <copyout+0x28>
  }
  return 0;
    80001782:	4501                	li	a0,0
    80001784:	a021                	j	8000178c <copyout+0x74>
    80001786:	4501                	li	a0,0
}
    80001788:	8082                	ret
      return -1;
    8000178a:	557d                	li	a0,-1
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6c02                	ld	s8,0(sp)
    800017a0:	6161                	addi	sp,sp,80
    800017a2:	8082                	ret

00000000800017a4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017a4:	caa5                	beqz	a3,80001814 <copyin+0x70>
{
    800017a6:	715d                	addi	sp,sp,-80
    800017a8:	e486                	sd	ra,72(sp)
    800017aa:	e0a2                	sd	s0,64(sp)
    800017ac:	fc26                	sd	s1,56(sp)
    800017ae:	f84a                	sd	s2,48(sp)
    800017b0:	f44e                	sd	s3,40(sp)
    800017b2:	f052                	sd	s4,32(sp)
    800017b4:	ec56                	sd	s5,24(sp)
    800017b6:	e85a                	sd	s6,16(sp)
    800017b8:	e45e                	sd	s7,8(sp)
    800017ba:	e062                	sd	s8,0(sp)
    800017bc:	0880                	addi	s0,sp,80
    800017be:	8b2a                	mv	s6,a0
    800017c0:	8a2e                	mv	s4,a1
    800017c2:	8c32                	mv	s8,a2
    800017c4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017c6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c8:	6a85                	lui	s5,0x1
    800017ca:	a01d                	j	800017f0 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017cc:	018505b3          	add	a1,a0,s8
    800017d0:	0004861b          	sext.w	a2,s1
    800017d4:	412585b3          	sub	a1,a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	fffff097          	auipc	ra,0xfffff
    800017de:	5da080e7          	jalr	1498(ra) # 80000db4 <memmove>

    len -= n;
    800017e2:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017e6:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017e8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017ec:	02098263          	beqz	s3,80001810 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017f0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017f4:	85ca                	mv	a1,s2
    800017f6:	855a                	mv	a0,s6
    800017f8:	00000097          	auipc	ra,0x0
    800017fc:	8fe080e7          	jalr	-1794(ra) # 800010f6 <walkaddr>
    if(pa0 == 0)
    80001800:	cd01                	beqz	a0,80001818 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001802:	418904b3          	sub	s1,s2,s8
    80001806:	94d6                	add	s1,s1,s5
    if(n > len)
    80001808:	fc99f2e3          	bgeu	s3,s1,800017cc <copyin+0x28>
    8000180c:	84ce                	mv	s1,s3
    8000180e:	bf7d                	j	800017cc <copyin+0x28>
  }
  return 0;
    80001810:	4501                	li	a0,0
    80001812:	a021                	j	8000181a <copyin+0x76>
    80001814:	4501                	li	a0,0
}
    80001816:	8082                	ret
      return -1;
    80001818:	557d                	li	a0,-1
}
    8000181a:	60a6                	ld	ra,72(sp)
    8000181c:	6406                	ld	s0,64(sp)
    8000181e:	74e2                	ld	s1,56(sp)
    80001820:	7942                	ld	s2,48(sp)
    80001822:	79a2                	ld	s3,40(sp)
    80001824:	7a02                	ld	s4,32(sp)
    80001826:	6ae2                	ld	s5,24(sp)
    80001828:	6b42                	ld	s6,16(sp)
    8000182a:	6ba2                	ld	s7,8(sp)
    8000182c:	6c02                	ld	s8,0(sp)
    8000182e:	6161                	addi	sp,sp,80
    80001830:	8082                	ret

0000000080001832 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001832:	cad5                	beqz	a3,800018e6 <copyinstr+0xb4>
{
    80001834:	715d                	addi	sp,sp,-80
    80001836:	e486                	sd	ra,72(sp)
    80001838:	e0a2                	sd	s0,64(sp)
    8000183a:	fc26                	sd	s1,56(sp)
    8000183c:	f84a                	sd	s2,48(sp)
    8000183e:	f44e                	sd	s3,40(sp)
    80001840:	f052                	sd	s4,32(sp)
    80001842:	ec56                	sd	s5,24(sp)
    80001844:	e85a                	sd	s6,16(sp)
    80001846:	e45e                	sd	s7,8(sp)
    80001848:	0880                	addi	s0,sp,80
    8000184a:	8aaa                	mv	s5,a0
    8000184c:	84ae                	mv	s1,a1
    8000184e:	8bb2                	mv	s7,a2
    80001850:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001852:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001854:	6a05                	lui	s4,0x1
    80001856:	a82d                	j	80001890 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001858:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000185c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000185e:	0017c793          	xori	a5,a5,1
    80001862:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001866:	60a6                	ld	ra,72(sp)
    80001868:	6406                	ld	s0,64(sp)
    8000186a:	74e2                	ld	s1,56(sp)
    8000186c:	7942                	ld	s2,48(sp)
    8000186e:	79a2                	ld	s3,40(sp)
    80001870:	7a02                	ld	s4,32(sp)
    80001872:	6ae2                	ld	s5,24(sp)
    80001874:	6b42                	ld	s6,16(sp)
    80001876:	6ba2                	ld	s7,8(sp)
    80001878:	6161                	addi	sp,sp,80
    8000187a:	8082                	ret
    8000187c:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001880:	9726                	add	a4,a4,s1
      --max;
    80001882:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001886:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000188a:	04e58663          	beq	a1,a4,800018d6 <copyinstr+0xa4>
{
    8000188e:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001890:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001894:	85ca                	mv	a1,s2
    80001896:	8556                	mv	a0,s5
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	85e080e7          	jalr	-1954(ra) # 800010f6 <walkaddr>
    if(pa0 == 0)
    800018a0:	cd0d                	beqz	a0,800018da <copyinstr+0xa8>
    n = PGSIZE - (srcva - va0);
    800018a2:	417906b3          	sub	a3,s2,s7
    800018a6:	96d2                	add	a3,a3,s4
    if(n > max)
    800018a8:	00d9f363          	bgeu	s3,a3,800018ae <copyinstr+0x7c>
    800018ac:	86ce                	mv	a3,s3
    while(n > 0){
    800018ae:	ca85                	beqz	a3,800018de <copyinstr+0xac>
    char *p = (char *) (pa0 + (srcva - va0));
    800018b0:	01750633          	add	a2,a0,s7
    800018b4:	41260633          	sub	a2,a2,s2
    800018b8:	87a6                	mv	a5,s1
      if(*p == '\0'){
    800018ba:	8e05                	sub	a2,a2,s1
    while(n > 0){
    800018bc:	96a6                	add	a3,a3,s1
    800018be:	85be                	mv	a1,a5
      if(*p == '\0'){
    800018c0:	00f60733          	add	a4,a2,a5
    800018c4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcec0>
    800018c8:	db41                	beqz	a4,80001858 <copyinstr+0x26>
        *dst = *p;
    800018ca:	00e78023          	sb	a4,0(a5)
      dst++;
    800018ce:	0785                	addi	a5,a5,1
    while(n > 0){
    800018d0:	fed797e3          	bne	a5,a3,800018be <copyinstr+0x8c>
    800018d4:	b765                	j	8000187c <copyinstr+0x4a>
    800018d6:	4781                	li	a5,0
    800018d8:	b759                	j	8000185e <copyinstr+0x2c>
      return -1;
    800018da:	557d                	li	a0,-1
    800018dc:	b769                	j	80001866 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800018de:	6b85                	lui	s7,0x1
    800018e0:	9bca                	add	s7,s7,s2
    800018e2:	87a6                	mv	a5,s1
    800018e4:	b76d                	j	8000188e <copyinstr+0x5c>
  int got_null = 0;
    800018e6:	4781                	li	a5,0
  if(got_null){
    800018e8:	0017c793          	xori	a5,a5,1
    800018ec:	40f0053b          	negw	a0,a5
}
    800018f0:	8082                	ret

00000000800018f2 <findMinAccum>:
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;


long long findMinAccum(void){
    800018f2:	7139                	addi	sp,sp,-64
    800018f4:	fc06                	sd	ra,56(sp)
    800018f6:	f822                	sd	s0,48(sp)
    800018f8:	f426                	sd	s1,40(sp)
    800018fa:	f04a                	sd	s2,32(sp)
    800018fc:	ec4e                	sd	s3,24(sp)
    800018fe:	e852                	sd	s4,16(sp)
    80001900:	e456                	sd	s5,8(sp)
    80001902:	0080                	addi	s0,sp,64
  struct proc *temp;
  long long min = -1;
    80001904:	5a7d                	li	s4,-1
  
  for(temp = proc; temp < &proc[NPROC]; temp++){
    80001906:	0000f497          	auipc	s1,0xf
    8000190a:	65a48493          	addi	s1,s1,1626 # 80010f60 <proc>
    acquire(&temp->lock);
    if(temp->state == RUNNABLE || temp->state == RUNNING){
    8000190e:	4985                	li	s3,1
      if(min == -1 || temp->accumulator < min){
    80001910:	8ad2                	mv	s5,s4
  for(temp = proc; temp < &proc[NPROC]; temp++){
    80001912:	00015917          	auipc	s2,0x15
    80001916:	44e90913          	addi	s2,s2,1102 # 80016d60 <tickslock>
    8000191a:	a821                	j	80001932 <findMinAccum+0x40>
        min = temp->accumulator;
    8000191c:	1684ba03          	ld	s4,360(s1)
      }
    }
    release(&temp->lock);
    80001920:	8526                	mv	a0,s1
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	3ea080e7          	jalr	1002(ra) # 80000d0c <release>
  for(temp = proc; temp < &proc[NPROC]; temp++){
    8000192a:	17848493          	addi	s1,s1,376
    8000192e:	03248263          	beq	s1,s2,80001952 <findMinAccum+0x60>
    acquire(&temp->lock);
    80001932:	8526                	mv	a0,s1
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	328080e7          	jalr	808(ra) # 80000c5c <acquire>
    if(temp->state == RUNNABLE || temp->state == RUNNING){
    8000193c:	4c9c                	lw	a5,24(s1)
    8000193e:	37f5                	addiw	a5,a5,-3
    80001940:	fef9e0e3          	bltu	s3,a5,80001920 <findMinAccum+0x2e>
      if(min == -1 || temp->accumulator < min){
    80001944:	fd5a0ce3          	beq	s4,s5,8000191c <findMinAccum+0x2a>
    80001948:	1684b783          	ld	a5,360(s1)
    8000194c:	fd47dae3          	bge	a5,s4,80001920 <findMinAccum+0x2e>
    80001950:	b7f1                	j	8000191c <findMinAccum+0x2a>
  }
  return min;
}
    80001952:	8552                	mv	a0,s4
    80001954:	70e2                	ld	ra,56(sp)
    80001956:	7442                	ld	s0,48(sp)
    80001958:	74a2                	ld	s1,40(sp)
    8000195a:	7902                	ld	s2,32(sp)
    8000195c:	69e2                	ld	s3,24(sp)
    8000195e:	6a42                	ld	s4,16(sp)
    80001960:	6aa2                	ld	s5,8(sp)
    80001962:	6121                	addi	sp,sp,64
    80001964:	8082                	ret

0000000080001966 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001966:	715d                	addi	sp,sp,-80
    80001968:	e486                	sd	ra,72(sp)
    8000196a:	e0a2                	sd	s0,64(sp)
    8000196c:	fc26                	sd	s1,56(sp)
    8000196e:	f84a                	sd	s2,48(sp)
    80001970:	f44e                	sd	s3,40(sp)
    80001972:	f052                	sd	s4,32(sp)
    80001974:	ec56                	sd	s5,24(sp)
    80001976:	e85a                	sd	s6,16(sp)
    80001978:	e45e                	sd	s7,8(sp)
    8000197a:	e062                	sd	s8,0(sp)
    8000197c:	0880                	addi	s0,sp,80
    8000197e:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001980:	0000f497          	auipc	s1,0xf
    80001984:	5e048493          	addi	s1,s1,1504 # 80010f60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001988:	8c26                	mv	s8,s1
    8000198a:	677d47b7          	lui	a5,0x677d4
    8000198e:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    80001992:	51b3c937          	lui	s2,0x51b3c
    80001996:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    8000199a:	1902                	slli	s2,s2,0x20
    8000199c:	993e                	add	s2,s2,a5
    8000199e:	040009b7          	lui	s3,0x4000
    800019a2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019a4:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019a6:	4b99                	li	s7,6
    800019a8:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800019aa:	00015a97          	auipc	s5,0x15
    800019ae:	3b6a8a93          	addi	s5,s5,950 # 80016d60 <tickslock>
    char *pa = kalloc();
    800019b2:	fffff097          	auipc	ra,0xfffff
    800019b6:	1a6080e7          	jalr	422(ra) # 80000b58 <kalloc>
    800019ba:	862a                	mv	a2,a0
    if(pa == 0)
    800019bc:	c131                	beqz	a0,80001a00 <proc_mapstacks+0x9a>
    uint64 va = KSTACK((int) (p - proc));
    800019be:	418485b3          	sub	a1,s1,s8
    800019c2:	858d                	srai	a1,a1,0x3
    800019c4:	032585b3          	mul	a1,a1,s2
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	6789                	lui	a5,0x2
    800019cc:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019ce:	875e                	mv	a4,s7
    800019d0:	86da                	mv	a3,s6
    800019d2:	40b985b3          	sub	a1,s3,a1
    800019d6:	8552                	mv	a0,s4
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	7fe080e7          	jalr	2046(ra) # 800011d6 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e0:	17848493          	addi	s1,s1,376
    800019e4:	fd5497e3          	bne	s1,s5,800019b2 <proc_mapstacks+0x4c>
  }
}
    800019e8:	60a6                	ld	ra,72(sp)
    800019ea:	6406                	ld	s0,64(sp)
    800019ec:	74e2                	ld	s1,56(sp)
    800019ee:	7942                	ld	s2,48(sp)
    800019f0:	79a2                	ld	s3,40(sp)
    800019f2:	7a02                	ld	s4,32(sp)
    800019f4:	6ae2                	ld	s5,24(sp)
    800019f6:	6b42                	ld	s6,16(sp)
    800019f8:	6ba2                	ld	s7,8(sp)
    800019fa:	6c02                	ld	s8,0(sp)
    800019fc:	6161                	addi	sp,sp,80
    800019fe:	8082                	ret
      panic("kalloc");
    80001a00:	00006517          	auipc	a0,0x6
    80001a04:	7b850513          	addi	a0,a0,1976 # 800081b8 <etext+0x1b8>
    80001a08:	fffff097          	auipc	ra,0xfffff
    80001a0c:	b56080e7          	jalr	-1194(ra) # 8000055e <panic>

0000000080001a10 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001a10:	7139                	addi	sp,sp,-64
    80001a12:	fc06                	sd	ra,56(sp)
    80001a14:	f822                	sd	s0,48(sp)
    80001a16:	f426                	sd	s1,40(sp)
    80001a18:	f04a                	sd	s2,32(sp)
    80001a1a:	ec4e                	sd	s3,24(sp)
    80001a1c:	e852                	sd	s4,16(sp)
    80001a1e:	e456                	sd	s5,8(sp)
    80001a20:	e05a                	sd	s6,0(sp)
    80001a22:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a24:	00006597          	auipc	a1,0x6
    80001a28:	79c58593          	addi	a1,a1,1948 # 800081c0 <etext+0x1c0>
    80001a2c:	0000f517          	auipc	a0,0xf
    80001a30:	10450513          	addi	a0,a0,260 # 80010b30 <pid_lock>
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	18e080e7          	jalr	398(ra) # 80000bc2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a3c:	00006597          	auipc	a1,0x6
    80001a40:	78c58593          	addi	a1,a1,1932 # 800081c8 <etext+0x1c8>
    80001a44:	0000f517          	auipc	a0,0xf
    80001a48:	10450513          	addi	a0,a0,260 # 80010b48 <wait_lock>
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	176080e7          	jalr	374(ra) # 80000bc2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a54:	0000f497          	auipc	s1,0xf
    80001a58:	50c48493          	addi	s1,s1,1292 # 80010f60 <proc>
      initlock(&p->lock, "proc");
    80001a5c:	00006b17          	auipc	s6,0x6
    80001a60:	77cb0b13          	addi	s6,s6,1916 # 800081d8 <etext+0x1d8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001a64:	8aa6                	mv	s5,s1
    80001a66:	677d47b7          	lui	a5,0x677d4
    80001a6a:	6cf78793          	addi	a5,a5,1743 # 677d46cf <_entry-0x1882b931>
    80001a6e:	51b3c937          	lui	s2,0x51b3c
    80001a72:	ea390913          	addi	s2,s2,-349 # 51b3bea3 <_entry-0x2e4c415d>
    80001a76:	1902                	slli	s2,s2,0x20
    80001a78:	993e                	add	s2,s2,a5
    80001a7a:	040009b7          	lui	s3,0x4000
    80001a7e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a80:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a82:	00015a17          	auipc	s4,0x15
    80001a86:	2dea0a13          	addi	s4,s4,734 # 80016d60 <tickslock>
      initlock(&p->lock, "proc");
    80001a8a:	85da                	mv	a1,s6
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	fffff097          	auipc	ra,0xfffff
    80001a92:	134080e7          	jalr	308(ra) # 80000bc2 <initlock>
      p->state = UNUSED;
    80001a96:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a9a:	415487b3          	sub	a5,s1,s5
    80001a9e:	878d                	srai	a5,a5,0x3
    80001aa0:	032787b3          	mul	a5,a5,s2
    80001aa4:	07b6                	slli	a5,a5,0xd
    80001aa6:	6709                	lui	a4,0x2
    80001aa8:	9fb9                	addw	a5,a5,a4
    80001aaa:	40f987b3          	sub	a5,s3,a5
    80001aae:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab0:	17848493          	addi	s1,s1,376
    80001ab4:	fd449be3          	bne	s1,s4,80001a8a <procinit+0x7a>
  }
}
    80001ab8:	70e2                	ld	ra,56(sp)
    80001aba:	7442                	ld	s0,48(sp)
    80001abc:	74a2                	ld	s1,40(sp)
    80001abe:	7902                	ld	s2,32(sp)
    80001ac0:	69e2                	ld	s3,24(sp)
    80001ac2:	6a42                	ld	s4,16(sp)
    80001ac4:	6aa2                	ld	s5,8(sp)
    80001ac6:	6b02                	ld	s6,0(sp)
    80001ac8:	6121                	addi	sp,sp,64
    80001aca:	8082                	ret

0000000080001acc <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001acc:	1141                	addi	sp,sp,-16
    80001ace:	e406                	sd	ra,8(sp)
    80001ad0:	e022                	sd	s0,0(sp)
    80001ad2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ad4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ad6:	2501                	sext.w	a0,a0
    80001ad8:	60a2                	ld	ra,8(sp)
    80001ada:	6402                	ld	s0,0(sp)
    80001adc:	0141                	addi	sp,sp,16
    80001ade:	8082                	ret

0000000080001ae0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001ae0:	1141                	addi	sp,sp,-16
    80001ae2:	e406                	sd	ra,8(sp)
    80001ae4:	e022                	sd	s0,0(sp)
    80001ae6:	0800                	addi	s0,sp,16
    80001ae8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001aea:	2781                	sext.w	a5,a5
    80001aec:	079e                	slli	a5,a5,0x7
  return c;
}
    80001aee:	0000f517          	auipc	a0,0xf
    80001af2:	07250513          	addi	a0,a0,114 # 80010b60 <cpus>
    80001af6:	953e                	add	a0,a0,a5
    80001af8:	60a2                	ld	ra,8(sp)
    80001afa:	6402                	ld	s0,0(sp)
    80001afc:	0141                	addi	sp,sp,16
    80001afe:	8082                	ret

0000000080001b00 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001b00:	1101                	addi	sp,sp,-32
    80001b02:	ec06                	sd	ra,24(sp)
    80001b04:	e822                	sd	s0,16(sp)
    80001b06:	e426                	sd	s1,8(sp)
    80001b08:	1000                	addi	s0,sp,32
  push_off();
    80001b0a:	fffff097          	auipc	ra,0xfffff
    80001b0e:	102080e7          	jalr	258(ra) # 80000c0c <push_off>
    80001b12:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b14:	2781                	sext.w	a5,a5
    80001b16:	079e                	slli	a5,a5,0x7
    80001b18:	0000f717          	auipc	a4,0xf
    80001b1c:	01870713          	addi	a4,a4,24 # 80010b30 <pid_lock>
    80001b20:	97ba                	add	a5,a5,a4
    80001b22:	7b9c                	ld	a5,48(a5)
    80001b24:	84be                	mv	s1,a5
  pop_off();
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	18a080e7          	jalr	394(ra) # 80000cb0 <pop_off>
  return p;
}
    80001b2e:	8526                	mv	a0,s1
    80001b30:	60e2                	ld	ra,24(sp)
    80001b32:	6442                	ld	s0,16(sp)
    80001b34:	64a2                	ld	s1,8(sp)
    80001b36:	6105                	addi	sp,sp,32
    80001b38:	8082                	ret

0000000080001b3a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b3a:	1141                	addi	sp,sp,-16
    80001b3c:	e406                	sd	ra,8(sp)
    80001b3e:	e022                	sd	s0,0(sp)
    80001b40:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b42:	00000097          	auipc	ra,0x0
    80001b46:	fbe080e7          	jalr	-66(ra) # 80001b00 <myproc>
    80001b4a:	fffff097          	auipc	ra,0xfffff
    80001b4e:	1c2080e7          	jalr	450(ra) # 80000d0c <release>

  if (first) {
    80001b52:	00007797          	auipc	a5,0x7
    80001b56:	cee7a783          	lw	a5,-786(a5) # 80008840 <first.1>
    80001b5a:	eb89                	bnez	a5,80001b6c <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b5c:	00001097          	auipc	ra,0x1
    80001b60:	cf6080e7          	jalr	-778(ra) # 80002852 <usertrapret>
}
    80001b64:	60a2                	ld	ra,8(sp)
    80001b66:	6402                	ld	s0,0(sp)
    80001b68:	0141                	addi	sp,sp,16
    80001b6a:	8082                	ret
    first = 0;
    80001b6c:	00007797          	auipc	a5,0x7
    80001b70:	cc07aa23          	sw	zero,-812(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80001b74:	4505                	li	a0,1
    80001b76:	00002097          	auipc	ra,0x2
    80001b7a:	a96080e7          	jalr	-1386(ra) # 8000360c <fsinit>
    80001b7e:	bff9                	j	80001b5c <forkret+0x22>

0000000080001b80 <allocpid>:
{
    80001b80:	1101                	addi	sp,sp,-32
    80001b82:	ec06                	sd	ra,24(sp)
    80001b84:	e822                	sd	s0,16(sp)
    80001b86:	e426                	sd	s1,8(sp)
    80001b88:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b8a:	0000f517          	auipc	a0,0xf
    80001b8e:	fa650513          	addi	a0,a0,-90 # 80010b30 <pid_lock>
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	0ca080e7          	jalr	202(ra) # 80000c5c <acquire>
  pid = nextpid;
    80001b9a:	00007797          	auipc	a5,0x7
    80001b9e:	caa78793          	addi	a5,a5,-854 # 80008844 <nextpid>
    80001ba2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ba4:	0014871b          	addiw	a4,s1,1
    80001ba8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001baa:	0000f517          	auipc	a0,0xf
    80001bae:	f8650513          	addi	a0,a0,-122 # 80010b30 <pid_lock>
    80001bb2:	fffff097          	auipc	ra,0xfffff
    80001bb6:	15a080e7          	jalr	346(ra) # 80000d0c <release>
}
    80001bba:	8526                	mv	a0,s1
    80001bbc:	60e2                	ld	ra,24(sp)
    80001bbe:	6442                	ld	s0,16(sp)
    80001bc0:	64a2                	ld	s1,8(sp)
    80001bc2:	6105                	addi	sp,sp,32
    80001bc4:	8082                	ret

0000000080001bc6 <proc_pagetable>:
{
    80001bc6:	1101                	addi	sp,sp,-32
    80001bc8:	ec06                	sd	ra,24(sp)
    80001bca:	e822                	sd	s0,16(sp)
    80001bcc:	e426                	sd	s1,8(sp)
    80001bce:	e04a                	sd	s2,0(sp)
    80001bd0:	1000                	addi	s0,sp,32
    80001bd2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	7f8080e7          	jalr	2040(ra) # 800013cc <uvmcreate>
    80001bdc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bde:	c121                	beqz	a0,80001c1e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001be0:	4729                	li	a4,10
    80001be2:	00005697          	auipc	a3,0x5
    80001be6:	41e68693          	addi	a3,a3,1054 # 80007000 <_trampoline>
    80001bea:	6605                	lui	a2,0x1
    80001bec:	040005b7          	lui	a1,0x4000
    80001bf0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bf2:	05b2                	slli	a1,a1,0xc
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	540080e7          	jalr	1344(ra) # 80001134 <mappages>
    80001bfc:	02054863          	bltz	a0,80001c2c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c00:	4719                	li	a4,6
    80001c02:	05893683          	ld	a3,88(s2)
    80001c06:	6605                	lui	a2,0x1
    80001c08:	020005b7          	lui	a1,0x2000
    80001c0c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c0e:	05b6                	slli	a1,a1,0xd
    80001c10:	8526                	mv	a0,s1
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	522080e7          	jalr	1314(ra) # 80001134 <mappages>
    80001c1a:	02054163          	bltz	a0,80001c3c <proc_pagetable+0x76>
}
    80001c1e:	8526                	mv	a0,s1
    80001c20:	60e2                	ld	ra,24(sp)
    80001c22:	6442                	ld	s0,16(sp)
    80001c24:	64a2                	ld	s1,8(sp)
    80001c26:	6902                	ld	s2,0(sp)
    80001c28:	6105                	addi	sp,sp,32
    80001c2a:	8082                	ret
    uvmfree(pagetable, 0);
    80001c2c:	4581                	li	a1,0
    80001c2e:	8526                	mv	a0,s1
    80001c30:	00000097          	auipc	ra,0x0
    80001c34:	9ae080e7          	jalr	-1618(ra) # 800015de <uvmfree>
    return 0;
    80001c38:	4481                	li	s1,0
    80001c3a:	b7d5                	j	80001c1e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c3c:	4681                	li	a3,0
    80001c3e:	4605                	li	a2,1
    80001c40:	040005b7          	lui	a1,0x4000
    80001c44:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c46:	05b2                	slli	a1,a1,0xc
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	6ae080e7          	jalr	1710(ra) # 800012f8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c52:	4581                	li	a1,0
    80001c54:	8526                	mv	a0,s1
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	988080e7          	jalr	-1656(ra) # 800015de <uvmfree>
    return 0;
    80001c5e:	4481                	li	s1,0
    80001c60:	bf7d                	j	80001c1e <proc_pagetable+0x58>

0000000080001c62 <proc_freepagetable>:
{
    80001c62:	1101                	addi	sp,sp,-32
    80001c64:	ec06                	sd	ra,24(sp)
    80001c66:	e822                	sd	s0,16(sp)
    80001c68:	e426                	sd	s1,8(sp)
    80001c6a:	e04a                	sd	s2,0(sp)
    80001c6c:	1000                	addi	s0,sp,32
    80001c6e:	84aa                	mv	s1,a0
    80001c70:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c72:	4681                	li	a3,0
    80001c74:	4605                	li	a2,1
    80001c76:	040005b7          	lui	a1,0x4000
    80001c7a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c7c:	05b2                	slli	a1,a1,0xc
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	67a080e7          	jalr	1658(ra) # 800012f8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c86:	4681                	li	a3,0
    80001c88:	4605                	li	a2,1
    80001c8a:	020005b7          	lui	a1,0x2000
    80001c8e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c90:	05b6                	slli	a1,a1,0xd
    80001c92:	8526                	mv	a0,s1
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	664080e7          	jalr	1636(ra) # 800012f8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c9c:	85ca                	mv	a1,s2
    80001c9e:	8526                	mv	a0,s1
    80001ca0:	00000097          	auipc	ra,0x0
    80001ca4:	93e080e7          	jalr	-1730(ra) # 800015de <uvmfree>
}
    80001ca8:	60e2                	ld	ra,24(sp)
    80001caa:	6442                	ld	s0,16(sp)
    80001cac:	64a2                	ld	s1,8(sp)
    80001cae:	6902                	ld	s2,0(sp)
    80001cb0:	6105                	addi	sp,sp,32
    80001cb2:	8082                	ret

0000000080001cb4 <freeproc>:
{
    80001cb4:	1101                	addi	sp,sp,-32
    80001cb6:	ec06                	sd	ra,24(sp)
    80001cb8:	e822                	sd	s0,16(sp)
    80001cba:	e426                	sd	s1,8(sp)
    80001cbc:	1000                	addi	s0,sp,32
    80001cbe:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cc0:	6d28                	ld	a0,88(a0)
    80001cc2:	c509                	beqz	a0,80001ccc <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	d90080e7          	jalr	-624(ra) # 80000a54 <kfree>
  p->trapframe = 0;
    80001ccc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001cd0:	68a8                	ld	a0,80(s1)
    80001cd2:	c511                	beqz	a0,80001cde <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cd4:	64ac                	ld	a1,72(s1)
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	f8c080e7          	jalr	-116(ra) # 80001c62 <proc_freepagetable>
  p->pagetable = 0;
    80001cde:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ce2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ce6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cea:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001cee:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cf2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cf6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cfa:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001cfe:	0004ac23          	sw	zero,24(s1)
}
    80001d02:	60e2                	ld	ra,24(sp)
    80001d04:	6442                	ld	s0,16(sp)
    80001d06:	64a2                	ld	s1,8(sp)
    80001d08:	6105                	addi	sp,sp,32
    80001d0a:	8082                	ret

0000000080001d0c <allocproc>:
{
    80001d0c:	1101                	addi	sp,sp,-32
    80001d0e:	ec06                	sd	ra,24(sp)
    80001d10:	e822                	sd	s0,16(sp)
    80001d12:	e426                	sd	s1,8(sp)
    80001d14:	e04a                	sd	s2,0(sp)
    80001d16:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d18:	0000f497          	auipc	s1,0xf
    80001d1c:	24848493          	addi	s1,s1,584 # 80010f60 <proc>
    80001d20:	00015917          	auipc	s2,0x15
    80001d24:	04090913          	addi	s2,s2,64 # 80016d60 <tickslock>
    acquire(&p->lock);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	f32080e7          	jalr	-206(ra) # 80000c5c <acquire>
    if(p->state == UNUSED) {
    80001d32:	4c9c                	lw	a5,24(s1)
    80001d34:	cf81                	beqz	a5,80001d4c <allocproc+0x40>
      release(&p->lock);
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	fd4080e7          	jalr	-44(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d40:	17848493          	addi	s1,s1,376
    80001d44:	ff2492e3          	bne	s1,s2,80001d28 <allocproc+0x1c>
  return 0;
    80001d48:	4481                	li	s1,0
    80001d4a:	a041                	j	80001dca <allocproc+0xbe>
  p->pid = allocpid();
    80001d4c:	00000097          	auipc	ra,0x0
    80001d50:	e34080e7          	jalr	-460(ra) # 80001b80 <allocpid>
    80001d54:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d56:	4785                	li	a5,1
    80001d58:	cc9c                	sw	a5,24(s1)
  p->ps_priority = 5;
    80001d5a:	4795                	li	a5,5
    80001d5c:	16f4a823          	sw	a5,368(s1)
  release(&p->lock);
    80001d60:	8526                	mv	a0,s1
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	faa080e7          	jalr	-86(ra) # 80000d0c <release>
  long long min = findMinAccum();
    80001d6a:	00000097          	auipc	ra,0x0
    80001d6e:	b88080e7          	jalr	-1144(ra) # 800018f2 <findMinAccum>
    80001d72:	892a                	mv	s2,a0
  acquire(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	ee6080e7          	jalr	-282(ra) # 80000c5c <acquire>
  if(min == -1) min = 0;
    80001d7e:	57fd                	li	a5,-1
    80001d80:	04f90c63          	beq	s2,a5,80001dd8 <allocproc+0xcc>
  p->accumulator = min;
    80001d84:	1724b423          	sd	s2,360(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	dd0080e7          	jalr	-560(ra) # 80000b58 <kalloc>
    80001d90:	892a                	mv	s2,a0
    80001d92:	eca8                	sd	a0,88(s1)
    80001d94:	c521                	beqz	a0,80001ddc <allocproc+0xd0>
  p->pagetable = proc_pagetable(p);
    80001d96:	8526                	mv	a0,s1
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	e2e080e7          	jalr	-466(ra) # 80001bc6 <proc_pagetable>
    80001da0:	892a                	mv	s2,a0
    80001da2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001da4:	c921                	beqz	a0,80001df4 <allocproc+0xe8>
  memset(&p->context, 0, sizeof(p->context));
    80001da6:	07000613          	li	a2,112
    80001daa:	4581                	li	a1,0
    80001dac:	06048513          	addi	a0,s1,96
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	fa4080e7          	jalr	-92(ra) # 80000d54 <memset>
  p->context.ra = (uint64)forkret;
    80001db8:	00000797          	auipc	a5,0x0
    80001dbc:	d8278793          	addi	a5,a5,-638 # 80001b3a <forkret>
    80001dc0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001dc2:	60bc                	ld	a5,64(s1)
    80001dc4:	6705                	lui	a4,0x1
    80001dc6:	97ba                	add	a5,a5,a4
    80001dc8:	f4bc                	sd	a5,104(s1)
}
    80001dca:	8526                	mv	a0,s1
    80001dcc:	60e2                	ld	ra,24(sp)
    80001dce:	6442                	ld	s0,16(sp)
    80001dd0:	64a2                	ld	s1,8(sp)
    80001dd2:	6902                	ld	s2,0(sp)
    80001dd4:	6105                	addi	sp,sp,32
    80001dd6:	8082                	ret
  if(min == -1) min = 0;
    80001dd8:	4901                	li	s2,0
    80001dda:	b76d                	j	80001d84 <allocproc+0x78>
    freeproc(p);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	ed6080e7          	jalr	-298(ra) # 80001cb4 <freeproc>
    release(&p->lock);
    80001de6:	8526                	mv	a0,s1
    80001de8:	fffff097          	auipc	ra,0xfffff
    80001dec:	f24080e7          	jalr	-220(ra) # 80000d0c <release>
    return 0;
    80001df0:	84ca                	mv	s1,s2
    80001df2:	bfe1                	j	80001dca <allocproc+0xbe>
    freeproc(p);
    80001df4:	8526                	mv	a0,s1
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	ebe080e7          	jalr	-322(ra) # 80001cb4 <freeproc>
    release(&p->lock);
    80001dfe:	8526                	mv	a0,s1
    80001e00:	fffff097          	auipc	ra,0xfffff
    80001e04:	f0c080e7          	jalr	-244(ra) # 80000d0c <release>
    return 0;
    80001e08:	84ca                	mv	s1,s2
    80001e0a:	b7c1                	j	80001dca <allocproc+0xbe>

0000000080001e0c <userinit>:
{
    80001e0c:	1101                	addi	sp,sp,-32
    80001e0e:	ec06                	sd	ra,24(sp)
    80001e10:	e822                	sd	s0,16(sp)
    80001e12:	e426                	sd	s1,8(sp)
    80001e14:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	ef6080e7          	jalr	-266(ra) # 80001d0c <allocproc>
    80001e1e:	84aa                	mv	s1,a0
  initproc = p;
    80001e20:	00007797          	auipc	a5,0x7
    80001e24:	a8a7bc23          	sd	a0,-1384(a5) # 800088b8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e28:	03400613          	li	a2,52
    80001e2c:	00007597          	auipc	a1,0x7
    80001e30:	a2458593          	addi	a1,a1,-1500 # 80008850 <initcode>
    80001e34:	6928                	ld	a0,80(a0)
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	5c4080e7          	jalr	1476(ra) # 800013fa <uvmfirst>
  p->sz = PGSIZE;
    80001e3e:	6785                	lui	a5,0x1
    80001e40:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e42:	6cb8                	ld	a4,88(s1)
    80001e44:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e48:	6cb8                	ld	a4,88(s1)
    80001e4a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e4c:	4641                	li	a2,16
    80001e4e:	00006597          	auipc	a1,0x6
    80001e52:	39258593          	addi	a1,a1,914 # 800081e0 <etext+0x1e0>
    80001e56:	15848513          	addi	a0,s1,344
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	052080e7          	jalr	82(ra) # 80000eac <safestrcpy>
  p->cwd = namei("/");
    80001e62:	00006517          	auipc	a0,0x6
    80001e66:	38e50513          	addi	a0,a0,910 # 800081f0 <etext+0x1f0>
    80001e6a:	00002097          	auipc	ra,0x2
    80001e6e:	20e080e7          	jalr	526(ra) # 80004078 <namei>
    80001e72:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e76:	478d                	li	a5,3
    80001e78:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e7a:	8526                	mv	a0,s1
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e90080e7          	jalr	-368(ra) # 80000d0c <release>
}
    80001e84:	60e2                	ld	ra,24(sp)
    80001e86:	6442                	ld	s0,16(sp)
    80001e88:	64a2                	ld	s1,8(sp)
    80001e8a:	6105                	addi	sp,sp,32
    80001e8c:	8082                	ret

0000000080001e8e <growproc>:
{
    80001e8e:	1101                	addi	sp,sp,-32
    80001e90:	ec06                	sd	ra,24(sp)
    80001e92:	e822                	sd	s0,16(sp)
    80001e94:	e426                	sd	s1,8(sp)
    80001e96:	e04a                	sd	s2,0(sp)
    80001e98:	1000                	addi	s0,sp,32
    80001e9a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e9c:	00000097          	auipc	ra,0x0
    80001ea0:	c64080e7          	jalr	-924(ra) # 80001b00 <myproc>
    80001ea4:	84aa                	mv	s1,a0
  sz = p->sz;
    80001ea6:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001ea8:	01204c63          	bgtz	s2,80001ec0 <growproc+0x32>
  } else if(n < 0){
    80001eac:	02094663          	bltz	s2,80001ed8 <growproc+0x4a>
  p->sz = sz;
    80001eb0:	e4ac                	sd	a1,72(s1)
  return 0;
    80001eb2:	4501                	li	a0,0
}
    80001eb4:	60e2                	ld	ra,24(sp)
    80001eb6:	6442                	ld	s0,16(sp)
    80001eb8:	64a2                	ld	s1,8(sp)
    80001eba:	6902                	ld	s2,0(sp)
    80001ebc:	6105                	addi	sp,sp,32
    80001ebe:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ec0:	4691                	li	a3,4
    80001ec2:	00b90633          	add	a2,s2,a1
    80001ec6:	6928                	ld	a0,80(a0)
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	5ec080e7          	jalr	1516(ra) # 800014b4 <uvmalloc>
    80001ed0:	85aa                	mv	a1,a0
    80001ed2:	fd79                	bnez	a0,80001eb0 <growproc+0x22>
      return -1;
    80001ed4:	557d                	li	a0,-1
    80001ed6:	bff9                	j	80001eb4 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ed8:	00b90633          	add	a2,s2,a1
    80001edc:	6928                	ld	a0,80(a0)
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	58e080e7          	jalr	1422(ra) # 8000146c <uvmdealloc>
    80001ee6:	85aa                	mv	a1,a0
    80001ee8:	b7e1                	j	80001eb0 <growproc+0x22>

0000000080001eea <fork>:
{
    80001eea:	7139                	addi	sp,sp,-64
    80001eec:	fc06                	sd	ra,56(sp)
    80001eee:	f822                	sd	s0,48(sp)
    80001ef0:	f426                	sd	s1,40(sp)
    80001ef2:	e456                	sd	s5,8(sp)
    80001ef4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ef6:	00000097          	auipc	ra,0x0
    80001efa:	c0a080e7          	jalr	-1014(ra) # 80001b00 <myproc>
    80001efe:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f00:	00000097          	auipc	ra,0x0
    80001f04:	e0c080e7          	jalr	-500(ra) # 80001d0c <allocproc>
    80001f08:	12050063          	beqz	a0,80002028 <fork+0x13e>
    80001f0c:	e852                	sd	s4,16(sp)
    80001f0e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f10:	048ab603          	ld	a2,72(s5)
    80001f14:	692c                	ld	a1,80(a0)
    80001f16:	050ab503          	ld	a0,80(s5)
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	6fe080e7          	jalr	1790(ra) # 80001618 <uvmcopy>
    80001f22:	04054863          	bltz	a0,80001f72 <fork+0x88>
    80001f26:	f04a                	sd	s2,32(sp)
    80001f28:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001f2a:	048ab783          	ld	a5,72(s5)
    80001f2e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f32:	058ab683          	ld	a3,88(s5)
    80001f36:	87b6                	mv	a5,a3
    80001f38:	058a3703          	ld	a4,88(s4)
    80001f3c:	12068693          	addi	a3,a3,288
    80001f40:	6388                	ld	a0,0(a5)
    80001f42:	678c                	ld	a1,8(a5)
    80001f44:	6b90                	ld	a2,16(a5)
    80001f46:	e308                	sd	a0,0(a4)
    80001f48:	e70c                	sd	a1,8(a4)
    80001f4a:	eb10                	sd	a2,16(a4)
    80001f4c:	6f90                	ld	a2,24(a5)
    80001f4e:	ef10                	sd	a2,24(a4)
    80001f50:	02078793          	addi	a5,a5,32 # 1020 <_entry-0x7fffefe0>
    80001f54:	02070713          	addi	a4,a4,32
    80001f58:	fed794e3          	bne	a5,a3,80001f40 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f5c:	058a3783          	ld	a5,88(s4)
    80001f60:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f64:	0d0a8493          	addi	s1,s5,208
    80001f68:	0d0a0913          	addi	s2,s4,208
    80001f6c:	150a8993          	addi	s3,s5,336
    80001f70:	a015                	j	80001f94 <fork+0xaa>
    freeproc(np);
    80001f72:	8552                	mv	a0,s4
    80001f74:	00000097          	auipc	ra,0x0
    80001f78:	d40080e7          	jalr	-704(ra) # 80001cb4 <freeproc>
    release(&np->lock);
    80001f7c:	8552                	mv	a0,s4
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	d8e080e7          	jalr	-626(ra) # 80000d0c <release>
    return -1;
    80001f86:	54fd                	li	s1,-1
    80001f88:	6a42                	ld	s4,16(sp)
    80001f8a:	a841                	j	8000201a <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001f8c:	04a1                	addi	s1,s1,8
    80001f8e:	0921                	addi	s2,s2,8
    80001f90:	01348b63          	beq	s1,s3,80001fa6 <fork+0xbc>
    if(p->ofile[i])
    80001f94:	6088                	ld	a0,0(s1)
    80001f96:	d97d                	beqz	a0,80001f8c <fork+0xa2>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f98:	00002097          	auipc	ra,0x2
    80001f9c:	776080e7          	jalr	1910(ra) # 8000470e <filedup>
    80001fa0:	00a93023          	sd	a0,0(s2)
    80001fa4:	b7e5                	j	80001f8c <fork+0xa2>
  np->cwd = idup(p->cwd);
    80001fa6:	150ab503          	ld	a0,336(s5)
    80001faa:	00002097          	auipc	ra,0x2
    80001fae:	8a6080e7          	jalr	-1882(ra) # 80003850 <idup>
    80001fb2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fb6:	4641                	li	a2,16
    80001fb8:	158a8593          	addi	a1,s5,344
    80001fbc:	158a0513          	addi	a0,s4,344
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	eec080e7          	jalr	-276(ra) # 80000eac <safestrcpy>
  pid = np->pid;
    80001fc8:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001fcc:	8552                	mv	a0,s4
    80001fce:	fffff097          	auipc	ra,0xfffff
    80001fd2:	d3e080e7          	jalr	-706(ra) # 80000d0c <release>
  acquire(&wait_lock);
    80001fd6:	0000f517          	auipc	a0,0xf
    80001fda:	b7250513          	addi	a0,a0,-1166 # 80010b48 <wait_lock>
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	c7e080e7          	jalr	-898(ra) # 80000c5c <acquire>
  np->parent = p;
    80001fe6:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001fea:	0000f517          	auipc	a0,0xf
    80001fee:	b5e50513          	addi	a0,a0,-1186 # 80010b48 <wait_lock>
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	d1a080e7          	jalr	-742(ra) # 80000d0c <release>
  acquire(&np->lock);
    80001ffa:	8552                	mv	a0,s4
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	c60080e7          	jalr	-928(ra) # 80000c5c <acquire>
  np->state = RUNNABLE;
    80002004:	478d                	li	a5,3
    80002006:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000200a:	8552                	mv	a0,s4
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	d00080e7          	jalr	-768(ra) # 80000d0c <release>
  return pid;
    80002014:	7902                	ld	s2,32(sp)
    80002016:	69e2                	ld	s3,24(sp)
    80002018:	6a42                	ld	s4,16(sp)
}
    8000201a:	8526                	mv	a0,s1
    8000201c:	70e2                	ld	ra,56(sp)
    8000201e:	7442                	ld	s0,48(sp)
    80002020:	74a2                	ld	s1,40(sp)
    80002022:	6aa2                	ld	s5,8(sp)
    80002024:	6121                	addi	sp,sp,64
    80002026:	8082                	ret
    return -1;
    80002028:	54fd                	li	s1,-1
    8000202a:	bfc5                	j	8000201a <fork+0x130>

000000008000202c <scheduler>:
{
    8000202c:	715d                	addi	sp,sp,-80
    8000202e:	e486                	sd	ra,72(sp)
    80002030:	e0a2                	sd	s0,64(sp)
    80002032:	fc26                	sd	s1,56(sp)
    80002034:	f84a                	sd	s2,48(sp)
    80002036:	f44e                	sd	s3,40(sp)
    80002038:	f052                	sd	s4,32(sp)
    8000203a:	ec56                	sd	s5,24(sp)
    8000203c:	e85a                	sd	s6,16(sp)
    8000203e:	e45e                	sd	s7,8(sp)
    80002040:	0880                	addi	s0,sp,80
    80002042:	8792                	mv	a5,tp
  int id = r_tp();
    80002044:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002046:	00779b13          	slli	s6,a5,0x7
    8000204a:	0000f717          	auipc	a4,0xf
    8000204e:	ae670713          	addi	a4,a4,-1306 # 80010b30 <pid_lock>
    80002052:	975a                	add	a4,a4,s6
    80002054:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &minP->context);
    80002058:	0000f717          	auipc	a4,0xf
    8000205c:	b1070713          	addi	a4,a4,-1264 # 80010b68 <cpus+0x8>
    80002060:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE) {
    80002062:	4a0d                	li	s4,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80002064:	00015997          	auipc	s3,0x15
    80002068:	cfc98993          	addi	s3,s3,-772 # 80016d60 <tickslock>
      minP->state = RUNNING;
    8000206c:	4b91                	li	s7,4
      c->proc = minP;
    8000206e:	079e                	slli	a5,a5,0x7
    80002070:	0000fa97          	auipc	s5,0xf
    80002074:	ac0a8a93          	addi	s5,s5,-1344 # 80010b30 <pid_lock>
    80002078:	9abe                	add	s5,s5,a5
    8000207a:	a0bd                	j	800020e8 <scheduler+0xbc>
      release(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	c8e080e7          	jalr	-882(ra) # 80000d0c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002086:	17848493          	addi	s1,s1,376
    8000208a:	03348b63          	beq	s1,s3,800020c0 <scheduler+0x94>
      acquire(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	bcc080e7          	jalr	-1076(ra) # 80000c5c <acquire>
      if(p->state == RUNNABLE) {
    80002098:	4c9c                	lw	a5,24(s1)
    8000209a:	ff4791e3          	bne	a5,s4,8000207c <scheduler+0x50>
        if(minP == 0 || p->accumulator < minP->accumulator) {
    8000209e:	00090f63          	beqz	s2,800020bc <scheduler+0x90>
    800020a2:	1684b703          	ld	a4,360(s1)
    800020a6:	16893783          	ld	a5,360(s2)
    800020aa:	fcf759e3          	bge	a4,a5,8000207c <scheduler+0x50>
                release(&minP->lock);
    800020ae:	854a                	mv	a0,s2
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	c5c080e7          	jalr	-932(ra) # 80000d0c <release>
            minP = p;
    800020b8:	8926                	mv	s2,s1
    800020ba:	b7f1                	j	80002086 <scheduler+0x5a>
    800020bc:	8926                	mv	s2,s1
    800020be:	b7e1                	j	80002086 <scheduler+0x5a>
    if(minP != 0) {
    800020c0:	04090063          	beqz	s2,80002100 <scheduler+0xd4>
      minP->state = RUNNING;
    800020c4:	01792c23          	sw	s7,24(s2)
      c->proc = minP;
    800020c8:	032ab823          	sd	s2,48(s5)
      swtch(&c->context, &minP->context);
    800020cc:	06090593          	addi	a1,s2,96
    800020d0:	855a                	mv	a0,s6
    800020d2:	00000097          	auipc	ra,0x0
    800020d6:	6d2080e7          	jalr	1746(ra) # 800027a4 <swtch>
      c->proc = 0;
    800020da:	020ab823          	sd	zero,48(s5)
      release(&minP->lock);
    800020de:	854a                	mv	a0,s2
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	c2c080e7          	jalr	-980(ra) # 80000d0c <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020e8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020f0:	10079073          	csrw	sstatus,a5
    minP = 0;
    800020f4:	4901                	li	s2,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800020f6:	0000f497          	auipc	s1,0xf
    800020fa:	e6a48493          	addi	s1,s1,-406 # 80010f60 <proc>
    800020fe:	bf41                	j	8000208e <scheduler+0x62>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002100:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002104:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002108:	10079073          	csrw	sstatus,a5
        asm volatile("wfi");
    8000210c:	10500073          	wfi
    80002110:	bfe1                	j	800020e8 <scheduler+0xbc>

0000000080002112 <sched>:
{
    80002112:	7179                	addi	sp,sp,-48
    80002114:	f406                	sd	ra,40(sp)
    80002116:	f022                	sd	s0,32(sp)
    80002118:	ec26                	sd	s1,24(sp)
    8000211a:	e84a                	sd	s2,16(sp)
    8000211c:	e44e                	sd	s3,8(sp)
    8000211e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002120:	00000097          	auipc	ra,0x0
    80002124:	9e0080e7          	jalr	-1568(ra) # 80001b00 <myproc>
    80002128:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	ab2080e7          	jalr	-1358(ra) # 80000bdc <holding>
    80002132:	cd25                	beqz	a0,800021aa <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002134:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002136:	2781                	sext.w	a5,a5
    80002138:	079e                	slli	a5,a5,0x7
    8000213a:	0000f717          	auipc	a4,0xf
    8000213e:	9f670713          	addi	a4,a4,-1546 # 80010b30 <pid_lock>
    80002142:	97ba                	add	a5,a5,a4
    80002144:	0a87a703          	lw	a4,168(a5)
    80002148:	4785                	li	a5,1
    8000214a:	06f71863          	bne	a4,a5,800021ba <sched+0xa8>
  if(p->state == RUNNING)
    8000214e:	4c98                	lw	a4,24(s1)
    80002150:	4791                	li	a5,4
    80002152:	06f70c63          	beq	a4,a5,800021ca <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002156:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000215a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000215c:	efbd                	bnez	a5,800021da <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000215e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002160:	0000f917          	auipc	s2,0xf
    80002164:	9d090913          	addi	s2,s2,-1584 # 80010b30 <pid_lock>
    80002168:	2781                	sext.w	a5,a5
    8000216a:	079e                	slli	a5,a5,0x7
    8000216c:	97ca                	add	a5,a5,s2
    8000216e:	0ac7a983          	lw	s3,172(a5)
    80002172:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002174:	2781                	sext.w	a5,a5
    80002176:	079e                	slli	a5,a5,0x7
    80002178:	07a1                	addi	a5,a5,8
    8000217a:	0000f597          	auipc	a1,0xf
    8000217e:	9e658593          	addi	a1,a1,-1562 # 80010b60 <cpus>
    80002182:	95be                	add	a1,a1,a5
    80002184:	06048513          	addi	a0,s1,96
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	61c080e7          	jalr	1564(ra) # 800027a4 <swtch>
    80002190:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002192:	2781                	sext.w	a5,a5
    80002194:	079e                	slli	a5,a5,0x7
    80002196:	993e                	add	s2,s2,a5
    80002198:	0b392623          	sw	s3,172(s2)
}
    8000219c:	70a2                	ld	ra,40(sp)
    8000219e:	7402                	ld	s0,32(sp)
    800021a0:	64e2                	ld	s1,24(sp)
    800021a2:	6942                	ld	s2,16(sp)
    800021a4:	69a2                	ld	s3,8(sp)
    800021a6:	6145                	addi	sp,sp,48
    800021a8:	8082                	ret
    panic("sched p->lock");
    800021aa:	00006517          	auipc	a0,0x6
    800021ae:	04e50513          	addi	a0,a0,78 # 800081f8 <etext+0x1f8>
    800021b2:	ffffe097          	auipc	ra,0xffffe
    800021b6:	3ac080e7          	jalr	940(ra) # 8000055e <panic>
    panic("sched locks");
    800021ba:	00006517          	auipc	a0,0x6
    800021be:	04e50513          	addi	a0,a0,78 # 80008208 <etext+0x208>
    800021c2:	ffffe097          	auipc	ra,0xffffe
    800021c6:	39c080e7          	jalr	924(ra) # 8000055e <panic>
    panic("sched running");
    800021ca:	00006517          	auipc	a0,0x6
    800021ce:	04e50513          	addi	a0,a0,78 # 80008218 <etext+0x218>
    800021d2:	ffffe097          	auipc	ra,0xffffe
    800021d6:	38c080e7          	jalr	908(ra) # 8000055e <panic>
    panic("sched interruptible");
    800021da:	00006517          	auipc	a0,0x6
    800021de:	04e50513          	addi	a0,a0,78 # 80008228 <etext+0x228>
    800021e2:	ffffe097          	auipc	ra,0xffffe
    800021e6:	37c080e7          	jalr	892(ra) # 8000055e <panic>

00000000800021ea <yield>:
{
    800021ea:	1101                	addi	sp,sp,-32
    800021ec:	ec06                	sd	ra,24(sp)
    800021ee:	e822                	sd	s0,16(sp)
    800021f0:	e426                	sd	s1,8(sp)
    800021f2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021f4:	00000097          	auipc	ra,0x0
    800021f8:	90c080e7          	jalr	-1780(ra) # 80001b00 <myproc>
    800021fc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021fe:	fffff097          	auipc	ra,0xfffff
    80002202:	a5e080e7          	jalr	-1442(ra) # 80000c5c <acquire>
  p->state = RUNNABLE;
    80002206:	478d                	li	a5,3
    80002208:	cc9c                	sw	a5,24(s1)
  sched();
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	f08080e7          	jalr	-248(ra) # 80002112 <sched>
  release(&p->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	af8080e7          	jalr	-1288(ra) # 80000d0c <release>
}
    8000221c:	60e2                	ld	ra,24(sp)
    8000221e:	6442                	ld	s0,16(sp)
    80002220:	64a2                	ld	s1,8(sp)
    80002222:	6105                	addi	sp,sp,32
    80002224:	8082                	ret

0000000080002226 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002226:	7179                	addi	sp,sp,-48
    80002228:	f406                	sd	ra,40(sp)
    8000222a:	f022                	sd	s0,32(sp)
    8000222c:	ec26                	sd	s1,24(sp)
    8000222e:	e84a                	sd	s2,16(sp)
    80002230:	e44e                	sd	s3,8(sp)
    80002232:	1800                	addi	s0,sp,48
    80002234:	89aa                	mv	s3,a0
    80002236:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002238:	00000097          	auipc	ra,0x0
    8000223c:	8c8080e7          	jalr	-1848(ra) # 80001b00 <myproc>
    80002240:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	a1a080e7          	jalr	-1510(ra) # 80000c5c <acquire>
  release(lk);
    8000224a:	854a                	mv	a0,s2
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	ac0080e7          	jalr	-1344(ra) # 80000d0c <release>

  // Go to sleep.
  p->chan = chan;
    80002254:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002258:	4789                	li	a5,2
    8000225a:	cc9c                	sw	a5,24(s1)

  sched();
    8000225c:	00000097          	auipc	ra,0x0
    80002260:	eb6080e7          	jalr	-330(ra) # 80002112 <sched>

  // Tidy up.
  p->chan = 0;
    80002264:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002268:	8526                	mv	a0,s1
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	aa2080e7          	jalr	-1374(ra) # 80000d0c <release>
  acquire(lk);
    80002272:	854a                	mv	a0,s2
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	9e8080e7          	jalr	-1560(ra) # 80000c5c <acquire>
}
    8000227c:	70a2                	ld	ra,40(sp)
    8000227e:	7402                	ld	s0,32(sp)
    80002280:	64e2                	ld	s1,24(sp)
    80002282:	6942                	ld	s2,16(sp)
    80002284:	69a2                	ld	s3,8(sp)
    80002286:	6145                	addi	sp,sp,48
    80002288:	8082                	ret

000000008000228a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000228a:	7139                	addi	sp,sp,-64
    8000228c:	fc06                	sd	ra,56(sp)
    8000228e:	f822                	sd	s0,48(sp)
    80002290:	f426                	sd	s1,40(sp)
    80002292:	f04a                	sd	s2,32(sp)
    80002294:	ec4e                	sd	s3,24(sp)
    80002296:	e852                	sd	s4,16(sp)
    80002298:	e456                	sd	s5,8(sp)
    8000229a:	e05a                	sd	s6,0(sp)
    8000229c:	0080                	addi	s0,sp,64
    8000229e:	8a2a                	mv	s4,a0
  struct proc *p;
  
  long long min = findMinAccum();
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	652080e7          	jalr	1618(ra) # 800018f2 <findMinAccum>
    800022a8:	8aaa                	mv	s5,a0
  if(min == -1){
    800022aa:	57fd                	li	a5,-1
    800022ac:	00f50d63          	beq	a0,a5,800022c6 <wakeup+0x3c>
    min = 0;
  }
  for(p = proc; p < &proc[NPROC]; p++) {
    800022b0:	0000f497          	auipc	s1,0xf
    800022b4:	cb048493          	addi	s1,s1,-848 # 80010f60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022b8:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022ba:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022bc:	00015917          	auipc	s2,0x15
    800022c0:	aa490913          	addi	s2,s2,-1372 # 80016d60 <tickslock>
    800022c4:	a821                	j	800022dc <wakeup+0x52>
    min = 0;
    800022c6:	4a81                	li	s5,0
    800022c8:	b7e5                	j	800022b0 <wakeup+0x26>
        p->accumulator = min;  // Reset per Rule B
      }
      release(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	a40080e7          	jalr	-1472(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022d4:	17848493          	addi	s1,s1,376
    800022d8:	03248863          	beq	s1,s2,80002308 <wakeup+0x7e>
    if(p != myproc()){
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	824080e7          	jalr	-2012(ra) # 80001b00 <myproc>
    800022e4:	fe9508e3          	beq	a0,s1,800022d4 <wakeup+0x4a>
      acquire(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	972080e7          	jalr	-1678(ra) # 80000c5c <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022f2:	4c9c                	lw	a5,24(s1)
    800022f4:	fd379be3          	bne	a5,s3,800022ca <wakeup+0x40>
    800022f8:	709c                	ld	a5,32(s1)
    800022fa:	fd4798e3          	bne	a5,s4,800022ca <wakeup+0x40>
        p->state = RUNNABLE;
    800022fe:	0164ac23          	sw	s6,24(s1)
        p->accumulator = min;  // Reset per Rule B
    80002302:	1754b423          	sd	s5,360(s1)
    80002306:	b7d1                	j	800022ca <wakeup+0x40>
    }
  }
}
    80002308:	70e2                	ld	ra,56(sp)
    8000230a:	7442                	ld	s0,48(sp)
    8000230c:	74a2                	ld	s1,40(sp)
    8000230e:	7902                	ld	s2,32(sp)
    80002310:	69e2                	ld	s3,24(sp)
    80002312:	6a42                	ld	s4,16(sp)
    80002314:	6aa2                	ld	s5,8(sp)
    80002316:	6b02                	ld	s6,0(sp)
    80002318:	6121                	addi	sp,sp,64
    8000231a:	8082                	ret

000000008000231c <reparent>:
{
    8000231c:	7179                	addi	sp,sp,-48
    8000231e:	f406                	sd	ra,40(sp)
    80002320:	f022                	sd	s0,32(sp)
    80002322:	ec26                	sd	s1,24(sp)
    80002324:	e84a                	sd	s2,16(sp)
    80002326:	e44e                	sd	s3,8(sp)
    80002328:	e052                	sd	s4,0(sp)
    8000232a:	1800                	addi	s0,sp,48
    8000232c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000232e:	0000f497          	auipc	s1,0xf
    80002332:	c3248493          	addi	s1,s1,-974 # 80010f60 <proc>
      pp->parent = initproc;
    80002336:	00006a17          	auipc	s4,0x6
    8000233a:	582a0a13          	addi	s4,s4,1410 # 800088b8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000233e:	00015997          	auipc	s3,0x15
    80002342:	a2298993          	addi	s3,s3,-1502 # 80016d60 <tickslock>
    80002346:	a029                	j	80002350 <reparent+0x34>
    80002348:	17848493          	addi	s1,s1,376
    8000234c:	01348d63          	beq	s1,s3,80002366 <reparent+0x4a>
    if(pp->parent == p){
    80002350:	7c9c                	ld	a5,56(s1)
    80002352:	ff279be3          	bne	a5,s2,80002348 <reparent+0x2c>
      pp->parent = initproc;
    80002356:	000a3503          	ld	a0,0(s4)
    8000235a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000235c:	00000097          	auipc	ra,0x0
    80002360:	f2e080e7          	jalr	-210(ra) # 8000228a <wakeup>
    80002364:	b7d5                	j	80002348 <reparent+0x2c>
}
    80002366:	70a2                	ld	ra,40(sp)
    80002368:	7402                	ld	s0,32(sp)
    8000236a:	64e2                	ld	s1,24(sp)
    8000236c:	6942                	ld	s2,16(sp)
    8000236e:	69a2                	ld	s3,8(sp)
    80002370:	6a02                	ld	s4,0(sp)
    80002372:	6145                	addi	sp,sp,48
    80002374:	8082                	ret

0000000080002376 <exit>:
{
    80002376:	7179                	addi	sp,sp,-48
    80002378:	f406                	sd	ra,40(sp)
    8000237a:	f022                	sd	s0,32(sp)
    8000237c:	ec26                	sd	s1,24(sp)
    8000237e:	e84a                	sd	s2,16(sp)
    80002380:	e44e                	sd	s3,8(sp)
    80002382:	e052                	sd	s4,0(sp)
    80002384:	1800                	addi	s0,sp,48
    80002386:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	778080e7          	jalr	1912(ra) # 80001b00 <myproc>
    80002390:	89aa                	mv	s3,a0
  if(p == initproc)
    80002392:	00006797          	auipc	a5,0x6
    80002396:	5267b783          	ld	a5,1318(a5) # 800088b8 <initproc>
    8000239a:	0d050493          	addi	s1,a0,208
    8000239e:	15050913          	addi	s2,a0,336
    800023a2:	00a79d63          	bne	a5,a0,800023bc <exit+0x46>
    panic("init exiting");
    800023a6:	00006517          	auipc	a0,0x6
    800023aa:	e9a50513          	addi	a0,a0,-358 # 80008240 <etext+0x240>
    800023ae:	ffffe097          	auipc	ra,0xffffe
    800023b2:	1b0080e7          	jalr	432(ra) # 8000055e <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    800023b6:	04a1                	addi	s1,s1,8
    800023b8:	01248b63          	beq	s1,s2,800023ce <exit+0x58>
    if(p->ofile[fd]){
    800023bc:	6088                	ld	a0,0(s1)
    800023be:	dd65                	beqz	a0,800023b6 <exit+0x40>
      fileclose(f);
    800023c0:	00002097          	auipc	ra,0x2
    800023c4:	3a0080e7          	jalr	928(ra) # 80004760 <fileclose>
      p->ofile[fd] = 0;
    800023c8:	0004b023          	sd	zero,0(s1)
    800023cc:	b7ed                	j	800023b6 <exit+0x40>
  begin_op();
    800023ce:	00002097          	auipc	ra,0x2
    800023d2:	eb0080e7          	jalr	-336(ra) # 8000427e <begin_op>
  iput(p->cwd);
    800023d6:	1509b503          	ld	a0,336(s3)
    800023da:	00001097          	auipc	ra,0x1
    800023de:	672080e7          	jalr	1650(ra) # 80003a4c <iput>
  end_op();
    800023e2:	00002097          	auipc	ra,0x2
    800023e6:	f1c080e7          	jalr	-228(ra) # 800042fe <end_op>
  p->cwd = 0;
    800023ea:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023ee:	0000e517          	auipc	a0,0xe
    800023f2:	75a50513          	addi	a0,a0,1882 # 80010b48 <wait_lock>
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	866080e7          	jalr	-1946(ra) # 80000c5c <acquire>
  reparent(p);
    800023fe:	854e                	mv	a0,s3
    80002400:	00000097          	auipc	ra,0x0
    80002404:	f1c080e7          	jalr	-228(ra) # 8000231c <reparent>
  wakeup(p->parent);
    80002408:	0389b503          	ld	a0,56(s3)
    8000240c:	00000097          	auipc	ra,0x0
    80002410:	e7e080e7          	jalr	-386(ra) # 8000228a <wakeup>
  acquire(&p->lock);
    80002414:	854e                	mv	a0,s3
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	846080e7          	jalr	-1978(ra) # 80000c5c <acquire>
  p->xstate = status;
    8000241e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002422:	4795                	li	a5,5
    80002424:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002428:	0000e517          	auipc	a0,0xe
    8000242c:	72050513          	addi	a0,a0,1824 # 80010b48 <wait_lock>
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	8dc080e7          	jalr	-1828(ra) # 80000d0c <release>
  sched();
    80002438:	00000097          	auipc	ra,0x0
    8000243c:	cda080e7          	jalr	-806(ra) # 80002112 <sched>
  panic("zombie exit");
    80002440:	00006517          	auipc	a0,0x6
    80002444:	e1050513          	addi	a0,a0,-496 # 80008250 <etext+0x250>
    80002448:	ffffe097          	auipc	ra,0xffffe
    8000244c:	116080e7          	jalr	278(ra) # 8000055e <panic>

0000000080002450 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002450:	7179                	addi	sp,sp,-48
    80002452:	f406                	sd	ra,40(sp)
    80002454:	f022                	sd	s0,32(sp)
    80002456:	ec26                	sd	s1,24(sp)
    80002458:	e84a                	sd	s2,16(sp)
    8000245a:	e44e                	sd	s3,8(sp)
    8000245c:	1800                	addi	s0,sp,48
    8000245e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002460:	0000f497          	auipc	s1,0xf
    80002464:	b0048493          	addi	s1,s1,-1280 # 80010f60 <proc>
    80002468:	00015997          	auipc	s3,0x15
    8000246c:	8f898993          	addi	s3,s3,-1800 # 80016d60 <tickslock>
    acquire(&p->lock);
    80002470:	8526                	mv	a0,s1
    80002472:	ffffe097          	auipc	ra,0xffffe
    80002476:	7ea080e7          	jalr	2026(ra) # 80000c5c <acquire>
    if(p->pid == pid){
    8000247a:	589c                	lw	a5,48(s1)
    8000247c:	01278d63          	beq	a5,s2,80002496 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	88a080e7          	jalr	-1910(ra) # 80000d0c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000248a:	17848493          	addi	s1,s1,376
    8000248e:	ff3491e3          	bne	s1,s3,80002470 <kill+0x20>
  }
  return -1;
    80002492:	557d                	li	a0,-1
    80002494:	a829                	j	800024ae <kill+0x5e>
      p->killed = 1;
    80002496:	4785                	li	a5,1
    80002498:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000249a:	4c98                	lw	a4,24(s1)
    8000249c:	4789                	li	a5,2
    8000249e:	00f70f63          	beq	a4,a5,800024bc <kill+0x6c>
      release(&p->lock);
    800024a2:	8526                	mv	a0,s1
    800024a4:	fffff097          	auipc	ra,0xfffff
    800024a8:	868080e7          	jalr	-1944(ra) # 80000d0c <release>
      return 0;
    800024ac:	4501                	li	a0,0
}
    800024ae:	70a2                	ld	ra,40(sp)
    800024b0:	7402                	ld	s0,32(sp)
    800024b2:	64e2                	ld	s1,24(sp)
    800024b4:	6942                	ld	s2,16(sp)
    800024b6:	69a2                	ld	s3,8(sp)
    800024b8:	6145                	addi	sp,sp,48
    800024ba:	8082                	ret
        p->state = RUNNABLE;
    800024bc:	478d                	li	a5,3
    800024be:	cc9c                	sw	a5,24(s1)
    800024c0:	b7cd                	j	800024a2 <kill+0x52>

00000000800024c2 <setkilled>:

void
setkilled(struct proc *p)
{
    800024c2:	1101                	addi	sp,sp,-32
    800024c4:	ec06                	sd	ra,24(sp)
    800024c6:	e822                	sd	s0,16(sp)
    800024c8:	e426                	sd	s1,8(sp)
    800024ca:	1000                	addi	s0,sp,32
    800024cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	78e080e7          	jalr	1934(ra) # 80000c5c <acquire>
  p->killed = 1;
    800024d6:	4785                	li	a5,1
    800024d8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	830080e7          	jalr	-2000(ra) # 80000d0c <release>
}
    800024e4:	60e2                	ld	ra,24(sp)
    800024e6:	6442                	ld	s0,16(sp)
    800024e8:	64a2                	ld	s1,8(sp)
    800024ea:	6105                	addi	sp,sp,32
    800024ec:	8082                	ret

00000000800024ee <killed>:

int
killed(struct proc *p)
{
    800024ee:	1101                	addi	sp,sp,-32
    800024f0:	ec06                	sd	ra,24(sp)
    800024f2:	e822                	sd	s0,16(sp)
    800024f4:	e426                	sd	s1,8(sp)
    800024f6:	e04a                	sd	s2,0(sp)
    800024f8:	1000                	addi	s0,sp,32
    800024fa:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	760080e7          	jalr	1888(ra) # 80000c5c <acquire>
  k = p->killed;
    80002504:	549c                	lw	a5,40(s1)
    80002506:	893e                	mv	s2,a5
  release(&p->lock);
    80002508:	8526                	mv	a0,s1
    8000250a:	fffff097          	auipc	ra,0xfffff
    8000250e:	802080e7          	jalr	-2046(ra) # 80000d0c <release>
  return k;
}
    80002512:	854a                	mv	a0,s2
    80002514:	60e2                	ld	ra,24(sp)
    80002516:	6442                	ld	s0,16(sp)
    80002518:	64a2                	ld	s1,8(sp)
    8000251a:	6902                	ld	s2,0(sp)
    8000251c:	6105                	addi	sp,sp,32
    8000251e:	8082                	ret

0000000080002520 <wait>:
{
    80002520:	715d                	addi	sp,sp,-80
    80002522:	e486                	sd	ra,72(sp)
    80002524:	e0a2                	sd	s0,64(sp)
    80002526:	fc26                	sd	s1,56(sp)
    80002528:	f84a                	sd	s2,48(sp)
    8000252a:	f44e                	sd	s3,40(sp)
    8000252c:	f052                	sd	s4,32(sp)
    8000252e:	ec56                	sd	s5,24(sp)
    80002530:	e85a                	sd	s6,16(sp)
    80002532:	e45e                	sd	s7,8(sp)
    80002534:	0880                	addi	s0,sp,80
    80002536:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	5c8080e7          	jalr	1480(ra) # 80001b00 <myproc>
    80002540:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002542:	0000e517          	auipc	a0,0xe
    80002546:	60650513          	addi	a0,a0,1542 # 80010b48 <wait_lock>
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	712080e7          	jalr	1810(ra) # 80000c5c <acquire>
        if(pp->state == ZOMBIE){
    80002552:	4a15                	li	s4,5
        havekids = 1;
    80002554:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002556:	00015997          	auipc	s3,0x15
    8000255a:	80a98993          	addi	s3,s3,-2038 # 80016d60 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000255e:	0000eb17          	auipc	s6,0xe
    80002562:	5eab0b13          	addi	s6,s6,1514 # 80010b48 <wait_lock>
    80002566:	a0c9                	j	80002628 <wait+0x108>
          pid = pp->pid;
    80002568:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000256c:	000b8e63          	beqz	s7,80002588 <wait+0x68>
    80002570:	4691                	li	a3,4
    80002572:	02c48613          	addi	a2,s1,44
    80002576:	85de                	mv	a1,s7
    80002578:	05093503          	ld	a0,80(s2)
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	19c080e7          	jalr	412(ra) # 80001718 <copyout>
    80002584:	04054063          	bltz	a0,800025c4 <wait+0xa4>
          freeproc(pp);
    80002588:	8526                	mv	a0,s1
    8000258a:	fffff097          	auipc	ra,0xfffff
    8000258e:	72a080e7          	jalr	1834(ra) # 80001cb4 <freeproc>
          release(&pp->lock);
    80002592:	8526                	mv	a0,s1
    80002594:	ffffe097          	auipc	ra,0xffffe
    80002598:	778080e7          	jalr	1912(ra) # 80000d0c <release>
          release(&wait_lock);
    8000259c:	0000e517          	auipc	a0,0xe
    800025a0:	5ac50513          	addi	a0,a0,1452 # 80010b48 <wait_lock>
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	768080e7          	jalr	1896(ra) # 80000d0c <release>
}
    800025ac:	854e                	mv	a0,s3
    800025ae:	60a6                	ld	ra,72(sp)
    800025b0:	6406                	ld	s0,64(sp)
    800025b2:	74e2                	ld	s1,56(sp)
    800025b4:	7942                	ld	s2,48(sp)
    800025b6:	79a2                	ld	s3,40(sp)
    800025b8:	7a02                	ld	s4,32(sp)
    800025ba:	6ae2                	ld	s5,24(sp)
    800025bc:	6b42                	ld	s6,16(sp)
    800025be:	6ba2                	ld	s7,8(sp)
    800025c0:	6161                	addi	sp,sp,80
    800025c2:	8082                	ret
            release(&pp->lock);
    800025c4:	8526                	mv	a0,s1
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	746080e7          	jalr	1862(ra) # 80000d0c <release>
            release(&wait_lock);
    800025ce:	0000e517          	auipc	a0,0xe
    800025d2:	57a50513          	addi	a0,a0,1402 # 80010b48 <wait_lock>
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	736080e7          	jalr	1846(ra) # 80000d0c <release>
            return -1;
    800025de:	59fd                	li	s3,-1
    800025e0:	b7f1                	j	800025ac <wait+0x8c>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025e2:	17848493          	addi	s1,s1,376
    800025e6:	03348463          	beq	s1,s3,8000260e <wait+0xee>
      if(pp->parent == p){
    800025ea:	7c9c                	ld	a5,56(s1)
    800025ec:	ff279be3          	bne	a5,s2,800025e2 <wait+0xc2>
        acquire(&pp->lock);
    800025f0:	8526                	mv	a0,s1
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	66a080e7          	jalr	1642(ra) # 80000c5c <acquire>
        if(pp->state == ZOMBIE){
    800025fa:	4c9c                	lw	a5,24(s1)
    800025fc:	f74786e3          	beq	a5,s4,80002568 <wait+0x48>
        release(&pp->lock);
    80002600:	8526                	mv	a0,s1
    80002602:	ffffe097          	auipc	ra,0xffffe
    80002606:	70a080e7          	jalr	1802(ra) # 80000d0c <release>
        havekids = 1;
    8000260a:	8756                	mv	a4,s5
    8000260c:	bfd9                	j	800025e2 <wait+0xc2>
    if(!havekids || killed(p)){
    8000260e:	c31d                	beqz	a4,80002634 <wait+0x114>
    80002610:	854a                	mv	a0,s2
    80002612:	00000097          	auipc	ra,0x0
    80002616:	edc080e7          	jalr	-292(ra) # 800024ee <killed>
    8000261a:	ed09                	bnez	a0,80002634 <wait+0x114>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000261c:	85da                	mv	a1,s6
    8000261e:	854a                	mv	a0,s2
    80002620:	00000097          	auipc	ra,0x0
    80002624:	c06080e7          	jalr	-1018(ra) # 80002226 <sleep>
    havekids = 0;
    80002628:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000262a:	0000f497          	auipc	s1,0xf
    8000262e:	93648493          	addi	s1,s1,-1738 # 80010f60 <proc>
    80002632:	bf65                	j	800025ea <wait+0xca>
      release(&wait_lock);
    80002634:	0000e517          	auipc	a0,0xe
    80002638:	51450513          	addi	a0,a0,1300 # 80010b48 <wait_lock>
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	6d0080e7          	jalr	1744(ra) # 80000d0c <release>
      return -1;
    80002644:	59fd                	li	s3,-1
    80002646:	b79d                	j	800025ac <wait+0x8c>

0000000080002648 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002648:	7179                	addi	sp,sp,-48
    8000264a:	f406                	sd	ra,40(sp)
    8000264c:	f022                	sd	s0,32(sp)
    8000264e:	ec26                	sd	s1,24(sp)
    80002650:	e84a                	sd	s2,16(sp)
    80002652:	e44e                	sd	s3,8(sp)
    80002654:	e052                	sd	s4,0(sp)
    80002656:	1800                	addi	s0,sp,48
    80002658:	84aa                	mv	s1,a0
    8000265a:	8a2e                	mv	s4,a1
    8000265c:	89b2                	mv	s3,a2
    8000265e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002660:	fffff097          	auipc	ra,0xfffff
    80002664:	4a0080e7          	jalr	1184(ra) # 80001b00 <myproc>
  if(user_dst){
    80002668:	c08d                	beqz	s1,8000268a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000266a:	86ca                	mv	a3,s2
    8000266c:	864e                	mv	a2,s3
    8000266e:	85d2                	mv	a1,s4
    80002670:	6928                	ld	a0,80(a0)
    80002672:	fffff097          	auipc	ra,0xfffff
    80002676:	0a6080e7          	jalr	166(ra) # 80001718 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000267a:	70a2                	ld	ra,40(sp)
    8000267c:	7402                	ld	s0,32(sp)
    8000267e:	64e2                	ld	s1,24(sp)
    80002680:	6942                	ld	s2,16(sp)
    80002682:	69a2                	ld	s3,8(sp)
    80002684:	6a02                	ld	s4,0(sp)
    80002686:	6145                	addi	sp,sp,48
    80002688:	8082                	ret
    memmove((char *)dst, src, len);
    8000268a:	0009061b          	sext.w	a2,s2
    8000268e:	85ce                	mv	a1,s3
    80002690:	8552                	mv	a0,s4
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	722080e7          	jalr	1826(ra) # 80000db4 <memmove>
    return 0;
    8000269a:	8526                	mv	a0,s1
    8000269c:	bff9                	j	8000267a <either_copyout+0x32>

000000008000269e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000269e:	7179                	addi	sp,sp,-48
    800026a0:	f406                	sd	ra,40(sp)
    800026a2:	f022                	sd	s0,32(sp)
    800026a4:	ec26                	sd	s1,24(sp)
    800026a6:	e84a                	sd	s2,16(sp)
    800026a8:	e44e                	sd	s3,8(sp)
    800026aa:	e052                	sd	s4,0(sp)
    800026ac:	1800                	addi	s0,sp,48
    800026ae:	8a2a                	mv	s4,a0
    800026b0:	84ae                	mv	s1,a1
    800026b2:	89b2                	mv	s3,a2
    800026b4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800026b6:	fffff097          	auipc	ra,0xfffff
    800026ba:	44a080e7          	jalr	1098(ra) # 80001b00 <myproc>
  if(user_src){
    800026be:	c08d                	beqz	s1,800026e0 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800026c0:	86ca                	mv	a3,s2
    800026c2:	864e                	mv	a2,s3
    800026c4:	85d2                	mv	a1,s4
    800026c6:	6928                	ld	a0,80(a0)
    800026c8:	fffff097          	auipc	ra,0xfffff
    800026cc:	0dc080e7          	jalr	220(ra) # 800017a4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026d0:	70a2                	ld	ra,40(sp)
    800026d2:	7402                	ld	s0,32(sp)
    800026d4:	64e2                	ld	s1,24(sp)
    800026d6:	6942                	ld	s2,16(sp)
    800026d8:	69a2                	ld	s3,8(sp)
    800026da:	6a02                	ld	s4,0(sp)
    800026dc:	6145                	addi	sp,sp,48
    800026de:	8082                	ret
    memmove(dst, (char*)src, len);
    800026e0:	0009061b          	sext.w	a2,s2
    800026e4:	85ce                	mv	a1,s3
    800026e6:	8552                	mv	a0,s4
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	6cc080e7          	jalr	1740(ra) # 80000db4 <memmove>
    return 0;
    800026f0:	8526                	mv	a0,s1
    800026f2:	bff9                	j	800026d0 <either_copyin+0x32>

00000000800026f4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800026f4:	715d                	addi	sp,sp,-80
    800026f6:	e486                	sd	ra,72(sp)
    800026f8:	e0a2                	sd	s0,64(sp)
    800026fa:	fc26                	sd	s1,56(sp)
    800026fc:	f84a                	sd	s2,48(sp)
    800026fe:	f44e                	sd	s3,40(sp)
    80002700:	f052                	sd	s4,32(sp)
    80002702:	ec56                	sd	s5,24(sp)
    80002704:	e85a                	sd	s6,16(sp)
    80002706:	e45e                	sd	s7,8(sp)
    80002708:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000270a:	00006517          	auipc	a0,0x6
    8000270e:	90650513          	addi	a0,a0,-1786 # 80008010 <etext+0x10>
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	e96080e7          	jalr	-362(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000271a:	0000f497          	auipc	s1,0xf
    8000271e:	99e48493          	addi	s1,s1,-1634 # 800110b8 <proc+0x158>
    80002722:	00014917          	auipc	s2,0x14
    80002726:	79690913          	addi	s2,s2,1942 # 80016eb8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000272a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000272c:	00006997          	auipc	s3,0x6
    80002730:	b3498993          	addi	s3,s3,-1228 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002734:	00006a97          	auipc	s5,0x6
    80002738:	b34a8a93          	addi	s5,s5,-1228 # 80008268 <etext+0x268>
    printf("\n");
    8000273c:	00006a17          	auipc	s4,0x6
    80002740:	8d4a0a13          	addi	s4,s4,-1836 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002744:	00006b97          	auipc	s7,0x6
    80002748:	ffcb8b93          	addi	s7,s7,-4 # 80008740 <states.0>
    8000274c:	a00d                	j	8000276e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000274e:	ed86a583          	lw	a1,-296(a3)
    80002752:	8556                	mv	a0,s5
    80002754:	ffffe097          	auipc	ra,0xffffe
    80002758:	e54080e7          	jalr	-428(ra) # 800005a8 <printf>
    printf("\n");
    8000275c:	8552                	mv	a0,s4
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	e4a080e7          	jalr	-438(ra) # 800005a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002766:	17848493          	addi	s1,s1,376
    8000276a:	03248263          	beq	s1,s2,8000278e <procdump+0x9a>
    if(p->state == UNUSED)
    8000276e:	86a6                	mv	a3,s1
    80002770:	ec04a783          	lw	a5,-320(s1)
    80002774:	dbed                	beqz	a5,80002766 <procdump+0x72>
      state = "???";
    80002776:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002778:	fcfb6be3          	bltu	s6,a5,8000274e <procdump+0x5a>
    8000277c:	02079713          	slli	a4,a5,0x20
    80002780:	01d75793          	srli	a5,a4,0x1d
    80002784:	97de                	add	a5,a5,s7
    80002786:	6390                	ld	a2,0(a5)
    80002788:	f279                	bnez	a2,8000274e <procdump+0x5a>
      state = "???";
    8000278a:	864e                	mv	a2,s3
    8000278c:	b7c9                	j	8000274e <procdump+0x5a>
  }
    8000278e:	60a6                	ld	ra,72(sp)
    80002790:	6406                	ld	s0,64(sp)
    80002792:	74e2                	ld	s1,56(sp)
    80002794:	7942                	ld	s2,48(sp)
    80002796:	79a2                	ld	s3,40(sp)
    80002798:	7a02                	ld	s4,32(sp)
    8000279a:	6ae2                	ld	s5,24(sp)
    8000279c:	6b42                	ld	s6,16(sp)
    8000279e:	6ba2                	ld	s7,8(sp)
    800027a0:	6161                	addi	sp,sp,80
    800027a2:	8082                	ret

00000000800027a4 <swtch>:
    800027a4:	00153023          	sd	ra,0(a0)
    800027a8:	00253423          	sd	sp,8(a0)
    800027ac:	e900                	sd	s0,16(a0)
    800027ae:	ed04                	sd	s1,24(a0)
    800027b0:	03253023          	sd	s2,32(a0)
    800027b4:	03353423          	sd	s3,40(a0)
    800027b8:	03453823          	sd	s4,48(a0)
    800027bc:	03553c23          	sd	s5,56(a0)
    800027c0:	05653023          	sd	s6,64(a0)
    800027c4:	05753423          	sd	s7,72(a0)
    800027c8:	05853823          	sd	s8,80(a0)
    800027cc:	05953c23          	sd	s9,88(a0)
    800027d0:	07a53023          	sd	s10,96(a0)
    800027d4:	07b53423          	sd	s11,104(a0)
    800027d8:	0005b083          	ld	ra,0(a1)
    800027dc:	0085b103          	ld	sp,8(a1)
    800027e0:	6980                	ld	s0,16(a1)
    800027e2:	6d84                	ld	s1,24(a1)
    800027e4:	0205b903          	ld	s2,32(a1)
    800027e8:	0285b983          	ld	s3,40(a1)
    800027ec:	0305ba03          	ld	s4,48(a1)
    800027f0:	0385ba83          	ld	s5,56(a1)
    800027f4:	0405bb03          	ld	s6,64(a1)
    800027f8:	0485bb83          	ld	s7,72(a1)
    800027fc:	0505bc03          	ld	s8,80(a1)
    80002800:	0585bc83          	ld	s9,88(a1)
    80002804:	0605bd03          	ld	s10,96(a1)
    80002808:	0685bd83          	ld	s11,104(a1)
    8000280c:	8082                	ret

000000008000280e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000280e:	1141                	addi	sp,sp,-16
    80002810:	e406                	sd	ra,8(sp)
    80002812:	e022                	sd	s0,0(sp)
    80002814:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002816:	00006597          	auipc	a1,0x6
    8000281a:	a9258593          	addi	a1,a1,-1390 # 800082a8 <etext+0x2a8>
    8000281e:	00014517          	auipc	a0,0x14
    80002822:	54250513          	addi	a0,a0,1346 # 80016d60 <tickslock>
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	39c080e7          	jalr	924(ra) # 80000bc2 <initlock>
}
    8000282e:	60a2                	ld	ra,8(sp)
    80002830:	6402                	ld	s0,0(sp)
    80002832:	0141                	addi	sp,sp,16
    80002834:	8082                	ret

0000000080002836 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002836:	1141                	addi	sp,sp,-16
    80002838:	e406                	sd	ra,8(sp)
    8000283a:	e022                	sd	s0,0(sp)
    8000283c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000283e:	00003797          	auipc	a5,0x3
    80002842:	67278793          	addi	a5,a5,1650 # 80005eb0 <kernelvec>
    80002846:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000284a:	60a2                	ld	ra,8(sp)
    8000284c:	6402                	ld	s0,0(sp)
    8000284e:	0141                	addi	sp,sp,16
    80002850:	8082                	ret

0000000080002852 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002852:	1141                	addi	sp,sp,-16
    80002854:	e406                	sd	ra,8(sp)
    80002856:	e022                	sd	s0,0(sp)
    80002858:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000285a:	fffff097          	auipc	ra,0xfffff
    8000285e:	2a6080e7          	jalr	678(ra) # 80001b00 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002862:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002866:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002868:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000286c:	00004697          	auipc	a3,0x4
    80002870:	79468693          	addi	a3,a3,1940 # 80007000 <_trampoline>
    80002874:	00004717          	auipc	a4,0x4
    80002878:	78c70713          	addi	a4,a4,1932 # 80007000 <_trampoline>
    8000287c:	8f15                	sub	a4,a4,a3
    8000287e:	040007b7          	lui	a5,0x4000
    80002882:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002884:	07b2                	slli	a5,a5,0xc
    80002886:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002888:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000288c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000288e:	18002673          	csrr	a2,satp
    80002892:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002894:	6d30                	ld	a2,88(a0)
    80002896:	6138                	ld	a4,64(a0)
    80002898:	6585                	lui	a1,0x1
    8000289a:	972e                	add	a4,a4,a1
    8000289c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000289e:	6d38                	ld	a4,88(a0)
    800028a0:	00000617          	auipc	a2,0x0
    800028a4:	13c60613          	addi	a2,a2,316 # 800029dc <usertrap>
    800028a8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028aa:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028ac:	8612                	mv	a2,tp
    800028ae:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028b4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028b8:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028bc:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028c0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028c2:	6f18                	ld	a4,24(a4)
    800028c4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028c8:	6928                	ld	a0,80(a0)
    800028ca:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028cc:	00004717          	auipc	a4,0x4
    800028d0:	7d070713          	addi	a4,a4,2000 # 8000709c <userret>
    800028d4:	8f15                	sub	a4,a4,a3
    800028d6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028d8:	577d                	li	a4,-1
    800028da:	177e                	slli	a4,a4,0x3f
    800028dc:	8d59                	or	a0,a0,a4
    800028de:	9782                	jalr	a5
}
    800028e0:	60a2                	ld	ra,8(sp)
    800028e2:	6402                	ld	s0,0(sp)
    800028e4:	0141                	addi	sp,sp,16
    800028e6:	8082                	ret

00000000800028e8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028e8:	1141                	addi	sp,sp,-16
    800028ea:	e406                	sd	ra,8(sp)
    800028ec:	e022                	sd	s0,0(sp)
    800028ee:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    800028f0:	00014517          	auipc	a0,0x14
    800028f4:	47050513          	addi	a0,a0,1136 # 80016d60 <tickslock>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	364080e7          	jalr	868(ra) # 80000c5c <acquire>
  ticks++;
    80002900:	00006717          	auipc	a4,0x6
    80002904:	fc070713          	addi	a4,a4,-64 # 800088c0 <ticks>
    80002908:	431c                	lw	a5,0(a4)
    8000290a:	2785                	addiw	a5,a5,1
    8000290c:	c31c                	sw	a5,0(a4)
  wakeup(&ticks);
    8000290e:	853a                	mv	a0,a4
    80002910:	00000097          	auipc	ra,0x0
    80002914:	97a080e7          	jalr	-1670(ra) # 8000228a <wakeup>
  release(&tickslock);
    80002918:	00014517          	auipc	a0,0x14
    8000291c:	44850513          	addi	a0,a0,1096 # 80016d60 <tickslock>
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	3ec080e7          	jalr	1004(ra) # 80000d0c <release>
}
    80002928:	60a2                	ld	ra,8(sp)
    8000292a:	6402                	ld	s0,0(sp)
    8000292c:	0141                	addi	sp,sp,16
    8000292e:	8082                	ret

0000000080002930 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002930:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002934:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002936:	0a07d263          	bgez	a5,800029da <devintr+0xaa>
{
    8000293a:	1101                	addi	sp,sp,-32
    8000293c:	ec06                	sd	ra,24(sp)
    8000293e:	e822                	sd	s0,16(sp)
    80002940:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002942:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002946:	46a5                	li	a3,9
    80002948:	00d70c63          	beq	a4,a3,80002960 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    8000294c:	577d                	li	a4,-1
    8000294e:	177e                	slli	a4,a4,0x3f
    80002950:	0705                	addi	a4,a4,1
    return 0;
    80002952:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002954:	06e78263          	beq	a5,a4,800029b8 <devintr+0x88>
  }
}
    80002958:	60e2                	ld	ra,24(sp)
    8000295a:	6442                	ld	s0,16(sp)
    8000295c:	6105                	addi	sp,sp,32
    8000295e:	8082                	ret
    80002960:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002962:	00003097          	auipc	ra,0x3
    80002966:	65a080e7          	jalr	1626(ra) # 80005fbc <plic_claim>
    8000296a:	872a                	mv	a4,a0
    8000296c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000296e:	47a9                	li	a5,10
    80002970:	00f50963          	beq	a0,a5,80002982 <devintr+0x52>
    } else if(irq == VIRTIO0_IRQ){
    80002974:	4785                	li	a5,1
    80002976:	00f50b63          	beq	a0,a5,8000298c <devintr+0x5c>
    return 1;
    8000297a:	4505                	li	a0,1
    } else if(irq){
    8000297c:	ef09                	bnez	a4,80002996 <devintr+0x66>
    8000297e:	64a2                	ld	s1,8(sp)
    80002980:	bfe1                	j	80002958 <devintr+0x28>
      uartintr();
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	07e080e7          	jalr	126(ra) # 80000a00 <uartintr>
    if(irq)
    8000298a:	a839                	j	800029a8 <devintr+0x78>
      virtio_disk_intr();
    8000298c:	00004097          	auipc	ra,0x4
    80002990:	b2a080e7          	jalr	-1238(ra) # 800064b6 <virtio_disk_intr>
    if(irq)
    80002994:	a811                	j	800029a8 <devintr+0x78>
      printf("unexpected interrupt irq=%d\n", irq);
    80002996:	85ba                	mv	a1,a4
    80002998:	00006517          	auipc	a0,0x6
    8000299c:	91850513          	addi	a0,a0,-1768 # 800082b0 <etext+0x2b0>
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	c08080e7          	jalr	-1016(ra) # 800005a8 <printf>
      plic_complete(irq);
    800029a8:	8526                	mv	a0,s1
    800029aa:	00003097          	auipc	ra,0x3
    800029ae:	636080e7          	jalr	1590(ra) # 80005fe0 <plic_complete>
    return 1;
    800029b2:	4505                	li	a0,1
    800029b4:	64a2                	ld	s1,8(sp)
    800029b6:	b74d                	j	80002958 <devintr+0x28>
    if(cpuid() == 0){
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	114080e7          	jalr	276(ra) # 80001acc <cpuid>
    800029c0:	c901                	beqz	a0,800029d0 <devintr+0xa0>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029c2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029c8:	14479073          	csrw	sip,a5
    return 2;
    800029cc:	4509                	li	a0,2
    800029ce:	b769                	j	80002958 <devintr+0x28>
      clockintr();
    800029d0:	00000097          	auipc	ra,0x0
    800029d4:	f18080e7          	jalr	-232(ra) # 800028e8 <clockintr>
    800029d8:	b7ed                	j	800029c2 <devintr+0x92>
}
    800029da:	8082                	ret

00000000800029dc <usertrap>:
{
    800029dc:	1101                	addi	sp,sp,-32
    800029de:	ec06                	sd	ra,24(sp)
    800029e0:	e822                	sd	s0,16(sp)
    800029e2:	e426                	sd	s1,8(sp)
    800029e4:	e04a                	sd	s2,0(sp)
    800029e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029ec:	1007f793          	andi	a5,a5,256
    800029f0:	e3b1                	bnez	a5,80002a34 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f2:	00003797          	auipc	a5,0x3
    800029f6:	4be78793          	addi	a5,a5,1214 # 80005eb0 <kernelvec>
    800029fa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029fe:	fffff097          	auipc	ra,0xfffff
    80002a02:	102080e7          	jalr	258(ra) # 80001b00 <myproc>
    80002a06:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a08:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a0a:	14102773          	csrr	a4,sepc
    80002a0e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a10:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a14:	47a1                	li	a5,8
    80002a16:	02f70763          	beq	a4,a5,80002a44 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a1a:	00000097          	auipc	ra,0x0
    80002a1e:	f16080e7          	jalr	-234(ra) # 80002930 <devintr>
    80002a22:	892a                	mv	s2,a0
    80002a24:	c151                	beqz	a0,80002aa8 <usertrap+0xcc>
  if(killed(p))
    80002a26:	8526                	mv	a0,s1
    80002a28:	00000097          	auipc	ra,0x0
    80002a2c:	ac6080e7          	jalr	-1338(ra) # 800024ee <killed>
    80002a30:	c929                	beqz	a0,80002a82 <usertrap+0xa6>
    80002a32:	a099                	j	80002a78 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002a34:	00006517          	auipc	a0,0x6
    80002a38:	89c50513          	addi	a0,a0,-1892 # 800082d0 <etext+0x2d0>
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	b22080e7          	jalr	-1246(ra) # 8000055e <panic>
    if(killed(p))
    80002a44:	00000097          	auipc	ra,0x0
    80002a48:	aaa080e7          	jalr	-1366(ra) # 800024ee <killed>
    80002a4c:	e921                	bnez	a0,80002a9c <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002a4e:	6cb8                	ld	a4,88(s1)
    80002a50:	6f1c                	ld	a5,24(a4)
    80002a52:	0791                	addi	a5,a5,4
    80002a54:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a5e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	2f0080e7          	jalr	752(ra) # 80002d52 <syscall>
  if(killed(p))
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	00000097          	auipc	ra,0x0
    80002a70:	a82080e7          	jalr	-1406(ra) # 800024ee <killed>
    80002a74:	c911                	beqz	a0,80002a88 <usertrap+0xac>
    80002a76:	4901                	li	s2,0
    exit(-1);
    80002a78:	557d                	li	a0,-1
    80002a7a:	00000097          	auipc	ra,0x0
    80002a7e:	8fc080e7          	jalr	-1796(ra) # 80002376 <exit>
  if(which_dev == 2){
    80002a82:	4789                	li	a5,2
    80002a84:	04f90f63          	beq	s2,a5,80002ae2 <usertrap+0x106>
  usertrapret();
    80002a88:	00000097          	auipc	ra,0x0
    80002a8c:	dca080e7          	jalr	-566(ra) # 80002852 <usertrapret>
}
    80002a90:	60e2                	ld	ra,24(sp)
    80002a92:	6442                	ld	s0,16(sp)
    80002a94:	64a2                	ld	s1,8(sp)
    80002a96:	6902                	ld	s2,0(sp)
    80002a98:	6105                	addi	sp,sp,32
    80002a9a:	8082                	ret
      exit(-1);
    80002a9c:	557d                	li	a0,-1
    80002a9e:	00000097          	auipc	ra,0x0
    80002aa2:	8d8080e7          	jalr	-1832(ra) # 80002376 <exit>
    80002aa6:	b765                	j	80002a4e <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002aac:	5890                	lw	a2,48(s1)
    80002aae:	00006517          	auipc	a0,0x6
    80002ab2:	84250513          	addi	a0,a0,-1982 # 800082f0 <etext+0x2f0>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	af2080e7          	jalr	-1294(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002abe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ac2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ac6:	00006517          	auipc	a0,0x6
    80002aca:	85a50513          	addi	a0,a0,-1958 # 80008320 <etext+0x320>
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	ada080e7          	jalr	-1318(ra) # 800005a8 <printf>
    setkilled(p);
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	00000097          	auipc	ra,0x0
    80002adc:	9ea080e7          	jalr	-1558(ra) # 800024c2 <setkilled>
    80002ae0:	b769                	j	80002a6a <usertrap+0x8e>
    acquire(&p->lock);      
    80002ae2:	8526                	mv	a0,s1
    80002ae4:	ffffe097          	auipc	ra,0xffffe
    80002ae8:	178080e7          	jalr	376(ra) # 80000c5c <acquire>
    p->accumulator += p->ps_priority;
    80002aec:	1704a703          	lw	a4,368(s1)
    80002af0:	1684b783          	ld	a5,360(s1)
    80002af4:	97ba                	add	a5,a5,a4
    80002af6:	16f4b423          	sd	a5,360(s1)
    release(&p->lock);
    80002afa:	8526                	mv	a0,s1
    80002afc:	ffffe097          	auipc	ra,0xffffe
    80002b00:	210080e7          	jalr	528(ra) # 80000d0c <release>
    yield();
    80002b04:	fffff097          	auipc	ra,0xfffff
    80002b08:	6e6080e7          	jalr	1766(ra) # 800021ea <yield>
    80002b0c:	bfb5                	j	80002a88 <usertrap+0xac>

0000000080002b0e <kerneltrap>:
{
    80002b0e:	7179                	addi	sp,sp,-48
    80002b10:	f406                	sd	ra,40(sp)
    80002b12:	f022                	sd	s0,32(sp)
    80002b14:	ec26                	sd	s1,24(sp)
    80002b16:	e84a                	sd	s2,16(sp)
    80002b18:	e44e                	sd	s3,8(sp)
    80002b1a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b1c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b20:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b24:	142027f3          	csrr	a5,scause
    80002b28:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002b2a:	1004f793          	andi	a5,s1,256
    80002b2e:	cb85                	beqz	a5,80002b5e <kerneltrap+0x50>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b30:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b34:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b36:	ef85                	bnez	a5,80002b6e <kerneltrap+0x60>
  if((which_dev = devintr()) == 0){
    80002b38:	00000097          	auipc	ra,0x0
    80002b3c:	df8080e7          	jalr	-520(ra) # 80002930 <devintr>
    80002b40:	cd1d                	beqz	a0,80002b7e <kerneltrap+0x70>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b42:	4789                	li	a5,2
    80002b44:	06f50a63          	beq	a0,a5,80002bb8 <kerneltrap+0xaa>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b48:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b4c:	10049073          	csrw	sstatus,s1
}
    80002b50:	70a2                	ld	ra,40(sp)
    80002b52:	7402                	ld	s0,32(sp)
    80002b54:	64e2                	ld	s1,24(sp)
    80002b56:	6942                	ld	s2,16(sp)
    80002b58:	69a2                	ld	s3,8(sp)
    80002b5a:	6145                	addi	sp,sp,48
    80002b5c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b5e:	00005517          	auipc	a0,0x5
    80002b62:	7e250513          	addi	a0,a0,2018 # 80008340 <etext+0x340>
    80002b66:	ffffe097          	auipc	ra,0xffffe
    80002b6a:	9f8080e7          	jalr	-1544(ra) # 8000055e <panic>
    panic("kerneltrap: interrupts enabled");
    80002b6e:	00005517          	auipc	a0,0x5
    80002b72:	7fa50513          	addi	a0,a0,2042 # 80008368 <etext+0x368>
    80002b76:	ffffe097          	auipc	ra,0xffffe
    80002b7a:	9e8080e7          	jalr	-1560(ra) # 8000055e <panic>
    printf("scause %p\n", scause);
    80002b7e:	85ce                	mv	a1,s3
    80002b80:	00006517          	auipc	a0,0x6
    80002b84:	80850513          	addi	a0,a0,-2040 # 80008388 <etext+0x388>
    80002b88:	ffffe097          	auipc	ra,0xffffe
    80002b8c:	a20080e7          	jalr	-1504(ra) # 800005a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b90:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b94:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b98:	00006517          	auipc	a0,0x6
    80002b9c:	80050513          	addi	a0,a0,-2048 # 80008398 <etext+0x398>
    80002ba0:	ffffe097          	auipc	ra,0xffffe
    80002ba4:	a08080e7          	jalr	-1528(ra) # 800005a8 <printf>
    panic("kerneltrap");
    80002ba8:	00006517          	auipc	a0,0x6
    80002bac:	80850513          	addi	a0,a0,-2040 # 800083b0 <etext+0x3b0>
    80002bb0:	ffffe097          	auipc	ra,0xffffe
    80002bb4:	9ae080e7          	jalr	-1618(ra) # 8000055e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bb8:	fffff097          	auipc	ra,0xfffff
    80002bbc:	f48080e7          	jalr	-184(ra) # 80001b00 <myproc>
    80002bc0:	d541                	beqz	a0,80002b48 <kerneltrap+0x3a>
    80002bc2:	fffff097          	auipc	ra,0xfffff
    80002bc6:	f3e080e7          	jalr	-194(ra) # 80001b00 <myproc>
    80002bca:	4d18                	lw	a4,24(a0)
    80002bcc:	4791                	li	a5,4
    80002bce:	f6f71de3          	bne	a4,a5,80002b48 <kerneltrap+0x3a>
    yield();
    80002bd2:	fffff097          	auipc	ra,0xfffff
    80002bd6:	618080e7          	jalr	1560(ra) # 800021ea <yield>
    80002bda:	b7bd                	j	80002b48 <kerneltrap+0x3a>

0000000080002bdc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bdc:	1101                	addi	sp,sp,-32
    80002bde:	ec06                	sd	ra,24(sp)
    80002be0:	e822                	sd	s0,16(sp)
    80002be2:	e426                	sd	s1,8(sp)
    80002be4:	1000                	addi	s0,sp,32
    80002be6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	f18080e7          	jalr	-232(ra) # 80001b00 <myproc>
  switch (n) {
    80002bf0:	4795                	li	a5,5
    80002bf2:	0497e163          	bltu	a5,s1,80002c34 <argraw+0x58>
    80002bf6:	048a                	slli	s1,s1,0x2
    80002bf8:	00006717          	auipc	a4,0x6
    80002bfc:	b7870713          	addi	a4,a4,-1160 # 80008770 <states.0+0x30>
    80002c00:	94ba                	add	s1,s1,a4
    80002c02:	409c                	lw	a5,0(s1)
    80002c04:	97ba                	add	a5,a5,a4
    80002c06:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c08:	6d3c                	ld	a5,88(a0)
    80002c0a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c0c:	60e2                	ld	ra,24(sp)
    80002c0e:	6442                	ld	s0,16(sp)
    80002c10:	64a2                	ld	s1,8(sp)
    80002c12:	6105                	addi	sp,sp,32
    80002c14:	8082                	ret
    return p->trapframe->a1;
    80002c16:	6d3c                	ld	a5,88(a0)
    80002c18:	7fa8                	ld	a0,120(a5)
    80002c1a:	bfcd                	j	80002c0c <argraw+0x30>
    return p->trapframe->a2;
    80002c1c:	6d3c                	ld	a5,88(a0)
    80002c1e:	63c8                	ld	a0,128(a5)
    80002c20:	b7f5                	j	80002c0c <argraw+0x30>
    return p->trapframe->a3;
    80002c22:	6d3c                	ld	a5,88(a0)
    80002c24:	67c8                	ld	a0,136(a5)
    80002c26:	b7dd                	j	80002c0c <argraw+0x30>
    return p->trapframe->a4;
    80002c28:	6d3c                	ld	a5,88(a0)
    80002c2a:	6bc8                	ld	a0,144(a5)
    80002c2c:	b7c5                	j	80002c0c <argraw+0x30>
    return p->trapframe->a5;
    80002c2e:	6d3c                	ld	a5,88(a0)
    80002c30:	6fc8                	ld	a0,152(a5)
    80002c32:	bfe9                	j	80002c0c <argraw+0x30>
  panic("argraw");
    80002c34:	00005517          	auipc	a0,0x5
    80002c38:	78c50513          	addi	a0,a0,1932 # 800083c0 <etext+0x3c0>
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	922080e7          	jalr	-1758(ra) # 8000055e <panic>

0000000080002c44 <fetchaddr>:
{
    80002c44:	1101                	addi	sp,sp,-32
    80002c46:	ec06                	sd	ra,24(sp)
    80002c48:	e822                	sd	s0,16(sp)
    80002c4a:	e426                	sd	s1,8(sp)
    80002c4c:	e04a                	sd	s2,0(sp)
    80002c4e:	1000                	addi	s0,sp,32
    80002c50:	84aa                	mv	s1,a0
    80002c52:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c54:	fffff097          	auipc	ra,0xfffff
    80002c58:	eac080e7          	jalr	-340(ra) # 80001b00 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c5c:	653c                	ld	a5,72(a0)
    80002c5e:	02f4f863          	bgeu	s1,a5,80002c8e <fetchaddr+0x4a>
    80002c62:	00848713          	addi	a4,s1,8
    80002c66:	02e7e663          	bltu	a5,a4,80002c92 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c6a:	46a1                	li	a3,8
    80002c6c:	8626                	mv	a2,s1
    80002c6e:	85ca                	mv	a1,s2
    80002c70:	6928                	ld	a0,80(a0)
    80002c72:	fffff097          	auipc	ra,0xfffff
    80002c76:	b32080e7          	jalr	-1230(ra) # 800017a4 <copyin>
    80002c7a:	00a03533          	snez	a0,a0
    80002c7e:	40a0053b          	negw	a0,a0
}
    80002c82:	60e2                	ld	ra,24(sp)
    80002c84:	6442                	ld	s0,16(sp)
    80002c86:	64a2                	ld	s1,8(sp)
    80002c88:	6902                	ld	s2,0(sp)
    80002c8a:	6105                	addi	sp,sp,32
    80002c8c:	8082                	ret
    return -1;
    80002c8e:	557d                	li	a0,-1
    80002c90:	bfcd                	j	80002c82 <fetchaddr+0x3e>
    80002c92:	557d                	li	a0,-1
    80002c94:	b7fd                	j	80002c82 <fetchaddr+0x3e>

0000000080002c96 <fetchstr>:
{
    80002c96:	7179                	addi	sp,sp,-48
    80002c98:	f406                	sd	ra,40(sp)
    80002c9a:	f022                	sd	s0,32(sp)
    80002c9c:	ec26                	sd	s1,24(sp)
    80002c9e:	e84a                	sd	s2,16(sp)
    80002ca0:	e44e                	sd	s3,8(sp)
    80002ca2:	1800                	addi	s0,sp,48
    80002ca4:	89aa                	mv	s3,a0
    80002ca6:	84ae                	mv	s1,a1
    80002ca8:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	e56080e7          	jalr	-426(ra) # 80001b00 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cb2:	86ca                	mv	a3,s2
    80002cb4:	864e                	mv	a2,s3
    80002cb6:	85a6                	mv	a1,s1
    80002cb8:	6928                	ld	a0,80(a0)
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	b78080e7          	jalr	-1160(ra) # 80001832 <copyinstr>
    80002cc2:	00054e63          	bltz	a0,80002cde <fetchstr+0x48>
  return strlen(buf);
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	21a080e7          	jalr	538(ra) # 80000ee2 <strlen>
}
    80002cd0:	70a2                	ld	ra,40(sp)
    80002cd2:	7402                	ld	s0,32(sp)
    80002cd4:	64e2                	ld	s1,24(sp)
    80002cd6:	6942                	ld	s2,16(sp)
    80002cd8:	69a2                	ld	s3,8(sp)
    80002cda:	6145                	addi	sp,sp,48
    80002cdc:	8082                	ret
    return -1;
    80002cde:	557d                	li	a0,-1
    80002ce0:	bfc5                	j	80002cd0 <fetchstr+0x3a>

0000000080002ce2 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ce2:	1101                	addi	sp,sp,-32
    80002ce4:	ec06                	sd	ra,24(sp)
    80002ce6:	e822                	sd	s0,16(sp)
    80002ce8:	e426                	sd	s1,8(sp)
    80002cea:	1000                	addi	s0,sp,32
    80002cec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cee:	00000097          	auipc	ra,0x0
    80002cf2:	eee080e7          	jalr	-274(ra) # 80002bdc <argraw>
    80002cf6:	c088                	sw	a0,0(s1)
}
    80002cf8:	60e2                	ld	ra,24(sp)
    80002cfa:	6442                	ld	s0,16(sp)
    80002cfc:	64a2                	ld	s1,8(sp)
    80002cfe:	6105                	addi	sp,sp,32
    80002d00:	8082                	ret

0000000080002d02 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d02:	1101                	addi	sp,sp,-32
    80002d04:	ec06                	sd	ra,24(sp)
    80002d06:	e822                	sd	s0,16(sp)
    80002d08:	e426                	sd	s1,8(sp)
    80002d0a:	1000                	addi	s0,sp,32
    80002d0c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d0e:	00000097          	auipc	ra,0x0
    80002d12:	ece080e7          	jalr	-306(ra) # 80002bdc <argraw>
    80002d16:	e088                	sd	a0,0(s1)
}
    80002d18:	60e2                	ld	ra,24(sp)
    80002d1a:	6442                	ld	s0,16(sp)
    80002d1c:	64a2                	ld	s1,8(sp)
    80002d1e:	6105                	addi	sp,sp,32
    80002d20:	8082                	ret

0000000080002d22 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d22:	1101                	addi	sp,sp,-32
    80002d24:	ec06                	sd	ra,24(sp)
    80002d26:	e822                	sd	s0,16(sp)
    80002d28:	e426                	sd	s1,8(sp)
    80002d2a:	e04a                	sd	s2,0(sp)
    80002d2c:	1000                	addi	s0,sp,32
    80002d2e:	892e                	mv	s2,a1
    80002d30:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002d32:	00000097          	auipc	ra,0x0
    80002d36:	eaa080e7          	jalr	-342(ra) # 80002bdc <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002d3a:	8626                	mv	a2,s1
    80002d3c:	85ca                	mv	a1,s2
    80002d3e:	00000097          	auipc	ra,0x0
    80002d42:	f58080e7          	jalr	-168(ra) # 80002c96 <fetchstr>
}
    80002d46:	60e2                	ld	ra,24(sp)
    80002d48:	6442                	ld	s0,16(sp)
    80002d4a:	64a2                	ld	s1,8(sp)
    80002d4c:	6902                	ld	s2,0(sp)
    80002d4e:	6105                	addi	sp,sp,32
    80002d50:	8082                	ret

0000000080002d52 <syscall>:
[SYS_set_ps_priority] sys_set_ps_priority,
};

void
syscall(void)
{
    80002d52:	1101                	addi	sp,sp,-32
    80002d54:	ec06                	sd	ra,24(sp)
    80002d56:	e822                	sd	s0,16(sp)
    80002d58:	e426                	sd	s1,8(sp)
    80002d5a:	e04a                	sd	s2,0(sp)
    80002d5c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	da2080e7          	jalr	-606(ra) # 80001b00 <myproc>
    80002d66:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d68:	05853903          	ld	s2,88(a0)
    80002d6c:	0a893783          	ld	a5,168(s2)
    80002d70:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d74:	37fd                	addiw	a5,a5,-1
    80002d76:	4755                	li	a4,21
    80002d78:	00f76f63          	bltu	a4,a5,80002d96 <syscall+0x44>
    80002d7c:	00369713          	slli	a4,a3,0x3
    80002d80:	00006797          	auipc	a5,0x6
    80002d84:	a0878793          	addi	a5,a5,-1528 # 80008788 <syscalls>
    80002d88:	97ba                	add	a5,a5,a4
    80002d8a:	639c                	ld	a5,0(a5)
    80002d8c:	c789                	beqz	a5,80002d96 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d8e:	9782                	jalr	a5
    80002d90:	06a93823          	sd	a0,112(s2)
    80002d94:	a839                	j	80002db2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d96:	15848613          	addi	a2,s1,344
    80002d9a:	588c                	lw	a1,48(s1)
    80002d9c:	00005517          	auipc	a0,0x5
    80002da0:	62c50513          	addi	a0,a0,1580 # 800083c8 <etext+0x3c8>
    80002da4:	ffffe097          	auipc	ra,0xffffe
    80002da8:	804080e7          	jalr	-2044(ra) # 800005a8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dac:	6cbc                	ld	a5,88(s1)
    80002dae:	577d                	li	a4,-1
    80002db0:	fbb8                	sd	a4,112(a5)
  }
}
    80002db2:	60e2                	ld	ra,24(sp)
    80002db4:	6442                	ld	s0,16(sp)
    80002db6:	64a2                	ld	s1,8(sp)
    80002db8:	6902                	ld	s2,0(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret

0000000080002dbe <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002dbe:	1101                	addi	sp,sp,-32
    80002dc0:	ec06                	sd	ra,24(sp)
    80002dc2:	e822                	sd	s0,16(sp)
    80002dc4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002dc6:	fec40593          	addi	a1,s0,-20
    80002dca:	4501                	li	a0,0
    80002dcc:	00000097          	auipc	ra,0x0
    80002dd0:	f16080e7          	jalr	-234(ra) # 80002ce2 <argint>
  exit(n);
    80002dd4:	fec42503          	lw	a0,-20(s0)
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	59e080e7          	jalr	1438(ra) # 80002376 <exit>
  return 0;  // not reached
}
    80002de0:	4501                	li	a0,0
    80002de2:	60e2                	ld	ra,24(sp)
    80002de4:	6442                	ld	s0,16(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret

0000000080002dea <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dea:	1141                	addi	sp,sp,-16
    80002dec:	e406                	sd	ra,8(sp)
    80002dee:	e022                	sd	s0,0(sp)
    80002df0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	d0e080e7          	jalr	-754(ra) # 80001b00 <myproc>
}
    80002dfa:	5908                	lw	a0,48(a0)
    80002dfc:	60a2                	ld	ra,8(sp)
    80002dfe:	6402                	ld	s0,0(sp)
    80002e00:	0141                	addi	sp,sp,16
    80002e02:	8082                	ret

0000000080002e04 <sys_fork>:

uint64
sys_fork(void)
{
    80002e04:	1141                	addi	sp,sp,-16
    80002e06:	e406                	sd	ra,8(sp)
    80002e08:	e022                	sd	s0,0(sp)
    80002e0a:	0800                	addi	s0,sp,16
  return fork();
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	0de080e7          	jalr	222(ra) # 80001eea <fork>
}
    80002e14:	60a2                	ld	ra,8(sp)
    80002e16:	6402                	ld	s0,0(sp)
    80002e18:	0141                	addi	sp,sp,16
    80002e1a:	8082                	ret

0000000080002e1c <sys_wait>:

uint64
sys_wait(void)
{
    80002e1c:	1101                	addi	sp,sp,-32
    80002e1e:	ec06                	sd	ra,24(sp)
    80002e20:	e822                	sd	s0,16(sp)
    80002e22:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e24:	fe840593          	addi	a1,s0,-24
    80002e28:	4501                	li	a0,0
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	ed8080e7          	jalr	-296(ra) # 80002d02 <argaddr>
  return wait(p);
    80002e32:	fe843503          	ld	a0,-24(s0)
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	6ea080e7          	jalr	1770(ra) # 80002520 <wait>
}
    80002e3e:	60e2                	ld	ra,24(sp)
    80002e40:	6442                	ld	s0,16(sp)
    80002e42:	6105                	addi	sp,sp,32
    80002e44:	8082                	ret

0000000080002e46 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e46:	7179                	addi	sp,sp,-48
    80002e48:	f406                	sd	ra,40(sp)
    80002e4a:	f022                	sd	s0,32(sp)
    80002e4c:	ec26                	sd	s1,24(sp)
    80002e4e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e50:	fdc40593          	addi	a1,s0,-36
    80002e54:	4501                	li	a0,0
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	e8c080e7          	jalr	-372(ra) # 80002ce2 <argint>
  addr = myproc()->sz;
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	ca2080e7          	jalr	-862(ra) # 80001b00 <myproc>
    80002e66:	653c                	ld	a5,72(a0)
    80002e68:	84be                	mv	s1,a5
  if(growproc(n) < 0)
    80002e6a:	fdc42503          	lw	a0,-36(s0)
    80002e6e:	fffff097          	auipc	ra,0xfffff
    80002e72:	020080e7          	jalr	32(ra) # 80001e8e <growproc>
    80002e76:	00054863          	bltz	a0,80002e86 <sys_sbrk+0x40>
    return -1;
  return addr;
}
    80002e7a:	8526                	mv	a0,s1
    80002e7c:	70a2                	ld	ra,40(sp)
    80002e7e:	7402                	ld	s0,32(sp)
    80002e80:	64e2                	ld	s1,24(sp)
    80002e82:	6145                	addi	sp,sp,48
    80002e84:	8082                	ret
    return -1;
    80002e86:	57fd                	li	a5,-1
    80002e88:	84be                	mv	s1,a5
    80002e8a:	bfc5                	j	80002e7a <sys_sbrk+0x34>

0000000080002e8c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e8c:	7139                	addi	sp,sp,-64
    80002e8e:	fc06                	sd	ra,56(sp)
    80002e90:	f822                	sd	s0,48(sp)
    80002e92:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e94:	fcc40593          	addi	a1,s0,-52
    80002e98:	4501                	li	a0,0
    80002e9a:	00000097          	auipc	ra,0x0
    80002e9e:	e48080e7          	jalr	-440(ra) # 80002ce2 <argint>
  acquire(&tickslock);
    80002ea2:	00014517          	auipc	a0,0x14
    80002ea6:	ebe50513          	addi	a0,a0,-322 # 80016d60 <tickslock>
    80002eaa:	ffffe097          	auipc	ra,0xffffe
    80002eae:	db2080e7          	jalr	-590(ra) # 80000c5c <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002eb2:	fcc42783          	lw	a5,-52(s0)
    80002eb6:	cba9                	beqz	a5,80002f08 <sys_sleep+0x7c>
    80002eb8:	f426                	sd	s1,40(sp)
    80002eba:	f04a                	sd	s2,32(sp)
    80002ebc:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002ebe:	00006997          	auipc	s3,0x6
    80002ec2:	a029a983          	lw	s3,-1534(s3) # 800088c0 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ec6:	00014917          	auipc	s2,0x14
    80002eca:	e9a90913          	addi	s2,s2,-358 # 80016d60 <tickslock>
    80002ece:	00006497          	auipc	s1,0x6
    80002ed2:	9f248493          	addi	s1,s1,-1550 # 800088c0 <ticks>
    if(killed(myproc())){
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	c2a080e7          	jalr	-982(ra) # 80001b00 <myproc>
    80002ede:	fffff097          	auipc	ra,0xfffff
    80002ee2:	610080e7          	jalr	1552(ra) # 800024ee <killed>
    80002ee6:	ed15                	bnez	a0,80002f22 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002ee8:	85ca                	mv	a1,s2
    80002eea:	8526                	mv	a0,s1
    80002eec:	fffff097          	auipc	ra,0xfffff
    80002ef0:	33a080e7          	jalr	826(ra) # 80002226 <sleep>
  while(ticks - ticks0 < n){
    80002ef4:	409c                	lw	a5,0(s1)
    80002ef6:	413787bb          	subw	a5,a5,s3
    80002efa:	fcc42703          	lw	a4,-52(s0)
    80002efe:	fce7ece3          	bltu	a5,a4,80002ed6 <sys_sleep+0x4a>
    80002f02:	74a2                	ld	s1,40(sp)
    80002f04:	7902                	ld	s2,32(sp)
    80002f06:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f08:	00014517          	auipc	a0,0x14
    80002f0c:	e5850513          	addi	a0,a0,-424 # 80016d60 <tickslock>
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	dfc080e7          	jalr	-516(ra) # 80000d0c <release>
  return 0;
    80002f18:	4501                	li	a0,0
}
    80002f1a:	70e2                	ld	ra,56(sp)
    80002f1c:	7442                	ld	s0,48(sp)
    80002f1e:	6121                	addi	sp,sp,64
    80002f20:	8082                	ret
      release(&tickslock);
    80002f22:	00014517          	auipc	a0,0x14
    80002f26:	e3e50513          	addi	a0,a0,-450 # 80016d60 <tickslock>
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	de2080e7          	jalr	-542(ra) # 80000d0c <release>
      return -1;
    80002f32:	557d                	li	a0,-1
    80002f34:	74a2                	ld	s1,40(sp)
    80002f36:	7902                	ld	s2,32(sp)
    80002f38:	69e2                	ld	s3,24(sp)
    80002f3a:	b7c5                	j	80002f1a <sys_sleep+0x8e>

0000000080002f3c <sys_kill>:

uint64
sys_kill(void)
{
    80002f3c:	1101                	addi	sp,sp,-32
    80002f3e:	ec06                	sd	ra,24(sp)
    80002f40:	e822                	sd	s0,16(sp)
    80002f42:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f44:	fec40593          	addi	a1,s0,-20
    80002f48:	4501                	li	a0,0
    80002f4a:	00000097          	auipc	ra,0x0
    80002f4e:	d98080e7          	jalr	-616(ra) # 80002ce2 <argint>
  return kill(pid);
    80002f52:	fec42503          	lw	a0,-20(s0)
    80002f56:	fffff097          	auipc	ra,0xfffff
    80002f5a:	4fa080e7          	jalr	1274(ra) # 80002450 <kill>
}
    80002f5e:	60e2                	ld	ra,24(sp)
    80002f60:	6442                	ld	s0,16(sp)
    80002f62:	6105                	addi	sp,sp,32
    80002f64:	8082                	ret

0000000080002f66 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f66:	1101                	addi	sp,sp,-32
    80002f68:	ec06                	sd	ra,24(sp)
    80002f6a:	e822                	sd	s0,16(sp)
    80002f6c:	e426                	sd	s1,8(sp)
    80002f6e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f70:	00014517          	auipc	a0,0x14
    80002f74:	df050513          	addi	a0,a0,-528 # 80016d60 <tickslock>
    80002f78:	ffffe097          	auipc	ra,0xffffe
    80002f7c:	ce4080e7          	jalr	-796(ra) # 80000c5c <acquire>
  xticks = ticks;
    80002f80:	00006797          	auipc	a5,0x6
    80002f84:	9407a783          	lw	a5,-1728(a5) # 800088c0 <ticks>
    80002f88:	84be                	mv	s1,a5
  release(&tickslock);
    80002f8a:	00014517          	auipc	a0,0x14
    80002f8e:	dd650513          	addi	a0,a0,-554 # 80016d60 <tickslock>
    80002f92:	ffffe097          	auipc	ra,0xffffe
    80002f96:	d7a080e7          	jalr	-646(ra) # 80000d0c <release>
  return xticks;
}
    80002f9a:	02049513          	slli	a0,s1,0x20
    80002f9e:	9101                	srli	a0,a0,0x20
    80002fa0:	60e2                	ld	ra,24(sp)
    80002fa2:	6442                	ld	s0,16(sp)
    80002fa4:	64a2                	ld	s1,8(sp)
    80002fa6:	6105                	addi	sp,sp,32
    80002fa8:	8082                	ret

0000000080002faa <sys_set_ps_priority>:

// step 3
uint64
sys_set_ps_priority(void){
    80002faa:	7179                	addi	sp,sp,-48
    80002fac:	f406                	sd	ra,40(sp)
    80002fae:	f022                	sd	s0,32(sp)
    80002fb0:	ec26                	sd	s1,24(sp)
    80002fb2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002fb4:	fffff097          	auipc	ra,0xfffff
    80002fb8:	b4c080e7          	jalr	-1204(ra) # 80001b00 <myproc>
    80002fbc:	84aa                	mv	s1,a0
  int priority;
  argint(0,&priority);
    80002fbe:	fdc40593          	addi	a1,s0,-36
    80002fc2:	4501                	li	a0,0
    80002fc4:	00000097          	auipc	ra,0x0
    80002fc8:	d1e080e7          	jalr	-738(ra) # 80002ce2 <argint>
  if(priority < 1 || priority > 10){
    80002fcc:	fdc42783          	lw	a5,-36(s0)
    80002fd0:	37fd                	addiw	a5,a5,-1
    80002fd2:	4725                	li	a4,9
    return -1;
    80002fd4:	557d                	li	a0,-1
  if(priority < 1 || priority > 10){
    80002fd6:	02f76163          	bltu	a4,a5,80002ff8 <sys_set_ps_priority+0x4e>
  }
  acquire(&p->lock);
    80002fda:	8526                	mv	a0,s1
    80002fdc:	ffffe097          	auipc	ra,0xffffe
    80002fe0:	c80080e7          	jalr	-896(ra) # 80000c5c <acquire>
  p->ps_priority = priority;
    80002fe4:	fdc42783          	lw	a5,-36(s0)
    80002fe8:	16f4a823          	sw	a5,368(s1)
  release(&p->lock);
    80002fec:	8526                	mv	a0,s1
    80002fee:	ffffe097          	auipc	ra,0xffffe
    80002ff2:	d1e080e7          	jalr	-738(ra) # 80000d0c <release>

  return 0;
    80002ff6:	4501                	li	a0,0
    80002ff8:	70a2                	ld	ra,40(sp)
    80002ffa:	7402                	ld	s0,32(sp)
    80002ffc:	64e2                	ld	s1,24(sp)
    80002ffe:	6145                	addi	sp,sp,48
    80003000:	8082                	ret

0000000080003002 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003002:	7179                	addi	sp,sp,-48
    80003004:	f406                	sd	ra,40(sp)
    80003006:	f022                	sd	s0,32(sp)
    80003008:	ec26                	sd	s1,24(sp)
    8000300a:	e84a                	sd	s2,16(sp)
    8000300c:	e44e                	sd	s3,8(sp)
    8000300e:	e052                	sd	s4,0(sp)
    80003010:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003012:	00005597          	auipc	a1,0x5
    80003016:	3d658593          	addi	a1,a1,982 # 800083e8 <etext+0x3e8>
    8000301a:	00014517          	auipc	a0,0x14
    8000301e:	d5e50513          	addi	a0,a0,-674 # 80016d78 <bcache>
    80003022:	ffffe097          	auipc	ra,0xffffe
    80003026:	ba0080e7          	jalr	-1120(ra) # 80000bc2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000302a:	0001c797          	auipc	a5,0x1c
    8000302e:	d4e78793          	addi	a5,a5,-690 # 8001ed78 <bcache+0x8000>
    80003032:	0001c717          	auipc	a4,0x1c
    80003036:	fae70713          	addi	a4,a4,-82 # 8001efe0 <bcache+0x8268>
    8000303a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000303e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003042:	00014497          	auipc	s1,0x14
    80003046:	d4e48493          	addi	s1,s1,-690 # 80016d90 <bcache+0x18>
    b->next = bcache.head.next;
    8000304a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000304c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000304e:	00005a17          	auipc	s4,0x5
    80003052:	3a2a0a13          	addi	s4,s4,930 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    80003056:	2b893783          	ld	a5,696(s2)
    8000305a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000305c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003060:	85d2                	mv	a1,s4
    80003062:	01048513          	addi	a0,s1,16
    80003066:	00001097          	auipc	ra,0x1
    8000306a:	4ec080e7          	jalr	1260(ra) # 80004552 <initsleeplock>
    bcache.head.next->prev = b;
    8000306e:	2b893783          	ld	a5,696(s2)
    80003072:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003074:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003078:	45848493          	addi	s1,s1,1112
    8000307c:	fd349de3          	bne	s1,s3,80003056 <binit+0x54>
  }
}
    80003080:	70a2                	ld	ra,40(sp)
    80003082:	7402                	ld	s0,32(sp)
    80003084:	64e2                	ld	s1,24(sp)
    80003086:	6942                	ld	s2,16(sp)
    80003088:	69a2                	ld	s3,8(sp)
    8000308a:	6a02                	ld	s4,0(sp)
    8000308c:	6145                	addi	sp,sp,48
    8000308e:	8082                	ret

0000000080003090 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003090:	7179                	addi	sp,sp,-48
    80003092:	f406                	sd	ra,40(sp)
    80003094:	f022                	sd	s0,32(sp)
    80003096:	ec26                	sd	s1,24(sp)
    80003098:	e84a                	sd	s2,16(sp)
    8000309a:	e44e                	sd	s3,8(sp)
    8000309c:	1800                	addi	s0,sp,48
    8000309e:	892a                	mv	s2,a0
    800030a0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030a2:	00014517          	auipc	a0,0x14
    800030a6:	cd650513          	addi	a0,a0,-810 # 80016d78 <bcache>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	bb2080e7          	jalr	-1102(ra) # 80000c5c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030b2:	0001c497          	auipc	s1,0x1c
    800030b6:	f7e4b483          	ld	s1,-130(s1) # 8001f030 <bcache+0x82b8>
    800030ba:	0001c797          	auipc	a5,0x1c
    800030be:	f2678793          	addi	a5,a5,-218 # 8001efe0 <bcache+0x8268>
    800030c2:	02f48f63          	beq	s1,a5,80003100 <bread+0x70>
    800030c6:	873e                	mv	a4,a5
    800030c8:	a021                	j	800030d0 <bread+0x40>
    800030ca:	68a4                	ld	s1,80(s1)
    800030cc:	02e48a63          	beq	s1,a4,80003100 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030d0:	449c                	lw	a5,8(s1)
    800030d2:	ff279ce3          	bne	a5,s2,800030ca <bread+0x3a>
    800030d6:	44dc                	lw	a5,12(s1)
    800030d8:	ff3799e3          	bne	a5,s3,800030ca <bread+0x3a>
      b->refcnt++;
    800030dc:	40bc                	lw	a5,64(s1)
    800030de:	2785                	addiw	a5,a5,1
    800030e0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030e2:	00014517          	auipc	a0,0x14
    800030e6:	c9650513          	addi	a0,a0,-874 # 80016d78 <bcache>
    800030ea:	ffffe097          	auipc	ra,0xffffe
    800030ee:	c22080e7          	jalr	-990(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    800030f2:	01048513          	addi	a0,s1,16
    800030f6:	00001097          	auipc	ra,0x1
    800030fa:	496080e7          	jalr	1174(ra) # 8000458c <acquiresleep>
      return b;
    800030fe:	a8b9                	j	8000315c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003100:	0001c497          	auipc	s1,0x1c
    80003104:	f284b483          	ld	s1,-216(s1) # 8001f028 <bcache+0x82b0>
    80003108:	0001c797          	auipc	a5,0x1c
    8000310c:	ed878793          	addi	a5,a5,-296 # 8001efe0 <bcache+0x8268>
    80003110:	00f48863          	beq	s1,a5,80003120 <bread+0x90>
    80003114:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003116:	40bc                	lw	a5,64(s1)
    80003118:	cf81                	beqz	a5,80003130 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000311a:	64a4                	ld	s1,72(s1)
    8000311c:	fee49de3          	bne	s1,a4,80003116 <bread+0x86>
  panic("bget: no buffers");
    80003120:	00005517          	auipc	a0,0x5
    80003124:	2d850513          	addi	a0,a0,728 # 800083f8 <etext+0x3f8>
    80003128:	ffffd097          	auipc	ra,0xffffd
    8000312c:	436080e7          	jalr	1078(ra) # 8000055e <panic>
      b->dev = dev;
    80003130:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003134:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003138:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000313c:	4785                	li	a5,1
    8000313e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003140:	00014517          	auipc	a0,0x14
    80003144:	c3850513          	addi	a0,a0,-968 # 80016d78 <bcache>
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	bc4080e7          	jalr	-1084(ra) # 80000d0c <release>
      acquiresleep(&b->lock);
    80003150:	01048513          	addi	a0,s1,16
    80003154:	00001097          	auipc	ra,0x1
    80003158:	438080e7          	jalr	1080(ra) # 8000458c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000315c:	409c                	lw	a5,0(s1)
    8000315e:	cb89                	beqz	a5,80003170 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003160:	8526                	mv	a0,s1
    80003162:	70a2                	ld	ra,40(sp)
    80003164:	7402                	ld	s0,32(sp)
    80003166:	64e2                	ld	s1,24(sp)
    80003168:	6942                	ld	s2,16(sp)
    8000316a:	69a2                	ld	s3,8(sp)
    8000316c:	6145                	addi	sp,sp,48
    8000316e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003170:	4581                	li	a1,0
    80003172:	8526                	mv	a0,s1
    80003174:	00003097          	auipc	ra,0x3
    80003178:	114080e7          	jalr	276(ra) # 80006288 <virtio_disk_rw>
    b->valid = 1;
    8000317c:	4785                	li	a5,1
    8000317e:	c09c                	sw	a5,0(s1)
  return b;
    80003180:	b7c5                	j	80003160 <bread+0xd0>

0000000080003182 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003182:	1101                	addi	sp,sp,-32
    80003184:	ec06                	sd	ra,24(sp)
    80003186:	e822                	sd	s0,16(sp)
    80003188:	e426                	sd	s1,8(sp)
    8000318a:	1000                	addi	s0,sp,32
    8000318c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000318e:	0541                	addi	a0,a0,16
    80003190:	00001097          	auipc	ra,0x1
    80003194:	496080e7          	jalr	1174(ra) # 80004626 <holdingsleep>
    80003198:	cd01                	beqz	a0,800031b0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000319a:	4585                	li	a1,1
    8000319c:	8526                	mv	a0,s1
    8000319e:	00003097          	auipc	ra,0x3
    800031a2:	0ea080e7          	jalr	234(ra) # 80006288 <virtio_disk_rw>
}
    800031a6:	60e2                	ld	ra,24(sp)
    800031a8:	6442                	ld	s0,16(sp)
    800031aa:	64a2                	ld	s1,8(sp)
    800031ac:	6105                	addi	sp,sp,32
    800031ae:	8082                	ret
    panic("bwrite");
    800031b0:	00005517          	auipc	a0,0x5
    800031b4:	26050513          	addi	a0,a0,608 # 80008410 <etext+0x410>
    800031b8:	ffffd097          	auipc	ra,0xffffd
    800031bc:	3a6080e7          	jalr	934(ra) # 8000055e <panic>

00000000800031c0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	e04a                	sd	s2,0(sp)
    800031ca:	1000                	addi	s0,sp,32
    800031cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031ce:	01050913          	addi	s2,a0,16
    800031d2:	854a                	mv	a0,s2
    800031d4:	00001097          	auipc	ra,0x1
    800031d8:	452080e7          	jalr	1106(ra) # 80004626 <holdingsleep>
    800031dc:	c535                	beqz	a0,80003248 <brelse+0x88>
    panic("brelse");

  releasesleep(&b->lock);
    800031de:	854a                	mv	a0,s2
    800031e0:	00001097          	auipc	ra,0x1
    800031e4:	402080e7          	jalr	1026(ra) # 800045e2 <releasesleep>

  acquire(&bcache.lock);
    800031e8:	00014517          	auipc	a0,0x14
    800031ec:	b9050513          	addi	a0,a0,-1136 # 80016d78 <bcache>
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	a6c080e7          	jalr	-1428(ra) # 80000c5c <acquire>
  b->refcnt--;
    800031f8:	40bc                	lw	a5,64(s1)
    800031fa:	37fd                	addiw	a5,a5,-1
    800031fc:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031fe:	e79d                	bnez	a5,8000322c <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003200:	68b8                	ld	a4,80(s1)
    80003202:	64bc                	ld	a5,72(s1)
    80003204:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003206:	68b8                	ld	a4,80(s1)
    80003208:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000320a:	0001c797          	auipc	a5,0x1c
    8000320e:	b6e78793          	addi	a5,a5,-1170 # 8001ed78 <bcache+0x8000>
    80003212:	2b87b703          	ld	a4,696(a5)
    80003216:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003218:	0001c717          	auipc	a4,0x1c
    8000321c:	dc870713          	addi	a4,a4,-568 # 8001efe0 <bcache+0x8268>
    80003220:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003222:	2b87b703          	ld	a4,696(a5)
    80003226:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003228:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000322c:	00014517          	auipc	a0,0x14
    80003230:	b4c50513          	addi	a0,a0,-1204 # 80016d78 <bcache>
    80003234:	ffffe097          	auipc	ra,0xffffe
    80003238:	ad8080e7          	jalr	-1320(ra) # 80000d0c <release>
}
    8000323c:	60e2                	ld	ra,24(sp)
    8000323e:	6442                	ld	s0,16(sp)
    80003240:	64a2                	ld	s1,8(sp)
    80003242:	6902                	ld	s2,0(sp)
    80003244:	6105                	addi	sp,sp,32
    80003246:	8082                	ret
    panic("brelse");
    80003248:	00005517          	auipc	a0,0x5
    8000324c:	1d050513          	addi	a0,a0,464 # 80008418 <etext+0x418>
    80003250:	ffffd097          	auipc	ra,0xffffd
    80003254:	30e080e7          	jalr	782(ra) # 8000055e <panic>

0000000080003258 <bpin>:

void
bpin(struct buf *b) {
    80003258:	1101                	addi	sp,sp,-32
    8000325a:	ec06                	sd	ra,24(sp)
    8000325c:	e822                	sd	s0,16(sp)
    8000325e:	e426                	sd	s1,8(sp)
    80003260:	1000                	addi	s0,sp,32
    80003262:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003264:	00014517          	auipc	a0,0x14
    80003268:	b1450513          	addi	a0,a0,-1260 # 80016d78 <bcache>
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	9f0080e7          	jalr	-1552(ra) # 80000c5c <acquire>
  b->refcnt++;
    80003274:	40bc                	lw	a5,64(s1)
    80003276:	2785                	addiw	a5,a5,1
    80003278:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000327a:	00014517          	auipc	a0,0x14
    8000327e:	afe50513          	addi	a0,a0,-1282 # 80016d78 <bcache>
    80003282:	ffffe097          	auipc	ra,0xffffe
    80003286:	a8a080e7          	jalr	-1398(ra) # 80000d0c <release>
}
    8000328a:	60e2                	ld	ra,24(sp)
    8000328c:	6442                	ld	s0,16(sp)
    8000328e:	64a2                	ld	s1,8(sp)
    80003290:	6105                	addi	sp,sp,32
    80003292:	8082                	ret

0000000080003294 <bunpin>:

void
bunpin(struct buf *b) {
    80003294:	1101                	addi	sp,sp,-32
    80003296:	ec06                	sd	ra,24(sp)
    80003298:	e822                	sd	s0,16(sp)
    8000329a:	e426                	sd	s1,8(sp)
    8000329c:	1000                	addi	s0,sp,32
    8000329e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032a0:	00014517          	auipc	a0,0x14
    800032a4:	ad850513          	addi	a0,a0,-1320 # 80016d78 <bcache>
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	9b4080e7          	jalr	-1612(ra) # 80000c5c <acquire>
  b->refcnt--;
    800032b0:	40bc                	lw	a5,64(s1)
    800032b2:	37fd                	addiw	a5,a5,-1
    800032b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032b6:	00014517          	auipc	a0,0x14
    800032ba:	ac250513          	addi	a0,a0,-1342 # 80016d78 <bcache>
    800032be:	ffffe097          	auipc	ra,0xffffe
    800032c2:	a4e080e7          	jalr	-1458(ra) # 80000d0c <release>
}
    800032c6:	60e2                	ld	ra,24(sp)
    800032c8:	6442                	ld	s0,16(sp)
    800032ca:	64a2                	ld	s1,8(sp)
    800032cc:	6105                	addi	sp,sp,32
    800032ce:	8082                	ret

00000000800032d0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032d0:	1101                	addi	sp,sp,-32
    800032d2:	ec06                	sd	ra,24(sp)
    800032d4:	e822                	sd	s0,16(sp)
    800032d6:	e426                	sd	s1,8(sp)
    800032d8:	e04a                	sd	s2,0(sp)
    800032da:	1000                	addi	s0,sp,32
    800032dc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032de:	00d5d79b          	srliw	a5,a1,0xd
    800032e2:	0001c597          	auipc	a1,0x1c
    800032e6:	1725a583          	lw	a1,370(a1) # 8001f454 <sb+0x1c>
    800032ea:	9dbd                	addw	a1,a1,a5
    800032ec:	00000097          	auipc	ra,0x0
    800032f0:	da4080e7          	jalr	-604(ra) # 80003090 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032f4:	0074f713          	andi	a4,s1,7
    800032f8:	4785                	li	a5,1
    800032fa:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800032fe:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003300:	90d9                	srli	s1,s1,0x36
    80003302:	00950733          	add	a4,a0,s1
    80003306:	05874703          	lbu	a4,88(a4)
    8000330a:	00e7f6b3          	and	a3,a5,a4
    8000330e:	c69d                	beqz	a3,8000333c <bfree+0x6c>
    80003310:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003312:	94aa                	add	s1,s1,a0
    80003314:	fff7c793          	not	a5,a5
    80003318:	8f7d                	and	a4,a4,a5
    8000331a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000331e:	00001097          	auipc	ra,0x1
    80003322:	14e080e7          	jalr	334(ra) # 8000446c <log_write>
  brelse(bp);
    80003326:	854a                	mv	a0,s2
    80003328:	00000097          	auipc	ra,0x0
    8000332c:	e98080e7          	jalr	-360(ra) # 800031c0 <brelse>
}
    80003330:	60e2                	ld	ra,24(sp)
    80003332:	6442                	ld	s0,16(sp)
    80003334:	64a2                	ld	s1,8(sp)
    80003336:	6902                	ld	s2,0(sp)
    80003338:	6105                	addi	sp,sp,32
    8000333a:	8082                	ret
    panic("freeing free block");
    8000333c:	00005517          	auipc	a0,0x5
    80003340:	0e450513          	addi	a0,a0,228 # 80008420 <etext+0x420>
    80003344:	ffffd097          	auipc	ra,0xffffd
    80003348:	21a080e7          	jalr	538(ra) # 8000055e <panic>

000000008000334c <balloc>:
{
    8000334c:	715d                	addi	sp,sp,-80
    8000334e:	e486                	sd	ra,72(sp)
    80003350:	e0a2                	sd	s0,64(sp)
    80003352:	fc26                	sd	s1,56(sp)
    80003354:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003356:	0001c797          	auipc	a5,0x1c
    8000335a:	0e67a783          	lw	a5,230(a5) # 8001f43c <sb+0x4>
    8000335e:	10078263          	beqz	a5,80003462 <balloc+0x116>
    80003362:	f84a                	sd	s2,48(sp)
    80003364:	f44e                	sd	s3,40(sp)
    80003366:	f052                	sd	s4,32(sp)
    80003368:	ec56                	sd	s5,24(sp)
    8000336a:	e85a                	sd	s6,16(sp)
    8000336c:	e45e                	sd	s7,8(sp)
    8000336e:	e062                	sd	s8,0(sp)
    80003370:	8baa                	mv	s7,a0
    80003372:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003374:	0001cb17          	auipc	s6,0x1c
    80003378:	0c4b0b13          	addi	s6,s6,196 # 8001f438 <sb>
      m = 1 << (bi % 8);
    8000337c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000337e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003380:	6c09                	lui	s8,0x2
    80003382:	a049                	j	80003404 <balloc+0xb8>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003384:	97ca                	add	a5,a5,s2
    80003386:	8e55                	or	a2,a2,a3
    80003388:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000338c:	854a                	mv	a0,s2
    8000338e:	00001097          	auipc	ra,0x1
    80003392:	0de080e7          	jalr	222(ra) # 8000446c <log_write>
        brelse(bp);
    80003396:	854a                	mv	a0,s2
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	e28080e7          	jalr	-472(ra) # 800031c0 <brelse>
  bp = bread(dev, bno);
    800033a0:	85a6                	mv	a1,s1
    800033a2:	855e                	mv	a0,s7
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	cec080e7          	jalr	-788(ra) # 80003090 <bread>
    800033ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033ae:	40000613          	li	a2,1024
    800033b2:	4581                	li	a1,0
    800033b4:	05850513          	addi	a0,a0,88
    800033b8:	ffffe097          	auipc	ra,0xffffe
    800033bc:	99c080e7          	jalr	-1636(ra) # 80000d54 <memset>
  log_write(bp);
    800033c0:	854a                	mv	a0,s2
    800033c2:	00001097          	auipc	ra,0x1
    800033c6:	0aa080e7          	jalr	170(ra) # 8000446c <log_write>
  brelse(bp);
    800033ca:	854a                	mv	a0,s2
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	df4080e7          	jalr	-524(ra) # 800031c0 <brelse>
}
    800033d4:	7942                	ld	s2,48(sp)
    800033d6:	79a2                	ld	s3,40(sp)
    800033d8:	7a02                	ld	s4,32(sp)
    800033da:	6ae2                	ld	s5,24(sp)
    800033dc:	6b42                	ld	s6,16(sp)
    800033de:	6ba2                	ld	s7,8(sp)
    800033e0:	6c02                	ld	s8,0(sp)
}
    800033e2:	8526                	mv	a0,s1
    800033e4:	60a6                	ld	ra,72(sp)
    800033e6:	6406                	ld	s0,64(sp)
    800033e8:	74e2                	ld	s1,56(sp)
    800033ea:	6161                	addi	sp,sp,80
    800033ec:	8082                	ret
    brelse(bp);
    800033ee:	854a                	mv	a0,s2
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	dd0080e7          	jalr	-560(ra) # 800031c0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033f8:	015c0abb          	addw	s5,s8,s5
    800033fc:	004b2783          	lw	a5,4(s6)
    80003400:	04fafa63          	bgeu	s5,a5,80003454 <balloc+0x108>
    bp = bread(dev, BBLOCK(b, sb));
    80003404:	40dad59b          	sraiw	a1,s5,0xd
    80003408:	01cb2783          	lw	a5,28(s6)
    8000340c:	9dbd                	addw	a1,a1,a5
    8000340e:	855e                	mv	a0,s7
    80003410:	00000097          	auipc	ra,0x0
    80003414:	c80080e7          	jalr	-896(ra) # 80003090 <bread>
    80003418:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000341a:	004b2503          	lw	a0,4(s6)
    8000341e:	84d6                	mv	s1,s5
    80003420:	4701                	li	a4,0
    80003422:	fca4f6e3          	bgeu	s1,a0,800033ee <balloc+0xa2>
      m = 1 << (bi % 8);
    80003426:	00777693          	andi	a3,a4,7
    8000342a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000342e:	41f7579b          	sraiw	a5,a4,0x1f
    80003432:	01d7d79b          	srliw	a5,a5,0x1d
    80003436:	9fb9                	addw	a5,a5,a4
    80003438:	4037d79b          	sraiw	a5,a5,0x3
    8000343c:	00f90633          	add	a2,s2,a5
    80003440:	05864603          	lbu	a2,88(a2)
    80003444:	00c6f5b3          	and	a1,a3,a2
    80003448:	dd95                	beqz	a1,80003384 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000344a:	2705                	addiw	a4,a4,1
    8000344c:	2485                	addiw	s1,s1,1
    8000344e:	fd471ae3          	bne	a4,s4,80003422 <balloc+0xd6>
    80003452:	bf71                	j	800033ee <balloc+0xa2>
    80003454:	7942                	ld	s2,48(sp)
    80003456:	79a2                	ld	s3,40(sp)
    80003458:	7a02                	ld	s4,32(sp)
    8000345a:	6ae2                	ld	s5,24(sp)
    8000345c:	6b42                	ld	s6,16(sp)
    8000345e:	6ba2                	ld	s7,8(sp)
    80003460:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003462:	00005517          	auipc	a0,0x5
    80003466:	fd650513          	addi	a0,a0,-42 # 80008438 <etext+0x438>
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	13e080e7          	jalr	318(ra) # 800005a8 <printf>
  return 0;
    80003472:	4481                	li	s1,0
    80003474:	b7bd                	j	800033e2 <balloc+0x96>

0000000080003476 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003476:	7179                	addi	sp,sp,-48
    80003478:	f406                	sd	ra,40(sp)
    8000347a:	f022                	sd	s0,32(sp)
    8000347c:	ec26                	sd	s1,24(sp)
    8000347e:	e84a                	sd	s2,16(sp)
    80003480:	e44e                	sd	s3,8(sp)
    80003482:	1800                	addi	s0,sp,48
    80003484:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003486:	47ad                	li	a5,11
    80003488:	02b7e563          	bltu	a5,a1,800034b2 <bmap+0x3c>
    if((addr = ip->addrs[bn]) == 0){
    8000348c:	02059793          	slli	a5,a1,0x20
    80003490:	01e7d593          	srli	a1,a5,0x1e
    80003494:	00b509b3          	add	s3,a0,a1
    80003498:	0509a483          	lw	s1,80(s3)
    8000349c:	e8b5                	bnez	s1,80003510 <bmap+0x9a>
      addr = balloc(ip->dev);
    8000349e:	4108                	lw	a0,0(a0)
    800034a0:	00000097          	auipc	ra,0x0
    800034a4:	eac080e7          	jalr	-340(ra) # 8000334c <balloc>
    800034a8:	84aa                	mv	s1,a0
      if(addr == 0)
    800034aa:	c13d                	beqz	a0,80003510 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800034ac:	04a9a823          	sw	a0,80(s3)
    800034b0:	a085                	j	80003510 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034b2:	ff45879b          	addiw	a5,a1,-12
    800034b6:	873e                	mv	a4,a5
    800034b8:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    800034ba:	0ff00793          	li	a5,255
    800034be:	08e7e163          	bltu	a5,a4,80003540 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034c2:	08052483          	lw	s1,128(a0)
    800034c6:	ec81                	bnez	s1,800034de <bmap+0x68>
      addr = balloc(ip->dev);
    800034c8:	4108                	lw	a0,0(a0)
    800034ca:	00000097          	auipc	ra,0x0
    800034ce:	e82080e7          	jalr	-382(ra) # 8000334c <balloc>
    800034d2:	84aa                	mv	s1,a0
      if(addr == 0)
    800034d4:	cd15                	beqz	a0,80003510 <bmap+0x9a>
    800034d6:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034d8:	08a92023          	sw	a0,128(s2)
    800034dc:	a011                	j	800034e0 <bmap+0x6a>
    800034de:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800034e0:	85a6                	mv	a1,s1
    800034e2:	00092503          	lw	a0,0(s2)
    800034e6:	00000097          	auipc	ra,0x0
    800034ea:	baa080e7          	jalr	-1110(ra) # 80003090 <bread>
    800034ee:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034f0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034f4:	02099713          	slli	a4,s3,0x20
    800034f8:	01e75593          	srli	a1,a4,0x1e
    800034fc:	97ae                	add	a5,a5,a1
    800034fe:	89be                	mv	s3,a5
    80003500:	4384                	lw	s1,0(a5)
    80003502:	cc99                	beqz	s1,80003520 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003504:	8552                	mv	a0,s4
    80003506:	00000097          	auipc	ra,0x0
    8000350a:	cba080e7          	jalr	-838(ra) # 800031c0 <brelse>
    return addr;
    8000350e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003510:	8526                	mv	a0,s1
    80003512:	70a2                	ld	ra,40(sp)
    80003514:	7402                	ld	s0,32(sp)
    80003516:	64e2                	ld	s1,24(sp)
    80003518:	6942                	ld	s2,16(sp)
    8000351a:	69a2                	ld	s3,8(sp)
    8000351c:	6145                	addi	sp,sp,48
    8000351e:	8082                	ret
      addr = balloc(ip->dev);
    80003520:	00092503          	lw	a0,0(s2)
    80003524:	00000097          	auipc	ra,0x0
    80003528:	e28080e7          	jalr	-472(ra) # 8000334c <balloc>
    8000352c:	84aa                	mv	s1,a0
      if(addr){
    8000352e:	d979                	beqz	a0,80003504 <bmap+0x8e>
        a[bn] = addr;
    80003530:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003534:	8552                	mv	a0,s4
    80003536:	00001097          	auipc	ra,0x1
    8000353a:	f36080e7          	jalr	-202(ra) # 8000446c <log_write>
    8000353e:	b7d9                	j	80003504 <bmap+0x8e>
    80003540:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003542:	00005517          	auipc	a0,0x5
    80003546:	f0e50513          	addi	a0,a0,-242 # 80008450 <etext+0x450>
    8000354a:	ffffd097          	auipc	ra,0xffffd
    8000354e:	014080e7          	jalr	20(ra) # 8000055e <panic>

0000000080003552 <iget>:
{
    80003552:	7179                	addi	sp,sp,-48
    80003554:	f406                	sd	ra,40(sp)
    80003556:	f022                	sd	s0,32(sp)
    80003558:	ec26                	sd	s1,24(sp)
    8000355a:	e84a                	sd	s2,16(sp)
    8000355c:	e44e                	sd	s3,8(sp)
    8000355e:	e052                	sd	s4,0(sp)
    80003560:	1800                	addi	s0,sp,48
    80003562:	892a                	mv	s2,a0
    80003564:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003566:	0001c517          	auipc	a0,0x1c
    8000356a:	ef250513          	addi	a0,a0,-270 # 8001f458 <itable>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	6ee080e7          	jalr	1774(ra) # 80000c5c <acquire>
  empty = 0;
    80003576:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003578:	0001c497          	auipc	s1,0x1c
    8000357c:	ef848493          	addi	s1,s1,-264 # 8001f470 <itable+0x18>
    80003580:	0001e697          	auipc	a3,0x1e
    80003584:	98068693          	addi	a3,a3,-1664 # 80020f00 <log>
    80003588:	a809                	j	8000359a <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000358a:	e781                	bnez	a5,80003592 <iget+0x40>
    8000358c:	00099363          	bnez	s3,80003592 <iget+0x40>
      empty = ip;
    80003590:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003592:	08848493          	addi	s1,s1,136
    80003596:	02d48763          	beq	s1,a3,800035c4 <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000359a:	449c                	lw	a5,8(s1)
    8000359c:	fef057e3          	blez	a5,8000358a <iget+0x38>
    800035a0:	4098                	lw	a4,0(s1)
    800035a2:	ff2718e3          	bne	a4,s2,80003592 <iget+0x40>
    800035a6:	40d8                	lw	a4,4(s1)
    800035a8:	ff4715e3          	bne	a4,s4,80003592 <iget+0x40>
      ip->ref++;
    800035ac:	2785                	addiw	a5,a5,1
    800035ae:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035b0:	0001c517          	auipc	a0,0x1c
    800035b4:	ea850513          	addi	a0,a0,-344 # 8001f458 <itable>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	754080e7          	jalr	1876(ra) # 80000d0c <release>
      return ip;
    800035c0:	89a6                	mv	s3,s1
    800035c2:	a025                	j	800035ea <iget+0x98>
  if(empty == 0)
    800035c4:	02098c63          	beqz	s3,800035fc <iget+0xaa>
  ip->dev = dev;
    800035c8:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800035cc:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800035d0:	4785                	li	a5,1
    800035d2:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800035d6:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800035da:	0001c517          	auipc	a0,0x1c
    800035de:	e7e50513          	addi	a0,a0,-386 # 8001f458 <itable>
    800035e2:	ffffd097          	auipc	ra,0xffffd
    800035e6:	72a080e7          	jalr	1834(ra) # 80000d0c <release>
}
    800035ea:	854e                	mv	a0,s3
    800035ec:	70a2                	ld	ra,40(sp)
    800035ee:	7402                	ld	s0,32(sp)
    800035f0:	64e2                	ld	s1,24(sp)
    800035f2:	6942                	ld	s2,16(sp)
    800035f4:	69a2                	ld	s3,8(sp)
    800035f6:	6a02                	ld	s4,0(sp)
    800035f8:	6145                	addi	sp,sp,48
    800035fa:	8082                	ret
    panic("iget: no inodes");
    800035fc:	00005517          	auipc	a0,0x5
    80003600:	e6c50513          	addi	a0,a0,-404 # 80008468 <etext+0x468>
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	f5a080e7          	jalr	-166(ra) # 8000055e <panic>

000000008000360c <fsinit>:
fsinit(int dev) {
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	e426                	sd	s1,8(sp)
    80003614:	e04a                	sd	s2,0(sp)
    80003616:	1000                	addi	s0,sp,32
    80003618:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000361a:	4585                	li	a1,1
    8000361c:	00000097          	auipc	ra,0x0
    80003620:	a74080e7          	jalr	-1420(ra) # 80003090 <bread>
    80003624:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003626:	02000613          	li	a2,32
    8000362a:	05850593          	addi	a1,a0,88
    8000362e:	0001c517          	auipc	a0,0x1c
    80003632:	e0a50513          	addi	a0,a0,-502 # 8001f438 <sb>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	77e080e7          	jalr	1918(ra) # 80000db4 <memmove>
  brelse(bp);
    8000363e:	8526                	mv	a0,s1
    80003640:	00000097          	auipc	ra,0x0
    80003644:	b80080e7          	jalr	-1152(ra) # 800031c0 <brelse>
  if(sb.magic != FSMAGIC)
    80003648:	0001c717          	auipc	a4,0x1c
    8000364c:	df072703          	lw	a4,-528(a4) # 8001f438 <sb>
    80003650:	102037b7          	lui	a5,0x10203
    80003654:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003658:	02f71163          	bne	a4,a5,8000367a <fsinit+0x6e>
  initlog(dev, &sb);
    8000365c:	0001c597          	auipc	a1,0x1c
    80003660:	ddc58593          	addi	a1,a1,-548 # 8001f438 <sb>
    80003664:	854a                	mv	a0,s2
    80003666:	00001097          	auipc	ra,0x1
    8000366a:	b80080e7          	jalr	-1152(ra) # 800041e6 <initlog>
}
    8000366e:	60e2                	ld	ra,24(sp)
    80003670:	6442                	ld	s0,16(sp)
    80003672:	64a2                	ld	s1,8(sp)
    80003674:	6902                	ld	s2,0(sp)
    80003676:	6105                	addi	sp,sp,32
    80003678:	8082                	ret
    panic("invalid file system");
    8000367a:	00005517          	auipc	a0,0x5
    8000367e:	dfe50513          	addi	a0,a0,-514 # 80008478 <etext+0x478>
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	edc080e7          	jalr	-292(ra) # 8000055e <panic>

000000008000368a <iinit>:
{
    8000368a:	7179                	addi	sp,sp,-48
    8000368c:	f406                	sd	ra,40(sp)
    8000368e:	f022                	sd	s0,32(sp)
    80003690:	ec26                	sd	s1,24(sp)
    80003692:	e84a                	sd	s2,16(sp)
    80003694:	e44e                	sd	s3,8(sp)
    80003696:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003698:	00005597          	auipc	a1,0x5
    8000369c:	df858593          	addi	a1,a1,-520 # 80008490 <etext+0x490>
    800036a0:	0001c517          	auipc	a0,0x1c
    800036a4:	db850513          	addi	a0,a0,-584 # 8001f458 <itable>
    800036a8:	ffffd097          	auipc	ra,0xffffd
    800036ac:	51a080e7          	jalr	1306(ra) # 80000bc2 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036b0:	0001c497          	auipc	s1,0x1c
    800036b4:	dd048493          	addi	s1,s1,-560 # 8001f480 <itable+0x28>
    800036b8:	0001e997          	auipc	s3,0x1e
    800036bc:	85898993          	addi	s3,s3,-1960 # 80020f10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036c0:	00005917          	auipc	s2,0x5
    800036c4:	dd890913          	addi	s2,s2,-552 # 80008498 <etext+0x498>
    800036c8:	85ca                	mv	a1,s2
    800036ca:	8526                	mv	a0,s1
    800036cc:	00001097          	auipc	ra,0x1
    800036d0:	e86080e7          	jalr	-378(ra) # 80004552 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036d4:	08848493          	addi	s1,s1,136
    800036d8:	ff3498e3          	bne	s1,s3,800036c8 <iinit+0x3e>
}
    800036dc:	70a2                	ld	ra,40(sp)
    800036de:	7402                	ld	s0,32(sp)
    800036e0:	64e2                	ld	s1,24(sp)
    800036e2:	6942                	ld	s2,16(sp)
    800036e4:	69a2                	ld	s3,8(sp)
    800036e6:	6145                	addi	sp,sp,48
    800036e8:	8082                	ret

00000000800036ea <ialloc>:
{
    800036ea:	7139                	addi	sp,sp,-64
    800036ec:	fc06                	sd	ra,56(sp)
    800036ee:	f822                	sd	s0,48(sp)
    800036f0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036f2:	0001c717          	auipc	a4,0x1c
    800036f6:	d5272703          	lw	a4,-686(a4) # 8001f444 <sb+0xc>
    800036fa:	4785                	li	a5,1
    800036fc:	06e7f463          	bgeu	a5,a4,80003764 <ialloc+0x7a>
    80003700:	f426                	sd	s1,40(sp)
    80003702:	f04a                	sd	s2,32(sp)
    80003704:	ec4e                	sd	s3,24(sp)
    80003706:	e852                	sd	s4,16(sp)
    80003708:	e456                	sd	s5,8(sp)
    8000370a:	e05a                	sd	s6,0(sp)
    8000370c:	8aaa                	mv	s5,a0
    8000370e:	8b2e                	mv	s6,a1
    80003710:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003712:	0001ca17          	auipc	s4,0x1c
    80003716:	d26a0a13          	addi	s4,s4,-730 # 8001f438 <sb>
    8000371a:	00495593          	srli	a1,s2,0x4
    8000371e:	018a2783          	lw	a5,24(s4)
    80003722:	9dbd                	addw	a1,a1,a5
    80003724:	8556                	mv	a0,s5
    80003726:	00000097          	auipc	ra,0x0
    8000372a:	96a080e7          	jalr	-1686(ra) # 80003090 <bread>
    8000372e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003730:	05850993          	addi	s3,a0,88
    80003734:	00f97793          	andi	a5,s2,15
    80003738:	079a                	slli	a5,a5,0x6
    8000373a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000373c:	00099783          	lh	a5,0(s3)
    80003740:	cf9d                	beqz	a5,8000377e <ialloc+0x94>
    brelse(bp);
    80003742:	00000097          	auipc	ra,0x0
    80003746:	a7e080e7          	jalr	-1410(ra) # 800031c0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000374a:	0905                	addi	s2,s2,1
    8000374c:	00ca2703          	lw	a4,12(s4)
    80003750:	0009079b          	sext.w	a5,s2
    80003754:	fce7e3e3          	bltu	a5,a4,8000371a <ialloc+0x30>
    80003758:	74a2                	ld	s1,40(sp)
    8000375a:	7902                	ld	s2,32(sp)
    8000375c:	69e2                	ld	s3,24(sp)
    8000375e:	6a42                	ld	s4,16(sp)
    80003760:	6aa2                	ld	s5,8(sp)
    80003762:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003764:	00005517          	auipc	a0,0x5
    80003768:	d3c50513          	addi	a0,a0,-708 # 800084a0 <etext+0x4a0>
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	e3c080e7          	jalr	-452(ra) # 800005a8 <printf>
  return 0;
    80003774:	4501                	li	a0,0
}
    80003776:	70e2                	ld	ra,56(sp)
    80003778:	7442                	ld	s0,48(sp)
    8000377a:	6121                	addi	sp,sp,64
    8000377c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000377e:	04000613          	li	a2,64
    80003782:	4581                	li	a1,0
    80003784:	854e                	mv	a0,s3
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	5ce080e7          	jalr	1486(ra) # 80000d54 <memset>
      dip->type = type;
    8000378e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003792:	8526                	mv	a0,s1
    80003794:	00001097          	auipc	ra,0x1
    80003798:	cd8080e7          	jalr	-808(ra) # 8000446c <log_write>
      brelse(bp);
    8000379c:	8526                	mv	a0,s1
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	a22080e7          	jalr	-1502(ra) # 800031c0 <brelse>
      return iget(dev, inum);
    800037a6:	0009059b          	sext.w	a1,s2
    800037aa:	8556                	mv	a0,s5
    800037ac:	00000097          	auipc	ra,0x0
    800037b0:	da6080e7          	jalr	-602(ra) # 80003552 <iget>
    800037b4:	74a2                	ld	s1,40(sp)
    800037b6:	7902                	ld	s2,32(sp)
    800037b8:	69e2                	ld	s3,24(sp)
    800037ba:	6a42                	ld	s4,16(sp)
    800037bc:	6aa2                	ld	s5,8(sp)
    800037be:	6b02                	ld	s6,0(sp)
    800037c0:	bf5d                	j	80003776 <ialloc+0x8c>

00000000800037c2 <iupdate>:
{
    800037c2:	1101                	addi	sp,sp,-32
    800037c4:	ec06                	sd	ra,24(sp)
    800037c6:	e822                	sd	s0,16(sp)
    800037c8:	e426                	sd	s1,8(sp)
    800037ca:	e04a                	sd	s2,0(sp)
    800037cc:	1000                	addi	s0,sp,32
    800037ce:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037d0:	415c                	lw	a5,4(a0)
    800037d2:	0047d79b          	srliw	a5,a5,0x4
    800037d6:	0001c597          	auipc	a1,0x1c
    800037da:	c7a5a583          	lw	a1,-902(a1) # 8001f450 <sb+0x18>
    800037de:	9dbd                	addw	a1,a1,a5
    800037e0:	4108                	lw	a0,0(a0)
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	8ae080e7          	jalr	-1874(ra) # 80003090 <bread>
    800037ea:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037ec:	05850793          	addi	a5,a0,88
    800037f0:	40d8                	lw	a4,4(s1)
    800037f2:	8b3d                	andi	a4,a4,15
    800037f4:	071a                	slli	a4,a4,0x6
    800037f6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037f8:	04449703          	lh	a4,68(s1)
    800037fc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003800:	04649703          	lh	a4,70(s1)
    80003804:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003808:	04849703          	lh	a4,72(s1)
    8000380c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003810:	04a49703          	lh	a4,74(s1)
    80003814:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003818:	44f8                	lw	a4,76(s1)
    8000381a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000381c:	03400613          	li	a2,52
    80003820:	05048593          	addi	a1,s1,80
    80003824:	00c78513          	addi	a0,a5,12
    80003828:	ffffd097          	auipc	ra,0xffffd
    8000382c:	58c080e7          	jalr	1420(ra) # 80000db4 <memmove>
  log_write(bp);
    80003830:	854a                	mv	a0,s2
    80003832:	00001097          	auipc	ra,0x1
    80003836:	c3a080e7          	jalr	-966(ra) # 8000446c <log_write>
  brelse(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	984080e7          	jalr	-1660(ra) # 800031c0 <brelse>
}
    80003844:	60e2                	ld	ra,24(sp)
    80003846:	6442                	ld	s0,16(sp)
    80003848:	64a2                	ld	s1,8(sp)
    8000384a:	6902                	ld	s2,0(sp)
    8000384c:	6105                	addi	sp,sp,32
    8000384e:	8082                	ret

0000000080003850 <idup>:
{
    80003850:	1101                	addi	sp,sp,-32
    80003852:	ec06                	sd	ra,24(sp)
    80003854:	e822                	sd	s0,16(sp)
    80003856:	e426                	sd	s1,8(sp)
    80003858:	1000                	addi	s0,sp,32
    8000385a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000385c:	0001c517          	auipc	a0,0x1c
    80003860:	bfc50513          	addi	a0,a0,-1028 # 8001f458 <itable>
    80003864:	ffffd097          	auipc	ra,0xffffd
    80003868:	3f8080e7          	jalr	1016(ra) # 80000c5c <acquire>
  ip->ref++;
    8000386c:	449c                	lw	a5,8(s1)
    8000386e:	2785                	addiw	a5,a5,1
    80003870:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003872:	0001c517          	auipc	a0,0x1c
    80003876:	be650513          	addi	a0,a0,-1050 # 8001f458 <itable>
    8000387a:	ffffd097          	auipc	ra,0xffffd
    8000387e:	492080e7          	jalr	1170(ra) # 80000d0c <release>
}
    80003882:	8526                	mv	a0,s1
    80003884:	60e2                	ld	ra,24(sp)
    80003886:	6442                	ld	s0,16(sp)
    80003888:	64a2                	ld	s1,8(sp)
    8000388a:	6105                	addi	sp,sp,32
    8000388c:	8082                	ret

000000008000388e <ilock>:
{
    8000388e:	1101                	addi	sp,sp,-32
    80003890:	ec06                	sd	ra,24(sp)
    80003892:	e822                	sd	s0,16(sp)
    80003894:	e426                	sd	s1,8(sp)
    80003896:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003898:	c10d                	beqz	a0,800038ba <ilock+0x2c>
    8000389a:	84aa                	mv	s1,a0
    8000389c:	451c                	lw	a5,8(a0)
    8000389e:	00f05e63          	blez	a5,800038ba <ilock+0x2c>
  acquiresleep(&ip->lock);
    800038a2:	0541                	addi	a0,a0,16
    800038a4:	00001097          	auipc	ra,0x1
    800038a8:	ce8080e7          	jalr	-792(ra) # 8000458c <acquiresleep>
  if(ip->valid == 0){
    800038ac:	40bc                	lw	a5,64(s1)
    800038ae:	cf99                	beqz	a5,800038cc <ilock+0x3e>
}
    800038b0:	60e2                	ld	ra,24(sp)
    800038b2:	6442                	ld	s0,16(sp)
    800038b4:	64a2                	ld	s1,8(sp)
    800038b6:	6105                	addi	sp,sp,32
    800038b8:	8082                	ret
    800038ba:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800038bc:	00005517          	auipc	a0,0x5
    800038c0:	bfc50513          	addi	a0,a0,-1028 # 800084b8 <etext+0x4b8>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	c9a080e7          	jalr	-870(ra) # 8000055e <panic>
    800038cc:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038ce:	40dc                	lw	a5,4(s1)
    800038d0:	0047d79b          	srliw	a5,a5,0x4
    800038d4:	0001c597          	auipc	a1,0x1c
    800038d8:	b7c5a583          	lw	a1,-1156(a1) # 8001f450 <sb+0x18>
    800038dc:	9dbd                	addw	a1,a1,a5
    800038de:	4088                	lw	a0,0(s1)
    800038e0:	fffff097          	auipc	ra,0xfffff
    800038e4:	7b0080e7          	jalr	1968(ra) # 80003090 <bread>
    800038e8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038ea:	05850593          	addi	a1,a0,88
    800038ee:	40dc                	lw	a5,4(s1)
    800038f0:	8bbd                	andi	a5,a5,15
    800038f2:	079a                	slli	a5,a5,0x6
    800038f4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038f6:	00059783          	lh	a5,0(a1)
    800038fa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038fe:	00259783          	lh	a5,2(a1)
    80003902:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003906:	00459783          	lh	a5,4(a1)
    8000390a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000390e:	00659783          	lh	a5,6(a1)
    80003912:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003916:	459c                	lw	a5,8(a1)
    80003918:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000391a:	03400613          	li	a2,52
    8000391e:	05b1                	addi	a1,a1,12
    80003920:	05048513          	addi	a0,s1,80
    80003924:	ffffd097          	auipc	ra,0xffffd
    80003928:	490080e7          	jalr	1168(ra) # 80000db4 <memmove>
    brelse(bp);
    8000392c:	854a                	mv	a0,s2
    8000392e:	00000097          	auipc	ra,0x0
    80003932:	892080e7          	jalr	-1902(ra) # 800031c0 <brelse>
    ip->valid = 1;
    80003936:	4785                	li	a5,1
    80003938:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000393a:	04449783          	lh	a5,68(s1)
    8000393e:	c399                	beqz	a5,80003944 <ilock+0xb6>
    80003940:	6902                	ld	s2,0(sp)
    80003942:	b7bd                	j	800038b0 <ilock+0x22>
      panic("ilock: no type");
    80003944:	00005517          	auipc	a0,0x5
    80003948:	b7c50513          	addi	a0,a0,-1156 # 800084c0 <etext+0x4c0>
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	c12080e7          	jalr	-1006(ra) # 8000055e <panic>

0000000080003954 <iunlock>:
{
    80003954:	1101                	addi	sp,sp,-32
    80003956:	ec06                	sd	ra,24(sp)
    80003958:	e822                	sd	s0,16(sp)
    8000395a:	e426                	sd	s1,8(sp)
    8000395c:	e04a                	sd	s2,0(sp)
    8000395e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003960:	c905                	beqz	a0,80003990 <iunlock+0x3c>
    80003962:	84aa                	mv	s1,a0
    80003964:	01050913          	addi	s2,a0,16
    80003968:	854a                	mv	a0,s2
    8000396a:	00001097          	auipc	ra,0x1
    8000396e:	cbc080e7          	jalr	-836(ra) # 80004626 <holdingsleep>
    80003972:	cd19                	beqz	a0,80003990 <iunlock+0x3c>
    80003974:	449c                	lw	a5,8(s1)
    80003976:	00f05d63          	blez	a5,80003990 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000397a:	854a                	mv	a0,s2
    8000397c:	00001097          	auipc	ra,0x1
    80003980:	c66080e7          	jalr	-922(ra) # 800045e2 <releasesleep>
}
    80003984:	60e2                	ld	ra,24(sp)
    80003986:	6442                	ld	s0,16(sp)
    80003988:	64a2                	ld	s1,8(sp)
    8000398a:	6902                	ld	s2,0(sp)
    8000398c:	6105                	addi	sp,sp,32
    8000398e:	8082                	ret
    panic("iunlock");
    80003990:	00005517          	auipc	a0,0x5
    80003994:	b4050513          	addi	a0,a0,-1216 # 800084d0 <etext+0x4d0>
    80003998:	ffffd097          	auipc	ra,0xffffd
    8000399c:	bc6080e7          	jalr	-1082(ra) # 8000055e <panic>

00000000800039a0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039a0:	7179                	addi	sp,sp,-48
    800039a2:	f406                	sd	ra,40(sp)
    800039a4:	f022                	sd	s0,32(sp)
    800039a6:	ec26                	sd	s1,24(sp)
    800039a8:	e84a                	sd	s2,16(sp)
    800039aa:	e44e                	sd	s3,8(sp)
    800039ac:	1800                	addi	s0,sp,48
    800039ae:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039b0:	05050493          	addi	s1,a0,80
    800039b4:	08050913          	addi	s2,a0,128
    800039b8:	a021                	j	800039c0 <itrunc+0x20>
    800039ba:	0491                	addi	s1,s1,4
    800039bc:	01248d63          	beq	s1,s2,800039d6 <itrunc+0x36>
    if(ip->addrs[i]){
    800039c0:	408c                	lw	a1,0(s1)
    800039c2:	dde5                	beqz	a1,800039ba <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800039c4:	0009a503          	lw	a0,0(s3)
    800039c8:	00000097          	auipc	ra,0x0
    800039cc:	908080e7          	jalr	-1784(ra) # 800032d0 <bfree>
      ip->addrs[i] = 0;
    800039d0:	0004a023          	sw	zero,0(s1)
    800039d4:	b7dd                	j	800039ba <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039d6:	0809a583          	lw	a1,128(s3)
    800039da:	ed99                	bnez	a1,800039f8 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039dc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039e0:	854e                	mv	a0,s3
    800039e2:	00000097          	auipc	ra,0x0
    800039e6:	de0080e7          	jalr	-544(ra) # 800037c2 <iupdate>
}
    800039ea:	70a2                	ld	ra,40(sp)
    800039ec:	7402                	ld	s0,32(sp)
    800039ee:	64e2                	ld	s1,24(sp)
    800039f0:	6942                	ld	s2,16(sp)
    800039f2:	69a2                	ld	s3,8(sp)
    800039f4:	6145                	addi	sp,sp,48
    800039f6:	8082                	ret
    800039f8:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039fa:	0009a503          	lw	a0,0(s3)
    800039fe:	fffff097          	auipc	ra,0xfffff
    80003a02:	692080e7          	jalr	1682(ra) # 80003090 <bread>
    80003a06:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a08:	05850493          	addi	s1,a0,88
    80003a0c:	45850913          	addi	s2,a0,1112
    80003a10:	a021                	j	80003a18 <itrunc+0x78>
    80003a12:	0491                	addi	s1,s1,4
    80003a14:	01248b63          	beq	s1,s2,80003a2a <itrunc+0x8a>
      if(a[j])
    80003a18:	408c                	lw	a1,0(s1)
    80003a1a:	dde5                	beqz	a1,80003a12 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003a1c:	0009a503          	lw	a0,0(s3)
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	8b0080e7          	jalr	-1872(ra) # 800032d0 <bfree>
    80003a28:	b7ed                	j	80003a12 <itrunc+0x72>
    brelse(bp);
    80003a2a:	8552                	mv	a0,s4
    80003a2c:	fffff097          	auipc	ra,0xfffff
    80003a30:	794080e7          	jalr	1940(ra) # 800031c0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a34:	0809a583          	lw	a1,128(s3)
    80003a38:	0009a503          	lw	a0,0(s3)
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	894080e7          	jalr	-1900(ra) # 800032d0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a44:	0809a023          	sw	zero,128(s3)
    80003a48:	6a02                	ld	s4,0(sp)
    80003a4a:	bf49                	j	800039dc <itrunc+0x3c>

0000000080003a4c <iput>:
{
    80003a4c:	1101                	addi	sp,sp,-32
    80003a4e:	ec06                	sd	ra,24(sp)
    80003a50:	e822                	sd	s0,16(sp)
    80003a52:	e426                	sd	s1,8(sp)
    80003a54:	1000                	addi	s0,sp,32
    80003a56:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a58:	0001c517          	auipc	a0,0x1c
    80003a5c:	a0050513          	addi	a0,a0,-1536 # 8001f458 <itable>
    80003a60:	ffffd097          	auipc	ra,0xffffd
    80003a64:	1fc080e7          	jalr	508(ra) # 80000c5c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a68:	4498                	lw	a4,8(s1)
    80003a6a:	4785                	li	a5,1
    80003a6c:	02f70263          	beq	a4,a5,80003a90 <iput+0x44>
  ip->ref--;
    80003a70:	449c                	lw	a5,8(s1)
    80003a72:	37fd                	addiw	a5,a5,-1
    80003a74:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a76:	0001c517          	auipc	a0,0x1c
    80003a7a:	9e250513          	addi	a0,a0,-1566 # 8001f458 <itable>
    80003a7e:	ffffd097          	auipc	ra,0xffffd
    80003a82:	28e080e7          	jalr	654(ra) # 80000d0c <release>
}
    80003a86:	60e2                	ld	ra,24(sp)
    80003a88:	6442                	ld	s0,16(sp)
    80003a8a:	64a2                	ld	s1,8(sp)
    80003a8c:	6105                	addi	sp,sp,32
    80003a8e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a90:	40bc                	lw	a5,64(s1)
    80003a92:	dff9                	beqz	a5,80003a70 <iput+0x24>
    80003a94:	04a49783          	lh	a5,74(s1)
    80003a98:	ffe1                	bnez	a5,80003a70 <iput+0x24>
    80003a9a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003a9c:	01048793          	addi	a5,s1,16
    80003aa0:	893e                	mv	s2,a5
    80003aa2:	853e                	mv	a0,a5
    80003aa4:	00001097          	auipc	ra,0x1
    80003aa8:	ae8080e7          	jalr	-1304(ra) # 8000458c <acquiresleep>
    release(&itable.lock);
    80003aac:	0001c517          	auipc	a0,0x1c
    80003ab0:	9ac50513          	addi	a0,a0,-1620 # 8001f458 <itable>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	258080e7          	jalr	600(ra) # 80000d0c <release>
    itrunc(ip);
    80003abc:	8526                	mv	a0,s1
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	ee2080e7          	jalr	-286(ra) # 800039a0 <itrunc>
    ip->type = 0;
    80003ac6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aca:	8526                	mv	a0,s1
    80003acc:	00000097          	auipc	ra,0x0
    80003ad0:	cf6080e7          	jalr	-778(ra) # 800037c2 <iupdate>
    ip->valid = 0;
    80003ad4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ad8:	854a                	mv	a0,s2
    80003ada:	00001097          	auipc	ra,0x1
    80003ade:	b08080e7          	jalr	-1272(ra) # 800045e2 <releasesleep>
    acquire(&itable.lock);
    80003ae2:	0001c517          	auipc	a0,0x1c
    80003ae6:	97650513          	addi	a0,a0,-1674 # 8001f458 <itable>
    80003aea:	ffffd097          	auipc	ra,0xffffd
    80003aee:	172080e7          	jalr	370(ra) # 80000c5c <acquire>
    80003af2:	6902                	ld	s2,0(sp)
    80003af4:	bfb5                	j	80003a70 <iput+0x24>

0000000080003af6 <iunlockput>:
{
    80003af6:	1101                	addi	sp,sp,-32
    80003af8:	ec06                	sd	ra,24(sp)
    80003afa:	e822                	sd	s0,16(sp)
    80003afc:	e426                	sd	s1,8(sp)
    80003afe:	1000                	addi	s0,sp,32
    80003b00:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b02:	00000097          	auipc	ra,0x0
    80003b06:	e52080e7          	jalr	-430(ra) # 80003954 <iunlock>
  iput(ip);
    80003b0a:	8526                	mv	a0,s1
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	f40080e7          	jalr	-192(ra) # 80003a4c <iput>
}
    80003b14:	60e2                	ld	ra,24(sp)
    80003b16:	6442                	ld	s0,16(sp)
    80003b18:	64a2                	ld	s1,8(sp)
    80003b1a:	6105                	addi	sp,sp,32
    80003b1c:	8082                	ret

0000000080003b1e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b1e:	1141                	addi	sp,sp,-16
    80003b20:	e406                	sd	ra,8(sp)
    80003b22:	e022                	sd	s0,0(sp)
    80003b24:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b26:	411c                	lw	a5,0(a0)
    80003b28:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b2a:	415c                	lw	a5,4(a0)
    80003b2c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b2e:	04451783          	lh	a5,68(a0)
    80003b32:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b36:	04a51783          	lh	a5,74(a0)
    80003b3a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b3e:	04c56783          	lwu	a5,76(a0)
    80003b42:	e99c                	sd	a5,16(a1)
}
    80003b44:	60a2                	ld	ra,8(sp)
    80003b46:	6402                	ld	s0,0(sp)
    80003b48:	0141                	addi	sp,sp,16
    80003b4a:	8082                	ret

0000000080003b4c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b4c:	457c                	lw	a5,76(a0)
    80003b4e:	10d7e063          	bltu	a5,a3,80003c4e <readi+0x102>
{
    80003b52:	7159                	addi	sp,sp,-112
    80003b54:	f486                	sd	ra,104(sp)
    80003b56:	f0a2                	sd	s0,96(sp)
    80003b58:	eca6                	sd	s1,88(sp)
    80003b5a:	e0d2                	sd	s4,64(sp)
    80003b5c:	fc56                	sd	s5,56(sp)
    80003b5e:	f85a                	sd	s6,48(sp)
    80003b60:	f45e                	sd	s7,40(sp)
    80003b62:	1880                	addi	s0,sp,112
    80003b64:	8b2a                	mv	s6,a0
    80003b66:	8bae                	mv	s7,a1
    80003b68:	8a32                	mv	s4,a2
    80003b6a:	84b6                	mv	s1,a3
    80003b6c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b6e:	9f35                	addw	a4,a4,a3
    return 0;
    80003b70:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b72:	0cd76563          	bltu	a4,a3,80003c3c <readi+0xf0>
    80003b76:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b78:	00e7f463          	bgeu	a5,a4,80003b80 <readi+0x34>
    n = ip->size - off;
    80003b7c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b80:	0a0a8563          	beqz	s5,80003c2a <readi+0xde>
    80003b84:	e8ca                	sd	s2,80(sp)
    80003b86:	f062                	sd	s8,32(sp)
    80003b88:	ec66                	sd	s9,24(sp)
    80003b8a:	e86a                	sd	s10,16(sp)
    80003b8c:	e46e                	sd	s11,8(sp)
    80003b8e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b90:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b94:	5c7d                	li	s8,-1
    80003b96:	a82d                	j	80003bd0 <readi+0x84>
    80003b98:	020d1d93          	slli	s11,s10,0x20
    80003b9c:	020ddd93          	srli	s11,s11,0x20
    80003ba0:	05890613          	addi	a2,s2,88
    80003ba4:	86ee                	mv	a3,s11
    80003ba6:	963e                	add	a2,a2,a5
    80003ba8:	85d2                	mv	a1,s4
    80003baa:	855e                	mv	a0,s7
    80003bac:	fffff097          	auipc	ra,0xfffff
    80003bb0:	a9c080e7          	jalr	-1380(ra) # 80002648 <either_copyout>
    80003bb4:	05850963          	beq	a0,s8,80003c06 <readi+0xba>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bb8:	854a                	mv	a0,s2
    80003bba:	fffff097          	auipc	ra,0xfffff
    80003bbe:	606080e7          	jalr	1542(ra) # 800031c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bc2:	013d09bb          	addw	s3,s10,s3
    80003bc6:	009d04bb          	addw	s1,s10,s1
    80003bca:	9a6e                	add	s4,s4,s11
    80003bcc:	0559f963          	bgeu	s3,s5,80003c1e <readi+0xd2>
    uint addr = bmap(ip, off/BSIZE);
    80003bd0:	00a4d59b          	srliw	a1,s1,0xa
    80003bd4:	855a                	mv	a0,s6
    80003bd6:	00000097          	auipc	ra,0x0
    80003bda:	8a0080e7          	jalr	-1888(ra) # 80003476 <bmap>
    80003bde:	85aa                	mv	a1,a0
    if(addr == 0)
    80003be0:	c539                	beqz	a0,80003c2e <readi+0xe2>
    bp = bread(ip->dev, addr);
    80003be2:	000b2503          	lw	a0,0(s6)
    80003be6:	fffff097          	auipc	ra,0xfffff
    80003bea:	4aa080e7          	jalr	1194(ra) # 80003090 <bread>
    80003bee:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf0:	3ff4f793          	andi	a5,s1,1023
    80003bf4:	40fc873b          	subw	a4,s9,a5
    80003bf8:	413a86bb          	subw	a3,s5,s3
    80003bfc:	8d3a                	mv	s10,a4
    80003bfe:	f8e6fde3          	bgeu	a3,a4,80003b98 <readi+0x4c>
    80003c02:	8d36                	mv	s10,a3
    80003c04:	bf51                	j	80003b98 <readi+0x4c>
      brelse(bp);
    80003c06:	854a                	mv	a0,s2
    80003c08:	fffff097          	auipc	ra,0xfffff
    80003c0c:	5b8080e7          	jalr	1464(ra) # 800031c0 <brelse>
      tot = -1;
    80003c10:	59fd                	li	s3,-1
      break;
    80003c12:	6946                	ld	s2,80(sp)
    80003c14:	7c02                	ld	s8,32(sp)
    80003c16:	6ce2                	ld	s9,24(sp)
    80003c18:	6d42                	ld	s10,16(sp)
    80003c1a:	6da2                	ld	s11,8(sp)
    80003c1c:	a831                	j	80003c38 <readi+0xec>
    80003c1e:	6946                	ld	s2,80(sp)
    80003c20:	7c02                	ld	s8,32(sp)
    80003c22:	6ce2                	ld	s9,24(sp)
    80003c24:	6d42                	ld	s10,16(sp)
    80003c26:	6da2                	ld	s11,8(sp)
    80003c28:	a801                	j	80003c38 <readi+0xec>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c2a:	89d6                	mv	s3,s5
    80003c2c:	a031                	j	80003c38 <readi+0xec>
    80003c2e:	6946                	ld	s2,80(sp)
    80003c30:	7c02                	ld	s8,32(sp)
    80003c32:	6ce2                	ld	s9,24(sp)
    80003c34:	6d42                	ld	s10,16(sp)
    80003c36:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c38:	854e                	mv	a0,s3
    80003c3a:	69a6                	ld	s3,72(sp)
}
    80003c3c:	70a6                	ld	ra,104(sp)
    80003c3e:	7406                	ld	s0,96(sp)
    80003c40:	64e6                	ld	s1,88(sp)
    80003c42:	6a06                	ld	s4,64(sp)
    80003c44:	7ae2                	ld	s5,56(sp)
    80003c46:	7b42                	ld	s6,48(sp)
    80003c48:	7ba2                	ld	s7,40(sp)
    80003c4a:	6165                	addi	sp,sp,112
    80003c4c:	8082                	ret
    return 0;
    80003c4e:	4501                	li	a0,0
}
    80003c50:	8082                	ret

0000000080003c52 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c52:	457c                	lw	a5,76(a0)
    80003c54:	10d7e963          	bltu	a5,a3,80003d66 <writei+0x114>
{
    80003c58:	7159                	addi	sp,sp,-112
    80003c5a:	f486                	sd	ra,104(sp)
    80003c5c:	f0a2                	sd	s0,96(sp)
    80003c5e:	e8ca                	sd	s2,80(sp)
    80003c60:	e0d2                	sd	s4,64(sp)
    80003c62:	fc56                	sd	s5,56(sp)
    80003c64:	f85a                	sd	s6,48(sp)
    80003c66:	f45e                	sd	s7,40(sp)
    80003c68:	1880                	addi	s0,sp,112
    80003c6a:	8aaa                	mv	s5,a0
    80003c6c:	8bae                	mv	s7,a1
    80003c6e:	8a32                	mv	s4,a2
    80003c70:	8936                	mv	s2,a3
    80003c72:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c74:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c78:	00043737          	lui	a4,0x43
    80003c7c:	0ef76763          	bltu	a4,a5,80003d6a <writei+0x118>
    80003c80:	0ed7e563          	bltu	a5,a3,80003d6a <writei+0x118>
    80003c84:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c86:	0c0b0863          	beqz	s6,80003d56 <writei+0x104>
    80003c8a:	eca6                	sd	s1,88(sp)
    80003c8c:	f062                	sd	s8,32(sp)
    80003c8e:	ec66                	sd	s9,24(sp)
    80003c90:	e86a                	sd	s10,16(sp)
    80003c92:	e46e                	sd	s11,8(sp)
    80003c94:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c96:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c9a:	5c7d                	li	s8,-1
    80003c9c:	a091                	j	80003ce0 <writei+0x8e>
    80003c9e:	020d1d93          	slli	s11,s10,0x20
    80003ca2:	020ddd93          	srli	s11,s11,0x20
    80003ca6:	05848513          	addi	a0,s1,88
    80003caa:	86ee                	mv	a3,s11
    80003cac:	8652                	mv	a2,s4
    80003cae:	85de                	mv	a1,s7
    80003cb0:	953e                	add	a0,a0,a5
    80003cb2:	fffff097          	auipc	ra,0xfffff
    80003cb6:	9ec080e7          	jalr	-1556(ra) # 8000269e <either_copyin>
    80003cba:	05850e63          	beq	a0,s8,80003d16 <writei+0xc4>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cbe:	8526                	mv	a0,s1
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	7ac080e7          	jalr	1964(ra) # 8000446c <log_write>
    brelse(bp);
    80003cc8:	8526                	mv	a0,s1
    80003cca:	fffff097          	auipc	ra,0xfffff
    80003cce:	4f6080e7          	jalr	1270(ra) # 800031c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd2:	013d09bb          	addw	s3,s10,s3
    80003cd6:	012d093b          	addw	s2,s10,s2
    80003cda:	9a6e                	add	s4,s4,s11
    80003cdc:	0569f263          	bgeu	s3,s6,80003d20 <writei+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ce0:	00a9559b          	srliw	a1,s2,0xa
    80003ce4:	8556                	mv	a0,s5
    80003ce6:	fffff097          	auipc	ra,0xfffff
    80003cea:	790080e7          	jalr	1936(ra) # 80003476 <bmap>
    80003cee:	85aa                	mv	a1,a0
    if(addr == 0)
    80003cf0:	c905                	beqz	a0,80003d20 <writei+0xce>
    bp = bread(ip->dev, addr);
    80003cf2:	000aa503          	lw	a0,0(s5)
    80003cf6:	fffff097          	auipc	ra,0xfffff
    80003cfa:	39a080e7          	jalr	922(ra) # 80003090 <bread>
    80003cfe:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d00:	3ff97793          	andi	a5,s2,1023
    80003d04:	40fc873b          	subw	a4,s9,a5
    80003d08:	413b06bb          	subw	a3,s6,s3
    80003d0c:	8d3a                	mv	s10,a4
    80003d0e:	f8e6f8e3          	bgeu	a3,a4,80003c9e <writei+0x4c>
    80003d12:	8d36                	mv	s10,a3
    80003d14:	b769                	j	80003c9e <writei+0x4c>
      brelse(bp);
    80003d16:	8526                	mv	a0,s1
    80003d18:	fffff097          	auipc	ra,0xfffff
    80003d1c:	4a8080e7          	jalr	1192(ra) # 800031c0 <brelse>
  }

  if(off > ip->size)
    80003d20:	04caa783          	lw	a5,76(s5)
    80003d24:	0327fb63          	bgeu	a5,s2,80003d5a <writei+0x108>
    ip->size = off;
    80003d28:	052aa623          	sw	s2,76(s5)
    80003d2c:	64e6                	ld	s1,88(sp)
    80003d2e:	7c02                	ld	s8,32(sp)
    80003d30:	6ce2                	ld	s9,24(sp)
    80003d32:	6d42                	ld	s10,16(sp)
    80003d34:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d36:	8556                	mv	a0,s5
    80003d38:	00000097          	auipc	ra,0x0
    80003d3c:	a8a080e7          	jalr	-1398(ra) # 800037c2 <iupdate>

  return tot;
    80003d40:	854e                	mv	a0,s3
    80003d42:	69a6                	ld	s3,72(sp)
}
    80003d44:	70a6                	ld	ra,104(sp)
    80003d46:	7406                	ld	s0,96(sp)
    80003d48:	6946                	ld	s2,80(sp)
    80003d4a:	6a06                	ld	s4,64(sp)
    80003d4c:	7ae2                	ld	s5,56(sp)
    80003d4e:	7b42                	ld	s6,48(sp)
    80003d50:	7ba2                	ld	s7,40(sp)
    80003d52:	6165                	addi	sp,sp,112
    80003d54:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d56:	89da                	mv	s3,s6
    80003d58:	bff9                	j	80003d36 <writei+0xe4>
    80003d5a:	64e6                	ld	s1,88(sp)
    80003d5c:	7c02                	ld	s8,32(sp)
    80003d5e:	6ce2                	ld	s9,24(sp)
    80003d60:	6d42                	ld	s10,16(sp)
    80003d62:	6da2                	ld	s11,8(sp)
    80003d64:	bfc9                	j	80003d36 <writei+0xe4>
    return -1;
    80003d66:	557d                	li	a0,-1
}
    80003d68:	8082                	ret
    return -1;
    80003d6a:	557d                	li	a0,-1
    80003d6c:	bfe1                	j	80003d44 <writei+0xf2>

0000000080003d6e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d6e:	1141                	addi	sp,sp,-16
    80003d70:	e406                	sd	ra,8(sp)
    80003d72:	e022                	sd	s0,0(sp)
    80003d74:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d76:	4639                	li	a2,14
    80003d78:	ffffd097          	auipc	ra,0xffffd
    80003d7c:	0b4080e7          	jalr	180(ra) # 80000e2c <strncmp>
}
    80003d80:	60a2                	ld	ra,8(sp)
    80003d82:	6402                	ld	s0,0(sp)
    80003d84:	0141                	addi	sp,sp,16
    80003d86:	8082                	ret

0000000080003d88 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d88:	711d                	addi	sp,sp,-96
    80003d8a:	ec86                	sd	ra,88(sp)
    80003d8c:	e8a2                	sd	s0,80(sp)
    80003d8e:	e4a6                	sd	s1,72(sp)
    80003d90:	e0ca                	sd	s2,64(sp)
    80003d92:	fc4e                	sd	s3,56(sp)
    80003d94:	f852                	sd	s4,48(sp)
    80003d96:	f456                	sd	s5,40(sp)
    80003d98:	f05a                	sd	s6,32(sp)
    80003d9a:	ec5e                	sd	s7,24(sp)
    80003d9c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d9e:	04451703          	lh	a4,68(a0)
    80003da2:	4785                	li	a5,1
    80003da4:	00f71f63          	bne	a4,a5,80003dc2 <dirlookup+0x3a>
    80003da8:	892a                	mv	s2,a0
    80003daa:	8aae                	mv	s5,a1
    80003dac:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dae:	457c                	lw	a5,76(a0)
    80003db0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003db2:	fa040a13          	addi	s4,s0,-96
    80003db6:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003db8:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dbc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dbe:	e79d                	bnez	a5,80003dec <dirlookup+0x64>
    80003dc0:	a88d                	j	80003e32 <dirlookup+0xaa>
    panic("dirlookup not DIR");
    80003dc2:	00004517          	auipc	a0,0x4
    80003dc6:	71650513          	addi	a0,a0,1814 # 800084d8 <etext+0x4d8>
    80003dca:	ffffc097          	auipc	ra,0xffffc
    80003dce:	794080e7          	jalr	1940(ra) # 8000055e <panic>
      panic("dirlookup read");
    80003dd2:	00004517          	auipc	a0,0x4
    80003dd6:	71e50513          	addi	a0,a0,1822 # 800084f0 <etext+0x4f0>
    80003dda:	ffffc097          	auipc	ra,0xffffc
    80003dde:	784080e7          	jalr	1924(ra) # 8000055e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de2:	24c1                	addiw	s1,s1,16
    80003de4:	04c92783          	lw	a5,76(s2)
    80003de8:	04f4f463          	bgeu	s1,a5,80003e30 <dirlookup+0xa8>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dec:	874e                	mv	a4,s3
    80003dee:	86a6                	mv	a3,s1
    80003df0:	8652                	mv	a2,s4
    80003df2:	4581                	li	a1,0
    80003df4:	854a                	mv	a0,s2
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	d56080e7          	jalr	-682(ra) # 80003b4c <readi>
    80003dfe:	fd351ae3          	bne	a0,s3,80003dd2 <dirlookup+0x4a>
    if(de.inum == 0)
    80003e02:	fa045783          	lhu	a5,-96(s0)
    80003e06:	dff1                	beqz	a5,80003de2 <dirlookup+0x5a>
    if(namecmp(name, de.name) == 0){
    80003e08:	85da                	mv	a1,s6
    80003e0a:	8556                	mv	a0,s5
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	f62080e7          	jalr	-158(ra) # 80003d6e <namecmp>
    80003e14:	f579                	bnez	a0,80003de2 <dirlookup+0x5a>
      if(poff)
    80003e16:	000b8463          	beqz	s7,80003e1e <dirlookup+0x96>
        *poff = off;
    80003e1a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003e1e:	fa045583          	lhu	a1,-96(s0)
    80003e22:	00092503          	lw	a0,0(s2)
    80003e26:	fffff097          	auipc	ra,0xfffff
    80003e2a:	72c080e7          	jalr	1836(ra) # 80003552 <iget>
    80003e2e:	a011                	j	80003e32 <dirlookup+0xaa>
  return 0;
    80003e30:	4501                	li	a0,0
}
    80003e32:	60e6                	ld	ra,88(sp)
    80003e34:	6446                	ld	s0,80(sp)
    80003e36:	64a6                	ld	s1,72(sp)
    80003e38:	6906                	ld	s2,64(sp)
    80003e3a:	79e2                	ld	s3,56(sp)
    80003e3c:	7a42                	ld	s4,48(sp)
    80003e3e:	7aa2                	ld	s5,40(sp)
    80003e40:	7b02                	ld	s6,32(sp)
    80003e42:	6be2                	ld	s7,24(sp)
    80003e44:	6125                	addi	sp,sp,96
    80003e46:	8082                	ret

0000000080003e48 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e48:	711d                	addi	sp,sp,-96
    80003e4a:	ec86                	sd	ra,88(sp)
    80003e4c:	e8a2                	sd	s0,80(sp)
    80003e4e:	e4a6                	sd	s1,72(sp)
    80003e50:	e0ca                	sd	s2,64(sp)
    80003e52:	fc4e                	sd	s3,56(sp)
    80003e54:	f852                	sd	s4,48(sp)
    80003e56:	f456                	sd	s5,40(sp)
    80003e58:	f05a                	sd	s6,32(sp)
    80003e5a:	ec5e                	sd	s7,24(sp)
    80003e5c:	e862                	sd	s8,16(sp)
    80003e5e:	e466                	sd	s9,8(sp)
    80003e60:	e06a                	sd	s10,0(sp)
    80003e62:	1080                	addi	s0,sp,96
    80003e64:	84aa                	mv	s1,a0
    80003e66:	8b2e                	mv	s6,a1
    80003e68:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e6a:	00054703          	lbu	a4,0(a0)
    80003e6e:	02f00793          	li	a5,47
    80003e72:	02f70363          	beq	a4,a5,80003e98 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e76:	ffffe097          	auipc	ra,0xffffe
    80003e7a:	c8a080e7          	jalr	-886(ra) # 80001b00 <myproc>
    80003e7e:	15053503          	ld	a0,336(a0)
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	9ce080e7          	jalr	-1586(ra) # 80003850 <idup>
    80003e8a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e8c:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003e90:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003e92:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e94:	4b85                	li	s7,1
    80003e96:	a87d                	j	80003f54 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003e98:	4585                	li	a1,1
    80003e9a:	852e                	mv	a0,a1
    80003e9c:	fffff097          	auipc	ra,0xfffff
    80003ea0:	6b6080e7          	jalr	1718(ra) # 80003552 <iget>
    80003ea4:	8a2a                	mv	s4,a0
    80003ea6:	b7dd                	j	80003e8c <namex+0x44>
      iunlockput(ip);
    80003ea8:	8552                	mv	a0,s4
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	c4c080e7          	jalr	-948(ra) # 80003af6 <iunlockput>
      return 0;
    80003eb2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003eb4:	8552                	mv	a0,s4
    80003eb6:	60e6                	ld	ra,88(sp)
    80003eb8:	6446                	ld	s0,80(sp)
    80003eba:	64a6                	ld	s1,72(sp)
    80003ebc:	6906                	ld	s2,64(sp)
    80003ebe:	79e2                	ld	s3,56(sp)
    80003ec0:	7a42                	ld	s4,48(sp)
    80003ec2:	7aa2                	ld	s5,40(sp)
    80003ec4:	7b02                	ld	s6,32(sp)
    80003ec6:	6be2                	ld	s7,24(sp)
    80003ec8:	6c42                	ld	s8,16(sp)
    80003eca:	6ca2                	ld	s9,8(sp)
    80003ecc:	6d02                	ld	s10,0(sp)
    80003ece:	6125                	addi	sp,sp,96
    80003ed0:	8082                	ret
      iunlock(ip);
    80003ed2:	8552                	mv	a0,s4
    80003ed4:	00000097          	auipc	ra,0x0
    80003ed8:	a80080e7          	jalr	-1408(ra) # 80003954 <iunlock>
      return ip;
    80003edc:	bfe1                	j	80003eb4 <namex+0x6c>
      iunlockput(ip);
    80003ede:	8552                	mv	a0,s4
    80003ee0:	00000097          	auipc	ra,0x0
    80003ee4:	c16080e7          	jalr	-1002(ra) # 80003af6 <iunlockput>
      return 0;
    80003ee8:	8a4a                	mv	s4,s2
    80003eea:	b7e9                	j	80003eb4 <namex+0x6c>
  len = path - s;
    80003eec:	40990633          	sub	a2,s2,s1
    80003ef0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ef4:	09ac5c63          	bge	s8,s10,80003f8c <namex+0x144>
    memmove(name, s, DIRSIZ);
    80003ef8:	8666                	mv	a2,s9
    80003efa:	85a6                	mv	a1,s1
    80003efc:	8556                	mv	a0,s5
    80003efe:	ffffd097          	auipc	ra,0xffffd
    80003f02:	eb6080e7          	jalr	-330(ra) # 80000db4 <memmove>
    80003f06:	84ca                	mv	s1,s2
  while(*path == '/')
    80003f08:	0004c783          	lbu	a5,0(s1)
    80003f0c:	01379763          	bne	a5,s3,80003f1a <namex+0xd2>
    path++;
    80003f10:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f12:	0004c783          	lbu	a5,0(s1)
    80003f16:	ff378de3          	beq	a5,s3,80003f10 <namex+0xc8>
    ilock(ip);
    80003f1a:	8552                	mv	a0,s4
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	972080e7          	jalr	-1678(ra) # 8000388e <ilock>
    if(ip->type != T_DIR){
    80003f24:	044a1783          	lh	a5,68(s4)
    80003f28:	f97790e3          	bne	a5,s7,80003ea8 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003f2c:	000b0563          	beqz	s6,80003f36 <namex+0xee>
    80003f30:	0004c783          	lbu	a5,0(s1)
    80003f34:	dfd9                	beqz	a5,80003ed2 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f36:	4601                	li	a2,0
    80003f38:	85d6                	mv	a1,s5
    80003f3a:	8552                	mv	a0,s4
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	e4c080e7          	jalr	-436(ra) # 80003d88 <dirlookup>
    80003f44:	892a                	mv	s2,a0
    80003f46:	dd41                	beqz	a0,80003ede <namex+0x96>
    iunlockput(ip);
    80003f48:	8552                	mv	a0,s4
    80003f4a:	00000097          	auipc	ra,0x0
    80003f4e:	bac080e7          	jalr	-1108(ra) # 80003af6 <iunlockput>
    ip = next;
    80003f52:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003f54:	0004c783          	lbu	a5,0(s1)
    80003f58:	01379763          	bne	a5,s3,80003f66 <namex+0x11e>
    path++;
    80003f5c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f5e:	0004c783          	lbu	a5,0(s1)
    80003f62:	ff378de3          	beq	a5,s3,80003f5c <namex+0x114>
  if(*path == 0)
    80003f66:	cf9d                	beqz	a5,80003fa4 <namex+0x15c>
  while(*path != '/' && *path != 0)
    80003f68:	0004c783          	lbu	a5,0(s1)
    80003f6c:	fd178713          	addi	a4,a5,-47
    80003f70:	cb19                	beqz	a4,80003f86 <namex+0x13e>
    80003f72:	cb91                	beqz	a5,80003f86 <namex+0x13e>
    80003f74:	8926                	mv	s2,s1
    path++;
    80003f76:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003f78:	00094783          	lbu	a5,0(s2)
    80003f7c:	fd178713          	addi	a4,a5,-47
    80003f80:	d735                	beqz	a4,80003eec <namex+0xa4>
    80003f82:	fbf5                	bnez	a5,80003f76 <namex+0x12e>
    80003f84:	b7a5                	j	80003eec <namex+0xa4>
    80003f86:	8926                	mv	s2,s1
  len = path - s;
    80003f88:	4d01                	li	s10,0
    80003f8a:	4601                	li	a2,0
    memmove(name, s, len);
    80003f8c:	2601                	sext.w	a2,a2
    80003f8e:	85a6                	mv	a1,s1
    80003f90:	8556                	mv	a0,s5
    80003f92:	ffffd097          	auipc	ra,0xffffd
    80003f96:	e22080e7          	jalr	-478(ra) # 80000db4 <memmove>
    name[len] = 0;
    80003f9a:	9d56                	add	s10,s10,s5
    80003f9c:	000d0023          	sb	zero,0(s10)
    80003fa0:	84ca                	mv	s1,s2
    80003fa2:	b79d                	j	80003f08 <namex+0xc0>
  if(nameiparent){
    80003fa4:	f00b08e3          	beqz	s6,80003eb4 <namex+0x6c>
    iput(ip);
    80003fa8:	8552                	mv	a0,s4
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	aa2080e7          	jalr	-1374(ra) # 80003a4c <iput>
    return 0;
    80003fb2:	4a01                	li	s4,0
    80003fb4:	b701                	j	80003eb4 <namex+0x6c>

0000000080003fb6 <dirlink>:
{
    80003fb6:	715d                	addi	sp,sp,-80
    80003fb8:	e486                	sd	ra,72(sp)
    80003fba:	e0a2                	sd	s0,64(sp)
    80003fbc:	f84a                	sd	s2,48(sp)
    80003fbe:	ec56                	sd	s5,24(sp)
    80003fc0:	e85a                	sd	s6,16(sp)
    80003fc2:	0880                	addi	s0,sp,80
    80003fc4:	892a                	mv	s2,a0
    80003fc6:	8aae                	mv	s5,a1
    80003fc8:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fca:	4601                	li	a2,0
    80003fcc:	00000097          	auipc	ra,0x0
    80003fd0:	dbc080e7          	jalr	-580(ra) # 80003d88 <dirlookup>
    80003fd4:	e129                	bnez	a0,80004016 <dirlink+0x60>
    80003fd6:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd8:	04c92483          	lw	s1,76(s2)
    80003fdc:	cca9                	beqz	s1,80004036 <dirlink+0x80>
    80003fde:	f44e                	sd	s3,40(sp)
    80003fe0:	f052                	sd	s4,32(sp)
    80003fe2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe4:	fb040a13          	addi	s4,s0,-80
    80003fe8:	49c1                	li	s3,16
    80003fea:	874e                	mv	a4,s3
    80003fec:	86a6                	mv	a3,s1
    80003fee:	8652                	mv	a2,s4
    80003ff0:	4581                	li	a1,0
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	b58080e7          	jalr	-1192(ra) # 80003b4c <readi>
    80003ffc:	03351363          	bne	a0,s3,80004022 <dirlink+0x6c>
    if(de.inum == 0)
    80004000:	fb045783          	lhu	a5,-80(s0)
    80004004:	c79d                	beqz	a5,80004032 <dirlink+0x7c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004006:	24c1                	addiw	s1,s1,16
    80004008:	04c92783          	lw	a5,76(s2)
    8000400c:	fcf4efe3          	bltu	s1,a5,80003fea <dirlink+0x34>
    80004010:	79a2                	ld	s3,40(sp)
    80004012:	7a02                	ld	s4,32(sp)
    80004014:	a00d                	j	80004036 <dirlink+0x80>
    iput(ip);
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	a36080e7          	jalr	-1482(ra) # 80003a4c <iput>
    return -1;
    8000401e:	557d                	li	a0,-1
    80004020:	a0a9                	j	8000406a <dirlink+0xb4>
      panic("dirlink read");
    80004022:	00004517          	auipc	a0,0x4
    80004026:	4de50513          	addi	a0,a0,1246 # 80008500 <etext+0x500>
    8000402a:	ffffc097          	auipc	ra,0xffffc
    8000402e:	534080e7          	jalr	1332(ra) # 8000055e <panic>
    80004032:	79a2                	ld	s3,40(sp)
    80004034:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004036:	4639                	li	a2,14
    80004038:	85d6                	mv	a1,s5
    8000403a:	fb240513          	addi	a0,s0,-78
    8000403e:	ffffd097          	auipc	ra,0xffffd
    80004042:	e28080e7          	jalr	-472(ra) # 80000e66 <strncpy>
  de.inum = inum;
    80004046:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000404a:	4741                	li	a4,16
    8000404c:	86a6                	mv	a3,s1
    8000404e:	fb040613          	addi	a2,s0,-80
    80004052:	4581                	li	a1,0
    80004054:	854a                	mv	a0,s2
    80004056:	00000097          	auipc	ra,0x0
    8000405a:	bfc080e7          	jalr	-1028(ra) # 80003c52 <writei>
    8000405e:	1541                	addi	a0,a0,-16
    80004060:	00a03533          	snez	a0,a0
    80004064:	40a0053b          	negw	a0,a0
    80004068:	74e2                	ld	s1,56(sp)
}
    8000406a:	60a6                	ld	ra,72(sp)
    8000406c:	6406                	ld	s0,64(sp)
    8000406e:	7942                	ld	s2,48(sp)
    80004070:	6ae2                	ld	s5,24(sp)
    80004072:	6b42                	ld	s6,16(sp)
    80004074:	6161                	addi	sp,sp,80
    80004076:	8082                	ret

0000000080004078 <namei>:

struct inode*
namei(char *path)
{
    80004078:	1101                	addi	sp,sp,-32
    8000407a:	ec06                	sd	ra,24(sp)
    8000407c:	e822                	sd	s0,16(sp)
    8000407e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004080:	fe040613          	addi	a2,s0,-32
    80004084:	4581                	li	a1,0
    80004086:	00000097          	auipc	ra,0x0
    8000408a:	dc2080e7          	jalr	-574(ra) # 80003e48 <namex>
}
    8000408e:	60e2                	ld	ra,24(sp)
    80004090:	6442                	ld	s0,16(sp)
    80004092:	6105                	addi	sp,sp,32
    80004094:	8082                	ret

0000000080004096 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004096:	1141                	addi	sp,sp,-16
    80004098:	e406                	sd	ra,8(sp)
    8000409a:	e022                	sd	s0,0(sp)
    8000409c:	0800                	addi	s0,sp,16
    8000409e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040a0:	4585                	li	a1,1
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	da6080e7          	jalr	-602(ra) # 80003e48 <namex>
}
    800040aa:	60a2                	ld	ra,8(sp)
    800040ac:	6402                	ld	s0,0(sp)
    800040ae:	0141                	addi	sp,sp,16
    800040b0:	8082                	ret

00000000800040b2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040b2:	1101                	addi	sp,sp,-32
    800040b4:	ec06                	sd	ra,24(sp)
    800040b6:	e822                	sd	s0,16(sp)
    800040b8:	e426                	sd	s1,8(sp)
    800040ba:	e04a                	sd	s2,0(sp)
    800040bc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040be:	0001d917          	auipc	s2,0x1d
    800040c2:	e4290913          	addi	s2,s2,-446 # 80020f00 <log>
    800040c6:	01892583          	lw	a1,24(s2)
    800040ca:	02892503          	lw	a0,40(s2)
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	fc2080e7          	jalr	-62(ra) # 80003090 <bread>
    800040d6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040d8:	02c92603          	lw	a2,44(s2)
    800040dc:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040de:	00c05f63          	blez	a2,800040fc <write_head+0x4a>
    800040e2:	0001d717          	auipc	a4,0x1d
    800040e6:	e4e70713          	addi	a4,a4,-434 # 80020f30 <log+0x30>
    800040ea:	87aa                	mv	a5,a0
    800040ec:	060a                	slli	a2,a2,0x2
    800040ee:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040f0:	4314                	lw	a3,0(a4)
    800040f2:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040f4:	0711                	addi	a4,a4,4
    800040f6:	0791                	addi	a5,a5,4
    800040f8:	fec79ce3          	bne	a5,a2,800040f0 <write_head+0x3e>
  }
  bwrite(buf);
    800040fc:	8526                	mv	a0,s1
    800040fe:	fffff097          	auipc	ra,0xfffff
    80004102:	084080e7          	jalr	132(ra) # 80003182 <bwrite>
  brelse(buf);
    80004106:	8526                	mv	a0,s1
    80004108:	fffff097          	auipc	ra,0xfffff
    8000410c:	0b8080e7          	jalr	184(ra) # 800031c0 <brelse>
}
    80004110:	60e2                	ld	ra,24(sp)
    80004112:	6442                	ld	s0,16(sp)
    80004114:	64a2                	ld	s1,8(sp)
    80004116:	6902                	ld	s2,0(sp)
    80004118:	6105                	addi	sp,sp,32
    8000411a:	8082                	ret

000000008000411c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000411c:	0001d797          	auipc	a5,0x1d
    80004120:	e107a783          	lw	a5,-496(a5) # 80020f2c <log+0x2c>
    80004124:	0cf05063          	blez	a5,800041e4 <install_trans+0xc8>
{
    80004128:	715d                	addi	sp,sp,-80
    8000412a:	e486                	sd	ra,72(sp)
    8000412c:	e0a2                	sd	s0,64(sp)
    8000412e:	fc26                	sd	s1,56(sp)
    80004130:	f84a                	sd	s2,48(sp)
    80004132:	f44e                	sd	s3,40(sp)
    80004134:	f052                	sd	s4,32(sp)
    80004136:	ec56                	sd	s5,24(sp)
    80004138:	e85a                	sd	s6,16(sp)
    8000413a:	e45e                	sd	s7,8(sp)
    8000413c:	0880                	addi	s0,sp,80
    8000413e:	8b2a                	mv	s6,a0
    80004140:	0001da97          	auipc	s5,0x1d
    80004144:	df0a8a93          	addi	s5,s5,-528 # 80020f30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004148:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000414a:	0001d997          	auipc	s3,0x1d
    8000414e:	db698993          	addi	s3,s3,-586 # 80020f00 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004152:	40000b93          	li	s7,1024
    80004156:	a00d                	j	80004178 <install_trans+0x5c>
    brelse(lbuf);
    80004158:	854a                	mv	a0,s2
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	066080e7          	jalr	102(ra) # 800031c0 <brelse>
    brelse(dbuf);
    80004162:	8526                	mv	a0,s1
    80004164:	fffff097          	auipc	ra,0xfffff
    80004168:	05c080e7          	jalr	92(ra) # 800031c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000416c:	2a05                	addiw	s4,s4,1
    8000416e:	0a91                	addi	s5,s5,4
    80004170:	02c9a783          	lw	a5,44(s3)
    80004174:	04fa5d63          	bge	s4,a5,800041ce <install_trans+0xb2>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004178:	0189a583          	lw	a1,24(s3)
    8000417c:	014585bb          	addw	a1,a1,s4
    80004180:	2585                	addiw	a1,a1,1
    80004182:	0289a503          	lw	a0,40(s3)
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	f0a080e7          	jalr	-246(ra) # 80003090 <bread>
    8000418e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004190:	000aa583          	lw	a1,0(s5)
    80004194:	0289a503          	lw	a0,40(s3)
    80004198:	fffff097          	auipc	ra,0xfffff
    8000419c:	ef8080e7          	jalr	-264(ra) # 80003090 <bread>
    800041a0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041a2:	865e                	mv	a2,s7
    800041a4:	05890593          	addi	a1,s2,88
    800041a8:	05850513          	addi	a0,a0,88
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	c08080e7          	jalr	-1016(ra) # 80000db4 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041b4:	8526                	mv	a0,s1
    800041b6:	fffff097          	auipc	ra,0xfffff
    800041ba:	fcc080e7          	jalr	-52(ra) # 80003182 <bwrite>
    if(recovering == 0)
    800041be:	f80b1de3          	bnez	s6,80004158 <install_trans+0x3c>
      bunpin(dbuf);
    800041c2:	8526                	mv	a0,s1
    800041c4:	fffff097          	auipc	ra,0xfffff
    800041c8:	0d0080e7          	jalr	208(ra) # 80003294 <bunpin>
    800041cc:	b771                	j	80004158 <install_trans+0x3c>
}
    800041ce:	60a6                	ld	ra,72(sp)
    800041d0:	6406                	ld	s0,64(sp)
    800041d2:	74e2                	ld	s1,56(sp)
    800041d4:	7942                	ld	s2,48(sp)
    800041d6:	79a2                	ld	s3,40(sp)
    800041d8:	7a02                	ld	s4,32(sp)
    800041da:	6ae2                	ld	s5,24(sp)
    800041dc:	6b42                	ld	s6,16(sp)
    800041de:	6ba2                	ld	s7,8(sp)
    800041e0:	6161                	addi	sp,sp,80
    800041e2:	8082                	ret
    800041e4:	8082                	ret

00000000800041e6 <initlog>:
{
    800041e6:	7179                	addi	sp,sp,-48
    800041e8:	f406                	sd	ra,40(sp)
    800041ea:	f022                	sd	s0,32(sp)
    800041ec:	ec26                	sd	s1,24(sp)
    800041ee:	e84a                	sd	s2,16(sp)
    800041f0:	e44e                	sd	s3,8(sp)
    800041f2:	1800                	addi	s0,sp,48
    800041f4:	892a                	mv	s2,a0
    800041f6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041f8:	0001d497          	auipc	s1,0x1d
    800041fc:	d0848493          	addi	s1,s1,-760 # 80020f00 <log>
    80004200:	00004597          	auipc	a1,0x4
    80004204:	31058593          	addi	a1,a1,784 # 80008510 <etext+0x510>
    80004208:	8526                	mv	a0,s1
    8000420a:	ffffd097          	auipc	ra,0xffffd
    8000420e:	9b8080e7          	jalr	-1608(ra) # 80000bc2 <initlock>
  log.start = sb->logstart;
    80004212:	0149a583          	lw	a1,20(s3)
    80004216:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004218:	0109a783          	lw	a5,16(s3)
    8000421c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000421e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004222:	854a                	mv	a0,s2
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	e6c080e7          	jalr	-404(ra) # 80003090 <bread>
  log.lh.n = lh->n;
    8000422c:	4d30                	lw	a2,88(a0)
    8000422e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004230:	00c05f63          	blez	a2,8000424e <initlog+0x68>
    80004234:	87aa                	mv	a5,a0
    80004236:	0001d717          	auipc	a4,0x1d
    8000423a:	cfa70713          	addi	a4,a4,-774 # 80020f30 <log+0x30>
    8000423e:	060a                	slli	a2,a2,0x2
    80004240:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004242:	4ff4                	lw	a3,92(a5)
    80004244:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004246:	0791                	addi	a5,a5,4
    80004248:	0711                	addi	a4,a4,4
    8000424a:	fec79ce3          	bne	a5,a2,80004242 <initlog+0x5c>
  brelse(buf);
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	f72080e7          	jalr	-142(ra) # 800031c0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004256:	4505                	li	a0,1
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	ec4080e7          	jalr	-316(ra) # 8000411c <install_trans>
  log.lh.n = 0;
    80004260:	0001d797          	auipc	a5,0x1d
    80004264:	cc07a623          	sw	zero,-820(a5) # 80020f2c <log+0x2c>
  write_head(); // clear the log
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	e4a080e7          	jalr	-438(ra) # 800040b2 <write_head>
}
    80004270:	70a2                	ld	ra,40(sp)
    80004272:	7402                	ld	s0,32(sp)
    80004274:	64e2                	ld	s1,24(sp)
    80004276:	6942                	ld	s2,16(sp)
    80004278:	69a2                	ld	s3,8(sp)
    8000427a:	6145                	addi	sp,sp,48
    8000427c:	8082                	ret

000000008000427e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000427e:	1101                	addi	sp,sp,-32
    80004280:	ec06                	sd	ra,24(sp)
    80004282:	e822                	sd	s0,16(sp)
    80004284:	e426                	sd	s1,8(sp)
    80004286:	e04a                	sd	s2,0(sp)
    80004288:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000428a:	0001d517          	auipc	a0,0x1d
    8000428e:	c7650513          	addi	a0,a0,-906 # 80020f00 <log>
    80004292:	ffffd097          	auipc	ra,0xffffd
    80004296:	9ca080e7          	jalr	-1590(ra) # 80000c5c <acquire>
  while(1){
    if(log.committing){
    8000429a:	0001d497          	auipc	s1,0x1d
    8000429e:	c6648493          	addi	s1,s1,-922 # 80020f00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042a2:	4979                	li	s2,30
    800042a4:	a039                	j	800042b2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800042a6:	85a6                	mv	a1,s1
    800042a8:	8526                	mv	a0,s1
    800042aa:	ffffe097          	auipc	ra,0xffffe
    800042ae:	f7c080e7          	jalr	-132(ra) # 80002226 <sleep>
    if(log.committing){
    800042b2:	50dc                	lw	a5,36(s1)
    800042b4:	fbed                	bnez	a5,800042a6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042b6:	5098                	lw	a4,32(s1)
    800042b8:	2705                	addiw	a4,a4,1
    800042ba:	0027179b          	slliw	a5,a4,0x2
    800042be:	9fb9                	addw	a5,a5,a4
    800042c0:	0017979b          	slliw	a5,a5,0x1
    800042c4:	54d4                	lw	a3,44(s1)
    800042c6:	9fb5                	addw	a5,a5,a3
    800042c8:	00f95963          	bge	s2,a5,800042da <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042cc:	85a6                	mv	a1,s1
    800042ce:	8526                	mv	a0,s1
    800042d0:	ffffe097          	auipc	ra,0xffffe
    800042d4:	f56080e7          	jalr	-170(ra) # 80002226 <sleep>
    800042d8:	bfe9                	j	800042b2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042da:	0001d797          	auipc	a5,0x1d
    800042de:	c4e7a323          	sw	a4,-954(a5) # 80020f20 <log+0x20>
      release(&log.lock);
    800042e2:	0001d517          	auipc	a0,0x1d
    800042e6:	c1e50513          	addi	a0,a0,-994 # 80020f00 <log>
    800042ea:	ffffd097          	auipc	ra,0xffffd
    800042ee:	a22080e7          	jalr	-1502(ra) # 80000d0c <release>
      break;
    }
  }
}
    800042f2:	60e2                	ld	ra,24(sp)
    800042f4:	6442                	ld	s0,16(sp)
    800042f6:	64a2                	ld	s1,8(sp)
    800042f8:	6902                	ld	s2,0(sp)
    800042fa:	6105                	addi	sp,sp,32
    800042fc:	8082                	ret

00000000800042fe <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042fe:	7139                	addi	sp,sp,-64
    80004300:	fc06                	sd	ra,56(sp)
    80004302:	f822                	sd	s0,48(sp)
    80004304:	f426                	sd	s1,40(sp)
    80004306:	f04a                	sd	s2,32(sp)
    80004308:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000430a:	0001d497          	auipc	s1,0x1d
    8000430e:	bf648493          	addi	s1,s1,-1034 # 80020f00 <log>
    80004312:	8526                	mv	a0,s1
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	948080e7          	jalr	-1720(ra) # 80000c5c <acquire>
  log.outstanding -= 1;
    8000431c:	509c                	lw	a5,32(s1)
    8000431e:	37fd                	addiw	a5,a5,-1
    80004320:	893e                	mv	s2,a5
    80004322:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004324:	50dc                	lw	a5,36(s1)
    80004326:	efb1                	bnez	a5,80004382 <end_op+0x84>
    panic("log.committing");
  if(log.outstanding == 0){
    80004328:	06091863          	bnez	s2,80004398 <end_op+0x9a>
    do_commit = 1;
    log.committing = 1;
    8000432c:	0001d497          	auipc	s1,0x1d
    80004330:	bd448493          	addi	s1,s1,-1068 # 80020f00 <log>
    80004334:	4785                	li	a5,1
    80004336:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004338:	8526                	mv	a0,s1
    8000433a:	ffffd097          	auipc	ra,0xffffd
    8000433e:	9d2080e7          	jalr	-1582(ra) # 80000d0c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004342:	54dc                	lw	a5,44(s1)
    80004344:	08f04063          	bgtz	a5,800043c4 <end_op+0xc6>
    acquire(&log.lock);
    80004348:	0001d517          	auipc	a0,0x1d
    8000434c:	bb850513          	addi	a0,a0,-1096 # 80020f00 <log>
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	90c080e7          	jalr	-1780(ra) # 80000c5c <acquire>
    log.committing = 0;
    80004358:	0001d797          	auipc	a5,0x1d
    8000435c:	bc07a623          	sw	zero,-1076(a5) # 80020f24 <log+0x24>
    wakeup(&log);
    80004360:	0001d517          	auipc	a0,0x1d
    80004364:	ba050513          	addi	a0,a0,-1120 # 80020f00 <log>
    80004368:	ffffe097          	auipc	ra,0xffffe
    8000436c:	f22080e7          	jalr	-222(ra) # 8000228a <wakeup>
    release(&log.lock);
    80004370:	0001d517          	auipc	a0,0x1d
    80004374:	b9050513          	addi	a0,a0,-1136 # 80020f00 <log>
    80004378:	ffffd097          	auipc	ra,0xffffd
    8000437c:	994080e7          	jalr	-1644(ra) # 80000d0c <release>
}
    80004380:	a825                	j	800043b8 <end_op+0xba>
    80004382:	ec4e                	sd	s3,24(sp)
    80004384:	e852                	sd	s4,16(sp)
    80004386:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004388:	00004517          	auipc	a0,0x4
    8000438c:	19050513          	addi	a0,a0,400 # 80008518 <etext+0x518>
    80004390:	ffffc097          	auipc	ra,0xffffc
    80004394:	1ce080e7          	jalr	462(ra) # 8000055e <panic>
    wakeup(&log);
    80004398:	0001d517          	auipc	a0,0x1d
    8000439c:	b6850513          	addi	a0,a0,-1176 # 80020f00 <log>
    800043a0:	ffffe097          	auipc	ra,0xffffe
    800043a4:	eea080e7          	jalr	-278(ra) # 8000228a <wakeup>
  release(&log.lock);
    800043a8:	0001d517          	auipc	a0,0x1d
    800043ac:	b5850513          	addi	a0,a0,-1192 # 80020f00 <log>
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	95c080e7          	jalr	-1700(ra) # 80000d0c <release>
}
    800043b8:	70e2                	ld	ra,56(sp)
    800043ba:	7442                	ld	s0,48(sp)
    800043bc:	74a2                	ld	s1,40(sp)
    800043be:	7902                	ld	s2,32(sp)
    800043c0:	6121                	addi	sp,sp,64
    800043c2:	8082                	ret
    800043c4:	ec4e                	sd	s3,24(sp)
    800043c6:	e852                	sd	s4,16(sp)
    800043c8:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800043ca:	0001da97          	auipc	s5,0x1d
    800043ce:	b66a8a93          	addi	s5,s5,-1178 # 80020f30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043d2:	0001da17          	auipc	s4,0x1d
    800043d6:	b2ea0a13          	addi	s4,s4,-1234 # 80020f00 <log>
    800043da:	018a2583          	lw	a1,24(s4)
    800043de:	012585bb          	addw	a1,a1,s2
    800043e2:	2585                	addiw	a1,a1,1
    800043e4:	028a2503          	lw	a0,40(s4)
    800043e8:	fffff097          	auipc	ra,0xfffff
    800043ec:	ca8080e7          	jalr	-856(ra) # 80003090 <bread>
    800043f0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043f2:	000aa583          	lw	a1,0(s5)
    800043f6:	028a2503          	lw	a0,40(s4)
    800043fa:	fffff097          	auipc	ra,0xfffff
    800043fe:	c96080e7          	jalr	-874(ra) # 80003090 <bread>
    80004402:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004404:	40000613          	li	a2,1024
    80004408:	05850593          	addi	a1,a0,88
    8000440c:	05848513          	addi	a0,s1,88
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	9a4080e7          	jalr	-1628(ra) # 80000db4 <memmove>
    bwrite(to);  // write the log
    80004418:	8526                	mv	a0,s1
    8000441a:	fffff097          	auipc	ra,0xfffff
    8000441e:	d68080e7          	jalr	-664(ra) # 80003182 <bwrite>
    brelse(from);
    80004422:	854e                	mv	a0,s3
    80004424:	fffff097          	auipc	ra,0xfffff
    80004428:	d9c080e7          	jalr	-612(ra) # 800031c0 <brelse>
    brelse(to);
    8000442c:	8526                	mv	a0,s1
    8000442e:	fffff097          	auipc	ra,0xfffff
    80004432:	d92080e7          	jalr	-622(ra) # 800031c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004436:	2905                	addiw	s2,s2,1
    80004438:	0a91                	addi	s5,s5,4
    8000443a:	02ca2783          	lw	a5,44(s4)
    8000443e:	f8f94ee3          	blt	s2,a5,800043da <end_op+0xdc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004442:	00000097          	auipc	ra,0x0
    80004446:	c70080e7          	jalr	-912(ra) # 800040b2 <write_head>
    install_trans(0); // Now install writes to home locations
    8000444a:	4501                	li	a0,0
    8000444c:	00000097          	auipc	ra,0x0
    80004450:	cd0080e7          	jalr	-816(ra) # 8000411c <install_trans>
    log.lh.n = 0;
    80004454:	0001d797          	auipc	a5,0x1d
    80004458:	ac07ac23          	sw	zero,-1320(a5) # 80020f2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	c56080e7          	jalr	-938(ra) # 800040b2 <write_head>
    80004464:	69e2                	ld	s3,24(sp)
    80004466:	6a42                	ld	s4,16(sp)
    80004468:	6aa2                	ld	s5,8(sp)
    8000446a:	bdf9                	j	80004348 <end_op+0x4a>

000000008000446c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000446c:	1101                	addi	sp,sp,-32
    8000446e:	ec06                	sd	ra,24(sp)
    80004470:	e822                	sd	s0,16(sp)
    80004472:	e426                	sd	s1,8(sp)
    80004474:	1000                	addi	s0,sp,32
    80004476:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004478:	0001d517          	auipc	a0,0x1d
    8000447c:	a8850513          	addi	a0,a0,-1400 # 80020f00 <log>
    80004480:	ffffc097          	auipc	ra,0xffffc
    80004484:	7dc080e7          	jalr	2012(ra) # 80000c5c <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004488:	0001d617          	auipc	a2,0x1d
    8000448c:	aa462603          	lw	a2,-1372(a2) # 80020f2c <log+0x2c>
    80004490:	47f5                	li	a5,29
    80004492:	06c7c663          	blt	a5,a2,800044fe <log_write+0x92>
    80004496:	0001d797          	auipc	a5,0x1d
    8000449a:	a867a783          	lw	a5,-1402(a5) # 80020f1c <log+0x1c>
    8000449e:	37fd                	addiw	a5,a5,-1
    800044a0:	04f65f63          	bge	a2,a5,800044fe <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044a4:	0001d797          	auipc	a5,0x1d
    800044a8:	a7c7a783          	lw	a5,-1412(a5) # 80020f20 <log+0x20>
    800044ac:	06f05163          	blez	a5,8000450e <log_write+0xa2>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044b0:	4781                	li	a5,0
    800044b2:	06c05663          	blez	a2,8000451e <log_write+0xb2>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044b6:	44cc                	lw	a1,12(s1)
    800044b8:	0001d717          	auipc	a4,0x1d
    800044bc:	a7870713          	addi	a4,a4,-1416 # 80020f30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044c0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044c2:	4314                	lw	a3,0(a4)
    800044c4:	04b68d63          	beq	a3,a1,8000451e <log_write+0xb2>
  for (i = 0; i < log.lh.n; i++) {
    800044c8:	2785                	addiw	a5,a5,1
    800044ca:	0711                	addi	a4,a4,4
    800044cc:	fef61be3          	bne	a2,a5,800044c2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044d0:	060a                	slli	a2,a2,0x2
    800044d2:	02060613          	addi	a2,a2,32
    800044d6:	0001d797          	auipc	a5,0x1d
    800044da:	a2a78793          	addi	a5,a5,-1494 # 80020f00 <log>
    800044de:	97b2                	add	a5,a5,a2
    800044e0:	44d8                	lw	a4,12(s1)
    800044e2:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044e4:	8526                	mv	a0,s1
    800044e6:	fffff097          	auipc	ra,0xfffff
    800044ea:	d72080e7          	jalr	-654(ra) # 80003258 <bpin>
    log.lh.n++;
    800044ee:	0001d717          	auipc	a4,0x1d
    800044f2:	a1270713          	addi	a4,a4,-1518 # 80020f00 <log>
    800044f6:	575c                	lw	a5,44(a4)
    800044f8:	2785                	addiw	a5,a5,1
    800044fa:	d75c                	sw	a5,44(a4)
    800044fc:	a835                	j	80004538 <log_write+0xcc>
    panic("too big a transaction");
    800044fe:	00004517          	auipc	a0,0x4
    80004502:	02a50513          	addi	a0,a0,42 # 80008528 <etext+0x528>
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	058080e7          	jalr	88(ra) # 8000055e <panic>
    panic("log_write outside of trans");
    8000450e:	00004517          	auipc	a0,0x4
    80004512:	03250513          	addi	a0,a0,50 # 80008540 <etext+0x540>
    80004516:	ffffc097          	auipc	ra,0xffffc
    8000451a:	048080e7          	jalr	72(ra) # 8000055e <panic>
  log.lh.block[i] = b->blockno;
    8000451e:	00279693          	slli	a3,a5,0x2
    80004522:	02068693          	addi	a3,a3,32
    80004526:	0001d717          	auipc	a4,0x1d
    8000452a:	9da70713          	addi	a4,a4,-1574 # 80020f00 <log>
    8000452e:	9736                	add	a4,a4,a3
    80004530:	44d4                	lw	a3,12(s1)
    80004532:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004534:	faf608e3          	beq	a2,a5,800044e4 <log_write+0x78>
  }
  release(&log.lock);
    80004538:	0001d517          	auipc	a0,0x1d
    8000453c:	9c850513          	addi	a0,a0,-1592 # 80020f00 <log>
    80004540:	ffffc097          	auipc	ra,0xffffc
    80004544:	7cc080e7          	jalr	1996(ra) # 80000d0c <release>
}
    80004548:	60e2                	ld	ra,24(sp)
    8000454a:	6442                	ld	s0,16(sp)
    8000454c:	64a2                	ld	s1,8(sp)
    8000454e:	6105                	addi	sp,sp,32
    80004550:	8082                	ret

0000000080004552 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004552:	1101                	addi	sp,sp,-32
    80004554:	ec06                	sd	ra,24(sp)
    80004556:	e822                	sd	s0,16(sp)
    80004558:	e426                	sd	s1,8(sp)
    8000455a:	e04a                	sd	s2,0(sp)
    8000455c:	1000                	addi	s0,sp,32
    8000455e:	84aa                	mv	s1,a0
    80004560:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004562:	00004597          	auipc	a1,0x4
    80004566:	ffe58593          	addi	a1,a1,-2 # 80008560 <etext+0x560>
    8000456a:	0521                	addi	a0,a0,8
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	656080e7          	jalr	1622(ra) # 80000bc2 <initlock>
  lk->name = name;
    80004574:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004578:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000457c:	0204a423          	sw	zero,40(s1)
}
    80004580:	60e2                	ld	ra,24(sp)
    80004582:	6442                	ld	s0,16(sp)
    80004584:	64a2                	ld	s1,8(sp)
    80004586:	6902                	ld	s2,0(sp)
    80004588:	6105                	addi	sp,sp,32
    8000458a:	8082                	ret

000000008000458c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000458c:	1101                	addi	sp,sp,-32
    8000458e:	ec06                	sd	ra,24(sp)
    80004590:	e822                	sd	s0,16(sp)
    80004592:	e426                	sd	s1,8(sp)
    80004594:	e04a                	sd	s2,0(sp)
    80004596:	1000                	addi	s0,sp,32
    80004598:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000459a:	00850913          	addi	s2,a0,8
    8000459e:	854a                	mv	a0,s2
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	6bc080e7          	jalr	1724(ra) # 80000c5c <acquire>
  while (lk->locked) {
    800045a8:	409c                	lw	a5,0(s1)
    800045aa:	cb89                	beqz	a5,800045bc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045ac:	85ca                	mv	a1,s2
    800045ae:	8526                	mv	a0,s1
    800045b0:	ffffe097          	auipc	ra,0xffffe
    800045b4:	c76080e7          	jalr	-906(ra) # 80002226 <sleep>
  while (lk->locked) {
    800045b8:	409c                	lw	a5,0(s1)
    800045ba:	fbed                	bnez	a5,800045ac <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045bc:	4785                	li	a5,1
    800045be:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045c0:	ffffd097          	auipc	ra,0xffffd
    800045c4:	540080e7          	jalr	1344(ra) # 80001b00 <myproc>
    800045c8:	591c                	lw	a5,48(a0)
    800045ca:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045cc:	854a                	mv	a0,s2
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	73e080e7          	jalr	1854(ra) # 80000d0c <release>
}
    800045d6:	60e2                	ld	ra,24(sp)
    800045d8:	6442                	ld	s0,16(sp)
    800045da:	64a2                	ld	s1,8(sp)
    800045dc:	6902                	ld	s2,0(sp)
    800045de:	6105                	addi	sp,sp,32
    800045e0:	8082                	ret

00000000800045e2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045e2:	1101                	addi	sp,sp,-32
    800045e4:	ec06                	sd	ra,24(sp)
    800045e6:	e822                	sd	s0,16(sp)
    800045e8:	e426                	sd	s1,8(sp)
    800045ea:	e04a                	sd	s2,0(sp)
    800045ec:	1000                	addi	s0,sp,32
    800045ee:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045f0:	00850913          	addi	s2,a0,8
    800045f4:	854a                	mv	a0,s2
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	666080e7          	jalr	1638(ra) # 80000c5c <acquire>
  lk->locked = 0;
    800045fe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004602:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004606:	8526                	mv	a0,s1
    80004608:	ffffe097          	auipc	ra,0xffffe
    8000460c:	c82080e7          	jalr	-894(ra) # 8000228a <wakeup>
  release(&lk->lk);
    80004610:	854a                	mv	a0,s2
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	6fa080e7          	jalr	1786(ra) # 80000d0c <release>
}
    8000461a:	60e2                	ld	ra,24(sp)
    8000461c:	6442                	ld	s0,16(sp)
    8000461e:	64a2                	ld	s1,8(sp)
    80004620:	6902                	ld	s2,0(sp)
    80004622:	6105                	addi	sp,sp,32
    80004624:	8082                	ret

0000000080004626 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004626:	7179                	addi	sp,sp,-48
    80004628:	f406                	sd	ra,40(sp)
    8000462a:	f022                	sd	s0,32(sp)
    8000462c:	ec26                	sd	s1,24(sp)
    8000462e:	e84a                	sd	s2,16(sp)
    80004630:	1800                	addi	s0,sp,48
    80004632:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004634:	00850913          	addi	s2,a0,8
    80004638:	854a                	mv	a0,s2
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	622080e7          	jalr	1570(ra) # 80000c5c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004642:	409c                	lw	a5,0(s1)
    80004644:	ef91                	bnez	a5,80004660 <holdingsleep+0x3a>
    80004646:	4481                	li	s1,0
  release(&lk->lk);
    80004648:	854a                	mv	a0,s2
    8000464a:	ffffc097          	auipc	ra,0xffffc
    8000464e:	6c2080e7          	jalr	1730(ra) # 80000d0c <release>
  return r;
}
    80004652:	8526                	mv	a0,s1
    80004654:	70a2                	ld	ra,40(sp)
    80004656:	7402                	ld	s0,32(sp)
    80004658:	64e2                	ld	s1,24(sp)
    8000465a:	6942                	ld	s2,16(sp)
    8000465c:	6145                	addi	sp,sp,48
    8000465e:	8082                	ret
    80004660:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004662:	0284a983          	lw	s3,40(s1)
    80004666:	ffffd097          	auipc	ra,0xffffd
    8000466a:	49a080e7          	jalr	1178(ra) # 80001b00 <myproc>
    8000466e:	5904                	lw	s1,48(a0)
    80004670:	413484b3          	sub	s1,s1,s3
    80004674:	0014b493          	seqz	s1,s1
    80004678:	69a2                	ld	s3,8(sp)
    8000467a:	b7f9                	j	80004648 <holdingsleep+0x22>

000000008000467c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000467c:	1141                	addi	sp,sp,-16
    8000467e:	e406                	sd	ra,8(sp)
    80004680:	e022                	sd	s0,0(sp)
    80004682:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004684:	00004597          	auipc	a1,0x4
    80004688:	eec58593          	addi	a1,a1,-276 # 80008570 <etext+0x570>
    8000468c:	0001d517          	auipc	a0,0x1d
    80004690:	9bc50513          	addi	a0,a0,-1604 # 80021048 <ftable>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	52e080e7          	jalr	1326(ra) # 80000bc2 <initlock>
}
    8000469c:	60a2                	ld	ra,8(sp)
    8000469e:	6402                	ld	s0,0(sp)
    800046a0:	0141                	addi	sp,sp,16
    800046a2:	8082                	ret

00000000800046a4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046a4:	1101                	addi	sp,sp,-32
    800046a6:	ec06                	sd	ra,24(sp)
    800046a8:	e822                	sd	s0,16(sp)
    800046aa:	e426                	sd	s1,8(sp)
    800046ac:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046ae:	0001d517          	auipc	a0,0x1d
    800046b2:	99a50513          	addi	a0,a0,-1638 # 80021048 <ftable>
    800046b6:	ffffc097          	auipc	ra,0xffffc
    800046ba:	5a6080e7          	jalr	1446(ra) # 80000c5c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046be:	0001d497          	auipc	s1,0x1d
    800046c2:	9a248493          	addi	s1,s1,-1630 # 80021060 <ftable+0x18>
    800046c6:	0001e717          	auipc	a4,0x1e
    800046ca:	93a70713          	addi	a4,a4,-1734 # 80022000 <disk>
    if(f->ref == 0){
    800046ce:	40dc                	lw	a5,4(s1)
    800046d0:	cf99                	beqz	a5,800046ee <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d2:	02848493          	addi	s1,s1,40
    800046d6:	fee49ce3          	bne	s1,a4,800046ce <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046da:	0001d517          	auipc	a0,0x1d
    800046de:	96e50513          	addi	a0,a0,-1682 # 80021048 <ftable>
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	62a080e7          	jalr	1578(ra) # 80000d0c <release>
  return 0;
    800046ea:	4481                	li	s1,0
    800046ec:	a819                	j	80004702 <filealloc+0x5e>
      f->ref = 1;
    800046ee:	4785                	li	a5,1
    800046f0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046f2:	0001d517          	auipc	a0,0x1d
    800046f6:	95650513          	addi	a0,a0,-1706 # 80021048 <ftable>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	612080e7          	jalr	1554(ra) # 80000d0c <release>
}
    80004702:	8526                	mv	a0,s1
    80004704:	60e2                	ld	ra,24(sp)
    80004706:	6442                	ld	s0,16(sp)
    80004708:	64a2                	ld	s1,8(sp)
    8000470a:	6105                	addi	sp,sp,32
    8000470c:	8082                	ret

000000008000470e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000470e:	1101                	addi	sp,sp,-32
    80004710:	ec06                	sd	ra,24(sp)
    80004712:	e822                	sd	s0,16(sp)
    80004714:	e426                	sd	s1,8(sp)
    80004716:	1000                	addi	s0,sp,32
    80004718:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000471a:	0001d517          	auipc	a0,0x1d
    8000471e:	92e50513          	addi	a0,a0,-1746 # 80021048 <ftable>
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	53a080e7          	jalr	1338(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    8000472a:	40dc                	lw	a5,4(s1)
    8000472c:	02f05263          	blez	a5,80004750 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004730:	2785                	addiw	a5,a5,1
    80004732:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004734:	0001d517          	auipc	a0,0x1d
    80004738:	91450513          	addi	a0,a0,-1772 # 80021048 <ftable>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	5d0080e7          	jalr	1488(ra) # 80000d0c <release>
  return f;
}
    80004744:	8526                	mv	a0,s1
    80004746:	60e2                	ld	ra,24(sp)
    80004748:	6442                	ld	s0,16(sp)
    8000474a:	64a2                	ld	s1,8(sp)
    8000474c:	6105                	addi	sp,sp,32
    8000474e:	8082                	ret
    panic("filedup");
    80004750:	00004517          	auipc	a0,0x4
    80004754:	e2850513          	addi	a0,a0,-472 # 80008578 <etext+0x578>
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	e06080e7          	jalr	-506(ra) # 8000055e <panic>

0000000080004760 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004760:	7139                	addi	sp,sp,-64
    80004762:	fc06                	sd	ra,56(sp)
    80004764:	f822                	sd	s0,48(sp)
    80004766:	f426                	sd	s1,40(sp)
    80004768:	0080                	addi	s0,sp,64
    8000476a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000476c:	0001d517          	auipc	a0,0x1d
    80004770:	8dc50513          	addi	a0,a0,-1828 # 80021048 <ftable>
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	4e8080e7          	jalr	1256(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    8000477c:	40dc                	lw	a5,4(s1)
    8000477e:	04f05c63          	blez	a5,800047d6 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004782:	37fd                	addiw	a5,a5,-1
    80004784:	c0dc                	sw	a5,4(s1)
    80004786:	06f04463          	bgtz	a5,800047ee <fileclose+0x8e>
    8000478a:	f04a                	sd	s2,32(sp)
    8000478c:	ec4e                	sd	s3,24(sp)
    8000478e:	e852                	sd	s4,16(sp)
    80004790:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004792:	0004a903          	lw	s2,0(s1)
    80004796:	0094c783          	lbu	a5,9(s1)
    8000479a:	89be                	mv	s3,a5
    8000479c:	689c                	ld	a5,16(s1)
    8000479e:	8a3e                	mv	s4,a5
    800047a0:	6c9c                	ld	a5,24(s1)
    800047a2:	8abe                	mv	s5,a5
  f->ref = 0;
    800047a4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047a8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047ac:	0001d517          	auipc	a0,0x1d
    800047b0:	89c50513          	addi	a0,a0,-1892 # 80021048 <ftable>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	558080e7          	jalr	1368(ra) # 80000d0c <release>

  if(ff.type == FD_PIPE){
    800047bc:	4785                	li	a5,1
    800047be:	04f90563          	beq	s2,a5,80004808 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047c2:	ffe9079b          	addiw	a5,s2,-2
    800047c6:	4705                	li	a4,1
    800047c8:	04f77b63          	bgeu	a4,a5,8000481e <fileclose+0xbe>
    800047cc:	7902                	ld	s2,32(sp)
    800047ce:	69e2                	ld	s3,24(sp)
    800047d0:	6a42                	ld	s4,16(sp)
    800047d2:	6aa2                	ld	s5,8(sp)
    800047d4:	a02d                	j	800047fe <fileclose+0x9e>
    800047d6:	f04a                	sd	s2,32(sp)
    800047d8:	ec4e                	sd	s3,24(sp)
    800047da:	e852                	sd	s4,16(sp)
    800047dc:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800047de:	00004517          	auipc	a0,0x4
    800047e2:	da250513          	addi	a0,a0,-606 # 80008580 <etext+0x580>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	d78080e7          	jalr	-648(ra) # 8000055e <panic>
    release(&ftable.lock);
    800047ee:	0001d517          	auipc	a0,0x1d
    800047f2:	85a50513          	addi	a0,a0,-1958 # 80021048 <ftable>
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	516080e7          	jalr	1302(ra) # 80000d0c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800047fe:	70e2                	ld	ra,56(sp)
    80004800:	7442                	ld	s0,48(sp)
    80004802:	74a2                	ld	s1,40(sp)
    80004804:	6121                	addi	sp,sp,64
    80004806:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004808:	85ce                	mv	a1,s3
    8000480a:	8552                	mv	a0,s4
    8000480c:	00000097          	auipc	ra,0x0
    80004810:	3b4080e7          	jalr	948(ra) # 80004bc0 <pipeclose>
    80004814:	7902                	ld	s2,32(sp)
    80004816:	69e2                	ld	s3,24(sp)
    80004818:	6a42                	ld	s4,16(sp)
    8000481a:	6aa2                	ld	s5,8(sp)
    8000481c:	b7cd                	j	800047fe <fileclose+0x9e>
    begin_op();
    8000481e:	00000097          	auipc	ra,0x0
    80004822:	a60080e7          	jalr	-1440(ra) # 8000427e <begin_op>
    iput(ff.ip);
    80004826:	8556                	mv	a0,s5
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	224080e7          	jalr	548(ra) # 80003a4c <iput>
    end_op();
    80004830:	00000097          	auipc	ra,0x0
    80004834:	ace080e7          	jalr	-1330(ra) # 800042fe <end_op>
    80004838:	7902                	ld	s2,32(sp)
    8000483a:	69e2                	ld	s3,24(sp)
    8000483c:	6a42                	ld	s4,16(sp)
    8000483e:	6aa2                	ld	s5,8(sp)
    80004840:	bf7d                	j	800047fe <fileclose+0x9e>

0000000080004842 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004842:	715d                	addi	sp,sp,-80
    80004844:	e486                	sd	ra,72(sp)
    80004846:	e0a2                	sd	s0,64(sp)
    80004848:	fc26                	sd	s1,56(sp)
    8000484a:	f052                	sd	s4,32(sp)
    8000484c:	0880                	addi	s0,sp,80
    8000484e:	84aa                	mv	s1,a0
    80004850:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004852:	ffffd097          	auipc	ra,0xffffd
    80004856:	2ae080e7          	jalr	686(ra) # 80001b00 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000485a:	409c                	lw	a5,0(s1)
    8000485c:	37f9                	addiw	a5,a5,-2
    8000485e:	4705                	li	a4,1
    80004860:	04f76a63          	bltu	a4,a5,800048b4 <filestat+0x72>
    80004864:	f84a                	sd	s2,48(sp)
    80004866:	f44e                	sd	s3,40(sp)
    80004868:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000486a:	6c88                	ld	a0,24(s1)
    8000486c:	fffff097          	auipc	ra,0xfffff
    80004870:	022080e7          	jalr	34(ra) # 8000388e <ilock>
    stati(f->ip, &st);
    80004874:	fb840913          	addi	s2,s0,-72
    80004878:	85ca                	mv	a1,s2
    8000487a:	6c88                	ld	a0,24(s1)
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	2a2080e7          	jalr	674(ra) # 80003b1e <stati>
    iunlock(f->ip);
    80004884:	6c88                	ld	a0,24(s1)
    80004886:	fffff097          	auipc	ra,0xfffff
    8000488a:	0ce080e7          	jalr	206(ra) # 80003954 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000488e:	46e1                	li	a3,24
    80004890:	864a                	mv	a2,s2
    80004892:	85d2                	mv	a1,s4
    80004894:	0509b503          	ld	a0,80(s3)
    80004898:	ffffd097          	auipc	ra,0xffffd
    8000489c:	e80080e7          	jalr	-384(ra) # 80001718 <copyout>
    800048a0:	41f5551b          	sraiw	a0,a0,0x1f
    800048a4:	7942                	ld	s2,48(sp)
    800048a6:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800048a8:	60a6                	ld	ra,72(sp)
    800048aa:	6406                	ld	s0,64(sp)
    800048ac:	74e2                	ld	s1,56(sp)
    800048ae:	7a02                	ld	s4,32(sp)
    800048b0:	6161                	addi	sp,sp,80
    800048b2:	8082                	ret
  return -1;
    800048b4:	557d                	li	a0,-1
    800048b6:	bfcd                	j	800048a8 <filestat+0x66>

00000000800048b8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048b8:	7179                	addi	sp,sp,-48
    800048ba:	f406                	sd	ra,40(sp)
    800048bc:	f022                	sd	s0,32(sp)
    800048be:	e84a                	sd	s2,16(sp)
    800048c0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048c2:	00854783          	lbu	a5,8(a0)
    800048c6:	cbc5                	beqz	a5,80004976 <fileread+0xbe>
    800048c8:	ec26                	sd	s1,24(sp)
    800048ca:	e44e                	sd	s3,8(sp)
    800048cc:	84aa                	mv	s1,a0
    800048ce:	892e                	mv	s2,a1
    800048d0:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800048d2:	411c                	lw	a5,0(a0)
    800048d4:	4705                	li	a4,1
    800048d6:	04e78963          	beq	a5,a4,80004928 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048da:	470d                	li	a4,3
    800048dc:	04e78f63          	beq	a5,a4,8000493a <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048e0:	4709                	li	a4,2
    800048e2:	08e79263          	bne	a5,a4,80004966 <fileread+0xae>
    ilock(f->ip);
    800048e6:	6d08                	ld	a0,24(a0)
    800048e8:	fffff097          	auipc	ra,0xfffff
    800048ec:	fa6080e7          	jalr	-90(ra) # 8000388e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048f0:	874e                	mv	a4,s3
    800048f2:	5094                	lw	a3,32(s1)
    800048f4:	864a                	mv	a2,s2
    800048f6:	4585                	li	a1,1
    800048f8:	6c88                	ld	a0,24(s1)
    800048fa:	fffff097          	auipc	ra,0xfffff
    800048fe:	252080e7          	jalr	594(ra) # 80003b4c <readi>
    80004902:	892a                	mv	s2,a0
    80004904:	00a05563          	blez	a0,8000490e <fileread+0x56>
      f->off += r;
    80004908:	509c                	lw	a5,32(s1)
    8000490a:	9fa9                	addw	a5,a5,a0
    8000490c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000490e:	6c88                	ld	a0,24(s1)
    80004910:	fffff097          	auipc	ra,0xfffff
    80004914:	044080e7          	jalr	68(ra) # 80003954 <iunlock>
    80004918:	64e2                	ld	s1,24(sp)
    8000491a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000491c:	854a                	mv	a0,s2
    8000491e:	70a2                	ld	ra,40(sp)
    80004920:	7402                	ld	s0,32(sp)
    80004922:	6942                	ld	s2,16(sp)
    80004924:	6145                	addi	sp,sp,48
    80004926:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004928:	6908                	ld	a0,16(a0)
    8000492a:	00000097          	auipc	ra,0x0
    8000492e:	428080e7          	jalr	1064(ra) # 80004d52 <piperead>
    80004932:	892a                	mv	s2,a0
    80004934:	64e2                	ld	s1,24(sp)
    80004936:	69a2                	ld	s3,8(sp)
    80004938:	b7d5                	j	8000491c <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000493a:	02451783          	lh	a5,36(a0)
    8000493e:	03079693          	slli	a3,a5,0x30
    80004942:	92c1                	srli	a3,a3,0x30
    80004944:	4725                	li	a4,9
    80004946:	02d76b63          	bltu	a4,a3,8000497c <fileread+0xc4>
    8000494a:	0792                	slli	a5,a5,0x4
    8000494c:	0001c717          	auipc	a4,0x1c
    80004950:	65c70713          	addi	a4,a4,1628 # 80020fa8 <devsw>
    80004954:	97ba                	add	a5,a5,a4
    80004956:	639c                	ld	a5,0(a5)
    80004958:	c79d                	beqz	a5,80004986 <fileread+0xce>
    r = devsw[f->major].read(1, addr, n);
    8000495a:	4505                	li	a0,1
    8000495c:	9782                	jalr	a5
    8000495e:	892a                	mv	s2,a0
    80004960:	64e2                	ld	s1,24(sp)
    80004962:	69a2                	ld	s3,8(sp)
    80004964:	bf65                	j	8000491c <fileread+0x64>
    panic("fileread");
    80004966:	00004517          	auipc	a0,0x4
    8000496a:	c2a50513          	addi	a0,a0,-982 # 80008590 <etext+0x590>
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	bf0080e7          	jalr	-1040(ra) # 8000055e <panic>
    return -1;
    80004976:	57fd                	li	a5,-1
    80004978:	893e                	mv	s2,a5
    8000497a:	b74d                	j	8000491c <fileread+0x64>
      return -1;
    8000497c:	57fd                	li	a5,-1
    8000497e:	893e                	mv	s2,a5
    80004980:	64e2                	ld	s1,24(sp)
    80004982:	69a2                	ld	s3,8(sp)
    80004984:	bf61                	j	8000491c <fileread+0x64>
    80004986:	57fd                	li	a5,-1
    80004988:	893e                	mv	s2,a5
    8000498a:	64e2                	ld	s1,24(sp)
    8000498c:	69a2                	ld	s3,8(sp)
    8000498e:	b779                	j	8000491c <fileread+0x64>

0000000080004990 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004990:	00954783          	lbu	a5,9(a0)
    80004994:	12078d63          	beqz	a5,80004ace <filewrite+0x13e>
{
    80004998:	711d                	addi	sp,sp,-96
    8000499a:	ec86                	sd	ra,88(sp)
    8000499c:	e8a2                	sd	s0,80(sp)
    8000499e:	e0ca                	sd	s2,64(sp)
    800049a0:	f456                	sd	s5,40(sp)
    800049a2:	f05a                	sd	s6,32(sp)
    800049a4:	1080                	addi	s0,sp,96
    800049a6:	892a                	mv	s2,a0
    800049a8:	8b2e                	mv	s6,a1
    800049aa:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800049ac:	411c                	lw	a5,0(a0)
    800049ae:	4705                	li	a4,1
    800049b0:	02e78a63          	beq	a5,a4,800049e4 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049b4:	470d                	li	a4,3
    800049b6:	02e78d63          	beq	a5,a4,800049f0 <filewrite+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049ba:	4709                	li	a4,2
    800049bc:	0ee79b63          	bne	a5,a4,80004ab2 <filewrite+0x122>
    800049c0:	f852                	sd	s4,48(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049c2:	0cc05663          	blez	a2,80004a8e <filewrite+0xfe>
    800049c6:	e4a6                	sd	s1,72(sp)
    800049c8:	fc4e                	sd	s3,56(sp)
    800049ca:	ec5e                	sd	s7,24(sp)
    800049cc:	e862                	sd	s8,16(sp)
    800049ce:	e466                	sd	s9,8(sp)
    int i = 0;
    800049d0:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800049d2:	6b85                	lui	s7,0x1
    800049d4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049d8:	6785                	lui	a5,0x1
    800049da:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800049de:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049e0:	4c05                	li	s8,1
    800049e2:	a849                	j	80004a74 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049e4:	6908                	ld	a0,16(a0)
    800049e6:	00000097          	auipc	ra,0x0
    800049ea:	250080e7          	jalr	592(ra) # 80004c36 <pipewrite>
    800049ee:	a85d                	j	80004aa4 <filewrite+0x114>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049f0:	02451783          	lh	a5,36(a0)
    800049f4:	03079693          	slli	a3,a5,0x30
    800049f8:	92c1                	srli	a3,a3,0x30
    800049fa:	4725                	li	a4,9
    800049fc:	0cd76b63          	bltu	a4,a3,80004ad2 <filewrite+0x142>
    80004a00:	0792                	slli	a5,a5,0x4
    80004a02:	0001c717          	auipc	a4,0x1c
    80004a06:	5a670713          	addi	a4,a4,1446 # 80020fa8 <devsw>
    80004a0a:	97ba                	add	a5,a5,a4
    80004a0c:	679c                	ld	a5,8(a5)
    80004a0e:	c7e1                	beqz	a5,80004ad6 <filewrite+0x146>
    ret = devsw[f->major].write(1, addr, n);
    80004a10:	4505                	li	a0,1
    80004a12:	9782                	jalr	a5
    80004a14:	a841                	j	80004aa4 <filewrite+0x114>
      if(n1 > max)
    80004a16:	2981                	sext.w	s3,s3
      begin_op();
    80004a18:	00000097          	auipc	ra,0x0
    80004a1c:	866080e7          	jalr	-1946(ra) # 8000427e <begin_op>
      ilock(f->ip);
    80004a20:	01893503          	ld	a0,24(s2)
    80004a24:	fffff097          	auipc	ra,0xfffff
    80004a28:	e6a080e7          	jalr	-406(ra) # 8000388e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a2c:	874e                	mv	a4,s3
    80004a2e:	02092683          	lw	a3,32(s2)
    80004a32:	016a0633          	add	a2,s4,s6
    80004a36:	85e2                	mv	a1,s8
    80004a38:	01893503          	ld	a0,24(s2)
    80004a3c:	fffff097          	auipc	ra,0xfffff
    80004a40:	216080e7          	jalr	534(ra) # 80003c52 <writei>
    80004a44:	84aa                	mv	s1,a0
    80004a46:	00a05763          	blez	a0,80004a54 <filewrite+0xc4>
        f->off += r;
    80004a4a:	02092783          	lw	a5,32(s2)
    80004a4e:	9fa9                	addw	a5,a5,a0
    80004a50:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a54:	01893503          	ld	a0,24(s2)
    80004a58:	fffff097          	auipc	ra,0xfffff
    80004a5c:	efc080e7          	jalr	-260(ra) # 80003954 <iunlock>
      end_op();
    80004a60:	00000097          	auipc	ra,0x0
    80004a64:	89e080e7          	jalr	-1890(ra) # 800042fe <end_op>

      if(r != n1){
    80004a68:	02999563          	bne	s3,s1,80004a92 <filewrite+0x102>
        // error from writei
        break;
      }
      i += r;
    80004a6c:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004a70:	015a5963          	bge	s4,s5,80004a82 <filewrite+0xf2>
      int n1 = n - i;
    80004a74:	414a87bb          	subw	a5,s5,s4
    80004a78:	89be                	mv	s3,a5
      if(n1 > max)
    80004a7a:	f8fbdee3          	bge	s7,a5,80004a16 <filewrite+0x86>
    80004a7e:	89e6                	mv	s3,s9
    80004a80:	bf59                	j	80004a16 <filewrite+0x86>
    80004a82:	64a6                	ld	s1,72(sp)
    80004a84:	79e2                	ld	s3,56(sp)
    80004a86:	6be2                	ld	s7,24(sp)
    80004a88:	6c42                	ld	s8,16(sp)
    80004a8a:	6ca2                	ld	s9,8(sp)
    80004a8c:	a801                	j	80004a9c <filewrite+0x10c>
    int i = 0;
    80004a8e:	4a01                	li	s4,0
    80004a90:	a031                	j	80004a9c <filewrite+0x10c>
    80004a92:	64a6                	ld	s1,72(sp)
    80004a94:	79e2                	ld	s3,56(sp)
    80004a96:	6be2                	ld	s7,24(sp)
    80004a98:	6c42                	ld	s8,16(sp)
    80004a9a:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004a9c:	034a9f63          	bne	s5,s4,80004ada <filewrite+0x14a>
    80004aa0:	8556                	mv	a0,s5
    80004aa2:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004aa4:	60e6                	ld	ra,88(sp)
    80004aa6:	6446                	ld	s0,80(sp)
    80004aa8:	6906                	ld	s2,64(sp)
    80004aaa:	7aa2                	ld	s5,40(sp)
    80004aac:	7b02                	ld	s6,32(sp)
    80004aae:	6125                	addi	sp,sp,96
    80004ab0:	8082                	ret
    80004ab2:	e4a6                	sd	s1,72(sp)
    80004ab4:	fc4e                	sd	s3,56(sp)
    80004ab6:	f852                	sd	s4,48(sp)
    80004ab8:	ec5e                	sd	s7,24(sp)
    80004aba:	e862                	sd	s8,16(sp)
    80004abc:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004abe:	00004517          	auipc	a0,0x4
    80004ac2:	ae250513          	addi	a0,a0,-1310 # 800085a0 <etext+0x5a0>
    80004ac6:	ffffc097          	auipc	ra,0xffffc
    80004aca:	a98080e7          	jalr	-1384(ra) # 8000055e <panic>
    return -1;
    80004ace:	557d                	li	a0,-1
}
    80004ad0:	8082                	ret
      return -1;
    80004ad2:	557d                	li	a0,-1
    80004ad4:	bfc1                	j	80004aa4 <filewrite+0x114>
    80004ad6:	557d                	li	a0,-1
    80004ad8:	b7f1                	j	80004aa4 <filewrite+0x114>
    ret = (i == n ? n : -1);
    80004ada:	557d                	li	a0,-1
    80004adc:	7a42                	ld	s4,48(sp)
    80004ade:	b7d9                	j	80004aa4 <filewrite+0x114>

0000000080004ae0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ae0:	7179                	addi	sp,sp,-48
    80004ae2:	f406                	sd	ra,40(sp)
    80004ae4:	f022                	sd	s0,32(sp)
    80004ae6:	ec26                	sd	s1,24(sp)
    80004ae8:	e052                	sd	s4,0(sp)
    80004aea:	1800                	addi	s0,sp,48
    80004aec:	84aa                	mv	s1,a0
    80004aee:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004af0:	0005b023          	sd	zero,0(a1)
    80004af4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004af8:	00000097          	auipc	ra,0x0
    80004afc:	bac080e7          	jalr	-1108(ra) # 800046a4 <filealloc>
    80004b00:	e088                	sd	a0,0(s1)
    80004b02:	cd49                	beqz	a0,80004b9c <pipealloc+0xbc>
    80004b04:	00000097          	auipc	ra,0x0
    80004b08:	ba0080e7          	jalr	-1120(ra) # 800046a4 <filealloc>
    80004b0c:	00aa3023          	sd	a0,0(s4)
    80004b10:	c141                	beqz	a0,80004b90 <pipealloc+0xb0>
    80004b12:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b14:	ffffc097          	auipc	ra,0xffffc
    80004b18:	044080e7          	jalr	68(ra) # 80000b58 <kalloc>
    80004b1c:	892a                	mv	s2,a0
    80004b1e:	c13d                	beqz	a0,80004b84 <pipealloc+0xa4>
    80004b20:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b22:	4985                	li	s3,1
    80004b24:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b28:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b2c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b30:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b34:	00004597          	auipc	a1,0x4
    80004b38:	a7c58593          	addi	a1,a1,-1412 # 800085b0 <etext+0x5b0>
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	086080e7          	jalr	134(ra) # 80000bc2 <initlock>
  (*f0)->type = FD_PIPE;
    80004b44:	609c                	ld	a5,0(s1)
    80004b46:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b4a:	609c                	ld	a5,0(s1)
    80004b4c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b50:	609c                	ld	a5,0(s1)
    80004b52:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b56:	609c                	ld	a5,0(s1)
    80004b58:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b5c:	000a3783          	ld	a5,0(s4)
    80004b60:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b64:	000a3783          	ld	a5,0(s4)
    80004b68:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b6c:	000a3783          	ld	a5,0(s4)
    80004b70:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b74:	000a3783          	ld	a5,0(s4)
    80004b78:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b7c:	4501                	li	a0,0
    80004b7e:	6942                	ld	s2,16(sp)
    80004b80:	69a2                	ld	s3,8(sp)
    80004b82:	a03d                	j	80004bb0 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b84:	6088                	ld	a0,0(s1)
    80004b86:	c119                	beqz	a0,80004b8c <pipealloc+0xac>
    80004b88:	6942                	ld	s2,16(sp)
    80004b8a:	a029                	j	80004b94 <pipealloc+0xb4>
    80004b8c:	6942                	ld	s2,16(sp)
    80004b8e:	a039                	j	80004b9c <pipealloc+0xbc>
    80004b90:	6088                	ld	a0,0(s1)
    80004b92:	c50d                	beqz	a0,80004bbc <pipealloc+0xdc>
    fileclose(*f0);
    80004b94:	00000097          	auipc	ra,0x0
    80004b98:	bcc080e7          	jalr	-1076(ra) # 80004760 <fileclose>
  if(*f1)
    80004b9c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ba0:	557d                	li	a0,-1
  if(*f1)
    80004ba2:	c799                	beqz	a5,80004bb0 <pipealloc+0xd0>
    fileclose(*f1);
    80004ba4:	853e                	mv	a0,a5
    80004ba6:	00000097          	auipc	ra,0x0
    80004baa:	bba080e7          	jalr	-1094(ra) # 80004760 <fileclose>
  return -1;
    80004bae:	557d                	li	a0,-1
}
    80004bb0:	70a2                	ld	ra,40(sp)
    80004bb2:	7402                	ld	s0,32(sp)
    80004bb4:	64e2                	ld	s1,24(sp)
    80004bb6:	6a02                	ld	s4,0(sp)
    80004bb8:	6145                	addi	sp,sp,48
    80004bba:	8082                	ret
  return -1;
    80004bbc:	557d                	li	a0,-1
    80004bbe:	bfcd                	j	80004bb0 <pipealloc+0xd0>

0000000080004bc0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bc0:	1101                	addi	sp,sp,-32
    80004bc2:	ec06                	sd	ra,24(sp)
    80004bc4:	e822                	sd	s0,16(sp)
    80004bc6:	e426                	sd	s1,8(sp)
    80004bc8:	e04a                	sd	s2,0(sp)
    80004bca:	1000                	addi	s0,sp,32
    80004bcc:	84aa                	mv	s1,a0
    80004bce:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bd0:	ffffc097          	auipc	ra,0xffffc
    80004bd4:	08c080e7          	jalr	140(ra) # 80000c5c <acquire>
  if(writable){
    80004bd8:	02090b63          	beqz	s2,80004c0e <pipeclose+0x4e>
    pi->writeopen = 0;
    80004bdc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004be0:	21848513          	addi	a0,s1,536
    80004be4:	ffffd097          	auipc	ra,0xffffd
    80004be8:	6a6080e7          	jalr	1702(ra) # 8000228a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bec:	2204a783          	lw	a5,544(s1)
    80004bf0:	e781                	bnez	a5,80004bf8 <pipeclose+0x38>
    80004bf2:	2244a783          	lw	a5,548(s1)
    80004bf6:	c78d                	beqz	a5,80004c20 <pipeclose+0x60>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	112080e7          	jalr	274(ra) # 80000d0c <release>
}
    80004c02:	60e2                	ld	ra,24(sp)
    80004c04:	6442                	ld	s0,16(sp)
    80004c06:	64a2                	ld	s1,8(sp)
    80004c08:	6902                	ld	s2,0(sp)
    80004c0a:	6105                	addi	sp,sp,32
    80004c0c:	8082                	ret
    pi->readopen = 0;
    80004c0e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c12:	21c48513          	addi	a0,s1,540
    80004c16:	ffffd097          	auipc	ra,0xffffd
    80004c1a:	674080e7          	jalr	1652(ra) # 8000228a <wakeup>
    80004c1e:	b7f9                	j	80004bec <pipeclose+0x2c>
    release(&pi->lock);
    80004c20:	8526                	mv	a0,s1
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	0ea080e7          	jalr	234(ra) # 80000d0c <release>
    kfree((char*)pi);
    80004c2a:	8526                	mv	a0,s1
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	e28080e7          	jalr	-472(ra) # 80000a54 <kfree>
    80004c34:	b7f9                	j	80004c02 <pipeclose+0x42>

0000000080004c36 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c36:	7159                	addi	sp,sp,-112
    80004c38:	f486                	sd	ra,104(sp)
    80004c3a:	f0a2                	sd	s0,96(sp)
    80004c3c:	eca6                	sd	s1,88(sp)
    80004c3e:	e8ca                	sd	s2,80(sp)
    80004c40:	e4ce                	sd	s3,72(sp)
    80004c42:	e0d2                	sd	s4,64(sp)
    80004c44:	fc56                	sd	s5,56(sp)
    80004c46:	1880                	addi	s0,sp,112
    80004c48:	84aa                	mv	s1,a0
    80004c4a:	8aae                	mv	s5,a1
    80004c4c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c4e:	ffffd097          	auipc	ra,0xffffd
    80004c52:	eb2080e7          	jalr	-334(ra) # 80001b00 <myproc>
    80004c56:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c58:	8526                	mv	a0,s1
    80004c5a:	ffffc097          	auipc	ra,0xffffc
    80004c5e:	002080e7          	jalr	2(ra) # 80000c5c <acquire>
  while(i < n){
    80004c62:	0f405063          	blez	s4,80004d42 <pipewrite+0x10c>
    80004c66:	f85a                	sd	s6,48(sp)
    80004c68:	f45e                	sd	s7,40(sp)
    80004c6a:	f062                	sd	s8,32(sp)
    80004c6c:	ec66                	sd	s9,24(sp)
    80004c6e:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004c70:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c72:	f9f40c13          	addi	s8,s0,-97
    80004c76:	4b85                	li	s7,1
    80004c78:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c7a:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c7e:	21c48c93          	addi	s9,s1,540
    80004c82:	a099                	j	80004cc8 <pipewrite+0x92>
      release(&pi->lock);
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	086080e7          	jalr	134(ra) # 80000d0c <release>
      return -1;
    80004c8e:	597d                	li	s2,-1
    80004c90:	7b42                	ld	s6,48(sp)
    80004c92:	7ba2                	ld	s7,40(sp)
    80004c94:	7c02                	ld	s8,32(sp)
    80004c96:	6ce2                	ld	s9,24(sp)
    80004c98:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c9a:	854a                	mv	a0,s2
    80004c9c:	70a6                	ld	ra,104(sp)
    80004c9e:	7406                	ld	s0,96(sp)
    80004ca0:	64e6                	ld	s1,88(sp)
    80004ca2:	6946                	ld	s2,80(sp)
    80004ca4:	69a6                	ld	s3,72(sp)
    80004ca6:	6a06                	ld	s4,64(sp)
    80004ca8:	7ae2                	ld	s5,56(sp)
    80004caa:	6165                	addi	sp,sp,112
    80004cac:	8082                	ret
      wakeup(&pi->nread);
    80004cae:	856a                	mv	a0,s10
    80004cb0:	ffffd097          	auipc	ra,0xffffd
    80004cb4:	5da080e7          	jalr	1498(ra) # 8000228a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cb8:	85a6                	mv	a1,s1
    80004cba:	8566                	mv	a0,s9
    80004cbc:	ffffd097          	auipc	ra,0xffffd
    80004cc0:	56a080e7          	jalr	1386(ra) # 80002226 <sleep>
  while(i < n){
    80004cc4:	05495e63          	bge	s2,s4,80004d20 <pipewrite+0xea>
    if(pi->readopen == 0 || killed(pr)){
    80004cc8:	2204a783          	lw	a5,544(s1)
    80004ccc:	dfc5                	beqz	a5,80004c84 <pipewrite+0x4e>
    80004cce:	854e                	mv	a0,s3
    80004cd0:	ffffe097          	auipc	ra,0xffffe
    80004cd4:	81e080e7          	jalr	-2018(ra) # 800024ee <killed>
    80004cd8:	f555                	bnez	a0,80004c84 <pipewrite+0x4e>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cda:	2184a783          	lw	a5,536(s1)
    80004cde:	21c4a703          	lw	a4,540(s1)
    80004ce2:	2007879b          	addiw	a5,a5,512
    80004ce6:	fcf704e3          	beq	a4,a5,80004cae <pipewrite+0x78>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cea:	86de                	mv	a3,s7
    80004cec:	01590633          	add	a2,s2,s5
    80004cf0:	85e2                	mv	a1,s8
    80004cf2:	0509b503          	ld	a0,80(s3)
    80004cf6:	ffffd097          	auipc	ra,0xffffd
    80004cfa:	aae080e7          	jalr	-1362(ra) # 800017a4 <copyin>
    80004cfe:	05650463          	beq	a0,s6,80004d46 <pipewrite+0x110>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d02:	21c4a783          	lw	a5,540(s1)
    80004d06:	0017871b          	addiw	a4,a5,1
    80004d0a:	20e4ae23          	sw	a4,540(s1)
    80004d0e:	1ff7f793          	andi	a5,a5,511
    80004d12:	97a6                	add	a5,a5,s1
    80004d14:	f9f44703          	lbu	a4,-97(s0)
    80004d18:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d1c:	2905                	addiw	s2,s2,1
    80004d1e:	b75d                	j	80004cc4 <pipewrite+0x8e>
    80004d20:	7b42                	ld	s6,48(sp)
    80004d22:	7ba2                	ld	s7,40(sp)
    80004d24:	7c02                	ld	s8,32(sp)
    80004d26:	6ce2                	ld	s9,24(sp)
    80004d28:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004d2a:	21848513          	addi	a0,s1,536
    80004d2e:	ffffd097          	auipc	ra,0xffffd
    80004d32:	55c080e7          	jalr	1372(ra) # 8000228a <wakeup>
  release(&pi->lock);
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	fd4080e7          	jalr	-44(ra) # 80000d0c <release>
  return i;
    80004d40:	bfa9                	j	80004c9a <pipewrite+0x64>
  int i = 0;
    80004d42:	4901                	li	s2,0
    80004d44:	b7dd                	j	80004d2a <pipewrite+0xf4>
    80004d46:	7b42                	ld	s6,48(sp)
    80004d48:	7ba2                	ld	s7,40(sp)
    80004d4a:	7c02                	ld	s8,32(sp)
    80004d4c:	6ce2                	ld	s9,24(sp)
    80004d4e:	6d42                	ld	s10,16(sp)
    80004d50:	bfe9                	j	80004d2a <pipewrite+0xf4>

0000000080004d52 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d52:	711d                	addi	sp,sp,-96
    80004d54:	ec86                	sd	ra,88(sp)
    80004d56:	e8a2                	sd	s0,80(sp)
    80004d58:	e4a6                	sd	s1,72(sp)
    80004d5a:	e0ca                	sd	s2,64(sp)
    80004d5c:	fc4e                	sd	s3,56(sp)
    80004d5e:	f852                	sd	s4,48(sp)
    80004d60:	f456                	sd	s5,40(sp)
    80004d62:	1080                	addi	s0,sp,96
    80004d64:	84aa                	mv	s1,a0
    80004d66:	892e                	mv	s2,a1
    80004d68:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d6a:	ffffd097          	auipc	ra,0xffffd
    80004d6e:	d96080e7          	jalr	-618(ra) # 80001b00 <myproc>
    80004d72:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	ee6080e7          	jalr	-282(ra) # 80000c5c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d7e:	2184a703          	lw	a4,536(s1)
    80004d82:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d86:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d8a:	02f71b63          	bne	a4,a5,80004dc0 <piperead+0x6e>
    80004d8e:	2244a783          	lw	a5,548(s1)
    80004d92:	c3b1                	beqz	a5,80004dd6 <piperead+0x84>
    if(killed(pr)){
    80004d94:	8552                	mv	a0,s4
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	758080e7          	jalr	1880(ra) # 800024ee <killed>
    80004d9e:	e50d                	bnez	a0,80004dc8 <piperead+0x76>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004da0:	85a6                	mv	a1,s1
    80004da2:	854e                	mv	a0,s3
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	482080e7          	jalr	1154(ra) # 80002226 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dac:	2184a703          	lw	a4,536(s1)
    80004db0:	21c4a783          	lw	a5,540(s1)
    80004db4:	fcf70de3          	beq	a4,a5,80004d8e <piperead+0x3c>
    80004db8:	f05a                	sd	s6,32(sp)
    80004dba:	ec5e                	sd	s7,24(sp)
    80004dbc:	e862                	sd	s8,16(sp)
    80004dbe:	a839                	j	80004ddc <piperead+0x8a>
    80004dc0:	f05a                	sd	s6,32(sp)
    80004dc2:	ec5e                	sd	s7,24(sp)
    80004dc4:	e862                	sd	s8,16(sp)
    80004dc6:	a819                	j	80004ddc <piperead+0x8a>
      release(&pi->lock);
    80004dc8:	8526                	mv	a0,s1
    80004dca:	ffffc097          	auipc	ra,0xffffc
    80004dce:	f42080e7          	jalr	-190(ra) # 80000d0c <release>
      return -1;
    80004dd2:	59fd                	li	s3,-1
    80004dd4:	a88d                	j	80004e46 <piperead+0xf4>
    80004dd6:	f05a                	sd	s6,32(sp)
    80004dd8:	ec5e                	sd	s7,24(sp)
    80004dda:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ddc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dde:	faf40c13          	addi	s8,s0,-81
    80004de2:	4b85                	li	s7,1
    80004de4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004de6:	05505263          	blez	s5,80004e2a <piperead+0xd8>
    if(pi->nread == pi->nwrite)
    80004dea:	2184a783          	lw	a5,536(s1)
    80004dee:	21c4a703          	lw	a4,540(s1)
    80004df2:	02f70c63          	beq	a4,a5,80004e2a <piperead+0xd8>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004df6:	0017871b          	addiw	a4,a5,1
    80004dfa:	20e4ac23          	sw	a4,536(s1)
    80004dfe:	1ff7f793          	andi	a5,a5,511
    80004e02:	97a6                	add	a5,a5,s1
    80004e04:	0187c783          	lbu	a5,24(a5)
    80004e08:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e0c:	86de                	mv	a3,s7
    80004e0e:	8662                	mv	a2,s8
    80004e10:	85ca                	mv	a1,s2
    80004e12:	050a3503          	ld	a0,80(s4)
    80004e16:	ffffd097          	auipc	ra,0xffffd
    80004e1a:	902080e7          	jalr	-1790(ra) # 80001718 <copyout>
    80004e1e:	01650663          	beq	a0,s6,80004e2a <piperead+0xd8>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e22:	2985                	addiw	s3,s3,1
    80004e24:	0905                	addi	s2,s2,1
    80004e26:	fd3a92e3          	bne	s5,s3,80004dea <piperead+0x98>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e2a:	21c48513          	addi	a0,s1,540
    80004e2e:	ffffd097          	auipc	ra,0xffffd
    80004e32:	45c080e7          	jalr	1116(ra) # 8000228a <wakeup>
  release(&pi->lock);
    80004e36:	8526                	mv	a0,s1
    80004e38:	ffffc097          	auipc	ra,0xffffc
    80004e3c:	ed4080e7          	jalr	-300(ra) # 80000d0c <release>
    80004e40:	7b02                	ld	s6,32(sp)
    80004e42:	6be2                	ld	s7,24(sp)
    80004e44:	6c42                	ld	s8,16(sp)
  return i;
}
    80004e46:	854e                	mv	a0,s3
    80004e48:	60e6                	ld	ra,88(sp)
    80004e4a:	6446                	ld	s0,80(sp)
    80004e4c:	64a6                	ld	s1,72(sp)
    80004e4e:	6906                	ld	s2,64(sp)
    80004e50:	79e2                	ld	s3,56(sp)
    80004e52:	7a42                	ld	s4,48(sp)
    80004e54:	7aa2                	ld	s5,40(sp)
    80004e56:	6125                	addi	sp,sp,96
    80004e58:	8082                	ret

0000000080004e5a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e5a:	1141                	addi	sp,sp,-16
    80004e5c:	e406                	sd	ra,8(sp)
    80004e5e:	e022                	sd	s0,0(sp)
    80004e60:	0800                	addi	s0,sp,16
    80004e62:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e64:	0035151b          	slliw	a0,a0,0x3
    80004e68:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004e6a:	8b89                	andi	a5,a5,2
    80004e6c:	c399                	beqz	a5,80004e72 <flags2perm+0x18>
      perm |= PTE_W;
    80004e6e:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e72:	60a2                	ld	ra,8(sp)
    80004e74:	6402                	ld	s0,0(sp)
    80004e76:	0141                	addi	sp,sp,16
    80004e78:	8082                	ret

0000000080004e7a <exec>:

int
exec(char *path, char **argv)
{
    80004e7a:	de010113          	addi	sp,sp,-544
    80004e7e:	20113c23          	sd	ra,536(sp)
    80004e82:	20813823          	sd	s0,528(sp)
    80004e86:	20913423          	sd	s1,520(sp)
    80004e8a:	21213023          	sd	s2,512(sp)
    80004e8e:	1400                	addi	s0,sp,544
    80004e90:	892a                	mv	s2,a0
    80004e92:	dea43823          	sd	a0,-528(s0)
    80004e96:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e9a:	ffffd097          	auipc	ra,0xffffd
    80004e9e:	c66080e7          	jalr	-922(ra) # 80001b00 <myproc>
    80004ea2:	84aa                	mv	s1,a0

  begin_op();
    80004ea4:	fffff097          	auipc	ra,0xfffff
    80004ea8:	3da080e7          	jalr	986(ra) # 8000427e <begin_op>

  if((ip = namei(path)) == 0){
    80004eac:	854a                	mv	a0,s2
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	1ca080e7          	jalr	458(ra) # 80004078 <namei>
    80004eb6:	c525                	beqz	a0,80004f1e <exec+0xa4>
    80004eb8:	fbd2                	sd	s4,496(sp)
    80004eba:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	9d2080e7          	jalr	-1582(ra) # 8000388e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ec4:	04000713          	li	a4,64
    80004ec8:	4681                	li	a3,0
    80004eca:	e5040613          	addi	a2,s0,-432
    80004ece:	4581                	li	a1,0
    80004ed0:	8552                	mv	a0,s4
    80004ed2:	fffff097          	auipc	ra,0xfffff
    80004ed6:	c7a080e7          	jalr	-902(ra) # 80003b4c <readi>
    80004eda:	04000793          	li	a5,64
    80004ede:	00f51a63          	bne	a0,a5,80004ef2 <exec+0x78>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004ee2:	e5042703          	lw	a4,-432(s0)
    80004ee6:	464c47b7          	lui	a5,0x464c4
    80004eea:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004eee:	02f70e63          	beq	a4,a5,80004f2a <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ef2:	8552                	mv	a0,s4
    80004ef4:	fffff097          	auipc	ra,0xfffff
    80004ef8:	c02080e7          	jalr	-1022(ra) # 80003af6 <iunlockput>
    end_op();
    80004efc:	fffff097          	auipc	ra,0xfffff
    80004f00:	402080e7          	jalr	1026(ra) # 800042fe <end_op>
  }
  return -1;
    80004f04:	557d                	li	a0,-1
    80004f06:	7a5e                	ld	s4,496(sp)
}
    80004f08:	21813083          	ld	ra,536(sp)
    80004f0c:	21013403          	ld	s0,528(sp)
    80004f10:	20813483          	ld	s1,520(sp)
    80004f14:	20013903          	ld	s2,512(sp)
    80004f18:	22010113          	addi	sp,sp,544
    80004f1c:	8082                	ret
    end_op();
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	3e0080e7          	jalr	992(ra) # 800042fe <end_op>
    return -1;
    80004f26:	557d                	li	a0,-1
    80004f28:	b7c5                	j	80004f08 <exec+0x8e>
    80004f2a:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	ffffd097          	auipc	ra,0xffffd
    80004f32:	c98080e7          	jalr	-872(ra) # 80001bc6 <proc_pagetable>
    80004f36:	8b2a                	mv	s6,a0
    80004f38:	2c050363          	beqz	a0,800051fe <exec+0x384>
    80004f3c:	ffce                	sd	s3,504(sp)
    80004f3e:	f7d6                	sd	s5,488(sp)
    80004f40:	efde                	sd	s7,472(sp)
    80004f42:	ebe2                	sd	s8,464(sp)
    80004f44:	e7e6                	sd	s9,456(sp)
    80004f46:	e3ea                	sd	s10,448(sp)
    80004f48:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f4a:	e8845783          	lhu	a5,-376(s0)
    80004f4e:	10078563          	beqz	a5,80005058 <exec+0x1de>
    80004f52:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f56:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f58:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f5a:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004f5e:	6c85                	lui	s9,0x1
    80004f60:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f64:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f68:	6a85                	lui	s5,0x1
    80004f6a:	a0b5                	j	80004fd6 <exec+0x15c>
      panic("loadseg: address should exist");
    80004f6c:	00003517          	auipc	a0,0x3
    80004f70:	64c50513          	addi	a0,a0,1612 # 800085b8 <etext+0x5b8>
    80004f74:	ffffb097          	auipc	ra,0xffffb
    80004f78:	5ea080e7          	jalr	1514(ra) # 8000055e <panic>
    if(sz - i < PGSIZE)
    80004f7c:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f7e:	874a                	mv	a4,s2
    80004f80:	009b86bb          	addw	a3,s7,s1
    80004f84:	4581                	li	a1,0
    80004f86:	8552                	mv	a0,s4
    80004f88:	fffff097          	auipc	ra,0xfffff
    80004f8c:	bc4080e7          	jalr	-1084(ra) # 80003b4c <readi>
    80004f90:	26a91b63          	bne	s2,a0,80005206 <exec+0x38c>
  for(i = 0; i < sz; i += PGSIZE){
    80004f94:	009a84bb          	addw	s1,s5,s1
    80004f98:	0334f463          	bgeu	s1,s3,80004fc0 <exec+0x146>
    pa = walkaddr(pagetable, va + i);
    80004f9c:	02049593          	slli	a1,s1,0x20
    80004fa0:	9181                	srli	a1,a1,0x20
    80004fa2:	95e2                	add	a1,a1,s8
    80004fa4:	855a                	mv	a0,s6
    80004fa6:	ffffc097          	auipc	ra,0xffffc
    80004faa:	150080e7          	jalr	336(ra) # 800010f6 <walkaddr>
    80004fae:	862a                	mv	a2,a0
    if(pa == 0)
    80004fb0:	dd55                	beqz	a0,80004f6c <exec+0xf2>
    if(sz - i < PGSIZE)
    80004fb2:	409987bb          	subw	a5,s3,s1
    80004fb6:	893e                	mv	s2,a5
    80004fb8:	fcfcf2e3          	bgeu	s9,a5,80004f7c <exec+0x102>
    80004fbc:	8956                	mv	s2,s5
    80004fbe:	bf7d                	j	80004f7c <exec+0x102>
    sz = sz1;
    80004fc0:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fc4:	2d05                	addiw	s10,s10,1
    80004fc6:	e0843783          	ld	a5,-504(s0)
    80004fca:	0387869b          	addiw	a3,a5,56
    80004fce:	e8845783          	lhu	a5,-376(s0)
    80004fd2:	08fd5463          	bge	s10,a5,8000505a <exec+0x1e0>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fd6:	e0d43423          	sd	a3,-504(s0)
    80004fda:	876e                	mv	a4,s11
    80004fdc:	e1840613          	addi	a2,s0,-488
    80004fe0:	4581                	li	a1,0
    80004fe2:	8552                	mv	a0,s4
    80004fe4:	fffff097          	auipc	ra,0xfffff
    80004fe8:	b68080e7          	jalr	-1176(ra) # 80003b4c <readi>
    80004fec:	21b51b63          	bne	a0,s11,80005202 <exec+0x388>
    if(ph.type != ELF_PROG_LOAD)
    80004ff0:	e1842783          	lw	a5,-488(s0)
    80004ff4:	4705                	li	a4,1
    80004ff6:	fce797e3          	bne	a5,a4,80004fc4 <exec+0x14a>
    if(ph.memsz < ph.filesz)
    80004ffa:	e4043483          	ld	s1,-448(s0)
    80004ffe:	e3843783          	ld	a5,-456(s0)
    80005002:	22f4e263          	bltu	s1,a5,80005226 <exec+0x3ac>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005006:	e2843783          	ld	a5,-472(s0)
    8000500a:	94be                	add	s1,s1,a5
    8000500c:	22f4e063          	bltu	s1,a5,8000522c <exec+0x3b2>
    if(ph.vaddr % PGSIZE != 0)
    80005010:	de843703          	ld	a4,-536(s0)
    80005014:	8ff9                	and	a5,a5,a4
    80005016:	20079e63          	bnez	a5,80005232 <exec+0x3b8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000501a:	e1c42503          	lw	a0,-484(s0)
    8000501e:	00000097          	auipc	ra,0x0
    80005022:	e3c080e7          	jalr	-452(ra) # 80004e5a <flags2perm>
    80005026:	86aa                	mv	a3,a0
    80005028:	8626                	mv	a2,s1
    8000502a:	85ca                	mv	a1,s2
    8000502c:	855a                	mv	a0,s6
    8000502e:	ffffc097          	auipc	ra,0xffffc
    80005032:	486080e7          	jalr	1158(ra) # 800014b4 <uvmalloc>
    80005036:	dea43c23          	sd	a0,-520(s0)
    8000503a:	1e050f63          	beqz	a0,80005238 <exec+0x3be>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000503e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005042:	00098863          	beqz	s3,80005052 <exec+0x1d8>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005046:	e2843c03          	ld	s8,-472(s0)
    8000504a:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000504e:	4481                	li	s1,0
    80005050:	b7b1                	j	80004f9c <exec+0x122>
    sz = sz1;
    80005052:	df843903          	ld	s2,-520(s0)
    80005056:	b7bd                	j	80004fc4 <exec+0x14a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005058:	4901                	li	s2,0
  iunlockput(ip);
    8000505a:	8552                	mv	a0,s4
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	a9a080e7          	jalr	-1382(ra) # 80003af6 <iunlockput>
  end_op();
    80005064:	fffff097          	auipc	ra,0xfffff
    80005068:	29a080e7          	jalr	666(ra) # 800042fe <end_op>
  p = myproc();
    8000506c:	ffffd097          	auipc	ra,0xffffd
    80005070:	a94080e7          	jalr	-1388(ra) # 80001b00 <myproc>
    80005074:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005076:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    8000507a:	6985                	lui	s3,0x1
    8000507c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000507e:	99ca                	add	s3,s3,s2
    80005080:	77fd                	lui	a5,0xfffff
    80005082:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005086:	4691                	li	a3,4
    80005088:	6609                	lui	a2,0x2
    8000508a:	964e                	add	a2,a2,s3
    8000508c:	85ce                	mv	a1,s3
    8000508e:	855a                	mv	a0,s6
    80005090:	ffffc097          	auipc	ra,0xffffc
    80005094:	424080e7          	jalr	1060(ra) # 800014b4 <uvmalloc>
    80005098:	8a2a                	mv	s4,a0
    8000509a:	e115                	bnez	a0,800050be <exec+0x244>
    proc_freepagetable(pagetable, sz);
    8000509c:	85ce                	mv	a1,s3
    8000509e:	855a                	mv	a0,s6
    800050a0:	ffffd097          	auipc	ra,0xffffd
    800050a4:	bc2080e7          	jalr	-1086(ra) # 80001c62 <proc_freepagetable>
  return -1;
    800050a8:	557d                	li	a0,-1
    800050aa:	79fe                	ld	s3,504(sp)
    800050ac:	7a5e                	ld	s4,496(sp)
    800050ae:	7abe                	ld	s5,488(sp)
    800050b0:	7b1e                	ld	s6,480(sp)
    800050b2:	6bfe                	ld	s7,472(sp)
    800050b4:	6c5e                	ld	s8,464(sp)
    800050b6:	6cbe                	ld	s9,456(sp)
    800050b8:	6d1e                	ld	s10,448(sp)
    800050ba:	7dfa                	ld	s11,440(sp)
    800050bc:	b5b1                	j	80004f08 <exec+0x8e>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050be:	75f9                	lui	a1,0xffffe
    800050c0:	95aa                	add	a1,a1,a0
    800050c2:	855a                	mv	a0,s6
    800050c4:	ffffc097          	auipc	ra,0xffffc
    800050c8:	622080e7          	jalr	1570(ra) # 800016e6 <uvmclear>
  stackbase = sp - PGSIZE;
    800050cc:	800a0b93          	addi	s7,s4,-2048
    800050d0:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    800050d4:	e0043783          	ld	a5,-512(s0)
    800050d8:	6388                	ld	a0,0(a5)
  sp = sz;
    800050da:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    800050dc:	4481                	li	s1,0
    ustack[argc] = sp;
    800050de:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    800050e2:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    800050e6:	c135                	beqz	a0,8000514a <exec+0x2d0>
    sp -= strlen(argv[argc]) + 1;
    800050e8:	ffffc097          	auipc	ra,0xffffc
    800050ec:	dfa080e7          	jalr	-518(ra) # 80000ee2 <strlen>
    800050f0:	0015079b          	addiw	a5,a0,1
    800050f4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050f8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800050fc:	15796163          	bltu	s2,s7,8000523e <exec+0x3c4>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005100:	e0043d83          	ld	s11,-512(s0)
    80005104:	000db983          	ld	s3,0(s11)
    80005108:	854e                	mv	a0,s3
    8000510a:	ffffc097          	auipc	ra,0xffffc
    8000510e:	dd8080e7          	jalr	-552(ra) # 80000ee2 <strlen>
    80005112:	0015069b          	addiw	a3,a0,1
    80005116:	864e                	mv	a2,s3
    80005118:	85ca                	mv	a1,s2
    8000511a:	855a                	mv	a0,s6
    8000511c:	ffffc097          	auipc	ra,0xffffc
    80005120:	5fc080e7          	jalr	1532(ra) # 80001718 <copyout>
    80005124:	10054f63          	bltz	a0,80005242 <exec+0x3c8>
    ustack[argc] = sp;
    80005128:	00349793          	slli	a5,s1,0x3
    8000512c:	97e6                	add	a5,a5,s9
    8000512e:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdcec0>
  for(argc = 0; argv[argc]; argc++) {
    80005132:	0485                	addi	s1,s1,1
    80005134:	008d8793          	addi	a5,s11,8
    80005138:	e0f43023          	sd	a5,-512(s0)
    8000513c:	008db503          	ld	a0,8(s11)
    80005140:	c509                	beqz	a0,8000514a <exec+0x2d0>
    if(argc >= MAXARG)
    80005142:	fb8493e3          	bne	s1,s8,800050e8 <exec+0x26e>
  sz = sz1;
    80005146:	89d2                	mv	s3,s4
    80005148:	bf91                	j	8000509c <exec+0x222>
  ustack[argc] = 0;
    8000514a:	00349793          	slli	a5,s1,0x3
    8000514e:	f9078793          	addi	a5,a5,-112
    80005152:	97a2                	add	a5,a5,s0
    80005154:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005158:	00349693          	slli	a3,s1,0x3
    8000515c:	06a1                	addi	a3,a3,8
    8000515e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005162:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005166:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005168:	f3796ae3          	bltu	s2,s7,8000509c <exec+0x222>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000516c:	e9040613          	addi	a2,s0,-368
    80005170:	85ca                	mv	a1,s2
    80005172:	855a                	mv	a0,s6
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	5a4080e7          	jalr	1444(ra) # 80001718 <copyout>
    8000517c:	f20540e3          	bltz	a0,8000509c <exec+0x222>
  p->trapframe->a1 = sp;
    80005180:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005184:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005188:	df043783          	ld	a5,-528(s0)
    8000518c:	0007c703          	lbu	a4,0(a5)
    80005190:	cf11                	beqz	a4,800051ac <exec+0x332>
    80005192:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005194:	02f00693          	li	a3,47
    80005198:	a029                	j	800051a2 <exec+0x328>
  for(last=s=path; *s; s++)
    8000519a:	0785                	addi	a5,a5,1
    8000519c:	fff7c703          	lbu	a4,-1(a5)
    800051a0:	c711                	beqz	a4,800051ac <exec+0x332>
    if(*s == '/')
    800051a2:	fed71ce3          	bne	a4,a3,8000519a <exec+0x320>
      last = s+1;
    800051a6:	def43823          	sd	a5,-528(s0)
    800051aa:	bfc5                	j	8000519a <exec+0x320>
  safestrcpy(p->name, last, sizeof(p->name));
    800051ac:	4641                	li	a2,16
    800051ae:	df043583          	ld	a1,-528(s0)
    800051b2:	158a8513          	addi	a0,s5,344
    800051b6:	ffffc097          	auipc	ra,0xffffc
    800051ba:	cf6080e7          	jalr	-778(ra) # 80000eac <safestrcpy>
  oldpagetable = p->pagetable;
    800051be:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051c2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800051c6:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051ca:	058ab783          	ld	a5,88(s5)
    800051ce:	e6843703          	ld	a4,-408(s0)
    800051d2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051d4:	058ab783          	ld	a5,88(s5)
    800051d8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051dc:	85ea                	mv	a1,s10
    800051de:	ffffd097          	auipc	ra,0xffffd
    800051e2:	a84080e7          	jalr	-1404(ra) # 80001c62 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051e6:	0004851b          	sext.w	a0,s1
    800051ea:	79fe                	ld	s3,504(sp)
    800051ec:	7a5e                	ld	s4,496(sp)
    800051ee:	7abe                	ld	s5,488(sp)
    800051f0:	7b1e                	ld	s6,480(sp)
    800051f2:	6bfe                	ld	s7,472(sp)
    800051f4:	6c5e                	ld	s8,464(sp)
    800051f6:	6cbe                	ld	s9,456(sp)
    800051f8:	6d1e                	ld	s10,448(sp)
    800051fa:	7dfa                	ld	s11,440(sp)
    800051fc:	b331                	j	80004f08 <exec+0x8e>
    800051fe:	7b1e                	ld	s6,480(sp)
    80005200:	b9cd                	j	80004ef2 <exec+0x78>
    80005202:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005206:	df843583          	ld	a1,-520(s0)
    8000520a:	855a                	mv	a0,s6
    8000520c:	ffffd097          	auipc	ra,0xffffd
    80005210:	a56080e7          	jalr	-1450(ra) # 80001c62 <proc_freepagetable>
  if(ip){
    80005214:	79fe                	ld	s3,504(sp)
    80005216:	7abe                	ld	s5,488(sp)
    80005218:	7b1e                	ld	s6,480(sp)
    8000521a:	6bfe                	ld	s7,472(sp)
    8000521c:	6c5e                	ld	s8,464(sp)
    8000521e:	6cbe                	ld	s9,456(sp)
    80005220:	6d1e                	ld	s10,448(sp)
    80005222:	7dfa                	ld	s11,440(sp)
    80005224:	b1f9                	j	80004ef2 <exec+0x78>
    80005226:	df243c23          	sd	s2,-520(s0)
    8000522a:	bff1                	j	80005206 <exec+0x38c>
    8000522c:	df243c23          	sd	s2,-520(s0)
    80005230:	bfd9                	j	80005206 <exec+0x38c>
    80005232:	df243c23          	sd	s2,-520(s0)
    80005236:	bfc1                	j	80005206 <exec+0x38c>
    80005238:	df243c23          	sd	s2,-520(s0)
    8000523c:	b7e9                	j	80005206 <exec+0x38c>
  sz = sz1;
    8000523e:	89d2                	mv	s3,s4
    80005240:	bdb1                	j	8000509c <exec+0x222>
    80005242:	89d2                	mv	s3,s4
    80005244:	bda1                	j	8000509c <exec+0x222>

0000000080005246 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005246:	7179                	addi	sp,sp,-48
    80005248:	f406                	sd	ra,40(sp)
    8000524a:	f022                	sd	s0,32(sp)
    8000524c:	ec26                	sd	s1,24(sp)
    8000524e:	e84a                	sd	s2,16(sp)
    80005250:	1800                	addi	s0,sp,48
    80005252:	892e                	mv	s2,a1
    80005254:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005256:	fdc40593          	addi	a1,s0,-36
    8000525a:	ffffe097          	auipc	ra,0xffffe
    8000525e:	a88080e7          	jalr	-1400(ra) # 80002ce2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005262:	fdc42703          	lw	a4,-36(s0)
    80005266:	47bd                	li	a5,15
    80005268:	02e7ec63          	bltu	a5,a4,800052a0 <argfd+0x5a>
    8000526c:	ffffd097          	auipc	ra,0xffffd
    80005270:	894080e7          	jalr	-1900(ra) # 80001b00 <myproc>
    80005274:	fdc42703          	lw	a4,-36(s0)
    80005278:	00371793          	slli	a5,a4,0x3
    8000527c:	0d078793          	addi	a5,a5,208
    80005280:	953e                	add	a0,a0,a5
    80005282:	611c                	ld	a5,0(a0)
    80005284:	c385                	beqz	a5,800052a4 <argfd+0x5e>
    return -1;
  if(pfd)
    80005286:	00090463          	beqz	s2,8000528e <argfd+0x48>
    *pfd = fd;
    8000528a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000528e:	4501                	li	a0,0
  if(pf)
    80005290:	c091                	beqz	s1,80005294 <argfd+0x4e>
    *pf = f;
    80005292:	e09c                	sd	a5,0(s1)
}
    80005294:	70a2                	ld	ra,40(sp)
    80005296:	7402                	ld	s0,32(sp)
    80005298:	64e2                	ld	s1,24(sp)
    8000529a:	6942                	ld	s2,16(sp)
    8000529c:	6145                	addi	sp,sp,48
    8000529e:	8082                	ret
    return -1;
    800052a0:	557d                	li	a0,-1
    800052a2:	bfcd                	j	80005294 <argfd+0x4e>
    800052a4:	557d                	li	a0,-1
    800052a6:	b7fd                	j	80005294 <argfd+0x4e>

00000000800052a8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052a8:	1101                	addi	sp,sp,-32
    800052aa:	ec06                	sd	ra,24(sp)
    800052ac:	e822                	sd	s0,16(sp)
    800052ae:	e426                	sd	s1,8(sp)
    800052b0:	1000                	addi	s0,sp,32
    800052b2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052b4:	ffffd097          	auipc	ra,0xffffd
    800052b8:	84c080e7          	jalr	-1972(ra) # 80001b00 <myproc>
    800052bc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052be:	0d050793          	addi	a5,a0,208
    800052c2:	4501                	li	a0,0
    800052c4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052c6:	6398                	ld	a4,0(a5)
    800052c8:	cb19                	beqz	a4,800052de <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052ca:	2505                	addiw	a0,a0,1
    800052cc:	07a1                	addi	a5,a5,8
    800052ce:	fed51ce3          	bne	a0,a3,800052c6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052d2:	557d                	li	a0,-1
}
    800052d4:	60e2                	ld	ra,24(sp)
    800052d6:	6442                	ld	s0,16(sp)
    800052d8:	64a2                	ld	s1,8(sp)
    800052da:	6105                	addi	sp,sp,32
    800052dc:	8082                	ret
      p->ofile[fd] = f;
    800052de:	00351793          	slli	a5,a0,0x3
    800052e2:	0d078793          	addi	a5,a5,208
    800052e6:	963e                	add	a2,a2,a5
    800052e8:	e204                	sd	s1,0(a2)
      return fd;
    800052ea:	b7ed                	j	800052d4 <fdalloc+0x2c>

00000000800052ec <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052ec:	715d                	addi	sp,sp,-80
    800052ee:	e486                	sd	ra,72(sp)
    800052f0:	e0a2                	sd	s0,64(sp)
    800052f2:	fc26                	sd	s1,56(sp)
    800052f4:	f84a                	sd	s2,48(sp)
    800052f6:	f44e                	sd	s3,40(sp)
    800052f8:	f052                	sd	s4,32(sp)
    800052fa:	ec56                	sd	s5,24(sp)
    800052fc:	e85a                	sd	s6,16(sp)
    800052fe:	0880                	addi	s0,sp,80
    80005300:	892e                	mv	s2,a1
    80005302:	8a2e                	mv	s4,a1
    80005304:	8ab2                	mv	s5,a2
    80005306:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005308:	fb040593          	addi	a1,s0,-80
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	d8a080e7          	jalr	-630(ra) # 80004096 <nameiparent>
    80005314:	84aa                	mv	s1,a0
    80005316:	14050b63          	beqz	a0,8000546c <create+0x180>
    return 0;

  ilock(dp);
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	574080e7          	jalr	1396(ra) # 8000388e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005322:	4601                	li	a2,0
    80005324:	fb040593          	addi	a1,s0,-80
    80005328:	8526                	mv	a0,s1
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	a5e080e7          	jalr	-1442(ra) # 80003d88 <dirlookup>
    80005332:	89aa                	mv	s3,a0
    80005334:	c921                	beqz	a0,80005384 <create+0x98>
    iunlockput(dp);
    80005336:	8526                	mv	a0,s1
    80005338:	ffffe097          	auipc	ra,0xffffe
    8000533c:	7be080e7          	jalr	1982(ra) # 80003af6 <iunlockput>
    ilock(ip);
    80005340:	854e                	mv	a0,s3
    80005342:	ffffe097          	auipc	ra,0xffffe
    80005346:	54c080e7          	jalr	1356(ra) # 8000388e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000534a:	4789                	li	a5,2
    8000534c:	02f91563          	bne	s2,a5,80005376 <create+0x8a>
    80005350:	0449d783          	lhu	a5,68(s3)
    80005354:	37f9                	addiw	a5,a5,-2
    80005356:	17c2                	slli	a5,a5,0x30
    80005358:	93c1                	srli	a5,a5,0x30
    8000535a:	4705                	li	a4,1
    8000535c:	00f76d63          	bltu	a4,a5,80005376 <create+0x8a>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005360:	854e                	mv	a0,s3
    80005362:	60a6                	ld	ra,72(sp)
    80005364:	6406                	ld	s0,64(sp)
    80005366:	74e2                	ld	s1,56(sp)
    80005368:	7942                	ld	s2,48(sp)
    8000536a:	79a2                	ld	s3,40(sp)
    8000536c:	7a02                	ld	s4,32(sp)
    8000536e:	6ae2                	ld	s5,24(sp)
    80005370:	6b42                	ld	s6,16(sp)
    80005372:	6161                	addi	sp,sp,80
    80005374:	8082                	ret
    iunlockput(ip);
    80005376:	854e                	mv	a0,s3
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	77e080e7          	jalr	1918(ra) # 80003af6 <iunlockput>
    return 0;
    80005380:	4981                	li	s3,0
    80005382:	bff9                	j	80005360 <create+0x74>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005384:	85ca                	mv	a1,s2
    80005386:	4088                	lw	a0,0(s1)
    80005388:	ffffe097          	auipc	ra,0xffffe
    8000538c:	362080e7          	jalr	866(ra) # 800036ea <ialloc>
    80005390:	892a                	mv	s2,a0
    80005392:	c531                	beqz	a0,800053de <create+0xf2>
  ilock(ip);
    80005394:	ffffe097          	auipc	ra,0xffffe
    80005398:	4fa080e7          	jalr	1274(ra) # 8000388e <ilock>
  ip->major = major;
    8000539c:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    800053a0:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    800053a4:	4785                	li	a5,1
    800053a6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800053aa:	854a                	mv	a0,s2
    800053ac:	ffffe097          	auipc	ra,0xffffe
    800053b0:	416080e7          	jalr	1046(ra) # 800037c2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053b4:	4705                	li	a4,1
    800053b6:	02ea0a63          	beq	s4,a4,800053ea <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800053ba:	00492603          	lw	a2,4(s2)
    800053be:	fb040593          	addi	a1,s0,-80
    800053c2:	8526                	mv	a0,s1
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	bf2080e7          	jalr	-1038(ra) # 80003fb6 <dirlink>
    800053cc:	06054e63          	bltz	a0,80005448 <create+0x15c>
  iunlockput(dp);
    800053d0:	8526                	mv	a0,s1
    800053d2:	ffffe097          	auipc	ra,0xffffe
    800053d6:	724080e7          	jalr	1828(ra) # 80003af6 <iunlockput>
  return ip;
    800053da:	89ca                	mv	s3,s2
    800053dc:	b751                	j	80005360 <create+0x74>
    iunlockput(dp);
    800053de:	8526                	mv	a0,s1
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	716080e7          	jalr	1814(ra) # 80003af6 <iunlockput>
    return 0;
    800053e8:	bfa5                	j	80005360 <create+0x74>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053ea:	00492603          	lw	a2,4(s2)
    800053ee:	00003597          	auipc	a1,0x3
    800053f2:	1ea58593          	addi	a1,a1,490 # 800085d8 <etext+0x5d8>
    800053f6:	854a                	mv	a0,s2
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	bbe080e7          	jalr	-1090(ra) # 80003fb6 <dirlink>
    80005400:	04054463          	bltz	a0,80005448 <create+0x15c>
    80005404:	40d0                	lw	a2,4(s1)
    80005406:	00003597          	auipc	a1,0x3
    8000540a:	1da58593          	addi	a1,a1,474 # 800085e0 <etext+0x5e0>
    8000540e:	854a                	mv	a0,s2
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	ba6080e7          	jalr	-1114(ra) # 80003fb6 <dirlink>
    80005418:	02054863          	bltz	a0,80005448 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000541c:	00492603          	lw	a2,4(s2)
    80005420:	fb040593          	addi	a1,s0,-80
    80005424:	8526                	mv	a0,s1
    80005426:	fffff097          	auipc	ra,0xfffff
    8000542a:	b90080e7          	jalr	-1136(ra) # 80003fb6 <dirlink>
    8000542e:	00054d63          	bltz	a0,80005448 <create+0x15c>
    dp->nlink++;  // for ".."
    80005432:	04a4d783          	lhu	a5,74(s1)
    80005436:	2785                	addiw	a5,a5,1
    80005438:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000543c:	8526                	mv	a0,s1
    8000543e:	ffffe097          	auipc	ra,0xffffe
    80005442:	384080e7          	jalr	900(ra) # 800037c2 <iupdate>
    80005446:	b769                	j	800053d0 <create+0xe4>
  ip->nlink = 0;
    80005448:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    8000544c:	854a                	mv	a0,s2
    8000544e:	ffffe097          	auipc	ra,0xffffe
    80005452:	374080e7          	jalr	884(ra) # 800037c2 <iupdate>
  iunlockput(ip);
    80005456:	854a                	mv	a0,s2
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	69e080e7          	jalr	1694(ra) # 80003af6 <iunlockput>
  iunlockput(dp);
    80005460:	8526                	mv	a0,s1
    80005462:	ffffe097          	auipc	ra,0xffffe
    80005466:	694080e7          	jalr	1684(ra) # 80003af6 <iunlockput>
  return 0;
    8000546a:	bddd                	j	80005360 <create+0x74>
    return 0;
    8000546c:	89aa                	mv	s3,a0
    8000546e:	bdcd                	j	80005360 <create+0x74>

0000000080005470 <sys_dup>:
{
    80005470:	7179                	addi	sp,sp,-48
    80005472:	f406                	sd	ra,40(sp)
    80005474:	f022                	sd	s0,32(sp)
    80005476:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005478:	fd840613          	addi	a2,s0,-40
    8000547c:	4581                	li	a1,0
    8000547e:	4501                	li	a0,0
    80005480:	00000097          	auipc	ra,0x0
    80005484:	dc6080e7          	jalr	-570(ra) # 80005246 <argfd>
    return -1;
    80005488:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000548a:	02054763          	bltz	a0,800054b8 <sys_dup+0x48>
    8000548e:	ec26                	sd	s1,24(sp)
    80005490:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005492:	fd843483          	ld	s1,-40(s0)
    80005496:	8526                	mv	a0,s1
    80005498:	00000097          	auipc	ra,0x0
    8000549c:	e10080e7          	jalr	-496(ra) # 800052a8 <fdalloc>
    800054a0:	892a                	mv	s2,a0
    return -1;
    800054a2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054a4:	00054f63          	bltz	a0,800054c2 <sys_dup+0x52>
  filedup(f);
    800054a8:	8526                	mv	a0,s1
    800054aa:	fffff097          	auipc	ra,0xfffff
    800054ae:	264080e7          	jalr	612(ra) # 8000470e <filedup>
  return fd;
    800054b2:	87ca                	mv	a5,s2
    800054b4:	64e2                	ld	s1,24(sp)
    800054b6:	6942                	ld	s2,16(sp)
}
    800054b8:	853e                	mv	a0,a5
    800054ba:	70a2                	ld	ra,40(sp)
    800054bc:	7402                	ld	s0,32(sp)
    800054be:	6145                	addi	sp,sp,48
    800054c0:	8082                	ret
    800054c2:	64e2                	ld	s1,24(sp)
    800054c4:	6942                	ld	s2,16(sp)
    800054c6:	bfcd                	j	800054b8 <sys_dup+0x48>

00000000800054c8 <sys_read>:
{
    800054c8:	7179                	addi	sp,sp,-48
    800054ca:	f406                	sd	ra,40(sp)
    800054cc:	f022                	sd	s0,32(sp)
    800054ce:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054d0:	fd840593          	addi	a1,s0,-40
    800054d4:	4505                	li	a0,1
    800054d6:	ffffe097          	auipc	ra,0xffffe
    800054da:	82c080e7          	jalr	-2004(ra) # 80002d02 <argaddr>
  argint(2, &n);
    800054de:	fe440593          	addi	a1,s0,-28
    800054e2:	4509                	li	a0,2
    800054e4:	ffffd097          	auipc	ra,0xffffd
    800054e8:	7fe080e7          	jalr	2046(ra) # 80002ce2 <argint>
  if(argfd(0, 0, &f) < 0)
    800054ec:	fe840613          	addi	a2,s0,-24
    800054f0:	4581                	li	a1,0
    800054f2:	4501                	li	a0,0
    800054f4:	00000097          	auipc	ra,0x0
    800054f8:	d52080e7          	jalr	-686(ra) # 80005246 <argfd>
    800054fc:	87aa                	mv	a5,a0
    return -1;
    800054fe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005500:	0007cc63          	bltz	a5,80005518 <sys_read+0x50>
  return fileread(f, p, n);
    80005504:	fe442603          	lw	a2,-28(s0)
    80005508:	fd843583          	ld	a1,-40(s0)
    8000550c:	fe843503          	ld	a0,-24(s0)
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	3a8080e7          	jalr	936(ra) # 800048b8 <fileread>
}
    80005518:	70a2                	ld	ra,40(sp)
    8000551a:	7402                	ld	s0,32(sp)
    8000551c:	6145                	addi	sp,sp,48
    8000551e:	8082                	ret

0000000080005520 <sys_write>:
{
    80005520:	7179                	addi	sp,sp,-48
    80005522:	f406                	sd	ra,40(sp)
    80005524:	f022                	sd	s0,32(sp)
    80005526:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005528:	fd840593          	addi	a1,s0,-40
    8000552c:	4505                	li	a0,1
    8000552e:	ffffd097          	auipc	ra,0xffffd
    80005532:	7d4080e7          	jalr	2004(ra) # 80002d02 <argaddr>
  argint(2, &n);
    80005536:	fe440593          	addi	a1,s0,-28
    8000553a:	4509                	li	a0,2
    8000553c:	ffffd097          	auipc	ra,0xffffd
    80005540:	7a6080e7          	jalr	1958(ra) # 80002ce2 <argint>
  if(argfd(0, 0, &f) < 0)
    80005544:	fe840613          	addi	a2,s0,-24
    80005548:	4581                	li	a1,0
    8000554a:	4501                	li	a0,0
    8000554c:	00000097          	auipc	ra,0x0
    80005550:	cfa080e7          	jalr	-774(ra) # 80005246 <argfd>
    80005554:	87aa                	mv	a5,a0
    return -1;
    80005556:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005558:	0007cc63          	bltz	a5,80005570 <sys_write+0x50>
  return filewrite(f, p, n);
    8000555c:	fe442603          	lw	a2,-28(s0)
    80005560:	fd843583          	ld	a1,-40(s0)
    80005564:	fe843503          	ld	a0,-24(s0)
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	428080e7          	jalr	1064(ra) # 80004990 <filewrite>
}
    80005570:	70a2                	ld	ra,40(sp)
    80005572:	7402                	ld	s0,32(sp)
    80005574:	6145                	addi	sp,sp,48
    80005576:	8082                	ret

0000000080005578 <sys_close>:
{
    80005578:	1101                	addi	sp,sp,-32
    8000557a:	ec06                	sd	ra,24(sp)
    8000557c:	e822                	sd	s0,16(sp)
    8000557e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005580:	fe040613          	addi	a2,s0,-32
    80005584:	fec40593          	addi	a1,s0,-20
    80005588:	4501                	li	a0,0
    8000558a:	00000097          	auipc	ra,0x0
    8000558e:	cbc080e7          	jalr	-836(ra) # 80005246 <argfd>
    return -1;
    80005592:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005594:	02054563          	bltz	a0,800055be <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005598:	ffffc097          	auipc	ra,0xffffc
    8000559c:	568080e7          	jalr	1384(ra) # 80001b00 <myproc>
    800055a0:	fec42783          	lw	a5,-20(s0)
    800055a4:	078e                	slli	a5,a5,0x3
    800055a6:	0d078793          	addi	a5,a5,208
    800055aa:	953e                	add	a0,a0,a5
    800055ac:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800055b0:	fe043503          	ld	a0,-32(s0)
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	1ac080e7          	jalr	428(ra) # 80004760 <fileclose>
  return 0;
    800055bc:	4781                	li	a5,0
}
    800055be:	853e                	mv	a0,a5
    800055c0:	60e2                	ld	ra,24(sp)
    800055c2:	6442                	ld	s0,16(sp)
    800055c4:	6105                	addi	sp,sp,32
    800055c6:	8082                	ret

00000000800055c8 <sys_fstat>:
{
    800055c8:	1101                	addi	sp,sp,-32
    800055ca:	ec06                	sd	ra,24(sp)
    800055cc:	e822                	sd	s0,16(sp)
    800055ce:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800055d0:	fe040593          	addi	a1,s0,-32
    800055d4:	4505                	li	a0,1
    800055d6:	ffffd097          	auipc	ra,0xffffd
    800055da:	72c080e7          	jalr	1836(ra) # 80002d02 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055de:	fe840613          	addi	a2,s0,-24
    800055e2:	4581                	li	a1,0
    800055e4:	4501                	li	a0,0
    800055e6:	00000097          	auipc	ra,0x0
    800055ea:	c60080e7          	jalr	-928(ra) # 80005246 <argfd>
    800055ee:	87aa                	mv	a5,a0
    return -1;
    800055f0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055f2:	0007ca63          	bltz	a5,80005606 <sys_fstat+0x3e>
  return filestat(f, st);
    800055f6:	fe043583          	ld	a1,-32(s0)
    800055fa:	fe843503          	ld	a0,-24(s0)
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	244080e7          	jalr	580(ra) # 80004842 <filestat>
}
    80005606:	60e2                	ld	ra,24(sp)
    80005608:	6442                	ld	s0,16(sp)
    8000560a:	6105                	addi	sp,sp,32
    8000560c:	8082                	ret

000000008000560e <sys_link>:
{
    8000560e:	7169                	addi	sp,sp,-304
    80005610:	f606                	sd	ra,296(sp)
    80005612:	f222                	sd	s0,288(sp)
    80005614:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005616:	08000613          	li	a2,128
    8000561a:	ed040593          	addi	a1,s0,-304
    8000561e:	4501                	li	a0,0
    80005620:	ffffd097          	auipc	ra,0xffffd
    80005624:	702080e7          	jalr	1794(ra) # 80002d22 <argstr>
    return -1;
    80005628:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000562a:	12054663          	bltz	a0,80005756 <sys_link+0x148>
    8000562e:	08000613          	li	a2,128
    80005632:	f5040593          	addi	a1,s0,-176
    80005636:	4505                	li	a0,1
    80005638:	ffffd097          	auipc	ra,0xffffd
    8000563c:	6ea080e7          	jalr	1770(ra) # 80002d22 <argstr>
    return -1;
    80005640:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005642:	10054a63          	bltz	a0,80005756 <sys_link+0x148>
    80005646:	ee26                	sd	s1,280(sp)
  begin_op();
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	c36080e7          	jalr	-970(ra) # 8000427e <begin_op>
  if((ip = namei(old)) == 0){
    80005650:	ed040513          	addi	a0,s0,-304
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	a24080e7          	jalr	-1500(ra) # 80004078 <namei>
    8000565c:	84aa                	mv	s1,a0
    8000565e:	c949                	beqz	a0,800056f0 <sys_link+0xe2>
  ilock(ip);
    80005660:	ffffe097          	auipc	ra,0xffffe
    80005664:	22e080e7          	jalr	558(ra) # 8000388e <ilock>
  if(ip->type == T_DIR){
    80005668:	04449703          	lh	a4,68(s1)
    8000566c:	4785                	li	a5,1
    8000566e:	08f70863          	beq	a4,a5,800056fe <sys_link+0xf0>
    80005672:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005674:	04a4d783          	lhu	a5,74(s1)
    80005678:	2785                	addiw	a5,a5,1
    8000567a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000567e:	8526                	mv	a0,s1
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	142080e7          	jalr	322(ra) # 800037c2 <iupdate>
  iunlock(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	2ca080e7          	jalr	714(ra) # 80003954 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005692:	fd040593          	addi	a1,s0,-48
    80005696:	f5040513          	addi	a0,s0,-176
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	9fc080e7          	jalr	-1540(ra) # 80004096 <nameiparent>
    800056a2:	892a                	mv	s2,a0
    800056a4:	cd35                	beqz	a0,80005720 <sys_link+0x112>
  ilock(dp);
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	1e8080e7          	jalr	488(ra) # 8000388e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056ae:	854a                	mv	a0,s2
    800056b0:	00092703          	lw	a4,0(s2)
    800056b4:	409c                	lw	a5,0(s1)
    800056b6:	06f71063          	bne	a4,a5,80005716 <sys_link+0x108>
    800056ba:	40d0                	lw	a2,4(s1)
    800056bc:	fd040593          	addi	a1,s0,-48
    800056c0:	fffff097          	auipc	ra,0xfffff
    800056c4:	8f6080e7          	jalr	-1802(ra) # 80003fb6 <dirlink>
    800056c8:	04054763          	bltz	a0,80005716 <sys_link+0x108>
  iunlockput(dp);
    800056cc:	854a                	mv	a0,s2
    800056ce:	ffffe097          	auipc	ra,0xffffe
    800056d2:	428080e7          	jalr	1064(ra) # 80003af6 <iunlockput>
  iput(ip);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	374080e7          	jalr	884(ra) # 80003a4c <iput>
  end_op();
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	c1e080e7          	jalr	-994(ra) # 800042fe <end_op>
  return 0;
    800056e8:	4781                	li	a5,0
    800056ea:	64f2                	ld	s1,280(sp)
    800056ec:	6952                	ld	s2,272(sp)
    800056ee:	a0a5                	j	80005756 <sys_link+0x148>
    end_op();
    800056f0:	fffff097          	auipc	ra,0xfffff
    800056f4:	c0e080e7          	jalr	-1010(ra) # 800042fe <end_op>
    return -1;
    800056f8:	57fd                	li	a5,-1
    800056fa:	64f2                	ld	s1,280(sp)
    800056fc:	a8a9                	j	80005756 <sys_link+0x148>
    iunlockput(ip);
    800056fe:	8526                	mv	a0,s1
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	3f6080e7          	jalr	1014(ra) # 80003af6 <iunlockput>
    end_op();
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	bf6080e7          	jalr	-1034(ra) # 800042fe <end_op>
    return -1;
    80005710:	57fd                	li	a5,-1
    80005712:	64f2                	ld	s1,280(sp)
    80005714:	a089                	j	80005756 <sys_link+0x148>
    iunlockput(dp);
    80005716:	854a                	mv	a0,s2
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	3de080e7          	jalr	990(ra) # 80003af6 <iunlockput>
  ilock(ip);
    80005720:	8526                	mv	a0,s1
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	16c080e7          	jalr	364(ra) # 8000388e <ilock>
  ip->nlink--;
    8000572a:	04a4d783          	lhu	a5,74(s1)
    8000572e:	37fd                	addiw	a5,a5,-1
    80005730:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005734:	8526                	mv	a0,s1
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	08c080e7          	jalr	140(ra) # 800037c2 <iupdate>
  iunlockput(ip);
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	3b6080e7          	jalr	950(ra) # 80003af6 <iunlockput>
  end_op();
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	bb6080e7          	jalr	-1098(ra) # 800042fe <end_op>
  return -1;
    80005750:	57fd                	li	a5,-1
    80005752:	64f2                	ld	s1,280(sp)
    80005754:	6952                	ld	s2,272(sp)
}
    80005756:	853e                	mv	a0,a5
    80005758:	70b2                	ld	ra,296(sp)
    8000575a:	7412                	ld	s0,288(sp)
    8000575c:	6155                	addi	sp,sp,304
    8000575e:	8082                	ret

0000000080005760 <sys_unlink>:
{
    80005760:	7151                	addi	sp,sp,-240
    80005762:	f586                	sd	ra,232(sp)
    80005764:	f1a2                	sd	s0,224(sp)
    80005766:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005768:	08000613          	li	a2,128
    8000576c:	f3040593          	addi	a1,s0,-208
    80005770:	4501                	li	a0,0
    80005772:	ffffd097          	auipc	ra,0xffffd
    80005776:	5b0080e7          	jalr	1456(ra) # 80002d22 <argstr>
    8000577a:	1a054763          	bltz	a0,80005928 <sys_unlink+0x1c8>
    8000577e:	eda6                	sd	s1,216(sp)
  begin_op();
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	afe080e7          	jalr	-1282(ra) # 8000427e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005788:	fb040593          	addi	a1,s0,-80
    8000578c:	f3040513          	addi	a0,s0,-208
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	906080e7          	jalr	-1786(ra) # 80004096 <nameiparent>
    80005798:	84aa                	mv	s1,a0
    8000579a:	c165                	beqz	a0,8000587a <sys_unlink+0x11a>
  ilock(dp);
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	0f2080e7          	jalr	242(ra) # 8000388e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057a4:	00003597          	auipc	a1,0x3
    800057a8:	e3458593          	addi	a1,a1,-460 # 800085d8 <etext+0x5d8>
    800057ac:	fb040513          	addi	a0,s0,-80
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	5be080e7          	jalr	1470(ra) # 80003d6e <namecmp>
    800057b8:	14050963          	beqz	a0,8000590a <sys_unlink+0x1aa>
    800057bc:	00003597          	auipc	a1,0x3
    800057c0:	e2458593          	addi	a1,a1,-476 # 800085e0 <etext+0x5e0>
    800057c4:	fb040513          	addi	a0,s0,-80
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	5a6080e7          	jalr	1446(ra) # 80003d6e <namecmp>
    800057d0:	12050d63          	beqz	a0,8000590a <sys_unlink+0x1aa>
    800057d4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057d6:	f2c40613          	addi	a2,s0,-212
    800057da:	fb040593          	addi	a1,s0,-80
    800057de:	8526                	mv	a0,s1
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	5a8080e7          	jalr	1448(ra) # 80003d88 <dirlookup>
    800057e8:	892a                	mv	s2,a0
    800057ea:	10050f63          	beqz	a0,80005908 <sys_unlink+0x1a8>
    800057ee:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	09e080e7          	jalr	158(ra) # 8000388e <ilock>
  if(ip->nlink < 1)
    800057f8:	04a91783          	lh	a5,74(s2)
    800057fc:	08f05663          	blez	a5,80005888 <sys_unlink+0x128>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005800:	04491703          	lh	a4,68(s2)
    80005804:	4785                	li	a5,1
    80005806:	08f70963          	beq	a4,a5,80005898 <sys_unlink+0x138>
  memset(&de, 0, sizeof(de));
    8000580a:	fc040993          	addi	s3,s0,-64
    8000580e:	4641                	li	a2,16
    80005810:	4581                	li	a1,0
    80005812:	854e                	mv	a0,s3
    80005814:	ffffb097          	auipc	ra,0xffffb
    80005818:	540080e7          	jalr	1344(ra) # 80000d54 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000581c:	4741                	li	a4,16
    8000581e:	f2c42683          	lw	a3,-212(s0)
    80005822:	864e                	mv	a2,s3
    80005824:	4581                	li	a1,0
    80005826:	8526                	mv	a0,s1
    80005828:	ffffe097          	auipc	ra,0xffffe
    8000582c:	42a080e7          	jalr	1066(ra) # 80003c52 <writei>
    80005830:	47c1                	li	a5,16
    80005832:	0af51863          	bne	a0,a5,800058e2 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005836:	04491703          	lh	a4,68(s2)
    8000583a:	4785                	li	a5,1
    8000583c:	0af70b63          	beq	a4,a5,800058f2 <sys_unlink+0x192>
  iunlockput(dp);
    80005840:	8526                	mv	a0,s1
    80005842:	ffffe097          	auipc	ra,0xffffe
    80005846:	2b4080e7          	jalr	692(ra) # 80003af6 <iunlockput>
  ip->nlink--;
    8000584a:	04a95783          	lhu	a5,74(s2)
    8000584e:	37fd                	addiw	a5,a5,-1
    80005850:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005854:	854a                	mv	a0,s2
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	f6c080e7          	jalr	-148(ra) # 800037c2 <iupdate>
  iunlockput(ip);
    8000585e:	854a                	mv	a0,s2
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	296080e7          	jalr	662(ra) # 80003af6 <iunlockput>
  end_op();
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	a96080e7          	jalr	-1386(ra) # 800042fe <end_op>
  return 0;
    80005870:	4501                	li	a0,0
    80005872:	64ee                	ld	s1,216(sp)
    80005874:	694e                	ld	s2,208(sp)
    80005876:	69ae                	ld	s3,200(sp)
    80005878:	a065                	j	80005920 <sys_unlink+0x1c0>
    end_op();
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	a84080e7          	jalr	-1404(ra) # 800042fe <end_op>
    return -1;
    80005882:	557d                	li	a0,-1
    80005884:	64ee                	ld	s1,216(sp)
    80005886:	a869                	j	80005920 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80005888:	00003517          	auipc	a0,0x3
    8000588c:	d6050513          	addi	a0,a0,-672 # 800085e8 <etext+0x5e8>
    80005890:	ffffb097          	auipc	ra,0xffffb
    80005894:	cce080e7          	jalr	-818(ra) # 8000055e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005898:	04c92703          	lw	a4,76(s2)
    8000589c:	02000793          	li	a5,32
    800058a0:	f6e7f5e3          	bgeu	a5,a4,8000580a <sys_unlink+0xaa>
    800058a4:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058a6:	4741                	li	a4,16
    800058a8:	86ce                	mv	a3,s3
    800058aa:	f1840613          	addi	a2,s0,-232
    800058ae:	4581                	li	a1,0
    800058b0:	854a                	mv	a0,s2
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	29a080e7          	jalr	666(ra) # 80003b4c <readi>
    800058ba:	47c1                	li	a5,16
    800058bc:	00f51b63          	bne	a0,a5,800058d2 <sys_unlink+0x172>
    if(de.inum != 0)
    800058c0:	f1845783          	lhu	a5,-232(s0)
    800058c4:	e7a5                	bnez	a5,8000592c <sys_unlink+0x1cc>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058c6:	29c1                	addiw	s3,s3,16
    800058c8:	04c92783          	lw	a5,76(s2)
    800058cc:	fcf9ede3          	bltu	s3,a5,800058a6 <sys_unlink+0x146>
    800058d0:	bf2d                	j	8000580a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058d2:	00003517          	auipc	a0,0x3
    800058d6:	d2e50513          	addi	a0,a0,-722 # 80008600 <etext+0x600>
    800058da:	ffffb097          	auipc	ra,0xffffb
    800058de:	c84080e7          	jalr	-892(ra) # 8000055e <panic>
    panic("unlink: writei");
    800058e2:	00003517          	auipc	a0,0x3
    800058e6:	d3650513          	addi	a0,a0,-714 # 80008618 <etext+0x618>
    800058ea:	ffffb097          	auipc	ra,0xffffb
    800058ee:	c74080e7          	jalr	-908(ra) # 8000055e <panic>
    dp->nlink--;
    800058f2:	04a4d783          	lhu	a5,74(s1)
    800058f6:	37fd                	addiw	a5,a5,-1
    800058f8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058fc:	8526                	mv	a0,s1
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	ec4080e7          	jalr	-316(ra) # 800037c2 <iupdate>
    80005906:	bf2d                	j	80005840 <sys_unlink+0xe0>
    80005908:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000590a:	8526                	mv	a0,s1
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	1ea080e7          	jalr	490(ra) # 80003af6 <iunlockput>
  end_op();
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	9ea080e7          	jalr	-1558(ra) # 800042fe <end_op>
  return -1;
    8000591c:	557d                	li	a0,-1
    8000591e:	64ee                	ld	s1,216(sp)
}
    80005920:	70ae                	ld	ra,232(sp)
    80005922:	740e                	ld	s0,224(sp)
    80005924:	616d                	addi	sp,sp,240
    80005926:	8082                	ret
    return -1;
    80005928:	557d                	li	a0,-1
    8000592a:	bfdd                	j	80005920 <sys_unlink+0x1c0>
    iunlockput(ip);
    8000592c:	854a                	mv	a0,s2
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	1c8080e7          	jalr	456(ra) # 80003af6 <iunlockput>
    goto bad;
    80005936:	694e                	ld	s2,208(sp)
    80005938:	69ae                	ld	s3,200(sp)
    8000593a:	bfc1                	j	8000590a <sys_unlink+0x1aa>

000000008000593c <sys_open>:

uint64
sys_open(void)
{
    8000593c:	7131                	addi	sp,sp,-192
    8000593e:	fd06                	sd	ra,184(sp)
    80005940:	f922                	sd	s0,176(sp)
    80005942:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005944:	f4c40593          	addi	a1,s0,-180
    80005948:	4505                	li	a0,1
    8000594a:	ffffd097          	auipc	ra,0xffffd
    8000594e:	398080e7          	jalr	920(ra) # 80002ce2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005952:	08000613          	li	a2,128
    80005956:	f5040593          	addi	a1,s0,-176
    8000595a:	4501                	li	a0,0
    8000595c:	ffffd097          	auipc	ra,0xffffd
    80005960:	3c6080e7          	jalr	966(ra) # 80002d22 <argstr>
    80005964:	87aa                	mv	a5,a0
    return -1;
    80005966:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005968:	0a07cf63          	bltz	a5,80005a26 <sys_open+0xea>
    8000596c:	f526                	sd	s1,168(sp)

  begin_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	910080e7          	jalr	-1776(ra) # 8000427e <begin_op>

  if(omode & O_CREATE){
    80005976:	f4c42783          	lw	a5,-180(s0)
    8000597a:	2007f793          	andi	a5,a5,512
    8000597e:	cfdd                	beqz	a5,80005a3c <sys_open+0x100>
    ip = create(path, T_FILE, 0, 0);
    80005980:	4681                	li	a3,0
    80005982:	4601                	li	a2,0
    80005984:	4589                	li	a1,2
    80005986:	f5040513          	addi	a0,s0,-176
    8000598a:	00000097          	auipc	ra,0x0
    8000598e:	962080e7          	jalr	-1694(ra) # 800052ec <create>
    80005992:	84aa                	mv	s1,a0
    if(ip == 0){
    80005994:	cd49                	beqz	a0,80005a2e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005996:	04449703          	lh	a4,68(s1)
    8000599a:	478d                	li	a5,3
    8000599c:	00f71763          	bne	a4,a5,800059aa <sys_open+0x6e>
    800059a0:	0464d703          	lhu	a4,70(s1)
    800059a4:	47a5                	li	a5,9
    800059a6:	0ee7e263          	bltu	a5,a4,80005a8a <sys_open+0x14e>
    800059aa:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	cf8080e7          	jalr	-776(ra) # 800046a4 <filealloc>
    800059b4:	892a                	mv	s2,a0
    800059b6:	cd65                	beqz	a0,80005aae <sys_open+0x172>
    800059b8:	ed4e                	sd	s3,152(sp)
    800059ba:	00000097          	auipc	ra,0x0
    800059be:	8ee080e7          	jalr	-1810(ra) # 800052a8 <fdalloc>
    800059c2:	89aa                	mv	s3,a0
    800059c4:	0c054f63          	bltz	a0,80005aa2 <sys_open+0x166>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059c8:	04449703          	lh	a4,68(s1)
    800059cc:	478d                	li	a5,3
    800059ce:	0ef70d63          	beq	a4,a5,80005ac8 <sys_open+0x18c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800059d2:	4789                	li	a5,2
    800059d4:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800059d8:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800059dc:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800059e0:	f4c42783          	lw	a5,-180(s0)
    800059e4:	0017f713          	andi	a4,a5,1
    800059e8:	00174713          	xori	a4,a4,1
    800059ec:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059f0:	0037f713          	andi	a4,a5,3
    800059f4:	00e03733          	snez	a4,a4
    800059f8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059fc:	4007f793          	andi	a5,a5,1024
    80005a00:	c791                	beqz	a5,80005a0c <sys_open+0xd0>
    80005a02:	04449703          	lh	a4,68(s1)
    80005a06:	4789                	li	a5,2
    80005a08:	0cf70763          	beq	a4,a5,80005ad6 <sys_open+0x19a>
    itrunc(ip);
  }

  iunlock(ip);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	f46080e7          	jalr	-186(ra) # 80003954 <iunlock>
  end_op();
    80005a16:	fffff097          	auipc	ra,0xfffff
    80005a1a:	8e8080e7          	jalr	-1816(ra) # 800042fe <end_op>

  return fd;
    80005a1e:	854e                	mv	a0,s3
    80005a20:	74aa                	ld	s1,168(sp)
    80005a22:	790a                	ld	s2,160(sp)
    80005a24:	69ea                	ld	s3,152(sp)
}
    80005a26:	70ea                	ld	ra,184(sp)
    80005a28:	744a                	ld	s0,176(sp)
    80005a2a:	6129                	addi	sp,sp,192
    80005a2c:	8082                	ret
      end_op();
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	8d0080e7          	jalr	-1840(ra) # 800042fe <end_op>
      return -1;
    80005a36:	557d                	li	a0,-1
    80005a38:	74aa                	ld	s1,168(sp)
    80005a3a:	b7f5                	j	80005a26 <sys_open+0xea>
    if((ip = namei(path)) == 0){
    80005a3c:	f5040513          	addi	a0,s0,-176
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	638080e7          	jalr	1592(ra) # 80004078 <namei>
    80005a48:	84aa                	mv	s1,a0
    80005a4a:	c90d                	beqz	a0,80005a7c <sys_open+0x140>
    ilock(ip);
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	e42080e7          	jalr	-446(ra) # 8000388e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a54:	04449703          	lh	a4,68(s1)
    80005a58:	4785                	li	a5,1
    80005a5a:	f2f71ee3          	bne	a4,a5,80005996 <sys_open+0x5a>
    80005a5e:	f4c42783          	lw	a5,-180(s0)
    80005a62:	d7a1                	beqz	a5,800059aa <sys_open+0x6e>
      iunlockput(ip);
    80005a64:	8526                	mv	a0,s1
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	090080e7          	jalr	144(ra) # 80003af6 <iunlockput>
      end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	890080e7          	jalr	-1904(ra) # 800042fe <end_op>
      return -1;
    80005a76:	557d                	li	a0,-1
    80005a78:	74aa                	ld	s1,168(sp)
    80005a7a:	b775                	j	80005a26 <sys_open+0xea>
      end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	882080e7          	jalr	-1918(ra) # 800042fe <end_op>
      return -1;
    80005a84:	557d                	li	a0,-1
    80005a86:	74aa                	ld	s1,168(sp)
    80005a88:	bf79                	j	80005a26 <sys_open+0xea>
    iunlockput(ip);
    80005a8a:	8526                	mv	a0,s1
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	06a080e7          	jalr	106(ra) # 80003af6 <iunlockput>
    end_op();
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	86a080e7          	jalr	-1942(ra) # 800042fe <end_op>
    return -1;
    80005a9c:	557d                	li	a0,-1
    80005a9e:	74aa                	ld	s1,168(sp)
    80005aa0:	b759                	j	80005a26 <sys_open+0xea>
      fileclose(f);
    80005aa2:	854a                	mv	a0,s2
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	cbc080e7          	jalr	-836(ra) # 80004760 <fileclose>
    80005aac:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	046080e7          	jalr	70(ra) # 80003af6 <iunlockput>
    end_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	846080e7          	jalr	-1978(ra) # 800042fe <end_op>
    return -1;
    80005ac0:	557d                	li	a0,-1
    80005ac2:	74aa                	ld	s1,168(sp)
    80005ac4:	790a                	ld	s2,160(sp)
    80005ac6:	b785                	j	80005a26 <sys_open+0xea>
    f->type = FD_DEVICE;
    80005ac8:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005acc:	04649783          	lh	a5,70(s1)
    80005ad0:	02f91223          	sh	a5,36(s2)
    80005ad4:	b721                	j	800059dc <sys_open+0xa0>
    itrunc(ip);
    80005ad6:	8526                	mv	a0,s1
    80005ad8:	ffffe097          	auipc	ra,0xffffe
    80005adc:	ec8080e7          	jalr	-312(ra) # 800039a0 <itrunc>
    80005ae0:	b735                	j	80005a0c <sys_open+0xd0>

0000000080005ae2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ae2:	7175                	addi	sp,sp,-144
    80005ae4:	e506                	sd	ra,136(sp)
    80005ae6:	e122                	sd	s0,128(sp)
    80005ae8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	794080e7          	jalr	1940(ra) # 8000427e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005af2:	08000613          	li	a2,128
    80005af6:	f7040593          	addi	a1,s0,-144
    80005afa:	4501                	li	a0,0
    80005afc:	ffffd097          	auipc	ra,0xffffd
    80005b00:	226080e7          	jalr	550(ra) # 80002d22 <argstr>
    80005b04:	02054963          	bltz	a0,80005b36 <sys_mkdir+0x54>
    80005b08:	4681                	li	a3,0
    80005b0a:	4601                	li	a2,0
    80005b0c:	4585                	li	a1,1
    80005b0e:	f7040513          	addi	a0,s0,-144
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	7da080e7          	jalr	2010(ra) # 800052ec <create>
    80005b1a:	cd11                	beqz	a0,80005b36 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	fda080e7          	jalr	-38(ra) # 80003af6 <iunlockput>
  end_op();
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	7da080e7          	jalr	2010(ra) # 800042fe <end_op>
  return 0;
    80005b2c:	4501                	li	a0,0
}
    80005b2e:	60aa                	ld	ra,136(sp)
    80005b30:	640a                	ld	s0,128(sp)
    80005b32:	6149                	addi	sp,sp,144
    80005b34:	8082                	ret
    end_op();
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	7c8080e7          	jalr	1992(ra) # 800042fe <end_op>
    return -1;
    80005b3e:	557d                	li	a0,-1
    80005b40:	b7fd                	j	80005b2e <sys_mkdir+0x4c>

0000000080005b42 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b42:	7135                	addi	sp,sp,-160
    80005b44:	ed06                	sd	ra,152(sp)
    80005b46:	e922                	sd	s0,144(sp)
    80005b48:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b4a:	ffffe097          	auipc	ra,0xffffe
    80005b4e:	734080e7          	jalr	1844(ra) # 8000427e <begin_op>
  argint(1, &major);
    80005b52:	f6c40593          	addi	a1,s0,-148
    80005b56:	4505                	li	a0,1
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	18a080e7          	jalr	394(ra) # 80002ce2 <argint>
  argint(2, &minor);
    80005b60:	f6840593          	addi	a1,s0,-152
    80005b64:	4509                	li	a0,2
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	17c080e7          	jalr	380(ra) # 80002ce2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b6e:	08000613          	li	a2,128
    80005b72:	f7040593          	addi	a1,s0,-144
    80005b76:	4501                	li	a0,0
    80005b78:	ffffd097          	auipc	ra,0xffffd
    80005b7c:	1aa080e7          	jalr	426(ra) # 80002d22 <argstr>
    80005b80:	02054b63          	bltz	a0,80005bb6 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b84:	f6841683          	lh	a3,-152(s0)
    80005b88:	f6c41603          	lh	a2,-148(s0)
    80005b8c:	458d                	li	a1,3
    80005b8e:	f7040513          	addi	a0,s0,-144
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	75a080e7          	jalr	1882(ra) # 800052ec <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b9a:	cd11                	beqz	a0,80005bb6 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	f5a080e7          	jalr	-166(ra) # 80003af6 <iunlockput>
  end_op();
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	75a080e7          	jalr	1882(ra) # 800042fe <end_op>
  return 0;
    80005bac:	4501                	li	a0,0
}
    80005bae:	60ea                	ld	ra,152(sp)
    80005bb0:	644a                	ld	s0,144(sp)
    80005bb2:	610d                	addi	sp,sp,160
    80005bb4:	8082                	ret
    end_op();
    80005bb6:	ffffe097          	auipc	ra,0xffffe
    80005bba:	748080e7          	jalr	1864(ra) # 800042fe <end_op>
    return -1;
    80005bbe:	557d                	li	a0,-1
    80005bc0:	b7fd                	j	80005bae <sys_mknod+0x6c>

0000000080005bc2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bc2:	7135                	addi	sp,sp,-160
    80005bc4:	ed06                	sd	ra,152(sp)
    80005bc6:	e922                	sd	s0,144(sp)
    80005bc8:	e14a                	sd	s2,128(sp)
    80005bca:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bcc:	ffffc097          	auipc	ra,0xffffc
    80005bd0:	f34080e7          	jalr	-204(ra) # 80001b00 <myproc>
    80005bd4:	892a                	mv	s2,a0
  
  begin_op();
    80005bd6:	ffffe097          	auipc	ra,0xffffe
    80005bda:	6a8080e7          	jalr	1704(ra) # 8000427e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bde:	08000613          	li	a2,128
    80005be2:	f6040593          	addi	a1,s0,-160
    80005be6:	4501                	li	a0,0
    80005be8:	ffffd097          	auipc	ra,0xffffd
    80005bec:	13a080e7          	jalr	314(ra) # 80002d22 <argstr>
    80005bf0:	04054d63          	bltz	a0,80005c4a <sys_chdir+0x88>
    80005bf4:	e526                	sd	s1,136(sp)
    80005bf6:	f6040513          	addi	a0,s0,-160
    80005bfa:	ffffe097          	auipc	ra,0xffffe
    80005bfe:	47e080e7          	jalr	1150(ra) # 80004078 <namei>
    80005c02:	84aa                	mv	s1,a0
    80005c04:	c131                	beqz	a0,80005c48 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	c88080e7          	jalr	-888(ra) # 8000388e <ilock>
  if(ip->type != T_DIR){
    80005c0e:	04449703          	lh	a4,68(s1)
    80005c12:	4785                	li	a5,1
    80005c14:	04f71163          	bne	a4,a5,80005c56 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c18:	8526                	mv	a0,s1
    80005c1a:	ffffe097          	auipc	ra,0xffffe
    80005c1e:	d3a080e7          	jalr	-710(ra) # 80003954 <iunlock>
  iput(p->cwd);
    80005c22:	15093503          	ld	a0,336(s2)
    80005c26:	ffffe097          	auipc	ra,0xffffe
    80005c2a:	e26080e7          	jalr	-474(ra) # 80003a4c <iput>
  end_op();
    80005c2e:	ffffe097          	auipc	ra,0xffffe
    80005c32:	6d0080e7          	jalr	1744(ra) # 800042fe <end_op>
  p->cwd = ip;
    80005c36:	14993823          	sd	s1,336(s2)
  return 0;
    80005c3a:	4501                	li	a0,0
    80005c3c:	64aa                	ld	s1,136(sp)
}
    80005c3e:	60ea                	ld	ra,152(sp)
    80005c40:	644a                	ld	s0,144(sp)
    80005c42:	690a                	ld	s2,128(sp)
    80005c44:	610d                	addi	sp,sp,160
    80005c46:	8082                	ret
    80005c48:	64aa                	ld	s1,136(sp)
    end_op();
    80005c4a:	ffffe097          	auipc	ra,0xffffe
    80005c4e:	6b4080e7          	jalr	1716(ra) # 800042fe <end_op>
    return -1;
    80005c52:	557d                	li	a0,-1
    80005c54:	b7ed                	j	80005c3e <sys_chdir+0x7c>
    iunlockput(ip);
    80005c56:	8526                	mv	a0,s1
    80005c58:	ffffe097          	auipc	ra,0xffffe
    80005c5c:	e9e080e7          	jalr	-354(ra) # 80003af6 <iunlockput>
    end_op();
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	69e080e7          	jalr	1694(ra) # 800042fe <end_op>
    return -1;
    80005c68:	557d                	li	a0,-1
    80005c6a:	64aa                	ld	s1,136(sp)
    80005c6c:	bfc9                	j	80005c3e <sys_chdir+0x7c>

0000000080005c6e <sys_exec>:

uint64
sys_exec(void)
{
    80005c6e:	7105                	addi	sp,sp,-480
    80005c70:	ef86                	sd	ra,472(sp)
    80005c72:	eba2                	sd	s0,464(sp)
    80005c74:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c76:	e2840593          	addi	a1,s0,-472
    80005c7a:	4505                	li	a0,1
    80005c7c:	ffffd097          	auipc	ra,0xffffd
    80005c80:	086080e7          	jalr	134(ra) # 80002d02 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c84:	08000613          	li	a2,128
    80005c88:	f3040593          	addi	a1,s0,-208
    80005c8c:	4501                	li	a0,0
    80005c8e:	ffffd097          	auipc	ra,0xffffd
    80005c92:	094080e7          	jalr	148(ra) # 80002d22 <argstr>
    80005c96:	87aa                	mv	a5,a0
    return -1;
    80005c98:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c9a:	0e07ce63          	bltz	a5,80005d96 <sys_exec+0x128>
    80005c9e:	e7a6                	sd	s1,456(sp)
    80005ca0:	e3ca                	sd	s2,448(sp)
    80005ca2:	ff4e                	sd	s3,440(sp)
    80005ca4:	fb52                	sd	s4,432(sp)
    80005ca6:	f756                	sd	s5,424(sp)
    80005ca8:	f35a                	sd	s6,416(sp)
    80005caa:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005cac:	e3040a13          	addi	s4,s0,-464
    80005cb0:	10000613          	li	a2,256
    80005cb4:	4581                	li	a1,0
    80005cb6:	8552                	mv	a0,s4
    80005cb8:	ffffb097          	auipc	ra,0xffffb
    80005cbc:	09c080e7          	jalr	156(ra) # 80000d54 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cc0:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005cc2:	89d2                	mv	s3,s4
    80005cc4:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cc6:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cca:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005ccc:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cd0:	00391513          	slli	a0,s2,0x3
    80005cd4:	85d6                	mv	a1,s5
    80005cd6:	e2843783          	ld	a5,-472(s0)
    80005cda:	953e                	add	a0,a0,a5
    80005cdc:	ffffd097          	auipc	ra,0xffffd
    80005ce0:	f68080e7          	jalr	-152(ra) # 80002c44 <fetchaddr>
    80005ce4:	02054a63          	bltz	a0,80005d18 <sys_exec+0xaa>
    if(uarg == 0){
    80005ce8:	e2043783          	ld	a5,-480(s0)
    80005cec:	cbb1                	beqz	a5,80005d40 <sys_exec+0xd2>
    argv[i] = kalloc();
    80005cee:	ffffb097          	auipc	ra,0xffffb
    80005cf2:	e6a080e7          	jalr	-406(ra) # 80000b58 <kalloc>
    80005cf6:	85aa                	mv	a1,a0
    80005cf8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cfc:	cd11                	beqz	a0,80005d18 <sys_exec+0xaa>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cfe:	865a                	mv	a2,s6
    80005d00:	e2043503          	ld	a0,-480(s0)
    80005d04:	ffffd097          	auipc	ra,0xffffd
    80005d08:	f92080e7          	jalr	-110(ra) # 80002c96 <fetchstr>
    80005d0c:	00054663          	bltz	a0,80005d18 <sys_exec+0xaa>
    if(i >= NELEM(argv)){
    80005d10:	0905                	addi	s2,s2,1
    80005d12:	09a1                	addi	s3,s3,8
    80005d14:	fb791ee3          	bne	s2,s7,80005cd0 <sys_exec+0x62>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d18:	100a0a13          	addi	s4,s4,256
    80005d1c:	6088                	ld	a0,0(s1)
    80005d1e:	c525                	beqz	a0,80005d86 <sys_exec+0x118>
    kfree(argv[i]);
    80005d20:	ffffb097          	auipc	ra,0xffffb
    80005d24:	d34080e7          	jalr	-716(ra) # 80000a54 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d28:	04a1                	addi	s1,s1,8
    80005d2a:	ff4499e3          	bne	s1,s4,80005d1c <sys_exec+0xae>
  return -1;
    80005d2e:	557d                	li	a0,-1
    80005d30:	64be                	ld	s1,456(sp)
    80005d32:	691e                	ld	s2,448(sp)
    80005d34:	79fa                	ld	s3,440(sp)
    80005d36:	7a5a                	ld	s4,432(sp)
    80005d38:	7aba                	ld	s5,424(sp)
    80005d3a:	7b1a                	ld	s6,416(sp)
    80005d3c:	6bfa                	ld	s7,408(sp)
    80005d3e:	a8a1                	j	80005d96 <sys_exec+0x128>
      argv[i] = 0;
    80005d40:	0009079b          	sext.w	a5,s2
    80005d44:	e3040593          	addi	a1,s0,-464
    80005d48:	078e                	slli	a5,a5,0x3
    80005d4a:	97ae                	add	a5,a5,a1
    80005d4c:	0007b023          	sd	zero,0(a5)
  int ret = exec(path, argv);
    80005d50:	f3040513          	addi	a0,s0,-208
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	126080e7          	jalr	294(ra) # 80004e7a <exec>
    80005d5c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d5e:	100a0a13          	addi	s4,s4,256
    80005d62:	6088                	ld	a0,0(s1)
    80005d64:	c901                	beqz	a0,80005d74 <sys_exec+0x106>
    kfree(argv[i]);
    80005d66:	ffffb097          	auipc	ra,0xffffb
    80005d6a:	cee080e7          	jalr	-786(ra) # 80000a54 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d6e:	04a1                	addi	s1,s1,8
    80005d70:	ff4499e3          	bne	s1,s4,80005d62 <sys_exec+0xf4>
  return ret;
    80005d74:	854a                	mv	a0,s2
    80005d76:	64be                	ld	s1,456(sp)
    80005d78:	691e                	ld	s2,448(sp)
    80005d7a:	79fa                	ld	s3,440(sp)
    80005d7c:	7a5a                	ld	s4,432(sp)
    80005d7e:	7aba                	ld	s5,424(sp)
    80005d80:	7b1a                	ld	s6,416(sp)
    80005d82:	6bfa                	ld	s7,408(sp)
    80005d84:	a809                	j	80005d96 <sys_exec+0x128>
  return -1;
    80005d86:	557d                	li	a0,-1
    80005d88:	64be                	ld	s1,456(sp)
    80005d8a:	691e                	ld	s2,448(sp)
    80005d8c:	79fa                	ld	s3,440(sp)
    80005d8e:	7a5a                	ld	s4,432(sp)
    80005d90:	7aba                	ld	s5,424(sp)
    80005d92:	7b1a                	ld	s6,416(sp)
    80005d94:	6bfa                	ld	s7,408(sp)
}
    80005d96:	60fe                	ld	ra,472(sp)
    80005d98:	645e                	ld	s0,464(sp)
    80005d9a:	613d                	addi	sp,sp,480
    80005d9c:	8082                	ret

0000000080005d9e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d9e:	7139                	addi	sp,sp,-64
    80005da0:	fc06                	sd	ra,56(sp)
    80005da2:	f822                	sd	s0,48(sp)
    80005da4:	f426                	sd	s1,40(sp)
    80005da6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	d58080e7          	jalr	-680(ra) # 80001b00 <myproc>
    80005db0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005db2:	fd840593          	addi	a1,s0,-40
    80005db6:	4501                	li	a0,0
    80005db8:	ffffd097          	auipc	ra,0xffffd
    80005dbc:	f4a080e7          	jalr	-182(ra) # 80002d02 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005dc0:	fc840593          	addi	a1,s0,-56
    80005dc4:	fd040513          	addi	a0,s0,-48
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	d18080e7          	jalr	-744(ra) # 80004ae0 <pipealloc>
    return -1;
    80005dd0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005dd2:	0c054763          	bltz	a0,80005ea0 <sys_pipe+0x102>
  fd0 = -1;
    80005dd6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dda:	fd043503          	ld	a0,-48(s0)
    80005dde:	fffff097          	auipc	ra,0xfffff
    80005de2:	4ca080e7          	jalr	1226(ra) # 800052a8 <fdalloc>
    80005de6:	fca42223          	sw	a0,-60(s0)
    80005dea:	08054e63          	bltz	a0,80005e86 <sys_pipe+0xe8>
    80005dee:	fc843503          	ld	a0,-56(s0)
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	4b6080e7          	jalr	1206(ra) # 800052a8 <fdalloc>
    80005dfa:	fca42023          	sw	a0,-64(s0)
    80005dfe:	06054a63          	bltz	a0,80005e72 <sys_pipe+0xd4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e02:	4691                	li	a3,4
    80005e04:	fc440613          	addi	a2,s0,-60
    80005e08:	fd843583          	ld	a1,-40(s0)
    80005e0c:	68a8                	ld	a0,80(s1)
    80005e0e:	ffffc097          	auipc	ra,0xffffc
    80005e12:	90a080e7          	jalr	-1782(ra) # 80001718 <copyout>
    80005e16:	02054063          	bltz	a0,80005e36 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e1a:	4691                	li	a3,4
    80005e1c:	fc040613          	addi	a2,s0,-64
    80005e20:	fd843583          	ld	a1,-40(s0)
    80005e24:	95b6                	add	a1,a1,a3
    80005e26:	68a8                	ld	a0,80(s1)
    80005e28:	ffffc097          	auipc	ra,0xffffc
    80005e2c:	8f0080e7          	jalr	-1808(ra) # 80001718 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e30:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e32:	06055763          	bgez	a0,80005ea0 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005e36:	fc442783          	lw	a5,-60(s0)
    80005e3a:	078e                	slli	a5,a5,0x3
    80005e3c:	0d078793          	addi	a5,a5,208
    80005e40:	97a6                	add	a5,a5,s1
    80005e42:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e46:	fc042783          	lw	a5,-64(s0)
    80005e4a:	078e                	slli	a5,a5,0x3
    80005e4c:	0d078793          	addi	a5,a5,208
    80005e50:	97a6                	add	a5,a5,s1
    80005e52:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e56:	fd043503          	ld	a0,-48(s0)
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	906080e7          	jalr	-1786(ra) # 80004760 <fileclose>
    fileclose(wf);
    80005e62:	fc843503          	ld	a0,-56(s0)
    80005e66:	fffff097          	auipc	ra,0xfffff
    80005e6a:	8fa080e7          	jalr	-1798(ra) # 80004760 <fileclose>
    return -1;
    80005e6e:	57fd                	li	a5,-1
    80005e70:	a805                	j	80005ea0 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005e72:	fc442783          	lw	a5,-60(s0)
    80005e76:	0007c863          	bltz	a5,80005e86 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005e7a:	078e                	slli	a5,a5,0x3
    80005e7c:	0d078793          	addi	a5,a5,208
    80005e80:	97a6                	add	a5,a5,s1
    80005e82:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e86:	fd043503          	ld	a0,-48(s0)
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	8d6080e7          	jalr	-1834(ra) # 80004760 <fileclose>
    fileclose(wf);
    80005e92:	fc843503          	ld	a0,-56(s0)
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	8ca080e7          	jalr	-1846(ra) # 80004760 <fileclose>
    return -1;
    80005e9e:	57fd                	li	a5,-1
}
    80005ea0:	853e                	mv	a0,a5
    80005ea2:	70e2                	ld	ra,56(sp)
    80005ea4:	7442                	ld	s0,48(sp)
    80005ea6:	74a2                	ld	s1,40(sp)
    80005ea8:	6121                	addi	sp,sp,64
    80005eaa:	8082                	ret
    80005eac:	0000                	unimp
	...

0000000080005eb0 <kernelvec>:
    80005eb0:	7111                	addi	sp,sp,-256
    80005eb2:	e006                	sd	ra,0(sp)
    80005eb4:	e40a                	sd	sp,8(sp)
    80005eb6:	e80e                	sd	gp,16(sp)
    80005eb8:	ec12                	sd	tp,24(sp)
    80005eba:	f016                	sd	t0,32(sp)
    80005ebc:	f41a                	sd	t1,40(sp)
    80005ebe:	f81e                	sd	t2,48(sp)
    80005ec0:	fc22                	sd	s0,56(sp)
    80005ec2:	e0a6                	sd	s1,64(sp)
    80005ec4:	e4aa                	sd	a0,72(sp)
    80005ec6:	e8ae                	sd	a1,80(sp)
    80005ec8:	ecb2                	sd	a2,88(sp)
    80005eca:	f0b6                	sd	a3,96(sp)
    80005ecc:	f4ba                	sd	a4,104(sp)
    80005ece:	f8be                	sd	a5,112(sp)
    80005ed0:	fcc2                	sd	a6,120(sp)
    80005ed2:	e146                	sd	a7,128(sp)
    80005ed4:	e54a                	sd	s2,136(sp)
    80005ed6:	e94e                	sd	s3,144(sp)
    80005ed8:	ed52                	sd	s4,152(sp)
    80005eda:	f156                	sd	s5,160(sp)
    80005edc:	f55a                	sd	s6,168(sp)
    80005ede:	f95e                	sd	s7,176(sp)
    80005ee0:	fd62                	sd	s8,184(sp)
    80005ee2:	e1e6                	sd	s9,192(sp)
    80005ee4:	e5ea                	sd	s10,200(sp)
    80005ee6:	e9ee                	sd	s11,208(sp)
    80005ee8:	edf2                	sd	t3,216(sp)
    80005eea:	f1f6                	sd	t4,224(sp)
    80005eec:	f5fa                	sd	t5,232(sp)
    80005eee:	f9fe                	sd	t6,240(sp)
    80005ef0:	c1ffc0ef          	jal	80002b0e <kerneltrap>
    80005ef4:	6082                	ld	ra,0(sp)
    80005ef6:	6122                	ld	sp,8(sp)
    80005ef8:	61c2                	ld	gp,16(sp)
    80005efa:	7282                	ld	t0,32(sp)
    80005efc:	7322                	ld	t1,40(sp)
    80005efe:	73c2                	ld	t2,48(sp)
    80005f00:	7462                	ld	s0,56(sp)
    80005f02:	6486                	ld	s1,64(sp)
    80005f04:	6526                	ld	a0,72(sp)
    80005f06:	65c6                	ld	a1,80(sp)
    80005f08:	6666                	ld	a2,88(sp)
    80005f0a:	7686                	ld	a3,96(sp)
    80005f0c:	7726                	ld	a4,104(sp)
    80005f0e:	77c6                	ld	a5,112(sp)
    80005f10:	7866                	ld	a6,120(sp)
    80005f12:	688a                	ld	a7,128(sp)
    80005f14:	692a                	ld	s2,136(sp)
    80005f16:	69ca                	ld	s3,144(sp)
    80005f18:	6a6a                	ld	s4,152(sp)
    80005f1a:	7a8a                	ld	s5,160(sp)
    80005f1c:	7b2a                	ld	s6,168(sp)
    80005f1e:	7bca                	ld	s7,176(sp)
    80005f20:	7c6a                	ld	s8,184(sp)
    80005f22:	6c8e                	ld	s9,192(sp)
    80005f24:	6d2e                	ld	s10,200(sp)
    80005f26:	6dce                	ld	s11,208(sp)
    80005f28:	6e6e                	ld	t3,216(sp)
    80005f2a:	7e8e                	ld	t4,224(sp)
    80005f2c:	7f2e                	ld	t5,232(sp)
    80005f2e:	7fce                	ld	t6,240(sp)
    80005f30:	6111                	addi	sp,sp,256
    80005f32:	10200073          	sret
    80005f36:	00000013          	nop
    80005f3a:	00000013          	nop
    80005f3e:	0001                	nop

0000000080005f40 <timervec>:
    80005f40:	34051573          	csrrw	a0,mscratch,a0
    80005f44:	e10c                	sd	a1,0(a0)
    80005f46:	e510                	sd	a2,8(a0)
    80005f48:	e914                	sd	a3,16(a0)
    80005f4a:	6d0c                	ld	a1,24(a0)
    80005f4c:	7110                	ld	a2,32(a0)
    80005f4e:	6194                	ld	a3,0(a1)
    80005f50:	96b2                	add	a3,a3,a2
    80005f52:	e194                	sd	a3,0(a1)
    80005f54:	4589                	li	a1,2
    80005f56:	14459073          	csrw	sip,a1
    80005f5a:	6914                	ld	a3,16(a0)
    80005f5c:	6510                	ld	a2,8(a0)
    80005f5e:	610c                	ld	a1,0(a0)
    80005f60:	34051573          	csrrw	a0,mscratch,a0
    80005f64:	30200073          	mret
    80005f68:	0001                	nop

0000000080005f6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f6a:	1141                	addi	sp,sp,-16
    80005f6c:	e406                	sd	ra,8(sp)
    80005f6e:	e022                	sd	s0,0(sp)
    80005f70:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f72:	0c000737          	lui	a4,0xc000
    80005f76:	4785                	li	a5,1
    80005f78:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f7a:	c35c                	sw	a5,4(a4)
}
    80005f7c:	60a2                	ld	ra,8(sp)
    80005f7e:	6402                	ld	s0,0(sp)
    80005f80:	0141                	addi	sp,sp,16
    80005f82:	8082                	ret

0000000080005f84 <plicinithart>:

void
plicinithart(void)
{
    80005f84:	1141                	addi	sp,sp,-16
    80005f86:	e406                	sd	ra,8(sp)
    80005f88:	e022                	sd	s0,0(sp)
    80005f8a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f8c:	ffffc097          	auipc	ra,0xffffc
    80005f90:	b40080e7          	jalr	-1216(ra) # 80001acc <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f94:	0085171b          	slliw	a4,a0,0x8
    80005f98:	0c0027b7          	lui	a5,0xc002
    80005f9c:	97ba                	add	a5,a5,a4
    80005f9e:	40200713          	li	a4,1026
    80005fa2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fa6:	00d5151b          	slliw	a0,a0,0xd
    80005faa:	0c2017b7          	lui	a5,0xc201
    80005fae:	97aa                	add	a5,a5,a0
    80005fb0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005fb4:	60a2                	ld	ra,8(sp)
    80005fb6:	6402                	ld	s0,0(sp)
    80005fb8:	0141                	addi	sp,sp,16
    80005fba:	8082                	ret

0000000080005fbc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fbc:	1141                	addi	sp,sp,-16
    80005fbe:	e406                	sd	ra,8(sp)
    80005fc0:	e022                	sd	s0,0(sp)
    80005fc2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fc4:	ffffc097          	auipc	ra,0xffffc
    80005fc8:	b08080e7          	jalr	-1272(ra) # 80001acc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fcc:	00d5151b          	slliw	a0,a0,0xd
    80005fd0:	0c2017b7          	lui	a5,0xc201
    80005fd4:	97aa                	add	a5,a5,a0
  return irq;
}
    80005fd6:	43c8                	lw	a0,4(a5)
    80005fd8:	60a2                	ld	ra,8(sp)
    80005fda:	6402                	ld	s0,0(sp)
    80005fdc:	0141                	addi	sp,sp,16
    80005fde:	8082                	ret

0000000080005fe0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fe0:	1101                	addi	sp,sp,-32
    80005fe2:	ec06                	sd	ra,24(sp)
    80005fe4:	e822                	sd	s0,16(sp)
    80005fe6:	e426                	sd	s1,8(sp)
    80005fe8:	1000                	addi	s0,sp,32
    80005fea:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fec:	ffffc097          	auipc	ra,0xffffc
    80005ff0:	ae0080e7          	jalr	-1312(ra) # 80001acc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ff4:	00d5179b          	slliw	a5,a0,0xd
    80005ff8:	0c201737          	lui	a4,0xc201
    80005ffc:	97ba                	add	a5,a5,a4
    80005ffe:	c3c4                	sw	s1,4(a5)
}
    80006000:	60e2                	ld	ra,24(sp)
    80006002:	6442                	ld	s0,16(sp)
    80006004:	64a2                	ld	s1,8(sp)
    80006006:	6105                	addi	sp,sp,32
    80006008:	8082                	ret

000000008000600a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000600a:	1141                	addi	sp,sp,-16
    8000600c:	e406                	sd	ra,8(sp)
    8000600e:	e022                	sd	s0,0(sp)
    80006010:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006012:	479d                	li	a5,7
    80006014:	04a7cc63          	blt	a5,a0,8000606c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006018:	0001c797          	auipc	a5,0x1c
    8000601c:	fe878793          	addi	a5,a5,-24 # 80022000 <disk>
    80006020:	97aa                	add	a5,a5,a0
    80006022:	0187c783          	lbu	a5,24(a5)
    80006026:	ebb9                	bnez	a5,8000607c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006028:	00451693          	slli	a3,a0,0x4
    8000602c:	0001c797          	auipc	a5,0x1c
    80006030:	fd478793          	addi	a5,a5,-44 # 80022000 <disk>
    80006034:	6398                	ld	a4,0(a5)
    80006036:	9736                	add	a4,a4,a3
    80006038:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    8000603c:	6398                	ld	a4,0(a5)
    8000603e:	9736                	add	a4,a4,a3
    80006040:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006044:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006048:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000604c:	97aa                	add	a5,a5,a0
    8000604e:	4705                	li	a4,1
    80006050:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006054:	0001c517          	auipc	a0,0x1c
    80006058:	fc450513          	addi	a0,a0,-60 # 80022018 <disk+0x18>
    8000605c:	ffffc097          	auipc	ra,0xffffc
    80006060:	22e080e7          	jalr	558(ra) # 8000228a <wakeup>
}
    80006064:	60a2                	ld	ra,8(sp)
    80006066:	6402                	ld	s0,0(sp)
    80006068:	0141                	addi	sp,sp,16
    8000606a:	8082                	ret
    panic("free_desc 1");
    8000606c:	00002517          	auipc	a0,0x2
    80006070:	5bc50513          	addi	a0,a0,1468 # 80008628 <etext+0x628>
    80006074:	ffffa097          	auipc	ra,0xffffa
    80006078:	4ea080e7          	jalr	1258(ra) # 8000055e <panic>
    panic("free_desc 2");
    8000607c:	00002517          	auipc	a0,0x2
    80006080:	5bc50513          	addi	a0,a0,1468 # 80008638 <etext+0x638>
    80006084:	ffffa097          	auipc	ra,0xffffa
    80006088:	4da080e7          	jalr	1242(ra) # 8000055e <panic>

000000008000608c <virtio_disk_init>:
{
    8000608c:	1101                	addi	sp,sp,-32
    8000608e:	ec06                	sd	ra,24(sp)
    80006090:	e822                	sd	s0,16(sp)
    80006092:	e426                	sd	s1,8(sp)
    80006094:	e04a                	sd	s2,0(sp)
    80006096:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006098:	00002597          	auipc	a1,0x2
    8000609c:	5b058593          	addi	a1,a1,1456 # 80008648 <etext+0x648>
    800060a0:	0001c517          	auipc	a0,0x1c
    800060a4:	08850513          	addi	a0,a0,136 # 80022128 <disk+0x128>
    800060a8:	ffffb097          	auipc	ra,0xffffb
    800060ac:	b1a080e7          	jalr	-1254(ra) # 80000bc2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060b0:	100017b7          	lui	a5,0x10001
    800060b4:	4398                	lw	a4,0(a5)
    800060b6:	2701                	sext.w	a4,a4
    800060b8:	747277b7          	lui	a5,0x74727
    800060bc:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060c0:	16f71463          	bne	a4,a5,80006228 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060c4:	100017b7          	lui	a5,0x10001
    800060c8:	43dc                	lw	a5,4(a5)
    800060ca:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060cc:	4709                	li	a4,2
    800060ce:	14e79d63          	bne	a5,a4,80006228 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060d2:	100017b7          	lui	a5,0x10001
    800060d6:	479c                	lw	a5,8(a5)
    800060d8:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060da:	14e79763          	bne	a5,a4,80006228 <virtio_disk_init+0x19c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060de:	100017b7          	lui	a5,0x10001
    800060e2:	47d8                	lw	a4,12(a5)
    800060e4:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060e6:	554d47b7          	lui	a5,0x554d4
    800060ea:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060ee:	12f71d63          	bne	a4,a5,80006228 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060f2:	100017b7          	lui	a5,0x10001
    800060f6:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060fa:	4705                	li	a4,1
    800060fc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060fe:	470d                	li	a4,3
    80006100:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006102:	10001737          	lui	a4,0x10001
    80006106:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006108:	c7ffe6b7          	lui	a3,0xc7ffe
    8000610c:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc61f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006110:	8f75                	and	a4,a4,a3
    80006112:	100016b7          	lui	a3,0x10001
    80006116:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006118:	472d                	li	a4,11
    8000611a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000611c:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006120:	439c                	lw	a5,0(a5)
    80006122:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006126:	8ba1                	andi	a5,a5,8
    80006128:	10078863          	beqz	a5,80006238 <virtio_disk_init+0x1ac>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000612c:	100017b7          	lui	a5,0x10001
    80006130:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006134:	43fc                	lw	a5,68(a5)
    80006136:	2781                	sext.w	a5,a5
    80006138:	10079863          	bnez	a5,80006248 <virtio_disk_init+0x1bc>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000613c:	100017b7          	lui	a5,0x10001
    80006140:	5bdc                	lw	a5,52(a5)
    80006142:	2781                	sext.w	a5,a5
  if(max == 0)
    80006144:	10078a63          	beqz	a5,80006258 <virtio_disk_init+0x1cc>
  if(max < NUM)
    80006148:	471d                	li	a4,7
    8000614a:	10f77f63          	bgeu	a4,a5,80006268 <virtio_disk_init+0x1dc>
  disk.desc = kalloc();
    8000614e:	ffffb097          	auipc	ra,0xffffb
    80006152:	a0a080e7          	jalr	-1526(ra) # 80000b58 <kalloc>
    80006156:	0001c497          	auipc	s1,0x1c
    8000615a:	eaa48493          	addi	s1,s1,-342 # 80022000 <disk>
    8000615e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	9f8080e7          	jalr	-1544(ra) # 80000b58 <kalloc>
    80006168:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000616a:	ffffb097          	auipc	ra,0xffffb
    8000616e:	9ee080e7          	jalr	-1554(ra) # 80000b58 <kalloc>
    80006172:	87aa                	mv	a5,a0
    80006174:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006176:	6088                	ld	a0,0(s1)
    80006178:	10050063          	beqz	a0,80006278 <virtio_disk_init+0x1ec>
    8000617c:	0001c717          	auipc	a4,0x1c
    80006180:	e8c73703          	ld	a4,-372(a4) # 80022008 <disk+0x8>
    80006184:	cb75                	beqz	a4,80006278 <virtio_disk_init+0x1ec>
    80006186:	cbed                	beqz	a5,80006278 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80006188:	6605                	lui	a2,0x1
    8000618a:	4581                	li	a1,0
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	bc8080e7          	jalr	-1080(ra) # 80000d54 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006194:	0001c497          	auipc	s1,0x1c
    80006198:	e6c48493          	addi	s1,s1,-404 # 80022000 <disk>
    8000619c:	6605                	lui	a2,0x1
    8000619e:	4581                	li	a1,0
    800061a0:	6488                	ld	a0,8(s1)
    800061a2:	ffffb097          	auipc	ra,0xffffb
    800061a6:	bb2080e7          	jalr	-1102(ra) # 80000d54 <memset>
  memset(disk.used, 0, PGSIZE);
    800061aa:	6605                	lui	a2,0x1
    800061ac:	4581                	li	a1,0
    800061ae:	6888                	ld	a0,16(s1)
    800061b0:	ffffb097          	auipc	ra,0xffffb
    800061b4:	ba4080e7          	jalr	-1116(ra) # 80000d54 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061b8:	100017b7          	lui	a5,0x10001
    800061bc:	4721                	li	a4,8
    800061be:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061c0:	4098                	lw	a4,0(s1)
    800061c2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061c6:	40d8                	lw	a4,4(s1)
    800061c8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800061cc:	649c                	ld	a5,8(s1)
    800061ce:	0007869b          	sext.w	a3,a5
    800061d2:	10001737          	lui	a4,0x10001
    800061d6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061da:	9781                	srai	a5,a5,0x20
    800061dc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800061e0:	689c                	ld	a5,16(s1)
    800061e2:	0007869b          	sext.w	a3,a5
    800061e6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061ea:	9781                	srai	a5,a5,0x20
    800061ec:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061f0:	4785                	li	a5,1
    800061f2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800061f4:	00f48c23          	sb	a5,24(s1)
    800061f8:	00f48ca3          	sb	a5,25(s1)
    800061fc:	00f48d23          	sb	a5,26(s1)
    80006200:	00f48da3          	sb	a5,27(s1)
    80006204:	00f48e23          	sb	a5,28(s1)
    80006208:	00f48ea3          	sb	a5,29(s1)
    8000620c:	00f48f23          	sb	a5,30(s1)
    80006210:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006214:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006218:	07272823          	sw	s2,112(a4)
}
    8000621c:	60e2                	ld	ra,24(sp)
    8000621e:	6442                	ld	s0,16(sp)
    80006220:	64a2                	ld	s1,8(sp)
    80006222:	6902                	ld	s2,0(sp)
    80006224:	6105                	addi	sp,sp,32
    80006226:	8082                	ret
    panic("could not find virtio disk");
    80006228:	00002517          	auipc	a0,0x2
    8000622c:	43050513          	addi	a0,a0,1072 # 80008658 <etext+0x658>
    80006230:	ffffa097          	auipc	ra,0xffffa
    80006234:	32e080e7          	jalr	814(ra) # 8000055e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006238:	00002517          	auipc	a0,0x2
    8000623c:	44050513          	addi	a0,a0,1088 # 80008678 <etext+0x678>
    80006240:	ffffa097          	auipc	ra,0xffffa
    80006244:	31e080e7          	jalr	798(ra) # 8000055e <panic>
    panic("virtio disk should not be ready");
    80006248:	00002517          	auipc	a0,0x2
    8000624c:	45050513          	addi	a0,a0,1104 # 80008698 <etext+0x698>
    80006250:	ffffa097          	auipc	ra,0xffffa
    80006254:	30e080e7          	jalr	782(ra) # 8000055e <panic>
    panic("virtio disk has no queue 0");
    80006258:	00002517          	auipc	a0,0x2
    8000625c:	46050513          	addi	a0,a0,1120 # 800086b8 <etext+0x6b8>
    80006260:	ffffa097          	auipc	ra,0xffffa
    80006264:	2fe080e7          	jalr	766(ra) # 8000055e <panic>
    panic("virtio disk max queue too short");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	47050513          	addi	a0,a0,1136 # 800086d8 <etext+0x6d8>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2ee080e7          	jalr	750(ra) # 8000055e <panic>
    panic("virtio disk kalloc");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	48050513          	addi	a0,a0,1152 # 800086f8 <etext+0x6f8>
    80006280:	ffffa097          	auipc	ra,0xffffa
    80006284:	2de080e7          	jalr	734(ra) # 8000055e <panic>

0000000080006288 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006288:	711d                	addi	sp,sp,-96
    8000628a:	ec86                	sd	ra,88(sp)
    8000628c:	e8a2                	sd	s0,80(sp)
    8000628e:	e4a6                	sd	s1,72(sp)
    80006290:	e0ca                	sd	s2,64(sp)
    80006292:	fc4e                	sd	s3,56(sp)
    80006294:	f852                	sd	s4,48(sp)
    80006296:	f456                	sd	s5,40(sp)
    80006298:	f05a                	sd	s6,32(sp)
    8000629a:	ec5e                	sd	s7,24(sp)
    8000629c:	e862                	sd	s8,16(sp)
    8000629e:	1080                	addi	s0,sp,96
    800062a0:	89aa                	mv	s3,a0
    800062a2:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062a4:	00c52b83          	lw	s7,12(a0)
    800062a8:	001b9b9b          	slliw	s7,s7,0x1
    800062ac:	1b82                	slli	s7,s7,0x20
    800062ae:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800062b2:	0001c517          	auipc	a0,0x1c
    800062b6:	e7650513          	addi	a0,a0,-394 # 80022128 <disk+0x128>
    800062ba:	ffffb097          	auipc	ra,0xffffb
    800062be:	9a2080e7          	jalr	-1630(ra) # 80000c5c <acquire>
  for(int i = 0; i < NUM; i++){
    800062c2:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062c4:	0001ca97          	auipc	s5,0x1c
    800062c8:	d3ca8a93          	addi	s5,s5,-708 # 80022000 <disk>
  for(int i = 0; i < 3; i++){
    800062cc:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800062ce:	5c7d                	li	s8,-1
    800062d0:	a885                	j	80006340 <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800062d2:	00fa8733          	add	a4,s5,a5
    800062d6:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062da:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062dc:	0207c563          	bltz	a5,80006306 <virtio_disk_rw+0x7e>
  for(int i = 0; i < 3; i++){
    800062e0:	2905                	addiw	s2,s2,1
    800062e2:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800062e4:	07490263          	beq	s2,s4,80006348 <virtio_disk_rw+0xc0>
    idx[i] = alloc_desc();
    800062e8:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800062ea:	0001c717          	auipc	a4,0x1c
    800062ee:	d1670713          	addi	a4,a4,-746 # 80022000 <disk>
    800062f2:	4781                	li	a5,0
    if(disk.free[i]){
    800062f4:	01874683          	lbu	a3,24(a4)
    800062f8:	fee9                	bnez	a3,800062d2 <virtio_disk_rw+0x4a>
  for(int i = 0; i < NUM; i++){
    800062fa:	2785                	addiw	a5,a5,1
    800062fc:	0705                	addi	a4,a4,1
    800062fe:	fe979be3          	bne	a5,s1,800062f4 <virtio_disk_rw+0x6c>
    idx[i] = alloc_desc();
    80006302:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80006306:	03205163          	blez	s2,80006328 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    8000630a:	fa042503          	lw	a0,-96(s0)
    8000630e:	00000097          	auipc	ra,0x0
    80006312:	cfc080e7          	jalr	-772(ra) # 8000600a <free_desc>
      for(int j = 0; j < i; j++)
    80006316:	4785                	li	a5,1
    80006318:	0127d863          	bge	a5,s2,80006328 <virtio_disk_rw+0xa0>
        free_desc(idx[j]);
    8000631c:	fa442503          	lw	a0,-92(s0)
    80006320:	00000097          	auipc	ra,0x0
    80006324:	cea080e7          	jalr	-790(ra) # 8000600a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006328:	0001c597          	auipc	a1,0x1c
    8000632c:	e0058593          	addi	a1,a1,-512 # 80022128 <disk+0x128>
    80006330:	0001c517          	auipc	a0,0x1c
    80006334:	ce850513          	addi	a0,a0,-792 # 80022018 <disk+0x18>
    80006338:	ffffc097          	auipc	ra,0xffffc
    8000633c:	eee080e7          	jalr	-274(ra) # 80002226 <sleep>
  for(int i = 0; i < 3; i++){
    80006340:	fa040613          	addi	a2,s0,-96
    80006344:	4901                	li	s2,0
    80006346:	b74d                	j	800062e8 <virtio_disk_rw+0x60>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006348:	fa042503          	lw	a0,-96(s0)
    8000634c:	00451693          	slli	a3,a0,0x4

  if(write)
    80006350:	0001c797          	auipc	a5,0x1c
    80006354:	cb078793          	addi	a5,a5,-848 # 80022000 <disk>
    80006358:	00451713          	slli	a4,a0,0x4
    8000635c:	0a070713          	addi	a4,a4,160
    80006360:	973e                	add	a4,a4,a5
    80006362:	01603633          	snez	a2,s6
    80006366:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006368:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000636c:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006370:	6398                	ld	a4,0(a5)
    80006372:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006374:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006378:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000637a:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000637c:	6390                	ld	a2,0(a5)
    8000637e:	00d60833          	add	a6,a2,a3
    80006382:	4741                	li	a4,16
    80006384:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006388:	4585                	li	a1,1
    8000638a:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    8000638e:	fa442703          	lw	a4,-92(s0)
    80006392:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006396:	0712                	slli	a4,a4,0x4
    80006398:	963a                	add	a2,a2,a4
    8000639a:	05898813          	addi	a6,s3,88
    8000639e:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800063a2:	0007b883          	ld	a7,0(a5)
    800063a6:	9746                	add	a4,a4,a7
    800063a8:	40000613          	li	a2,1024
    800063ac:	c710                	sw	a2,8(a4)
  if(write)
    800063ae:	001b3613          	seqz	a2,s6
    800063b2:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063b6:	8e4d                	or	a2,a2,a1
    800063b8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063bc:	fa842603          	lw	a2,-88(s0)
    800063c0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800063c4:	00451813          	slli	a6,a0,0x4
    800063c8:	02080813          	addi	a6,a6,32
    800063cc:	983e                	add	a6,a6,a5
    800063ce:	577d                	li	a4,-1
    800063d0:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063d4:	0612                	slli	a2,a2,0x4
    800063d6:	98b2                	add	a7,a7,a2
    800063d8:	03068713          	addi	a4,a3,48
    800063dc:	973e                	add	a4,a4,a5
    800063de:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800063e2:	6398                	ld	a4,0(a5)
    800063e4:	9732                	add	a4,a4,a2
    800063e6:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063e8:	4689                	li	a3,2
    800063ea:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800063ee:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063f2:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800063f6:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063fa:	6794                	ld	a3,8(a5)
    800063fc:	0026d703          	lhu	a4,2(a3)
    80006400:	8b1d                	andi	a4,a4,7
    80006402:	0706                	slli	a4,a4,0x1
    80006404:	96ba                	add	a3,a3,a4
    80006406:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000640a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000640e:	6798                	ld	a4,8(a5)
    80006410:	00275783          	lhu	a5,2(a4)
    80006414:	2785                	addiw	a5,a5,1
    80006416:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000641a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000641e:	100017b7          	lui	a5,0x10001
    80006422:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006426:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000642a:	0001c917          	auipc	s2,0x1c
    8000642e:	cfe90913          	addi	s2,s2,-770 # 80022128 <disk+0x128>
  while(b->disk == 1) {
    80006432:	84ae                	mv	s1,a1
    80006434:	00b79c63          	bne	a5,a1,8000644c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006438:	85ca                	mv	a1,s2
    8000643a:	854e                	mv	a0,s3
    8000643c:	ffffc097          	auipc	ra,0xffffc
    80006440:	dea080e7          	jalr	-534(ra) # 80002226 <sleep>
  while(b->disk == 1) {
    80006444:	0049a783          	lw	a5,4(s3)
    80006448:	fe9788e3          	beq	a5,s1,80006438 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000644c:	fa042903          	lw	s2,-96(s0)
    80006450:	00491713          	slli	a4,s2,0x4
    80006454:	02070713          	addi	a4,a4,32
    80006458:	0001c797          	auipc	a5,0x1c
    8000645c:	ba878793          	addi	a5,a5,-1112 # 80022000 <disk>
    80006460:	97ba                	add	a5,a5,a4
    80006462:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006466:	0001c997          	auipc	s3,0x1c
    8000646a:	b9a98993          	addi	s3,s3,-1126 # 80022000 <disk>
    8000646e:	00491713          	slli	a4,s2,0x4
    80006472:	0009b783          	ld	a5,0(s3)
    80006476:	97ba                	add	a5,a5,a4
    80006478:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000647c:	854a                	mv	a0,s2
    8000647e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006482:	00000097          	auipc	ra,0x0
    80006486:	b88080e7          	jalr	-1144(ra) # 8000600a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000648a:	8885                	andi	s1,s1,1
    8000648c:	f0ed                	bnez	s1,8000646e <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000648e:	0001c517          	auipc	a0,0x1c
    80006492:	c9a50513          	addi	a0,a0,-870 # 80022128 <disk+0x128>
    80006496:	ffffb097          	auipc	ra,0xffffb
    8000649a:	876080e7          	jalr	-1930(ra) # 80000d0c <release>
}
    8000649e:	60e6                	ld	ra,88(sp)
    800064a0:	6446                	ld	s0,80(sp)
    800064a2:	64a6                	ld	s1,72(sp)
    800064a4:	6906                	ld	s2,64(sp)
    800064a6:	79e2                	ld	s3,56(sp)
    800064a8:	7a42                	ld	s4,48(sp)
    800064aa:	7aa2                	ld	s5,40(sp)
    800064ac:	7b02                	ld	s6,32(sp)
    800064ae:	6be2                	ld	s7,24(sp)
    800064b0:	6c42                	ld	s8,16(sp)
    800064b2:	6125                	addi	sp,sp,96
    800064b4:	8082                	ret

00000000800064b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800064b6:	1101                	addi	sp,sp,-32
    800064b8:	ec06                	sd	ra,24(sp)
    800064ba:	e822                	sd	s0,16(sp)
    800064bc:	e426                	sd	s1,8(sp)
    800064be:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064c0:	0001c497          	auipc	s1,0x1c
    800064c4:	b4048493          	addi	s1,s1,-1216 # 80022000 <disk>
    800064c8:	0001c517          	auipc	a0,0x1c
    800064cc:	c6050513          	addi	a0,a0,-928 # 80022128 <disk+0x128>
    800064d0:	ffffa097          	auipc	ra,0xffffa
    800064d4:	78c080e7          	jalr	1932(ra) # 80000c5c <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064d8:	100017b7          	lui	a5,0x10001
    800064dc:	53bc                	lw	a5,96(a5)
    800064de:	8b8d                	andi	a5,a5,3
    800064e0:	10001737          	lui	a4,0x10001
    800064e4:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800064e6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800064ea:	689c                	ld	a5,16(s1)
    800064ec:	0204d703          	lhu	a4,32(s1)
    800064f0:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800064f4:	04f70a63          	beq	a4,a5,80006548 <virtio_disk_intr+0x92>
    __sync_synchronize();
    800064f8:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800064fc:	6898                	ld	a4,16(s1)
    800064fe:	0204d783          	lhu	a5,32(s1)
    80006502:	8b9d                	andi	a5,a5,7
    80006504:	078e                	slli	a5,a5,0x3
    80006506:	97ba                	add	a5,a5,a4
    80006508:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000650a:	00479713          	slli	a4,a5,0x4
    8000650e:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80006512:	9726                	add	a4,a4,s1
    80006514:	01074703          	lbu	a4,16(a4)
    80006518:	e729                	bnez	a4,80006562 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000651a:	0792                	slli	a5,a5,0x4
    8000651c:	02078793          	addi	a5,a5,32
    80006520:	97a6                	add	a5,a5,s1
    80006522:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006524:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006528:	ffffc097          	auipc	ra,0xffffc
    8000652c:	d62080e7          	jalr	-670(ra) # 8000228a <wakeup>

    disk.used_idx += 1;
    80006530:	0204d783          	lhu	a5,32(s1)
    80006534:	2785                	addiw	a5,a5,1
    80006536:	17c2                	slli	a5,a5,0x30
    80006538:	93c1                	srli	a5,a5,0x30
    8000653a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000653e:	6898                	ld	a4,16(s1)
    80006540:	00275703          	lhu	a4,2(a4)
    80006544:	faf71ae3          	bne	a4,a5,800064f8 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006548:	0001c517          	auipc	a0,0x1c
    8000654c:	be050513          	addi	a0,a0,-1056 # 80022128 <disk+0x128>
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	7bc080e7          	jalr	1980(ra) # 80000d0c <release>
}
    80006558:	60e2                	ld	ra,24(sp)
    8000655a:	6442                	ld	s0,16(sp)
    8000655c:	64a2                	ld	s1,8(sp)
    8000655e:	6105                	addi	sp,sp,32
    80006560:	8082                	ret
      panic("virtio_disk_intr status");
    80006562:	00002517          	auipc	a0,0x2
    80006566:	1ae50513          	addi	a0,a0,430 # 80008710 <etext+0x710>
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	ff4080e7          	jalr	-12(ra) # 8000055e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
