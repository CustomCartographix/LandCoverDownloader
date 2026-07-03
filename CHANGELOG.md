# Changelog

All notable changes to the Land Cover Downloader QGIS plugin are documented
in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.2] - 2026-07-03

### Added

- **Support for 2025 land cover data.** `YEARLIST` now runs 2017–2025 and
  the "Data Collection Year" enum defaults to the newest year. Esri released
  the 2025 tiles in April 2026 (confirmed via
  [Esri Community thread](https://community.esri.com/t5/arcgis-living-atlas-questions/2025-update-on-sentinel-2-10m-land-use-land-cover/td-p/1696377)),
  using the same year-end-inclusive naming as 2024
  (`lc2025/{zone}_20250101-20251231.tif`). `downloadLandCoverRaster` was
  generalized to apply the new naming convention for any year ≥ 2024, so
  future years should Just Work if Esri keeps the same convention.

### Changed

- Default `defaultValue` on the year enum is now computed as
  `len(YEARLIST) - 1` rather than a hardcoded index, so it auto-tracks the
  newest entry.

## [1.0.1] - 2026-07-03

### Fixed

- **`numpy._core._exceptions._ArrayMemoryError` from `gdal:merge` on large,
  multi-UTM-zone AOIs.**
  `gdal_merge.py` allocated the entire output as an int64 numpy array, which
  aborted on wide AOIs (dkrasne's case tried to allocate 47.7 GiB). The
  clip-per-tile + `gdal:merge` sequence has been replaced with a single
  `osgeo.gdal.Warp` call that mosaics, reprojects (multi-UTM input), and
  clips to the AOI cutline in one streaming pass. Peak memory is now a few MB
  regardless of AOI size. (Reported in the follow-up on
  [issue #1](https://github.com/CustomCartographix/LandCoverDownloader/issues/1).)
- **Output raster now renders with the Esri Living Atlas palette instead of grayscale.**
  The new `gdal.Warp` pipeline preserves the source color table directly on
  the output GeoTIFF (unlike `gdal:merge`, which stripped it). On top of that,
  a bundled QML style (`resources/land_cover_style.qml`) covering the nine
  Esri classes (Water, Trees, Flooded vegetation, Crops, Built area, Bare
  ground, Snow/Ice, Clouds, Rangeland) is applied via a
  `QgsProcessingLayerPostProcessorInterface` implementation so the layer also
  loads with matching class labels in the QGIS legend.
- **`DeprecationWarning: QgsVectorFileWriter.writeAsVectorFormat()` is deprecated.**
  Replaced with `writeAsVectorFormatV3()`, using a `SaveVectorOptions` object
  for driver, encoding, and `onlySelectedFeatures`. (Reported in
  [issue #1](https://github.com/CustomCartographix/LandCoverDownloader/issues/1).)
- **`ResourceWarning: unclosed file` in `downloadLandCoverRaster`.**
  The `open(output_filename, "wb").write(content)` call left the file handle
  dangling; it is now wrapped in a `with` block so the writer is closed
  deterministically. (Reported in
  [issue #1](https://github.com/CustomCartographix/LandCoverDownloader/issues/1).)
- **`ResourceWarning: Implicitly cleaning up <TemporaryDirectory ...>`.**
  The scratch directory was being garbage-collected instead of explicitly
  cleaned up. It is now used as a context manager
  (`with TemporaryDirectory() as scratch_folder:`), which also removes the
  dependency on the Python 3.12-only `delete=` keyword argument. (Reported in
  [issue #1](https://github.com/CustomCartographix/LandCoverDownloader/issues/1).)
- **Network errors during tile download now surface as clear Processing errors.**
  `downloadLandCoverRaster` checks `QNetworkReply.error()` and raises
  `QgsProcessingException` with the failing URL and Qt's error string. Previously
  a failed request silently wrote a corrupt/empty file that later blew up
  opaquely in GDAL.
- **`chdir()` no longer mutates process-wide state.**
  Resource paths (packaged UTM grid, icons, style, scratch files) are built
  with `os.path.join(os.path.dirname(__file__), ...)` instead.
- **README typo: "Data Collection Year (2014-2017)" → "(2017-2024)".**
  Fixed all three occurrences plus the "range: 2014-2024" line. The
  algorithm-code labels were already correct.

### Changed

- **Mosaic/clip pipeline rewritten around `osgeo.gdal.Warp`.**
  Replaces the old `gdal:cliprasterbymasklayer` (per tile) + `gdal:merge`
  chain in `mosaicAndClipRasters`. The new implementation writes the AOI to a
  temporary shapefile cutline, then does a single `gdal.Warp` pass over all
  downloaded tiles with `resampleAlg='near'` (categorical data),
  `cropToCutline=True`, and `dstSRS=` the AOI CRS. Output is LZW-compressed
  tiled GeoTIFF. GDAL warp progress is forwarded to the Processing feedback
  panel via a callback, and cancellation aborts the warp cleanly.
- **Deduplicated the three algorithm classes.**
  The download / UTM-select / clip / mosaic sequence is now a single helper
  (`runLandCoverPipeline`) in `land_cover_functions.py`, called by all three
  algorithms. `DownloadFromLatLng`, `DownloadFromPoint`, and `DownloadFromAoi`
  now share a `_LandCoverAlgorithmBase` for translation, help URL, display name,
  year-parameter creation, output-raster-parameter creation, and post-processor
  registration. `YEARLIST` and the model CRS are module-level constants.
- **`qgisMinimumVersion` bumped from `3.0` to `3.20`.**
  Required by `QgsVectorFileWriter.writeAsVectorFormatV3()`.

### Added

- `resources/land_cover_style.qml` — QGIS QML style for the Esri Sentinel-2
  Land Use/Land Cover palette.
- `resources/aoi_outline_style.qml` — polygon style for the generated AOI:
  solid red outline (0.6 mm) with no fill. Applied automatically to the AOI
  vector output of the Lat/Lng and Point tools (the AOI tool takes an AOI
  as input and produces no AOI output).
- Post-processors in `land_cover_functions.py` that apply the bundled styles
  when the output layers load into the project:
  `SetLandCoverStylePostProcessor` (for the raster) and
  `SetAoiOutlineStylePostProcessor` (for the AOI). Both subclass a shared
  `_StyleFromQmlPostProcessor` base so the load-and-repaint logic lives in
  one place.
- Docstrings on all shared helpers in `land_cover_functions.py`.

## [1.0.0] - 2026-01-11

### Added

- Initial release with three Processing algorithms:
  - Download Land Cover from Lat/Lng
  - Download Land Cover from Point
  - Download Land Cover from AOI
- Downloads Sentinel-2 10 m Land Use / Land Cover data from Esri's Living
  Atlas (2017–2024).
