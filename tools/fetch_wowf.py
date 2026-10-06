import json, sys, time, subprocess, os
OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)
profs = ["alchemy","blacksmithing","cooking","enchanting","engineering","first-aid","leatherworking","tailoring","mining","fishing","herbalism","skinning"]
def get(url):
    for _ in range(3):
        r = subprocess.run(["curl","-s","--compressed","-m","30",url],capture_output=True)
        try: return json.loads(r.stdout)
        except Exception: time.sleep(2)
    raise SystemExit("fail "+url)
for lang in ["ko","en"]:
    for p in profs:
        first = get(f"https://wowf.io/api/professions/{p}/recipes?l={lang}&p=1")
        pages = first.get("pages",1)
        res = {"items":list(first.get("items",[])),"names":dict(first.get("names",{})),"icons":dict(first.get("icons",{})),"cats":first.get("cats",[]),"total":first.get("total")}
        for pg in range(2,pages+1):
            d = get(f"https://wowf.io/api/professions/{p}/recipes?l={lang}&p={pg}")
            res["items"] += d.get("items",[]); res["names"].update(d.get("names",{})); res["icons"].update(d.get("icons",{}))
            time.sleep(0.3)
        json.dump(res, open(f"{OUT}/{p}.{lang}.json","w"), ensure_ascii=False)
        print(lang, p, pages, res["total"], len(res["items"]))
