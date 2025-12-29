/* ============================================================
   DATA CLEANING PIPELINE (MySQL 8.0+)
   Dataset: layoffs
   Output : layoffs_staging_cleaned
   Steps  : 
     1) Create staging copy
     2) Remove duplicates (real removal)
     3) Standardize text fields
     4) Fix dates + datatype
     5) Handle null/blank values
     6) Remove unusable rows
     7) Create final cleaned table
   ============================================================ */

-- ------------------------------------------------------------
-- 0) Inspect original data (optional)
-- ------------------------------------------------------------
SELECT * FROM layoffs;


-- ------------------------------------------------------------
-- 1) Create staging table (safe copy)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;


-- ------------------------------------------------------------
-- 2) Remove duplicates (ACTUALLY remove from staging)
--    We mark duplicates with ROW_NUMBER() and delete row_num > 1
-- ------------------------------------------------------------

-- Ensure no leftover helper table
DROP TABLE IF EXISTS layoffs_staging_dedup;

-- Create a dedup helper table including row_num
CREATE TABLE layoffs_staging_dedup AS
SELECT
  *,
  ROW_NUMBER() OVER (
    PARTITION BY 
      company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ORDER BY company
  ) AS row_num
FROM layoffs_staging;

-- Delete duplicates (keep only row_num = 1)
DELETE FROM layoffs_staging_dedup
WHERE row_num > 1;

-- Drop row_num column after dedup
ALTER TABLE layoffs_staging_dedup
DROP COLUMN row_num;

-- Replace staging with deduplicated table (optional but clean)
DROP TABLE IF EXISTS layoffs_staging;
RENAME TABLE layoffs_staging_dedup TO layoffs_staging;


-- ------------------------------------------------------------
-- 3) Standardize / Clean text fields
-- ------------------------------------------------------------

-- 3.1 Trim company names
UPDATE layoffs_staging
SET company = TRIM(company)
WHERE company IS NOT NULL;

-- 3.2 Normalize Industry values (example: all Crypto variants → 'Crypto')
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 3.3 Standardize country (example: fix "United States." / "United States " etc.)
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM TRIM(country))
WHERE country IS NOT NULL;

-- Optional: force exact value for United States variants
UPDATE layoffs_staging
SET country = 'United States'
WHERE country LIKE 'United States%';


-- ------------------------------------------------------------
-- 4) Convert date from text to DATE type
--    Only convert if date is currently stored as text like 'mm/dd/YYYY'
-- ------------------------------------------------------------

-- Convert values to DATE (temporarily)
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL
  AND `date` <> '';

-- Convert column type to DATE
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;


-- ------------------------------------------------------------
-- 5) Handle NULL and blank values
-- ------------------------------------------------------------

-- 5.1 Convert blank industry to NULL
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

-- 5.2 Fill missing industry by matching same company + location
UPDATE layoffs_staging t1
JOIN layoffs_staging t2
  ON t1.company = t2.company
 AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- ------------------------------------------------------------
-- 6) Remove unusable rows
--    If total_laid_off AND percentage_laid_off are both NULL -> remove
-- ------------------------------------------------------------

-- Check how many rows will be deleted (safe preview)
SELECT COUNT(*) AS rows_to_delete
FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Delete them
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ------------------------------------------------------------
-- 7) Create final cleaned table (snapshot)
-- ------------------------------------------------------------

DROP TABLE IF EXISTS layoffs_staging_cleaned;

CREATE TABLE layoffs_staging_cleaned AS
SELECT *
FROM layoffs_staging;

-- Verify
SELECT COUNT(*) AS cleaned_rows FROM layoffs_staging_cleaned;
SELECT * FROM layoffs_staging_cleaned LIMIT 50;

-- ------------------------------------------------------------

