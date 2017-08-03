#!/bin/bash
# ttf2fop - Prepare TrueType fonts for use with Apache FOP
# Copyright (C) 2011 Damien Goutte-Gattat
# 
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.

set -e

program_name=${0##*/}
fop_libs_dir=/usr/lib/apache-xml
fop_fonts_dir=/usr/share/fop/fonts

die()
{
    echo "$program_name: $@" >&2
    exit 1
}

show_usage()
{
    cat <<EOH
Usage: $program_name [options] TTF_FILE...
Generate a FOP metrics file for each TTF file given on the
command line. If no file is given, read TTF filenames from
standard input.

Options:
  -h, --help                Show this help message.
  -v, --version             Show the version message.

  -l, --fop-libs PATH       Specify the location of FOP
                            Jar files (default: $fop_libs_dir).
  -d, --fonts-dir PATH      Specify the directory where the
                            metrics file should be stored
                            (default: $fop_fonts_dir).
EOH
}

process_ttf_file()
{
    fontfile=$1
    [ -f "$fontfile" ] || return

    fontname=$(basename $fontfile .ttf)
    fontbasename=$(echo $fontname | cut -d- -f1)
    fontstylespec=$(echo $fontname | cut -d- -f2)

    case "$fontstylespec" in
    Italic|Oblique)
        fontstyle=italic
        fontweight=normal
        filequalifier=italic
        ;;
    Bold)
        fontstyle=normal
        fontweight=bold
        filequalifier=bold
        ;;

    BoldItalic|BoldOblique)
        fontstyle=italic
        fontweight=bold
        filequalifier=bold-italic
        ;;

    *)
        fontstyle=normal
        fontweight=normal
        filequalifier=regular
        ;;
    esac

    java -cp $fop_libs_dir:$fop_libs_dir/* \
      org.apache.fop.fonts.apps.TTFReader -q \
      $fontfile $fontbasename-$filequalifier.xml
    cat <<EOF
    <font metrics-url="$fop_fonts_dir/$fontbasename-$filequalifier.xml"
        embed-url="$fontfile"
        kerning="yes">
        <font-triplet name="$fontbasename" style="$fontstyle" weight="$fontweight" />
    </font>
EOF
}

while true ; do
    case "$1" in
    -h|--help)
        show_usage
        exit 0
        ;;

    -v|--version)
        sed -n '2,/^$/ s/^# //p' $0
        exit 0
        ;;

    -l|--fop-libs)
        [ -n "$2" ] || die "missing argument for option --fop-libs"
        fop_libs_dir=$2
        shift 2
        ;;

    -d|--fonts-dir)
        [ -n "$2" ] || die "missing argument for option --fonts-dir"
        fop_fonts_dir=$2
        shift 2
        ;;

    *)
        break
        ;;
    esac
done

echo "<?xml version=\"1.0\"?>"
echo "<fonts>"

if [ -z "$*" ]; then
    cat | while read f ; do process_ttf_file $f ; done
else
    for f in "$@" ; do process_ttf_file $f ; done
fi

echo "</fonts>"
