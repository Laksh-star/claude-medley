---
name: "ink-wash"
description: "Make a Chinese ink-painting title card as a vertical 9:16 MP4: misty karst peaks, a red sun, birds, a drifting boat, a vertical brush-revealed title and red seal. Use for /ink-wash."
---

# /ink-wash: ink-painting title card

A shan-shui style title card on warm paper: four layers of karst mountains rise out of drifting mist, a red sun blooms, birds cross the sky, a small boat drifts on brushed water beside a dark cliff with a leaning pine. Then the title writes itself top-down in a vertical column, followed by an italic subtitle, a red seal and a chapter label. Everything is drawn in code (SVG + seeded randomness), with no images. Output: 720×1280 MP4, 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

Good for: chapter or episode openers, story or film titles, poems and quotes, festival or cultural posts, any calm "once upon a time" moment.

## 1. Get the content

The user usually pastes a title (e.g. "The river keeps no name") and then types /ink-wash. Map it into CONFIG:

- `title`: the vertical title, ideally ≤ 26 characters (longer titles run into the water line; shorten or split the extra into `subtitle`)
- `subtitle`: an optional small italic line; `chapter`: an optional right-edge label; use "" to drop either
- `seal`: one character in the red chop, by default the first letter of the title or of the author's name
- `sun`: position and radius; keep `x` ≥ 300 so it stays clear of the title column
- `boat`, `cliff`, `birds`: toggle or count the scene elements
- `seed`: changes the mountain shapes. If the peaks look crowded or a spire collides with the sun, try another seed.

If the user asks for a seal or title in a non-Latin script (Telugu, Devanagari, CJK), the bundled Cormorant font won't have those glyphs. Install the matching font (`@fontsource/noto-serif-telugu`, `@fontsource/noto-serif-devanagari`, `@fontsource/noto-serif-sc`), copy its woff2 into `fonts/`, add an `@font-face`, and put that family first in the `#title` / `#seal` font stack. For non-Latin vertical titles, drop `text-transform:uppercase` and reduce `letter-spacing`.

## 2. Set up the project

```bash
P=ink-wash-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/cormorant-garamond
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
F=node_modules/@fontsource/cormorant-garamond/files
cp $F/cormorant-garamond-latin-{400,500}-normal.woff2 $F/cormorant-garamond-latin-400-italic.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (palette in `:root`).

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=720, height=1280" />
<script src="gsap.min.js"></script>
<style>
@font-face{font-family:Serif;src:url(fonts/cormorant-garamond-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:Serif;src:url(fonts/cormorant-garamond-latin-500-normal.woff2) format("woff2");font-weight:500}
@font-face{font-family:Serif;src:url(fonts/cormorant-garamond-latin-400-italic.woff2) format("woff2");font-weight:400;font-style:italic}
:root{--paper:#efebe2;--ink:#1d1c1a;--sun:#c8352c}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--paper)}
#root{position:relative;width:720px;height:1280px;overflow:hidden;background:var(--paper)}
#scene{position:absolute;inset:0;transform-origin:50% 60%}
svg{position:absolute;inset:0}
#title{position:absolute;top:150px;left:70px;writing-mode:vertical-rl;font:500 40px/1 Serif,serif;letter-spacing:.26em;text-transform:uppercase;color:var(--ink)}
#sub{position:absolute;top:156px;left:150px;writing-mode:vertical-rl;font:italic 400 24px/1.3 Serif,serif;letter-spacing:.08em;color:#4a4740}
#seal{position:absolute;left:84px;width:40px;height:40px;background:var(--sun);color:#f5efe4;font:500 22px/40px Serif,serif;text-align:center;border-radius:3px}
#chapter{position:absolute;right:64px;top:160px;writing-mode:vertical-rl;font:400 20px/1 Serif,serif;letter-spacing:.3em;text-transform:uppercase;color:#5a564e}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <div id="scene" class="clip" data-start="0" data-duration="8" data-track-index="0">
  <svg id="art" viewBox="0 0 720 1280" data-layout-ignore>
   <defs>
    <filter id="grain" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".9" numOctaves="2" seed="4"/><feColorMatrix values="0 0 0 0 .3  0 0 0 0 .28  0 0 0 0 .24  0 0 0 .09 0"/></filter>
    <filter id="brush" x="-5%" y="-5%" width="110%" height="110%"><feTurbulence type="fractalNoise" baseFrequency=".035 .09" numOctaves="3" seed="7"/><feDisplacementMap in="SourceGraphic" scale="14"/></filter>
    <filter id="soft"><feGaussianBlur stdDeviation="3"/></filter>
    <filter id="mistblur"><feGaussianBlur stdDeviation="22"/></filter>
    <radialGradient id="sunG" cx=".45" cy=".42" r=".6"><stop offset="0" stop-color="#d63f33"/><stop offset=".8" stop-color="#c8352c"/><stop offset="1" stop-color="#b52e27" stop-opacity=".85"/></radialGradient>
   </defs>
   <circle id="sun" filter="url(#brush)" fill="url(#sunG)"/>
   <g id="birds" fill="none" stroke="#2a2825" stroke-width="2.2" stroke-linecap="round"></g>
   <g id="ridges"></g>
   <g id="mist"></g>
   <g id="water" stroke="#8d897f" stroke-width="1.4" stroke-linecap="round" opacity=".6"></g>
   <g id="boat" fill="#1f1e1c"></g>
   <path id="cliff" filter="url(#brush)" fill="#24231f"/>
   <rect width="720" height="1280" filter="url(#grain)"/>
  </svg>
  <div id="title"></div><div id="sub"></div><div id="seal"></div><div id="chapter"></div>
 </div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  title: "The river keeps no name", // vertical title, keep under ~26 characters
  subtitle: "Three days down the river",  // small italic line beside it ("" to drop)
  chapter: "Chapter one",           // right-edge vertical label ("" to drop)
  seal: "R",                         // 1 Latin character in the red chop (an initial)
  sun: { x: 470, y: 430, r: 62 },   // red sun position & size
  boat: true, cliff: true, birds: 4, seed: 11
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s), NS = "http://www.w3.org/2000/svg";
let s = C.seed >>> 0; const rnd = () => { s = (s + 0x6D2B79F5) >>> 0; let t = s; t = Math.imul(t ^ t >>> 15, t | 1); t ^= t + Math.imul(t ^ t >>> 7, t | 61); return ((t ^ t >>> 14) >>> 0) / 4294967296; };
const mk = (tag, a, parent) => { const e = document.createElementNS(NS, tag); for (const k in a) e.setAttribute(k, a[k]); parent.appendChild(e); return e; };
const defs = $("#art defs");
// title text, one span per character for a top-down brush reveal
const chars = t => [...t].map(ch => `<span class="ch">${ch === " " ? " " : ch}</span>`).join("");
$("#title").innerHTML = chars(C.title); $("#sub").textContent = C.subtitle; $("#chapter").textContent = C.chapter; $("#seal").textContent = C.seal;
if (!C.subtitle) $("#sub").style.display = "none"; if (!C.chapter) $("#chapter").style.display = "none";
$("#seal").style.top = (150 + $("#title").offsetHeight + 18) + "px";
// sun
const sun = $("#sun"); sun.setAttribute("cx", C.sun.x); sun.setAttribute("cy", C.sun.y); sun.setAttribute("r", C.sun.r);
// ridge layers: far → near, each a midpoint-displacement skyline that fades into mist below
const layers = [
  {base: 760, amp: 150, tone: .28, blur: 2.4, fade: 170},
  {base: 840, amp: 140, tone: .45, blur: 1.4, fade: 150},
  {base: 920, amp: 120, tone: .66, blur: .7,  fade: 140},
  {base: 1010, amp: 90, tone: .88, blur: 0,   fade: 120}
];
const skyline = (base, amp) => {
  let pts = [[-40, base - amp * .2], [760, base - amp * .25]];
  let disp = amp;
  for (let it = 0; it < 7; it++) {
    const np = [];
    for (let i = 0; i < pts.length - 1; i++) {
      const [x0, y0] = pts[i], [x1, y1] = pts[i + 1];
      np.push(pts[i], [(x0 + x1) / 2 + (rnd() - .5) * (x1 - x0) * .25, (y0 + y1) / 2 - (rnd() - .35) * disp]);
    }
    np.push(pts.at(-1)); pts = np; disp *= .55;
  }
  // karst pinnacles: a few tall rounded spires added on top of the skyline
  const spires = [...Array(2 + Math.floor(rnd() * 2))].map(() => ({cx: 40 + rnd() * 640, w: 35 + rnd() * 45, h: amp * (.8 + rnd() * .9)}));
  return pts.map(([x, y]) => { for (const sp of spires) y -= sp.h * Math.exp(-(((x - sp.cx) / sp.w) ** 2)); return [x, Math.min(base + 40, y)]; });
};
const ridgeG = $("#ridges");
layers.forEach((L, i) => {
  const g = mk("linearGradient", {id: "rg" + i, x1: 0, y1: 0, x2: 0, y2: 1}, defs);
  const top = L.base - L.amp, bot = L.base + L.fade;
  g.setAttribute("gradientUnits", "userSpaceOnUse"); g.setAttribute("y1", top); g.setAttribute("y2", bot);
  const c = Math.round(235 - L.tone * 205);
  mk("stop", {offset: 0, "stop-color": `rgb(${c},${c - 1},${c - 4})`}, g);
  mk("stop", {offset: .55, "stop-color": `rgb(${c},${c - 1},${c - 4})`, "stop-opacity": .55}, g);
  mk("stop", {offset: 1, "stop-color": "#efebe2", "stop-opacity": 0}, g);
  const pts = skyline(L.base, L.amp);
  const d = "M" + pts.map(p => p[0].toFixed(1) + "," + p[1].toFixed(1)).join(" L") + ` L760,${bot} L-40,${bot} Z`;
  const p = mk("path", {d, fill: `url(#rg${i})`, class: "ridge", filter: L.blur ? "" : "url(#brush)"}, ridgeG);
  if (L.blur) { const f = mk("filter", {id: "rb" + i}, defs); mk("feGaussianBlur", {stdDeviation: L.blur}, f); p.setAttribute("filter", `url(#rb${i})`); }
});
// mist bands
const mistG = $("#mist");
[[760, 140], [870, 120], [980, 160]].forEach(([y, h], i) => mk("ellipse", {cx: 200 + i * 180, cy: y, rx: 420, ry: h / 2, fill: "#efebe2", opacity: .6, filter: "url(#mistblur)", class: "mistb"}, mistG));
// water strokes
const waterG = $("#water");
for (let i = 0; i < 9; i++) { const y = 1080 + i * 16 + rnd() * 6, x = 60 + rnd() * 420, w = 40 + rnd() * 140; mk("line", {x1: x, x2: x + w, y1: y, y2: y, class: "wv"}, waterG); }
// boat with a standing figure
if (C.boat) {
  const b = mk("g", {transform: "translate(420,1100)"}, $("#boat")); // inner group holds position; GSAP drifts the outer one
  mk("path", {d: "M-34,0 Q0,9 34,0 L28,-4 Q0,2 -28,-4 Z"}, b);
  mk("path", {d: "M6,-4 L8,-22 L11,-22 L12,-4 Z"}, b); mk("circle", {cx: 9.5, cy: -26, r: 3.6}, b);
  mk("line", {x1: 14, y1: -20, x2: 30, y2: 2, stroke: "#1f1e1c", "stroke-width": 1.4}, b);
}
// cliff, bottom-right, with a leaning pine
if (C.cliff) {
  $("#cliff").setAttribute("d", "M720,900 C680,906 656,940 646,990 C634,1046 606,1076 596,1124 C584,1176 562,1214 544,1280 L720,1280 Z");
  // leaning pine: trunk + flat layered foliage pads
  const pine = mk("g", {id: "pine", filter: "url(#brush)", fill: "#24231f"}, $("#art"));
  mk("path", {d: "M668,912 C650,880 628,858 596,846 L598,840 C632,850 656,872 676,906 Z"}, pine);
  [[600,838,46,9],[632,856,34,7],[566,848,30,6],[648,880,26,6]].forEach(([cx,cy,rx,ry]) => mk("ellipse", {cx, cy, rx, ry}, pine));
  $("#art").insertBefore(pine, $("#art rect:last-of-type"));
} else $("#cliff").remove();
// birds
const birdG = $("#birds"), birds = [];
for (let i = 0; i < C.birds; i++) { const g = mk("g", {}, birdG); mk("path", {d: "M-9,-3 Q-4,-7 0,0 Q4,-7 9,-3"}, g); birds.push({g, x: C.sun.x - 120 + i * 34 + rnd() * 20, y: C.sun.y - 110 - rnd() * 60 + i * 8, sc: .7 + rnd() * .5}); }

// timeline
const tl = gsap.timeline({paused:true});
tl.fromTo("#scene", {scale:1.06}, {scale:1, duration:8, ease:"power1.out"}, 0);
tl.from(".ridge", {opacity:0, y:40, duration:2.2, stagger:.35, ease:"power2.out"}, 0.1);
tl.fromTo(".mistb", {x:-60}, {x:60, duration:8, ease:"none"}, 0);
tl.fromTo(sun, {attr:{r:0}, opacity:0}, {attr:{r:C.sun.r}, opacity:1, duration:1.6, ease:"power3.out"}, 0.9);
tl.from(".wv", {attr:{x2:(i, el) => el.getAttribute("x1")}, opacity:0, duration:1.2, stagger:.06, ease:"power2.out"}, 1.6);
if (C.boat) tl.fromTo("#boat", {x:-60, opacity:0}, {x:60, opacity:1, duration:6, ease:"none"}, 2.0);
if (C.cliff) tl.from(["#cliff","#pine"], {opacity:0, x:40, duration:1.4, ease:"power2.out"}, 1.2);
birds.forEach((b, i) => { tl.fromTo(b.g, {attr:{transform:`translate(${b.x - 80},${b.y + 30}) scale(${b.sc})`}, opacity:0}, {attr:{transform:`translate(${b.x + 60},${b.y - 20}) scale(${b.sc})`}, opacity:1, duration:5.5, ease:"none"}, 2.2 + i * .25); });
tl.from("#title .ch", {opacity:0, y:-8, filter:"blur(6px)", duration:.7, stagger:.07, ease:"power2.out"}, 2.4);
tl.from("#sub", {opacity:0, duration:1.0}, 3.9);
tl.from("#seal", {opacity:0, scale:1.6, duration:.35, ease:"power4.out"}, 4.4);
tl.from("#chapter", {opacity:0, duration:1.0}, 4.6);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

Gotcha baked into the template: GSAP tweening `x` on an SVG `<g>` overwrites that group's `transform` attribute. That's why the boat's position lives on an inner group and GSAP drifts the outer `#boat`. Follow the same pattern for any new element you animate.

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors
npx hyperframes render --output ink-wash.mp4 --quality high
for t in 1 2.5 4 7.9; do ffmpeg -v error -y -ss $t -i ink-wash.mp4 -frames:v 1 f_$t.png; done
```

Look at the final frame. The title column and seal must end above the water lines (~y 1060); the sun must be clear of the title and the tallest spire; the boat should sit on the water between the title and the cliff. If the peaks look bad, change `seed` and re-render rather than hand-editing paths.

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. It is 720×1280 (9:16) and silent; a soft music bed can be added with HyperFrames' native `<audio>` clip if the user supplies a track.