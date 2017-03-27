#!/bin/bash
#
# doi2ref.sh
#
# descriotion: This script outputs a journal reference information from doi url. 
#  *** American Meteorological Society's URL is only available for now ***
#
# version: 0.2.0
#
# original script was coded by Takashi Unuma
# last modified: 27th March 2017
#

# debug level
debug_level=10

if test ${debug_level} -ge 100 ; then
    set -x
fi

# define temporary html file
TMPFILE=out.html


# debug mode
if test ${debug_level} -ge 100 ; then
    #
    # AMS
    #URL="http://journals.ametsoc.org/action/showCitFormats?doi=10.1175%2FJAS-D-16-0215.1"
    #URL='http://journals.ametsoc.org/action/showCitFormats?doi=10.1175%2F1520-0469%281963%29020%3C0130%3ADNF%3E2.0.CO%3B2'
    #
    # Wiley
    URL="http://onlinelibrary.wiley.com/enhanced/exportCitation/doi/10.1002/2016JD026037"
    #URL="http://onlinelibrary.wiley.com/enhanced/exportCitation/doi/10.1002/qj.2944"
    #
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
if test ${debug_level} -ge 100 ; then
    echo "DEBUG: ${URL}"
fi

# get html source from ${URL}
w3m -dump_source ${URL} > ${TMPFILE}


if test `echo ${URL} | grep "journals.ametsoc.org" | wc -l` -eq 1 ; then
    #
    # for journals.ametsoc.org
    #
    # check lines which is necessary for handle specific lines in the html file of out.html
    start_num=`awk '/list of articles/{print NR + 7}' ${TMPFILE}`
    end_num=`expr ${start_num} + 8`
    #
    # extract doi information from ${URL}
    doi=`echo ${URL} | sed -e "s/\?doi\=/ /g" -e "s/\%2F/\//g" | awk '{print $2}' | sed -e 's/\%/\\\%/g'`
    if test ${debug_level} -ge 100 ; then
	echo ${doi}
    fi
    #
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
    #
elif test `echo ${URL} | grep "onlinelibrary.wiley.com" | wc -l` -eq 1 ; then
    #
    # for onlinelibrary.wiley.com
    #
    cp ${TMPFILE} test.html
    # check lines which is necessary for handle specific lines in the html file of out.html
    start_num=`awk '/How to cite/{print NR}' ${TMPFILE}`
    end_num=`expr ${start_num}`
    #
    # extract doi information from ${URL}
    doi=`echo ${URL} | sed -e "s/doi\// /g" | awk '{print $2}'`
    if test ${debug_level} -ge 100 ; then
	echo "DEBUG: doi: ${doi}"
    fi
    #
    # output reference information
    tmp=`awk 'NR>='"${start_num}"' && NR<='"${end_num}"' {print $0}' ${TMPFILE} | \
	sed -e 's/<span\ class\=\"author\">//g'      \
	-e 's/<span\ class\=\"pubYear\">//g'         \
	-e 's/<span\ class\=\"articleTitle\">//'     \
	-e 's/<span\ class\=\"journalTitle\">//'     \
	-e 's/<span\ class\=\"vol\">//'              \
	-e 's/<span\ class\=\"page\">//g'            \
	-e 's/\&ndash\;/-/g'                         \
	-e "s|<a class=\"accessionId\" href=\"http://dx.doi.org/${doi}\" target=\"_blank\" title=\"Link to external resource: ${doi}\">||g" \
	-e 's/<span\ class\=\"doi\">//g'             \
	-e 's|</span>||g'                            \
	-e 's|</a>||g'                               \
	-e 's|</cite>||g'                            \
	-e 's|</p>||g'                               \
	-e 's|</div>||g'                             \
	-e '/^$/d'                                   \
	-e 's/,<\/i>/<\/i>,/g'                       \
	-e 's| (|, |g'                               \
	-e 's|),|:|g'                                \
	-e 's|    ||g'`
    #
    if test `echo ${doi} | grep JD | wc -l` -eq 1 ; then
	# ?
	echo ${tmp} | awk '{print substr($0, 145)}'
    elif test `echo ${doi} | grep qj | wc -l` -eq 1 ; then
	# QJ
	echo ${tmp} | awk '{print substr($0, 78)}'
    else
	echo "*** The input wiley's URL is not supported in this script ***"
    fi
    #
else
    #
    echo "*** The input URL is not supported in this script ***"
    #
fi

# remove temporary file
rm -f ${TMPFILE}
