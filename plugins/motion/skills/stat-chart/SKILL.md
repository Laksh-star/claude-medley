---
name: "stat-chart"
description: "Animate one big number as a vertical 9:16 MP4: the figure counts up, a line chart draws itself, one callout marks the turning point. Use for /stat-chart or a stat reel."
---

# /stat-chart: big number, chart, one callout

A dark fintech-style card for reels and posts: a header with the org name, a huge number counting from start to end value, a line chart that draws in white up to an event and in accent orange after it, one callout at that event, then a takeaway pill and source line. Output: 720×1280 MP4, about 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

## 1. Get the data, and never invent it

The user usually pastes a short line (e.g. "6.3M watch hours, up from 0.8M since our first original") and then types /stat-chart. Map it into CONFIG:

- `endValue`, `prefix`, `suffix`, `decimals`: the headline figure ($4.2B → "$", 4.2, "B", 1; 6.3M hours → "", 6.3, "M", 1)
- `startValue`: where the count starts (usually the first series value)
- `label`: what the number measures; `brand`: org or product name; `meta`: a small descriptor (units, cadence)
- `series`: real data points as `[label, value]`, oldest first; put a year label only on the points that should show one on the axis
- `calloutIndex` + `calloutWhen/What/Sub`: the event that bent the curve
- `tagPill` + `tagText`: the one-line takeaway; `dateTag`: as-of date; `source`, `range`: footer

Rules:
- Only plot numbers the user gave or that come from a source they pointed to. If they give the big number but no series, ask for the data points (4–20 is ideal). If they explicitly want an illustrative version, you may sketch a plausible curve, but then set `source` to "Illustrative, not actual data".
- `tagPill` must be arithmetic on the user's numbers (e.g. 6.3 / 0.8 = 7.9×); compute it, don't guess.
- Use a real org name only if it is the user's own or a client's with permission; otherwise use a fictional one.
- If something essential is missing and the user isn't around, render with clearly labelled placeholders and say so.

## 2. Set up the project

```bash
P=stat-chart-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/inter @fontsource/jetbrains-mono
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
cp node_modules/@fontsource/inter/files/inter-latin-{400,600,800}-normal.woff2 \
   node_modules/@fontsource/jetbrains-mono/files/jetbrains-mono-latin-{400,500}-normal.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs (jsdelivr, Google Fonts) are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found, point it at any installed Chromium: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with the template below and edit only the CONFIG block. To change the palette, edit the `:root` variables; the accent also appears as `#ff5a1f` in the gradient and the dashed vline.

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
:root{--bg:#0b0b0c;--ink:#f4f2ee;--dim:#8a8781;--faint:#2a2927;--accent:#ff5a1f}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--bg)}
#root{position:relative;width:720px;height:1280px;font-family:Inter,sans-serif;color:var(--ink);overflow:hidden}
#stage{position:absolute;inset:0;transform-origin:50% 45%}
.mono{font-family:Mono,monospace;letter-spacing:.06em;text-transform:uppercase}
#head{position:absolute;left:48px;right:48px;top:170px;display:flex;justify-content:space-between;align-items:center}
#brand{display:flex;align-items:center;gap:10px;font-weight:800;font-size:17px;letter-spacing:.08em}
#brand i{display:block;width:14px;height:14px;background:var(--accent);border-radius:3px}
#meta{font-size:13px;color:var(--dim)}
#label{position:absolute;left:48px;top:236px;font-size:20px;color:#c9c6c0}
#big{position:absolute;left:44px;top:262px;font-weight:800;letter-spacing:-.045em;line-height:1;white-space:nowrap}
#big .pre{font-size:96px;vertical-align:top;position:relative;top:10px;margin-right:4px}
#big .num{font-size:190px}
#big .suf{font-size:104px;margin-left:6px}
#tag{position:absolute;left:48px;top:498px;display:flex;align-items:center;gap:12px;font-size:17px}
#tag .pill{background:var(--accent);color:#0b0b0c;font-weight:600;padding:5px 10px;border-radius:4px;font-family:Mono,monospace}
#tag .txt{color:#c9c6c0}
#date{position:absolute;right:48px;top:503px;font-size:15px;color:var(--ink)}
#date::before{content:"";display:inline-block;width:7px;height:7px;border-radius:50%;background:var(--accent);margin-right:8px;vertical-align:1px}
#chart{position:absolute;left:0;top:560px;width:720px;height:460px}
#callout{position:absolute;width:300px}
#callout .when{font-size:14px;color:var(--accent);margin-bottom:6px}
#callout .what{font-size:22px;font-weight:600;line-height:1.15}
#callout .sub{font-size:17px;color:#a29e97;margin-top:4px}
#foot{position:absolute;left:48px;right:48px;top:1060px;display:flex;justify-content:space-between;font-size:13px;color:#8f8b84}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <div id="stage" class="clip" data-start="0" data-duration="8" data-track-index="0">
  <div id="head"><div id="brand"><i></i><span id="brandName"></span></div><div id="meta" class="mono"></div></div>
  <div id="label"></div>
  <div id="big"><span class="pre"></span><span class="num">0</span><span class="suf"></span></div>
  <div id="tag"><span class="pill"></span><span class="txt"></span></div>
  <div id="date" class="mono"></div>
  <svg id="chart" viewBox="0 0 720 460"></svg>
  <div id="callout"><div class="when mono"></div><div class="what"></div><div class="sub"></div></div>
  <div id="foot" class="mono"><span id="src"></span><span id="range"></span></div>
 </div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  brand: "KATHA STREAM",                  // short org / product name (fictional placeholder)
  meta: "Hours · monthly · all regions",  // small top-right descriptor
  label: "Monthly watch hours",          // what the big number measures
  prefix: "", suffix: "M", decimals: 1,   // big number formatting
  startValue: 0.8, endValue: 6.3,         // counts from start to end
  tagPill: "7.9×", tagText: "since the first original", // the one-line takeaway
  dateTag: "Oct 2025",                    // as-of date of the end value
  // series: [label, value]; x labels shown only where label is non-empty
  series: [["2020",0.8],["",0.85],["",0.95],["2021",1.0],["",1.1],["",1.2],["2022",1.3],["",1.35],["",1.5],["2023",1.6],["",2.4],["",3.1],["2024",3.9],["",4.4],["",4.9],["2025",5.5],["",6.0],["",6.3]],
  calloutIndex: 9,                        // series index where the event happened; line turns accent after it
  calloutWhen: "Jan 2023", calloutWhat: "First original drops", calloutSub: "Watch time triples in a year",
  source: "Source: placeholder data", range: "Jan 2020 – Oct 2025"
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s);
$("#brandName").textContent = C.brand; $("#meta").textContent = C.meta; $("#label").textContent = C.label;
$("#big .pre").textContent = C.prefix; $("#big .suf").textContent = C.suffix;
$("#tag .pill").textContent = C.tagPill; $("#tag .txt").textContent = C.tagText; $("#date").textContent = C.dateTag;
$("#callout .when").textContent = C.calloutWhen; $("#callout .what").textContent = C.calloutWhat; $("#callout .sub").textContent = C.calloutSub;
$("#src").textContent = C.source; $("#range").textContent = C.range;

// shrink the big number if it would overflow the frame
const big = $("#big"); $("#big .num").textContent = C.endValue.toFixed(C.decimals);
const fit = Math.min(1, 632 / big.scrollWidth); big.style.transformOrigin = "0 0"; big.style.transform = `scale(${fit})`;

// build chart
const svgNS = "http://www.w3.org/2000/svg", svg = $("#chart");
const X0 = 48, X1 = 672, Y0 = 380, Y1 = 40, vals = C.series.map(d => d[1]);
const vmax = Math.max(...vals) * 1.08, vmin = 0;
const px = i => X0 + (X1 - X0) * i / (C.series.length - 1), py = v => Y0 - (Y0 - Y1) * (v - vmin) / (vmax - vmin);
const el = (n, a) => { const e = document.createElementNS(svgNS, n); for (const k in a) e.setAttribute(k, a[k]); svg.appendChild(e); return e; };
for (let g = 0; g <= 4; g++) { const y = Y1 + (Y0 - Y1) * g / 4; el("line", {x1:X0, x2:X1, y1:y, y2:y, stroke:"#1e1d1b", "stroke-width":1, class:"grid"}); }
C.series.forEach((d, i) => { if (d[0]) { const t = el("text", {x:px(i), y:Y0 + 30, fill:"#9a968f", "font-size":15, "font-family":"Mono", "text-anchor":"middle", class:"xl"}); t.textContent = d[0]; } });
const ptsStr = a => a.map(i => `${px(i).toFixed(1)},${py(vals[i]).toFixed(1)}`).join(" L");
const ci = Math.max(1, Math.min(C.series.length - 2, C.calloutIndex));
const before = [...Array(ci + 1).keys()], after = [...Array(C.series.length - ci).keys()].map(k => k + ci);
const area = el("path", {d:`M${ptsStr(after)} L${px(after.at(-1))},${Y0} L${px(ci)},${Y0} Z`, fill:"url(#fade)", opacity:0});
const defs = document.createElementNS(svgNS, "defs"); defs.innerHTML = `<linearGradient id="fade" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ff5a1f" stop-opacity=".28"/><stop offset="1" stop-color="#ff5a1f" stop-opacity="0"/></linearGradient>`; svg.prepend(defs);
const lineA = el("path", {d:`M${ptsStr(before)}`, fill:"none", stroke:"#e9e6e0", "stroke-width":3, "stroke-linejoin":"round", "stroke-linecap":"round"});
const lineB = el("path", {d:`M${ptsStr(after)}`, fill:"none", stroke:"var(--accent)", "stroke-width":4, "stroke-linejoin":"round", "stroke-linecap":"round"});
const vline = el("line", {x1:px(ci), x2:px(ci), y1:py(vals[ci]), y2:Y1 + 10, stroke:"#ff5a1f", "stroke-width":1, "stroke-dasharray":"3 4", opacity:0});
const dot = el("circle", {cx:px(ci), cy:py(vals[ci]), r:7, fill:"#0b0b0c", stroke:"#f4f2ee", "stroke-width":3});
const end = el("circle", {cx:px(C.series.length - 1), cy:py(vals.at(-1)), r:6, fill:"var(--accent)"});
[lineA, lineB].forEach(p => { const L = p.getTotalLength(); p.style.strokeDasharray = L; p.style.strokeDashoffset = L; });
// place the callout beside the event, flipping side if near the right edge
const co = $("#callout"), cx = px(ci), leftSide = cx > 340;
co.style.top = (560 + Math.max(Y1 + 30, py(vals[ci]) - 150)) + "px";
co.style.left = (leftSide ? cx - 320 : cx + 20) + "px"; co.style.textAlign = leftSide ? "right" : "left";

// timeline
const tl = gsap.timeline({paused:true});
tl.fromTo("#stage", {scale:.94}, {scale:1, duration:8, ease:"none"}, 0);
tl.from(["#head","#label"], {opacity:0, y:14, duration:.5, stagger:.08, ease:"power3.out"}, .1);
tl.from("#big", {opacity:0, y:24, duration:.5, ease:"power3.out"}, .3);
// counter: tween the text itself and format it with a modifier (callbacks can be skipped by the renderer's seeks)
tl.fromTo("#big .num", {textContent:C.startValue}, {textContent:C.endValue, duration:4.4, ease:"power2.inOut", modifiers:{textContent:v => (+v).toFixed(C.decimals)}}, .5);
tl.from(".grid,.xl", {opacity:0, duration:.6, stagger:.02}, .4);
tl.to(lineA, {strokeDashoffset:0, duration:1.8, ease:"none"}, .6);
tl.from(dot, {attr:{r:0}, duration:.35, ease:"back.out(3)"}, 2.4);
tl.to(vline, {opacity:1, duration:.3}, 2.5);
tl.from(co, {opacity:0, x:leftSide ? 16 : -16, duration:.5, ease:"power3.out"}, 2.55);
tl.to(lineB, {strokeDashoffset:0, duration:2.5, ease:"power1.inOut"}, 2.5);
tl.to(area, {opacity:1, duration:1.0}, 4.9);
tl.from(end, {attr:{r:0}, duration:.35, ease:"back.out(3)"}, 4.95);
tl.from(["#tag","#date"], {opacity:0, y:10, duration:.45, stagger:.1, ease:"power3.out"}, 5.0);
tl.from("#foot", {opacity:0, duration:.5}, 5.3);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

Layout notes: the big number auto-shrinks to fit; the callout flips to the left of the event when the event sits in the right half. Keep `calloutWhat` under ~24 characters and `calloutSub` under ~32.

**Rendering rule:** never drive what's on screen from `onUpdate`/`onComplete` callbacks. The renderer sometimes seeks with events suppressed, so a callback-painted value can freeze on random frames. The counter tweens `textContent` directly and formats it with a GSAP `modifiers` function, which runs on every render; keep that pattern if you add numbers.

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors
npx hyperframes render --output stat-chart.mp4 --quality high
for t in 1 2.6 4 7.9; do ffmpeg -v error -y -ss $t -i stat-chart.mp4 -frames:v 1 f_$t.png; done
```

Look at the frames. The callout must not cross the orange line, the number must not clip at the right edge, it must read with the right decimals mid-count, and the final frame must show the end value exactly. Expected and fine: a `nested_structure_needs_subcomposition` warning, and a `text_below_floor` warning for the small mono labels (they're texture, not reading text).

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. If the user posts reels, mention it's 720×1280 (9:16) and silent: a music bed can be added with HyperFrames' native `<audio>` clip if they supply a track.