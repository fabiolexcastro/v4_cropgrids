

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(terra, fs, sf, tidyverse, glue, rnaturalearthdata, rnaturalearth)

g <- gc(reset = T)
rm(list = ls())
options(scipen = 999, warn = -1)


# Load data ---------------------------------------------------------------
wrld <- ne_countries(returnclass = 'sf', scale = 50)
rstr <- rast('./raw/22491997/CROPGRIDSv1.08_NC_maps/CROPGRIDSv1.08_NC_maps/CROPGRIDSv1.08_coffee.nc')

# To extract by mask  -----------------------------------------------------
rstr <- terra::crop(rstr, vect(wrld))
rstr <- terra::mask(rstr, vect(wrld))

# To remove zero values ---------------------------------------------------
rstr <- ifel(rstr <= 0, NA, rstr)

# Raster to table ---------------------------------------------------------
tble <- terra::as.data.frame(rstr, xy = TRUE)

# To make the map  --------------------------------------------------------
g.crop <- ggplot() + 
  geom_tile(data = tble, aes(x = x, y = y, fill = croparea)) + 
  scale_fill_viridis_c(na.value = 'white') + 
  geom_sf(data = wrld, fill = NA, col = 'grey60') +
  coord_sf() +
  labs(fill = 'Croparea') +
  theme_void() + 
  theme(legend.position = 'bottom', 
        legend.key.width = unit(3, 'line'))


# To save the maps  -------------------------------------------------------
dout <- glue('./png/maps'); dir_create(dout)
ggsave(plot = g.crop, filename = glue('{dout}/crop_coffee.jpg'), units = 'in', width = 9, height = 6, dpi = 300)





