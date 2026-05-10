############################################################
## Static site map → JPEG (no interactive controls)
############################################################

# 0. Install / load required packages
pkgs <- c("sf", "osmdata", "ggplot2", "ggrepel", "rnaturalearth")
to_install <- pkgs[!pkgs %in% rownames(installed.packages())]
if(length(to_install)) install.packages(to_install, quiet = TRUE)

library(sf)
library(osmdata)
library(ggplot2)
library(ggrepel)
library(rnaturalearth)

# 1. Read your site data
setwd("/home/sat/work/winddata/")      # adjust path if needed
lines <- readLines("latilongi.dat")
lat   <- as.numeric(sub(".*LATITUDE:\\s*([-0-9.]+).*", "\\1", lines))
lon   <- as.numeric(sub(".*LONGITUDE:\\s*([-0-9.]+).*", "\\1", lines))
sites  <- data.frame(lon, lat, name = paste0("Site ", seq_along(lat)))
# extra site in blue
sites2 <- data.frame(lon  = -104.41732,
                     lat  =   45.33335,
                     name = "Extra site")

# 2. Build bounding box (±0.3° padding)
pad  <- 5
xlim <- range(c(sites$lon,  sites2$lon)) + c(-pad, pad)
ylim <- range(c(sites$lat,  sites2$lat)) + c(-pad, pad)
bbox <- c(xmin = xlim[1], ymin = ylim[1],
          xmax = xlim[2], ymax = ylim[2])

# 3. Fetch OSM background layers (cached in tempdir())
q <- opq(bbox = bbox)

roads  <- q %>%
  add_osm_feature(key = "highway",
                  value = c("motorway","primary","secondary","tertiary")) %>%
  osmdata_sf() %>% .$osm_lines

rivers <- q %>%
  add_osm_feature(key = "waterway", value = "river") %>%
  osmdata_sf() %>% .$osm_lines

water  <- q %>%
  add_osm_feature(key = "natural", value = c("water","lake")) %>%
  osmdata_sf() %>% .$osm_polygons

places <- q %>%
  add_osm_feature(key = "place",
                  value = c("city","town","village")) %>%
  osmdata_sf() %>% .$osm_points

# 4. First-level admin borders (states / provinces)
states <- ne_states(returnclass = "sf") %>%
  st_crop(xmin = bbox["xmin"], xmax = bbox["xmax"],
          ymin = bbox["ymin"], ymax = bbox["ymax"])

# 5. Prepare label data frames
state_centroids <- st_centroid(states$geometry)
state_coords    <- st_coordinates(state_centroids)
state_labels    <- data.frame(state_coords,
                              label = states$name_en)

place_coords <- st_coordinates(places$geometry)
place_labels <- data.frame(place_coords,
                           name = places$name)

###########333

# create an sfc POLYGON from your bbox
box_sfc <- st_as_sfc(st_bbox(c(xmin = xlim[1], xmax = xlim[2],
                               ymin = ylim[1], ymax = ylim[2]),
                             crs = 4326))

states <- ne_states(returnclass = "sf")
states_crop <- st_crop(states, box_sfc)
##################33

# 6. Combine site data for ggplot
sites_df  <- sites
sites2_df <- sites2

# 7. Build static ggplot
p <- ggplot() +
  # water bodies & rivers
  geom_sf(data = water,  fill = "aliceblue", colour = NA) +
  #geom_sf(data = rivers, colour = "skyblue3", size = 0.3) +
  # roads
#  geom_sf(data = roads,  colour = "grey60", size = 0.2) +
  # state borders
  geom_sf(data = states, fill = NA, colour = "grey50", size = 0.2) +
  # place labels (gray)
  geom_text(data = place_labels,
            aes(X, Y, label = name),
            size = 2.5, colour = "grey40",
            check_overlap = TRUE) +
  # state labels (darker gray, repel)
  #geom_text_repel(data = state_labels,
   #               aes(X, Y, label = label),
    #              size = 3, colour = "grey20",
     #             min.segment.length = 0) +
  # site points + labels
  geom_point(data = sites_df,  aes(lon, lat),
             colour = "red",  size = 3) +
  #geom_text(data = sites_df,
   #         aes(lon, lat, label = name),
    #        hjust = -0.1, vjust = -0.3, size = 3,
     #       colour = "red") +
  geom_point(data = sites2_df, aes(lon, lat),
             colour = "blue", size = 3) +
  geom_text(data = sites2_df,
            aes(lon, lat, label = name),
            hjust = -0.1, vjust = -0.3, size = 3,
            colour = "blue") +
  coord_sf(xlim = xlim, ylim = ylim, expand = TRUE) +
  theme_void() +
  ggtitle("Site Map with Landscape Details")

# 8. Save to JPEG (no UI controls to worry about)
ggsave("site_map.jpg", plot = p,
       width = 7, height = 5, dpi = 300)

cat("✔ Saved static JPEG: site_map.jpg\n")

