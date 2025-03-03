--------------------------------------------------
-- Task 1: Update the film "Inception" to set a new 
-- rental duration and rental rate.
--------------------------------------------------
UPDATE film
SET rental_duration = 21,   
    rental_rate = 9.99,
    last_update = now()
WHERE title = 'Inception'
  AND release_year = 2010;

--------------------------------------------------
-- Task 2: Update an existing customer (with >=10 rentals and >=10 payments)
-- Change their first name, last name, address, and create_date.
--------------------------------------------------
-- We use a subquery to select one customer meeting the criteria.
UPDATE customer
SET first_name = 'Temirlan',
    last_name = 'Alzhan',
    address_id = (
        -- Select any valid address from the address table.
        SELECT address_id FROM address LIMIT 1
    ),
    -- Task 3: change create date to current date
    create_date = current_date,
    last_update = now()
WHERE customer_id = (
    SELECT customer_id FROM (
        SELECT c.customer_id
        FROM customer c
        JOIN rental r ON c.customer_id = r.customer_id
        JOIN payment p ON c.customer_id = p.customer_id
        GROUP BY c.customer_id
        HAVING COUNT(r.rental_id) >= 10
           AND COUNT(p.payment_id) >= 10
        LIMIT 1
    ) AS eligible_customer
);
