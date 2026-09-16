#!/usr/bin/env python3
"""CUPS Admin icon — old-school dot-matrix printer with green-bar fanfold paper."""
import cairosvg, os

BG = {
    "graphite": ("#5b6470", "#2e343c"),
    "slate":    ("#6b7a8c", "#3a4655"),
    "green":    ("#2f8f5b", "#1b5a39"),
    "cream":    ("#e9e2cf", "#cbbf9f"),
}

def greenbar(x, y, w, h, bar=26, holes=True, rot=0, id_="gb"):
    """A sheet of green-bar paper: alternating pale green / white bands + tractor holes."""
    out = [f'<g transform="rotate({rot} {x+w/2} {y+h/2})">']
    out.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="#ffffff"/>')
    yy = y
    i = 0
    while yy < y + h:
        if i % 2 == 0:
            hh = min(bar, y + h - yy)
            out.append(f'<rect x="{x}" y="{yy}" width="{w}" height="{hh}" fill="#c9ebd2"/>')
        yy += bar; i += 1
    if holes:
        # tractor-feed strips
        for hx in (x + 22, x + w - 22):
            out.append(f'<line x1="{hx+ (18 if hx==x+22 else -18)}" y1="{y}" x2="{hx+(18 if hx==x+22 else -18)}" y2="{y+h}" stroke="#b9c3cc" stroke-width="3" stroke-dasharray="10 8"/>')
            hy = y + 18
            while hy < y + h - 8:
                out.append(f'<circle cx="{hx}" cy="{hy}" r="6.5" fill="#9aa4ad"/>')
                hy += 40
    out.append('</g>')
    return "\n".join(out)

def svg(top, bottom, dark_glyph=False):
    body_top, body_bot = ("#f4f6f8", "#d9dee5")
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{top}"/><stop offset="1" stop-color="{bottom}"/>
  </linearGradient>
  <linearGradient id="body" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="{body_top}"/><stop offset="1" stop-color="{body_bot}"/>
  </linearGradient>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
    <feDropShadow dx="0" dy="14" stdDeviation="18" flood-color="#000" flood-opacity="0.28"/>
  </filter>
  <filter id="soft" x="-10%" y="-10%" width="120%" height="120%">
    <feDropShadow dx="0" dy="4" stdDeviation="4" flood-color="#000" flood-opacity="0.22"/>
  </filter>
  <clipPath id="clip"><rect x="100" y="100" width="824" height="824" rx="185"/></clipPath>
  <clipPath id="outclip"><path d="M300 640 h424 v250 h-424 z"/></clipPath>
</defs>
<rect x="100" y="100" width="824" height="824" rx="185" fill="url(#bg)" filter="url(#shadow)"/>
<rect x="100" y="100" width="824" height="412" rx="185" fill="#ffffff" opacity="0.06" clip-path="url(#clip)"/>

<g clip-path="url(#clip)">
<g filter="url(#soft)">
  <!-- incoming fanfold sheet, tilted back -->
  {greenbar(318, 250, 388, 200, rot=0)}
  <!-- printer body: wide, flat, dot-matrix style -->
  <rect x="212" y="436" width="600" height="220" rx="40" fill="url(#body)"/>
  <!-- paper slot on top -->
  <rect x="290" y="436" width="444" height="16" rx="8" fill="#a9b2bc"/>
  <!-- control panel: green ready light + two grey buttons -->
  <circle cx="742" cy="500" r="16" fill="#34c759"/>
  <rect x="712" y="540" width="60" height="18" rx="9" fill="#b8c0c9"/>
  <rect x="712" y="572" width="60" height="18" rx="9" fill="#b8c0c9"/>
  <!-- front lip -->
  <rect x="212" y="606" width="600" height="50" rx="25" fill="#c5ccd5"/>
  <rect x="300" y="596" width="424" height="14" rx="7" fill="#9aa4ad"/>
</g>
  <!-- output fanfold coming out the front, with a perforation fold -->
  <g filter="url(#soft)" clip-path="url(#clip)">
    {greenbar(300, 612, 424, 160, rot=0)}
    <line x1="300" y1="692" x2="724" y2="692" stroke="#9aa4ad" stroke-width="3" stroke-dasharray="6 6"/>
  </g>
  <!-- dot-matrix text: two identical lines, end to end between the tractor strips -->
  <g fill="#3a4a3f">
    {"".join(f'<circle cx="{x}" cy="{y}" r="4"/>' for y in (639, 651, 663) for x in range(364, 662, 12) if ((x-364)//12) % 7 != 6)}
    {"".join(f'<circle cx="{x}" cy="{y}" r="4"/>' for y in (719, 731, 743) for x in range(364, 662, 12) if ((x-364)//12) % 7 != 6)}
  </g>
</g>
</svg>'''

os.makedirs("out2", exist_ok=True)
for name, (top, bottom) in BG.items():
    s = svg(top, bottom)
    open(f"out2/icon-{name}.svg", "w").write(s)
    cairosvg.svg2png(bytestring=s.encode(), write_to=f"out2/icon-{name}-1024.png", output_width=1024, output_height=1024)
    cairosvg.svg2png(bytestring=s.encode(), write_to=f"out2/icon-{name}-256.png", output_width=256, output_height=256)
print("done")
