---
name: "phone-mockup"
description: "Animate an app showcase as a vertical 9:16 MP4: a phone floats in with a live dashboard screen while UI cards pop out around it. Use for /phone-mockup."
---

# /phone-mockup: phone with floating UI cards

On a soft light-grey stage, a phone rises in at a 3D tilt and settles. Its screen comes alive: the headline number counts up, a sparkline draws, action buttons and a transaction list fade in. Three white UI cards then pop out around the phone (a notification, a goal card with a progress bar, a progress ring) and float gently. Everything is HTML/CSS, with no screenshots needed. Output: 720×1280 MP4, 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

Good for: app launches and product posts, feature announcements, SaaS dashboards, "what the product does" reels. The screen layout (hero metric → chart → actions → list) fits finance, fitness, analytics, learning and streaming apps by relabelling.

## 1. Get the content

The user usually pastes an app name or tagline and then types /phone-mockup. Map it into CONFIG:

- `headline`: the line above the phone ("" to drop)
- `appName`, `balanceLabel`, `prefix`, `balance`, `decimals`, `delta`: the screen's hero metric (e.g. "Watch time this week", "", 1240, " min" goes in `delta`)
- `spark`: the shape of the in-app chart; `actions`: four short button labels
- `transactions`: three list rows `[title, subtitle, value, colour]` (a value starting with `+` turns green)
- `card1` / `card2` / `card3`: the floating notification, goal-with-progress-bar, and ring cards

Rules:
- This is a mock-up. Use the user's app name, or a clearly fictional one; never imitate a real company's app, logo or brand colours (no bank, Apple, Google lookalikes).
- Values on the screen are UI copy, not claims. If the user wants real metrics presented as facts, use their numbers; otherwise keep them obviously illustrative.

## 2. Set up the project

```bash
P=phone-mockup-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/inter
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
cp node_modules/@fontsource/inter/files/inter-latin-{400,600,800}-normal.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (`--accent` green and `--accent2` blue in `:root`).

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
:root{--bg1:#eef0f3;--bg2:#d9dde3;--ink:#121417;--dim:#5f6670;--accent:#1f9d55;--accent2:#2563eb;--card:#ffffff}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--bg1)}
#root{position:relative;width:720px;height:1280px;overflow:hidden;background:radial-gradient(ellipse 70% 50% at 50% 42%,#fbfbfc 0%,var(--bg1) 45%,var(--bg2) 100%);font-family:Inter,sans-serif;color:var(--ink)}
#head{position:absolute;left:0;right:0;top:140px;text-align:center;font:800 40px/1.1 Inter,sans-serif;letter-spacing:-.02em}
#stage{position:absolute;inset:0;perspective:1600px}
#phone{position:absolute;left:200px;top:290px;width:320px;height:660px;border-radius:52px;background:#111;padding:11px;box-shadow:0 0 0 2px #2b2b2e inset,0 50px 80px rgba(20,25,35,.28),0 12px 24px rgba(20,25,35,.18);transform-style:preserve-3d}
#screen{position:relative;width:100%;height:100%;border-radius:42px;background:#f7f8fa;overflow:hidden}
#island{position:absolute;left:50%;top:10px;width:96px;height:28px;margin-left:-48px;background:#000;border-radius:16px;z-index:3}
.sb{display:flex;justify-content:space-between;padding:14px 26px 0;font:600 14px Inter,sans-serif}
.app{padding:22px 20px 0}
.row{display:flex;justify-content:space-between;align-items:center}
.appname{font:800 19px Inter,sans-serif}
.av{width:32px;height:32px;border-radius:50%;background:linear-gradient(135deg,#f5b26b,#e2683c)}
.lbl{font:400 14px Inter,sans-serif;color:var(--dim);margin-top:20px}
#bal{font:800 40px/1.1 Inter,sans-serif;letter-spacing:-.03em;margin-top:4px}
#delta{display:inline-block;margin-top:8px;background:#e3f5ea;color:#13753d;font:600 13px Inter,sans-serif;padding:4px 9px;border-radius:20px}
#spark{display:block;margin:14px -4px 0}
.acts{display:flex;justify-content:space-between;margin-top:14px}
.act{display:flex;flex-direction:column;align-items:center;gap:6px;font:600 11.5px Inter,sans-serif;color:#3b4149;width:60px}
.act i{width:44px;height:44px;border-radius:50%;background:#e9ecf1;display:block;position:relative}
.act i::after{content:"";position:absolute;inset:15px;border-radius:4px;background:var(--accent2);opacity:.85}
.list{margin-top:18px;background:#fff;border-radius:18px;padding:6px 14px}
.tx{display:flex;align-items:center;gap:11px;padding:10px 0;border-bottom:1px solid #eef0f3}
.tx:last-child{border:0}
.tx i{width:34px;height:34px;border-radius:10px;display:block}
.tx .n{font:600 14px Inter,sans-serif}.tx .s{font:400 12px Inter,sans-serif;color:var(--dim)}
.tx .a{margin-left:auto;font:600 14px Inter,sans-serif}
.float{position:absolute;background:var(--card);border-radius:18px;box-shadow:0 20px 40px rgba(20,25,35,.16),0 4px 10px rgba(20,25,35,.08);padding:14px 16px;font-family:Inter,sans-serif}
#f1{left:40px;top:244px;width:262px;display:flex;gap:12px;align-items:center}
#f1 i{width:40px;height:40px;border-radius:12px;background:var(--accent);flex:none}
#f1 .t{font:600 16px Inter,sans-serif}#f1 .x{font:400 14px Inter,sans-serif;color:var(--dim);margin-top:2px}
#f2{left:488px;top:600px;width:212px}
#f2 .t{font:600 14px Inter,sans-serif;color:var(--dim)}#f2 .v{font:800 28px Inter,sans-serif;letter-spacing:-.02em;margin:4px 0 10px}
#f2 .bar{height:9px;border-radius:9px;background:#e8ebf0;overflow:hidden}#f2 .bar b{display:block;height:100%;width:0;background:var(--accent2);border-radius:9px}
#f2 .p{font:400 13px Inter,sans-serif;color:var(--dim);margin-top:8px}
#f3{left:14px;top:850px;width:206px;display:flex;align-items:center;gap:12px}
#f3 .t{font:600 16px Inter,sans-serif}#f3 .x{font:400 13px Inter,sans-serif;color:var(--dim)}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <div id="head" class="clip" data-start="0" data-duration="8" data-track-index="3"></div>
 <div id="stage" class="clip" data-start="0" data-duration="8" data-track-index="0">
  <div id="phone"><div id="screen"><div id="island"></div>
   <div class="sb"><span>9:41</span><span>●●● ▮</span></div>
   <div class="app">
    <div class="row"><div class="appname" id="appName"></div><div class="av"></div></div>
    <div class="lbl" id="balLabel"></div><div id="bal"></div><div id="delta"></div>
    <svg id="spark" width="288" height="86" viewBox="0 0 288 86"></svg>
    <div class="acts" id="acts"></div>
    <div class="list" id="list"></div>
   </div>
  </div></div>
  <div class="float" id="f1"><i></i><div><div class="t"></div><div class="x"></div></div></div>
  <div class="float" id="f2"><div class="t"></div><div class="v"></div><div class="bar"><b></b></div><div class="p"></div></div>
  <div class="float" id="f3"><svg width="58" height="58" viewBox="0 0 58 58"><circle cx="29" cy="29" r="23" fill="none" stroke="#e8ebf0" stroke-width="7"/><circle id="ring" cx="29" cy="29" r="23" fill="none" stroke="var(--accent)" stroke-width="7" stroke-linecap="round" transform="rotate(-90 29 29)"/><text id="ringTxt" x="29" y="34" text-anchor="middle" font-family="Inter" font-weight="800" font-size="14" fill="#121417"></text></svg><div><div class="t"></div><div class="x"></div></div></div>
 </div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  headline: "Your watchlist, sorted",    // above the phone ("" to drop)
  appName: "Reelbook",                    // fictional app name or the user's own app
  balanceLabel: "Films watched this year", prefix: "", balance: 148, decimals: 0,
  delta: "▲ 12 this month",
  spark: [3, 5, 4, 7, 6, 9, 8, 10, 12, 11, 14, 15],             // shape of the in-app chart
  actions: ["Watch", "Lists", "Friends", "More"],
  transactions: [["Night Train", "Tonight · Drama", "2h 18m", "#f4b860"], ["Long Interval", "Yesterday · Classic", "+1", "#4cc38a"], ["Monsoon Reel", "Mon · Series", "Ep 4", "#7aa2f7"]],
  card1: { title: "New episode", text: "Monsoon Reel · Ep 5 is out" },
  card2: { title: "Yearly goal", value: "148 films", progress: .74, note: "74% of 200" },
  card3: { title: "Queued", text: "3 films this weekend", ring: .6 }
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s), NS = "http://www.w3.org/2000/svg";
$("#head").textContent = C.headline; if (!C.headline) $("#head").style.display = "none";
$("#appName").textContent = C.appName; $("#balLabel").textContent = C.balanceLabel; $("#delta").textContent = C.delta;
const fmt = v => C.prefix + v.toLocaleString("en-US", {minimumFractionDigits: C.decimals, maximumFractionDigits: C.decimals});
$("#bal").textContent = fmt(C.balance);
$("#acts").innerHTML = C.actions.map(a => `<div class="act"><i></i>${a}</div>`).join("");
$("#list").innerHTML = C.transactions.map(([n, s, a, c]) => `<div class="tx"><i style="background:${c}"></i><div><div class="n">${n}</div><div class="s">${s}</div></div><div class="a" style="color:${a.startsWith("+") ? "#13753d" : "#121417"}">${a}</div></div>`).join("");
$("#f1 .t").textContent = C.card1.title; $("#f1 .x").textContent = C.card1.text;
$("#f2 .t").textContent = C.card2.title; $("#f2 .v").textContent = C.card2.value; $("#f2 .p").textContent = C.card2.note;
$("#f3 .t").textContent = C.card3.title; $("#f3 .x").textContent = C.card3.text; $("#ringTxt").textContent = Math.round(C.card3.ring * 100) + "%";
// spark chart
const sv = $("#spark"), mn = Math.min(...C.spark), mx = Math.max(...C.spark);
const sp = C.spark.map((v, i) => [4 + i * 280 / (C.spark.length - 1), 78 - (v - mn) / (mx - mn || 1) * 66]);
const line = "M" + sp.map(p => p.map(n => n.toFixed(1)).join(",")).join(" L");
sv.innerHTML = `<defs><linearGradient id="sg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1f9d55" stop-opacity=".22"/><stop offset="1" stop-color="#1f9d55" stop-opacity="0"/></linearGradient></defs><path id="sArea" d="${line} L284,86 L4,86 Z" fill="url(#sg)"/><path id="sLine" d="${line}" fill="none" stroke="#1f9d55" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>`;
const sLine = $("#sLine"), sL = sLine.getTotalLength(); sLine.style.strokeDasharray = sL; sLine.style.strokeDashoffset = sL;
const ring = $("#ring"), rL = 2 * Math.PI * 23; ring.style.strokeDasharray = rL; ring.style.strokeDashoffset = rL;


const tl = gsap.timeline({paused:true});
tl.fromTo("#head", {opacity: 0, y: 16}, {opacity: 1, y: 0, duration: .6, ease: "power3.out"}, .2);
tl.fromTo("#phone", {y: 700, rotationX: 28, rotationY: -22, rotationZ: 6}, {y: 0, rotationX: 8, rotationY: -12, rotationZ: 2, duration: 1.3, ease: "power3.out"}, .1);
tl.to("#phone", {rotationX: 3, rotationY: -5, rotationZ: 0, duration: 6, ease: "sine.inOut"}, 1.4);
tl.fromTo("#bal", {textContent: 0}, {textContent: C.balance, duration: 1.8, ease: "power2.out", modifiers: {textContent: v => fmt(+v)}}, 1.0);
tl.to(sLine, {strokeDashoffset: 0, duration: 1.4, ease: "power1.inOut"}, 1.2);
tl.fromTo("#sArea", {opacity: 0}, {opacity: 1, duration: .8}, 2.2);
tl.fromTo(".act", {opacity: 0, y: 10}, {opacity: 1, y: 0, duration: .35, stagger: .07}, 1.5);
tl.fromTo(".tx", {opacity: 0, y: 12}, {opacity: 1, y: 0, duration: .4, stagger: .1}, 1.8);
tl.fromTo("#f1", {opacity: 0, x: -80, scale: .9}, {opacity: 1, x: 0, scale: 1, duration: .6, ease: "back.out(1.5)"}, 2.4);
tl.fromTo("#f2", {opacity: 0, x: 80, scale: .9}, {opacity: 1, x: 0, scale: 1, duration: .6, ease: "back.out(1.5)"}, 3.0);
tl.fromTo("#f2 .bar b", {width: "0%"}, {width: C.card2.progress * 100 + "%", duration: 1.0, ease: "power2.out"}, 3.4);
tl.fromTo("#f3", {opacity: 0, x: -80, scale: .9}, {opacity: 1, x: 0, scale: 1, duration: .6, ease: "back.out(1.5)"}, 3.6);
tl.to(ring, {strokeDashoffset: rL * (1 - C.card3.ring), duration: 1.1, ease: "power2.out"}, 3.9);
// gentle float on each card after arrival
[["#f1", 3.0, -8], ["#f2", 3.6, 9], ["#f3", 4.2, -7]].forEach(([s, t, dy]) => tl.to(s, {y: dy, duration: 1.6, ease: "sine.inOut", yoyo: true, repeat: Math.floor((8 - t) / 1.6) - 1}, t));
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

Layout notes: the floating cards are placed to overlap only the phone's bezel, never its screen text. If you make card text longer, widen the card outward (decrease `left` for #f1/#f3), not inward. Keep list titles under ~14 characters and the hero number under ~9 characters.

**Rendering rule:** never drive what's on screen from `onUpdate`/`onComplete` callbacks. The renderer sometimes seeks with events suppressed, so a callback-painted value freezes on random frames. The counter here tweens `textContent` directly and formats it with a GSAP `modifiers` function, which runs on every render; use the same pattern for any number.

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors (a text_occluded error means a card covers screen text: move the card)
npx hyperframes render --output phone-mockup.mp4 --quality high
for t in 0.7 2.0 3.4 7.8; do ffmpeg -v error -y -ss $t -i phone-mockup.mp4 -frames:v 1 f_$t.png; done
```

Look at the frames: the counter must read correctly mid-count (formatted, no long decimals) and land on the exact `balance` value; no card may cover the app name, hero number or list values.

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. It is 720×1280 (9:16) and silent.