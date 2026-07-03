<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.20" styleCategories="AllStyleCategories" hasScaleBasedVisibilityFlag="0">
  <pipe>
    <provider>
      <resampling enabled="false" zoomedOutResamplingMethod="nearestNeighbour" zoomedInResamplingMethod="nearestNeighbour" maxOversampling="2"/>
    </provider>
    <rasterrenderer type="paletted" opacity="1" band="1" alphaBand="-1" nodataColor="">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <colorPalette>
        <paletteEntry value="1" color="#1a5bab" label="Water" alpha="255"/>
        <paletteEntry value="2" color="#358221" label="Trees" alpha="255"/>
        <paletteEntry value="4" color="#87d19e" label="Flooded vegetation" alpha="255"/>
        <paletteEntry value="5" color="#ffdb5c" label="Crops" alpha="255"/>
        <paletteEntry value="7" color="#ed022a" label="Built area" alpha="255"/>
        <paletteEntry value="8" color="#ede9e4" label="Bare ground" alpha="255"/>
        <paletteEntry value="9" color="#f2faff" label="Snow/Ice" alpha="255"/>
        <paletteEntry value="10" color="#c8c8c8" label="Clouds" alpha="255"/>
        <paletteEntry value="11" color="#c6ad8d" label="Rangeland" alpha="255"/>
      </colorPalette>
      <colorramp name="[source]" type="randomcolors"/>
    </rasterrenderer>
    <brightnesscontrast brightness="0" contrast="0" gamma="1"/>
    <huesaturation colorizeGreen="128" colorizeOn="0" colorizeRed="255" colorizeBlue="128" grayscaleMode="0" saturation="0" colorizeStrength="100" invertColors="0"/>
    <rasterresampler maxOversampling="2"/>
    <resamplingStage>resamplingFilter</resamplingStage>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
