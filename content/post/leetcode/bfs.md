---
title: "BFS 廣度優先搜尋"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "以 BFS/queue 走訪圖與樹,含 Clone Graph、Course Schedule II"
tags: ["leetcode", "bfs", "graph"]
categories: ["演算法"]
---

## 133. Clone Graph

- 這題的目標是要 deep clone 一個 graph，包含所有的 edge
- 這題先宣告一個 global `map<Node*, Node*>`，方便對應新舊的點
- 這題可以用 DFS 也可以用 BFS 解，畢竟都是要在圖走過一遍
- 那 BFS 就是使用 while loop，以及一個 queue
- 那首先一樣，在進入 while loop 之前，先把第一個 node，他對應的 clone node new 出來，new node 放到 map 中，然後舊的 node 放到 queue 裡面。
- 進入 while loop 後，就是取出一個 node，並且 for loop access node neighbor
    - 這時候要檢查一下，如果 map 沒有看到這個 node，就 new clone node
        - 然後也要放進 queue 裡面，因為這個 node 還沒有被走過
    - 把 new node 放到 clone node 的 neighbor 裡面

## 210. Courses Schedule II

- 這題的目標是排出選課順序，有修課擋修順序
- 使用的方法是把 topological sort 的觀念放進來
- 觀念是每一個 node 的 indegree==0 的時候，才執行他，然後把這個 node 的鄰居 indegree-1
- 和 BFS 混在一起的做法就是，在進入 queue 之前，就要先把可以執行的放進去
- 然後每次選取 node，把鄰居 indegree-1，如果變成 0，那就放進 queue 裡面
- 每個 node 執行完後，放到 order result
- 這組 order result 很自然的就是答案