#!/usr/bin/env Rscript

# ── 0. SETTINGS ───────────────────────────────────────────────────────────────
data_file <- "latilongi.dat"
out_pdf   <- "sites_map_inset.pdf"
out_jpg   <- "sites_map_inset.jpg"

pad_zoom <- 0.9   # extra padding around your sites in the zoom map

# ── INSET POSITION & SIZE in NPC units ────────────────────────────────────────
# These four must match draw_plot() arguments below
in_x <- 0.20    # inset lower-left corner (horizontal)
in_y <- 0.25    # inset lower-left corner (vertical)
in_w <- 0.65    # inset width
in_h <- 0.65    # inset height

# ── 1. INSTALL & LOAD ─────────────────────────────────────────────────────────
pkgs <- c("sf","osmdata","ggplot2","ggrepel",
          "rnaturalearth","cowplot","grid")
to_install <- setdiff(pkgs, installed.packages()[,"Package"])
if(length(to_install)) install.packages(to_install, quiet=TRUE)
lapply(pkgs, library, character.only=TRUE)

# ── 2. READ SITES & ZOOM BBOX ─────────────────────────────────────────────────
setwd("/home/sat/work/winddata/")
lines <- readLines(data_file)
lat   <- as.numeric(sub(".*LATITUDE:\\s*([-0-9.]+).*","\\1",lines))
lon   <- as.numeric(sub(".*LONGITUDE:\\s*([-0-9.]+).*","\\1",lines))
sites <- data.frame(lon, lat, name = paste0("Site ", seq_along(lat)))

# optional extra point
sites2 <- data.frame(lon=-104.41732, lat=45.33335, name="Extra site")

xlim <- range(c(sites$lon, sites2$lon)) + c(-pad_zoom, pad_zoom)
ylim <- range(c(sites$lat, sites2$lat)) + c(-pad_zoom, pad_zoom)
bbox <- c(xmin=xlim[1], ymin=ylim[1], xmax=xlim[2], ymax=ylim[2])

# ── 3. FETCH OSM FOR ZOOM ─────────────────────────────────────────────────────
message("Fetching OSM data…")
q_base <- opq(bbox=bbox)
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
place_df <- data.frame(st_coordinates(places), label=places$name)

# ── 4. LOAD & CROP STATES ─────────────────────────────────────────────────────
states_raw   <- ne_states(returnclass="sf")
states_fixed <- st_make_valid(states_raw)
states_zoom  <- suppressWarnings(st_crop(states_fixed, bbox))

# ── 5. ZOOMED MAP ─────────────────────────────────────────────────────────────
pts  <- st_as_sf(sites,  coords=c("lon","lat"), crs=4326)
pts2 <- st_as_sf(sites2, coords=c("lon","lat"), crs=4326)

p_zoom <- ggplot() +
  geom_sf(data=water,  fill="aliceblue", colour=NA) +
  geom_sf(data=rivers, colour="skyblue3", linewidth=0.4) +
  geom_sf(data=roads,  colour="grey60", linewidth=0.3) +
  geom_sf(data=states_zoom, fill=NA, colour="grey50", linewidth=0.3) +
  geom_sf(data=places, colour="grey20", size=1) +
  geom_text_repel(data=place_df,
                  aes(x=X, y=Y, label=label),
                  size=3, colour="grey20") +
  geom_sf(data=pts,  colour="red",  size=3) +
  geom_sf(data=pts2, colour="blue", size=3,pch=15) +
  # geom_text_repel(data=data.frame(st_coordinates(pts),  label=sites$name),
  #                 aes(X,Y,label=label), colour="red",  size=3) +
  # geom_text_repel(data=data.frame(st_coordinates(pts2), label=sites2$name),
  #                 aes(X,Y,label=label), colour="blue", size=3) +
  coord_sf(xlim=xlim, ylim=ylim, expand=FALSE) +
  theme_void() +
  theme(panel.background=element_rect(fill="white",colour=NA))

# ── 6. OVERVIEW BASE ──────────────────────────────────────────────────────────
overview_countries <- ne_countries(returnclass="sf")
p_overview_base <- ggplot() +
  geom_sf(data=overview_countries,
          fill="gray95", colour="gray70") +
  geom_rect(aes(xmin = bbox["xmin"], xmax = bbox["xmax"],
                ymin = bbox["ymin"], ymax = bbox["ymax"]),
            colour = "red", fill = NA, size = 0.8) +
  coord_sf(expand=FALSE) +
  theme_void()

# ── 7. NORMALIZE RED BOX AGAINST WORLD ─────────────────────────────────────────
world_bb <- st_bbox(overview_countries)
xr <- c(world_bb["xmin"], world_bb["xmax"])
yr <- c(world_bb["ymin"], world_bb["ymax"])

rxmin <- (bbox["xmin"] - xr[1]) / diff(xr)
rxmax <- (bbox["xmax"] - xr[1]) / diff(xr)
rymin <- (bbox["ymin"] - yr[1]) / diff(yr)
rymax <- (bbox["ymax"] - yr[1]) / diff(yr)

# ── 8. DRAW RECTANGLE & CONNECTORS in NPC ─────────────────────────────────────
rect_cx <- (rxmin + rxmax)/2
rect_cy <- (rymin + rymax)/2
rect_w  <- rxmax - rxmin
rect_h  <- rymax - rymin

rect_grob <- grid::rectGrob(
  x      = unit(rect_cx, "npc"),
  y      = unit(rect_cy, "npc"),
  width  = unit(rect_w,  "npc"),
  height = unit(rect_h,  "npc"),
  gp     = grid::gpar(col="red", fill=NA, lwd=0.8)
)

connector_grob <- grid::segmentsGrob(
  x0 = unit(c(rxmin, rxmin,  rxmax, rxmax),       "npc"),
  y0 = unit(c(rymin, rymax,  rymin, rymax),       "npc"),
  x1 = unit(c(in_x,   in_x,    in_x+in_w, in_x+in_w), "npc"),
  y1 = unit(c(in_y,   in_y+in_h,in_y,     in_y+in_h), "npc"),
  gp = grid::gpar(col="red", lwd=1)
)

# ── 9. COMPOSE & SAVE ────────────────────────────────────────────────────────
final_map <- cowplot::ggdraw() +
  cowplot::draw_plot(p_overview_base) +
  cowplot::draw_plot(p_zoom,
                     x      = in_x,
                     y      = in_y,
                     width  = in_w,
                     height = in_h) +
  cowplot::draw_grob(rect_grob) +
  cowplot::draw_grob(connector_grob)

final_map <- cowplot::ggdraw() +
  cowplot::draw_plot(p_overview_base) +
  cowplot::draw_plot(p_zoom,
                     x = 0.15, y = 0.05,    # you may need to tweak x/y too
                     width = 0.90, height = 0.85)

ggsave(out_pdf, final_map, width=10, height=7)
ggsave(out_jpg, final_map, width=10, height=7, dpi=1200)

message("✔ Saved: ", out_pdf, " & ", out_jpg)

