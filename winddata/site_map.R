# ----------------- libraries -----------------
library(ggplot2)
library(leaflet)
library(rnaturalearth)      # finer coastlines (≈1:10 m scale)
library(rnaturalearthdata)

# ----------------- 1. read data ---------------
setwd("/home/sat/work/winddata/")
lines <- readLines("latilongi.dat")

lat   <- as.numeric(sub(".*LATITUDE:\\s*([-0-9.]+).*",  "\\1", lines))
lon   <- as.numeric(sub(".*LONGITUDE:\\s*([-0-9.]+).*", "\\1", lines))

sites  <- data.frame(lon, lat)
sites2 <- data.frame(lon = 45.33335, lat = 45.33335)   # edit / extend

# --------------- 2. map limits ----------------
pad_deg <- 1                         # add ±1° around data
xlim <- range(c(sites$lon,  sites2$lon)) + c(-pad_deg, pad_deg)
ylim <- range(c(sites$lat,  sites2$lat)) + c(-pad_deg, pad_deg)

# --------------- 3. coastline -----------------
coast <- rnaturalearth::ne_countries(scale = "large",
                                     returnclass = "sf")

# --------------- 4. static plot ---------------
plot_static <- ggplot() +
  geom_sf(data = coast, fill = "grey90", colour = "white", linewidth = 0.2) +
  geom_point(data = sites,  aes(lon, lat), colour = "red",  size = 3) +
  geom_point(data = sites2, aes(lon, lat), colour = "blue", size = 3) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  theme_void() +
  ggtitle("Site locations")

ggsave("sites_map.pdf", plot_static, width = 6, height = 4, device = cairo_pdf)
cat("✔ PDF saved as sites_map.pdf\n")

# --------------- 5. interactive (optional) ----
leaflet() |>
  addProviderTiles("CartoDB.Positron") |>
  addCircleMarkers(data = sites,  ~lon, ~lat, radius = 4, color = "red") |>
  addCircleMarkers(data = sites2, ~lon, ~lat, radius = 4, color = "blue") |>
  fitBounds(xlim[1], ylim[1], xlim[2], ylim[2])

