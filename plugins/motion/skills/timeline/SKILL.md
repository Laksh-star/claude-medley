---
name: "timeline"
description: "Animate a milestone story as a vertical 9:16 MP4: a headline, then a diagonal timeline draws itself while dated milestone cards land one by one, the last highlighted. Use for /timeline."
---

# /timeline: from a garage to 31 countries

On a bright, airy background, a small mono eyebrow and a bold headline appear ("From a garage to **31 countries**", the key words in blue). A blue spine then draws diagonally down the frame; as it reaches each year, a dot pops, the year label fades in, and a white milestone card (icon, year, title, one-line detail) slides in beside it. The final milestone lands as a blue highlighted card and gets a small pulse. Output: 720×1280 MP4, 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

Good for: company or product origin stories, a career journey, project histories, "how we got here" anniversary posts.

## 1. Get the content

The user usually pastes a headline (e.g. "From a garage to 31 countries") and then types /timeline. Map it into CONFIG:

- `eyebrow`: a short mono label (name · range)
- `title`: the headline, with the words to highlight wrapped in `[[ ]]`; keep it to two lines (≤ ~34 characters)
- `milestones`: 3–6 rows `[year, title, detail]`, oldest first; the last one is highlighted. Titles ≤ 26 characters, details ≤ 36.

Rules:
- Milestones are factual claims. Use the user's dates and events; if they give only the headline, ask for the milestones. Don't fill gaps with plausible-sounding events.
- Years can be any short label ("2016", "Q3 '24", "Day 1").

## 2. Set up the project

```bash
P=timeline-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/inter @fontsource/jetbrains-mono
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
cp node_modules/@fontsource/inter/files/inter-latin-{400,600,800}-normal.woff2 \
   node_modules/@fontsource/jetbrains-mono/files/jetbrains-mono-latin-{400,500}-normal.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (`--accent` in `:root` sets the highlight colour).

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=720, height=1280" />
<script src="gsap.min.js"></script>
<style>
@font-face{font-family:Inter;src:url(fonts/inter-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:Inter;src:url(fonts/inter-latin-600-normal.woff2) format("woff2");font-weight:600}
@font-face{font-family:Inter;src:url(fonts/inter-latin-800-normal.woff2) format("woff2");font-weight:800}
@font-face{font-family:Mono;src:url(fonts/jetbrains-mono-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:Mono;src:url(fonts/jetbrains-mono-latin-500-normal.woff2) format("woff2");font-weight:500}
:root{--bg:#f3f4f7;--ink:#101216;--dim:#5b616b;--line:#c9cdd4;--accent:#1d4ed8;--card:#ffffff}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--bg)}
#root{position:relative;width:720px;height:1280px;overflow:hidden;background:radial-gradient(ellipse 80% 60% at 70% 40%,#ffffff 0%,var(--bg) 70%);font-family:Inter,sans-serif;color:var(--ink)}
#stage{position:absolute;inset:0;transform-origin:50% 40%}
#eyebrow{position:absolute;left:48px;top:120px;display:flex;align-items:center;gap:10px;font:500 15px Mono,monospace;letter-spacing:.1em;text-transform:uppercase;color:var(--dim)}
#eyebrow i{width:12px;height:12px;border-radius:3px;background:var(--ink);display:block}
#title{position:absolute;left:46px;top:156px;width:640px;font:800 50px/1.06 Inter,sans-serif;letter-spacing:-.03em}
#title em{font-style:normal;color:var(--accent);white-space:nowrap}
#line{position:absolute;inset:0}
.yr{position:absolute;font:500 22px Mono,monospace;color:#555b65;text-align:right;width:90px}
.yr.last{color:var(--ink);font-weight:500}
.card{position:absolute;width:380px;background:var(--card);border-radius:16px;padding:16px 18px;display:flex;gap:14px;align-items:flex-start;box-shadow:0 14px 34px rgba(16,18,22,.10),0 2px 6px rgba(16,18,22,.06)}
.card .ic{width:44px;height:44px;border-radius:12px;background:#eef0f4;flex:none;display:flex;align-items:center;justify-content:center}
.card .y{font:500 14px Mono,monospace;color:var(--dim);letter-spacing:.06em}
.card .t{font:600 21px/1.2 Inter,sans-serif;margin-top:3px}
.card .s{font:400 16px/1.35 Inter,sans-serif;color:var(--dim);margin-top:3px}
.card.hi{background:var(--accent);color:#fff;box-shadow:0 20px 44px rgba(29,78,216,.35)}
.card.hi .y,.card.hi .s{color:#dbe4ff}.card.hi .ic{background:rgba(255,255,255,.18)}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <div id="stage" class="clip" data-start="0" data-duration="8" data-track-index="0">
  <div id="eyebrow"><i></i><span id="eb"></span></div>
  <div id="title"></div>
  <svg id="line" viewBox="0 0 720 1280" data-layout-ignore></svg>
  <div id="items"></div>
 </div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  eyebrow: "Northlight · 2016 → now",
  title: "From a garage to [[31 countries]]",   // [[ ]] marks the highlighted words
  // [year, title, one-line detail] — oldest first, 3 to 6 items; the last one is highlighted
  milestones: [
    ["2016", "A lamp in a garage", "Prototype one, made from offcuts"],
    ["2018", "First 500 orders", "Pre-order sold out in a week"],
    ["2021", "The Arc ships worldwide", "Now shipping to 31 countries"],
    ["2024", "Copenhagen studio opens", "40 people, one long table"]
  ]
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s), NS = "http://www.w3.org/2000/svg";
const esc = s => s.replace(/[&<>]/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;"}[c]));
$("#eb").textContent = C.eyebrow; $("#title").innerHTML = esc(C.title).replace(/\[\[(.+?)\]\]/, "<em>$1</em>");
// diagonal spine from below the title to the bottom; milestones spaced evenly along it
const titleBottom = 156 + $("#title").offsetHeight, N = C.milestones.length;
const A = [150, titleBottom + 70], B = [250, 1180];
const at = f => [A[0] + (B[0] - A[0]) * f, A[1] + (B[1] - A[1]) * f];
const svg = $("#line"), mk = (t, a) => { const e = document.createElementNS(NS, t); for (const k in a) e.setAttribute(k, a[k]); svg.appendChild(e); return e; };
mk("line", {x1: A[0], y1: A[1], x2: B[0], y2: B[1], stroke: "#e2e5ea", "stroke-width": 4, "stroke-linecap": "round"});
const spine = mk("line", {x1: A[0], y1: A[1], x2: B[0], y2: B[1], stroke: "var(--accent)", "stroke-width": 4, "stroke-linecap": "round"});
const spineLen = Math.hypot(B[0] - A[0], B[1] - A[1]); spine.style.strokeDasharray = spineLen + 6; spine.style.strokeDashoffset = spineLen + 6;
const icons = [
  '<circle cx="11" cy="11" r="5" fill="none" stroke="currentColor" stroke-width="2.2"/><path d="M11 1v3M11 18v3M1 11h3M18 11h3" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>',
  '<path d="M3 7l8-4 8 4v9l-8 4-8-4z M3 7l8 4 8-4 M11 11v9" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"/>',
  '<circle cx="11" cy="11" r="8.5" fill="none" stroke="currentColor" stroke-width="2"/><path d="M2.5 11h17M11 2.5c3 3 3 14 0 17M11 2.5c-3 3-3 14 0 17" fill="none" stroke="currentColor" stroke-width="1.8"/>',
  '<path d="M11 21s-7-6.2-7-11.5a7 7 0 0 1 14 0C18 14.8 11 21 11 21z" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="11" cy="9.5" r="2.5" fill="currentColor"/>',
  '<path d="M3 17l5-5 4 4 7-8" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>',
  '<rect x="3" y="3" width="16" height="16" rx="4" fill="none" stroke="currentColor" stroke-width="2"/><path d="M7 11l3 3 5-6" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>'
];
const items = $("#items"), parts = [];
C.milestones.forEach(([y, t, s], i) => {
  const f = (i + .5) / N, [x, yy] = at(f), last = i === N - 1;
  const dot = mk("circle", {cx: x, cy: yy, r: last ? 9 : 7, fill: last ? "var(--accent)" : "#fff", stroke: "var(--accent)", "stroke-width": 3.5});
  const yr = document.createElement("div"); yr.className = "yr" + (last ? " last" : ""); yr.textContent = y; yr.style.left = (x - 112) + "px"; yr.style.top = (yy - 14) + "px"; items.appendChild(yr);
  const cd = document.createElement("div"); cd.className = "card" + (last ? " hi" : "");
  cd.innerHTML = `<div class="ic"><svg width="22" height="22" viewBox="0 0 22 22" style="color:${last ? "#fff" : "#2b3038"}">${icons[i % icons.length]}</svg></div><div><div class="y">${y}</div><div class="t">${esc(t)}</div><div class="s">${esc(s)}</div></div>`;
  cd.style.left = Math.min(316, x + 40) + "px"; items.appendChild(cd); cd.style.top = (yy - cd.offsetHeight / 2) + "px";
  parts.push({dot, yr, cd, f});
});

const tl = gsap.timeline({paused:true});
tl.fromTo("#stage", {scale: 1.03}, {scale: 1, duration: 8, ease: "power1.out"}, 0);
tl.fromTo("#eyebrow", {opacity: 0, y: 10}, {opacity: 1, y: 0, duration: .5, ease: "power3.out"}, .1);
tl.fromTo("#title", {opacity: 0, y: 20}, {opacity: 1, y: 0, duration: .6, ease: "power3.out"}, .25);
const T0 = 1.0, SPAN = 4.6;   // spine draws from T0 over SPAN seconds; each milestone lands as the line reaches it
tl.to(spine, {strokeDashoffset: 0, duration: SPAN, ease: "none"}, T0);
parts.forEach(({dot, yr, cd, f}, i) => {
  const t = T0 + SPAN * f;
  tl.fromTo(dot, {attr: {r: 0}}, {attr: {r: i === N - 1 ? 9 : 7}, duration: .35, ease: "back.out(3)"}, t - .1);
  tl.fromTo(yr, {opacity: 0, x: 10}, {opacity: 1, x: 0, duration: .35, ease: "power2.out"}, t - .05);
  tl.fromTo(cd, {opacity: 0, x: 60, rotation: 3}, {opacity: 1, x: 0, rotation: 0, duration: .55, ease: "back.out(1.4)"}, t);
});
tl.fromTo(".card.hi", {scale: 1}, {scale: 1.04, duration: .4, yoyo: true, repeat: 1, ease: "sine.inOut"}, T0 + SPAN * parts.at(-1).f + .6);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

Layout notes: with 6 milestones the cards get close; if they touch, shorten details to one line or drop to 5. A three-line title pushes the spine down; shorten the title instead of shrinking it.

**Rendering rule:** never drive what's on screen from `onUpdate`/`onComplete` callbacks. The renderer sometimes seeks with events suppressed, so a callback-painted value freezes on random frames. Tween real properties (dash offsets, attributes, transforms), as this template does.

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors
npx hyperframes render --output timeline.mp4 --quality high
for t in 1.0 3.0 5.0 7.8; do ffmpeg -v error -y -ss $t -i timeline.mp4 -frames:v 1 f_$t.png; done
```

Look at the final frame: highlighted words must stay together on one line, no two cards may overlap, and each card's year must match the dot it sits beside.

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. It is 720×1280 (9:16) and silent.