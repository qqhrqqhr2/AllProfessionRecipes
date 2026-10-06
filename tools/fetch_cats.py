import re, json, subprocess, sys
OUT=sys.argv[1]
profs=["alchemy","blacksmithing","cooking","enchanting","engineering","first-aid","leatherworking","tailoring","mining"]
res={}
for lang in ["ko","en"]:
    for p in profs:
        h=subprocess.run(["curl","-s","--compressed","-m","40",f"https://wowf.io/{lang}/professions/{p}"],capture_output=True).stdout.decode()
        chunks=re.findall(r'self\.__next_f\.push\(\[1,"(.*?)"\]\)</script>',h,re.S)
        big=''.join(json.loads('"'+c+'"') for c in chunks)
        i=big.find('"cats":[')
        cats=json.JSONDecoder().raw_decode(big,i+7)[0] if i>=0 else []
        res[f"{p}.{lang}"]=cats; print(lang,p,len(cats))
json.dump(res,open(OUT,"w"),ensure_ascii=False)
