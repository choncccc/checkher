"""Builds assets/map/agoo_map.json, the offline map behind Nearby Health
Services, from OpenStreetMap data (ODbL, (c) OpenStreetMap contributors).

Usage: python tool/build_offline_map.py [overpass.json]
Without an argument it downloads the area from the Overpass API.
"""
import json
import sys
import urllib.parse
import urllib.request

# South, west, north, east: Agoo, La Union.
BBOX = (16.27, 120.33, 16.37, 120.41)
OUT = 'assets/map/agoo_map.json'
TOLERANCE = 0.00002  # ~2 m; simplification threshold in degrees

QUERY = f"""[out:json][timeout:90];
(way["highway"~"^(trunk|primary|secondary|tertiary|unclassified|residential|living_street)$"]{BBOX};
way["waterway"~"^(river|stream)$"]{BBOX};
way["natural"="coastline"](16.25,120.30,16.39,120.43);
node["place"~"^(town|village)$"]{BBOX};);
out geom;"""

# Road classes drawn by the app, widest first.
ROAD_KIND = {
    'trunk': 'major', 'primary': 'major', 'secondary': 'major',
    'tertiary': 'minor', 'unclassified': 'minor',
    'residential': 'street', 'living_street': 'street',
}


def fetch():
    req = urllib.request.Request(
        'https://overpass-api.de/api/interpreter',
        data=urllib.parse.urlencode({'data': QUERY}).encode(),
        headers={'User-Agent': 'CheckHER offline map builder'},
    )
    with urllib.request.urlopen(req, timeout=180) as r:
        return json.load(r)


def simplify(pts, tol=TOLERANCE):
    """Douglas-Peucker on (lat, lon) pairs."""
    if len(pts) < 3:
        return pts
    (ay, ax), (by, bx) = pts[0], pts[-1]
    dy, dx = by - ay, bx - ax
    norm = (dx * dx + dy * dy) ** 0.5
    best, idx = 0.0, 0
    for i in range(1, len(pts) - 1):
        py, px = pts[i]
        d = (abs(dx * (ay - py) - dy * (ax - px)) / norm if norm
             else ((py - ay) ** 2 + (px - ax) ** 2) ** 0.5)
        if d > best:
            best, idx = d, i
    if best <= tol:
        return [pts[0], pts[-1]]
    return simplify(pts[:idx + 1], tol)[:-1] + simplify(pts[idx:], tol)


def flat(pts):
    return [round(v, 5) for p in simplify(pts) for v in p]


def chain(lines):
    """Joins coastline ways that share endpoints into longer lines."""
    lines = [list(l) for l in lines]
    joined = True
    while joined:
        joined = False
        for i, a in enumerate(lines):
            for j, b in enumerate(lines):
                if i != j and a[-1] == b[0]:
                    lines[i] = a + b[1:]
                    del lines[j]
                    joined = True
                    break
            if joined:
                break
    return lines


def main():
    data = json.load(open(sys.argv[1], encoding='utf-8')) if len(sys.argv) > 1 else fetch()
    roads, water, coast, places = [], [], [], []
    for e in data['elements']:
        tags = e.get('tags', {})
        if e['type'] == 'node':
            if tags.get('place') in ('town', 'village') and 'name' in tags:
                places.append([tags['name'], round(e['lat'], 5), round(e['lon'], 5),
                               1 if tags['place'] == 'town' else 0])
            continue
        pts = [(g['lat'], g['lon']) for g in e.get('geometry', [])]
        if len(pts) < 2:
            continue
        if tags.get('highway') in ROAD_KIND:
            roads.append([ROAD_KIND[tags['highway']], flat(pts)])
        elif tags.get('waterway'):
            water.append(flat(pts))
        elif tags.get('natural') == 'coastline':
            coast.append(pts)
    # OSM coastlines keep land on the left, so the sea is the area to the
    # right of each line; Agoo's shore faces west, so close each line far
    # out to sea to get a fillable polygon.
    sea = []
    for line in chain(coast):
        (s_lat, _), (e_lat, _) = line[0], line[-1]
        sea.append(flat(line + [(e_lat, 120.2), (s_lat, 120.2)]))
    order = {'street': 0, 'minor': 1, 'major': 2}
    roads.sort(key=lambda r: order[r[0]])  # draw major roads on top
    out = {
        'attribution': '© OpenStreetMap contributors',
        'bounds': list(BBOX),
        'sea': sea,
        'water': water,
        'roads': roads,
        'places': places,
    }
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, separators=(',', ':'))
    print(f'{OUT}: {len(roads)} roads, {len(water)} waterways, '
          f'{len(sea)} sea polygons, {len(places)} places')


if __name__ == '__main__':
    main()
