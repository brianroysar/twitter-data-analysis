# Load libraries
library(dplyr)
library(statnet)
library(vader)

# Load sample data set
surveillance_replies <- read.csv("/Users/brianroysar/Desktop/network_analysis/surveillance_edges.csv", sep=',',header=TRUE,colClasses="character")

# Create a nodes list with an ID column

surveillance_nodes1 <- select(surveillance_replies, Source, from_user, user_followers_count, user_friends_count)
surveillance_nodes2 <- select(surveillance_replies, Target, in_reply_to_screen_name)

surveillance_nodes1 <- unique(surveillance_nodes1)
surveillance_nodes2 <- unique(surveillance_nodes2)

# Create each column for the nodes spreadsheet based on the edges spreadsheet
ID <- c(surveillance_nodes1$Source, surveillance_nodes2$Target)
Label <- c(surveillance_nodes1$from_user, surveillance_nodes2$in_reply_to_screen_name)

followers_count <- unlist(surveillance_nodes1$user_followers_count)
friends_count <- unlist(surveillance_nodes1$user_friends_count)
surveillance_reply_nodes <- cbind(ID, Label, followers_count, friends_count)
royals_reply_nodes <- data.frame(surveillance_reply_nodes)

royals_reply_nodes <- unique(royals_reply_nodes)

View(royals_reply_nodes)

write.csv(royals_reply_nodes, "/Users/brianroysar/Desktop/network_analysis/surveillance_replies_nodes.csv", row.names=FALSE)

#------------------------------------------------------------------------------------------------

## Adding additional attributes ##

# run sentiment analysis and add compound score to edge list
royals_replies_vader <- vader_df(royals_replies$text)
royals_replies <- royals_replies %>% 
  mutate(sentiment = royals_replies_vader$compound)

royals_replies[is.na(royals_replies)] <- 0


View(royals_replies) # view the result

# Write the dataframes to csv files without row numbers for easy import into Gephi
write.csv(royals_replies, "royals_replies.csv", row.names = FALSE)
write.csv(royals_reply_nodes, "royals_reply_nodes.csv", row.names = FALSE)
