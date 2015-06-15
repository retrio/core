.PHONY: all assets assets-plain assets-hover assets-click

all: assets

assets: assets-plain assets-hover assets-click

%-hover.png: %.svg
	cat $< | sed -E "s/fill:#[a-fA-F0-9]{6}/fill:#ffffff/g" | inkscape --export-width=192 --export-height=192 -e $@ /dev/stdin
	mogrify -resize 48x48 $@

%-click.png: %.svg
	cat $< | sed -E "s/fill:#[a-fA-F0-9]{6}/fill:#ff0000/g" | inkscape --export-width=192 --export-height=192 -e $@ /dev/stdin
	mogrify -resize 48x48 $@

%.png: %.svg
	cat $< | sed -E "s/fill:#[a-fA-F0-9]{6}/fill:#cccccc/g" | inkscape --export-width=192 --export-height=192 -e $@ /dev/stdin
	mogrify -resize 48x48 $@

assets-plain: $(patsubst assets/graphics/%.svg, assets/graphics/%.png, $(wildcard assets/graphics/*.svg))
assets-hover: $(patsubst assets/graphics/%.svg, assets/graphics/%-hover.png, $(wildcard assets/graphics/*.svg))
assets-click: $(patsubst assets/graphics/%.svg, assets/graphics/%-click.png, $(wildcard assets/graphics/*.svg))
