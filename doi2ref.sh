#!/bin/bash
#
# doi2ref.sh
#
# descriotion: This script outputs a journal reference information from doi url. 
#  *** American Meteorological Society's URL is only available for now ***
#
# version: 0.1.0
#
# original script was coded by Takashi Unuma
# last modified: 27th March 2017
#

# debug level
debug_level=0

if test ${debug_level} -ge 100 ; then
    set -x
fi

# define temporary html file
TMPFILE=out.html


# debug mode
if test ${debug_level} -ge 100 ; then
    URL="http://journals.ametsoc.org/action/showCitFormats?doi=10.1175%2FJAS-D-16-0215.1"
    #URL='http://journals.ametsoc.org/action/showCitFormats?doi=10.1175%2F1520-0469%281963%29020%3C0130%3ADNF%3E2.0.CO%3B2'
else
    # check argument
    if test $# -ne 1 ; then
	echo "USAGE: doi2ref.sh [URL]"
	exit 1
    fi
    URL=$1
    # remove temporary html file if it exists
    if test -s ${TMPFILE} ; then
	rm -f ${TMPFILE}
    fi
fi

# get html source from ${URL}
w3m -dump_source ${URL} > ${TMPFILE}

# check lines which is necessary for handle specific lines in the html file of out.html
start_num=`awk '/list of articles/{print NR + 7}' ${TMPFILE}`
end_num=`expr ${start_num} + 8`

# extract doi information from ${URL}
doi=`echo ${URL} | sed -e "s/\?doi\=/ /g" -e "s/\%2F/\//g" | awk '{print $2}' | sed -e 's/\%/\\\%/g'`

# debug
if test ${debug_level} -ge 100 ; then
    echo ${URL}
    echo ${doi}
fi

# output reference information
awk 'NR>='"${start_num}"' && NR<='"${end_num}"' {print $0}' ${TMPFILE} | \
    sed -e 's/<span\ class\=\"art_authors\">//g' \
    -e 's/<span\ class\=\"year\">//g'            \
    -e 's/<span\ class\=\"art_title\">//'        \
    -e 's/<span\ class\=\"journalName\">//'      \
    -e 's/<span\ class\=\"volume\">//'           \
    -e 's/<span\ class\=\"page\">//g'            \
    -e 's/\&ndash\;/-/g'                         \
    -e "s|<a href=\"/doi/abs/${doi}\">||g"       \
    -e 's/<span\ class\=\"doi\">//g'             \
    -e 's/<\/span>//g'                           \
    -e 's/<\/a>//g'                              \
    -e '/^$/d'                                   \
    -e 's/,<\/i>/<\/i>,/g'                       \
    -e 's|    ||g'

# remove temporary file
rm -f ${TMPFILE}
