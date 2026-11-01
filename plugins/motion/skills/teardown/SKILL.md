---
name: "teardown"
description: "Animate an exploded product view as a vertical 9:16 MP4: an isometric object lifts apart layer by layer and every part gets a numbered label. Use for /teardown."
---

# /teardown: exploded view, every part labelled

On a dark dotted backdrop, an assembled isometric object (by default a 21-key mechanical keyboard) rises into view, then separates vertically into its layers. Leader lines draw out to numbered labels ("01 Keycaps · PBT · 1u × 21"), followed by a title ("21 keys, opened") and a mono subtitle. Everything is drawn in SVG from a small layer spec, with no images. Output: 720×1280 MP4, 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

Good for: product breakdowns, "what's inside" posts, explaining a stack or architecture as physical layers (e.g. an AI system: model, tools, memory, interface), and hardware launches.

## 1. Get the content

The user usually pastes a short line (e.g. "21 keys, opened") and then types /teardown. Map it into CONFIG:

- `title`, `subtitle`: the caption block at the bottom
- `grid`: `cols × rows` cells and `pitch`. This sets the object's footprint and the number of keys, holes and chips.
- `layers`: bottom → top, 3–7 layers. Each has `name`, `spec` (one short line), `kind`, `h` (thickness), `color` (sides) and `top` (top face):
  - `tray`: an open case with a dark recess
  - `pins`: six small posts (standoffs, feet, connectors)
  - `slab`: a flat board; add `holes: true` for a plate with one cut-out per cell, or `chips: true` for a PCB with pads and a chip
  - `grid`: one block per cell (keys, switches, modules, server units); options: `inset`, `taper` (keycap slope), `stem` (a coloured nub on top), `accent` + `accentIndex` (one highlighted cell)
- `objectX`, `objectY`, `scale`, `gap`: placement, size, and exploded spacing

For non-keyboard subjects, reuse the kinds: e.g. a phone = tray (frame) → slab+chips (logic board) → slab (battery) → slab (display); a software stack = slab layers with a `grid` top layer for apps. Rules:
- Specs are factual claims; use what the user gave. If they name a real product, don't invent its internals: ask, or keep specs generic ("Main board", "Battery").
- Keep `name` under ~16 characters and `spec` under ~26 so labels fit the right column.

## 2. Set up the project

```bash
P=teardown-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/inter @fontsource/jetbrains-mono
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
cp node_modules/@fontsource/inter/files/inter-latin-{400,600,800}-normal.woff2 \
   node_modules/@fontsource/jetbrains-mono/files/jetbrains-mono-latin-{400,500}-normal.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (`--accent` in `:root` colours the numbers and title bar).

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
:root{--bg:#0c0c0e;--ink:#f3f1ec;--dim:#9b978f;--accent:#ff6a2b}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--bg)}
#root{position:relative;width:720px;height:1280px;overflow:hidden;background:radial-gradient(ellipse 80% 55% at 40% 45%,#1b1b1f 0%,var(--bg) 70%);font-family:Inter,sans-serif;color:var(--ink)}
#dots{position:absolute;inset:0;background-image:radial-gradient(#2a2a2e 1.2px,transparent 1.3px);background-size:22px 22px;opacity:.7}
#art{position:absolute;inset:0}
.lab{position:absolute;left:478px;width:220px}
.lab .n{font:500 15px Mono,monospace;color:var(--accent);margin-right:8px}
.lab .t{font:600 21px Inter,sans-serif}
.lab .s{font:400 14px/1.35 Mono,monospace;color:var(--dim);margin-top:4px;letter-spacing:.02em}
#title{position:absolute;left:44px;top:1060px}
#title .bar{width:34px;height:4px;background:var(--accent);margin-bottom:16px}
#title h1{font:800 46px/1.05 Inter,sans-serif;letter-spacing:-.02em}
#title p{font:400 16px Mono,monospace;color:var(--dim);margin-top:10px;letter-spacing:.08em;text-transform:uppercase}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <div id="dots" data-layout-ignore></div>
 <svg id="art" class="clip" data-start="0" data-duration="8" data-track-index="0" viewBox="0 0 720 1280" data-layout-ignore><g id="obj"></g><g id="leads"></g></svg>
 <div id="labs" class="clip" data-start="0" data-duration="8" data-track-index="1"></div>
 <div id="title" class="clip" data-start="0" data-duration="8" data-track-index="2"><div class="bar"></div><h1></h1><p></p></div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  title: "21 keys, opened",
  subtitle: "Exploded view · 6 layers · 19.05 mm pitch",
  grid: { cols: 7, rows: 3, pitch: 19 },   // key/cell grid shared by grid, plate holes and the footprint
  // layers bottom → top. kind: tray | pins | slab | grid. Labels are numbered from the top.
  layers: [
    { name: "Case",         spec: "Gasket mount · 6063 alloy", kind: "tray", h: 14, color: "#2b2b30", top: "#3a3a40" },
    { name: "Standoffs",    spec: "Brass · M2 × 6",            kind: "pins", h: 7,  color: "#b08a3e", top: "#d8b25a" },
    { name: "Circuit board",spec: "Hot-swap · RP2040",         kind: "slab", h: 2.5,color: "#1b5e37", top: "#227a46", chips: true },
    { name: "Plate",        spec: "1.5 mm aluminium",          kind: "slab", h: 2,  color: "#8c9197", top: "#b7bcc1", holes: true },
    { name: "Switches",     spec: "Linear · hot-swap",         kind: "grid", h: 7,  color: "#2a2a2e", top: "#38383d", stem: "#d8403a", inset: 2.5 },
    { name: "Keycaps",      spec: "PBT · 1u × 21",             kind: "grid", h: 9,  color: "#c9c7c2", top: "#f1efe9", accent: "#ff6a2b", accentIndex: 6, inset: 1, taper: 2.4 }
  ],
  objectX: 250, objectY: 600, scale: 2.05, gap: 66  // assembled position, size, and world-z gap between exploded layers
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s), NS = "http://www.w3.org/2000/svg";
const mk = (tag, a, parent) => { const e = document.createElementNS(NS, tag); for (const k in a) e.setAttribute(k, a[k]); parent.appendChild(e); return e; };
const TH = 30 * Math.PI / 180, PITCH = 58 * Math.PI / 180, S = C.scale, cT = Math.cos(TH), sT = Math.sin(TH), cP = Math.cos(PITCH), sP = Math.sin(PITCH);
const rot = (x, y) => [x * cT - y * sT, x * sT + y * cT];
const prj = (x, y, z = 0) => { const [xr, yr] = rot(x, y); return [S * xr, S * (yr * cP - z * sP)]; };
const pts = a => a.map(p => prj(...p).map(n => n.toFixed(1)).join(",")).join(" ");
const shade = (hex, f) => { const n = parseInt(hex.slice(1), 16); const c = [n >> 16, n >> 8 & 255, n & 255].map(v => Math.round(Math.min(255, v * f))); return `rgb(${c})`; };
const G = C.grid, W = G.cols * G.pitch + 12, D = G.rows * G.pitch + 12, X0 = -W / 2, Y0 = -D / 2;
const cells = []; for (let r = 0; r < G.rows; r++) for (let c = 0; c < G.cols; c++) cells.push({c, r, x: X0 + 6 + c * G.pitch, y: Y0 + 6 + r * G.pitch});
cells.sort((a, b) => rot(a.x, a.y)[1] - rot(b.x, b.y)[1]);
// frustum box: bottom rect at z0, top rect inset by `taper` at z0+h; draws visible sides + top
const sides = [[[0, -1], (a, b) => [a[0], a[1]]], [[1, 0], (a, b) => [a[1], a[2]]], [[0, 1], (a, b) => [a[2], a[3]]], [[-1, 0], (a, b) => [a[3], a[0]]]];
const box = (g, x0, y0, x1, y1, z0, h, side, top, taper = 0) => {
  const bot = [[x0, y0], [x1, y0], [x1, y1], [x0, y1]], tp = [[x0 + taper, y0 + taper], [x1 - taper, y0 + taper], [x1 - taper, y1 - taper], [x0 + taper, y1 - taper]];
  sides.forEach(([n], k) => { const [nx, ny] = rot(...n); if (ny <= 0) return; const i = k, j = (k + 1) % 4;
    mk("polygon", {points: pts([[...bot[i], z0], [...bot[j], z0], [...tp[j], z0 + h], [...tp[i], z0 + h]]), fill: shade(side, nx > 0 ? .72 : 1)}, g); });
  return mk("polygon", {points: pts(tp.map(p => [...p, z0 + h])), fill: top}, g);
};
// build each layer as a static group at z=0; the explode moves whole groups vertically on screen
const obj = $("#obj"), layerGs = [];
C.layers.forEach(L => {
  const g = mk("g", {}, obj); layerGs.push(g);
  if (L.kind === "tray") {
    box(g, X0 - 6, Y0 - 6, X0 + W + 6, Y0 + D + 6, 0, L.h, L.color, L.top);
    mk("polygon", {points: pts([[X0 + 1, Y0 + 1, L.h], [X0 + W - 1, Y0 + 1, L.h], [X0 + W - 1, Y0 + D - 1, L.h], [X0 + 1, Y0 + D - 1, L.h]]), fill: shade(L.color, .6)}, g);
  } else if (L.kind === "pins") {
    const spots = []; for (const fx of [.08, .5, .92]) for (const fy of [.15, .85]) spots.push([X0 + W * fx, Y0 + D * fy]);
    spots.sort((a, b) => rot(...a)[1] - rot(...b)[1]).forEach(([x, y]) => box(g, x - 2.2, y - 2.2, x + 2.2, y + 2.2, 0, L.h, L.color, L.top));
  } else if (L.kind === "slab") {
    box(g, X0, Y0, X0 + W, Y0 + D, 0, L.h, L.color, L.top);
    if (L.holes) cells.forEach(k => mk("polygon", {points: pts([[k.x + 2.5, k.y + 2.5, L.h], [k.x + G.pitch - 2.5, k.y + 2.5, L.h], [k.x + G.pitch - 2.5, k.y + G.pitch - 2.5, L.h], [k.x + 2.5, k.y + G.pitch - 2.5, L.h]]), fill: shade(L.color, .45)}, g));
    if (L.chips) {
      cells.forEach(k => { const [x, y] = prj(k.x + G.pitch / 2, k.y + G.pitch / 2, L.h); mk("ellipse", {cx: x, cy: y, rx: 3.2, ry: 2, fill: "#d9b45a"}, g); mk("ellipse", {cx: x + 7, cy: y + 3, rx: 1.6, ry: 1, fill: "#d9b45a"}, g); });
      const cx = X0 + W * .62, cy = Y0 + D * .5; box(g, cx - 7, cy - 7, cx + 7, cy + 7, L.h, 2, "#111114", "#1d1d21");
    }
  } else if (L.kind === "grid") {
    cells.forEach((k, idx) => {
      const isAcc = L.accent && (k.r * G.cols + k.c) === L.accentIndex, col = isAcc ? L.accent : L.color, top = isAcc ? shade(L.accent, 1.12) : L.top;
      const i = L.inset;
      box(g, k.x + i, k.y + i, k.x + G.pitch - i, k.y + G.pitch - i, 0, L.h, col, top, L.taper || 0);
      if (L.stem) { const m = G.pitch / 2; box(g, k.x + m - 2, k.y + m - 2, k.x + m + 2, k.y + m + 2, L.h, 2.5, L.stem, shade(L.stem, 1.2)); }
    });
  }
});
// stack heights (assembled) and exploded offsets, both as world z
const N = C.layers.length, zA = [], zE = []; let acc = 0;
C.layers.forEach((L, i) => { zA.push(acc); acc += L.kind === "pins" ? 0 : L.h; zE.push(i * C.gap); });
const explodedBase = 600 - prj(0, 0, zE[N - 1] / 2)[1]; // centres the exploded stack around y≈600
const baseY = t => C.objectY + (explodedBase - C.objectY) * t;
// each layer group moves on screen-y only (a z shift is a pure vertical move in this projection)
const yA = zA.map(z => baseY(0) + prj(0, 0, z)[1]), yE = zE.map(z => baseY(1) + prj(0, 0, z)[1]);
layerGs.forEach((g, i) => gsap.set(g, {x: C.objectX, y: yA[i]}));
// labels (numbered from the top layer) + leader lines from each layer's right corner
const labs = $("#labs"), leads = $("#leads"), corner = prj(X0 + W, Y0, 0);
const labEls = C.layers.map((L, i) => {
  const n = String(N - i).padStart(2, "0"), d = document.createElement("div");
  d.className = "lab"; d.innerHTML = `<div><span class="n">${n}</span><span class="t">${L.name}</span></div><div class="s">${L.spec}</div>`; labs.appendChild(d); return d;
});
const leadEls = C.layers.map(() => mk("path", {fill: "none", stroke: "#5b5852", "stroke-width": 1.2}, leads));
const layoutLabels = () => C.layers.forEach((L, i) => {
  const z = zE[i] + L.h; const [, dy] = prj(0, 0, z); const y = baseY(1) + dy + corner[1];
  const x = C.objectX + corner[0], ly = y - 8; labEls[i].style.top = (ly - 14) + "px";
  const d = `M${x + 6},${y} L${x + 30},${ly} L468,${ly}`; leadEls[i].setAttribute("d", d);
  const len = leadEls[i].getTotalLength(); leadEls[i].style.strokeDasharray = len; leadEls[i].dataset.len = len;
});
layoutLabels();
$("#title h1").textContent = C.title; $("#title p").textContent = C.subtitle;

const tl = gsap.timeline({paused:true});
tl.fromTo("#obj", {opacity: 0, y: 40}, {opacity: 1, y: 0, duration: .9, ease: "power3.out"}, .1);
layerGs.forEach((g, i) => tl.to(g, {y: yE[i], duration: 2.0, ease: "power3.inOut"}, 1.1));
const order = [...C.layers.keys()].reverse();
order.forEach((i, k) => {
  tl.fromTo(leadEls[i], {strokeDashoffset: +leadEls[i].dataset.len}, {strokeDashoffset: 0, duration: .45, ease: "power2.out"}, 2.7 + k * .22);
  tl.fromTo(labEls[i], {opacity: 0, x: 14}, {opacity: 1, x: 0, duration: .4, ease: "power3.out"}, 2.85 + k * .22);
});
tl.fromTo("#title", {opacity: 0, y: 20}, {opacity: 1, y: 0, duration: .6, ease: "power3.out"}, 4.4);
tl.fromTo("#art", {scale: 1}, {scale: 1.03, transformOrigin: "35% 45%", duration: 8, ease: "none"}, 0);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

Sizing: with 7 layers, lower `gap` to ~56; with 3–4 layers raise it to ~80. For a wider grid (e.g. 12 × 4), lower `scale` until the object's right corner stays left of the label column (x ≈ 470).

**Rendering rule:** never drive what's on screen from `onUpdate`/`onComplete` callbacks. The renderer sometimes seeks with events suppressed, so a callback-painted value freezes on random frames. Tween real properties (here each layer group's `y`).

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors
npx hyperframes render --output teardown.mp4 --quality high
for t in 0.8 2.0 3.4 7.8; do ffmpeg -v error -y -ss $t -i teardown.mp4 -frames:v 1 f_$t.png; done
```

Look at the final frame: no layer may overlap the next, the top layer must sit below ~y 150, each leader line must point at its own layer, and labels must not collide (if they do, raise `gap`).

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. It is 720×1280 (9:16) and silent.