---
title: "Linked List 鏈結串列"
date: 2026-08-15
draft: false
description: "鏈結串列經典題,含反轉、快慢指標、找交點、合併 K 條等"
tags: ["leetcode", "linked-list"]
categories: ["演算法"]
---

## 21. Merge Two Sorted Lists

- 這題應該是直覺的使用recursive，如果list1是nullptr，就回傳list2，反之亦然
- 接下來就是比大小，大的話，就是用小的那個去self function，以達成recursive

## 83. Remove Duplicates from Sorted List

- Linked list 基礎題，使用一個pointer指著現在的node，並且和下一個node比較，如果value相同，那就刪除下一個點，並且不要前進。
- 反之如果value不同，那就前進一格
- 所以一個while迴圈就可以搞定，迴圈裡面一組if else
- 記得刪掉的點要delete，避免memory leak
- Function開頭不用if head == nullptr 去提前結束，整體來看不會比較快

## 141. Linked List Cycle

- 經典的fast, slow pointer手法，也就是fast走兩步，slow走一步，移動過程中發現fast == slow，那就代表有cycle
- 因為剛開始的時候，fast和slow都會等於head ，所以while迴圈的判斷條件一定不能使用兩個相等來判斷
- 因為快指標走比較快，所以while的判斷條件使用fast存在與否去判斷
    - 也可以使用fast && fast → next，當然while迴圈內容也會跟著改變
- Fast移動碰到nullptr就是沒有cycle
- 移動後再判斷fast == slow

## 160. Intersection of Two Linked Lists

- 這題的題目是給定兩個linked list ，如果有交集，就回傳第一個交集點，沒有則是回傳nullptr
- 這題有很多解法，首先是暴力解，時間複雜度O(m*n)，兩層while迴圈很直覺
- 下一個解法是hash table，一個linked list走過一圈全部記錄起來
    - 另一個走過一圈，碰到hash table有東西就有答案了
- 下一個是兩個都走過一遍，就可以知道長度的差異
    - 然後長的那一條就先走幾步，使兩者剩餘的長度相等
    - 之後就走while迴圈去找到交叉點
- 最後一個解法很聰明，不需要知道長度多少
    - 基本上是上一個解法的再延伸
    - 一個linked list走到底之後，使這個ptr為另一條的”開頭”
    - 所以兩個pointer走的長度就會自然相同
    - While迴圈就也只要簡單判斷兩者是否相同就好
    - 是的話就回傳當下的pointer
        - 如果有交叉，提前結束就會回傳交叉點
        - 如果沒交叉，都會走到底，所以會是nullptr，回傳的也是正確答案

## 203. Remove Linked List Elements

- 這題的目的是把linked list中的特定值全部移除掉
    - 首先要注意一些corner case
    - 可能是整條都會被刪掉，所以要注意首節點
- 最直觀的解法就是traverse一整條linked list
    - 因為有可能整條不見，所以要漂亮的解法，就要宣告一個dummy node
        - 延伸思考: 有沒有辦法使用pointer to pointer的技巧
    - 然後宣告一個pointer指向dummy node
    - While迴圈的判斷條件就是pointer → next
    - 內容就很簡單，如果下一個node的Val要被移除掉，就直接把pointer → next指向 pointer → next → next
    - 如果不用移除，就簡單將pointer往前移動一個
    - 最後回傳dummy.next
- 另一個是recursion
    - 可以縮小input，丟到遞迴去
        - 根據現在的值去判斷要丟什麼內容到遞迴去
        - 先判斷nullptr，如果是，就回傳nullptr
        - 再判斷是否相同，如果相同，就直接回傳遞迴，input就是head→next
        - 最後就是把head→next = recursive()，input也是head→ next，然後return head

## 206. Reverse Linked List

- 這是基本題，input是一個linked list head，回傳一個reverse好的linked list
- 宣告一個prev, curr，prev = nullptr, curr = head
    - 使用while迴圈，head先往前走
    - 然後curr next 指到prev，prev = curr, curr = head
- 最後因為head和curr都會是nullptr，而prev剛好會是linked list的head
- 所以回傳prev

## 234. Palindrome Linked List

- 這題是判斷linked list是不是palindrome (回文)
- stack掃過一遍的方式太trivial，直接跳過，用follow up的空間複查度O(1)來解
- 首先要判斷回文，就是要先走到中間，因為我們要拆一半，那既然要拆一半，後半段就可以直接reverse，最後手上有兩個linked list，直接做判斷兩者值是否一樣就好
- 第一個重點，要找出中間的點:
    - 想法就是快慢指標，fast and slow往前，當fast碰到nullptr時，slow就會是mid node
- 第二個重點是，因為這題要拆解成三個步驟，所以務必要寫成小的function去call
    - 一個function內參數一多，步伐就亂，參數名稱會搞到自己
    - 再來是比較好Debug

## 19. Remove Nth Node From End of List

- 給定一個linked list和一個index，要刪掉從tail數回來的第n個node
- 這題最難的想法是只能走一遍
    - 去思考linked list的長度和index的關係
    - 長度L，要刪掉的就是第L-n個
- 所以使用兩個指標，先走n步後，第二個指標也開始走，那麼第一個指標走到tail的時候，第二個指標的下一個就是要刪掉的node
- 因為有可能會動到首節點，所以要宣告一個dummy node

## 143. Reorder List

- 這題給定一個linked list，然後更新成N1→Nn→N2→Nn-1→N3以此類推
- 所以第一個想法就是，要先把linked list切一半，並且作反轉
- 那就跟Palindrome那題很像了，就是基本功，要切function，找出mid和反轉
- 細節就是找mid時，偶數最好是要前一個，就是1234，mid要找出2
    - 要記得把2→next清掉成nullptr
- 最後就使用一個while loop把兩個併起來，然後第一個linked list長度一定是大於等於反轉的那條
    - 然後要有新的變數去記錄兩個linked list的下一個點，不然指一指就亂了

## 23. Merge k Sorted Lists

- 這題是Merge 2 sorted lists的延伸題
- 基本上解法很多，可以是priority queue，也可以使用寫過的merge 2 sorted lists
- 有K個lists，如果合併要快，就是要兩兩合併，而且要次數相等，不能1和2，1和3，1和4以次類推的合併
- 想法是1和n, 2和n-1, 3和n-2
- 第二個iteration會讓n減半，這裡要知道下一個n是多少很重要，因為和奇數偶數有關係
    - 現在有4，下一輪就是2，但如果是3，下一輪應該也要是2
    - 所以會是n = (n+1) / 2
- 這想法源自於merge sort