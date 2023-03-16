# Import sample data set: Twitter reaction to Prince Harry and Princess Meghan's appearance on Oprah in March 2021. 
twitter_data <- read.csv("/Users/brianroysar/Desktop/network_analysis/final_merged.csv", sep=',',header=TRUE,colClasses="character")

# Rename data set and convert it to a data frame.
surveillance <- data.frame(twitter_data)

# Activate the needed libraries.
library(dplyr)

# Replace empty strings (blank cells) with "NA"

surveillance[surveillance == ''] <- NA

# Select the columns you want to include in your edgelist and filter the resulting dataframe to only include replies. For this example, we're including the sending user's followers count, friends count, and location. Note the location data and determine whether is useful or not. Consider if/how you might want to work with location data for your own data set.

surveillance_replies <- surveillance %>%
  select(from_user_id_str, from_user, in_reply_to_user_id_str, in_reply_to_screen_name, time, text, user_followers_count, user_friends_count) %>%   
  filter(!is.na(surveillance$in_reply_to_user_id_str))

# View the resulting dataframe
# View(surveillance)

# Rename the column headers to match Gephi's naming conventions
colnames(surveillance_replies)[1] = "Source"
colnames(surveillance_replies)[3] = "Target"

# Replace NA values in the friends and followers count with 0 so Gephi recognizes the variables as integers.
# surveillance_replies[is.na(surveillance_replies)] <- 0

# Add sentiment scores

surveillance_replies_vader <- vader_df(surveillance_replies$text)
surveillance_replies <- surveillance_replies %>% 
  mutate(sentiment = surveillance_replies_vader$compound)

# Create categorical values from sentiment compound scores
surveillance_replies <- surveillance_replies %>%
  mutate(sent_cat = 
           case_when(
             surveillance_replies$sentiment >=0.75 ~ "Very Positive",
             surveillance_replies$sentiment >=0.2 & surveillance_replies$sentiment < 0.75 ~ "Moderately Positive",
             surveillance_replies$sentiment >= -0.2 & surveillance_replies$sentiment < 0.2 ~ "Neutral",
             surveillance_replies$sentiment <= -0.2 & surveillance_replies$sentiment > -0.75  ~ "Moderately Negative",
             surveillance_replies$sentiment < -0.75 ~ "Very Negative")
  )

View(surveillance_replies) # view the result

# Save the resulting data frame as a CSV file
write.csv(surveillance_replies, "/Users/brianroysar/Desktop/network_analysis/surveillance_edges.csv", row.names = FALSE)

# Remember to remove the first column (ID column that R auto-generates) of the CSV file before importing it into Gephi.

# Import the edgelist to Gephi.

