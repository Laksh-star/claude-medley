---
name: "map-route"
description: "Animate a route on a 3D isometric city as a vertical 9:16 MP4: buildings rise, a blue route draws itself to a pinned destination, an ETA card slides up. Use for /map-route."
---

# /map-route: 3D city, a route that draws itself

A clean white isometric city (procedurally generated blocks, parks with trees, a river with bridges) builds outward from the starting point. A blue route then draws itself street by street with a moving marker while the camera pulls back from the start to frame the whole trip. A red pin drops on the destination with its label, and a white ETA card slides up ("18 min · 6.1 km · Avoids the flyover · Start"). Output: 720×1280 MP4, 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

Good for: "how to find us", venue or office directions, event invites, delivery or travel stories, "my commute" posts.

## 1. Get the content

The user usually pastes something like "Directions to Studio Eleven, 6.1 km" and then types /map-route. Map it into CONFIG:

- `destination`: the pin label; `eta`, `distance`, `note`, `button`: the bottom card
- `route`: waypoints as street intersections `[col, row]`. Consecutive points must share a column or a row (streets are a grid). Higher row = nearer the viewer. Keep it within about cols -4..4 and rows -6..6 so it stays on the generated city; 4–7 waypoints with 3–5 turns looks best.
- `river`: the block column that is water (or `null`); the route may cross it, and a bridge appears automatically there
- `parks`, `landmarks`: optional scenery and grey labels (`[name, col, row]`, fractions allowed)
- `seed`: changes the building layout

Rules:
- This is a stylised, generic city, not a real map. Never claim it shows real streets. If the user wants a real place, use real place names only as labels (destination, landmarks) and keep the city generic, or say that a real map needs a map provider.
- Use the user's real distance and time if given; otherwise leave the card fields as obvious placeholders and say so. Don't invent a precise ETA for a real trip.

## 2. Set up the project

```bash
P=map-route-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/inter
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js node_modules/gsap/dist/MotionPathPlugin.min.js .
cp node_modules/@fontsource/inter/files/inter-latin-{400,600,800}-normal.woff2 fonts/
```

GSAP, its MotionPath plugin and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (palette in `:root`).

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=720, height=1280" />
<script src="gsap.min.js"></script>
<script src="MotionPathPlugin.min.js"></script>
<style>
@font-face{font-family:Inter;src:url(fonts/inter-latin-400-normal.woff2) format("woff2");font-weight:400}
@font-face{font-family:Inter;src:url(fonts/inter-latin-600-normal.woff2) format("woff2");font-weight:600}
@font-face{font-family:Inter;src:url(fonts/inter-latin-800-normal.woff2) format("woff2");font-weight:800}
:root{--ground:#e7e6e2;--street:#f8f8f6;--top:#fdfdfc;--sideA:#dddcd8;--sideB:#c8c7c2;--park:#cde3c0;--tree:#86bd70;--water:#a8c9ea;--route:#1f66e0;--pin:#e8453c}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--ground)}
#root{position:relative;width:720px;height:1280px;overflow:hidden;background:var(--ground);font-family:Inter,sans-serif}
#map{position:absolute;inset:0}
.lbl{font:600 15px Inter,sans-serif;fill:#6b6a66;letter-spacing:.02em;paint-order:stroke;stroke:#f3f2ef;stroke-width:4px}
#card{position:absolute;left:32px;right:32px;top:1040px;background:#fff;border-radius:22px;padding:22px 24px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 18px 40px rgba(0,0,0,.14)}
#eta{font:800 44px/1 Inter,sans-serif;color:#111;letter-spacing:-.02em}
#sub{font:400 19px/1.3 Inter,sans-serif;color:#5d5c58;margin-top:8px}
#sub b{color:#12783a;font-weight:600}
#go{background:var(--route);color:#fff;font:600 22px Inter,sans-serif;padding:16px 30px;border-radius:14px}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <svg id="map" class="clip" data-start="0" data-duration="8" data-track-index="0" viewBox="0 0 720 1280" data-layout-ignore>
  <g id="cam"><g id="ground"></g><g id="routeG"></g><g id="bldg"></g><g id="labels"></g><g id="pinG"></g></g>
 </svg>
 <div id="card" class="clip" data-start="5.2" data-duration="2.8" data-track-index="1">
  <div><div id="eta"></div><div id="sub"></div></div><div id="go"></div>
 </div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  destination: "Studio Eleven",          // pin label at the end of the route
  eta: "18 min", distance: "6.1 km", note: "Avoids the flyover", button: "Start",
  // route waypoints as street intersections [col, row]; consecutive points must share a col or a row.
  // cols run -8..8, rows -10..10 (higher row = nearer the viewer); keep the route within about cols -4..4, rows -6..6. Start = first point.
  route: [[-4,5],[-4,3],[-1,3],[-1,0],[2,0],[2,-3]],
  river: 1,                               // block column that is a river (null for none); streets cross it as bridges
  parks: [[-2,-3],[3,-2],[-5,1],[4,3],[-2,6]],     // block [col,row] that are parks
  landmarks: [["Old Market",-4,4.2],["Metro Junction",0.4,1.6],["Lakeside",1.1,4.4]], // [name, col, row] (fractions ok)
  seed: 5
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s), NS = "http://www.w3.org/2000/svg";
let sd = C.seed >>> 0; const rnd = () => { sd = (sd + 0x6D2B79F5) >>> 0; let t = sd; t = Math.imul(t ^ t >>> 15, t | 1); t ^= t + Math.imul(t ^ t >>> 7, t | 61); return ((t ^ t >>> 14) >>> 0) / 4294967296; };
const mk = (tag, a, parent) => { const e = document.createElementNS(NS, tag); for (const k in a) e.setAttribute(k, a[k]); parent.appendChild(e); return e; };
const css = v => getComputedStyle(document.documentElement).getPropertyValue(v).trim();
// projection: rotate world about z, then tilt
const P = 72, B = 50, TH = -35 * Math.PI / 180, PITCH = 40 * Math.PI / 180, S = .95, CX = 360, CY = 600;
const cT = Math.cos(TH), sT = Math.sin(TH), cP = Math.cos(PITCH), sP = Math.sin(PITCH);
const rot = (x, y) => [x * cT - y * sT, x * sT + y * cT];
const prj = (x, y, z = 0) => { const [xr, yr] = rot(x, y); return [CX + S * xr, CY + S * (yr * cP - z * sP)]; };
const pts = a => a.map(p => prj(...p).map(n => n.toFixed(1)).join(",")).join(" ");
const COLS = [-8, 8], ROWS = [-10, 10], X0 = (COLS[0] - 1.5) * P, X1 = (COLS[1] + 1.5) * P, Y0 = (ROWS[0] - 1.5) * P, Y1 = (ROWS[1] + 1.5) * P;
const isPark = (i, j) => C.parks.some(p => p[0] === i && p[1] === j);
const ground = $("#ground");
mk("polygon", {points: pts([[X0, Y0], [X1, Y0], [X1, Y1], [X0, Y1]]), fill: css("--ground")}, ground);
// streets: vertical (constant x), then river, then horizontal streets (which become bridges over the river)
const SW = P - B;
for (let i = COLS[0] - 1; i <= COLS[1]; i++) { const x = i * P + P / 2; mk("polygon", {points: pts([[x - SW / 2, Y0], [x + SW / 2, Y0], [x + SW / 2, Y1], [x - SW / 2, Y1]]), fill: css("--street")}, ground); }
if (C.river !== null) { const x = C.river * P; mk("polygon", {points: pts([[x - P / 2 + 4, Y0], [x + P / 2 - 4, Y0], [x + P / 2 - 4, Y1], [x - P / 2 + 4, Y1]]), fill: css("--water")}, ground); }
// horizontal streets; across the river only every 3rd row (and wherever the route crosses) becomes a bridge
const routeRows = new Set(); C.route.forEach((p, k) => { if (k && p[1] === C.route[k - 1][1]) routeRows.add(p[1]); });
const hStreet = (y, xa, xb) => mk("polygon", {points: pts([[xa, y - SW / 2], [xb, y - SW / 2], [xb, y + SW / 2], [xa, y + SW / 2]]), fill: css("--street")}, ground);
for (let j = ROWS[0] - 1; j <= ROWS[1]; j++) {
  const y = j * P + P / 2;
  if (C.river === null || j % 3 === 0 || routeRows.has(j)) { hStreet(y, X0, X1); continue; }
  hStreet(y, X0, C.river * P - P / 2 + 4); hStreet(y, C.river * P + P / 2 - 4, X1);
}
// blocks → parks or buildings
const blds = [];
// keep buildings low beside the route so the line stays visible from this angle
const segs = C.route.slice(1).map((p, k) => [C.route[k].map(n => n * P + P / 2), p.map(n => n * P + P / 2)]);
const nearRoute = (x, y) => segs.some(([[ax, ay], [bx, by]]) => { const t = Math.max(0, Math.min(1, ((x - ax) * (bx - ax) + (y - ay) * (by - ay)) / ((bx - ax) ** 2 + (by - ay) ** 2 || 1))); return Math.hypot(x - ax - t * (bx - ax), y - ay - t * (by - ay)) < P * .9; });
for (let i = COLS[0]; i <= COLS[1]; i++) for (let j = ROWS[0]; j <= ROWS[1]; j++) {
  if (i === C.river) continue;
  const bx = i * P, by = j * P;
  if (isPark(i, j)) {
    mk("polygon", {points: pts([[bx - B / 2, by - B / 2], [bx + B / 2, by - B / 2], [bx + B / 2, by + B / 2], [bx - B / 2, by + B / 2]]), fill: css("--park")}, ground);
    for (let k = 0; k < 5; k++) blds.push({tree: true, x: bx + (rnd() - .5) * (B - 14), y: by + (rnd() - .5) * (B - 14)});
    continue;
  }
  const centre = 1 - Math.min(1, Math.hypot(i, j) / 8);
  const split = rnd() < .6, lots = split ? [[-1, -1], [1, -1], [-1, 1], [1, 1]] : [[0, 0]];
  lots.forEach(([u, v]) => {
    const w = split ? B / 2 - 3 : B - 4, cx = bx + u * B / 4, cy = by + v * B / 4;
    let h = 10 + rnd() * 20 + centre * 36 * rnd(); if (nearRoute(cx, cy)) h = 6 + rnd() * 6;
    blds.push({x0: cx - w / 2, x1: cx + w / 2, y0: cy - w / 2, y1: cy + w / 2, h});
  });
}
// paint order: far → near
blds.forEach(b => { const cx = b.tree ? b.x : (b.x0 + b.x1) / 2, cy = b.tree ? b.y : (b.y0 + b.y1) / 2; b.key = rot(cx, cy)[1]; b.cx = cx; b.cy = cy; });
blds.sort((a, b) => a.key - b.key);
const bG = $("#bldg"), start = C.route[0].map(n => n * P + P / 2);
const maxD = Math.hypot(X1 - X0, Y1 - Y0) / 2;
const faces = [[[0, -1], b => [[b.x0, b.y0], [b.x1, b.y0]]], [[1, 0], b => [[b.x1, b.y0], [b.x1, b.y1]]], [[0, 1], b => [[b.x1, b.y1], [b.x0, b.y1]]], [[-1, 0], b => [[b.x0, b.y1], [b.x0, b.y0]]]];
// each polygon gets its flat (h=0) and full-height point strings; GSAP tweens the numbers inside the attribute,
// so the rise is exact geometry and needs no update callbacks (the renderer may skip those when it seeks)
const sidePts = (e, h) => { const [[ax, ay], [bx2, by2]] = e; return pts([[ax, ay, 0], [bx2, by2, 0], [bx2, by2, h], [ax, ay, h]]); };
const topPts = (b, h) => pts([[b.x0, b.y0, h], [b.x1, b.y0, h], [b.x1, b.y1, h], [b.x0, b.y1, h]]);
blds.forEach(b => {
  b.delay = Math.hypot(b.cx - start[0], b.cy - start[1]) / maxD;
  if (b.tree) { const [x, y] = prj(b.x, b.y, 7); b.el = mk("circle", {cx: x, cy: y, r: 6.5, fill: css("--tree")}, bG); return; }
  b.polys = faces.filter(([n]) => rot(n[0], n[1])[1] > 0).map(([n, edge]) => { const e = edge(b);
    return {el: mk("polygon", {points: sidePts(e, .01), fill: rot(n[0], n[1])[0] > 0 ? css("--sideB") : css("--sideA"), stroke: "#bdbcb7", "stroke-width": .4}, bG), to: sidePts(e, b.h)}; });
  b.polys.push({el: mk("polygon", {points: topPts(b, .01), fill: css("--top"), stroke: "#d6d5d1", "stroke-width": .5}, bG), to: topPts(b, b.h)});
});
// route on the street layer (buildings in front correctly occlude it)
const rG = $("#routeG"), wpt = C.route.map(([a, b]) => prj(a * P + P / 2, b * P + P / 2));
const dRoute = "M" + wpt.map(p => p.map(n => n.toFixed(1)).join(",")).join(" L");
const casing = mk("path", {d: dRoute, fill: "none", stroke: "#fff", "stroke-width": 15, "stroke-linejoin": "round", "stroke-linecap": "round"}, rG);
const line = mk("path", {d: dRoute, fill: "none", stroke: css("--route"), "stroke-width": 9, "stroke-linejoin": "round", "stroke-linecap": "round"}, rG);
const L = line.getTotalLength();
[casing, line].forEach(p => { p.style.strokeDasharray = L + 2; p.style.strokeDashoffset = L + 2; });
// start pulse + moving head (drawn above buildings so it never hides)
const pinG = $("#pinG");
const pulse = mk("circle", {cx: wpt[0][0], cy: wpt[0][1], r: 10, fill: "none", stroke: css("--route"), "stroke-width": 3, opacity: 0}, pinG);
const head = mk("g", {}, pinG); mk("circle", {r: 13, fill: css("--route"), opacity: .22}, head); mk("circle", {r: 8, fill: css("--route"), stroke: "#fff", "stroke-width": 3}, head);
gsap.registerPlugin(MotionPathPlugin);
gsap.set(head, {x: wpt[0][0], y: wpt[0][1]});
// destination pin with label
const [ex, ey] = wpt.at(-1), pin = mk("g", {transform: `translate(${ex},${ey})`}, pinG), pinIn = mk("g", {}, pin);
mk("path", {d: "M0,0 C-4,-10 -14,-18 -14,-30 A14,14 0 1 1 14,-30 C14,-18 4,-10 0,0 Z", fill: css("--pin"), stroke: "#fff", "stroke-width": 2.5}, pinIn);
mk("circle", {cy: -30, r: 5, fill: "#fff"}, pinIn);
const tag = mk("g", {transform: "translate(22,-48)"}, pinIn);
const tagText = mk("text", {x: 14, y: 21, "font-family": "Inter", "font-weight": 600, "font-size": 17, fill: "#1a1a1a"}, tag); tagText.textContent = C.destination;
const tw = tagText.getComputedTextLength() + 28; tag.insertBefore(mk("rect", {width: tw, height: 32, rx: 9, fill: "#fff", stroke: "#e4e3df"}, tag), tagText);
// landmarks
const lab = $("#labels");
C.landmarks.forEach(([n, i, j]) => { const [x, y] = prj(i * P, j * P, 60); const t = mk("text", {x, y, "text-anchor": "middle", class: "lbl"}, lab); t.textContent = n; });
// card
$("#eta").textContent = C.eta; $("#sub").innerHTML = `${C.distance} · <b>${C.note}</b>`; $("#go").textContent = C.button;
// camera: start close on the start point, end framing the whole route above the card
const xs = wpt.map(p => p[0]), ys = wpt.map(p => p[1]);
const bw = Math.max(...xs) - Math.min(...xs) + 160, bh = Math.max(...ys) - Math.min(...ys) + 220;
const endS = Math.min(1.6, 640 / bw, 860 / bh), endC = [(Math.max(...xs) + Math.min(...xs)) / 2, (Math.max(...ys) + Math.min(...ys)) / 2 - 30];
const camTo = (x, y, s) => ({x: 360 - x * s, y: 560 - y * s, scale: s});
gsap.set("#cam", {svgOrigin: "0 0", ...camTo(wpt[0][0], wpt[0][1], 2.0)});

const tl = gsap.timeline({paused:true});
blds.forEach(b => { const t0 = b.delay * 1.6;
  if (b.tree) tl.fromTo(b.el, {attr: {r: 0}}, {attr: {r: 6.5}, duration: .5, ease: "back.out(2)"}, t0);
  else b.polys.forEach(p => tl.to(p.el, {attr: {points: p.to}, duration: .55, ease: "power3.out"}, t0)); });
tl.fromTo(lab.children, {opacity: 0}, {opacity: 1, duration: .6, stagger: .15}, 1.2);
tl.fromTo(pulse, {attr: {r: 8}, opacity: .9}, {attr: {r: 30}, opacity: 0, duration: 1.2, repeat: 1, ease: "power1.out"}, .6);
tl.to([casing, line], {strokeDashoffset: 0, duration: 3.6, ease: "power1.inOut"}, 1.2);
tl.to(head, {motionPath: {path: line}, duration: 3.6, ease: "power1.inOut"}, 1.2);
tl.to("#cam", {...camTo(endC[0], endC[1], endS), duration: 4.4, ease: "power2.inOut"}, .4);
tl.fromTo(pinIn, {scale: 0, transformOrigin: "50% 100%"}, {scale: 1, duration: .5, ease: "back.out(2.2)"}, 4.7);
tl.fromTo(head, {opacity: 1}, {opacity: 0, duration: .25}, 4.8);
tl.fromTo("#card", {y: 160, opacity: 0}, {y: 0, opacity: 1, duration: .6, ease: "power3.out"}, 5.2);
tl.to("#cam", {...camTo(endC[0], endC[1], endS * 1.03), duration: 2.4, ease: "none"}, 5.6);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

How it stays readable: buildings within about one block of the route are capped low, and the camera pitch is 40°, so the route isn't hidden behind towers. If a custom route still disappears behind buildings, shorten the legs that run toward the viewer (changing row) or move the route into the middle of the grid.

**Rendering rule:** never drive what's on screen from `onUpdate`/`onComplete` callbacks. The renderer sometimes seeks with events suppressed, so a callback-painted value freezes on random frames. This template tweens real properties instead: polygon `points` (GSAP interpolates the numbers in the string), `strokeDashoffset`, MotionPath for the marker, and transforms for the camera. Keep it that way when editing.

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors
npx hyperframes render --output map-route.mp4 --quality high
for t in 0.8 2.2 3.6 5.0 7.8; do ffmpeg -v error -y -ss $t -i map-route.mp4 -frames:v 1 f_$t.png; done
```

Look at the frames. The route should be visible along its whole length by 5 s, the pin label must not run off the right edge (if it does, flip the route so it ends further left), and the ETA card must not cover the destination pin. Rendering takes longer than the other styles (~900 buildings); that's normal.

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. It is 720×1280 (9:16) and silent.