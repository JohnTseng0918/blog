---
title: "Topological Sort 拓撲排序"
date: 2026-08-15
draft: false
description: "以 indegree 拓撲排序判斷可否修完課程,Course Schedule"
tags: ["leetcode", "topological-sort", "graph"]
categories: ["演算法"]
---

## 207. Courses Schedule

- 有numCourses堂課，有預備知識，就是要先修完A才能修B，要檢查是不是可以全部課都修完
- 每一堂課都是一個node，只要有其他node指向這個node，就是indegree + 1
- 計算出所有課程的indegree之後，就開始演算法
- 把所有indegree == 0的找出來，代表他們沒有dependency or dependency被消除了
- 然後這個node的adjlist指到的所有node，將他們的indegree - 1
- 直到沒有indegree == 0的可以找，如果全部都是0，return true，如果還有非0，則return false