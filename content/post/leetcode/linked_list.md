---
title: "Linked List 鏈結串列"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "鏈結串列經典題,含反轉、快慢指標、找交點、合併 K 條等"
tags: ["leetcode", "linked-list"]
categories: ["演算法"]
---

## 21. Merge Two Sorted Lists

- 這題應該是直覺的使用 recursive，如果 list1 是 nullptr，就回傳 list2，反之亦然
- 接下來就是比大小，大的話，就是用小的那個去 self function，以達成 recursive

## 83. Remove Duplicates from Sorted List

- Linked list 基礎題，使用一個 pointer 指著現在的 node，並且和下一個 node 比較，如果 value 相同，那就刪除下一個點，並且不要前進。
- 反之如果 value 不同，那就前進一格
- 所以一個 while 迴圈就可以搞定，迴圈裡面一組 if else
- 記得刪掉的點要 delete，避免 memory leak
- Function 開頭不用 if head == nullptr 去提前結束，整體來看不會比較快

## 141. Linked List Cycle

- 經典的 fast, slow pointer 手法，也就是 fast 走兩步，slow 走一步，移動過程中發現 fast == slow，那就代表有 cycle
- 因為剛開始的時候，fast 和 slow 都會等於 head，所以 while 迴圈的判斷條件一定不能使用兩個相等來判斷
- 因為快指標走比較快，所以 while 的判斷條件使用 fast 存在與否去判斷
    - 也可以使用 fast && fast → next，當然 while 迴圈內容也會跟著改變
- Fast 移動碰到 nullptr 就是沒有 cycle
- 移動後再判斷 fast == slow

## 160. Intersection of Two Linked Lists

- 這題的題目是給定兩個 linked list，如果有交集，就回傳第一個交集點，沒有則是回傳 nullptr
- 這題有很多解法，首先是暴力解，時間複雜度 O(m*n)，兩層 while 迴圈很直覺
- 下一個解法是 hash table，一個 linked list 走過一圈全部記錄起來
    - 另一個走過一圈，碰到 hash table 有東西就有答案了
- 下一個是兩個都走過一遍，就可以知道長度的差異
    - 然後長的那一條就先走幾步，使兩者剩餘的長度相等
    - 之後就走 while 迴圈去找到交叉點
- 最後一個解法很聰明，不需要知道長度多少
    - 基本上是上一個解法的再延伸
    - 一個 linked list 走到底之後，使這個 ptr 為另一條的「開頭」
    - 所以兩個 pointer 走的長度就會自然相同
    - While 迴圈就也只要簡單判斷兩者是否相同就好
    - 是的話就回傳當下的 pointer
        - 如果有交叉，提前結束就會回傳交叉點
        - 如果沒交叉，都會走到底，所以會是 nullptr，回傳的也是正確答案

## 203. Remove Linked List Elements

- 這題的目的是把 linked list 中的特定值全部移除掉
    - 首先要注意一些 corner case
    - 可能是整條都會被刪掉，所以要注意首節點
- 最直觀的解法就是 traverse 一整條 linked list
    - 因為有可能整條不見，所以要漂亮的解法，就要宣告一個 dummy node
        - 延伸思考: 有沒有辦法使用 pointer to pointer 的技巧
    - 然後宣告一個 pointer 指向 dummy node
    - While 迴圈的判斷條件就是 pointer → next
    - 內容就很簡單，如果下一個 node 的 Val 要被移除掉，就直接把 pointer → next 指向 pointer → next → next
    - 如果不用移除，就簡單將 pointer 往前移動一個
    - 最後回傳 dummy.next
- 另一個是 recursion
    - 可以縮小 input，丟到遞迴去
        - 根據現在的值去判斷要丟什麼內容到遞迴去
        - 先判斷 nullptr，如果是，就回傳 nullptr
        - 再判斷是否相同，如果相同，就直接回傳遞迴，input 就是 head→next
        - 最後就是把 head→next = recursive()，input 也是 head→ next，然後 return head

## 206. Reverse Linked List

- 這是基本題，input 是一個 linked list head，回傳一個 reverse 好的 linked list
- 宣告一個 prev, curr，prev = nullptr, curr = head
    - 使用 while 迴圈，head 先往前走
    - 然後 curr next 指到 prev，prev = curr, curr = head
- 最後因為 head 和 curr 都會是 nullptr，而 prev 剛好會是 linked list 的 head
- 所以回傳 prev

## 234. Palindrome Linked List

- 這題是判斷 linked list 是不是 palindrome (回文)
- stack 掃過一遍的方式太 trivial，直接跳過，用 follow up 的空間複雜度 O(1)來解
- 首先要判斷回文，就是要先走到中間，因為我們要拆一半，那既然要拆一半，後半段就可以直接 reverse，最後手上有兩個 linked list，直接做判斷兩者值是否一樣就好
- 第一個重點，要找出中間的點:
    - 想法就是快慢指標，fast and slow 往前，當 fast 碰到 nullptr 時，slow 就會是 mid node
- 第二個重點是，因為這題要拆解成三個步驟，所以務必要寫成小的 function 去 call
    - 一個 function 內參數一多，步伐就亂，參數名稱會搞到自己
    - 再來是比較好 Debug

## 19. Remove Nth Node From End of List

- 給定一個 linked list 和一個 index，要刪掉從 tail 數回來的第 n 個 node
- 這題最難的想法是只能走一遍
    - 去思考 linked list 的長度和 index 的關係
    - 長度 L，要刪掉的就是第 L-n 個
- 所以使用兩個指標，先走 n 步後，第二個指標也開始走，那麼第一個指標走到 tail 的時候，第二個指標的下一個就是要刪掉的 node
- 因為有可能會動到首節點，所以要宣告一個 dummy node

## 143. Reorder List

- 這題給定一個 linked list，然後更新成 N1→Nn→N2→Nn-1→N3 以此類推
- 所以第一個想法就是，要先把 linked list 切一半，並且作反轉
- 那就跟 Palindrome 那題很像了，就是基本功，要切 function，找出 mid 和反轉
- 細節就是找 mid 時，偶數最好是要前一個，就是 1234，mid 要找出 2
    - 要記得把 2→next 清掉成 nullptr
- 最後就使用一個 while loop 把兩個併起來，然後第一個 linked list 長度一定是大於等於反轉的那條
    - 然後要有新的變數去記錄兩個 linked list 的下一個點，不然指一指就亂了

## 23. Merge k Sorted Lists

- 這題是 Merge 2 sorted lists 的延伸題
- 基本上解法很多，可以是 priority queue，也可以使用寫過的 merge 2 sorted lists
- 有 K 個 lists，如果合併要快，就是要兩兩合併，而且要次數相等，不能 1 和 2，1 和 3，1 和 4 以此類推的合併
- 想法是 1 和 n, 2 和 n-1, 3 和 n-2
- 第二個 iteration 會讓 n 減半，這裡要知道下一個 n 是多少很重要，因為和奇數偶數有關係
    - 現在有 4，下一輪就是 2，但如果是 3，下一輪應該也要是 2
    - 所以會是 n = (n+1) / 2
- 這想法源自於 merge sort