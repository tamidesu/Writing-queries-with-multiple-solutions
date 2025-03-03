-- Insert a favorite film "Inception" into the film table.
INSERT INTO film (
    title, 
    description, 
    release_year, 
    language_id, 
    rental_duration, 
    rental_rate, 
    replacement_cost, 
    rating, 
    special_features, 
    last_update
)
VALUES (
    'Inception', 
    'A mind-bending thriller about dream invasion and inception.', 
    2010, 
    1,                  
    14,                
    4.99, 
    19.99, 
    'PG-13', 
    '{"Behind the Scenes","Trailers"}',  
    now()
);

-- Insert leading actors into the actor table.
INSERT INTO actor (first_name, last_name, last_update)
VALUES ('Leonardo', 'DiCaprio', now());

INSERT INTO actor (first_name, last_name, last_update)
VALUES ('Joseph', 'Gordon-Levitt', now());

INSERT INTO actor (first_name, last_name, last_update)
VALUES ('Elliot', 'Page', now());

-- Link the film "Inception" with its actors in the film_actor table.
INSERT INTO film_actor (film_id, actor_id, last_update)
VALUES (
    (SELECT film_id FROM film WHERE title = 'Inception' AND release_year = 2010),
    (SELECT actor_id FROM actor WHERE first_name = 'Leonardo' AND last_name = 'DiCaprio'),
    now()
);

INSERT INTO film_actor (film_id, actor_id, last_update)
VALUES (
    (SELECT film_id FROM film WHERE title = 'Inception' AND release_year = 2010),
    (SELECT actor_id FROM actor WHERE first_name = 'Joseph' AND last_name = 'Gordon-Levitt'),
    now()
);

INSERT INTO film_actor (film_id, actor_id, last_update)
VALUES (
    (SELECT film_id FROM film WHERE title = 'Inception' AND release_year = 2010),
    (SELECT actor_id FROM actor WHERE first_name = 'Elliot' AND last_name = 'Page'),
    now()
);

-- Add the film to a store's inventory.
INSERT INTO inventory (film_id, store_id, last_update)
VALUES (
    (SELECT film_id FROM film WHERE title = 'Inception' AND release_year = 2010),
    1, 
    now()
);
