.PHONY: all assets assets-plain assets-hover assets-click

all: assets

assets: assets-plain assets-hover assets-click

assets/graphics/%-hover.png: assets/svg/%.svg
	cat $< | sed -E "s/fill:#[a-fA-F0-9]{6}/fill:#ffffff/g" | inkscape --export-width=192 --export-height=192 -e $@ /dev/stdin
	mogrify -resize 48x48 $@

assets/graphics/%-click.png: assets/svg/%.svg
	cat $< | sed -E "s/fill:#[a-fA-F0-9]{6}/fill:#ff0000/g" | inkscape --export-width=192 --export-height=192 -e $@ /dev/stdin
	mogrify -resize 48x48 $@

assets/graphics/%.png: assets/svg/%.svg
	cat $< | sed -E "s/fill:#[a-fA-F0-9]{6}/fill:#cccccc/g" | inkscape --export-width=192 --export-height=192 -e $@ /dev/stdin
	mogrify -resize 48x48 $@

assets-plain: $(patsubst assets/svg/%.svg, assets/graphics/%.png, $(wildcard assets/svg/*.svg))
assets-hover: $(patsubst assets/svg/%.svg, assets/graphics/%-hover.png, $(wildcard assets/svg/*.svg))
assets-click: $(patsubst assets/svg/%.svg, assets/graphics/%-click.png, $(wildcard assets/svg/*.svg))
