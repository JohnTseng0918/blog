---
title: "DFS 深度優先搜尋"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "以 DFS/遞迴解樹與圖,含 BST 驗證、LCA、Course Schedule 等"
tags: ["leetcode", "dfs", "tree", "graph", "binary-tree"]
categories: ["演算法"]
---

## 98. Validate Binary Search Tree

- 給定一棵樹，必須驗證他是不是 BST
    - BST 代表左子樹都要嚴格小於 node，右子樹也要嚴格大於 node
- 那這題就是要先知道 INT_MAX, INT_MIN 這兩個東西
- 然後呼叫 dfs(root, max, min) 這樣下去，讓 node 檢查和 max, min value 的關係
- 如果比 max 大，或是比 min 小，就是錯誤
- 然後呼叫左子樹的時候，因為都要比左子樹大 dfs(root → left, root→val, min)，因此是這樣 call
- 反之右子樹 dfs(root → right, max, root→val)
- 然後兩者的 return value 需要 and，有人違反就是錯
- dfs 開頭需要判斷!root return true

## 100. Same Tree

- 這是基本的 DFS 題目，同時 visit 兩個 tree 看有沒有相等
- 基本上就是直接做 recursive
- 都是 nullptr return true，任一是 nullptr，而另一個不是，則 return false
- 然後檢查兩者 value 是否相等，不相等 return false
- 關鍵是 recursive 怎麼 call，左右子樹都要檢查，所以左右都要呼叫
    - 因為要把結果一路回傳到 root，所以左右子樹呼叫的結果，要用&&去算是否一樣，然後回傳

## 104. Maximum Depth of Binary Tree

- 這也是基本題，要算出樹高
- 遞迴的解法就是 max(左子樹高，右子樹高)
- 有兩種想法，一種是由上往下數高度，另一種是由下往上數高度
- 由上往下數就是，root 是 0，下一層是 1，一路看可以深入到第幾層
    - 所以 recursive 就會被深度當參數往下送
- 由下往上數就是，一路往下 call 到 nullptr，然後 return 0
    - 不是 nullptr 就是 return max(左右)+1

## 133. Clone Graph

- 這題的目標是要 deep clone 一個 graph，包含所有的 edge
- 這題先宣告一個 global `map<Node*, Node*>`，方便對應新舊的點
- dfs 一進去就先 new 一個新的點放到 map 裡面，因為所有要呼叫的點都是沒走過的點，並且在 function 最後 return new node
- 然後就開始對 neighbor 做 for loop
    - 如果有出現沒在 map 裡面的點，就對那個點做 dfs，然後把點放到 clone node 的 neighbor 中
    - 如果是有出現的點，那就單純放到 neighbor 中就好

## 207. Course Schedule

- 有 numCourses 堂課，有預備知識，就是要先修完 A 才能修 B，要檢查是不是可以全部課都修完
- 這題如果用 indegree == 0 的方式很容易找到答案
- 另外用 DFS 解的話就是找這個 graph 是不是 acyclic
- 首先先做出 Adjacency List
- 然後就使用 DFS 來遞迴
- 注意會需要一個 `vector<bool>` 來記錄走過的點，走到就先 mark 起來，然後再往下 call DFS
    - 如果在 DFS 的過程中發現有走到被 mark 的點，那就代表這是循環圖，沒有辦法修完
- 還需要一個 `vector<bool>` 做加速，因為不知道有幾個連通圖，所以每一個 node 都要當一次起點做 DFS，這樣太花時間了。
    - 所以使用一個 `vector<bool>` `Done`，當這個點走完，就把 Done 標記成 true
    - 每一個點要做 DFS 前，如果是 Done 就代表搜尋過了，不用再 DFS 一次

## 210. Course Schedule II

- 這題是 Course Schedule 的延伸，如果可以排出順序，就回傳順序，不能就回傳空的 vector
- DFS 的解法大同小異，基於上面的解法，再加上一個 order 去記錄順序
- 當 DFS 走到底的時候，把 node 放進 order vector 裡面
- 最後得到的是一組剛好反過來順序的 vector，reverse 後即是解答

## 226. Invert Binary Tree

- 這題就是每一層都要左右 swap
- 透過遞迴很簡單，就是先 swap，然後 recursive call 左右子樹，最後 return head
    - 不用管左右子樹的回傳值，因為用不到
- 另一個方法是 non-recursive
    - 就是用 stack 去實作，最外面先把 head push 進去 stack 裡面
- while 迴圈的判斷條件是 stack 不是空
    - 先把左右子樹都 push 進去 stack
    - 然後 swap 左右子樹
- 最後也是 return root
- non-recursive 的作法有一個小重點我犯錯過，就是從 stack 取了一個點後要馬上 pop
    - 如果不馬上 pop，等把左右子樹 push 進去就會出錯

## 235. Lowest Common Ancestor of a Binary Search Tree

- 給定一個 tree，兩個 node，要找出在這個 BST 中，兩個 node 的共同祖先
- 這題要充分利用 BST 的特性，也就是數字都是有被排序過的
    - node value 一定比所有左子樹大，一定比所有右子樹小
- 所以要利用這個特性，如果同時大於兩個 node，就往左子樹 DFS
    - 反之同時小於則往右子樹 DFS
- 不能移動就代表這個 node 就是共同的祖先

## 236. Lowest Common Ancestor of a Binary Tree

- 235 的延伸，給定一個 tree，兩個 node，要在這個 tree 中找到兩個 node 的共同祖先
- 一樣是 DFS 下去找，碰到 node 和兩個 node 任一 node 相同時，就回傳 node
- 然後左右子樹下去 DFS，檢查 return value
- 兩個都不是 nullptr，代表現在這個位置的 node 就是 return value
- 只有一個不是 nullptr，就把那個值回傳回去

## 572. Subtree of Another Tree

- 給定一個樹，以及一個子樹，要 return 子樹是不是樹的一部分(要完全相同，leaf 不同也不行)
- 最直白的想法就是利用 100 題的 same tree 的 function
- 然後對 tree 做 dfs，每個 node 再和 subtree 去執行 same tree
- 注意 subtree function 也要做 recursive
    - 一定要做!root 判斷，不然後面 access 到 root 如果是 nullptr 會出事
    - 然後對 root 和 subtree 做 same tree
    - 最後 recursive left and right tree
- 另一個有趣的字串解
    - 把樹用字串表示，也就是左右括號把樹包起來
    - 然後左右子樹用逗號分開，注意 nullptr 也要被字串化
    - 最後用字串比對去找 C++ string find ≠ string::npos