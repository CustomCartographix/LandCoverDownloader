# Changelog

All notable changes to the Land Cover Downloader QGIS plugin are documented
in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.1] - 2026-07-03

### Fixed

- **Output raster now renders with the Esri Living Atlas palette instead of grayscale.**
  `gdal:merge` strips color tables when combining paletted tiles, and
  `gdal:cliprasterbymasklayer` did not reliably preserve them either, so QGIS
  fell back to Singleband Gray. A bundled QML style
  (`resources/land_cover_style.qml`) covering the nine Esri classes (Water,
  Trees, Flooded vegetation, Crops, Built area, Bare ground, Snow/Ice, Clouds,
  Rangeland) is now applied to the output raster via a
  `QgsProcessingLayerPostProcessorInterface` implementation, so the correct
  symbology loads automatically for all three tools.
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
- `SetLandCoverStylePostProcessor` in `land_cover_functions.py` —
  post-processor that applies the bundled style when the output raster loads
  into the project.
- Docstrings on all shared helpers in `land_cover_functions.py`.

### Known issues (not addressed in this release)

- **`numpy._core._exceptions._ArrayMemoryError` from `gdal:merge` on large,
  multi-UTM-zone AOIs** (from the follow-up in
  [issue #1](https://github.com/CustomCartographix/LandCoverDownloader/issues/1)).
  `gdal_merge.py` allocates the full output as an int64 array, which fails on
  wide AOIs. Fixing this properly means replacing the clip-then-merge sequence
  with a `gdal:buildvirtualraster` (VRT) + single-clip pipeline that streams
  instead of allocating the output in memory. Planned for a future release.

## [1.0.0] - 2026-01-11

### Added

- Initial release with three Processing algorithms:
  - Download Land Cover from Lat/Lng
  - Download Land Cover from Point
  - Download Land Cover from AOI
- Downloads Sentinel-2 10 m Land Use / Land Cover data from Esri's Living
  Atlas (2017–2024).
