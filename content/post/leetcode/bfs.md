---
title: "BFS 廣度優先搜尋"
date: 2026-08-15
draft: false
description: "以 BFS/queue 走訪圖與樹,含 Clone Graph、Course Schedule II"
tags: ["leetcode", "bfs", "graph"]
categories: ["演算法"]
---

## 133. Clone Graph

- 這題的目標是要deep clone一個graph，包含所有的edge
- 這題先宣告一個global map<Node*, Node* >，方便對應新舊的點
- 這題可以用DFS也可以用BFS解，畢竟都是要在圖走過一遍
- 那BFS就是使用while loop，以及一個queue
- 那首先一樣，在進入while loop之前，先把第一個node，他對應的clone node new出來，new node放到map中，然後舊的node放到queue裡面。
- 進入while loop後，就是取出一個node，並且for loop access node neightbor
    - 這時候要檢查一下，如果map沒有看到這個node，就new clone node
        - 然後也要放進queue裡面，因為這個node還沒有被走過
    - 把new node放到clone node的neighbor裡面

## 210. Courses Schedule II

- 這題的目標是排出選課順序，有修課擋修順序
- 使用的方法是把topological sort的觀念放進來
- 觀念是每一個node的indegree==0的時候，才執行他，然後把這個node的鄰居indegree-1
- 和BFS混在一起的做法就是，在進入queue之前，就要先把可以執行的放進去
- 然後每次選取node，把鄰居indegree-1，如果變成0，那就放進queue裡面
- 每個node執行完後，放到order result
- 這組order result很自然的就是答案