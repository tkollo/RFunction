library('rjson')
library('rsvg')
library('twitteR')
library('httr')
library('jsonlite')
library('ggplot2')

# Getting the weather data ------------------------------------------------------------------

credentials_file = "credentials.json"
credentials <- fromJSON(file=credentials_file)
key <- credentials$openweathermap$key
city <- "London"
country <- "GB"

url_api <- paste0("http://api.openweathermap.org/data/2.5/forecast?q=", city, ",", country,"&APPID=", key)

res <- content(GET(url_api))

dat <- data.frame(
  dt=sapply(res$list, `[[`, "dt_txt", USE.NAMES = FALSE),
  temp=sapply(sapply(res$list, `[`, "main"), `[[`, "temp", USE.NAMES = FALSE),
  stringsAsFactors = FALSE
)

dat$dt <- as.POSIXct(dat$dt, format='%Y-%m-%d %H:%M:%S', origin='GMT')
dat$temp <- round(dat$temp - 273.15, 1)

# Min and max temperature for annotating the plot
min_dat <- dat[which.min(dat$temp),]
max_dat <- dat[which.max(dat$temp),]

# Making the plot ------------------------------------------------------------------

p<-ggplot(dat, aes(x=dt, y=temp, colour=temp)) +
  geom_line() +
  geom_point(size=2) +
  geom_text(data=min_dat, aes(label=temp), nudge_y = -1, colour="black") +
  geom_text(data=max_dat, aes(label=temp), nudge_y = +1, colour="black") +
  scale_x_datetime(date_labels = "%a\n%b %d") +
  theme_bw(base_size = 16) +
  xlab(NULL) +
  scale_y_continuous(breaks = seq(0,100,5)) +
  ylab("Temperature (Celcius)") +
  ggtitle(paste0("Temperature forecast in ", city, ", ", country), subtitle=strftime(Sys.Date(), "%A, %B %d"))+ 
  geom_smooth(method = "loess", span=0.25, colour=NA, fill="grey80" ) +
  scale_color_continuous(low="blue", high="red", limits=c(-10, 50), guide=FALSE)

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

credentials <- fromJSON(file=credentials_file)
ckey <- credentials$twitter$consumer_key
csecret <- credentials$twitter$consumer_secret
atoken <- credentials$twitter$access_token
asecret <- credentials$twitter$access_secret

setup_twitter_oauth(ckey, csecret, atoken, asecret)
if (Sys.getenv('WEBSITE_COMPUTE_MODE') == 'Dynamic') {
  # The graphics libraries on the consumption mode are not available
  # so you cannot generate a graph
  tweet(paste("The temperature in", city, "is", dat$temp[1], "degrees Celcius.", "Use R on Azure Function https://github.com/thdeltei/azure-function-r"))  
} else {
  tweet(paste("The temperature in", city, "is", dat$temp[1], "degrees Celcius.", "Use R on Azure Function https://github.com/thdeltei/azure-function-r"), mediaPath = plot_file_png)
}

#  ------------------------------------------------------------------------