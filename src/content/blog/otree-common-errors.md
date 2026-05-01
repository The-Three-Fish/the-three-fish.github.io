---
title: "oTree 常见报错合集：TemplateDoesNotExist、KeyError、NoReverseMatch"
description: "整理 oTree 初学者最常遇到的报错，按症状、原因和解决方式快速定位问题。"
image: "/images/blog-4.jpg"
date: 2026-05-01T11:00:00Z
draft: false
categories: ["oTree 入门系列"]
tags: ["oTree", "入门", "报错排查"]
---

学 oTree 的时候，报错不可怕，可怕的是不知道从哪里查。很多错误其实都来自几个固定原因：文件名不匹配、变量没定义、页面顺序不对、模板里写错变量名。

这篇按常见报错整理，适合出错时快速对照。

---

## 一、TemplateDoesNotExist

意思是 oTree 找不到页面对应的 HTML 模板。

常见原因：

- `Page` 类名和模板文件名不一致。
- 模板放错文件夹。
- app 名写错。
- 文件扩展名不是 `.html`。

如果页面类是：

```python
class Contribute(Page):
    pass
```

app 叫 `public_goods`，模板应该放在：

```text
public_goods/templates/public_goods/Contribute.html
```

检查顺序：先看 app 文件夹名，再看 `templates/app名/`，最后看 HTML 文件名是否和 Page 类完全一致。

---

## 二、KeyError

`KeyError` 通常表示你访问了一个不存在的 key。最常见场景是 `participant.vars`。

例如：

```python
player.treatment = player.participant.vars['treatment']
```

如果前面没有写入 `participant.vars['treatment']`，这里就会报错。

更稳妥的写法是：

```python
player.treatment = player.participant.vars.get('treatment', 'control')
```

但不要滥用默认值。正式实验中，如果 treatment 必须存在，最好回头检查为什么没有被正确分配。

---

## 三、NoReverseMatch

这个错误通常和页面跳转、URL、app 名有关。初学者最常见的原因是 `settings.py` 里 `app_sequence` 写了不存在的 app。

检查：

```python
SESSION_CONFIGS = [
    dict(
        name='demo',
        app_sequence=['public_goods', 'survey'],
        num_demo_participants=4,
    )
]
```

确认 `public_goods` 和 `survey` 都是真实存在的 app 文件夹，并且里面有合法的 oTree app 代码。

---

## 四、NameError

`NameError` 表示使用了没有定义的名字。

例如：

```python
player.payoff = endowment - player.contribution
```

如果 `endowment` 没有定义，就会报错。通常应该写成：

```python
player.payoff = C.ENDOWMENT - player.contribution
```

遇到 `NameError`，先检查拼写，再检查变量是否在当前作用域里。

---

## 五、AttributeError

`AttributeError` 通常表示对象上没有这个属性。

例如：

```python
player.contributions
```

但你在 `Player` 里定义的是：

```python
contribution = models.CurrencyField()
```

多了一个 `s` 就会出错。oTree 字段名、模板变量名、Python 变量名都建议保持简洁一致。

---

## 六、表单字段不显示

如果页面上没有出现输入框，检查 `form_model` 和 `form_fields`：

```python
class Decision(Page):
    form_model = 'player'
    form_fields = ['contribution']
```

同时确认 `Player` 里真的定义了这个字段：

```python
class Player(BasePlayer):
    contribution = models.CurrencyField(min=0, max=C.ENDOWMENT)
```

模板里也要有：

```html
{{ formfields }}
```

或者手动渲染具体字段。

---

## 七、WaitPage 一直卡住

等待页卡住通常有几种原因：

- 同组有人还没到等待页。
- 某个参与者退出了。
- 分组人数设置和实际参与人数不匹配。
- `PLAYERS_PER_GROUP` 不适合当前 session 人数。

测试时可以打开多个参与者链接，看是否有人停在前面页面。正式实验中，要提前设计退出处理方案，否则多人实验很容易被一个退出者卡住。

---

## 八、排错顺序

遇到报错时，建议按这个顺序查：

1. 看报错最后几行，找到具体文件和行号。
2. 检查拼写：类名、字段名、模板名、app 名。
3. 检查变量是否已经定义并赋值。
4. 检查页面是否加入 `page_sequence`。
5. 检查 `settings.py` 里的 `app_sequence`。

oTree 报错看起来长，但真正有用的信息通常在最后一屏。先定位文件和行号，再回到代码里查对应变量，效率会高很多。
