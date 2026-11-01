---
name: "ui-walkthrough"
description: "Animate a product click-through as a vertical 9:16 MP4: a cursor clicks a button, picks a menu item, sets options in a dialog and confirms, with numbered step captions. Use for /ui-walkthrough."
---

# /ui-walkthrough: cursor clicks through a flow, step captions

A dark desktop app window (title bar, preview canvas, editing timeline) sits on a soft teal backdrop. A cursor clicks the top-right button, the camera zooms in, a dropdown opens and the cursor picks an item. A dialog opens with tabs and settings; the cursor drags a slider, then clicks the primary action. A progress bar fills, the dialog closes, the camera pulls back and a success toast slides in. Numbered black caption pills ("1 Open Publish", "2 Pick size & bitrate", "3 Hit Render") narrate each beat. Output: 720×1280 MP4, 8 s, rendered locally with HyperFrames (HTML + GSAP → MP4).

Good for: "how to do X in our product" tips, feature demos, onboarding snippets, release-note reels. The beat structure (button → menu item → dialog with fields and a slider → primary action → toast) covers most SaaS flows: Share → Export, New → Invoice → Send, Settings → Integrations → Connect.

## 1. Get the content

The user usually pastes a short task (e.g. "Render the trailer as a vertical master") and then types /ui-walkthrough. Map it into CONFIG:

- `windowTitle`, `windowSub`: the app window's title bar
- `trigger`: the top-right button clicked first; `menu` + `menuPick`: the dropdown items and the index the cursor picks
- `dialogTitle`, `tabs`, `fields` (`[label, value]` rows, 2–4), `slider` (label, from/to positions 0–1 and their texts)
- `action`: the dialog's primary button; `toast`: the success message
- `steps`: exactly three caption texts, one per beat (≤ 24 characters each)

Rules:
- The window is a generic editor mock-up. Use the user's product name and real menu wording if they give it; never recreate a real company's UI, logo or brand look (no Figma/Notion/Canva lookalikes).
- If the user's real flow has no slider, set `slider.label` to a real setting and keep the drag; or say the flow was simplified.

## 2. Set up the project

```bash
P=ui-walkthrough-$(date +%Y%m%d-%H%M%S)
npx -y hyperframes init "$P" >/dev/null && cd "$P"
npm i --no-save gsap@3.13.0 @fontsource/inter @fontsource/jetbrains-mono
mkdir -p fonts && cp node_modules/gsap/dist/gsap.min.js .
cp node_modules/@fontsource/inter/files/inter-latin-{400,600,800}-normal.woff2 \
   node_modules/@fontsource/jetbrains-mono/files/jetbrains-mono-latin-400-normal.woff2 fonts/
```

GSAP and the fonts are vendored locally on purpose: CDNs are often blocked in sandboxes and the render then fails with `SUB_TIMELINE_SCRIPT_FAILURE`. If the render reports that no Chrome was found: `export HYPERFRAMES_BROWSER_PATH="$(find / -name chrome -type f -path '*chrom*' 2>/dev/null | head -1)"`.

## 3. Write index.html

Overwrite the scaffolded `index.html` with this template and edit only the CONFIG block (backdrop and accent in `:root`).

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
:root{--bg1:#d6ebe6;--bg2:#a9cfc7;--win:#1b1c20;--panel:#24262b;--line:#33363d;--ink:#eceef1;--dim:#9aa0aa;--accent:#2563eb}
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:720px;height:1280px;overflow:hidden;background:var(--bg1)}
#root{position:relative;width:720px;height:1280px;overflow:hidden;background:linear-gradient(160deg,var(--bg1),var(--bg2));font-family:Inter,sans-serif}
#cam{position:absolute;inset:0;transform-origin:0 0}
#win{position:absolute;left:40px;top:300px;width:640px;height:640px;background:var(--win);border-radius:18px;box-shadow:0 40px 80px rgba(10,40,35,.35);overflow:hidden;color:var(--ink)}
.bar{height:62px;display:flex;align-items:center;padding:0 18px;border-bottom:1px solid var(--line);gap:14px}
.dots{display:flex;gap:7px}.dots i{width:12px;height:12px;border-radius:50%;display:block}
.ttl .a{font:600 16px Inter,sans-serif}.ttl .b{font:400 12px Inter,sans-serif;color:var(--dim);margin-top:2px}
.sp{flex:1}
.avs{display:flex}.avs i{width:26px;height:26px;border-radius:50%;border:2px solid var(--win);margin-left:-7px;display:block}
#share{background:#2d3036;border:1px solid #42464e;padding:8px 16px;border-radius:9px;font:600 14px Inter,sans-serif}
#preview{position:absolute;left:18px;top:80px;width:604px;height:330px;border-radius:12px;overflow:hidden;background:linear-gradient(#3b2f5c,#c0687a 62%,#f2b27a)}
#preview svg{position:absolute;inset:0}
#tline{position:absolute;left:18px;right:18px;top:430px;bottom:18px;background:var(--panel);border-radius:12px;padding:14px}
.track{height:34px;border-radius:7px;margin-bottom:10px;display:flex;gap:4px}
.track b{display:block;height:100%;border-radius:6px}
#playhead{position:absolute;top:8px;bottom:8px;width:2px;background:#ff5b5b;left:0}
#menu{position:absolute;left:470px;top:56px;width:170px;background:#2a2d33;border:1px solid #42464e;border-radius:12px;padding:6px;box-shadow:0 20px 40px rgba(0,0,0,.4);opacity:0}
#menu div{font:400 15px Inter,sans-serif;padding:10px 12px;border-radius:8px;color:#d9dce1}
#menu .on{background:#3a3e46;color:#fff}
#dlg{position:absolute;left:110px;top:120px;width:420px;background:#26282e;border:1px solid #42464e;border-radius:16px;padding:20px;box-shadow:0 30px 60px rgba(0,0,0,.5);opacity:0}
#dlg h3{font:600 18px Inter,sans-serif;margin-bottom:14px}
.tabs{display:flex;gap:4px;background:#1d1f24;border-radius:9px;padding:4px;margin-bottom:16px}
.tabs span{flex:1;text-align:center;font:600 13px Inter,sans-serif;padding:7px 0;border-radius:7px;color:var(--dim)}
.tabs .on{background:#3a3e46;color:#fff}
.fld{display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #33363d;font:400 15px Inter,sans-serif}
.fld .v{background:#1d1f24;border-radius:7px;padding:6px 10px;font:400 14px Mono,monospace;color:#e3e6ea}
#qrow{display:flex;align-items:center;gap:14px;padding:14px 0 6px;font:400 15px Inter,sans-serif}
#slider{position:relative;flex:1;height:6px;background:#3a3e46;border-radius:6px}
#fill{position:absolute;left:0;top:0;bottom:0;width:100%;background:var(--accent);border-radius:6px;transform-origin:0 50%}
#knob{position:absolute;top:50%;left:0;width:20px;height:20px;margin:-10px 0 0 -10px;background:#fff;border-radius:50%;box-shadow:0 2px 6px rgba(0,0,0,.4)}
#qv{width:62px;text-align:right;color:var(--dim)}
.btns{display:flex;justify-content:flex-end;gap:10px;margin-top:16px}
.btns span{font:600 14px Inter,sans-serif;padding:10px 18px;border-radius:9px}
#cancel{background:#33363d;color:#cfd3d9}
#export{background:var(--accent);color:#fff;position:relative;overflow:hidden}
#prog{position:absolute;left:0;top:0;bottom:0;width:0;background:rgba(0,0,0,.25)}
#cursor{position:absolute;left:0;top:0;width:30px;height:30px;z-index:20;filter:drop-shadow(0 3px 4px rgba(0,0,0,.35))}
#ripple{position:absolute;left:0;top:0;width:44px;height:44px;margin:-22px 0 0 -22px;border-radius:50%;border:3px solid var(--accent);opacity:0;z-index:19}
#toast{position:absolute;left:140px;top:962px;width:440px;background:#fff;border-radius:14px;padding:14px 18px;display:flex;align-items:center;gap:12px;box-shadow:0 20px 40px rgba(0,0,0,.25);opacity:0;font-family:Inter,sans-serif}
#toast i{width:30px;height:30px;border-radius:50%;background:#22a35a;display:block;flex:none;position:relative}
#toast i::after{content:"";position:absolute;left:10px;top:7px;width:7px;height:12px;border:solid #fff;border-width:0 3px 3px 0;transform:rotate(45deg)}
#toast .t{font:600 16px Inter,sans-serif;color:#111}#toast .x{font:400 13px Mono,monospace;color:#555;margin-top:2px}
#caps{position:absolute;left:0;right:0;top:1100px;height:60px}
.cap{position:absolute;left:0;right:0;margin:0 auto;width:max-content;top:0;white-space:nowrap;background:#111;color:#fff;border-radius:40px;padding:12px 22px 12px 12px;display:flex;align-items:center;gap:12px;font:600 21px Inter,sans-serif;opacity:0}
.cap b{width:34px;height:34px;border-radius:50%;background:#fff;color:#111;display:flex;align-items:center;justify-content:center;font:800 17px Inter,sans-serif}
</style>
</head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="8" data-width="720" data-height="1280">
 <div id="cam" class="clip" data-start="0" data-duration="8" data-track-index="0">
  <div id="win">
   <div class="bar"><div class="dots"><i style="background:#ff5f57"></i><i style="background:#febc2e"></i><i style="background:#28c840"></i></div>
    <div class="ttl"><div class="a" id="wTitle"></div><div class="b" id="wSub"></div></div><div class="sp"></div>
    <div class="avs"><i style="background:#f59e0b"></i><i style="background:#ec4899"></i><i style="background:#22c55e"></i></div><div id="share"></div></div>
   <div id="preview"><svg viewBox="0 0 604 330" preserveAspectRatio="none"><circle cx="470" cy="80" r="22" fill="#f6e6c8"/><path d="M0,330 L0,230 L40,230 L40,200 L80,200 L80,240 L120,240 L120,180 L150,180 L150,150 L170,150 L170,180 L200,180 L200,220 L250,220 L250,190 L290,190 L290,240 L330,240 L330,170 L360,170 L360,200 L400,200 L400,160 L430,160 L430,210 L470,210 L470,185 L510,185 L510,230 L560,230 L560,200 L604,200 L604,330Z" fill="#3a2d4d"/><path d="M0,330 L0,270 L60,270 L60,250 L110,250 L110,280 L170,280 L170,240 L220,240 L220,275 L280,275 L280,255 L340,255 L340,285 L400,285 L400,245 L460,245 L460,270 L520,270 L520,255 L604,255 L604,330Z" fill="#241d33"/></svg></div>
   <div id="tline"><div class="track"><b style="width:28%;background:#5b8def"></b><b style="width:40%;background:#7c6cf0"></b><b style="width:30%;background:#5b8def"></b></div>
    <div class="track"><b style="width:55%;background:#2fa37a"></b><b style="width:43%;background:#2fa37a;opacity:.7"></b></div>
    <div class="track"><b style="width:98%;background:#c48a2e;opacity:.85"></b></div><div id="playhead"></div></div>
   <div id="menu"></div>
   <div id="dlg"><h3 id="dTitle"></h3><div class="tabs" id="tabs"></div><div id="fields"></div>
    <div id="qrow"><span id="qLabel"></span><div id="slider"><div id="fill"></div><div id="knob"></div></div><span id="qv"></span></div>
    <div class="btns"><span id="cancel">Cancel</span><span id="export"><i id="prog"></i><span id="expTxt"></span></span></div></div>
  </div>
  <div id="ripple"></div>
  <svg id="cursor" viewBox="0 0 30 30"><path d="M5,3 L5,25 L11,19.5 L15,28 L19,26 L15,17.5 L23,17.5 Z" fill="#111" stroke="#fff" stroke-width="2" stroke-linejoin="round"/></svg>
  <div id="toast"><i></i><div><div class="t" id="tTitle"></div><div class="x" id="tSub"></div></div></div>
 </div>
 <div id="caps" class="clip" data-start="0" data-duration="8" data-track-index="1"></div>
</div>
<script>
/* ============ CONFIG — the only block to edit ============ */
const CONFIG = {
  windowTitle: "Trailer cut · final", windowSub: "Edited 2 min ago",
  trigger: "Publish",                                 // top-right button the cursor clicks first
  menu: ["Schedule", "Share link", "Render…", "Archive"], menuPick: 2,   // dropdown items + index to click
  dialogTitle: "Render", tabs: ["Reel", "Square", "Wide"],
  fields: [["Codec", "ProRes 422"], ["Size", "1080 × 1920"], ["Audio", "Stereo · −14 LUFS"]],
  slider: { label: "Bitrate", from: .35, to: .9, fromText: "Standard", toText: "Master" },
  action: "Render",                                   // primary button in the dialog
  toast: { title: "Render finished", sub: "trailer-final.mov · 212 MB" },
  steps: ["Open Publish", "Pick size & bitrate", "Hit Render"]   // captions for the three beats
};
/* ========================================================= */
const C = CONFIG, $ = s => document.querySelector(s);
$("#wTitle").textContent = C.windowTitle; $("#wSub").textContent = C.windowSub; $("#share").textContent = C.trigger;
$("#menu").innerHTML = C.menu.map((m, i) => `<div data-i="${i}">${m}</div>`).join("");
$("#dTitle").textContent = C.dialogTitle; $("#tabs").innerHTML = C.tabs.map((t, i) => `<span class="${i ? "" : "on"}">${t}</span>`).join("");
$("#fields").innerHTML = C.fields.map(([k, v]) => `<div class="fld"><span>${k}</span><span class="v">${v}</span></div>`).join("");
$("#qLabel").textContent = C.slider.label; $("#qv").textContent = C.slider.fromText; $("#expTxt").textContent = C.action;
$("#tTitle").textContent = C.toast.title; $("#tSub").textContent = C.toast.sub;
$("#caps").innerHTML = C.steps.map((s, i) => `<div class="cap"><b>${i + 1}</b>${s}</div>`).join("");
const slW = $("#slider").offsetWidth; gsap.set("#fill", {scaleX: C.slider.from}); gsap.set("#knob", {x: slW * C.slider.from});
// measure targets in camera space (camera is untransformed at this point)
const at = (el, fx = .5, fy = .5) => { const r = (typeof el === "string" ? $(el) : el).getBoundingClientRect(); return [r.left + r.width * fx, r.top + r.height * fy]; };
const pick = $(`#menu [data-i="${C.menuPick}"]`);
const P = { share: at("#share"), item: at(pick, .35), knob: at("#knob"), export: at("#export"), dlg: at("#dlg"), win: at("#win") };
const knobTo = [P.knob[0] + slW * (C.slider.to - C.slider.from), P.knob[1]];
// camera and cursor are tweened as real transforms, never through update callbacks (the renderer may skip those when it seeks)
const camTo = (x, y, s) => ({x: 360 - x * s, y: 600 - y * s, scale: s});
gsap.set("#cam", {transformOrigin: "0 0", ...camTo(360, 640, 1)});
const curEl = $("#cursor"), curAt = p => ({x: p[0] - 5, y: p[1] - 3});
gsap.set(curEl, curAt([380, 1150]));
const tl = gsap.timeline({paused:true});
const moveTo = (p, t, d = .7) => tl.to(curEl, {...curAt(p), duration: d, ease: "power2.inOut"}, t);
const click = (t, p) => { tl.to(curEl, {scale: .82, duration: .08, yoyo: true, repeat: 1, transformOrigin: "15% 10%"}, t);
  tl.fromTo("#ripple", {x: p[0], y: p[1], scale: .3, opacity: .9}, {scale: 1.6, opacity: 0, duration: .45, ease: "power2.out", immediateRender: false}, t); };
const caption = (i, t) => { const caps = document.querySelectorAll(".cap"); if (i) tl.to(caps[i - 1], {opacity: 0, y: -10, duration: .25}, t - .1);
  tl.fromTo(caps[i], {opacity: 0, y: 14}, {opacity: 1, y: 0, duration: .35, ease: "back.out(1.6)"}, t); };

tl.fromTo("#win", {y: 40}, {y: 0, duration: .7, ease: "power3.out"}, 0);
tl.fromTo("#playhead", {x: 120}, {x: 420, duration: 8, ease: "none"}, 0);
tl.fromTo(curEl, {opacity: 0}, {opacity: 1, duration: .3}, .5);
// beat 1: trigger → menu → item
caption(0, .7);
tl.to("#cam", {...camTo(P.share[0] - 90, P.share[1] + 110, 1.5), duration: 1.0, ease: "power2.inOut"}, .6);
moveTo(P.share, .8, .9); click(1.75, P.share);
tl.fromTo("#menu", {opacity: 0, y: -8}, {opacity: 1, y: 0, duration: .25}, 1.85);
moveTo(P.item, 2.1, .45);
tl.set(pick, {className: "on"}, 2.45); click(2.6, P.item);
tl.to("#menu", {opacity: 0, duration: .15}, 2.75);
// beat 2: dialog + slider
tl.fromTo("#dlg", {opacity: 0, scale: .94}, {opacity: 1, scale: 1, duration: .35, ease: "back.out(1.4)"}, 2.8);
tl.to("#cam", {...camTo(P.dlg[0], P.dlg[1] + 20, 1.38), duration: .8, ease: "power2.inOut"}, 2.7);
caption(1, 3.0);
moveTo(P.knob, 3.2, .6);
tl.to(curEl, {scale: .88, duration: .1, transformOrigin: "15% 10%"}, 3.85);
tl.to(curEl, {x: knobTo[0] - 5, duration: .7, ease: "power1.inOut"}, 3.95);
tl.to("#fill", {scaleX: C.slider.to, duration: .7, ease: "power1.inOut"}, 3.95);
tl.to("#knob", {x: slW * C.slider.to, duration: .7, ease: "power1.inOut"}, 3.95);
tl.set("#qv", {textContent: C.slider.toText, color: "#fff"}, 4.35);
tl.to(curEl, {scale: 1, duration: .1}, 4.65);
// beat 3: primary action → progress → toast
caption(2, 4.8);
moveTo(P.export, 4.8, .55); click(5.45, P.export);
tl.to("#prog", {width: "100%", duration: .7, ease: "power1.inOut"}, 5.55);
tl.to("#dlg", {opacity: 0, scale: .96, duration: .25}, 6.25);
tl.to("#cam", {...camTo(360, 640, 1), duration: .8, ease: "power2.inOut"}, 6.15);
tl.fromTo("#toast", {opacity: 0, y: 30}, {opacity: 1, y: 0, duration: .45, ease: "back.out(1.6)"}, 6.4);
tl.to(document.querySelectorAll(".cap")[2], {opacity: 0, duration: .3}, 6.3);
tl.to(curEl, {opacity: 0, duration: .3}, 6.4);
window.__timelines = window.__timelines || {}; window.__timelines["main"] = tl; tl.seek(0);
</script>
</body>
</html>
```

How targeting works: the script measures each clickable element's centre once, before the camera moves, and drives the cursor and camera to those points. If you add or rename UI elements, keep the ids (`#share`, `#export`, `#knob`, `#dlg`) or update the `P` map.

**Rendering rule:** never drive what's on screen from `onUpdate`/`onComplete` callbacks. The renderer sometimes seeks with events suppressed, so a callback-painted cursor or camera freezes on random frames (this bug happened while building this template). Tween the real transforms (`x`, `y`, `scale`) as the template does, and animate transforms rather than `left`/`top`, which `check` flags because they stutter.

## 4. Check, render, verify

```bash
npx hyperframes check     # must report 0 errors
npx hyperframes render --output ui-walkthrough.mp4 --quality high
for t in 1.6 2.5 3.4 4.6 6.0 7.8; do ffmpeg -v error -y -ss $t -i ui-walkthrough.mp4 -frames:v 1 f_$t.png; done
```

Look at the frames: at 1.6 s the cursor is on the trigger, at 2.5 s on the chosen menu item, at 4.6 s on the dragged knob, and at 6.0 s on the primary button. If any is off, a target element was renamed or hidden. Expected and fine: warnings about overlapping `.cap` tweens and the closing toast being on screen under 2 s.

## 5. Deliver

Hand over the MP4 (send it as a file if your environment can, otherwise give its path) with one line on what it shows. It is 720×1280 (9:16) and silent.