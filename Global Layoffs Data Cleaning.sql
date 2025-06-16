-- Data Cleaning

select * from layoffs;

-- 1. Remove Duplicate
-- 2. Standardize Data
-- 3. Null Values or Blank Values
-- 4. Remove Columns


-- Create another table(copy) to query

Create Table Layoffs_Staging
like layoffs;

select * from layoffs_staging;

Insert into Layoffs_Staging
select * from layoffs;

-- Remove Duplicates

select *, row_number() over 
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

with duplicate_cte as
(
select *, row_number() over 
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

-- Delete duplicate data by creating another table(cannot delete in a CTE)


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2
(
select *, row_number() over 
(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
);

select * from layoffs_staging2;

select * from layoffs_staging2
where row_num > 1;

Delete from layoffs_staging2
where row_num > 1;

-- Standardizing Data
-- standardizing the company column
select company,  trim(company)
from layoffs_staging2;

Update layoffs_staging2
set company = trim(company);

-- standardizing the industry column
select distinct industry
from layoffs_staging2;

select * from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'crypto' 
where industry like 'Crypto%';

-- standardizing the country column
-- select distinct country, replace(country, '.', '')
-- from layoffs_staging2
-- order by 1;

-- using this code instead
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'united states%';

select distinct country
from layoffs_staging2
order by 1;

-- standardizing the date column

select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select `date` from
layoffs_staging2;

-- changing the date column data type to date; it was originally a text data type

Alter Table layoffs_staging2
Modify Column `date` Date;

-- Populating Null Values

select distinct *
from layoffs_staging2
where industry is null
or industry = '';

-- changing the blank 'industry' to nulls
update layoffs_staging2
set industry = null
where industry = '';

select distinct * from layoffs_staging2 -- checking if there's an 'Airbnb row where industry is blank
where company = 'Airbnb'
;

select distinct t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- Deleting data that is not needed

delete 
from layoffs_staging2
where total_laid_off is null
or percentage_laid_off is null;

Alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;