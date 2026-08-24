---
title: "C struct 的 padding 與 packing"
date: 2026-08-24
draft: false
description: "self-alignment、padding 從哪來、stride address、bitfield 的坑,以及重排成員來縮小 struct 的技巧與代價"
tags: ["c", "alignment", "struct", "memory"]
categories: ["程式語言"]
---

整理自 [The Lost Art of Structure Packing](http://www.catb.org/esr/structure-packing/)。規格層面的定義另外整理在 [alignment]({{< ref "/post/c-language/alignment.md" >}})。

## self-alignment

在 Intel、ARM、RISC-V 這類主流 ISA 上,基本型別都是 **self-aligned**:**型別大小是幾 byte,起始位址就必須是幾的倍數**。

| 型別 | 大小 | 起始位址須是 |
|---|---|---|
| `char` | 1 | 任意位址 |
| `short` | 2 | 2 的倍數 |
| `int` / `float` | 4 | 4 的倍數 |
| `long` / `double` / 指標(64-bit) | 8 | 8 的倍數 |

- 有號/無號不影響對齊
- 對齊讓存取可以用**單一指令**完成;沒對齊的話可能要跨 machine word 邊界做兩次以上的存取再拼起來
- `char` 是特例:在一個 machine word 內不管放哪裡成本都一樣,所以沒有偏好的對齊

補充幾個歷史/例外:

- 舊機器(如 Sun SPARC)上違反對齊不只是變慢,而是直接 illegal instruction fault;x86 也可以透過設定處理器 flag(`EFLAGS.AC`)把它變成 fault
- self-alignment 不是唯一可能的規則,某些嵌入式處理器有更嚴格的規則
- Motorola 68020 是反例:它是 16-bit granularity 的機器,struct 可以從 16-bit 邊界開始而沒有速度懲罰,所以只有奇數長度的 char 欄位會造成 padding

## padding 從哪來

**slop 只會出現在兩個地方**:

1. 對齊需求**大**的成員,接在對齊需求**小**的成員後面
2. struct 自然結束的位置**還沒到 stride address**,要補到那裡

先看第一種:

```c
char *p;      /* 8 bytes */
char c;       /* 1 byte  */
char pad[3];  /* 3 bytes ← 編譯器插入的 */
int x;        /* 4 bytes */
```

- `x` 需要 4-byte 對齊,`c` 之後的位址不是 4 的倍數,所以中間長出 3 bytes 的洞
- 這種洞的舊稱是 **slop**
- **padding 的內容是 undefined,不保證是 0** —— 所以 `memcmp` 兩個 struct 來判斷相等是錯的

換成 `short x` 只要補 1 byte,換成 `long x` 要補 7 bytes;把小的排後面則完全不用補。

> 純量陣列(`char[]`、`int[]` …)在 self-alignment 平台上**沒有內部 padding**,因為前一個元素結束的位置正好就是下一個元素的合法起點。struct 陣列則不然,見下面的 stride address。

## struct 的對齊與 stride address

兩條基本規則:

- struct 的對齊 = **所有成員中最寬者的對齊**(這是讓每個成員都自動 self-aligned 最簡單的做法)
- struct 的位址 = **第一個成員的位址**,前面不會有 padding(C++ 不一定,有 vtable 等因素)

要查證實際 offset,用 `<stddef.h>` 的 `offsetof()`。

**成員順序會鎖死 padding 大小**

```c
struct foo2 {
    char c;      /* 1 byte  */
    char pad[7]; /* 7 bytes */
    char *p;     /* 8 bytes */
    long x;      /* 8 bytes */
};
```

如果 `c`、`p`、`x` 是三個獨立變數,`c` 可以落在 word 內任意位置,padding 是 0 到 7 都有可能。但一旦包進 struct,整個 struct 是 pointer-aligned,`c` 只能從 8 的倍數開始,後面那 7 bytes 就**鎖死了**。

**stride address 與尾端 padding**

**stride address** = struct 資料結束之後,第一個與 struct 自身對齊相同的位址。

> 規則:編譯器會**把 struct 補到 stride address**,這決定了 `sizeof` 的結果。

```c
struct foo3 {
    char *p;     /* 8 bytes */
    char c;      /* 1 byte  */
    char pad[7]; /* 7 bytes ← 補到 stride address */
};               /* sizeof == 16, 不是 9 */
```

- 理由很直接:`struct foo3 quad[4];` 裡每個元素的 `p` 都必須 8-byte 對齊
- 對照組:`struct foo4 { short s; char c; };` 只需要 2-byte 對齊,尾端補 1 byte,`sizeof == 4`

**巢狀 struct**

內層 struct 一樣要有它自己最寬成員的對齊,並且把這個對齊需求**往外傳染**:

```c
struct foo5 {
    char c;           /* 1 byte  */
    char pad1[7];     /* 7 bytes */
    struct foo5_inner {
        char *p;      /* 8 bytes */
        short x;      /* 2 bytes */
        char pad2[6]; /* 6 bytes */
    } inner;
};                    /* sizeof == 24,其中 13 bytes 是 padding */
```

24 bytes 裡有 13 bytes 是浪費 —— 超過一半。

## bitfield

bitfield 讓你宣告小於一個 char 寬度的欄位,最小到 1 bit:

```c
struct foo6 {
    short s;
    char  c;
    int   flip:1;
    int   nybble:4;
    int   septet:7;
};
```

它是用 machine word 上的 mask / shift 指令實作的。C99 [6.7.2.1] p10 保證**相鄰的 bitfield 在空間夠時會被緊密打包進同一個 storage unit**,但除此之外幾乎什麼都不保證:

| 項目 | 規格態度 |
|---|---|
| 用多大的 storage unit 裝 | 實作自己挑 |
| 塞不下時放下一個 unit 還是跨 unit | implementation-defined |
| unit 內從高位排到低位還是相反 | implementation-defined |
| storage unit 本身的對齊 | **unspecified** |
| padding bit 的值 | 不保證為 0 |

所以同一個 `struct foo6`,padding 可能補在 payload 之後,也可能補在之前 —— 兩種佈局都合法。

實務上還要注意:

- bitfield 的 base type 決定的是**有號性**,不一定決定 storage unit 大小;`short flip:1` / `long flip:1` 支不支援、會不會改變 unit 大小,都由實作決定
- GCC 把這件事交給 ABI 決定,x86-64 ABI 不允許 bitfield 共用跨越的 allocation unit
- **不要拿 bitfield 直接對映硬體暫存器或網路封包格式**,要精確控制位元位置就用 `uint32_t` + shift/mask
- clang 的 `-Wpadded` 可以幫忙檢查

> 原文說「bitfield 不能跨 machine word 邊界」,這個講法比規格嚴格。C99 的原文是「塞不下時放下一個 unit 還是跨越相鄰 unit 是 implementation-defined」,並沒有禁止跨越;C11 [6.7.2.1] p11 與 C++14 又進一步放寬。實務上仍以「不要指望它跨得過去」為準。

## 重排成員(packing)

**最簡單的做法:依對齊需求由大到小排列。**

指標 → `long` / `double` → `int` → `short` → `char`。

```c
struct foo10 {                  struct foo11 {
    char c;          /* 1 */        struct foo11 *p; /* 8 */
    char pad1[7];    /* 7 */        short x;         /* 2 */
    struct foo10 *p; /* 8 */        char c;          /* 1 */
    short x;         /* 2 */        char pad[5];     /* 5 */
    char pad2[6];    /* 6 */    };
};  /* 24 bytes */              /* 16 bytes */
```

為什麼由大到小排就不會有中間的洞?因為**對齊嚴格的欄位的 stride address,一定也是對齊寬鬆的欄位的合法起點**。剩下的就只有尾端 padding。

幾個補充:

- **由小到大排也可以**。更一般的條件是:(a) 同樣大小的欄位排在連續的一段裡,(b) 段與段之間的大小差距(以 2 的倍數計)盡量小
- **重排不保證有效**。把上面的 `foo5` 內外對調,還是 24 bytes,因為外層的 `c` 沒辦法塞進內層 struct 的尾端 padding 裡 —— 這種情況要改資料結構設計才有救
- 這些規則同樣適用於 Go 的 struct、以及標了 `repr(C)` 的 Rust struct

**為什麼編譯器不自動重排?**

C 是設計來寫作業系統和貼近硬體的程式的。自動重排會破壞「struct 佈局精確對應到 memory-mapped 裝置暫存器」這件事。Go 沿用了 C 的哲學不重排;Rust 則相反,預設允許編譯器重排欄位。

## 麻煩的純量型別

重排前先確認這幾個型別的實際大小(用 `sizeof` 量,不要用猜的):

- **`enum`**:規格只保證與某個整數型別相容,**沒有規定是哪一個**。通常是 `int`,但也可能是 `short`、`long` 甚至 `char`
- **`long double`**:有 80-bit、128-bit 實作;80-bit 的又可能被補到 96 或 128 bits
- **x86 Linux 上的 `double`**:獨立變數是 8-byte 對齊,但在 struct 裡可能只需要 4-byte 對齊,視編譯器與選項而定

## 可讀性與 cache locality

機械式地照大小重排不一定是對的,還有兩件事要權衡:

- **可讀性**:語意相關的欄位應該擺在一起,struct 的設計本身就是在傳達程式的設計
- **cache locality**:常被一起存取的欄位擺在同一條 cache line 內(x86-64 是 64 bytes,其他平台常見 32 bytes)

好消息是這兩者方向一致 —— 把相關且會被一起存取的欄位擺在相鄰位置,同時改善可讀性與 cache 命中率。

多執行緒下還有第三個問題:**cache line bouncing**。在熱迴圈裡應該讓「讀的資料」和「寫的資料」落在不同的 cache line,以減少 bus traffic。這點有時會和上面「相關資料擺一起」的建議衝突。

## 其他縮小技巧

- **把 boolean flag 收成 1-bit bitfield**,塞進本來就是 slop 的位置。存取會慢一點,但如果因此讓 working set 縮小到能進 cache,這點代價通常划算
- **縮短欄位本身的寬度**。例如已知資料不早於某個年份,就能用 32-bit 的相對時間偏移取代 64-bit `time_t`(記得加上界檢查,否則會出現很難查的 bug)
- 每次縮短欄位都可能連帶消掉 slop、或創造出新的重排空間,常常會有連鎖效益
- **union 是風險最高的做法**:確定某些欄位不會同時使用時,可以讓它們共用儲存空間。但只要生命週期分析有一點錯,後果從 crash 到(更糟的)無聲資料損毀都有可能

## 強制覆寫對齊規則

```c
#pragma pack(1)
struct __attribute__((packed)) Wire { uint8_t tag; uint32_t val; };
```

- GCC / clang 有 `packed` attribute,也有 `-fpack-struct` 可以套用到整個編譯單元
- **不要隨便用**:它會產生更慢、更大的程式碼,而且成員會落在沒對齊的位址上,取成員位址再解參考就是 UB
- 唯一真正站得住腳的理由,是必須讓佈局精確符合硬體或協定的位元級要求

## 工具

| 工具 | 用途 |
|---|---|
| `clang -Wpadded` | 回報結構中的對齊空洞與 padding |
| `clang -fdump-record-layouts` | 更詳細的佈局資訊(未文件化) |
| `pahole` | 產生 padding、對齊、cache line 邊界的報告(現在隨 gdb 一起發佈) |
| `static_assert`(C11) | 把假設寫進程式碼裡 |

```c
#include <assert.h>
static_assert(sizeof(struct foo4) == 4, "Check your assumptions");
```

## 小結

- 主流 ISA 上基本型別都是 **self-aligned**;struct 的對齊 = 最寬成員的對齊,且開頭不會有 padding
- slop 只有兩個來源:**大接在小後面**、以及**補到 stride address**
- `sizeof` 由 stride address 決定,所以 `{ char *p; char c; }` 是 16 bytes 而不是 9
- padding 的內容 **undefined**,不要用 `memcmp` 比較 struct
- 依對齊需求由大到小重排是最簡單的省空間手法,但重排**不保證**有效,而且要和可讀性、cache locality 一起權衡
- bitfield 除了「相鄰時會緊密打包」之外幾乎什麼都不保證,不可移植
- `#pragma pack` / `packed` 只在必須精確對應硬體或協定佈局時才用
