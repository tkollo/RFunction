library('rjson')
library('rsvg')
library('twitteR')
library('httr')
library('jsonlite')
library('ggplot2')

library(viridis)
library(geojsonio)
library(broom)
library(dplyr)



data=read.table("https://www.r-graph-gallery.com/wp-content/uploads/2017/12/data_on_french_states.csv", header=T, sep=";")
data %>% ggplot( aes(x=nb_equip)) + geom_histogram(bins=20, fill='skyblue', color='white') + scale_x_log10()




spdf <- geojson_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/communes.geojson",  what = "sp")

# Since it is a bit to much data, I select only a subset of it:
spdf = spdf[ substr(spdf@data$code,1,2)  %in% c("06", "83", "13", "30", "34", "11", "66") , ]

# I need to fortify the data AND keep trace of the commune code! (Takes 2 minutes)

spdf_fortified <- tidy(spdf, region = "code")


spdf_fortified = spdf_fortified %>%
  left_join(. , data, by=c("id"="depcom")) 

spdf_fortified$nb_equip[ is.na(spdf_fortified$nb_equip)] = 0.001




p <- ggplot() +
  geom_polygon(data = spdf_fortified, aes(fill = nb_equip, x = long, y = lat, group = group) , size=0, alpha=0.9) +
  theme_void() +
  scale_fill_viridis(trans = "log", breaks=c(1,25,50,100,200), name="Number of restaurant", guide = guide_legend( keyheight = unit(3, units = "mm"), keywidth=unit(12, units = "mm"), label.position = "bottom", title.position = 'top', nrow=1) ) +
  labs(
    title = "South of France Restaurant concentration",
    subtitle = "Number of restaurant per city district", 
    caption = "Data: INSEE | Creation: Yan Holtz | r-graph-gallery.com"
  ) +
  theme(
    text = element_text(color = "#22211d"), 
    plot.background = element_rect(fill = "#f5f5f2", color = NA), 
    panel.background = element_rect(fill = "#f5f5f2", color = NA), 
    legend.background = element_rect(fill = "#f5f5f2", color = NA),
    
    plot.title = element_text(size= 18, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.4, l = 2, unit = "cm")),
    plot.subtitle = element_text(size= 12, hjust=0.01, color = "#4e4d47", margin = margin(b = -0.1, t = 0.43, l = 2, unit = "cm")),
    plot.caption = element_text( size=7, color = "#4e4d47", margin = margin(b = 0.3, r=-99, unit = "cm") ),
    
    legend.position = c(0.7, 0.09)
  ) +
  coord_map()


# Export to file ------------------------------------------------------------------

# Printing to SVG first and then converting to PNG because of graphics driver issues
plot_file <- tempfile(fileext = ".svg")
svg(plot_file, width=7, height=5)
print(p)
dev.off()
plot_file_png <- tempfile(fileext = ".png")
rsvg_png(plot_file, plot_file_png)

#  ------------------------------------------------------------------------

# Posting to twitter ------------------------------------------------------------------

credentials <- fromJSON(credentials_file)
ckey <- credentials$twitter$consumer_key
csecret <- credentials$twitter$consumer_secret
atoken <- credentials$twitter$access_token
asecret <- credentials$twitter$access_secret

setup_twitter_oauth(ckey, csecret, atoken, asecret)
if (Sys.getenv('WEBSITE_COMPUTE_MODE') == 'Dynamic') {
  # The graphics libraries on the consumption mode are not available
  # so you cannot generate a graph
  tweet(paste("Restaurants in southern France."))  
} else {
  tweet(paste("Restaurants in southern France."), mediaPath = plot_file_png)
}

#  ------------------------------------------------------------------------