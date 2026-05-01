---
title: "oTree 多轮实验设计：round_number、in_rounds 和跨轮数据读取"
description: "讲解 oTree 多轮实验中如何设置轮数、读取历史选择、累计收益，并避免跨轮数据使用错误。"
image: "/images/blog-4.jpg"
date: 2026-05-01T08:00:00Z
draft: false
categories: ["oTree 入门系列"]
tags: ["oTree", "入门", "多轮实验"]
---

很多经济学实验不是只做一次决策，而是重复很多轮。比如重复囚徒困境、公共品博弈、拍卖、风险选择任务。oTree 对多轮实验支持很好，但初学者容易混淆“当前轮”和“历史轮”。

---

## 一、NUM_ROUNDS 决定轮数

轮数在 `C` 里设置：

```python
class C(BaseConstants):
    NAME_IN_URL = 'repeated_game'
    PLAYERS_PER_GROUP = 2
    NUM_ROUNDS = 10
```

设置为 10 后，同一个 app 会重复运行 10 轮。每一轮都有自己的 `Subsession`、`Group`、`Player` 数据。

---

## 二、round_number 是当前第几轮

在页面或函数里，可以通过 `player.round_number` 判断当前轮数。

```python
class Instructions(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == 1
```

说明页通常只在第一轮出现，结果页可能每轮都出现，最终总结页只在最后一轮出现：

```python
class FinalResults(Page):
    @staticmethod
    def is_displayed(player: Player):
        return player.round_number == C.NUM_ROUNDS
```

---

## 三、读取上一轮数据

如果要读取上一轮选择，可以用 `in_round()`：

```python
previous_player = player.in_round(player.round_number - 1)
previous_choice = previous_player.choice
```

使用前要先判断不是第一轮：

```python
if player.round_number > 1:
    previous_player = player.in_round(player.round_number - 1)
```

否则第一轮会去找第 0 轮，直接报错。

---

## 四、读取多轮历史

如果要读取从第 1 轮到当前轮的所有记录，可以用 `in_rounds()`：

```python
history = player.in_rounds(1, player.round_number)
total_payoff = sum(p.payoff for p in history)
```

如果只想读已经完成的历史轮，不包括当前轮：

```python
past_rounds = player.in_rounds(1, player.round_number - 1)
```

`in_all_rounds()` 可以读取这个 app 中该参与者的所有轮次：

```python
all_rounds = player.in_all_rounds()
```

但在实验进行中，未来轮次还没有填写数据，所以不要假设未来轮次字段已经有值。

---

## 五、累计收益怎么做

一种做法是每轮计算本轮 payoff，最后在最终页展示总收益：

```python
class FinalResults(Page):
    @staticmethod
    def vars_for_template(player: Player):
        total = sum(p.payoff for p in player.in_all_rounds())
        return dict(total_payoff=total)
```

如果你需要把累计收益导出成字段，可以在最后一轮写入：

```python
class FinalResults(Page):
    @staticmethod
    def before_next_page(player: Player, timeout_happened):
        player.total_payoff = sum(p.payoff for p in player.in_all_rounds())
```

前提是 `Player` 里定义了：

```python
total_payoff = models.CurrencyField()
```

---

## 六、分组是否每轮变化

多轮实验要提前决定：每轮重新随机分组，还是固定同组？

固定同组：

```python
def creating_session(subsession: Subsession):
    if subsession.round_number == 1:
        subsession.group_randomly()
    else:
        subsession.group_like_round(1)
```

每轮重组：

```python
def creating_session(subsession: Subsession):
    subsession.group_randomly()
```

这不是技术细节，而是实验设计的一部分。固定匹配和随机匹配会改变参与者策略，也会影响后续分析。

---

## 七、常见错误

第一，在第一轮读取上一轮数据。

第二，把当前轮和历史轮变量混在一起，导致展示了错误信息。

第三，重新随机分组后，还假设上一轮同组成员就是这一轮同组成员。

第四，只在最终页计算累计收益，但参与者没有到达最终页就退出，导致字段为空。

写多轮实验时，建议先画出每一轮需要显示什么、记录什么、读取什么历史。流程画清楚，代码会简单很多。
