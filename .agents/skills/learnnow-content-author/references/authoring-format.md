# Authoring format — hard compiler constraints

Authoritative source: `docs/ContentAuthoring.md` plus the compiler itself
(`Packages/LearnNowContentKit/Sources/`). This file is the checklist a writer needs
at hand; when the two disagree, the compiler wins.

## Directory shape

```text
ContentSource/
  learnnow.yml                  # only file with fixed name/meaning
  lessons/<lesson>/
    lesson.yml                  # manifest
    pages/*.md                  # one page per file
    cards.md
    tips.md
    assets/                     # optional local images
    _full-draft.md              # draft archive, never referenced
    _quality-report.md          # optional review archive, never referenced
```

Directory and file names carry no compile semantics except `learnnow.yml`. Only
files reachable from a manifest are compiled.

**Draft-file safety.** `lint --all` recursively discovers *only* `.yml`/`.yaml` files
whose top-level `format` is `learnnow.lesson-bundle/v1`. Markdown files that no
manifest references are never parsed. Therefore `_full-draft.md` and
`_quality-report.md` are safe; a stray `draft.yml` is not.

## IDs

- Must match `[A-Za-z0-9][A-Za-z0-9._-]*`, and be globally unique across routes,
  tracks, modules (lessons), pages, exercises, exercise options, cards, and tips.
- Explicit, never derived from titles. Never renamed or reused once published.
- Copy edits keep the ID; a real change in learning meaning that should reset FSRS
  memory gets a new ID.
- Deleting any stable entity (including a single quiz option) requires appending the
  old ID to `retiredIDs` in `learnnow.yml`. That list only grows; a retired ID can
  never come back and can never also be live.

## `learnnow.yml`

```yaml
format: learnnow.project/v1
schemaVersion: 2
releaseVersion: "2026.07.31.1"     # dot-separated UInt64 components, never decreases
locale: zh-Hans
primaryRouteID: datascience
minAppBuild: 1
publishedAt: "2026-07-28T00:00:00Z" # RFC 3339, a fixed release value, not "now"
retiredIDs: []

routes:
  - id: example-route
    title: 一门学科的入口
    subtitle: 三个词概括这条线
    systemImage: chevron.left.forwardslash.chevron.right
    accent: purple
    cta: 开始学习
    interactive: true
    tracks:
      - id: example-track
        title: 一条示例学习线
        lessons:
          - lessons/example-lesson/lesson.yml
```

Every ID in this file uses an `example-` prefix on purpose. **Do not copy them into a
real lesson** — many published IDs are already retired, and a retired ID that shows up
live again is a hard error.

- Order comes from array order. There is no `order` field in the author format.
- Track IDs are globally unique; one manifest mounts under exactly one Track.
- `interactive: false` routes are "coming soon" cards and hold no tracks.
- `requiredCapabilities` is always derived by the compiler; never write it.

### Closed value sets (frequent lint failures)

| Field | Allowed values |
|-------|----------------|
| `accent` (route/page/card/tip/callout/feedback) | `blue`, `pink`, `mint`, `purple`, `amber` |
| `tone` (callout/feedback) | `information`, `success`, `warning` |
| `kind` (quiz) | `singleChoice` |
| `systemImage` (route, tip) | `cpu`, `paintpalette`, `chevron.left.forwardslash.chevron.right`, `lightbulb`, `chart.bar.xaxis` |
| image extension | `png`, `jpg`, `jpeg`, `gif`, `webp` |

The `systemImage` allowlist is enforced in `ContentPolicy.allowedSystemImages`; any
other SF Symbol name is a hard error even if it exists in SF Symbols. Extending the
allowlist is an app-side change, not a content change.

### `defaults`

Declarable at project / route / track / lesson, merged in that order. Only `locale`,
`page.accent`, `card.accent`, `card.topic`, `tip.accent`, `tip.systemImage` are
inheritable. IDs, revisions, paths, order, prerequisites, XP, answers, and body text
must always be explicit. Unknown fields, type conflicts, and a locale different from
the project locale are errors. YAML anchors, aliases, and custom tags are rejected.

## `lesson.yml`

```yaml
format: learnnow.lesson-bundle/v1
id: example-lesson
title: 一句话说清本课在答什么
prerequisites: []                 # stable lesson IDs, never file paths
completion:
  xp: 20                          # must be positive
  message: 一句进入复习池的收口话。

pages:
  - id: example-page-1
    title: 这一页替学习者解决的那件事
    source: pages/first.md
    accent: purple
    revision: 1                   # positive integer
    objectives:
      - example.first.behaviour-name   # at least one, or lint errors
cards:
  - cards.md
tips:
  - tips.md
```

One author Lesson compiles to one completable Module; each `pages` entry compiles to
one Page. A module with no lessons, a page with no objectives, or a non-positive XP
value are all errors.

`objectives` are free-form stable strings; use dotted, lesson-scoped, behaviour-named
identifiers (`example.first.tell-two-things-apart`), one per page.

## Page Markdown

No YAML front matter. Body only. The block IR is a closed allowlist — anything not on
this list throws `block.unsupported` and fails the build:

| Block | Author syntax | Notes |
|-------|---------------|-------|
| paragraph | plain text | blank line between paragraphs |
| heading | `#`–`######` | levels 1–6 compile; authoring convention is `##`/`###` only |
| list | `-` or `1.` | **single level, one paragraph per item** |
| table | GFM pipe table | required header + separator; cell inline only; soft guide ≤4 columns |
| code | ` ```text ` fence | language is a free string; `text` for diagrams |
| callout | `@Callout(...) { }` | blocks inside, no `@Quiz` |
| image | `@Image(...)` | no body, `alt` mandatory |
| quiz | `@Quiz(...) { }` | `singleChoice` only |

### Inline (closed allowlist)

Inline markup is likewise closed — anything else is a hard error:

| Syntax | Compiles as | Authoring use |
|--------|-------------|----------------|
| `**strong**` | strong | 1～3 key phrases per `##` section — never whole sentences |
| `*emphasis*` | emphasis | light tone tilt; sparse; do not compete with bold |
| `` `code` `` | code | concrete tokens: example numbers, model-node labels, short technical nouns |
| plain text | text | default for ordinary prose |

**Do not** bold every noun, wrap full sentences in `**...**`, or sprinkle backticks on
ordinary Chinese prose ("backtick soup"). Missing emphasis (uniform grey prose with
zero anchors) and over-emphasis are both rubric defects — see
`references/quality-rubric.md` § C10 / C11 and `references/pedagogy.md` § 行内强调.

**There is no nested-list IR.** Concretely:

- A nested list (a list item containing a list, or two paragraphs in one item) →
  `list.unsupportedNesting`. Use `###` subsections or draw the hierarchy inside a
  fenced block.
- GFM pipe tables **are supported** in page Markdown. Prefer them for short
  comparisons once each object is established in a sentence (soft guide: ≤4
  columns; 3–5 judgment rows). Header row + separator are required. Alignment
  markers (`:---`, `:---:`, `---:`) and empty cells are allowed. Cell content may
  only use the inline allowlist above — no nested blocks, lists, or links inside
  cells. Do not put tables in Card / Tip / Feedback sources.

Also forbidden, all hard errors: raw HTML, links (including bare autolinks), inline
images, block quotes (`>`), thematic breaks, scripts, remote components.

```text
写不了                        改成
--------------------------    --------------------------
- 外层                        ### 小节标题 ＋ 单层列表，
  - 内层                      或把层级画进 fenced text 块

> 强调一句                    **关键短语**、`具体token` 或 @Callout
```

### Author-side budgets (rubric-enforced, not compiler-enforced)

The compiler happily accepts a page with eight quizzes, no headings, and 2000 字 of
unbroken prose. The rubric does not:

- **≤3 pages per Lesson**, 1～2 `objectives` per page;
- **≤2 `@Quiz` per page**, 1 (最多 2) `@Callout` per page;
- **2～4 `##` sections** and at least one fenced `text` block per page;
- roughly **250–450 汉字 of prose per page** — about three phone screens;
- paragraphs of **2～4 sentences / ~60–90 汉字**, never 3+ consecutive paragraphs
  without a structural break.

A page that is mostly unbroken prose (密密麻麻) is a 否决项. When the material does
not fit, add a **Lesson in the same Track**, never a longer page.

See `references/pedagogy.md` § 页内排版规范 and `references/quality-rubric.md`
§ 眯眼测试.

### Directives

```markdown
@Callout(title: "核心认知", tone: "warning", accent: "amber") {
一句可脱稿复述的洞见。
}

@Image(path: "assets/chart.png", alt: "必填替代文本", caption: "图 1")

@Quiz(id: "example-page-1.quiz", kind: "singleChoice") {
情境化的问句写在这里。

@Option(id: "example-p1-correct", correct: true) {
正确选项文本

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
可选的选项级解释，最多一个，且不带 when。
}
}

@Option(id: "example-p1-distractor") {
指向具体迷思概念的干扰项
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
指向原因，不只是"对了"。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
指出最可能的误解，并给一步可执行的检查。
}
}
```

Quiz rules the compiler enforces:

- exactly one `@Option(correct: true)`, at least two options with distinct IDs;
- both `when: "correct"` and `when: "incorrect"` feedback present, each non-empty;
- prompt must include at least one paragraph;
- `@Quiz` may not be nested inside `@Callout`;
- each exercise ID may be referenced by exactly one page block.

`@Callout` bodies accept normal blocks (no quizzes). `@Feedback`, `@Tip`, and
`@Highlight` bodies accept **paragraphs only** — no lists or code inside them.

`@Image` takes no body, and `alt` is mandatory. Images resolve relative to
`lesson.yml`, must stay inside the lesson directory, are 1 byte–8 MiB, and are
signature-checked against their extension. Compiled path becomes
`assets/<lessonID>/<relative-path>`.

## `cards.md`

Top level accepts `@Card` directives only.

```markdown
@Card(id: "example-card-1", revision: 1, sourcePage: "example-page-1", topic: "示例主题", accent: "purple", frontTitle: "提取用的提示词", frontSubtitle: "一句限定范围的副标题", backTitle: "核心判别") {
背面正文，纯段落。

@Highlight {
最容易忘的那一句判别点。
}
}
```

Required arguments: `id`, `revision`, `frontTitle`, `backTitle`; plus `topic` and
`accent` unless inherited from `defaults`. Body **and** exactly one `@Highlight` are
required. `sourcePage` is optional but must name a page of this same lesson.

## `tips.md`

Top level accepts `@Tip` directives only; body is paragraphs.

```markdown
@Tip(id: "example-tip-1", revision: 1, sourcePage: "example-page-1", title: "一句脱离课程也成立的提醒", systemImage: "lightbulb", accent: "purple") {
一句在首页闲逛时也能读懂的提醒。
}
```

Global tips referenced from `learnnow.yml` via `globalTips:` may not declare
`sourcePage`.

## Commands

```bash
# validate the published tree
swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource

# also validate unmounted draft bundles (emits lesson.unreferenced warnings)
swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource --all

# deterministic build output
swift run --package-path Packages/LearnNowContentKit learnnow-content build \
  --source ContentSource --output /tmp/learnnow-content

# preview bundle for the Debug app
swift run --package-path Packages/LearnNowContentKit learnnow-content preview \
  --source ContentSource --output .build/content-preview
```

Debug app preview: set the Run scheme environment variable
`LEARNNOW_CONTENT_PREVIEW_CATALOG` to the preview output directory (or directly to
its `CatalogV2.json`).

Syncing `LearnNow/Resources/CatalogV2.json` + `ContentManifest.json` + `assets/`
is a release step (see `docs/ContentAuthoring.md`); CI byte-compares them against a
fresh build, so either sync all three from one build or none.

`warning` exits successfully; `error` fails. CI additionally requires a
`releaseVersion` bump whenever the catalog, manifest metadata, or asset hashes
change, and fails on version regressions, deleted-but-not-retired IDs, shrinking
retirement lists, and revived retired IDs.
