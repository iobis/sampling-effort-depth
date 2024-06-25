library(dplyr)
library(arrow)
library(sfarrow)
library(sf)
library(ggplot2)
library(viridis)
library(h3jsr)
library(scales)
library(glue)

generate_figure <- function(dataset, title, outfile) {

  # open dataset
  
  ds <- open_dataset(dataset)
  
  # summarize
  
  df <- ds %>% 
    group_by(cell) %>%
    summarize(records = sum(records)) %>% 
    collect() %>% 
    mutate(geometry = cell_to_polygon(cell)) %>% 
    st_as_sf(crs = 4326) %>% 
    st_wrap_dateline()
  
  # filter
  
  sf_use_s2(FALSE)
  bbox <- st_bbox(c(xmin = -180, ymin = -85, xmax = 180, ymax = 85), crs = st_crs(4326))
  bbox_sf <- st_as_sfc(bbox)
  filtered_df <- st_intersection(df, bbox_sf)
  
  # plot
  
  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  n_recs <- label_comma()(sum(df$records))
  
  ggplot() +
    geom_sf(data = filtered_df, aes(fill = records), color = NA) +
    geom_sf(data = world, color = NA, fill = "#dddddd") +
    scale_fill_viridis(option = "inferno", na.value = "white", trans = "log10", labels = comma) +
    coord_sf(crs = "ESRI:54030") +
    theme_void() +
    theme(legend.position = "bottom", legend.key.width = unit(1, "in")) +
    ggtitle(title, subtitle = glue("{n_recs} records"))
  
  ggsave(outfile, width = 10, height = 5, dpi = 600, bg = "white", scale = 1.2)
  
}

generate_figure("data/h3_4_20231025_0_200", "0 - 200 m", "data/depth_0_200.png")
generate_figure("data/h3_4_20231025_200_3000", "200 - 3000 m", "data/depth_200_3000.png")
generate_figure("data/h3_4_20231025_3000_6000", "3000 - 6000 m", "data/depth_3000_6000.png")
