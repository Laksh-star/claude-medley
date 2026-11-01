---
name: "paper-desk"
description: "Animate evidence on a desk as a vertical 9:16 MP4: taped notes on a green cutting mat, a chart circled in red marker, a slapped-down label and a highlighted quote. Use for /paper-desk."
---

# /paper-desk: evidence on the desk, marked up

A cream paper sheet drops onto a green cutting mat and gets taped down. A chart draws itself on it, a red marker rings the key part, and a handwritten note with an arrow ("INTERVAL SLUMP") writes itself beside the ring. A torn label ("THE INTERVAL") slaps down, then a second note card slides in and one sentence on it gets a yellow highlighter sweep. Output: 720×1280 MP4, 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

Good for: "here's what the data says" posts, research findings, retention or funnel insights, case-study evidence, teaching one chart.

## 1. Get the content

The user usually pastes a finding (e.g. "Most AI pilots stall right after the first review") and then types /paper-desk. Map it into CONFIG:

- `figLabel`, `figTitle`: the small mono label and serif headline on the main sheet
- `series`, `yMax`, `yLabel`, `xStart`, `xEnd`: the chart (any decay, growth or funnel curve works; 8–20 points)
- `circle`: the series index range `[from, to]` to ring in red
- `annotation`: 2–4 words of red handwriting ("" to drop)
- `hook`: the slapped label (≤ 12 characters reads best)
- `noteLabel`, `noteText`: the second card; wrap exactly one sentence in `[[ ]]` to highlight it

Rules:
- Chart numbers must be the user's (or from a source they point to). If they give only the finding, ask for the data, or, if they want an illustrative chart, set `figLabel` to include "Illustrative".
- The note text should be the user's own words or a quote they supply with its source; don't fabricate quotes from real people.

## 2. Set up the project

```bash
P=paper-desk-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/source-serif-4 @fontsource/jetbrains-mono @fontsource/inter @fontsource/permanent-marker
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
F=node_modules/@fontsource
cp $F/source-serif-4/files/source-serif-4-latin-{400,600}-normal.woff2 \
   $F/jetbrains-mono/files/jetbrains-mono-latin-{400,500}-normal.woff2 \
   $F/inter/files/inter-latin-800-normal.woff2 \
   $F/permanent-marker/files/permanent-marker-latin-400-normal.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (mat, marker and highlighter colours in `:root`).

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=720, height=1280" />
<script src="gsap.min.js"></script>
<style>
@font-face{font-family:Serif;src:url(fonts/source-serif-4-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:Serif;src:url(fonts/source-serif-4-latin-600-normal.woff2) format("woff2");font-weight:600}
@font-face{font-family:Mono;src:url(fonts/jetbrains-mono-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:Mono;src:url(fonts/jetbrains-mono-latin-500-normal.woff2) format("woff2");font-weight:500}
@font-face{font-family:Inter;src:url(fonts/inter-latin-800-normal.woff2) format("woff2");font-weight:800}
@font-face{font-family:Marker;src:url(fonts/permanent-marker-latin-400-normal.woff2) format("woff2");font-weight:400}
:root{--mat:#1d5a3a;--line:rgba(255,255,255,.07);--line2:rgba(255,255,255,.16);--paper:#f5f0e3;--ink:#1c1b19;--red:#d92b2b;--hl:#f2e34b}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--mat)}
#root{position:relative;width:720px;height:1280px;overflow:hidden;background:var(--mat)}
#desk{position:absolute;inset:0;transform-origin:50% 45%}
#mat{position:absolute;inset:-40px;background-image:linear-gradient(var(--line2) 1.5px,transparent 1.5px),linear-gradient(90deg,var(--line2) 1.5px,transparent 1.5px),linear-gradient(var(--line) 1px,transparent 1px),linear-gradient(90deg,var(--line) 1px,transparent 1px);background-size:100px 100px,100px 100px,20px 20px,20px 20px}
#vig{position:absolute;inset:0;background:radial-gradient(ellipse 75% 65% at 50% 45%,transparent 40%,rgba(0,0,0,.45) 100%)}
.paper{position:absolute;background:var(--paper);color:var(--ink);box-shadow:0 2px 3px rgba(0,0,0,.25),0 18px 36px rgba(0,0,0,.35)}
.paper::after{content:"";position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.35),transparent 40%,rgba(0,0,0,.04));pointer-events:none}
.tape{position:absolute;width:110px;height:34px;background:rgba(235,224,190,.78);box-shadow:0 1px 2px rgba(0,0,0,.15)}
#main{left:66px;top:200px;width:560px;padding:30px 34px 26px;transform:rotate(-2.2deg)}
.fig{font:500 13px Mono,monospace;letter-spacing:.1em;text-transform:uppercase;color:#5c5850}
#figTitle{font:600 34px/1.12 Serif,serif;margin:10px 0 14px;max-width:470px}
#chart{display:block;overflow:visible}
#hook{position:absolute;left:44px;top:742px;padding:14px 24px 12px;background:#fbfaf6;font:800 50px/1 Inter,sans-serif;letter-spacing:-.02em;color:#111;transform:rotate(-6deg);clip-path:polygon(0 6%,4% 0,30% 4%,62% 0,100% 5%,98% 48%,100% 96%,70% 100%,35% 95%,3% 100%,0 60%)}
#note{left:300px;top:850px;width:360px;padding:22px 24px 24px;transform:rotate(3deg)}
#noteText{font:400 21px/1.45 Serif,serif;margin-top:10px}
.hl{background-image:linear-gradient(var(--hl),var(--hl));background-repeat:no-repeat;background-size:0% 100%;background-position:0 85%}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <div id="desk" class="clip" data-start="0" data-duration="8" data-track-index="0">
  <div id="mat" data-layout-ignore></div><div id="vig"></div>
  <div id="main" class="paper"><div class="fig" id="figLabel"></div><div id="figTitle"></div><svg id="chart" width="492" height="300" viewBox="0 0 492 300"></svg>
   <div class="tape" style="left:-30px;top:-14px;transform:rotate(-28deg)"></div><div class="tape" style="right:-26px;top:-10px;transform:rotate(24deg)"></div></div>
  <div id="note" class="paper"><div class="fig" id="noteLabel"></div><div id="noteText"></div><div class="tape" style="left:120px;top:-18px;transform:rotate(-3deg)"></div></div>
  <div id="hook"></div>
 </div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  figLabel: "Exhibit 2 · Illustrative · AI pilots still active",
  figTitle: "Most AI pilots stall right after the first review",
  series: [100, 97, 92, 64, 50, 45, 43, 42, 41, 40, 40, 39], // y values, plotted 0..yMax left→right
  yMax: 100, yLabel: "100%", xStart: "Month 1", xEnd: "Month 12",
  circle: [2, 4],                       // series index range to ring with red marker
  annotation: "Interval slump",         // red handwriting next to the ring ("" to drop)
  hook: "THE INTERVAL",                 // slapped-down label
  noteLabel: "From the workshop notes",
  noteText: "Every pilot looked healthy at the launch review. [[The ones that survived had a named owner before the first demo.]] The rest drifted once the novelty wore off."
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s), NS = "http://www.w3.org/2000/svg";
const mk = (tag, a, parent) => { const e = document.createElementNS(NS, tag); for (const k in a) e.setAttribute(k, a[k]); parent.appendChild(e); return e; };
$("#figLabel").textContent = C.figLabel; $("#figTitle").textContent = C.figTitle; $("#hook").textContent = C.hook; $("#noteLabel").textContent = C.noteLabel;
const esc = s => s.replace(/[&<>]/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;"}[c]));
$("#noteText").innerHTML = esc(C.noteText).replace(/\[\[(.+?)\]\]/, '<span class="hl">$1</span>');
// chart
const svg = $("#chart"), X0 = 46, X1 = 476, Y0 = 250, Y1 = 22;
const px = i => X0 + (X1 - X0) * i / (C.series.length - 1), py = v => Y0 - (Y0 - Y1) * v / C.yMax;
mk("line", {x1: X0, y1: Y1 - 6, x2: X0, y2: Y0, stroke: "#2a2926", "stroke-width": 1.5, class: "axis"}, svg);
mk("line", {x1: X0, y1: Y0, x2: X1 + 6, y2: Y0, stroke: "#2a2926", "stroke-width": 1.5, class: "axis"}, svg);
const tx = (x, y, t, a) => { const e = mk("text", {x, y, "font-family": "Mono", "font-size": 14, fill: "#4d4a44", "text-anchor": a, class: "axis"}, svg); e.textContent = t; };
tx(X0 - 8, Y1 + 5, C.yLabel, "end"); tx(X0, Y0 + 24, C.xStart, "middle"); tx(X1, Y0 + 24, C.xEnd, "middle");
// slightly smoothed polyline (Catmull-Rom → Bézier)
const P = C.series.map((v, i) => [px(i), py(v)]);
let d = `M${P[0][0]},${P[0][1]}`;
for (let i = 0; i < P.length - 1; i++) { const p0 = P[i - 1] || P[i], p1 = P[i], p2 = P[i + 1], p3 = P[i + 2] || p2;
  d += ` C${p1[0] + (p2[0] - p0[0]) / 6},${p1[1] + (p2[1] - p0[1]) / 6} ${p2[0] - (p3[0] - p1[0]) / 6},${p2[1] - (p3[1] - p1[1]) / 6} ${p2[0]},${p2[1]}`; }
const curve = mk("path", {d, fill: "none", stroke: "#1c1b19", "stroke-width": 3, "stroke-linecap": "round"}, svg);
// hand-drawn marker ring around circle[] range: a wobbly ellipse that overshoots its start
const [a, b] = C.circle, xs = P.slice(a, b + 1).map(p => p[0]), ys = P.slice(a, b + 1).map(p => p[1]);
const cx = (Math.min(...xs) + Math.max(...xs)) / 2, cy = (Math.min(...ys) + Math.max(...ys)) / 2;
const rx = (Math.max(...xs) - Math.min(...xs)) / 2 + 26, ry = (Math.max(...ys) - Math.min(...ys)) / 2 + 24;
let ring = ""; for (let k = 0; k <= 64; k++) { const t = -2.2 + k / 64 * Math.PI * 2.25, w = 1 + .045 * Math.sin(t * 2 + .6) + k / 64 * .09;
  ring += (k ? " L" : "M") + (cx + rx * w * Math.cos(t)).toFixed(1) + "," + (cy + ry * w * Math.sin(t)).toFixed(1); }
const ringEl = mk("path", {d: ring, fill: "none", stroke: "var(--red)", "stroke-width": 4.5, "stroke-linecap": "round", "stroke-linejoin": "round", opacity: .92}, svg);
// annotation: marker text with a small arrow pointing back at the ring
let ann = null, arrow = null;
if (C.annotation) {
  const ax = cx + rx + 34, ay = cy - ry * .2;
  ann = mk("text", {x: ax + 16, y: ay, "font-family": "Marker", "font-size": 27, fill: "var(--red)", transform: `rotate(-4 ${ax} ${ay})`}, svg); ann.textContent = C.annotation.toUpperCase();
  arrow = mk("path", {d: `M${ax + 8},${ay + 6} Q${ax - 8},${ay + 14} ${cx + rx + 6},${cy + 4} M${cx + rx + 6},${cy + 4} l12,-2 M${cx + rx + 6},${cy + 4} l5,10`, fill: "none", stroke: "var(--red)", "stroke-width": 3.5, "stroke-linecap": "round"}, svg);
  const clip = mk("clipPath", {id: "annClip"}, svg); const cr = mk("rect", {x: ax, y: ay - 40, width: 0, height: 60}, clip); ann.setAttribute("clip-path", "url(#annClip)"); ann.clipRect = cr;
}
[curve, ringEl, arrow].forEach(p => { if (!p) return; const L = p.getTotalLength(); p.style.strokeDasharray = L; p.style.strokeDashoffset = L; p.dataset.len = L; });

const tl = gsap.timeline({paused:true});
tl.fromTo("#desk", {scale: 1.04}, {scale: 1, duration: 8, ease: "power1.out"}, 0);
tl.fromTo("#main", {y: -900, rotation: -9}, {y: 0, rotation: -2.2, duration: .9, ease: "power3.out"}, .15);
tl.fromTo("#main .tape", {opacity: 0, scale: 1.4}, {opacity: 1, scale: 1, duration: .25, stagger: .12, ease: "power4.out"}, .95);
tl.fromTo(".axis", {opacity: 0}, {opacity: 1, duration: .4}, 1.0);
tl.to(curve, {strokeDashoffset: 0, duration: 1.3, ease: "power1.inOut"}, 1.2);
tl.to(ringEl, {strokeDashoffset: 0, duration: .8, ease: "power1.inOut"}, 2.55);
if (arrow) { tl.to(arrow, {strokeDashoffset: 0, duration: .35, ease: "power1.out"}, 3.3); tl.to(ann.clipRect, {attr: {width: 300}, duration: .7, ease: "none"}, 3.5); }
tl.fromTo("#hook", {opacity: 0, scale: 1.5, rotation: -14}, {opacity: 1, scale: 1, rotation: -6, duration: .35, ease: "back.out(2)"}, 4.1);
tl.fromTo("#note", {x: 560, rotation: 12}, {x: 0, rotation: 3, duration: .7, ease: "power3.out"}, 4.5);
tl.fromTo("#note .tape", {opacity: 0, scale: 1.4}, {opacity: 1, scale: 1, duration: .25, ease: "power4.out"}, 5.15);
tl.to(".hl", {backgroundSize: "100% 100%", duration: 1.1, ease: "power1.inOut"}, 5.5);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

Layout notes: if the ring sits near the right edge of the chart, the annotation runs off the sheet. In that case ring an earlier range, or shorten `annotation` to 1–2 words. Keep `figTitle` to two lines and `noteText` under ~35 words.

**Rendering rule:** never drive what's on screen from `onUpdate`/`onComplete` callbacks. The renderer sometimes seeks with events suppressed, so a callback-painted value freezes on random frames. Tween real properties (as here: dash offsets, clip width, transforms).

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors
npx hyperframes render --output paper-desk.mp4 --quality high
for t in 0.8 2.4 3.9 5.0 7.8; do ffmpeg -v error -y -ss $t -i paper-desk.mp4 -frames:v 1 f_$t.png; done
```

Look at the frames: the ring must surround the intended part of the curve, the annotation must stay on the paper, and nothing should peek in from the frame edge before its entrance.

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. It is 720×1280 (9:16) and silent.