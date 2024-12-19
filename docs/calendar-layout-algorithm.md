# 日历日程排列算法

## 概述

日历中重叠日程的视觉排列是一个经典的 **区间划分 (Interval Partitioning)** 问题。目标是：在一天/一周的时间轴上，将可能重叠的多个事件水平排列，使得所有事件同时可见且不遮盖。

飞书、Google Calendar、Outlook 等主流日历应用采用相同的核心算法——**贪心列打包 (Greedy Column Packing)**。

---

## 算法流程（3 步）

### 第 1 步：按开始时间排序

将所有日程按开始时间升序排列。开始时间相同则按结束时间升序，确保处理顺序确定。

```
sorted = events.sort((a, b) => a.start - b.start || a.end - b.end)
```

### 第 2 步：重叠分组

扫描排序后的列表，识别出互相重叠的事件组（传递性闭合）：

- 维护 `groupEndTime` = 当前组中所有事件最晚的结束时间
- 如果下一个事件的 `start < groupEndTime`，属于当前组
- 当 `start >= groupEndTime`，当前组结束，开启新组

```
groups = []
currentGroup = []
groupEndTime = 0

for event in sorted:
  if event.start >= groupEndTime:
    if currentGroup is not empty:
      groups.append(currentGroup)
    currentGroup = [event]
    groupEndTime = event.end
  else:
    currentGroup.append(event)
    groupEndTime = max(groupEndTime, event.end)

groups.append(currentGroup)
```

不同组之间在时间轴上完全不相交，因此各组独立布局。

### 第 3 步：组内列分配

每组内，使用贪心算法将事件分配到最小数量的列中：

- 维护 `columns` 数组，每列记录该列最新事件的结束时间
- 对于每个事件，找到第一个 `column.endTime <= event.start` 的列（即该列最后一个事件已结束）
- 如果找到，放入该列并更新 `column.endTime = event.end`
- 如果没找到（所有列当前都有活动事件），创建新列

```
columns = []  // 每列最新的结束时间

for event in group:
  placed = false
  for i, endTime in columns:
    if endTime <= event.start:
      columns[i] = event.end
      event.columnIndex = i
      placed = true
      break
  if not placed:
    columns.append(event.end)
    event.columnIndex = len(columns) - 1

event.totalColumns = len(columns)
```

这是一种贪心最优解——对于日历数据（重叠数通常 ≤ 5），贪心算法与最优解一致。

### 第 4 步：计算位置

每个事件的 CSS/渲染坐标：

```
width  = 1 / totalColumns
left   = columnIndex / totalColumns
top    = startTime.toMinutes() * heightPerMinute
height = (endTime - startTime).toMinutes() * heightPerMinute
```

---

## 示例

```
时间    事件
8:00    ┌────────┐
        │ 会议 A  │
9:00    │ (8:30  │
        │ -10:30)│──┐
9:30    └────────┘  │  ┌────────┐
                    │  │ 会议 C  │
10:00  ┌────────┐   │  │(9:30   │
       │ 会议 B  │   │  │-10:30) │
10:30  │(9:00   │   │  └────────┘
       │-10:00) │   │
       └────────┘   │
                    │
11:00               │  ┌────────┐
                    └──│ 会议 D  │
                       │(10:20  │
                       │-11:20) │
                       └────────┘
```

分组结果：
- **组 1**（8:30-11:20）：会议 A, B, C, D → 互相重叠（传递性），需要 3 列
- `A(0,3)`, `B(1,3)`, `C(2,3)`, `D(1,3)`（columnIndex, totalColumns）

每个事件宽度 = 1/3，列依次摆放。

---

## 当前项目实现

项目中使用的 `infinite_calendar_view` 包的 `SideEventArranger` 实现了上述算法：

| 组件 | 路径 | 说明 |
|------|------|------|
| `SideEventArranger` | 包内 `src/events/side_events_arranger.dart` | 贪心列分配算法 |
| `SimpleEventArranger` | 包内 `src/events/simple_events_arranger.dart` | 不处理重叠，垂直堆叠 |
| `EventArranger` | 包内 `src/events/event_arranger.dart` | 抽象基类，定义 `arrange()` 接口 |
| `EventsPlanner` | 包内 `src/events_planner.dart` | 周/日视图主组件 |
| 自定义页面 | `buzzing/lib/page/calendar/` | 14 个文件，均委托给 `infinite_calendar_view` |

项目未实现自定义排列算法，全部委托给第三方包 `infinite_calendar_view: ^2.7.0`（实际使用 v2.10.1）。

---

## 优化方向

若需要替代第三方包，自定义实现要点：

1. **冲突检测传递性** — 需要构建完整的冲突图，不能仅检查相邻事件
2. **堆叠优化** — 填充短事件到已结束事件下方，减少列数（如飞书处理「会议 A 下方放会议 D」的场景）
3. **跨天事件** — 分段处理，开始日显示部分，中间日全天显示，结束日显示部分
4. **拖拽交互** — 拖拽时需要保持列分配的稳定性
5. **水平滚动/缩放** — 不同时间粒度的列宽自适应

---

## 参考资料

- [Google Calendar Day View Layout](https://dev.to/arghya_majumder/google-calendar-day-view-42a0) — 4 步算法详解
- [FullCalendar event-placement.ts](https://github.com/fullcalendar/fullcalendar) — 开源实现参考
- [TOAST UI Calendar](https://ui.toast.com/tui-calendar) — 分层布局 + 碰撞检测
- RFC 5545 — iCalendar 重复规则标准
