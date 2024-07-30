CREATE DATABASE cars;
use cars;
DESCRIBE cars_24;
SELECT * from cars_24;
-- Highest_car_price & Lowest_car_price by location
WITH Highest_car AS (
    SELECT 
        Car_Model, 
        Brand, 
        Car_Name, 
        Car_Variant, 
        Car_Transmission, 
        Car_Price_lakh as Top_priced_Car,
        location,
        RANK() OVER (PARTITION BY location ORDER BY Car_Price_lakh DESC) as rank_1
    FROM cars_24
),
Lowest_car AS (
    SELECT 
        Car_Model, 
        Brand, 
        Car_Name, 
        Car_Variant, 
        Car_Transmission, 
        Car_Price_lakh as Low_priced_car,
        location,
        RANK() OVER (PARTITION BY location ORDER BY Car_Price_lakh ASC) as rank_2
    FROM cars_24
)
SELECT 
    h.Car_Model AS Highest_Car_Model,
    h.Brand,
    h.Car_Name AS Highest_Car_Name,
    h.Car_Variant AS Highest_Car_Variant,
    h.Car_Transmission AS Highest_Car_Transmission,
    h.Top_priced_Car,
    l.Car_Model AS Lowest_Car_Model,
    l.Car_Name AS Lowest_Car_Name,
    l.Car_Variant AS Lowest_Car_Variant,
    l.Car_Transmission AS Lowest_Car_Transmission,
    l.Low_priced_car,
    h.location
FROM 
    Highest_car h
JOIN 
    Lowest_car l 
ON 
    h.location = l.location 
    AND h.rank_1 = 1 
    AND l.rank_2 = 1
ORDER BY 
    h.Car_Model;
    
-- Which Brand has How many cars
SELECT Brand, count(*) as Number_of_Cars from cars_24
group by 1
order by 2 desc;

-- Year vs Number_of_cars
SELECT Car_Model, COUNT(*) as Number_of_cars from cars_24
GROUP BY 1
ORDER BY 2 desc;
 
-- Avg Monthly_emi by location
SELECT location, round(AVG(Monthly_EMI),2) as avg_emi from cars_24
GROUP BY 1
ORDER BY 2 desc;

-- AVG car_price by Brand
SELECT Brand, round(AVG(Car_price_lakh),2) as avg_price_lakh from cars_24
group by 1
ORDER BY 2 desc;

-- different Transmissions vs number_of_cars
SELECT Car_Transmission, count(*) from cars_24
group by 1
order by 2 desc;

-- Owner type vs numebr_of_Cars
SELECT Owner_Type, Count(*) as Number_of_cars from cars_24
GROUP BY 1
ORDER BY 2 desc;

-- find the 3rd highest_priced_car by Brand
with Highest_car as(
SELECT Brand, Car_price_lakh as Highest_priced_car,
rank() over(partition by Brand ORDER BY Car_price_lakh desc) as rank_
from cars_24)
SELECT Brand, Highest_priced_car from Highest_car
where rank_ = 3
ORDER BY 2 desc;

-- find bottom 2 least_priced_cars by location
with least_priced_car as(
SELECT location, Car_price_lakh as Least_priced_car,
rank() over(partition by location order by Car_price_lakh asc) as rank_
from cars_24
)
SELECT location, Least_priced_car from least_priced_car
where rank_<=2
order by 1;

-- Highest_km_driven by year
with Highest_km_driven as(
select Car_Model as Model_Year, KM_Driven as Highest_Km_Driven,
rank() over(partition by Car_Model order by KM_Driven desc) as rank_
from cars_24)
SELECT Model_Year, Highest_Km_Driven from Highest_km_driven 
where rank_ = 1
ORDER BY 1 asc;

-- How many cars are there in delhi(faridabad) / Hyderabad
-- location = "Delhi"
SELECT location, count(*) as Number_of_cars from cars_24
where location like "%delhi%" or location like "%faridabad%"
group by 1
order by 2 asc;
-- location = "Hyderabad"
SELECT location, count(*) as Number_of_cars from cars_24
where location like "%Hyderabad%"
GROUP BY 1
order by 2 asc;


