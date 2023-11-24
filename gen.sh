#!/bin/bash

rm -f days.tex

year=2024
for month in {1..12}; do

    days_in_month=$(cal -d "$year-$month-01" | awk 'NF {DAYS = $NF}; END {print DAYS}')

  for ((day=1; day<=$days_in_month; day++)); do
        # use `date`` to validate
        if date -j -f "%Y-%m-%d" "$year-$month-$day" > /dev/null 2>&1; then
            bookmark=$(sqlite3 bookmarks.db "SELECT a.name, a.author, b.mark_text, b.id FROM books AS a INNER JOIN bookmarks AS b ON a.id = b.book_id AND LENGTH(b.mark_text) < 430 ORDER BY RANDOM() LIMIT 1")

            book_name=$(echo $bookmark | cut -d '|' -f1)
            author=$(echo $bookmark | cut -d '|' -f2)
            mark_text=$(echo $bookmark | cut -d '|' -f3)
            id=$(echo $bookmark | cut -d '|' -f4)

            echo -n | tee "days/$year-$month-$day.tex" << EOF
\title{\date[d=$day,m=$month,y=$year][year:cn-a,年,month:cn,day:cn,日,,weekday]}
$mark_text\footnote{$book_name, $author}

EOF

            cat days/$year-$month-$day.tex >> days.tex
            sqlite3 bookmarks.db "DELETE FROM bookmarks WHERE ID = '$id'"
        fi
    done
done

context calendar.tex

# refill the sqlite db
rm -f bookmarks.db
sqlite3 bookmarks.db < bookmarks.sql
