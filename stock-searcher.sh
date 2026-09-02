#!/bin/bash
tmp_file="/tmp/result_curl_$(date +'%Y-%m-%d').txt"

declare -A urls_to_check=(
    ["Paté"]="https://www.maxizoo.fr/p/petbalance-medica-cure-de-reconstructionreconvalescence-16x100g-1335012/|En rupture de stock"
)

for label in "${!urls_to_check[@]}"; do
    IFS="|" read -r url_to_check out_of_stock_label <<< "${urls_to_check[$label]}"

    curl -s "$url_to_check" \
    --compressed \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
    -H 'Accept-Language: fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-Site: cross-site' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' > "$tmp_file"

    if grep -q "$out_of_stock_label" "$tmp_file"; then
      echo "Pas de dispo pour $label"
    else
      echo "$label est dispo!"
      cp $tmp_file ~/stock-searcher
      
      echo -e "Subject: $label est dispo" | msmtp $STOCK_SEARCHER_DESTINATION_MAIL
    fi
done

rm "$tmp_file"