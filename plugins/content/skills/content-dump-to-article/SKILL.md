---
name: content-dump-to-article
description: Turn a raw content dump (research notes, NotebookLM exports, infographics, transcripts) into a fact-checked, themed Medium-style article with an image plan. Use when the user pastes or uploads a long unstructured note plus optional reference images and says "make an article", "explore this in an article", "use this as reference", "content dump", or similar. Outputs the article (.md), an image plan with placements and generation prompts, and a list of factual corrections found during verification.
---

# Content Dump → Article

Convert a raw research dump into a publication-ready article. The dump is **reference material, not draft text**: always re-research, fact-check, and rewrite from scratch in the writer's voice.

## Workflow

### 1. Parse the dump
Identify: the core story or event, the theme or metaphor the writer is reaching for (film, cricket, classical literature, a sport, a journey), claims with numbers, dates or quotes, any attached infographics, and cross-references to the writer's earlier pieces ("we wrote about X earlier").

### 2. Clarify (at most 3–4 questions)
Ask only what the dump doesn't answer: target length (default ~1,500 words / 6-minute read), links to earlier articles to cross-reference, and anything genuinely ambiguous about angle or audience. If the writer has already chosen a theme, refine it rather than asking about it.

### 3. Fact-check everything (non-negotiable)
Web-search every load-bearing claim: dates, valuations, percentages, quotes, names, page counts, partner counts. Content dumps, especially NotebookLM outputs, routinely contain small errors. Rules:

- Only verified facts go in the article; link each to its source inline (Medium style).
- Keep a running **corrections list**: every discrepancy between the dump/images and verified sources (e.g. "dump says 150 partners; source says ~50").
- Quotes must be exact and attributed; if a quote can't be verified, drop it.
- If a claim can't be verified either way, leave it out or mark it clearly as unverified.

### 4. Write the article
- **Voice:** match the writer. If they have a saved writing-style profile or skill, use it. Otherwise default to first person, authoritative but warm, prose over bullets, specific numbers over hand-waving, no corporate speak or hype words, and the spelling conventions the writer uses (e.g. Indian or British English).
- **Theme discipline:** the chosen metaphor must open the piece, recur at each act transition, and close the loop in the final paragraph with elevated meaning. Keep any structural framework invisible to the reader.
- **"Simple but not too simple":** explain each technical mechanism in one accessible line plus one concrete analogy; cut technical sidebars that don't serve the narrative.
- Insert `**[IMAGE n: description — placement]**` markers where visuals belong.
- Cross-references: link inline if a URL was provided; otherwise insert `**[LINK TO PREVIOUS ARTICLE]**` and tell the writer.
- Medium formatting: short paragraphs, strategic subheads, an italic dek under the title, and an ending with a call to action or a provocative question.

### 5. Produce the image plan (separate file)
For each `[IMAGE n]` marker:
- **Status:** reuse an attached image as-is, adapt or crop it, or create new.
- For attached infographics: judge density (NotebookLM exports are usually too text-dense for a Medium column; recommend cropping to one panel) and flag any factual errors baked into them.
- For new images: a complete generation prompt (style, palette matching the theme, aspect ratio: hero ~1600×840, inline ~1400×700), and a note when text-heavy cards should be made in a design tool or code instead of generative AI, which mangles text.
- Alt text for every image.
- List attached images *not* to use, with reasons.

If the writer keeps images in an assets folder, download any reusable images there and reference them by filename in the markers.

### 6. Deliver
Three outputs: `<topic>-article.md`, `<topic>-image-plan.md`, and the corrections list (in the image plan or the reply). Then a 2–3 sentence summary: what was verified, what was corrected, and what needs the writer's input (links, placeholders).

## Quality bar
Before delivering, check: every factual sentence traceable to a source; theme present at the open, the transitions and the close; no framework mechanics visible; no unexplained jargon; placeholders flagged to the writer; corrections list complete.
