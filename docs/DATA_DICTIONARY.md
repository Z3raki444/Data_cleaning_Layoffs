# Layoffs dataset — data dictionary

The MySQL workflow in `Main.sql` creates `layoffs_staging_cleaned` from the raw `layoffs` table.

| Field | Meaning | Cleaning considerations |
| --- | --- | --- |
| `company` | Employer name | Whitespace trimmed |
| `location` | Reported location | Location can repeat across companies |
| `industry` | Industry classification | Crypto labels normalized; nulls may be imputed |
| `total_laid_off` | Number of affected employees | May be missing |
| `percentage_laid_off` | Fraction of employees affected | May be missing; values should normally be 0–1 |
| `date` | Reported event date | Converted from MM/DD/YYYY to MySQL DATE |
| `stage` | Organization stage | Source value |
| `country` | Country | Trailing dots and whitespace removed |
| `funds_raised_millions` | Reported capital raised in millions | May be missing |

## Limitations

- The source table is preserved, but staging tables are re-created on each run.
- Duplicate identification is based on matching columns, not on a guaranteed unique event ID.
- Matching company and location to fill `industry` may be ambiguous.
- These records are not a comprehensive census of all layoffs.

Run [SQL quality diagnostics](../sql/quality_checks.sql) after the main script.
