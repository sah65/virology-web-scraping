# virology-web-scraping

A solo project for **CS636004 - Data Analytics with R Programming** (Spring 2025)  
Instructor: Prof. Jaini Bhavsar  
Author: **Sanim Hossain (sah65)**

---

## 📌 Project Description

This project demonstrates the use of R for web scraping and data analysis.  
I extracted article metadata from the [Virology Journal (BioMed Central)](https://virologyj.biomedcentral.com/) and performed keyword-based analysis of recent publications.

---

## 🛠️ Technologies Used

- **Language**: R  
- **Packages**: `rvest`, `dplyr`, `stringr`, `ggplot2`, `readr`  
- **Tools**: RStudio, GitHub

---

## 📁 Files Included

| File | Description |
|------|-------------|
| `virology_scraper.R` | R script to extract, clean, and analyze Virology Journal articles |
| `virology_articles_2023_cleaned.csv` | Extracted and cleaned dataset with article info |
| `Virology_Project_Slides_Sanim_Hossain_With_Code.pptx` | Presentation slides for submission and demo |
| `README.md` | Project overview and usage |

---

## 📊 Key Visualizations

- **Top 15 Most Frequent Keywords**: Bar plot showing commonly occurring research keywords
- **Keyword Distribution by Month**: Line plot showing keyword appearance trend across time

---

## 🧠 Learning Outcomes

- Gained hands-on experience with **web scraping** using R and `rvest`
- Understood how to handle **real-world data inconsistencies** (e.g., encoding issues, irregular authorship formats)
- Built a complete **data pipeline** from extraction → cleaning → analysis → visualization

---

## 📎 How to Reproduce

1. Clone the repo:
   ```bash
   git clone https://github.com/sah65/virology-web-scraping.git
   cd virology-web-scraping
