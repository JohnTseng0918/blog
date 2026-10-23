---
title: "Topological Sort 拓撲排序"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "以 indegree 拓撲排序判斷可否修完課程,Course Schedule"
tags: ["leetcode", "topological-sort", "graph"]
categories: ["演算法"]
---

## 207. Courses Schedule

- 有 numCourses 堂課，有預備知識，就是要先修完 A 才能修 B，要檢查是不是可以全部課都修完
- 每一堂課都是一個 node，只要有其他 node 指向這個 node，就是 indegree + 1
- 計算出所有課程的 indegree 之後，就開始演算法
- 把所有 indegree == 0 的找出來，代表他們沒有 dependency or dependency 被消除了
- 然後這個 node 的 adjlist 指到的所有 node，將他們的 indegree - 1
- 直到沒有 indegree == 0 的可以找，如果全部都是 0，return true，如果還有非 0，則 return false