import json, sys
# 사용법: python3 build_data.py <raw 폴더> <출력 Data.lua>
R=sys.argv[1].rstrip('/')+'/'
OUT=sys.argv[2]
CATS=json.load(open(R+'wowf/cats.json'))
profs=[("alchemy",171),("blacksmithing",164),("enchanting",333),("engineering",202),("leatherworking",165),("tailoring",197),("mining",186),("cooking",185),("first-aid",129)]
def lua_str(s):
    return '"'+s.replace('\\','\\\\').replace('"','\\"').replace('\n','\\n').replace('\r','')+'"'
out=["-- 자동 생성 파일: tools/build_data.py","-- 데이터 출처: wowf.io (레시피·분류·재료), seemeta.com (숙련 구간)","local _, ns = ...","ns.Data = {}","ns.ItemNames = {}","local D = ns.Data"]
stats={}
allnames_ko={}; allnames_en={}
for slug,skill in profs:
    ko=json.load(open(R+f'wowf/api/{slug}.ko.json')); en=json.load(open(R+f'wowf/api/{slug}.en.json'))
    sm=json.load(open(R+f'seemeta/parsed/{slug}.json'))
    by={(x['t'],x['id']):x for x in sm}; byname={x['n']:x for x in sm}
    en_by={x['s']:x for x in en['items']}
    kc=CATS[slug+'.ko']; ec=CATS[slug+'.en']
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
        flags=(1 if x.get('new') else 0)+(2 if trainer else 0)
        reag='{'+','.join('{%d,%d}'%(a,b) for a,b in x['r'])+'}'
        rows.append('{%d,%d,%d,%d,%d,%d,%d,%d,%d,%s,%s,%s,%s,%s,%s}'%(
            x['s'],x.get('i',0),x.get('c',0),org,y,g,gr,flags,x.get('q',1),
            lua_str(x.get('icon','')),lua_str(x['n']),lua_str(e.get('n',x['n'])),reag,
            lua_str(x.get('d','')),lua_str(e.get('d',x.get('d','')))))
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
