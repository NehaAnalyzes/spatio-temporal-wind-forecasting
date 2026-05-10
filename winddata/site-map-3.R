#!/usr/bin/env Rscript

# ── 0. Settings ────────────────────────────────────────────────────────────────
data_file <- "latilongi.dat"               # your input file
out_pdf   <- "sites_map_inset.pdf"
out_jpg   <- "sites_map_inset.jpg"

# ── 1. Install & load packages ────────────────────────────────────────────────
required <- c("sf","osmdata","ggplot2","ggrepel",
              "rnaturalearth","cowplot")
to_install <- setdiff(required, installed.packages()[,"Package"])
if(length(to_install)) install.packages(to_install, quiet=TRUE)
lapply(required, library, character.only=TRUE)

# ── 2. Read sites & compute bbox ───────────────────────────────────────────────
lines <- readLines(data_file)
lat   <- as.numeric(sub(".*LATITUDE:\\s*([-0-9.]+).*", "\\1", lines))
lon   <- as.numeric(sub(".*LONGITUDE:\\s*([-0-9.]+).*", "\\1", lines))
sites <- data.frame(lon, lat, name = paste0("Site ", seq_along(lat)))

# optional extra point
sites2 <- data.frame(
  lon  = -104.41732,
  lat  = 45.33335,
  name = "Extra site"
)

pad  <- 0.6
xlim <- range(c(sites$lon, sites2$lon)) + c(-pad, pad)
ylim <- range(c(sites$lat, sites2$lat)) + c(-pad, pad)
bbox <- c(xmin = xlim[1], ymin = ylim[1],
          xmax = xlim[2], ymax = ylim[2])

# ── 3. Download OSM layers for zoomed area ────────────────────────────────────
message("Fetching OSM…")
q_base <- opq(bbox = bbox)

roads  <- q_base %>% add_osm_feature("highway",
                                     c("motorway","primary","secondary","tertiary")) %>%
  osmdata_sf() %>% .$osm_lines

rivers <- q_base %>% add_osm_feature("waterway","river") %>%
  osmdata_sf() %>% .$osm_lines

water  <- q_base %>% add_osm_feature("natural",c("water","lake")) %>%
  osmdata_sf() %>% .$osm_polygons

places <- q_base %>% add_osm_feature("place",
                                     c("city","town","village")) %>%
  osmdata_sf() %>% .$osm_points

# extract XY coords for place labels
place_df <- data.frame(
  st_coordinates(places),
  label = places$name
)

# ── 4. Load & fix state geometry, then crop ───────────────────────────────────
states_raw   <- rnaturalearth::ne_states(returnclass = "sf")
# repair invalid rings
states_fixed <- sf::st_make_valid(states_raw)
states       <- suppressWarnings(st_crop(states_fixed, bbox))

# ── 5. Build zoomed map ───────────────────────────────────────────────────────
pts  <- st_as_sf(sites,  coords = c("lon","lat"), crs = 4326)
pts2 <- st_as_sf(sites2, coords = c("lon","lat"), crs = 4326)

p_zoom <- ggplot() +
  geom_sf(data = water,   fill = "aliceblue", colour = NA) +
#  geom_sf(data = rivers,  colour = "skyblue3", linewidth = 0.4) +
  geom_sf(data = roads,   colour = "grey60",   linewidth = 0.3) +
  geom_sf(data = states,  fill = NA, colour = "grey50", linewidth = 0.3) +
  geom_sf(data = places,  colour = "grey50", size = 1) +
  geom_text_repel(
    data = place_df,
    aes(x = X, y = Y, label = label),
    size = 3, colour = "grey20"
  ) +
  geom_sf(data = pts,  colour = "red",  size = 3) +
  geom_sf(data = pts2, colour = "blue", size = 3) +
  # geom_text_repel(
  #   data = data.frame(st_coordinates(pts),  label = sites$name),
  #   aes(X, Y, label = label),
  #   colour = "red", size = 3
  # ) +
  # geom_text_repel(
  #   data = data.frame(st_coordinates(pts2), label = sites2$name),
  #   aes(X, Y, label = label),
  #   colour = "blue", size = 3
  # ) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "white", colour = NA)
  )


# ── 6. Build overview map ─────────────────────────────────────────────────────
overview_countries <- rnaturalearth::ne_countries(returnclass = "sf")

p_overview <- ggplot() +
  geom_sf(data = overview_countries,
          fill = "gray95", colour = "gray70") +
  geom_rect(aes(xmin = bbox["xmin"], xmax = bbox["xmax"],
                ymin = bbox["ymin"], ymax = bbox["ymax"]),
            colour = "red", fill = NA, size = 0.8) +
  coord_sf(expand = FALSE) +
  theme_void()

# ── 7. Compose inset with cowplot ─────────────────────────────────────────────
final_map <- cowplot::ggdraw() +
  cowplot::draw_plot(p_overview) +
  cowplot::draw_plot(p_zoom,
                    # x = 0.60, y = 0.55,
                    x = 0.20, y = 0.25,
                   #  width = 0.35, height = 0.35)
                  width = 0.65, height = 0.65)

# ── 8. Save outputs ────────────────────────────────────────────────────────────
ggsave(out_pdf, final_map, width = 10, height = 7)
ggsave(out_jpg, final_map, width = 10, height = 7, dpi = 1200)

message("✔ Saved: ", out_pdf, " & ", out_jpg)

