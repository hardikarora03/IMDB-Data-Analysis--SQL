USE imdb;

-- Q1. Find the total number of rows in each table of the schema?
-- Code below:

SELECT 
    table_name, table_rows
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA = 'imdb';


-- Q2. Which columns in the movie table have null values?
-- Code below:

SELECT 
	   SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_nulls, 
	   SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls, 
	   SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
	   SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_nulls,
	   SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
	   SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
	   SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_nulls,
	   SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_nulls,
	   SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_nulls
FROM movie;


-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
-- Code below:

-- Number of movies released each year.
SELECT 
    year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY year;

-- Number of movies released each month.
SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);


-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Code below:

SELECT 
    COUNT(id) AS number_of_movies, year, country
FROM
    movie
WHERE
    (country = 'USA' OR country = 'India')
        AND year = 2019
GROUP BY country;


-- Q5. Find the unique list of the genres present in the data set?
-- Code below:

SELECT DISTINCT
    genre
FROM
    genre;


-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
    genre, COUNT(movie_id) AS number_of_movies
FROM
    genre AS g
        JOIN
    movie AS m ON g.movie_id = m.id
GROUP BY genre
ORDER BY number_of_movies DESC
LIMIT 1;


-- Q7. How many movies belong to only one genre?
-- Type your code below:

SELECT 
    COUNT(movie_id) AS number_of_movies
FROM
    (SELECT 
        movie_id
    FROM
        genre
    GROUP BY movie_id
    HAVING COUNT(genre) = 1) AS subquery;


-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
-- Code below:

SELECT 
    genre, ROUND(AVG(duration), 2) AS avg_duration
FROM
    genre AS g
        JOIN
    movie AS m ON g.movie_id = m.id
GROUP BY genre
ORDER BY AVG(duration) DESC;


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)
-- Code below:

WITH genre_rank AS
(
	SELECT genre, COUNT(movie_id) AS movie_count,
			RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM genre
	GROUP BY genre
)
SELECT *
FROM genre_rank
WHERE genre='thriller';


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
-- Code below:

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM
    ratings;


-- Q11. Which are the top 10 movies based on average rating?
-- Code below:

SELECT title, avg_rating,
		DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM movie AS m
INNER JOIN ratings AS r
ON r.movie_id = m.id
LIMIT 10;


-- Q12. Summarise the ratings table based on the movie counts by median ratings.
-- Code below:

SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY median_rating;


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
-- Code below:

SELECT production_company, COUNT(id) AS movie_count,
		DENSE_RANK() OVER(ORDER BY COUNT(id) DESC) AS prod_company_rank
FROM movie AS m
JOIN ratings AS r
ON m.id = r.movie_id
WHERE avg_rating > 8 AND production_company IS NOT NULL
GROUP BY production_company
ORDER BY movie_count DESC;


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
-- Code below:

SELECT 
    g.genre, COUNT(g.movie_id) AS movie_count
FROM
    genre AS g
        INNER JOIN
    ratings AS r ON g.movie_id = r.movie_id
        INNER JOIN
    movie AS m ON m.id = g.movie_id
WHERE
    m.country = 'USA'
        AND r.total_votes > 1000
        AND MONTH(date_published) = 3
        AND year = 2017
GROUP BY g.genre
ORDER BY movie_count DESC;


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
-- Code below:

SELECT 
    title, avg_rating, genre
FROM
    genre AS g
        INNER JOIN
    ratings AS r ON g.movie_id = r.movie_id
        INNER JOIN
    movie AS m ON m.id = g.movie_id
WHERE
    title LIKE 'The%' AND avg_rating > 8
ORDER BY avg_rating DESC;


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Code below

SELECT 
    median_rating, COUNT(movie_id) AS movie_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    median_rating = 8
        AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP BY median_rating;


-- Q17. Do German movies get more votes than Italian movies? 
-- Code below:

SELECT 
    SUM(CASE
        WHEN m.languages LIKE '%German%' THEN r.total_votes
        ELSE 0
    END) AS total_votes_german,
    SUM(CASE
        WHEN m.languages LIKE '%Italian%' THEN r.total_votes
        ELSE 0
    END) AS total_votes_italian
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id;
    
-- Answer is Yes


-- Q18. Which columns in the names table have null values??
-- Code below:

SELECT 
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movies_nulls
FROM
    names;


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- Code below:

WITH top_genre AS
(
	SELECT g.genre, COUNT(g.movie_id) AS movie_count
	FROM genre AS g
	INNER JOIN ratings AS r
	ON g.movie_id = r.movie_id
	WHERE avg_rating > 8
    GROUP BY genre
    ORDER BY movie_count
    LIMIT 3
),

top_director AS
(
SELECT n.name AS director_name,
		COUNT(g.movie_id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_row_rank
FROM names AS n 
INNER JOIN director_mapping AS dm 
ON n.id = dm.name_id 
INNER JOIN genre AS g 
ON dm.movie_id = g.movie_id 
INNER JOIN ratings AS r 
ON r.movie_id = g.movie_id,
top_genre
WHERE g.genre in (top_genre.genre) AND avg_rating>8
GROUP BY director_name
ORDER BY movie_count DESC
)

SELECT *
FROM top_director
WHERE director_row_rank <= 3
LIMIT 3;


-- Q20. Who are the top two actors whose movies have a median rating >= 8?
-- Code below:

SELECT DISTINCT
    name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM
    ratings AS r
        INNER JOIN
    role_mapping AS rm ON rm.movie_id = r.movie_id
        INNER JOIN
    names AS n ON rm.name_id = n.id
WHERE
    median_rating >= 8
        AND category = 'actor'
GROUP BY name
ORDER BY movie_count DESC
LIMIT 2;


-- Q21. Which are the top three production houses based on the number of votes received by their movies?
-- Code below:

SELECT production_company, SUM(total_votes) AS vote_count,
	DENSE_RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
GROUP BY production_company
LIMIT 3;


-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
-- Code below:

SELECT 
    nm.name AS actor_name, 
    SUM(r.total_votes) AS total_votes, 
    COUNT(DISTINCT m.id) as movie_count, 
    ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actor_avg_rating, 
    RANK() OVER(ORDER BY SUM(r.avg_rating) DESC) AS actor_rank
FROM 
    movie AS m 
    INNER JOIN ratings AS r ON m.id = r.movie_id 
    INNER JOIN role_mapping AS rm ON m.id=rm.movie_id 
    INNER JOIN names AS nm ON rm.name_id=nm.id
WHERE 
    category='actor' 
    AND country= 'India'
GROUP BY 
    nm.name
HAVING 
    COUNT(DISTINCT m.id)>=5
ORDER BY 
    actor_avg_rating DESC
LIMIT 1;


-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
-- Code below:

SELECT 
    nm.name AS actress_name, 
    SUM(r.total_votes) AS total_votes, 
    COUNT(DISTINCT m.id) AS movie_count, 
    ROUND(SUM(CASE WHEN nm.name = nm.name THEN r.avg_rating*r.total_votes ELSE 0 END) /
          SUM(CASE WHEN nm.name = nm.name THEN r.total_votes ELSE 0 END), 2) AS actress_avg_rating, 
    RANK() OVER(ORDER BY SUM(r.avg_rating) DESC) AS actress_rank
FROM 
    movie AS m 
    INNER JOIN ratings AS r ON m.id = r.movie_id 
    INNER JOIN role_mapping AS rm ON m.id=rm.movie_id 
    INNER JOIN names AS nm ON rm.name_id=nm.id
WHERE 
    category='actress' 
    AND country='India' 
    AND FIND_IN_SET('hindi', m.languages) > 0
GROUP BY 
    nm.name
HAVING 
    COUNT(DISTINCT m.id)>=3
ORDER BY 
    actress_avg_rating DESC
LIMIT 1;


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Code below:

SELECT 
    title,
    CASE
        WHEN avg_rating > 8 THEN 'Superhit movies'
        WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        WHEN avg_rating < 5 THEN 'Flop movies'
    END AS avg_rating_category
FROM
    movie AS m
        INNER JOIN
    genre AS g ON m.id = g.movie_id
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    genre = 'thriller';


-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.)
-- Code below:

SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;


-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)
-- Code below:

-- Top 3 Genres based on most number of movies

WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre AS g
    INNER JOIN movie AS m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),

top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
        
	FROM movie AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)

SELECT *
FROM top_5
WHERE movie_rank<=5;


-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
-- Code below:

SELECT production_company,
		COUNT(m.id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM movie AS m 
INNER JOIN ratings AS r 
ON m.id=r.movie_id
WHERE median_rating >= 8 AND production_company IS NOT NULL AND languages LIKE '%,%'
GROUP BY production_company
LIMIT 2;


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
-- Code below:

SELECT 
    n.name, 
    SUM(r.total_votes) AS total_votes,
    COUNT(rm.movie_id) AS movie_count,
    AVG(r.avg_rating) AS avg_rating,
    DENSE_RANK() OVER(ORDER BY AVG(r.avg_rating) DESC) AS actress_rank
FROM 
    names AS n
    INNER JOIN role_mapping AS rm ON n.id = rm.name_id
    INNER JOIN ratings AS r ON r.movie_id = rm.movie_id
    INNER JOIN genre AS g ON r.movie_id = g.movie_id
WHERE 
    category = 'actress' 
    AND r.avg_rating > 8 
    AND g.genre = 'drama'
GROUP BY 
    n.name
LIMIT 3;


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations*/

-- Code below:

WITH movie_date_info AS
(
SELECT d.name_id, name, d.movie_id,
	   m.date_published, 
       LEAD(date_published, 1) OVER(PARTITION BY d.name_id ORDER BY date_published, d.movie_id) AS next_movie_date
FROM director_mapping d
	 JOIN names AS n 
     ON d.name_id=n.id 
	 JOIN movie AS m 
     ON d.movie_id=m.id
),

date_difference AS
(
	 SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	 FROM movie_date_info
 ),
 
 avg_inter_days AS
 (
	 SELECT name_id, AVG(diff) AS avg_inter_movie_days
	 FROM date_difference
	 GROUP BY name_id
 ),
 
 final_result AS
 (
	 SELECT d.name_id AS director_id,
		 name AS director_name,
		 COUNT(d.movie_id) AS number_of_movies,
		 ROUND(avg_inter_movie_days) AS inter_movie_days,
		 ROUND(AVG(avg_rating),2) AS avg_rating,
		 SUM(total_votes) AS total_votes,
		 MIN(avg_rating) AS min_rating,
		 MAX(avg_rating) AS max_rating,
		 SUM(duration) AS total_duration,
		 ROW_NUMBER() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_row_rank
	 FROM
		 names AS n 
         JOIN director_mapping AS d 
         ON n.id=d.name_id
		 JOIN ratings AS r 
         ON d.movie_id=r.movie_id
		 JOIN movie AS m 
         ON m.id=r.movie_id
		 JOIN avg_inter_days AS a 
         ON a.name_id=d.name_id
	 GROUP BY director_id
 )
 SELECT *	
 FROM final_result
 LIMIT 9;
 