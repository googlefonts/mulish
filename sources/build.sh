#!/bin/sh
set -e

TTFDIR=../fonts/ttf
VFDIR=../fonts/vf
mkdir -p $TTFDIR
mkdir -p $VFDIR

echo "Generating Static fonts"
rm -r $TTFDIR/*.ttf
fontmake -g Mulish.glyphs -i -o ttf --output-dir $TTFDIR -a

echo "Post processing"
ttfs=$(ls $TTFDIR/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	gftools fix-hinting $ttf;
	mv "$ttf.fix" $ttf;
done


echo "Generating VFs"
rm -r $VFDIR/*.ttf
fontmake -g temp_no_slnt_axis/Mulish.glyphs -o variable --output-path "$VFDIR/Mulish[wght].ttf"
fontmake -g temp_no_slnt_axis/Mulish_Italic.glyphs -o variable --output-path "$VFDIR/Mulish-Italic[wght].ttf"

echo "Post processing VFs"
for f in $VFDIR/*.ttf
do
	echo Processing $f

	# Apply manual fvar table
	ttx -m $f Mulish_fvar.ttx
	mv ./Mulish_fvar.ttf $f
	# rm Mulish_fvar.ttf

	gftools fix-dsig -f $f
	ttfautohint $f $f.fix
	mv $f.fix $f
	gftools fix-unwanted-tables $f
	gftools fix-hinting $f
	mv $f.fix $f
done

rm -rf master_ufo/ instance_ufo/
