install.packages("rvest")
install.packages("httr")
install.packages("xml2")
install.packages("dplyr")     # for data manipulation
install.packages("stringr")   # for string cleaning
install.packages("readr")     # for exporting CSV

library(rvest)
library(httr)
library(xml2)
library(dplyr)
library(stringr)

# Step 1: Define the URL for a specific year
year <- 2023
base_url <- paste0("https://virologyj.biomedcentral.com/articles?year=", year)

# Step 2: Read the HTML from the page
page <- read_html(base_url)

# Step 3: Extract article links
article_links <- page %>%
  html_nodes(".c-listing__title a") %>%
  html_attr("href") %>%
  paste0("https://virologyj.biomedcentral.com", .)

# Preview the links
head(article_links)

# Function to scrape one article
scrape_article_data <- function(url) {
  article_page <- read_html(url)
  
  # 1. Title
  title <- article_page %>%
    html_node("h1.c-article-title") %>%
    html_text(trim = TRUE)
  
  # 2. Authors
  authors <- article_page %>%
    html_nodes(".c-article-author-list__item") %>%
    html_text(trim = TRUE) %>%
    paste(collapse = ", ")
  
  # 3. Corresponding Author (fallback to NA)
  corr_author <- article_page %>%
    html_node(".c-article-corresponding-author__name") %>%
    html_text(trim = TRUE)
  if (is.null(corr_author)) corr_author <- NA
  
  # 4. Corresponding Email (fallback to NA)
  corr_email <- article_page %>%
    html_node(".c-article-corresponding-author__email a") %>%
    html_text(trim = TRUE)
  if (is.null(corr_email)) corr_email <- NA
  
  # 5. Publish Date
  pub_date <- article_page %>%
    html_node("time") %>%
    html_attr("datetime")
  
  # 6. Abstract (fallback to section#Abs1 or second alternative)
  abstract_node <- article_page %>%
    html_node("section#Abs1 .c-article-section__content")
  if (is.na(abstract_node) || is.null(abstract_node)) {
    abstract_node <- article_page %>%
      html_node(".Abstract .c-article-section__content")
  }
  abstract <- if (!is.null(abstract_node)) html_text(abstract_node, trim = TRUE) else NA
  
  # 7. Keywords
  keywords <- article_page %>%
    html_nodes(".c-article-subject-list__subject") %>%
    html_text(trim = TRUE) %>%
    paste(collapse = ", ")
  
  # Return as a data frame row
  return(data.frame(
    URL = url,
    Title = title,
    Authors = authors,
    Corresponding_Author = corr_author,
    Corresponding_Email = corr_email,
    Publish_Date = pub_date,
    Abstract = abstract,
    Keywords = keywords,
    stringsAsFactors = FALSE
  ))
}

test_article <- scrape_article_data("https://virologyj.biomedcentral.com/articles/10.1186/s12985-023-02256-z")
print(test_article)


# Scrape all articles
all_articles_data <- lapply(article_links, function(link) {
  tryCatch({
    scrape_article_data(link)
  }, error = function(e) {
    message(paste("Failed to scrape:", link))
    return(NULL)
  })
}) %>%
  bind_rows()

# Save to CSV
output_path <- "~/Library/Mobile Documents/com~apple~CloudDocs/Documents/College/CS636/Project_CS636/virology_articles_2023.csv"
write.csv(all_articles_data, output_path, row.names = FALSE)

# Print preview
head(all_articles_data)


# Step 7: Data Cleaning

cleaned_data <- all_articles_data %>%
  distinct() %>%  # Remove duplicate rows
  mutate(
    Authors = str_replace_all(Authors, "\\n", " "),
    Authors = str_replace_all(Authors, "ORCID:.*?(,|$)", ""),
    Authors = str_replace_all(Authors, ",,", ","),
    Authors = str_squish(Authors),  # remove extra spaces
    Abstract = str_squish(Abstract),
    Title = str_squish(Title),
    Keywords = str_squish(Keywords)
  )

# Save cleaned data
cleaned_path <- "~/Library/Mobile Documents/com~apple~CloudDocs/Documents/College/CS636/Project_CS636/virology_articles_2023_cleaned.csv"
write.csv(cleaned_data, cleaned_path, row.names = FALSE)

# Preview cleaned data
head(cleaned_data)

# Load ggplot2 for visualization
install.packages("ggplot2")  
library(ggplot2)

# Step 8: Visualize top 15 most frequent keywords
# Split keywords by comma and unnest them
library(tidyr)
library(tibble)

# Prepare keyword frequency table
keyword_freq <- cleaned_data %>%
  filter(!is.na(Keywords)) %>%
  pull(Keywords) %>%
  str_split(",\\s*") %>%
  unlist() %>%
  str_trim() %>%
  tolower() %>%
  as_tibble() %>%
  count(value, sort = TRUE) %>%
  top_n(15, n)

# Bar chart of top keywords
ggplot(keyword_freq, aes(x = reorder(value, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 15 Most Frequent Keywords (Virology Journal 2023)",
       x = "Keyword",
       y = "Frequency") +
  theme_minimal()

# Step 8b: Plot Article Counts by Date (Publication Timeline)
install.packages("lubridate")
library(lubridate)

# Convert Publish_Date to date format
cleaned_data$Publish_Date <- as.Date(cleaned_data$Publish_Date)

# Count articles by date
date_counts <- cleaned_data %>%
  filter(!is.na(Publish_Date)) %>%
  count(Publish_Date)

# Plot articles published over time
ggplot(date_counts, aes(x = Publish_Date, y = n)) +
  geom_col(fill = "darkgreen") +
  labs(title = "Articles Published Over Time in 2023",
       x = "Date",
       y = "Number of Articles") +
  theme_minimal()