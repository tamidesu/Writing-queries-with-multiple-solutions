----------------------------------------------------------------
-- TASK 1: Remove a previously inserted film from the inventory
-- and all corresponding rental (and payment) records.
--
-- In this example, the film "Inception" (release_year 2010) was inserted earlier.
----------------------------------------------------------------

-- Step 1: Delete payment records associated with rentals of "Inception"
DELETE FROM payment
WHERE rental_id IN (
    SELECT rental_id
    FROM rental
    WHERE inventory_id IN (
        SELECT inventory_id
        FROM inventory
        WHERE film_id = (
            SELECT film_id
            FROM film
            WHERE title = 'Inception'
              AND release_year = 2010
        )
    )
);

-- Step 2: Delete rental records associated with "Inception"
DELETE FROM rental
WHERE inventory_id IN (
    SELECT inventory_id
    FROM inventory
    WHERE film_id = (
        SELECT film_id
        FROM film
        WHERE title = 'Inception'
          AND release_year = 2010
    )
);

-- Step 3: Delete the film from the inventory.
-- This removes the copies of the film from the store's inventory.
DELETE FROM inventory
WHERE film_id = (
    SELECT film_id
    FROM film
    WHERE title = 'Inception'
      AND release_year = 2010
);

----------------------------------------------------------------
-- TASK 2: Remove any records related to you (as a customer)
-- from all tables except "customer" and "inventory".
----------------------------------------------------------------
-- Step 1: Delete payment records for your customer.
DELETE FROM payment
WHERE customer_id = (
    SELECT customer_id
    FROM customer
    WHERE first_name = 'Temirlan'
      AND last_name = 'Alzhan'
    LIMIT 1
);

-- Step 2: Delete rental records for your customer.
DELETE FROM rental
WHERE customer_id = (
    SELECT customer_id
    FROM customer
    WHERE first_name = 'Temirlan'
      AND last_name = 'Alzhan'
    LIMIT 1
);
