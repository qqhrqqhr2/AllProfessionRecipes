import json, sys
# 사용법: python3 build_data.py <raw 폴더> <출력 Data.lua>
R=sys.argv[1].rstrip('/')+'/'
OUT=sys.argv[2]
CATS=json.load(open(R+'wowf/cats.json'))
profs=[("alchemy",171),("blacksmithing",164),("enchanting",333),("engineering",202),("leatherworking",165),("tailoring",197),("mining",186),("cooking",185),("first-aid",129),("herbalism",182),("skinning",393),("fishing",356)]
CAMP={"ko":"야영","en":"Camping"}

DUNGEON_DROP={"ko":"던전 드랍: ","en":"Dungeon drop: "}

def src_lines(x, lang="ko"):
    """배우는 곳 문장 목록. 판매 NPC는 좌표를 붙이고, 드랍 던전(dr)도 한 줄로 넣는다."""
    s=x.get('src')
    lines=(list(s) if isinstance(s,list) else [s]) if s else []
    dr=[d.get('n') for d in (x.get('dr') or []) if isinstance(d,dict) and d.get('n')]
    if dr:
        lines.append(DUNGEON_DROP[lang]+', '.join(dr))
    if not lines: return []
    # w는 [NPC, ...] 또는 [[NPC, ...], ...] 두 가지 모양
    npcs=[]
    for g in (x.get('w') or []):
        if isinstance(g,dict): npcs.append(g)
        elif isinstance(g,list): npcs.extend(n for n in g if isinstance(n,dict))
    for i in range(len(lines)):
        for npc in npcs:
            at=npc.get('at'); name=npc.get('name')
            if not at or not name: continue
            key=name+' ('
            j=lines[i].find(key)
            if j<0: continue
            k=lines[i].find(')', j+len(key))
            if k<0: continue
            seg=lines[i][j:k]
            if ',' in seg.split('(')[-1]: continue  # 이미 좌표 있음
            lines[i]=lines[i][:k]+' %g, %g'%(at['x'],at['y'])+lines[i][k:]
    return lines
def lua_str(s):
    return '"'+s.replace('\\','\\\\').replace('"','\\"').replace('\n','\\n').replace('\r','')+'"'
out=["-- 자동 생성 파일: tools/build_data.py","-- 데이터 출처: wowf.io (레시피·분류·재료), seemeta.com (숙련 구간)","local _, ns = ...","ns.Data = {}","ns.ItemNames = {}","local D = ns.Data"]
stats={}
allnames_ko={}; allnames_en={}
for slug,skill in profs:
    ko=json.load(open(R+f'wowf/api/{slug}.ko.json')); en=json.load(open(R+f'wowf/api/{slug}.en.json'))
    try:
        sm=json.load(open(R+f'seemeta/parsed/{slug}.json'))
    except FileNotFoundError:
        sm=[]
    by={(x['t'],x['id']):x for x in sm}; byname={x['n']:x for x in sm}
    en_by={x['s']:x for x in en['items']}
    kc=CATS.get(slug+'.ko') or []; ec=CATS.get(slug+'.en') or []
    if not kc:
        cs=sorted({x['c'] for x in ko['items'] if x.get('c')})
        kc=[[c,CAMP['ko'],0] for c in cs]; ec=[[c,CAMP['en'],0] for c in cs]
    catko={c[0]:c[1] for c in kc}; caten={c[0]:c[1] for c in ec}
    allnames_ko.update(ko['names']); allnames_en.update(en['names'])
    rows=[]; matched=0
    for x in ko['items']:
        e=en_by.get(x['s'],{})
        m=(by.get(('item',x['i'])) if x.get('i') else None) or by.get(('spell',x['s'])) or byname.get(e.get('n'))
        org=x['l']; y=g=gr=0; trainer = 'book' not in x
        if m:
            matched+=1
            nums=m['nums']
            if m['trainer']: trainer=True
            else: trainer=False
            if len(nums)>=3: y,g,gr=nums[-3],nums[-2],nums[-1]
        # Explicit wowf.io trainer sources take priority over older skill-range data.
        if src_lines(x, 'ko') == ['교관'] or src_lines(e, 'en') == ['Trainer']:
            trainer = True
        flags=(1 if x.get('new') else 0)+(2 if trainer else 0)
        reag='{'+','.join('{%d,%d}'%(a,b) for a,b in x['r'])+'}'
        sk='\n'.join(src_lines(x,'ko')); se='\n'.join(src_lines(e,'en')) if e else sk
        rows.append('{%d,%d,%d,%d,%d,%d,%d,%d,%d,%s,%s,%s,%s,%s,%s,%s,%s}'%(
            x['s'],x.get('i',0),x.get('c',0),org,y,g,gr,flags,x.get('q',1),
            lua_str(x.get('icon','')),lua_str(x['n']),lua_str(e.get('n',x['n'])),reag,
            lua_str(x.get('d','')),lua_str(e.get('d',x.get('d',''))),
            lua_str(sk),lua_str(se)))
    cats=','.join('{%d,%s,%s}'%(c[0],lua_str(catko[c[0]]),lua_str(caten.get(c[0],catko[c[0]])) ) for c in kc)
    out.append(f'D[{skill}] = {{ slug={lua_str(slug)}, cats={{{cats}}}, recipes={{')
    out.append(',\n'.join(rows))
    out.append('}}')
    stats[slug]=(len(rows),matched)
out.append('local N = ns.ItemNames')
for k,v in allnames_ko.items():
    out.append('N[%s]={%s,%s}'%(k,lua_str(v),lua_str(allnames_en.get(k,v))))
open(OUT,'w',encoding='utf-8').write('\n'.join(out)+'\n')
print(stats)
