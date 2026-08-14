---
title: "DFS 深度優先搜尋"
date: 2026-08-15
draft: false
description: "以 DFS/遞迴解樹與圖,含 BST 驗證、LCA、Course Schedule 等"
tags: ["leetcode", "dfs", "tree", "graph", "binary-tree"]
categories: ["演算法"]
---

## 98. Validate Binary Search Tree

- 給定一棵樹，必須驗證他是不是BST
    - BST代表左子樹都要嚴格小於node，右子樹也要嚴格大於node
- 那這題就是要先知道INT_MAX, INT_MIN這兩個東西
- 然後呼叫dfs (root , max, min) 這樣下去，讓node檢查和max, min value的關係
- 如果比max大，或是比min小，就是錯誤
- 然後呼叫左子樹的時候，因為都要比左子樹大dfs(root → left, root→val, min)，因此是這樣call
- 反之右子樹dfs(root → right, max, root→val)
- 然後兩者的return value需要and，有人違反就是錯
- dfs開頭需要判斷!root return true

## 100. Same Tree

- 這是基本的DFS題目，同時visit兩個tree看有沒有相等
- 基本上就是直接做recursive
- 都是nullptr return true，任一是nullptr，而另一個不是，則return false
- 然後檢查兩者value是否相等，不相等return false
- 關鍵是recursive怎麼call，左右子樹都要檢查，所以左右都要呼叫
    - 因為要把結果一路回傳到root，所以左右子樹呼叫的結果，要用&&去算是否一樣，然後回傳

## 104. Maximum Depth of Binary Tree

- 這也是基本題，要算出樹高
- 遞迴的解法就是max(左子樹高，右子樹高)
- 有兩種想法，一種是由上往下數高度，另一種是由下往上數高度
- 由上往下數就是，root是0，下一層是1，一路看可以深入到第幾層
    - 所以recursive就會被深度當參數往下送
- 由下往上數就是，一路往下call 到nullptr，然後return 0
    - 不是nullptr就是return max(左右)+1

## 133. Clone Graph

- 這題的目標是要deep clone一個graph，包含所有的edge
- 這題先宣告一個global map<Node*, Node* >，方便對應新舊的點
- dfs一進去就先new一個新的點放到map裡面，因為所有要呼叫的點都是沒走過的點，並且在function最後return new node
- 然後就開始對neighbor做for loop
    - 如果有出現沒在map裡面的點，就對那個點做dfs，然後把點放到clone node的neighbor中
    - 如果是有出現的點，那就單純放到neighbor中就好

## 207. Course Schedule

- 有numCourses堂課，有預備知識，就是要先修完A才能修B，要檢查是不是可以全部課都修完
- 這題如果用 indegree == 0 的方式很容易找到答案
- 另外用DFS解的話就是找這個graph是不是acyclic
- 首先先做出Adjacency List
- 然後就使用DFS來遞迴
- 注意會需要一個vector<bool> 來記錄走過的點，走到就先mark起來，然後再往下call DFS
    - 如果在DFS的過程中發現有走到被mark的點，那就代表這是循環圖，沒有辦法修完
- 還需要一個vector<bool> 做加速，因為不知道有幾個連通圖，所以每一個node都要當一次起點做DFS，這樣太花時間了。
    - 所以使用一個vector<bool> Done，當這個點走完，就把Done標記成true
    - 每一個點要做DFS前，如果是Done就代表搜尋過了，不用再DFS一次

## 210. Course Schedule II

- 這題是Courses Schedule的延伸，如果可以排出順序，就回傳順序，不能就回傳空的vector
- DFS的解法大同小異，基於上面的解法，再加上一個order去記錄順序
- 當DFS走到底的時候，把node放進order vector裡面
- 最後得到的是一組剛好反過來順序的vector，reverse後即是解答

## 226. Invert Binary Tree

- 這題就是每一層都要左右swap
- 透過遞迴很簡單，就是先swap，然後recursive call 左右子樹，最後return head
    - 不用管左右子樹的回傳值，因為用不到
- 另一個方法是non-recursive
    - 就是用stack去實作，最外面先把head push進去stack裡面
- while迴圈的判斷條件是stack不是空
    - 先把左右子樹都push進去stack
    - 然後swap左右子樹
- 最後也是return root
- non-recursive的作法有一個小重點我犯錯過，就是從stack取了一個點後要馬上pop
    - 如果不馬上pop，等把左右子樹push進去就會出錯

## 235. Lowest Common Ancestor of a Binary Search Tree

- 給定一個tree，兩個node，要找出在這個BST中，兩個node的共同祖先
- 這題要充分利用BST的特性，也就是數字都是有被排序過的
    - node value一定比所有左子樹大，一定比所有右子樹小
- 所以要利用這個特性，如果同時大於兩個node，就往左子樹DFS
    - 反之同時小於則往右子樹DFS
- 不能移動就代表這個node就是共同的祖先

## 236. Lowest Common Ancestor of a Binary Tree

- 235的延伸，給定一個tree，兩個node，要在這個tree中找到兩個node的共同祖先
- 一樣是DFS下去找，碰到node和兩個node任一node相同時，就回傳node
- 然後左右子樹下去DFS，檢查return value
- 兩個都不是nullptr，代表現在這個位置的node就是return value
- 只有一個不是nullptr，就把那個值回傳回去

## 572. Subtree of Another Tree

- 給定一個樹，以及一個子樹，要return子樹是不是樹的一部分(要完全相同，leaf不同也不行)
- 最直白的想法就是利用100題的same tree的function
- 然後對tree做dfs，每個node在和subtree去執行same tree
- 注意subtree function也要做recursive
    - 一定要做!root判斷，不然後面access到root如果是nullptr會出事
    - 然後對root和subtree做same tree
    - 最後recursive left and right tree
- 另一個有趣的字串解
    - 把樹用字串表示，也就是左右括號把樹包起來
    - 然後左右子樹用逗號分開，注意nullptr也要被字串化
    - 最後用字串比對去找 c++ string find ≠ string::npos