-- ============================================================
-- PROJECT  : Rome Airbnb Market Analysis
-- DATASET  : Inside Airbnb – Rome, Lazio, Italy (Sep 2025)
-- TOOL     : MySQL
-- AUTHOR   : Mahak Agarwal
-- ============================================================

-- Data Display
SELECT * FROM airbnb_db.airbnb_data;

-- ============================================================
-- MODULE 1 : EXPLORATION
-- ============================================================

-- 1. Total number of listings in the dataset
SELECT COUNT(*) AS total_listings FROM airbnb_db.airbnb_data;

-- 2. Number of distinct neighbourhoods
SELECT COUNT(DISTINCT(neighbourhood)) AS total_neighbourhoods FROM airbnb_db.airbnb_data;

-- 3. Listings with zero reviews
SELECT COUNT(*) AS listings_with_zero_reviews FROM airbnb_db.airbnb_data WHERE number_of_reviews=0;

-- 4. Listings with NULL reviews_per_month
SELECT COUNT(*) AS listings_null_reviews_per_month FROM airbnb_db.airbnb_data WHERE reviews_per_month IS NULL;


-- ============================================================
-- MODULE 2 : PRICING OVERVIEW
-- ============================================================

-- 5. Average, minimum, and maximum price
SELECT AVG(price) AS avg_price, MIN(price) AS min_price, MAX(price) AS max_price FROM airbnb_db.airbnb_data;

-- 6. Average price by room (highest to lowest)
SELECT room_type, AVG(price) AS avg_price FROM airbnb_db.airbnb_data GROUP BY room_type ORDER BY AVG(price) DESC;

-- 7. 5 most expensive neighbourhoods by avg price
SELECT neighbourhood, AVG(price) AS avg_price FROM airbnb_db.airbnb_data GROUP BY neighbourhood ORDER BY AVG(price) DESC LIMIT 5;

-- 8. 5 most affordable neighbourhoods by avg price
SELECT neighbourhood, AVG(price) AS avg_price FROM airbnb_db.airbnb_data GROUP BY neighbourhood ORDER BY AVG(price) LIMIT 5;


-- ============================================================
-- MODULE 3 : ROOM TYPE ANALYSIS
-- ============================================================

-- 9. COUNT AND PERCENTAGE OF LISTINGS PER ROOM TYPE
SELECT room_type, COUNT(*) AS total_listings, (COUNT(*)*100/(SELECT COUNT(*) FROM airbnb_db.airbnb_data)) AS percentage FROM airbnb_db.airbnb_data  GROUP BY room_type;

-- 10. ROOM TYPE WITH HIGHEST AVERAGE AVAILABILITY
SELECT room_type, (AVG(availability_365)) AS Avg_availability FROM airbnb_db.airbnb_data GROUP BY room_type order by Avg_availability DESC limit 1;


-- ============================================================
-- MODULE 4 : HOST BEHAVIOUR
-- ============================================================

-- 11. HOSTS WITH MORE THAN 10 LISTINGS
SELECT DISTINCT host_id, calculated_host_listings_count FROM airbnb_db.airbnb_data WHERE calculated_host_listings_count > 10;

-- 12. AVG PRICE: SINGLE LISTING HOSTS VS MULTI LISTING HOSTS
SELECT 
CASE 
WHEN calculated_host_listings_count=1 THEN 'Single listing hosts'
ELSE 'Multi listing hosts'
END AS host_type, AVG(price) AS avg_price
FROM airbnb_db.airbnb_data GROUP BY host_type;


-- ============================================================
-- MODULE 5 : AVAILABILITY AND DEMAND
-- ============================================================

-- 13. AVG AVAILABILITY_365 BY ROOM_TYPE
SELECT room_type, avg(availability_365) AS Avg_availability_365 FROM airbnb_db.airbnb_data GROUP BY room_type;

-- 14. CASE: LISTINGS GROUPED INTO AVAILABILITY BANDS
SELECT 
CASE 
	WHEN availability_365>=0 AND availability_365<=90 THEN 'Low availability'
	WHEN availability_365>90 AND availability_365<=180 THEN 'Medium availability'
    WHEN availability_365>180 AND availability_365<=270 THEN 'High availability'
    ELSE 'Always available'
END AS Availability_bands, COUNT(*) AS Listings_Count
FROM airbnb_db.airbnb_data
GROUP BY Availability_bands 
ORDER BY Availability_bands;


-- ============================================================
-- MODULE 6 : REVIEWS ANALYSIS
-- ============================================================

-- 15. TOP 10 NEIGHBOURHOODS BY AVG REVIEWS_PER_MONTH
SELECT neighbourhood, ROUND(AVG(reviews_per_month),2) AS Avg_monthly_reviews 
FROM  airbnb_db.airbnb_data 
GROUP BY neighbourhood 
ORDER BY ROUND(AVG(reviews_per_month),2) DESC LIMIT 10;

-- 16. CASE: LISTINGS FLAGGED AS POPULAR/AVERAGE/LOW
SELECT 
CASE 
	WHEN reviews_per_month > 2 THEN 'POPULAR'
	WHEN reviews_per_month BETWEEN 1 AND 2 THEN 'AVERAGE'
    ELSE 'LOW'
END AS Popularity, 
COUNT(*) AS Listings_Count
FROM airbnb_db.airbnb_data
GROUP BY Popularity 
ORDER BY Popularity;


-- ============================================================
-- MODULE 7 : PRICING OUTLIERS
-- ============================================================

-- 17. LISTINGS PRICED ABOVE 500 AND THEIR ROOM TYPES
SELECT room_type, COUNT(*) AS Listings_above_500 
FROM airbnb_db.airbnb_data 
WHERE price>500
GROUP BY room_type 
ORDER BY Listings_above_500 DESC;

-- 18. AVG PRICE WITH VS WITHOUT LISTINGS ABOVE 500
SELECT
CASE
WHEN price>=500 THEN 'Price above 500'
ELSE 'Price below 500'
END AS price_type, AVG(price) AS avg_price
FROM airbnb_db.airbnb_data GROUP BY price_type;


-- ============================================================
-- MODULE 8 : STORED PROCEDURE
-- ============================================================

-- 19. PROCEDURE: INPUT NEIGHBOURHOOD --> RETURN KPI SUMMARY
DELIMITER // 
CREATE PROCEDURE neighbourhood_name(IN n VARCHAR(200))
BEGIN
SELECT 
COUNT(*) AS Listings,
ROUND(AVG(price),2) as Avg_price,
ROUND(AVG(availability_365),2) as Avg_availability,
ROUND(AVG(reviews_per_month),2) as Avg_monthly_reviews
FROM airbnb_db.airbnb_data 
WHERE neighbourhood = n;
END //
DELIMITER ;

CALL neighbourhood_name ('I Centro Storico');


