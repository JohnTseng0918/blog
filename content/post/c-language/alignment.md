---
title: "C 語言 alignment"
date: 2026-08-24
draft: false
description: "C99 規格中的 alignment:型別的對齊需求、指標轉型與 UB、struct padding、malloc 的對齊保證,以及 C11 之後的 _Alignof / _Alignas"
tags: ["c", "alignment", "memory"]
categories: ["程式語言"]
---

## 是什麼

C99 [3.2]:

> **alignment**
> requirement that objects of a particular type be located on storage boundaries with addresses that are particular multiples of a byte address

- alignment 是指:某個型別的物件,必須被放在**位址為某個特定值之倍數**的位置上
- 這個「特定值」就是該型別的 **alignment requirement**,通常是 1、2、4、8… 這種 2 的次方

```c
// 典型的 x86-64 / RV64 結果
sizeof(char)  == 1, _Alignof(char)  == 1   // 位址可以是任意值
sizeof(int)   == 4, _Alignof(int)   == 4   // 位址必須是 4 的倍數
sizeof(double)== 8, _Alignof(double)== 8   // 位址必須是 8 的倍數
```

**為什麼硬體要這個限制?**

- 記憶體是以固定寬度的 word 為單位存取的。一個對齊的 4-byte 讀取只要一次 bus transaction,跨越 word 邊界的讀取則要兩次再拼起來
- 有些架構(早期 ARM、部分 RISC-V 實作、SPARC)遇到 misaligned access 直接丟出 exception;x86 雖然允許,但會變慢
- Cache line 也是同理:跨 cache line 的存取會摸到兩條 line

注意規格**沒有規定**任何型別的 alignment 值是多少 —— 那完全是 implementation-defined。規格只規定了「**哪些型別彼此的 alignment 必須相同**」,以及「**沒對齊會發生什麼事**」。

## 哪些型別的 alignment 保證相同

這些是 C99 [6.2.5] 給的保證,可以放心依賴。

**① 有號 / 無號整數型別**

C99 [6.2.5] p6:

> For each of the signed integer types, there is a corresponding (but different) unsigned integer type (designated with the keyword `unsigned`) that uses the same amount of storage (including sign information) and has the same alignment requirements.

- `int` 與 `unsigned int` 佔一樣的空間、對齊需求一樣
- 所以 `int *` 與 `unsigned int *` 互轉不會有對齊問題(但透過不同型別讀寫仍受 strict aliasing 規則約束)

**② complex type**

C99 [6.2.5] p13:

> Each complex type has the same representation and alignment requirements as an array type containing exactly two elements of the corresponding real type; the first element is equal to the real part, and the second element to the imaginary part, of the complex number.

- `double _Complex` 的表示法與對齊需求,等同於 `double[2]`
- 所以把 `double _Complex *` 當成 `double *` 去取實部/虛部是有規格背書的

**③ qualified 與 unqualified 版本**

C99 [6.2.5] p26:

> The qualified or unqualified versions of a type are distinct types that belong to the same type category and have the same representation and alignment requirements.

- `const int`、`volatile int`、`int` 是**不同型別**,但表示法與對齊需求完全相同
- 加 [const]({{< ref "const.md" >}}) 或 `volatile` 不會改變記憶體佈局,它們只活在型別系統層次

**④ 指標型別**

C99 [6.2.5] p27:

> A pointer to `void` shall have the same representation and alignment requirements as a pointer to a character type. Similarly, pointers to qualified or unqualified versions of compatible types shall have the same representation and alignment requirements. All pointers to structure types shall have the same representation and alignment requirements as each other. All pointers to union types shall have the same representation and alignment requirements as each other. Pointers to other types need not have the same representation or alignment requirements.

整理成表:

| 保證相同的組合 | 例子 |
|---|---|
| `void *` 與 `char *` | `void *` ↔ `char *` |
| 指向 compatible type 的 qualified / unqualified 版本 | `int *` ↔ `const int *` |
| 所有指向 struct 的指標之間 | `struct A *` ↔ `struct B *` |
| 所有指向 union 的指標之間 | `union A *` ↔ `union B *` |

- 除此之外(例如 `int *` 與 `double *`、`int *` 與函式指標)**沒有任何保證**
- 這裡講的是「**指標本身**」的表示法與對齊,不是它指到的東西的對齊

> 規格的 footnote 39 補充:「same representation and alignment requirements」的用意是保證這些型別**可以互換**當作函式引數、回傳值與 union 成員。

## 沒對齊會發生什麼事

**① 整數轉指標:可能就是沒對齊的**

C99 [6.3.2.3] p5:

> An integer may be converted to any pointer type. Except as previously specified, the result is implementation-defined, might not be correctly aligned, might not point to an entity of the referenced type, and might be a trap representation.

- 把整數(例如寫死的 MMIO 位址)cast 成指標,結果是 implementation-defined
- 規格明講了三個「可能」:可能沒對齊、可能沒指到該型別的實體、可能是 trap representation

```c
// 寫 driver 時很常見,但對齊是你自己要負責的
volatile uint32_t *reg = (volatile uint32_t *)0x10000000UL;
```

**② 指標轉指標:轉出來沒對齊就是 UB**

C99 [6.3.2.3] p7:

> A pointer to an object or incomplete type may be converted to a pointer to a different object or incomplete type. If the resulting pointer is not correctly aligned for the pointed-to type, the behavior is undefined. Otherwise, when converted back again, the result shall compare equal to the original pointer.

- 注意 UB 的**時間點在轉型當下**,不是等到你去解參考才發生
- 只要對齊沒問題,轉過去再轉回來,結果會與原指標相等

```c
char buf[16];

int *p = (int *)buf;      // buf 只保證 alignment 1,轉成 int * 就可能是 UB
int *q = (int *)(buf + 1);// 幾乎肯定沒對齊
```

同一節的 footnote 57 補了一句很實用的性質:

> In general, the concept "correctly aligned" is transitive: if a pointer to type A is correctly aligned for a pointer to type B, which in turn is correctly aligned for a pointer to type C, then a pointer to type A is correctly aligned for a pointer to type C.

- 「正確對齊」具有**傳遞性**:A 對得起 B、B 對得起 C,則 A 對得起 C
- 實務上的意義:只要拿到一個對齊需求最嚴格的位址(例如 `malloc` 回傳值),它對任何型別都是對齊的

**③ 解參考沒對齊的指標:UB**

C99 [6.5.3.2] p4 的 footnote 87:

> Among the invalid values for dereferencing a pointer by the unary `*` operator are a null pointer, an address inappropriately aligned for the type of object pointed to, and the address of an object after the end of its lifetime.

- 規格把「對該型別而言不適當對齊的位址」和 null pointer、dangling pointer 並列為 **invalid value**
- 對 invalid value 做 `*` 就是 undefined behavior

**安全的做法:用 `memcpy`**

要從一段任意位址的 byte 流裡取出一個 `int`,不要 cast 指標,用 `memcpy`:

```c
uint32_t load_u32(const unsigned char *p) {
    uint32_t v;
    memcpy(&v, p, sizeof v);   // 完全沒有對齊要求
    return v;
}
```

- `memcpy` 的參數是 `void *`,對齊需求是 1,永遠合法
- 現代編譯器在目標平台允許 misaligned access 時,會把這段 `memcpy` 直接優化成一條 load 指令,沒有額外成本

## struct 與 union 的 alignment

C99 [6.7.2.1] p12:

> Each non-bit-field member of a structure or union object is aligned in an implementation-defined manner appropriate to its type.

- 每個非 bit-field 成員都會被擺在**適合它自己型別**的對齊位置上
- 「implementation-defined」表示規格不規定具體怎麼擺,但成員自身的對齊需求一定要被滿足

C99 [6.7.2.1] p13:

> Within a structure object, the non-bit-field members and the units in which bit-fields reside have addresses that increase in the order in which they are declared. A pointer to a structure object, suitably converted, points to its initial member (or if that member is a bit-field, then to the unit in which it resides), and vice versa. There may be unnamed padding within a structure object, but not at its beginning.

- 成員的位址**依宣告順序遞增**(編譯器不可以重排成員)
- struct 指標轉型後指向它的**第一個成員**,反之亦然 —— 因為 **struct 開頭不會有 padding**

C99 [6.7.2.1] p15:

> There may be unnamed padding at the end of a structure or union.

把這三條合起來,就推得出實務上熟知的排列規則:

- 成員順序固定 + 每個成員都要對齊 → 中間必須塞 **padding**
- struct 開頭不能有 padding → struct 自己的 alignment 至少等於第一個成員的 alignment
- 實務上,struct 的 alignment = **所有成員 alignment 的最大值**;`sizeof` 會被補到該值的倍數(否則陣列的第二個元素就會沒對齊)

```c
struct A {
    char  c;   // offset 0
               // offset 1..3: 3 bytes padding
    int   i;   // offset 4  (要 4-byte 對齊)
    char  d;   // offset 8
               // offset 9..11: 3 bytes 尾端 padding
};             // _Alignof == 4, sizeof == 12
```

**成員順序會影響大小**

同樣的成員,換個宣告順序就能省下空間:

```c
struct Bad  { char a; int b; char c; };   // sizeof == 12
struct Good { int b; char a; char c; };   // sizeof == 8
```

- 一般的做法:把**對齊需求大的成員排前面**,小的排後面
- 用 `offsetof`(`<stddef.h>`)可以直接查證每個成員的實際 offset:

```c
#include <stddef.h>
printf("%zu %zu\n", offsetof(struct A, i), sizeof(struct A));
```

**union**

- union 的 alignment = 所有成員 alignment 的最大值,`sizeof` = 最大成員大小補到該對齊的倍數
- 所以「宣告一個含有各種型別的 union」是 C11 之前拿到「夠嚴格的對齊」的常見手法

### bit-field 的對齊完全不能依賴

C99 [6.7.2.1] p10:

> An implementation may allocate any addressable storage unit large enough to hold a bit-field. If enough space remains, a bit-field that immediately follows another bit-field in a structure shall be packed into adjacent bits of the same unit. If insufficient space remains, whether a bit-field that does not fit is put into the next unit or overlaps adjacent units is implementation-defined. The order of allocation of bit-fields within a unit (high-order to low-order or low-order to high-order) is implementation-defined. The alignment of the addressable storage unit is unspecified.

這一段幾乎每句都在說「不保證」:

| 項目 | 規格態度 |
|---|---|
| 用多大的 storage unit 裝 bit-field | 實作自己挑(只要塞得下) |
| 相鄰 bit-field 塞得下時 | **保證**打包進同一個 unit 的相鄰位元 |
| 塞不下時放下一個 unit 還是跨 unit | implementation-defined |
| unit 內是從高位排到低位還是相反 | implementation-defined |
| **storage unit 本身的對齊** | **unspecified** |

- 結論:bit-field 的記憶體佈局**不可攜**,不要拿它直接對映硬體暫存器或網路封包格式
- 要精確控制位元位置,用明確的 `uint32_t` + shift/mask

## malloc 家族的對齊保證

C99 [7.20.3]:

> The pointer returned if the allocation succeeds is suitably aligned so that it may be assigned to a pointer to any type of object and then used to access such an object or an array of such objects in the space allocated (until the space is explicitly deallocated).

- `malloc` / `calloc` / `realloc` 回傳的指標,對**任何型別**都是正確對齊的
- 所以 `(int *)malloc(n)`、`(struct S *)malloc(sizeof(struct S))` 永遠安全,不需要自己做對齊
- 搭配前面 footnote 57 的傳遞性:拿到這個位址之後,不管轉成什麼型別都對得起來

同一節其他幾個容易忽略的點:

- 多次呼叫之間配到的記憶體,**順序與連續性都是 unspecified**
- 回傳的指標指向這塊空間的**起始位址**(最低的 byte address)
- `malloc(0)` 是 **implementation-defined**:可能回傳 null,也可能回傳一個不能拿來存取物件的非 null 指標

注意這個保證是給 `malloc` 回傳值的**起點**。自己在 buffer 裡切位置時,對齊要自己算:

```c
unsigned char *base = malloc(1024);
int *p = (int *)(base + 3);   // base 對齊,但 base + 3 不對齊 → UB
```

## C99 之後:標準終於能「表達」對齊

C99 只描述對齊需求,**沒有提供任何語法去查詢或指定**它。要拿到某個型別的 alignment,以前只能用這個 hack:

```c
#define ALIGNOF(type) offsetof(struct { char c; type t; }, t)
```

C11 把這件事標準化了:

| 設施 | 標頭檔 | 用途 |
|---|---|---|
| `_Alignof(type)` / `alignof` | `<stdalign.h>` | 查詢型別的對齊需求 |
| `_Alignas(x)` / `alignas` | `<stdalign.h>` | 指定物件或成員的對齊 |
| `max_align_t` | `<stddef.h>` | 對齊需求最嚴格的型別,等同 `malloc` 的保證 |
| `aligned_alloc(align, size)` | `<stdlib.h>` | 配置指定對齊的記憶體 |

```c
#include <stdalign.h>

alignas(64) char cacheline_buf[64];   // 對齊到 cache line
printf("%zu\n", alignof(max_align_t));

void *p = aligned_alloc(4096, 4096);  // size 必須是 align 的整數倍
```

- C23 之後 `alignof` / `alignas` 直接成為關鍵字,不再需要 include `<stdalign.h>`
- POSIX 另有 `posix_memalign`;Windows 是 `_aligned_malloc`

GCC / Clang 的擴充也很常見:

```c
struct __attribute__((packed)) Wire { uint8_t tag; uint32_t val; };  // 拿掉所有 padding
struct __attribute__((aligned(64))) Node { ... };                     // 提高對齊
```

- `packed` 會讓成員落在沒對齊的位址上,**取它的成員位址再解參考就是 UB**
- 用 `packed` 的 struct 時,只透過 `.` 存取成員(編譯器會產生 misaligned-safe 的存取),不要把成員位址傳出去

## 小結

- alignment = 「某型別的物件位址必須是某個值的倍數」,**具體數值是 implementation-defined**
- 規格保證對齊相同的組合:有號/無號整數、complex 與對應的 `T[2]`、qualified 與 unqualified 版本、`void *` 與 `char *`、所有 struct 指標之間、所有 union 指標之間
- 對齊出錯有三個 UB 入口:整數轉指標(implementation-defined,可能沒對齊)、**指標轉型當下**就沒對齊、解參考沒對齊的指標
- 「正確對齊」是**傳遞的**,所以拿到 `malloc` 回傳值之後,轉成任何型別都安全
- struct 成員順序不可重排、開頭不可有 padding,中間與尾端可以有 padding;成員排列順序會直接影響 `sizeof`
- bit-field 的 storage unit 對齊是 **unspecified**,佈局完全不可攜
- 要在任意 byte 位址上讀寫多位元組的值,用 `memcpy`,不要 cast 指標
- C99 沒有查詢/指定對齊的語法,C11 才補上 `_Alignof`、`_Alignas`、`max_align_t`、`aligned_alloc`
