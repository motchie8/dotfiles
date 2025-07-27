local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"translate_to_english",
		fmt(
			[[
以下の文章を英語に翻訳してください。
            ]],
			{}
		)
	),
	s(
		"translate_to_english_with_nuance",
		fmt(
			[[
Please translate the following sentence into simple and natural English.
            ]],
			{}
		)
	),
	s(
		"translate_to_japanese",
		fmt(
			[[
以下の文章を日本語に翻訳してください。
            ]],
			{}
		)
	),
	s(
		"include_section",
		fmt(
			[[
>>> include

/path/**/*.py
            ]],
			{}
		)
	),
	s(
		"generate_code",
		fmt(
			[[
{} で {} するコードを生成してください。
以下のような機能を実現したいです。
```
* {}
```
            ]],
			{ i(1, "lang"), i(2, "target"), i(3, "example") }
		)
	),
	s(
		"generate_code_by_example",
		fmt(
			[[
{} の最新バージョンでは、以下のようなコードで {} を実装できます。

```
{}
```

上記を踏まえて、以下のリソースを実装するコードを生成してください。
* {}
            ]],
			{ i(1, "lang"), i(2, "target_type"), i(3, "example_code"), i(4, "target_resource") }
		)
	),
	s(
		"generate_flowchart",
		fmt(
			[[
以下のリソースを `mermaid` のflowchartで記述するためのコードを書いてください。

```
# Database(as nodes in a cyclindrical shape)
* {}

# Process(as default nodes)
* {}

# Dependent process
* {}
```
            ]],
			{ i(1, "database_name"), i(2, "process_name"), i(3, "direction") }
		)
	),
	s(
		"generate_service_comparison",
		fmt(
			[[
{} について調査しています。
他のサービスとの長所短所の比較と、使い方の例をまとめてください。
出力は以下のフォーマットに従い、簡潔にまとめてください。

```
# サービス名

## 概要
* サービスの概要を3~5行程度で簡潔にまとめる

| 機能 | できること | できないこと |
| --- | --- | --- |

## 他のサービスとの比較

| サービス名 | メリット | デメリット |
| --- | --- | --- |

## 使い方
サービスの使い方が伝わる簡単なサンプルコードを記述
```
            ]],
			{ i(1, "service") }
		)
	),
	s(
		"task_break_down",
		fmt(
			[[
業務で {} を実施する必要があります。
目標を達成するための必要な内容を細分化し、以下のフォーマットに従って整理してください。

```
## 概要
- タスクの概要

## 完了の定義
- 何をもってタスクが完了したとみなすかを記載する

## ToDo List
- [ ] 分割されたタスク: 時間の見積り(min): 期限

## ガントチャート
- 以下のような mermaid 記法でガントチャートを記載

gantt
    title A Gantt Diagram
    dateFormat YYYY-MM-DD
    section Section
        A task          :a1, 2014-01-01, 30d
        Another task    :after a1, 20d
    section Another
        Task in Another :2014-01-12, 12d
        another task    :24d
```
            ]],
			{ i(1, "task") }
		)
	),
	s(
		"generate_design_comparison",
		fmt(
			[[
{} を使って {} を実装したいです。
現在、以下の方法を検討しています。
メリットとデメリットを表にまとめて比較してください。
他にも良い方法があれば、適宜表に追加してください。

- 方法
```
- {}
- {}
```

- 出力表
```
| 方法 | 評価 | メリット | デメリット |
| --- | --- | --- | --- |
```
            ]],
			{ i(1, "service"), i(2, "function"), i(3, "method1"), i(4, "method2") }
		)
	),
	s(
		"generate_requirement_and_approach",
		fmt(
			[[
{} を使って {} を実装したいです。
現在、以下の要件を満たす方法を検討しています。
メリットとデメリットをmarkdownの表にまとめて比較してください。
他にも良い方法があれば、適宜表に追加してください。

- 要件
```
- {}
- {}
```

- 出力表
```
| 要件 | 実現方法 | メリット | デメリット |
| --- | --- | --- | --- |
```
            ]],
			{ i(1, "service"), i(2, "function"), i(3, "requirement1"), i(4, "requirement2") }
		)
	),
}
