---
name: learnnow-content-author
description: Author LearnNow lessons in ContentSource/ — write one coherent full draft first, then split it into at most three structured pages, plus cards and tips. Use when creating or revising LearnNow course content, adding a Lesson bundle, wiring routes/tracks in learnnow.yml, or fixing learnnow-content lint failures on authored content.
---

# LearnNow Content Author

Write teaching material for LearnNow: a Chinese-language (`zh-Hans`) iOS app whose
only content source of truth is `ContentSource/`, compiled by `learnnow-content` into
a strongly typed catalog.

Five rules dominate everything else:

1. **Draft first, split second.** Never write page files directly. Write one
   continuous lecture (`_full-draft.md`), then cut it into pages. This is what keeps
   a lesson from degenerating into six disconnected flashcards.
2. **少页、短段、有结构。** A Lesson is **at most 3 pages**, and a page is read on a
   phone: it must fit in **about three screen scrolls**. That means roughly
   **250–450 汉字 of prose** carried by frequent structural breaks — `##` sections,
   short paragraphs, a fenced `text` model, one `@Callout`. Six 150-字 taps is a
   defect; so is one 900-字 wall of text. Aim for **fewer words with more structure**.
3. **Never ship a wall of text.** 密密麻麻的连续段落 is a 否决项, not a style
   preference. Details: `references/pedagogy.md` § 页内排版规范.
4. **Vary the page with sparse inline emphasis.** Use `**bold**` for 1–3 key
   phrases per section (never whole sentences). Use `` `inline code` `` for
   concrete tokens: example numbers, model-node labels, short technical nouns.
   No bold-every-noun; no backtick soup on ordinary prose. Details:
   `references/pedagogy.md` § 行内强调, `references/authoring-format.md` § Inline.
5. **Absorb principles, never imitate voices.** The pedagogy references distill
   kernels from several excellent explainers. Reproducing their catchphrases,
   personas, or verbal tics is a defect, not a compliment. See
   `references/pedagogy.md` § 禁止表面模仿.

## Workflow (mandatory order)

```mermaid
flowchart LR
  brief[1 Brief 写作合同] --> fullDraft[2 完整讲义稿]
  fullDraft --> split[3 拆成 ≤3 页]
  split --> cardsTips[4 Cards 与 Tips]
  cardsTips --> lint[5 learnnow-content lint]
  lint --> review[6 教学质量评审]
  review -->|不通过| fullDraft
  review -->|通过| deliver[7 可预览交付]
```

Skipping a step is not allowed. In particular, do not fix a review finding by
patching a single page: fix it in the full draft and re-split, so the narrative
stays consistent.

### 1. Brief（写作合同）

Before writing, settle the contract below. Keep it in the chat or at the top of
`_full-draft.md`; it never ships. If you cannot fill every row, you do not yet know
what the lesson is about — and 概念预算 is where over-scoped lessons get caught.

| 项 | 要求 |
|----|------|
| **核心问题** | 一个真实问题，一句话，带问号。`了解 X` / `X 基础` 不是核心问题。 |
| **心智模型** | 一行写完全课要留下的模型：一条流程、一条分界线或一条判断规则。 |
| **学习者起点** | 可以假设什么？零基础课假设零术语，并列出你会在课内建立的前置。 |
| **终点行为** | 最多 3 条，用行为动词（"能判断同一串字节在不同约定下含义不同"，不是"了解编码"）。 |
| **概念预算** | 核心概念 1 个；必须掌握的支撑概念 2～4 个；只需识别 ≤5 个；延后到下一课的写清。 |
| **贯穿例子** | 一个具体对象，每页复用。现在就选定。 |
| **范围边界** | 「本课会讲」3 条 ＋「本课不讲」3 条。 |

概念预算超了就**拆成同一个 Track 里的下一个 Lesson**，既不靠多加一页硬塞，也不靠把
一页写长。**深度要靠多一课，不靠多一屏。**每个新术语首次出现时，作者心里必须已经给
它贴了标签：**掌握 / 识别 / 延后**。

### 2. Full draft (`_full-draft.md`)

One continuous, readable lecture in `zh-Hans`. Open with a question the learner can
feel, give the 30 秒答案 within the first 150 字, then advance one step per
paragraph. Constraints and structure: `references/pedagogy.md`.

The draft has a budget too: **约 1000–1300 汉字 of prose**, because it has to fit
into at most 3 pages of 250–450 字 each. A 2000-字 draft does not split into three
pages; it splits into three walls. Overrunning the draft budget means the 概念预算
overran — 拆成两个 Lesson.

The draft file lives inside the lesson directory with a leading underscore and is
**never** referenced by `lesson.yml`, so it never compiles. Underscore-prefixed
`.md` files are safe: the compiler only reads pages/cards/tips listed in a manifest,
and `lint --all` only discovers stray `.yml`/`.yaml` bundles. Never give a draft or
report file a `.yml` extension inside `ContentSource/`.

### 3. Split into pages（最多 3 页）

Cut the draft at **支撑概念簇** boundaries, not at every new term and not at a 字数
target. Three pages means three answers to "这一页替学习者解决了什么"; if you cannot
name three distinct jobs, use two pages.

Each page:

- covers **one cluster**: 1 个新的主概念 ＋ 最多 1 个紧邻的从属概念。紧邻的意思是第二个
  概念只有靠第一个才讲得清；隔着一层的两个概念放同页就是超载;
- declares **1～2 个 `objectives`**, one per cluster member, written as behaviours;
- runs roughly **250–450 汉字 of prose** plus structural blocks — 手机上约 3 屏，
  读完做完约 3～5 分钟;
- is **structured**: 2～4 个 `##` sections, at least one fenced `text` block, 1 个
  （最多 2 个）`@Callout`, single-level lists for genuinely parallel items;
- keeps paragraphs short: **2～4 句 / 约 60–90 汉字**，段与段之间留空行;
- uses **sparse inline emphasis**: `**bold**` on 1～3 key phrases per `##` section;
  `` `code` `` on concrete tokens (numbers, labels, short technical nouns) — not on
  ordinary prose nouns;
- carries **1～2 `@Quiz`**, never more than 2;
- continues the previous page's example and voice — no scenario switching.

「一整坨不分段的小字」是**否决项**，不是风格问题。排版硬要求见
`references/pedagogy.md` § 页内排版规范。

Splitting removes prose; that is the point. Anything that no longer fits either
compresses into a fenced block, or moves to **the next Lesson in the same Track**.
Never solve "内容还没讲完" by letting a page grow past three screens — 那只会把课变
成一堵墙。Do not silently drop the story beats that made the draft coherent: if a
beat matters and has no room, it is a Lesson of its own.

### 4. Cards and Tips

Cards and tips are the spaced-repetition surface, not a summary of the page. Only
include the discriminations that are easy to forget or easy to confuse. Rules:
`references/pedagogy.md` § 间隔复习.

### 5. Lint

From the repo root:

```bash
swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource

swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource --all
```

Zero `error` is the bar. Warnings are acceptable only when deliberate (an
intentionally card-less lesson, a draft bundle not yet mounted). Format is not
negotiable: `references/authoring-format.md` lists every hard constraint, including
the allowlists that are easy to trip over (`systemImage` is a five-value allowlist;
accents and tones are closed enums) and the blocks the IR simply does not have
(**GFM 表格与嵌套列表都是 hard error**).

### 6. Pedagogy review

Start with the 眯眼测试 in `references/quality-rubric.md`: look at each page's shape
without reading it. A uniform grey slab means a wall of text — fix the layout before
judging anything else. Then score the lesson against every line of the rubric. Any
否决项 or two 重大缺陷 sends the work back to step 2. Reviewing your own draft works better if
you read the pages in order, out loud, as a beginner, and stop at the first sentence
you would have to re-read. Then run 快速删减测试 on every block: 删掉它，核心问题还
答得出来吗？属于下一课吗？只是换了个说法吗？任一为「是」就删、合或移。

### 7. Deliver

Report: created paths, lint result, what changed across review rounds, remaining
risks, and how to preview. Preview commands: `docs/ContentAuthoring.md`.

## Mounting a lesson

A lesson is invisible until mounted in `ContentSource/learnnow.yml` under a Route →
Track. When adding content:

- Bump `releaseVersion` (dot-separated integers, must never go backwards) whenever
  the compiled catalog changes.
- Never rename or reuse a published ID; retire it in `retiredIDs` instead. Merging
  pages retires the old page IDs **and** their quiz and option IDs.
- A lesson manifest may be mounted in exactly one Track.
- Prefer adding a new Route over rewriting an existing one when the new material is
  a different subject.
- A Track is the unit that absorbs depth. Related lessons that would otherwise bloat
  each other belong side by side in one Track, in reading order — 一课一问，串成一条
  线，而不是一课讲完所有事。
- Deleting a lesson retires **every** ID it published: the lesson/module ID, page IDs,
  quiz IDs, every option ID, card IDs, and tip IDs.

## References

| File | Read it when |
|------|--------------|
| `references/authoring-format.md` | Writing or fixing any file under `ContentSource/` |
| `references/pedagogy.md` | Writing the draft, splitting pages, laying out a page, wording quizzes |
| `references/quality-rubric.md` | Reviewing a draft or a finished lesson |
| `examples/page-skeleton.md` | Shaping a single structured page |

Repo docs that outrank this skill on their own topics: `docs/ContentAuthoring.md`
(compiler and release), `docs/LearnNow-核心设计原则.md` (product rhythm). Where the
product doc's per-page rhythm and this skill's ≤3 页 / 三屏结构化页 budget disagree,
this skill wins for authoring: a lesson is 2～3 structured, scannable pages — neither
six thin taps nor three walls of text. When in doubt, cut words and add structure;
when the material still does not fit, add a Lesson, not a screen.
