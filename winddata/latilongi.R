# --------------------- libraries ---------------------
library(ggplot2)   # static plot
library(maps)      # world outlines
library(leaflet)   # optional interactive map

# --------------------- 1. read & parse ----------------
setwd("/home/sat/work/winddata/")
############################################################
## Site‑map generator
## ---------------------------------------------------------
##  • Input  : "sites.txt"   (one line per site)
##  • Output : "sites_map.pdf"
############################################################



# ----- 1.  read & parse -----------------------------------
file_path <- "latilongi.dat"          # change if needed
lines <- readLines(file_path)

# extract numbers after LATITUDE: / LONGITUDE:
lat <- as.numeric(sub(".*LATITUDE:\\s*([-0-9.]+).*",   "\\1", lines))
lon <- as.numeric(sub(".*LONGITUDE:\\s*([-0-9.]+).*",  "\\1", lines))

sites  <- data.frame(lon = lon, lat = lat)
sites2 <- data.frame(lon = 45.33335, lat = 45.33335)
# ----- 2.  compute padded limits --------------------------
pad  <- 0.01                           # 5 % margin
xlim <- range(sites$lon)
ylim <- range(sites$lat)

xlim <- xlim + c(-1, 1) * diff(xlim) * pad
ylim <- ylim + c(-1, 1) * diff(ylim) * pad

# ----- 3.  build static map -------------------------------
world <- map_data("world")

plot_static <- ggplot() +
  geom_polygon(data = world,
               aes(long, lat, group = group),
               fill = "grey90", colour = "white", linewidth = 0.2) +
  geom_point(data = sites,
             aes(lon, lat),
             colour = "red", size = 3) +
  coord_fixed(xlim = xlim, ylim = ylim) +
  theme_void() +
  ggtitle("Site locations (40 points)")
plot_static

# ----- 4.  save to PDF ------------------------------------
ggsave("sites_map.jpg", plot = plot_static,
       width = 6, height = 4, device = "jpg")

cat("✔ PDF saved as sites_map.pdf\n")

# ----- 5.  optional interactive view ----------------------
leaflet(sites) |>
  addProviderTiles("CartoDB.Positron") |>
  addCircleMarkers(~lon, ~lat, radius = 3,
                   color = "red", fillOpacity = 1.1) |>
  fitBounds(lng1 = xlim[1], lat1 = ylim[1],
            lng2 = xlim[2], lat2 = ylim[2])



