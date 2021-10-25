#!/bin/sh

###
## V: 0.1
## Author : Seitosan@Nospof
## Disclamer : This script freeze the index if the index destination have the same number of document as source
###
src_srv=$1
dest_srv=$2
src_auth=$3
dest_auth=$4

curl -k -s "${src_srv}/_cat/indices?expand_wildcards=open&pretty=true&format=json" -u "${src_auth}" | grep index | cut -d '"' -f 4 | while read index;
do
  unset docCountSrc
  unset docCountDest
  docCountSrc=$(curl -k -s "${src_srv}/_cat/indices/${index}?pretty=true&format=json" -u "${src_auth}" | grep docs.count | cut -d '"' -f 4 );
  docCountDest=$(curl -k -s "${dest_srv}/_cat/indices/${index}?pretty=true&format=json" -u "${dest_auth}" | grep docs.count | cut -d '"' -f 4 );
  if [[ $docCountSrc == $docCountDest ]];
  then
    echo "Freezing ${index}"
    curl -x POST -k -s "${src_srv}/${index}/_freeze" -u "${src_auth}" ;
  else
    echo "########"
    echo "SRC : ${docCountSrc}"
    echo "DEST : ${docCountDest}"
    echo "INDEX : ${index}"
    echo "########"
  fi
done
