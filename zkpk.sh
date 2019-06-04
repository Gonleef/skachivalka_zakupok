#!/bin/bash
user_agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0"

curl -A "$user_agent" "http://zakupki.gov.ru/epz/order/extendedsearch/orderCsvSettings/extendedSearch/download.html?morphology=on&openMode=USE_DEFAULT_PARAMS&pageNumber=1&sortDirection=false&recordsPerPage=_10&showLotsInfoHidden=false&fz44=on&fz223=on&af=on&currencyIdGeneral=-1&region_regions_5277383=region_regions_5277383&regions=5277383&regionDeleted=false&sortBy=UPDATE_DATE&quickSearch=false&userId=null&conf=true;true;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;false;" | iconv -f CP1251 -t UTF8 > list.csv 

zakupki=$(tail -n 500 list.csv | awk -F ";" '{print $1 $2}')
mkdir info
mkdir files
for zakupka in $zakupki
do
    ggg=$(echo $zakupka | awk -F "№" '{print $1; print $2}')
    fz=$(echo $ggg | awk '{print $1;}')
    number=$(echo $ggg | awk '{print $2;}')
    if [ "$fz" == "223-ФЗ" ]
    then
	cd info
	curl -o $number -A "$user_agent" "http://zakupki.gov.ru/223/purchase/public/purchase/info/lot-list.html?regNumber=$number"
	cd ../
	cd files
	curl -o $number -A "$user_agent" "http://zakupki.gov.ru/223/purchase/public/purchase/info/documents.html?regNumber=$number"
	downloads=$(grep "/223/purchase/public/download/download.html?id=" $number | awk -F "href=\"" '{print $2}' | awk -F "\"" '{print $1}')
	for download in $downloads
	do
	    for link in $download
	    do
		wget --content-disposition --user-agent="$user_agent"  "http://zakupki.gov.ru$link"
	    done
	done
	rm $number
	cd ../
    else
	cd info
	curl -o $number -A "$user_agent" "http://zakupki.gov.ru/epz/order/notice/ea44/view/common-info.html?regNumber=$number"
	cd ../
	cd files
	curl -o $number -A "$user_agent" "http://zakupki.gov.ru/epz/order/notice/ea44/view/documents.html?regNumber=$number"
	downloads=$(grep "zakupki.gov.ru/44fz/filestore/public/1.0/download/priz/file.html?uid=" $number | awk -F "href=\"" '{print $2}' | awk -F "\"" '{print $1}')
	for download in $downloads
	do
	    for link in $download
	    do
		wget --content-disposition --user-agent="$user_agent"  "$link"
	    done
	done
	rm $number
	cd ../
    fi
done

    
