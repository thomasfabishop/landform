
##Code for classifying landform using DEM

#Next steps are get DEM of example farms

#(i) diagonal (ii) L'lara (iii) dune/swale (iv) Willora


library(terra)
library(raster)
library(SLGACloud)
library(sf)
library(landform)

bindana_shp <- st_read("Data/BindanaDowns.shp")

# Download Elevation
prods <- getProductMetaData() # check for rows of interest
DEM <- cogLoad(prods[587,]$StagingPath) |> # select DEM
  crop(c(extent(bindana_shp)[1]-0.05, extent(bindana_shp)[2]+0.05, 
         extent(bindana_shp)[3]-0.05, extent(bindana_shp)[4]+0.05)) |> # crop to a buffered farm boundary
  brick() # formatting

plot(bindana_shp)

library(terra)
library(whitebox)

# Define file path for the GeoTIFF
tiff_path <- "Data/Bindana DEM.tif"
dem <- rast(tiff_path)
crs(dem) <- "EPSG:4326"  # Change if necessary

# Compute landform classification using the Pennock landform classification
landform_path <- "landform_classification.tif"
wb <- whitebox::WhiteboxTools()
wb$run_tool("PennockLandformClass", list(dem = tiff_path, output = landform_path))

# Compute terrain derivatives required for landform classification
wb <- whitebox::WhiteboxTools()
wb$set_working_directory(dirname(tiff_path))

test <- landform(dem,81)
plot(test$`Lower Slope`)
plot(bindana_shp, add = T, col = NA)

wb <- whitebox::WhiteboxTools()
wb$set_working_directory(dirname(tiff_path))

# Generate slope, aspect, and curvature
slope_path <- "slope.tif"
aspect_path <- "aspect.tif"
curvature_path <- "curvature.tif"
wb$run_tool("Slope", list(i = tiff_path, output = slope_path))
wb$run_tool("Aspect", list(i = tiff_path, output = aspect_path))
wb$run_tool("Curvature", list(i = tiff_path, output = curvature_path))

# Compute landform classification using the Pennock landform classification
landform_path <- "landform_classification.tif"
wb$run_tool("PennockLandformClass", list(dem = tiff_path, output = landform_path))

# Read and plot the classified landforms
landform <- rast(landform_path)
plot(landform, main = "Landform Classification")

# Save the output as a new raster
destination_path <- "path/to/output/landform_classification.tif"
writeRaster(landform, destination_path, format = "GTiff", overwrite = TRUE)

print("Landform classification completed and saved.")


# Check the DEM properties
print(dem)

# Ensure the CRS is set correctly
crs(dem) <- "EPSG:4326"  # Change if necessary

# Compute landform classification using the landform package
landform_class <- landform::classify_landforms(dem)

# Plot the classified landforms
plot(landform_class, main = "Landform Classification")

# Save the output as a new raster
destination_path <- "path/to/output/landform_classification.tif"
writeRaster(landform_class, destination_path, format = "GTiff", overwrite = TRUE)

print("Landform classification completed and saved.")


