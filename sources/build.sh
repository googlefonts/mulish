#!/bin/sh
set -e


# echo "Generating Static fonts"
# TTFDIR=../fonts/ttf
# mkdir -p $TTFDIR
# rm -rf $TTFDIR/*.ttf
# fontmake -g Mulish.glyphs -i -o ttf --output-dir $TTFDIR -a
# # Heavy fonts (weightClass 1000) currently not allowed
# rm $TTFDIR/*Heavy*.ttf

# echo "Post processing"
# ttfs=$(ls $TTFDIR/*.ttf)
# for ttf in $ttfs
# do
# 	gftools fix-dsig -f $ttf;
# 	ttfautohint $ttf $ttf.fix
# 	mv "$ttf.fix" $ttf;
# 	gftools fix-hinting $ttf;
# 	mv "$ttf.fix" $ttf;
# done


echo "Generating VFs"
VFDIR=../fonts/vf
mkdir -p $VFDIR
rm -rf $VFDIR/*.ttf
fontmake -g Mulish.glyphs -o variable --flatten-components --output-path "$VFDIR/Mulish[ital,wght].ttf"

# Build STAT table
python gen_stat.py "$VFDIR/Mulish[ital,wght].ttf"

# -- Splitting, start --
# Everything under here (until --end--) can be removed once ital axis is allowed in GF specs.
# The complete VF gets split into separate Roman and Italic fonts.

# Restrict weights to the currently allowed range (exclude Heavy), and split ital axis.
fonttools varLib.instancer "$VFDIR/Mulish[ital,wght].ttf" ital=0 wght=200:900 --update-name-table -o "$VFDIR/Mulish[wght].ttf"
fonttools varLib.instancer "$VFDIR/Mulish[ital,wght].ttf" ital=1 wght=200:900 --update-name-table -o "$VFDIR/Mulish-Italic[wght].ttf"

# Delete original upright+italic file
rm "$VFDIR/Mulish[ital,wght].ttf"

# -- Splitting, end --

echo "Post processing VFs"
for f in $VFDIR/*.ttf
do
	echo Processing $f
	gftools fix-dsig -f $f
	gftools fix-unwanted-tables $f
	gftools fix-nonhinting $f $f.fix
	mv $f.fix $f
done

# Clean up
rm -rf $VFDIR/*backup*.ttf
rm -rf master_ufo/ instance_ufo/
