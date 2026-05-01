---
title: "oTree 页面流程控制：is_displayed、before_next_page 和 WaitPage"
description: "讲清楚 oTree 页面什么时候显示、什么时候跳过、如何保存中间状态，以及 WaitPage 如何同步一组参与者。"
image: "/images/blog-4.jpg"
date: 2026-05-01T06:00:00Z
draft: false
categories: ["oTree 入门系列"]
tags: ["oTree", "入门", "页面流程"]
---

写 oTree 实验时，最容易卡住的地方之一是页面流程：为什么某个页面没有出现？为什么参与者被卡在等待页？为什么下一页拿不到刚刚填写的数据？

这篇只讲三个最常用的工具：`is_displayed`、`before_next_page` 和 `WaitPage`。掌握它们之后，大多数实验流程都能写清楚。

---

## 一、page_sequence 决定基础顺序

每个 app 的最后通常会有：

```python
page_sequence = [Introduction, Decision, Results]
```

这表示参与者会按顺序经过 `Introduction`、`Decision`、`Results`。但真实实验里，不是每个人都看到同样页面，所以还需要条件判断。

---

## 二、is_displayed：决定页面是否出现

`is_displayed` 用来控制页面是否显示。比如只有处理组参与者看到某个说明页：

```python
class TreatmentInfo(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.treatment == 'high'
```

返回 `True` 就显示，返回 `False` 就跳过。常见用途包括：

- 只让某个角色看到页面，例如买家页、卖家页。
- 只在第一轮显示说明页。
- 根据 treatment 显示不同材料。
- 问卷里根据上一题答案决定是否追问。

例如只在第一轮显示说明：

```python
class Instructions(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == 1
```

注意：被跳过的页面不会执行该页面的表单提交逻辑，也不会进入 `before_next_page`。

---

## 三、before_next_page：离开页面前做事

`before_next_page` 会在参与者点击下一页、表单验证通过之后执行。适合用来计算结果、写入变量、设置后续页面需要用的数据。

```python
class Decision(Page):
    form_model = 'player'
    form_fields = ['contribution']

    @staticmethod
    def before_next_page(player: Player, timeout_happened):
        player.kept = C.ENDOWMENT - player.contribution
```

它适合做这些事：

- 根据表单输入计算 payoff 或中间变量。
- 记录是否超时。
- 把当前选择写入 `participant.vars`，供后续 app 使用。
- 在某一页结束后更新组内状态。

不建议把所有实验逻辑都塞进 `before_next_page`。如果是组内统一计算，经常应该放到 `WaitPage.after_all_players_arrive`。

---

## 四、WaitPage：等同组成员到齐

多人实验通常需要同步。例如公共品博弈里，所有人提交贡献后，系统才能计算组内总贡献。

```python
class ResultsWaitPage(WaitPage):
    @staticmethod
    def after_all_players_arrive(group: Group):
        players = group.get_players()
        group.total_contribution = sum(p.contribution for p in players)
        for p in players:
            p.payoff = C.ENDOWMENT - p.contribution + group.total_contribution / C.PLAYERS_PER_GROUP
```

`WaitPage` 的意思是：参与者到这里后先等着，等同组所有人都到达，再执行 `after_all_players_arrive`，然后一起进入下一页。

---

## 五、常见错误

第一，把组内计算写在某个玩家的 `before_next_page` 里。这样可能出现先后顺序问题，因为其他玩家还没提交。

第二，在 `is_displayed` 里访问还没有定义的变量。比如 treatment 还没赋值，就用 `player.treatment` 判断。

第三，忘记把 `WaitPage` 放进 `page_sequence`。定义了类但没有加入顺序，页面不会执行。

---

## 六、推荐写法

一个清晰的多人实验流程通常长这样：

```python
page_sequence = [
    Instructions,
    Decision,
    ResultsWaitPage,
    Results,
]
```

页面是否显示交给 `is_displayed`，个人提交后的处理交给 `before_next_page`，组内统一计算交给 `WaitPage.after_all_players_arrive`。这样代码边界清楚，后面排错也更容易。
