---
title: "Trace xv6"
date: 2026-06-30
draft: true
description: "MIT 6.S081 / trace xv6-riscv source code 的隨意筆記"
tags: ["xv6", "riscv", "kernel"]
categories: ["作業系統"]
---

## Trace Note

### Homework 1 due: file descriptors

#### cat.c

這個作業要 trace cat 的實作方式,並且要 track argv[i] 是如何 pass 給 open(),
以及 file descriptor 的 result 是什麼、file descriptor 這個 integer 是指向什麼?

首先 cat.c 是個 user program,很輕鬆就可以看到 main 入口

一開始先有一個判斷,如果 argc <= 1,代表只有 argv[0](按照慣例是執行檔的名稱)、沒有輸入任何檔名
所以就呼叫了 cat(0),參數是 file descriptor,0 也就是 standard input

```
void cat(int fd){
  int n;

  while ((n = read(fd, buf, sizeof(buf))) > 0) {
    if (write(1, buf, n) != n) {
      fprintf(2, "cat: write error\n");
      exit(1);
    }
  }
  if (n < 0) {
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
```

實作可以清楚看到用一個 while 去做 read,並且把 read 到的 byte 數 assign 給 n
如果 n > 0,代表有讀到 data,接下來就會進入裡面執行 write

回到 main function,如果 argc > 1
就會去 open argv[i],然後將 file descriptor 傳入 cat

#### system call flow

有一個很有趣的問題,是 user program 呼叫 system call open(),但是 kernel code 只有找到 sys_open,中間是發生什麼事情?

首先,open 不是一個真正的 function,它是由 usys.pl 產生的一段 assembly

```
.global open
open:
    li a7, SYS_open   # 把系統呼叫編號 15 放進 a7 暫存器
    ecall             # 觸發 trap 進入 kernel
    ret               # 回到 cat,回傳值已經在 a0
```

參數的傳遞方式: 就是依照 RISC-V calling convention,進到 open 的時候 path 在 a0,mode 在 a1
a7 是系統呼叫編號,kernel 會依據此數值來查表

ecall 完會跳轉到 stvec 暫存器的 address,也就是 uservec,這邊的 value 是上次從 kernel 切換到 user 的時候設定的

進入 uservec,也就是 assembly,會把暫存器(除了 x0/zero 共 31 個)都存進 trapframe,最後呼叫 C function usertrap

usertrap 裡頭會判斷是不是 system call,然後就跳進去 syscall()

syscalls 是個 function pointer array,最後進入 sys_open