import re, sys, json, subprocess, html, os
OUT=sys.argv[1]; os.makedirs(OUT,exist_ok=True)
profs=["alchemy","blacksmithing","cooking","enchanting","engineering","first-aid","leatherworking","tailoring","mining"]
for p in profs:
    h=subprocess.run(["curl","-s","--compressed","-m","40",f"https://seemeta.com/en/wow-forever/professions/{p}"],capture_output=True).stdout.decode("utf-8","replace")
    i=h.find('id="wf-prof-recipes"'); h=h[i:]
    rows=[]
    for li in re.split(r'<li style="[^"]*"><a data-name ',h)[1:]:
        m=re.match(r'href="https://www\.wowhead\.com/forever/(item|spell)=(\d+)"',li)
        name=re.search(r'<span data-t[^>]*>([^<]*)</span>',li)
        sk=re.search(r'<p data-skill>(.*?)</p>',li,re.S)
        spans=sk.group(1) if sk else ''
        trainer='Learned from a trainer' in spans
        nums=[int(x) for x in re.findall(r'<span>(\d+)<!---->',spans)]
        rows.append({"t":m.group(1),"id":int(m.group(2)),"n":html.unescape(name.group(1)) if name else None,"trainer":trainer,"nums":nums})
    json.dump(rows,open(f"{OUT}/{p}.json","w"))
    print(p,len(rows))
