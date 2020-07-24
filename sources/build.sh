#!/bin/sh
set -e


echo "Generating Static fonts"
TTFDIR=../fonts/ttf
mkdir -p $TTFDIR
rm -rf $TTFDIR/*.ttf
fontmake -g Mulish.glyphs -i -o ttf --output-dir $TTFDIR -a

echo "Post processing"
ttfs=$(ls $TTFDIR/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	ttfautohint $ttf $ttf.fix
	mv "$ttf.fix" $ttf;
	gftools fix-hinting $ttf;
	mv "$ttf.fix" $ttf;
done


# echo "Generating VFs"
# VFDIR=../fonts/vf
# mkdir -p $VFDIR
# rm -rf $VFDIR/*.ttf
# fontmake -g temp_no_slnt_axis/Mulish.glyphs -o variable --output-path "$VFDIR/Mulish[wght].ttf"
# fontmake -g temp_no_slnt_axis/Mulish_Italic.glyphs -o variable --output-path "$VFDIR/Mulish-Italic[wght].ttf"

# echo "Post processing VFs"
# for f in $VFDIR/*.ttf
# do
# 	echo Processing $f

# 	# Apply manual fvar table
# 	ttx -m $f Mulish_fvar.ttx
# 	mv ./Mulish_fvar.ttf $f

# 	gftools fix-dsig -f $f
# 	gftools fix-unwanted-tables $f
# 	gftools fix-nonhinting $f $f.fix
# 	mv $f.fix $f
# done

# Clean up
rm -rf $VFDIR/*backup*.ttf
rm -rf master_ufo/ instance_ufo/
