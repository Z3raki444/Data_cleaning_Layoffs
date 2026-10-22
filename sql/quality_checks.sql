-- Diagnostic queries to run after Main.sql in MySQL 8.0+.
-- The checks do not update data; investigate any returned anomalies.

SELECT 'raw' AS dataset, COUNT(*) AS rows_count FROM layoffs
UNION ALL
SELECT 'cleaned', COUNT(*) FROM layoffs_staging_cleaned;

-- Duplicate groups remaining after cleaning
SELECT company, location, industry, total_laid_off, percentage_laid_off,
       `date`, stage, country, funds_raised_millions, COUNT(*) AS copies
FROM layoffs_staging_cleaned
GROUP BY company, location, industry, total_laid_off, percentage_laid_off,
         `date`, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;

-- Rows expected to be removed
SELECT COUNT(*) AS unusable_rows
FROM layoffs_staging_cleaned
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Columns requiring inspection (some missingness may be legitimate)
SELECT SUM(company IS NULL OR TRIM(company) = '') AS missing_company,
       SUM(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
       SUM(`date` IS NULL) AS missing_date,
       SUM(total_laid_off < 0) AS negative_layoffs,
       SUM(percentage_laid_off < 0 OR percentage_laid_off > 1) AS invalid_percentage
FROM layoffs_staging_cleaned;
