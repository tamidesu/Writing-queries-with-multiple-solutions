---------------------------------------------------------------
-- Task 1:
-- Which staff members made the highest revenue for each store 
-- and deserve a bonus for the year 2017?
---------------------------------------------------------------

-- -----------------------------------------------------------
-- Task 1, Solution 1: Using a Correlated Subquery with HAVING
-----------------------------------------------------------
SELECT i.store_id,
       r.staff_id,
       st.first_name,
       st.last_name,
       SUM(p.amount) AS staff_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN staff st ON r.staff_id = st.staff_id
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY i.store_id, r.staff_id, st.first_name, st.last_name
HAVING SUM(p.amount) = (
    SELECT MAX(sub.total_rev)
    FROM (
         SELECT r2.staff_id,
                SUM(p2.amount) AS total_rev
         FROM payment p2
         JOIN rental r2 ON p2.rental_id = r2.rental_id
         JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
         WHERE EXTRACT(YEAR FROM p2.payment_date) = 2017
           AND i2.store_id = i.store_id
         GROUP BY r2.staff_id
    ) sub
);

-----------------------------------------------------------
-- Task 1, Solution 2: Using Aggregated Subqueries and JOINs
-----------------------------------------------------------
-- First, compute revenue per staff per store.
-- Then, compute the maximum revenue per store.
-- Finally, join them to get only the staff with maximum revenue.
-----------------------------------------------------------
-- Subquery A: Revenue per staff per store in 2017
WITH StaffRevenue AS (
    SELECT i.store_id,
           r.staff_id,
           st.first_name,
           st.last_name,
           SUM(p.amount) AS staff_revenue
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN staff st ON r.staff_id = st.staff_id
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY i.store_id, r.staff_id, st.first_name, st.last_name
)
-- Subquery B: Maximum revenue per store
, StoreMaxRevenue AS (
    SELECT store_id,
           MAX(staff_revenue) AS max_revenue
    FROM StaffRevenue
    GROUP BY store_id
)
-- Main query: Only return rows where staff_revenue equals the maximum revenue for the store.
SELECT sr.store_id,
       sr.staff_id,
       sr.first_name,
       sr.last_name,
       sr.staff_revenue
FROM StaffRevenue sr
JOIN StoreMaxRevenue smr 
  ON sr.store_id = smr.store_id 
 AND sr.staff_revenue = smr.max_revenue;


---------------------------------------------------------------
-- Task 2:
-- Which five movies were rented more than the others, and what 
-- is the expected age of the audience for these movies?
-- (We assume the film's rating indicates the audience age.)
---------------------------------------------------------------

-- -----------------------------------------------------------
-- Task 2, Solution 1: Direct Aggregation with a CASE Expression
-----------------------------------------------------------
SELECT f.title,
       COUNT(r.rental_id) AS rental_count,
       CASE 
           WHEN f.rating = 'G' THEN 'All ages'
           WHEN f.rating = 'PG' THEN '10+'
           WHEN f.rating = 'PG-13' THEN '13+'
           WHEN f.rating = 'R' THEN '17+'
           ELSE 'Unknown'
       END AS expected_audience_age
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title, f.rating
ORDER BY rental_count DESC
LIMIT 5;

-----------------------------------------------------------
-- Task 2, Solution 2: Using a CTE for Rental Aggregation
-----------------------------------------------------------
WITH MovieRentals AS (
    SELECT i.film_id,
           COUNT(r.rental_id) AS rental_count
    FROM inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY i.film_id
)
SELECT f.title,
       mr.rental_count,
       CASE 
           WHEN f.rating = 'G' THEN 'All ages'
           WHEN f.rating = 'PG' THEN '10+'
           WHEN f.rating = 'PG-13' THEN '13+'
           WHEN f.rating = 'R' THEN '17+'
           ELSE 'Unknown'
       END AS expected_audience_age
FROM film f
JOIN MovieRentals mr ON f.film_id = mr.film_id
ORDER BY mr.rental_count DESC
LIMIT 5;


---------------------------------------------------------------
-- Task 3:
-- Which actors/actresses didn't act for a longer period of time than 
-- the others?
-- (Interpreted as those with the shortest career span, calculated as 
-- the difference between the earliest and latest film release years.)
---------------------------------------------------------------

-- -----------------------------------------------------------
-- Task 3, Solution 1: Using Aggregation with a Correlated Subquery
-----------------------------------------------------------
SELECT a.actor_id,
       a.first_name,
       a.last_name,
       MAX(f.release_year) - MIN(f.release_year) AS career_span
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING MAX(f.release_year) - MIN(f.release_year) = (
    SELECT MIN(span)
    FROM (
         SELECT MAX(f2.release_year) - MIN(f2.release_year) AS span
         FROM actor a2
         JOIN film_actor fa2 ON a2.actor_id = fa2.actor_id
         JOIN film f2 ON fa2.film_id = f2.film_id
         GROUP BY a2.actor_id
    ) spans
);

-----------------------------------------------------------
-- Task 3, Solution 2: Using Aggregated Subqueries and JOINs
-----------------------------------------------------------
-- First, calculate each actor's career span.
-- Then, determine the minimum career span among all actors.
-- Finally, join to select only the actor(s) whose span equals that minimum.
-----------------------------------------------------------
-- Subquery A: Career span for each actor
WITH ActorCareer AS (
    SELECT a.actor_id,
           a.first_name,
           a.last_name,
           MAX(f.release_year) - MIN(f.release_year) AS career_span
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id = f.film_id
    GROUP BY a.actor_id, a.first_name, a.last_name
)
-- Subquery B: Minimum career span value
, MinCareer AS (
    SELECT MIN(career_span) AS min_span
    FROM ActorCareer
)
-- Main query: Return only those actor(s) with the minimum career span
SELECT ac.actor_id,
       ac.first_name,
       ac.last_name,
       ac.career_span
FROM ActorCareer ac, MinCareer mc
WHERE ac.career_span = mc.min_span;
