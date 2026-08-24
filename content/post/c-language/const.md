---
title: "C 語言 const"
date: 2026-08-05
draft: false
description: "const 是什麼、怎麼讀指標上的 const、const 不等於常數,以及常見的誤解"
tags: ["c", "const"]
categories: ["程式語言"]
---

## 是什麼

- `const` 是一個 **type qualifier**,和 `volatile`、`restrict` 都是 type qualifier
- 它表達的是 **「我不會透過這個名字去修改它」**,是給 compiler 的一個承諾

```c
const int x = 10;
const char *msg = "hello";
```

下面對照 **C99** 的三段規範。

**① qualified 與 unqualified 是「不同的型別」**

C99 [6.2.5]:

> Any type so far mentioned is an unqualified type. Each unqualified type has several qualified versions of its type, corresponding to the combinations of one, two, or all three of the `const`, `volatile`, and `restrict` qualifiers. The qualified or unqualified versions of a type are distinct types that belong to the same type category and have the same representation and alignment requirements. A derived type is not qualified by the qualifiers (if any) of the type from which it is derived.

任何 unqualified type 都可以與 `const` 組合,形成該型別的 qualified 版本。qualified type 與其對應的 unqualified type 是 **不同的型別**,但在記憶體表示法(representation)與對齊需求(alignment requirements)上完全相同。

- 換句話說,`const int` 和 `int` 佔一樣的空間、擺法一樣,差別純粹在**型別系統層次**
- 最後一句「derived type 不會繼承來源型別的 qualifier」是後面理解指標的關鍵伏筆

**② const 物件不是 modifiable lvalue**

C99 [6.3.2.1]:

> An lvalue is an expression with an object type or an incomplete type other than `void`; if an lvalue does not designate an object when it is evaluated, the behavior is undefined. ... A **modifiable lvalue** is an lvalue that does not have array type, does not have an incomplete type, does not have a const-qualified type, and if it is a structure or union, does not have any member (including, recursively, any member or element of all contained aggregates or unions) with a const-qualified type.

而 C99 [6.5.16] 對賦值運算子的 constraint 是:

> An assignment operator shall have a modifiable lvalue as its left operand.

兩條合起來就是 `const` 不能被賦值的真正理由:

- const-qualified 的物件**不屬於** modifiable lvalue
- 賦值運算子要求左運算元必須是 modifiable lvalue
- 所以寫 `a = 6;` 違反 constraint,compiler **一定要**報錯

```c
const int a = 5;   // OK:初始化不是賦值,走的是 initializer 的規則
a = 6;             // 編譯錯誤:a 不是 modifiable lvalue

const int b;       // 合法但沒意義:block scope 下值不確定,且之後再也無法賦值
```

**③ 繞過 const 去修改 const 物件是 UB**

C99 [6.7.3]:

> If an attempt is made to modify an object defined with a const-qualified type through use of an lvalue with non-const-qualified type, the behavior is undefined.

注意這句話的方向:被修改的物件**在定義時**就是 const,而你透過某種方式(通常是 cast 掉 const)拿到一個非 const 的 lvalue 去改它 —— 這是 undefined behavior。

```c
const int v = 10;           // v 本身在定義時是 const 限定型別

int *ptr = (int *)&v;       // 強制拔掉 const
*ptr = 20;                  // 未定義行為
```

為什麼標準把它訂成 UB,而不是要求 compiler 報錯?因為同一節還給了實作很大的空間。C99 [6.7.3]:

> The implementation may place a const object that is not volatile in a read-only region of storage. Moreover, the implementation need not allocate storage for such an object if its address is never used.

- 非 `volatile` 的 `const` 物件,實作**可以**把它放進唯讀的儲存區
- 如果這個物件的位址從來沒被取用過,實作**可以**完全不幫它配置空間

這兩條許可,正好對應到實務上會踩到的兩種結果:

- **直接 crash**:`const` 物件被放進唯讀的 `.rodata` section,寫進去就是 segfault
- **改了卻沒效果**:compiler 認定「它是 const,值不會變」,把 `v` 的值直接內嵌進程式碼,後面讀到的還是 `10`

② 是 constraint violation,compiler 一定要給診斷訊息,你當場就編不過;③ 是 undefined behavior,compiler 沒義務抓,編得過、跑起來才炸。所以 cast 掉 const 危險的地方不在於它繞過檢查,而在於它把編譯期錯誤變成執行期的未定義行為。

## 指標上的 const 怎麼讀

這是 `const` 最容易搞混的地方。先看規格怎麼定調。

### 規格怎麼定調

C99 [6.2.5] EXAMPLE:

> The type designated as "`float *`" has type "pointer to `float`". Its type category is pointer, not a floating type. The const-qualified version of this type is designated as "`float * const`" whereas the type designated as "`const float *`" is not a qualified type — its type is "pointer to const-qualified `float`" and is a pointer to a qualified type.

- `float *` 是 pointer to float,它的 **const-qualified version 是 `float * const`**
- `const float *` **不是** 一個 const-qualified type,它是 pointer to const float ——「指標本身沒被限定,被限定的是它指到的東西」

這正好呼應 ① 最後那句:derived type(指標)不會繼承來源型別(`float`)的 qualifier。`const float *` 的 `const` 是黏在 `float` 上,不是黏在指標上。

C99 [6.7.5.1] EXAMPLE:

> The following pair of declarations demonstrates the difference between a "variable pointer to a constant value" and a "constant pointer to a variable value".
>
> ```c
> const int *ptr_to_constant;
> int *const constant_ptr;
> ```
>
> The contents of any object pointed to by `ptr_to_constant` shall not be modified through that pointer, but `ptr_to_constant` itself may be changed to point to another object. Similarly, the contents of the `int` pointed to by `constant_ptr` may be modified, but `constant_ptr` itself shall always point to the same location.

### 記憶法:從變數名往左讀

遇到 `*` 就唸「pointer to」:

| 宣告 | 讀法 | 意思 |
|---|---|---|
| `const float *p` | p is a **pointer to** a **const float** | 指到的值不能改,指標可以改 |
| `float const *p` | 同上,兩種寫法完全等價 | 同上 |
| `float *const p` | p is a **const pointer to** a **float** | 值可以改,指標本身不能改 |
| `const float *const p` | p is a **const pointer to** a **const float** | 兩者都不能改 |

實際差別:

```c
int a = 1, b = 2;

const int *p1 = &a;
*p1 = 10;      // ✗ 編譯錯誤:不能透過 p1 改值
p1 = &b;       // ✓ 可以改指標本身

int *const p2 = &a;
*p2 = 10;      // ✓ 可以改值
p2 = &b;       // ✗ 編譯錯誤:不能改指標本身
```

- 另一個等價的判斷規則:**`const` 修飾的是它左邊的東西;左邊沒東西時,才修飾右邊**
  - `const int *` → `const` 左邊沒東西,所以修飾 `int`(指到的值是 const)
  - `int *const` → `const` 左邊是 `*`,所以修飾指標本身

### 用 typedef 驗證

C99 [6.7.5.1] 接著給了一個很好的驗證方式:

> The declaration of the constant pointer `constant_ptr` may be clarified by including a definition for the type "pointer to `int`".
>
> ```c
> typedef int *int_ptr;
> const int_ptr constant_ptr;
> ```
>
> declares `constant_ptr` as an object that has type "const-qualified pointer to `int`".

- `int_ptr` 這個型別是「pointer to int」,`const` 修飾的是**這整個型別**,所以結果是 `int *const`,不是 `const int *`
- 這裡的重點是:**typedef 不是文字替換**。如果你把它當 macro 展開成 `const int * constant_ptr`,就會得到完全相反的答案
- 反過來說,當你被 `const` 的位置繞暈時,把型別抽成 typedef 就能看清楚 `const` 到底黏在誰身上

## 為什麼需要它

**1. 讓 compiler 幫你抓錯**

把不該改的東西標成 `const`,寫錯的當下就是編譯錯誤,而不是跑起來才發現資料被改掉。

**2. 當作函式介面的文件**

看到這個 signature 就知道 `src` 只會被讀、`dest` 會被寫:

```c
void *memcpy(void *dest, const void *src, size_t n);
size_t strlen(const char *s);
```

標準函式庫大量使用這個慣例,對呼叫者來說是很強的資訊。

**3. 保護字串常值**

```c
char *s = "hello";       // C 允許,但改 s[0] 是 UB
const char *s = "hello"; // 建議寫法,改它會編譯錯誤
```

字串常值本身型別是 `char[]`(不是 `const char[]`,這點和 C++ 不同),但**修改它是 undefined behavior**。用 `const char *` 接住,才能讓 compiler 幫你擋下來。

## const 不等於「常數」

這是最大的誤解 —— C 的 `const` 物件 **不是 constant expression**,不能用在需要編譯期常數的地方:

```c
const int SIZE = 10;

int arr[SIZE];          // block scope 下變成 VLA;file scope / static 則直接編譯錯誤
switch (x) {
    case SIZE: ...      // ✗ 編譯錯誤:case label 需要常數運算式
}
struct { int a[SIZE]; } s;  // ✗ 編譯錯誤
```

- 需要真正的編譯期常數,用 `#define` 或 `enum`:

```c
#define SIZE 10       // 擇一即可,兩者同時寫會展開成 enum { 10 = 10 }
enum { SIZE = 10 };
```

> 這點和 C++ 不一樣。C++ 的 `const int SIZE = 10;` 是 constant expression,可以直接拿來當陣列大小。

## 常見的坑

### `char **` 不能隱式轉成 `const char **`

單層的 `char *` → `const char *` 是合法的隱式轉換,但多一層之後就不行了:

```c
void f(const char **p);

char *arr[10];
f(arr);          // ✗ constraint violation(GCC 預設給 warning)
```

#### 為什麼危險

規格直接舉了例子說明。C99 [6.5.16.1] EXAMPLE 3:

> ```c
> const char **cpp;
> char *p;
> const char c = 'A';
> cpp = &p;    // constraint violation
> *cpp = &c;   // valid
> *p = 0;      // valid
> ```
>
> The first assignment is unsafe because it would allow the following valid code to attempt to change the value of the const object `c`.

把三行連起來看就通了 —— 假設第一行被允許:

1. `cpp = &p` → `cpp` 指向 `p`,於是 `*cpp` **就是** `p` 這個物件
2. `*cpp = &c` → `*cpp` 的型別是 `const char *`,拿 `&c`(也是 `const char *`)賦值完全合法。但實際效果是 **`p` 現在指向了 `c`**
3. `*p = 0` → `p` 的型別是 `char *`,透過它寫入當然合法。但它寫的是 `c` —— 一個 const 物件

結果:三行單獨看每一行都合法,合起來卻改掉了 const 物件,而且**沒有任何一行出現 cast**。

- 這正是前面 ③ 講的 UB,只是被拆成三步藏起來了
- compiler 沒辦法在第 2、3 行抓到問題(那時型別資訊已經合法了),所以標準選擇**在源頭第 1 行就擋掉**
- 要真的傳過去,只能明確寫 cast,等於你自己簽名擔保安全

#### 規格憑什麼擋

EXAMPLE 只說了「unsafe」,真正的依據在同一節的 Constraints。C99 [6.5.16.1] p1 列出賦值合法的六種情形,和指標有關的是第三條:

> One of the following shall hold:
> - ...
> - **both operands are pointers to qualified or unqualified versions of compatible types, and the type pointed to by the left has all the qualifiers of the type pointed to by the right;**
> - ...

拆成兩個要件:

- **(a)** 兩邊都是指標,且各自指到的型別,在**剝掉頂層 qualifier 後**互相 compatible
- **(b)** 左邊指到的型別,擁有右邊指到的型別的**所有 qualifier**

判斷 compatible 還要再往下查三條:

| 條文 | 規則 |
|---|---|
| [6.2.7] p1 | Two types have compatible type if their types are the same. |
| [6.7.3] p9 | For two **qualified** types to be compatible, both shall have the **identically qualified** version of a compatible type. |
| [6.7.5.1] p2 | For two **pointer** types to be compatible, both shall be **identically qualified** and both shall be pointers to compatible types. |

**先看單層為什麼可以**

```c
char *q;
const char *p = q;   // ✓ 合法
```

- 指到的型別:左 `const char`,右 `char`
- **(a)** 剝掉頂層 qualifier → `char` vs `char`,compatible ✓
- **(b)** 左的 qualifier = `{const}`,右的 = `{}`,右邊的每個 qualifier 左邊都有 ✓

**再看雙層為什麼不行**

```c
const char **cpp;
char *p;
cpp = &p;            // ✗ constraint violation
```

- 指到的型別:左 `const char *`,右 `char *`
- **(b) 居然是過的** —— 回想前面 [6.2.5] EXAMPLE 說過,`const char *` **不是** const-qualified type,它是「pointer to const char」。所以左右兩邊指到的型別**都是 unqualified 的指標型別**,qualifier 集合都是 `{}`,(b) 形同虛設 ✓
- **(a) 才是卡住的地方** —— 要問 `const char *` 和 `char *` 是否 compatible:
  1. 依 [6.7.5.1] p2,兩個指標型別 compatible,需要「identically qualified」且「指向 compatible types」
  2. 兩者都是 unqualified 指標,第一個條件過
  3. 但指向的是 `const char` vs `char` —— 依 [6.7.3] p9,兩者不是 identically qualified,**不 compatible**
  4. 所以 `const char *` 與 `char *` 不 compatible ✗

**關鍵洞見:qualifier 只被剝一層**

(a) 裡「qualified or unqualified versions of」這個寬鬆說法,**只作用在指到的型別的最頂層**:

- 單層時,`const` 的差異剛好就在那一層,被剝掉了,所以放行
- 雙層時,`const` 的差異被埋在**更深一層**(`const char *` 裡的 `char` 上),剝不到,於是撞上 [6.7.5.1] p2「identically qualified」這個沒有轉圜餘地的硬性要求

換句話說,C 的 const 相容性**不會遞迴地往下寬容**。這不是規格漏寫,而是刻意的 —— 前面三步推導已經證明,一旦往下寬容就能無 cast 地改掉 const 物件。

**補充:為什麼 (b) 只要求單向**

(b) 只說「左邊要有右邊的所有 qualifier」,反過來不用。C99 對這一條有 footnote 96 解釋:

> The asymmetric appearance of these constraints with respect to type qualifiers is due to the conversion (specified in 6.3.2.1) that changes lvalues to "the value of the expression" and thus removes any type qualifiers that were applied to the type category of the expression (for example, it removes `const` but not `volatile` from the type `int volatile * const`).

- 依 [6.3.2.1] p2,右運算元會先做 **lvalue conversion**:「If the lvalue has qualified type, the value has the unqualified version of the type of the lvalue」
- 也就是右邊**頂層**的 qualifier 在取值時就被丟掉了,所以 `const int x; int y = x;` 當然合法
- 既然頂層 qualifier 對右邊不具意義,約束自然只能是單向的 —— 這也是為什麼 (b) 談的是「**指到的**型別」的 qualifier,而不是運算元本身的

### `const` 不代表值不會變

`const` 只是承諾「**我不會透過這個名字改它**」,不代表這塊記憶體真的不會變:

```c
const volatile uint32_t *status_reg;
```

- 這是硬體唯讀狀態暫存器的典型宣告:我的程式不會寫它(`const`),但硬體會改它(`volatile`)
- 所以 compiler 不能因為 `const` 就把讀取 optimize 掉

### 含 const 成員的 struct 不能整體賦值

回到 ② 的 modifiable lvalue 定義,裡面那句 **including, recursively** 是關鍵:只要 struct 或 union 裡(遞迴地)包含任何 const-qualified 的成員,**整個 struct 物件**就不再是 modifiable lvalue。

```c
struct S { const int id; int val; };

struct S a = {1, 2};
struct S b = {3, 4};
a = b;              // ✗ 編譯錯誤:a.id 是 const,整個 a 都不是 modifiable lvalue
a.val = 5;          // ✓ 單獨改非 const 成員沒問題
```

- 這也是為什麼含 const 成員的 struct 用起來很綁手:不能整體賦值,自然也不能放進需要賦值的容器操作裡

## 小結

- `const` = **type qualifier**,語意是「不透過這個 lvalue 修改」,主要價值是 compiler 幫你檢查 + 當文件
- `const int` 和 `int` 是**不同型別**,但表示法與對齊完全相同
- 不能賦值的機制是:const 物件不是 **modifiable lvalue**,而賦值要求左運算元必須是
- 指標上的 `const` 從變數名往左讀;判斷 `const` 黏在誰身上,可以用 typedef 驗證
- C 的 `const` **不是編譯期常數**,要常數請用 `#define` / `enum`
- cast 掉 `const` 再去改原本就是 const 的物件 = undefined behavior
- const 的相容性**只寬容一層**:`char *` → `const char *` 可以,`char **` → `const char **` 不行
- `const` 和 [volatile]({{< ref "volatile.md" >}}) 正交,`const volatile` 是合法且常見的組合
