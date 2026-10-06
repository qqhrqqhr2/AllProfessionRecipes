# All Profession Recipes (모든 전문 기술 제조법)

World of Warcraft: Forever addon that adds tabs for the professions you have **not** learned to the profession window, and lists every recipe in the same layout as the default window.

와우 포에버용 애드온입니다. 전문 기술 창 옆에 **배우지 않은 전문 기술** 탭을 추가하고, 기본 창과 같은 모양으로 모든 제조법을 보여줍니다.

## 기능 / Features

- 배우지 않은 전문 기술 탭: 연금술, 대장기술, 마법부여, 기계공학, 가죽세공, 재봉술, 채광, 요리, 응급치료
- 분류별 목록(접기/펼치기), 검색, 재료(보유/필요), 숙련 구간(주황·노랑·초록·회색), 배우는 방법
- 포에버 신규 제조법 표시(`*`), "포에버 신규만", "숙련 225 이하만" 필터
- **안 배운 제조법** 탭(두루마리): 지금 열린 배운 전문 기술에서 아직 배우지 않은 제조법만 보기
- 설정 탭(톱니바퀴): 언어(자동/한국어/English), 탭 위치(왼쪽/아래/오른쪽), 탭 아이콘 크기, 후원
- Unlearned profession tabs, category list with search, reagents, skill-up colors, how to learn
- "Missing recipes" tab for professions you already have
- Settings: language, tab position, tab icon size

## 명령어 / Commands

| 명령어 | 설명 |
| --- | --- |
| `/apr` | 단독 창 열기 / open standalone window |
| `/apr config` | 설정 창 / settings |
| `/apr left` `/apr bottom` `/apr side` | 탭 위치 / tab position |
| `/apr icon 30` | 탭 아이콘 크기 / tab icon size (16–48) |
| `/apr reset` | 설정 초기화 / reset settings |

## 데이터 / Data

Recipe data comes from [wowf.io](https://wowf.io/ko/professions) (recipes, categories, reagents, Korean/English names) and [seemeta.com](https://seemeta.com/en/wow-forever/professions) (skill-up ranges).

`Data.lua` is generated:

```sh
python3 tools/fetch_wowf.py raw/wowf/api
python3 tools/fetch_cats.py raw/wowf/cats.json
python3 tools/fetch_seemeta.py raw/seemeta/parsed
python3 tools/build_data.py raw Data.lua
```

## 후원 / Support

[buymeacoffee.com/qqhrqqhr2](https://buymeacoffee.com/qqhrqqhr2)
