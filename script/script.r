options(tz="Europe/Berlin")

library(httr)
library(jsonlite)
library(rjson)
library(rsvg)
library(twitteR)
library(ggplot2)


text <- as.character(Sys.time())

credentials_file = "credentials.json"
credentials <- jsonlite::fromJSON(credentials_file)
ckey <- credentials$twitter$consumer_key
csecret <- credentials$twitter$consumer_secret
atoken <- credentials$twitter$access_token
asecret <- credentials$twitter$access_secret

setup_twitter_oauth(ckey, csecret, atoken, asecret)

tweet(text) 
