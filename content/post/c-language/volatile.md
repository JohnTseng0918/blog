---
title: "C 語言 volatile"
date: 2026-07-28
draft: false
description: "volatile 是什麼、為什麼需要它、常見使用場景,以及它不能做什麼"
tags: ["c", "volatile"]
categories: ["程式語言"]
---

## 是什麼

- `volatile` 是一個 **type qualifier**,和 `const`、`restrict` 都是 type qualifier

```c
volatile int flag;
volatile uint32_t *reg = (volatile uint32_t *)0x10000000;
```

下面對照 **C99 [6.7.3]** 的三段規範。

**① 對 volatile 物件的存取,不能被 optimize 掉或重排**

> An object that has volatile-qualified type may be modified in ways unknown to the implementation or have other unknown side effects. Therefore any expression referring to such an object shall be evaluated strictly according to the rules of the abstract machine.

它告訴 compiler:**這個變數的值可能在程式的 control flow 之外被改變**,所以每次存取都要老實照做。

**② 典型用途是 MMIO 與非同步中斷**

> A volatile declaration may be used to describe an object corresponding to a memory-mapped input/output port or an object accessed by an asynchronously interrupting function. Actions on objects so declared shall not be "optimized out" by an implementation or reordered except as permitted by the rules for evaluating expressions.

這個 volatile 變數可能是透過 MMIO 讀取,或被非同步的 interrupt function 存取的物件,所以 compiler 不能把對它的存取 optimize 掉,或任意重排(除非符合運算式求值的規則)。

**③ 用非 volatile 的 lvalue 存取 volatile 物件是 UB**

> If an attempt is made to refer to an object defined with a volatile-qualified type through use of an lvalue with non-volatile-qualified type, the behavior is undefined.

透過指標轉型(casting)等方式強制拔除該物件的 volatile 屬性,再用「不具備 volatile 屬性的左值」去存取該記憶體位置,就是 undefined behavior。

```c
volatile int v = 10;        // v 本身在定義時是 volatile 限定型別

// 錯誤示範：將 volatile 變數的位址，強制轉型為一般 (非 volatile) 的指標
int *ptr = (int *)&v;

// 未定義行為：透過「非 volatile 限定的左值」(*ptr) 去讀取它
int val = *ptr;

// 未定義行為：透過「非 volatile 限定的左值」(*ptr) 去修改它
*ptr = 20;
```
- 原因在於 compiler optimization
  - compiler 沒看到 volatile 就會大膽做 optimize,但這塊記憶體本質上是 volatile,所以 compiler 被騙去做 optimize,最終的程式碼就可能產生不預期的錯誤

## 為什麼需要它

compiler 為了效能,會假設「沒有人動過的變數,值不會變」,於是做各種 optimize。例如:

```c
int flag = 0;

void wait(void) {
    while (flag == 0) {
        // 什麼都不做,等別人把 flag 設成 1
    }
}
```

compiler 看到迴圈內沒有改到 `flag`,可能把它 optimize 成:

```c
void wait(void) {
    if (flag == 0) {
        while (1) { }   // 直接變成無窮迴圈!
    }
}
```

因為它把 `flag` 讀進暫存器後就不再重新載入了。如果 `flag` 是被 **中斷處理函式** 或 **另一條執行緒** 改的,這段程式就永遠卡住。

把它宣告成 `volatile int flag;` 後,compiler 每次跑到 `flag == 0` 都會 **重新從記憶體讀取**,問題就解決了。

## 常見使用場景

1. **Memory-mapped I/O(MMIO)**
   - 硬體暫存器被映射到某個記憶體位址,讀寫它其實是在跟裝置溝通
   - 讀取同一個位址可能每次都拿到不同值(例如狀態暫存器)
   ```c
   #define UART_STATUS (*(volatile uint8_t *)0x10000005)
   while ((UART_STATUS & TX_READY) == 0)
       ;   // 忙碌等待,直到硬體就緒
   ```

2. **中斷處理函式(ISR)共用的變數**
   - 主程式和 ISR 之間共享的旗標,要標成 `volatile`

3. **signal handler 修改的變數**
   - 標準建議搭配 `volatile sig_atomic_t`

## volatile 不能做什麼

這是最容易誤會的地方 —— `volatile` **不是** 同步或原子(atomic)工具:

- ❌ **不保證原子性**:`volatile int x; x++;` 仍然是「讀-改-寫」三個步驟,多執行緒下會有 race condition
- ❌ **不是 memory barrier**:它只限制對「該變數本身」的 optimize,不會限制其他記憶體操作的重排序
- ❌ **不能取代 mutex / atomic**:多執行緒同步請用 `<stdatomic.h>` 或鎖

> 口訣:`volatile` 解決的是「**compiler optimize 掉存取**」的問題,不是「**多執行緒正確性**」的問題。

## volatile 與 const 可以並存

兩者不衝突,可以同時出現:

```c
const volatile uint32_t *status_reg;
```

意思是:**我的程式不會去寫它**(`const`),但**它的值可能被硬體改變**(`volatile`)—— 典型的唯讀硬體狀態暫存器。