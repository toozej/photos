# [photos](https://photos.toozej.com)

Photography site built with [Folio Deluxe](https://github.com/toozej/hugo-theme-folio-deluxe).

## Usage

Install Hugo 0.158.0 or later and Python 3.9 or later. Builds need network access to download photographs from the existing photo hosts.

```sh
git submodule update --init --recursive
make build
make check
make serve
```

The theme is a Git submodule. A new clone can use `git clone --recurse-submodules git@github.com:toozej/photos.git`.
Set `HUGO=/path/to/hugo` when the default executable is too old.

Collections remain in `content/collections/`. Each collection uses its existing `images.txt` manifest. Set `cover` to a full image URL to select its cover. The Film-Only collection uses `weight: -10` to remain first.

The homepage keeps its three featured photos from `content/home-images.txt`. The Collections page shows collection covers and photo counts. Collections without photos remain in the source but do not appear as empty cards.

Uses categories and equipment remain in `content/uses/`. Equipment uses `gearType` for its description. An item without an image uses the theme's placeholder.

The Feed and category pages use site templates to show collection photos with the Folio Deluxe viewer. The build checks links, image alternatives, and WebP output. The build keeps original photos and source manifests out of `public/`.
