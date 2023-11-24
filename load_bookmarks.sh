#!/bin/bash
cat <<EOF > bookmarks.sql

CREATE TABLE books (
  id TEXT PRIMARY KEY,
  name TEXT,
  author TEXT,
  cover_url TEXT
);

CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER,
  mark_text TEXT
);

EOF

curl 'https://weread.qq.com/web/book/bookmarklist' \
  -H 'authority: weread.qq.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en,zh-CN;q=0.9,zh;q=0.8,en-US;q=0.7,de-DE;q=0.6,de;q=0.5,zh-TW;q=0.4' \
  -H 'cache-control: no-cache' \
  -H 'cookie: pac_uid=0_73d726eb464f5; pgv_pvid=9337758705; fqm_pvqid=25a7415a-d54c-47a1-a940-c2768c036718; wr_gid=242036021; wr_vid=11208925; wr_pf=1; wr_rt=web%40IP1zQ0uOXvVAyMith16_AL; wr_localvid=d49329206ab08ddd49ca246; wr_name=%E8%97%8F%E8%97%8F%E8%97%8F; wr_gender=1; ETCI=428babbcf03d43df871189f01514f4e1; msecToken=7e6e2cc7930924170ac721f13b77d9fc; _clck=3544113978|1|ff8|0; wr_theme=white; fqm_sessionid=ef3b2ddf-cc96-4571-aab6-04d44d933089; pgv_info=ssid=s1906482455; iip=0; wr_fp=95561327; wr_avatar=https%3A%2F%2Fwx.qlogo.cn%2Fmmhead%2FlthyYWMve6BOsjFFArGKtqYT0VtoGdTkGyV2IO9uH2E%2F0; wr_skey=Y7Wuokiu' \
  -H 'dnt: 1' \
  -H 'pragma: no-cache' \
  -H 'referer: https://weread.qq.com/web/reader/d1332cf0813ab7e32g012510' \
  -H 'sec-ch-ua: "Google Chrome";v="119", "Chromium";v="119", "Not?A_Brand";v="24"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36' \
  --compressed \
  -o bookmarks.json

jq -r "\"INSERT INTO books VALUES ('\" + (.books[] | .bookId + \"', '\" + .title + \"', '\" + .author + \"', '\" + .cover) + \"');\"" bookmarks.json >> bookmarks.sql

jq -r "\"INSERT INTO bookmarks (book_id, mark_text) VALUES ('\" + (.updated[] | .bookId + \"', '\" + .markText) + \"');\"" bookmarks.json >> bookmarks.sql

rm -f bookmarks.db
sqlite3 bookmarks.db < bookmarks.sql