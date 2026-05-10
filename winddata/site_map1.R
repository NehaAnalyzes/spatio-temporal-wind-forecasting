# install.packages(c("ggplot2", "ggspatial", "rosm", "sf"))
library(ggplot2)
library(ggspatial)      # annotation_map_tile()
library(sf)

# ---------- site coordinates ----------
setwd("/home/sat/work/winddata/")
lines <- readLines("latilongi.dat")

lat   <- as.numeric(sub(".*LATITUDE:\\s*([-0-9.]+).*",  "\\1", lines))
lon   <- as.numeric(sub(".*LONGITUDE:\\s*([-0-9.]+).*", "\\1", lines))

sites  <- data.frame(lon, lat)
sites  <- data.frame(lon, lat)
sites2 <- data.frame(lon = -104.41732, lat = 45.33335)

# ---------- tight bounding box --------
pad  <- 50
xlim <- range(c(sites$lon,  sites2$lon)) + c(-pad, pad)
ylim <- range(c(sites$lat,  sites2$lat)) + c(-pad, pad)

# ---------- build map -----------------
p <- ggplot() +
  annotation_map_tile(type = "osm", zoom = 11,
                      cachedir = "~/.osm_cache") +      # streets & names
  geom_point(data = sites,  aes(lon, lat), colour = "red",  size = 3) +
  geom_point(data = sites2, aes(lon, lat), colour = "blue", size = 3) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE) +
  theme_void() +
  ggtitle("Site locations – OpenStreetMap") +
  labs(caption = "© OpenStreetMap contributors")

ggsave("sites_map.pdf", p, width = 7, height = 5, device = cairo_pdf)
ggsave("sites_map.jpg", p,
       width  = 7, height = 5, units = "in",
       dpi    = 300,           # print quality
       device = "jpeg")
cat("✔ JPEG saved as sites_map.jpg (300 dpi)\n")