############################################################
##  Site-map with rich background (OpenStreetMap features)
############################################################
pkgs <- c("sf", "osmdata", "ggplot2", "ggrepel", "rnaturalearth")
inst <- pkgs %in% rownames(installed.packages())
if (any(!inst)) install.packages(pkgs[!inst], quiet = TRUE)

library(sf)
library(osmdata)
library(ggplot2)
library(ggrepel)
library(rnaturalearth)           # for state borders

## ---------- 1. read site data ----------
setwd("/home/sat/work/winddata/")
lines <- readLines("latilongi.dat")
lat  <- as.numeric(sub(".*LATITUDE:\\s*([-0-9.]+).*",  "\\1", lines))
lon  <- as.numeric(sub(".*LONGITUDE:\\s*([-0-9.]+).*", "\\1", lines))
sites <- data.frame(lon, lat, name = paste0("Site ", seq_along(lat)))

sites2 <- data.frame(lon  = -104.41732,
                     lat  = 45.33335,
                     name = "Extra site")

## ---------- 2. build bounding box ----------
pad  <- 0.3                               # tighten if the map is too large
xlim <- range(c(sites$lon, sites2$lon)) + c(-pad, pad)
ylim <- range(c(sites$lat, sites2$lat)) + c(-pad, pad)
bbox <- c(xmin = xlim[1], ymin = ylim[1], xmax = xlim[2], ymax = ylim[2])

## ---------- 3. fetch OpenStreetMap layers ----------
message("Downloading OSM data … this runs once and is cached in tempdir()")

q <- opq(bbox = bbox)

roads  <- opq(bbox) %>%
  add_osm_feature("highway",
                  c("motorway", "primary",
                    "secondary", "tertiary")) %>%
  osmdata_sf() %>%
  .$osm_lines             # extract element

rivers <- opq(bbox) %>%
  add_osm_feature("waterway", "river") %>%
  osmdata_sf() %>%
  .$osm_lines

water  <- opq(bbox) %>%
  add_osm_feature("natural", c("water", "lake")) %>%
  osmdata_sf() %>%
  .$osm_polygons

places <- opq(bbox) %>%
  add_osm_feature("place", c("city", "town", "village")) %>%
  osmdata_sf() %>%
  .$osm_points

## ---------- 4. state borders (optional) ----------
states <- ne_states(scale = "medium", returnclass = "sf") |>
  st_crop(bbox)

## ---------- 5. convert sites to sf ----------
pts  <- st_as_sf(sites,  coords = c("lon", "lat"), crs = 4326)
pts2 <- st_as_sf(sites2, coords = c("lon", "lat"), crs = 4326)

## ---------- 6. build plot ----------
p <- ggplot() +
  # lakes / water bodies
  geom_sf(data = water,  fill = "aliceblue", colour = NA) +
  # rivers
  geom_sf(data = rivers, colour = "skyblue3", linewidth = 0.4) +
  # roads
  geom_sf(data = roads,  colour = "grey60", linewidth = 0.3) +
  # state borders
  geom_sf(data = states, fill = NA, colour = "grey50", linewidth = 0.3) +
  # towns / cities
  geom_sf(data = places, colour = "grey20", size = 1) +
  geom_text_repel(data = st_drop_geometry(places),
                  aes(x = lon, y = lat, label = name),
                  size = 3, colour = "grey20",
                  min.segment.length = 0) +
  # site symbols
  geom_sf(data = pts,  colour = "red",  size = 3) +
  geom_sf(data = pts2, colour = "blue", size = 3) +
  geom_text_repel(data = data.frame(st_coordinates(pts), label = sites$name),
                  aes(X, Y, label = label),
                  colour = "red",  size = 3,
                  min.segment.length = 0) +
  geom_text_repel(data = data.frame(st_coordinates(pts2), label = sites2$name),
                  aes(X, Y, label = label),
                  colour = "blue", size = 3,
                  min.segment.length = 0) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  theme_void() +
  ggtitle("Site map with OSM background")

## ---------- 7. export ----------
pdf("sites_map.pdf", width = 7, height = 5)
print(p)
dev.off()

jpeg("sites_map.jpg", width = 2200, height = 1600, quality = 94)
print(p)
dev.off()

message("✔  maps saved: sites_map.pdf (vector) and sites_map.jpg (raster)")

