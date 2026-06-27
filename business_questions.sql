CREATE DATABASE bengaluru_rentals;
USE bengaluru_rentals;

CREATE TABLE rentals (
    seller_type VARCHAR(20),
    bedroom INT,
    layout_type VARCHAR(10),
    property_type VARCHAR(50),
    locality VARCHAR(100),
    price DECIMAL(10,2),
    area DECIMAL(10,2),
    furnish_type VARCHAR(30),
    bathroom INT,
    rent_per_sq_ft DECIMAL(10,2)
);

describe rentals;

#Null Check

SELECT
SUM(CASE WHEN seller_type IS NULL THEN 1 ELSE 0 END) seller_nulls,
SUM(CASE WHEN locality IS NULL THEN 1 ELSE 0 END) locality_nulls,
SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) price_nulls
FROM rentals;

# Check Distinct Localities

SELECT COUNT(DISTINCT locality)
FROM rentals;

# Exploratory Data Analysis
## 1. Average Rent
SELECT ROUND(AVG(price),2) avg_rent
FROM rentals;

## 2. Average Area
SELECT ROUND(AVG(area),2) avg_area
FROM rentals;

## 3. Property Type Distribution
SELECT
    property_type,
    COUNT(*) AS listings,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM rentals
GROUP BY property_type
ORDER BY listings DESC;

## 4. Furnishing Distribution

Select furnish_type, count(furnish_type) as Listings_Furnished 
from rentals
group by furnish_type
Order by Listings_Furnished desc;

## 5. Owner vs Agent Listings

SELECT
seller_type,
COUNT(*) listings
FROM rentals
GROUP BY seller_type;

## 6. Which localities are most expensive(Top 5)?

Select locality, Round(Avg(price),2) as Avg_rent
from rentals
group by locality 
order by Avg_rent desc limit 5;

## 7. Which localities are cheapest(Low 5)?

SELECT locality, ROUND(AVG(price),2) avg_rent
FROM rentals
GROUP BY locality
ORDER BY avg_rent
LIMIT 5;

## 8. Does furnishing increase rent?

SELECT
furnish_type,
ROUND(AVG(price),2) avg_rent
FROM rentals
GROUP BY furnish_type
ORDER BY avg_rent DESC;

## 9. Does bedroom count increase rent?

SELECT
bedroom,
ROUND(AVG(price),2) avg_rent
FROM rentals
GROUP BY bedroom
ORDER BY bedroom desc;

## 10. Which localities charge highest rent per sq ft?

SELECT
locality,
ROUND(AVG(rent_per_sq_ft),2) avg_rent_sqft
FROM rentals
GROUP BY locality
ORDER BY avg_rent_sqft DESC
LIMIT 10;

## Ranking localities

SELECT
locality,
AVG(price) avg_rent,
DENSE_RANK() OVER(
ORDER BY AVG(price) DESC
) rent_rank
FROM rentals
GROUP BY locality;

##  Premium vs Budget Localities

With CIty_Avg as (Select Avg(price) avg_rent from rentals)

Select locality, 
Avg(price) as locality_rent
from rentals
group by locality 
having Avg(price) > (select avg_rent from city_avg);

## Which locality gives the best value for money?

SELECT
locality,
ROUND(AVG(price),0) avg_rent,
ROUND(AVG(area),0) avg_area,
ROUND(AVG(rent_per_sq_ft),2) avg_rent_sqft
FROM rentals
GROUP BY locality
HAVING COUNT(*) >= 5
ORDER BY avg_rent_sqft;


## Which property type generates highest rent?

Select property_type, Round(Avg(price),2) as Avg_rent from rentals group by property_type order by Avg_rent desc;

## Does larger area always mean higher rent? For scatter plot

SELECT
area,
price
FROM rentals;

# Budget-Friendly Localities

SELECT
locality,
ROUND(AVG(price),0) avg_rent
FROM rentals
GROUP BY locality
HAVING AVG(price) <
(
SELECT AVG(price)
FROM rentals
)
ORDER BY avg_rent;

Select * from rentals;

Select bedroom, round(Avg(rent_per_sq_ft),2) as RPSF from rentals group by bedroom order by bedroom, RPSF;

## Which BHK category gives best rent per sq ft?

SELECT
bedroom,
ROUND(AVG(rent_per_sq_ft),2) avg_rent_sqft
FROM rentals
GROUP BY bedroom
ORDER BY avg_rent_sqft DESC;

## Most expensive locality for each property type

With Locality_rank as ( Select 
							locality, property_type,
                            Round(Avg(price),2) as Avg_rent, 
                            row_number() Over(Partition by property_type order by Avg(price) desc) as rn
                            from rentals group by locality, property_type)
                            
Select * from Locality_rank where rn = 1;


