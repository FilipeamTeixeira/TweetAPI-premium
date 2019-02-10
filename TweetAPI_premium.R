# R example to extract tweets from Twitter premium API

library(httr)
library(base64enc)
library(tidyverse)

appname <- "twitter_app"
key <- "xxxxxxxx"
secret <- "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# base64 encoding
kands <- paste(key, secret, sep=":")
base64kands <- base64encode(charToRaw(kands))
base64kandsb <- paste("Basic", base64kands, sep=" ")

# request bearer token
resToken <- POST(url = "https://api.twitter.com/oauth2/token",
                 add_headers("Authorization" = base64kandsb, "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"),
                 body = "grant_type=client_credentials")

# get bearer token
bearer <- content(resToken)
bearerToken <- bearer[["access_token"]]
bearerTokenb <- paste("Bearer", bearerToken, sep=" ")


# search for tweets
latitude <- "40.6413"
longitude <- "-73.7781"
max_results <- 10
query <- ""
label <- "development"

resTweets <- POST(url = paste("https://api.twitter.com/1.1/tweets/search/fullarchive/", label,".json", sep = ""),
                  add_headers("authorization" = bearerTokenb, "content-Type" = "application/json"),
                  body = paste("{\"query\": ", query, " \"point_radius:[",
                               longitude, " ", latitude," 2km]\",\"maxResults\": ",
                               max_results,"}", sep = ""))

# parse tweets into data.frame
tweets <- content(resTweets)
tweets_result <- tweets$results

tweet_list <- list()
for (i in 1:max_results){
  tweet <- tweets_result[[i]]
  created_at <- as.character(tweet[["created_at"]])
  id <- as.numeric(tweet[["id"]])
  id_str <- as.character(tweet[["id_str"]])
  text <- as.character(tweet[["text"]])
  user_name <- as.character(tweet[["user"]][["name"]])
  screen_name <- as.character(tweet[["user"]][["screen_name"]])
  if(is.null(tweet[["coordinates"]][["coordinates"]])){
#    coords <- unlist(tweet[["place"]][["bounding_box"]]["coordinates"][[1]][[1]])
    longitude <- NA
    latitude <- NA
  }else{
    longitude <- tweet[["coordinates"]][["coordinates"]][[1]]
    latitude <- tweet[["coordinates"]][["coordinates"]][[2]]
  }
  lang <- as.character(tweet[["lang"]])
  retweeted <- tweet[["retweeted"]]
  
  tweet_df <- data.frame(created_at, id, id_str, id_str, text, user_name,
                         screen_name, latitude, longitude, lang, retweeted)
  
  tweet_list[[i]] <- tweet_df
}

tweet_df <- do.call(rbind, tweet_list)
View(tweet_df)
