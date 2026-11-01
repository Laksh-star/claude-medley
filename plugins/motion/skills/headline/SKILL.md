---
name: "headline"
description: "Animate a newspaper-style article as a vertical 9:16 MP4: the page rises, the camera pushes in on the headline and one key line gets highlighted. Use for /headline."
---

# /headline: article push-in, line highlighted

A white newspaper page rises at a tilt out of a dim wall of blurred pages. The camera pushes in on the headline, pans down to the opening paragraph, and a yellow highlighter sweeps across the one sentence that matters. An optional reader-comment chip pops in at the end. Output: 720×1280 MP4, 7.5 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

## 1. Get the content

The user usually pastes a headline or opening line and then types /headline. Map it into CONFIG:

- `headline`: the article headline (ideally ≤ 100 characters; longer ones push the body down)
- `body`: the opening paragraph, ≤ ~60 words, with exactly ONE sentence wrapped in `[[ ]]`, which is what gets highlighted
- `kicker`, `byline`, `bydate`, `dateline`, `edition`, `nav`: small furniture
- `publication`: the masthead name
- `chipText`: an optional one-line reaction; set to "" to drop the chip

Rules:
- The masthead is the user's own publication (e.g. his newsletter or Medium name) or a clearly fictional one. Never use or imitate a real outlet's name, logo or typography (no "The New York Times", "The Economist", lookalikes).
- Use the user's text. If they give only a headline, ask for the paragraph. If they explicitly want a mock-up, you may draft a short paragraph, but keep the byline fictional and say in your reply that the body is illustrative.
- If they don't say which line to highlight, pick the sentence carrying the key number or claim, and mention which one you picked.
- Never present a fabricated article about a real company or person as real news. Fictional companies are fine; for real ones, use only what the user supplied.

## 2. Set up the project

```bash
P=headline-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/playfair-display @fontsource/source-serif-4 @fontsource/inter
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
F=node_modules/@fontsource
cp $F/playfair-display/files/playfair-display-latin-{700,800}-normal.woff2 \
   $F/source-serif-4/files/source-serif-4-latin-{400,600}-normal.woff2 \
   $F/inter/files/inter-latin-{400,600,800}-normal.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (`--hl` in `:root` is the highlighter colour; `--kicker` is the section colour).

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=720, height=1280" />
<script src="gsap.min.js"></script>
<style>
@font-face{font-family:Display;src:url(fonts/playfair-display-latin-700-normal.woff2) format("woff2");font-weight:700}
@font-face{font-family:Display;src:url(fonts/playfair-display-latin-800-normal.woff2) format("woff2");font-weight:800}
@font-face{font-family:Body;src:url(fonts/source-serif-4-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:Body;src:url(fonts/source-serif-4-latin-600-normal.woff2) format("woff2");font-weight:600}
@font-face{font-family:UI;src:url(fonts/inter-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:UI;src:url(fonts/inter-latin-600-normal.woff2) format("woff2");font-weight:600}
@font-face{font-family:UI;src:url(fonts/inter-latin-800-normal.woff2) format("woff2");font-weight:800}
:root{--bg:#111110;--paper:#fbfaf6;--ink:#151413;--kicker:#c4122f;--hl:#e8f53a}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--bg)}
#root{position:relative;width:720px;height:1280px;overflow:hidden}
#cam{position:absolute;inset:0;transform-origin:50% 50%}
#wall{position:absolute;left:-260px;top:-200px;width:1240px;height:1700px;display:grid;grid-template-columns:repeat(6,1fr);gap:26px;transform:rotate(-8deg);filter:blur(3px) brightness(.42)}
.pg{background:#d9d6cf;border-radius:3px;padding:16px 14px;height:250px}
.pg b{display:block;height:9px;background:#7c7972;margin:0 0 8px;border-radius:2px}
.pg i{display:block;height:4px;background:#aaa69e;margin:0 0 6px}
#vign{position:absolute;inset:0;background:radial-gradient(ellipse 70% 60% at 50% 45%,transparent 30%,rgba(0,0,0,.75) 100%)}
#persp{position:absolute;inset:0;perspective:1400px}
#card{position:absolute;left:100px;top:300px;width:520px;background:var(--paper);color:var(--ink);padding:26px 30px 34px;box-shadow:0 40px 80px rgba(0,0,0,.6),0 4px 12px rgba(0,0,0,.4);transform-origin:50% 0%}
.mast{display:flex;justify-content:space-between;font:600 8px/1 UI,sans-serif;letter-spacing:.12em;text-transform:uppercase;color:#4a4744}
#pub{font:800 40px/1.05 Display,serif;text-align:center;margin:8px 0 8px;letter-spacing:-.01em}
.nav{display:flex;justify-content:center;gap:16px;font:600 9px/1 UI,sans-serif;color:#3c3a37;padding:7px 0;border-top:1px solid #1d1c1a;border-bottom:3px double #1d1c1a}
#kicker{font:800 10px/1 UI,sans-serif;letter-spacing:.14em;text-transform:uppercase;color:var(--kicker);margin:20px 0 8px}
#hed{font:700 31px/1.12 Display,serif;letter-spacing:-.01em}
.by{display:flex;align-items:center;gap:9px;margin:16px 0 18px}
.av{width:24px;height:24px;border-radius:50%;background:linear-gradient(135deg,#9a8f84,#5d554e)}
.by .n{font:600 11px/1.2 UI,sans-serif}.by .d{font:400 10px/1.2 UI,sans-serif;color:#6b6762}
#body{font:400 16.5px/1.55 Body,serif;color:#232120}
#body::first-letter{font:700 58px/.8 Display,serif;float:left;margin:6px 8px 0 0}
.hl{background-image:linear-gradient(var(--hl),var(--hl));background-repeat:no-repeat;background-size:0% 100%;background-position:0 88%;padding:0 1px}
#chip{position:absolute;left:330px;top:900px;width:300px;background:#fff;border-radius:12px;padding:14px 16px;box-shadow:0 18px 40px rgba(0,0,0,.45);font:400 15px/1.35 UI,sans-serif;color:#1a1a1a}
#chip .who{display:flex;align-items:center;gap:8px;font-weight:600;font-size:13px;margin-bottom:6px}
#chip .who i{width:20px;height:20px;border-radius:50%;background:linear-gradient(135deg,#f0a35e,#c4122f)}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="7.5" data-width="720" data-height="1280">
 <div id="cam" class="clip" data-start="0" data-duration="7.5" data-track-index="0">
  <div id="wall" data-layout-ignore></div>
  <div id="vign"></div>
  <div id="persp"><div id="card">
   <div class="mast"><span id="dateline"></span><span id="edition"></span></div>
   <div id="pub"></div>
   <div class="nav" id="nav"></div>
   <div id="kicker"></div>
   <h1 id="hed"></h1>
   <div class="by"><div class="av"></div><div><div class="n" id="byline"></div><div class="d" id="bydate"></div></div></div>
   <p id="body"></p>
  </div></div>
 </div>
 <div id="chip" class="clip" data-start="5.4" data-duration="2.1" data-track-index="1"><div class="who"><i></i><span id="chipWho"></span></div><div id="chipText"></div></div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  publication: "The Daily Interval",          // fictional masthead — never a real outlet's name
  dateline: "Friday, November 6, 2026", edition: "Weekend Edition",
  nav: ["Cinema","Business","Markets","Tech","Opinion","Culture"],
  kicker: "Cinema / Business",
  headline: "A small studio gave its script desk an AI reader. The real win wasn't the savings.",
  byline: "By Meera Rao", bydate: "Nov 6, 2026 · 6 min read",
  // wrap the ONE line to highlight in [[ ]]
  body: "When Monsoon Reel Studios added an AI reader to its script desk last summer, the producers expected to save money. [[Instead, the time from first draft to greenlight fell from eleven weeks to four.]] The savings arrived later, and from a place nobody had planned for.",
  chipWho: "Reader", chipText: "Speed was the story all along." // set chipText to "" to drop the comment chip
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s);
$("#pub").textContent = C.publication; $("#dateline").textContent = C.dateline; $("#edition").textContent = C.edition;
$("#nav").innerHTML = C.nav.map(n => `<span>${n}</span>`).join(""); $("#kicker").textContent = C.kicker;
$("#hed").textContent = C.headline; $("#byline").textContent = C.byline; $("#bydate").textContent = C.bydate;
const esc = s => s.replace(/[&<>]/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;"}[c]));
$("#body").innerHTML = esc(C.body).replace(/\[\[(.+?)\]\]/, '<span class="hl">$1</span>');
$("#chipWho").textContent = C.chipWho; $("#chipText").textContent = C.chipText;
if (!C.chipText) $("#chip").style.display = "none";
// background wall of blurred pages
let w = ""; for (let i = 0; i < 36; i++) { w += `<div class="pg"><b style="width:${60 + (i * 37) % 35}%"></b><b style="width:${40 + (i * 53) % 45}%"></b>${"<i></i>".repeat(14)}</div>`; }
$("#wall").innerHTML = w;

// camera targets measured from layout: push toward headline, then pan to the highlighted line
const card = $("#card"), hl = $(".hl") || $("#body");
const cardTop = 300, hedMid = cardTop + $("#hed").offsetTop + $("#hed").offsetHeight / 2;
const hlMid = cardTop + hl.offsetTop + hl.offsetHeight / 2;
const camTo = (y, s) => ({ scale: s, y: (640 - y) * s });

const tl = gsap.timeline({paused:true});
tl.fromTo("#wall", {y:40}, {y:-60, duration:7.5, ease:"none"}, 0);
tl.fromTo(card, {y:900, rotationX:38, rotationZ:-6}, {y:0, rotationX:10, rotationZ:-3, duration:1.4, ease:"power3.out"}, 0.1);
tl.to(card, {rotationX:0, rotationZ:-1.5, duration:2.2, ease:"power2.inOut"}, 1.4);
tl.to("#cam", {...camTo(hedMid, 1.38), duration:1.7, ease:"power2.inOut"}, 1.2);
tl.to("#cam", {...camTo(hlMid, 1.5), duration:1.4, ease:"power2.inOut"}, 3.0);
tl.to(".hl", {backgroundSize:"100% 100%", duration:1.3, ease:"power1.inOut"}, 4.1);
tl.fromTo("#chip", {opacity:0, y:30, scale:.92}, {opacity:1, y:0, scale:1, duration:.5, ease:"back.out(1.6)"}, 5.4);
tl.to("#cam", {scale:"+=0.03", duration:2.0, ease:"none"}, 5.5);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

Layout notes: the camera targets are measured from the laid-out card, so longer headlines or paragraphs still centre correctly, but a body much over ~60 words makes the card taller than the frame at 1.5× zoom. Trim the paragraph rather than shrinking type.

## 4. Check, render, verify

```bash
npx hyperframes check
npx hyperframes render --output headline.mp4 --quality high
for t in 0.6 2.4 3.9 5.0 7.2; do ffmpeg -v error -y -ss $t -i headline.mp4 -frames:v 1 f_$t.png; done
```

Expected and fine: `check` reports `content_overlap` errors between masthead, nav, kicker and headline during roughly 0–2.4 s. These are measurement artefacts of the card's 3D tilt (rotated bounding boxes), not real overlaps, and the render proceeds. Any overlap reported after ~2.5 s, or any other error, is real and must be fixed. Look at the frames: the highlighted sentence should sit near the vertical centre at 5 s and be fully highlighted by 5.4 s, and the chip must not cover it.

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows (and, if you drafted the body or picked the highlight, say so). It is 720×1280 (9:16) and silent.