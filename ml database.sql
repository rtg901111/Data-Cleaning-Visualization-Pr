--Sanghun Kim (#48712903)

--Question 2
--Create the four tables
CREATE TABLE links(
movieId INTEGER NOT NULL PRIMARY KEY,
imdbId INTEGER,
tmbdId INTEGER);

ALTER TABLE links RENAME COLUMN tmbdId to tmdbId;

CREATE TABLE movies(
movieId INTEGER NOT NULL PRIMARY KEY,
title VARCHAR,
genres VARCHAR);

CREATE TABLE ratings(
userId INTEGER,
movieId INTEGER,
rating float,
timestamp INTEGER);

CREATE TABLE tags(
userId INTEGER,
movieId INTEGER,
tag VARCHAR,
timestamp INTEGER);

--Load the four datasets into the tables.
COPY links 
FROM 'C:\Users\rtg90\Desktop\Course Material\Stats 170A\ml-latest\links.csv' (format csv, DELIMITER ',', HEADER);

COPY movies 
FROM 'C:\Users\rtg90\Desktop\Course Material\Stats 170A\ml-latest\movies.csv' (format csv, DELIMITER ',', HEADER);

COPY ratings 
FROM 'C:\Users\rtg90\Desktop\Course Material\Stats 170A\ml-latest\ratings.csv' (format csv, DELIMITER ',', HEADER);

COPY tags 
FROM 'C:\Users\rtg90\Desktop\Course Material\Stats 170A\ml-latest\tags.csv' (format csv, DELIMITER ',', HEADER);

--Run count queires to check if the datasets are loaded correctly.
SELECT COUNT(*) FROM links;
SELECT COUNT(*) FROM movies;
SELECT COUNT(*) FROM ratings;
SELECT COUNT(*) FROM tags;

--Question 3
--Part a
--It is the year of the movie. It is in the column "title" of the table "movies." The title column's values have a
--format of 'movie title (year)'. 
SELECT *,
SUBSTRING(title, '[(]([0-9]{1,4})[)]') AS year
FROM movies
ORDER BY title
LIMIT 10;

--Part b
--There are four tables in IMDB dataset that extraction is needed: namebasics, titlebasics, titlecrew, and titleprincipals.

--namebasics table had two columns (primaryProfession and KnownforTitles) that could be separated into multiple columns.
select *
      ,split_part(primaryprofession, ',', 1) as prof1
	  ,split_part(primaryprofession, ',', 2) as prof2
	  ,split_part(primaryprofession, ',', 3) as prof3
	  ,split_part(knownfortitles, ',', 1) as kft1
	  ,split_part(knownfortitles, ',', 2) as kft2
	  ,split_part(knownfortitles, ',', 3) as kft3
	  ,split_part(knownfortitles, ',', 4) as kft4
from namebasics
ORDER BY nconst
LIMIT 10;

--titlebasics table had genres column that could be separated into multiple columns.
SELECT *
      ,split_part(genres, ',', 1) as genre1
	  ,split_part(genres, ',', 2) as genre2
	  ,split_part(genres, ',', 3) as genre3
from titlebasics
ORDER BY tconst
LIMIT 10;

--titlecrew table had two columns (directors and writers) that could be separated. Some movies had a lot of writers
--as they had more than 10 writers. I was not sure if I should make 20 columns for writers because it would waste memory.
select *
      ,split_part(directors, ',', 1) as dir1
	  ,split_part(directors, ',', 2) as dir2
	  ,split_part(writers, ',', 1) as wr1
	  ,split_part(writers, ',', 2) as wr2
	  ,split_part(writers, ',', 3) as wr3
	  ,split_part(writers, ',', 4) as wr4
	  ,split_part(writers, ',', 5) as wr5
	  ,split_part(writers, ',', 6) as wr6
	  ,split_part(writers, ',', 7) as wr7
	  ,split_part(writers, ',', 8) as wr8
	  ,split_part(writers, ',', 9) as wr9
	  ,split_part(writers, ',', 10) as wr10
from titlecrew
ORDER BY tconst
LIMIT 10;

--titleprincipals had characters column that can be separated into a few columns.
SELECT *
      ,split_part(characters, ',', 1) as char1
	  ,split_part(characters, ',', 2) as char2
	  ,split_part(characters, ',', 3) as char3
from titleprincipals
ORDER BY tconst
LIMIT 10;

--Part c
SELECT *, to_timestamp(timestamp) AS new_timestamp--, 'yyyy-mm-dd HH24:MI:SS')
FROM ratings
LIMIT 10;

SELECT *, to_timestamp(timestamp) AS new_timestamp--, 'yyyy-mm-dd HH24:MI:SS')
FROM tags
LIMIT 10;

--Part d
--If one uses the rating for a movie from only one database, the result of analysis may be biased for some reason.
--It would be good to see the combined ratings. One thing to notice is that MovieLens ratings are from 0 to 5, but
--IMDB ratings seem to be from 1 to 10. So, I multiplied MovieLens ratings by 2 and then computed the average rating
--of the both datasets. 

SELECT  imdbId, AVG(rating) AS MovieLens_rating, AVG(averageRating) AS IMDB_rating, ((AVG(rating)*2) + AVG(averageRating))/2 AS Combined_rating
FROM ratings natural join links join 
(SELECT *,
CAST (SUBSTRING(tconst, '([1-9]+[0-9]*)') AS INTEGER) AS mid
FROM titleratings) AS IMDB
ON IMDB.mid = imdbId
GROUP BY imdbId
LIMIT 20;

--Part e
--Movies table would likely be the most problematic dataset to analyze with SQL in its current form because 
--its columns like title and genres have multiple values. Title column has year in it and genres column have multiple
--values in one column. I am going to separate them into new fields. 

SELECT *
	,SUBSTRING(title, '[(]([0-9]{1,4})[)]') AS year
	,split_part(genres, '|', 1) as genre1
	,split_part(genres, '|', 2) as genre2
	,split_part(genres, '|', 3) as genre3
	,split_part(genres, '|', 4) as genre4
	,split_part(genres, '|', 5) as genre5
FROM movies
LIMIT 20;

--Part f
--sub-part i)
SELECT tmdbId, COUNT(tmdbId) as cnt
FROM links
GROUP BY tmdbId
ORDER BY cnt Desc;
--The tmdbid of 141971 repeats the most (with frequency of 3).

--sub-part ii)
SELECT title
FROM links natural join movies
WHERE tmdbid = 141971;
--The movie names associated with the tmdbid of 141971 are: Blackout (2008), Blackout (2007), and Blackout (2007).

--sub-part iii)
--The TMDB ID's are not unique here because the title column of movies table includes the year of the movie. 
--So, the movies with the same title but different years have the same TMDB ID. 

--sub-part iv)
SELECT *
FROM titlebasics,
CAST (SUBSTRING(tconst, '([1-9]+[0-9]*)') AS INTEGER) AS newid
WHERE newid IN 
(SELECT imdbId
FROM links 
WHERE tmdbid = 141971);

--Part g

SELECT tconst, primarytitle as title, averagerating as IMDB_avg, numvotes as IMDB_num_contributors, ML_avg, Ml_num_contributors,
( (averagerating + (ml_avg * 2) ) / 2) as avg_of_both
FROM titleratings natural join titlebasics,
CAST (SUBSTRING(tconst, '([1-9]+[0-9]*)') AS INTEGER) AS newid
join 
(SELECT imdbId, AVG(rating) as ML_avg, COUNT(userId) as ML_num_contributors
FROM ratings natural join links
GROUP BY imdbId) as a
ON newid = imdbId
LIMIT 100;

--To compute the combined review values, I multiplied the review values from MoviesLens by 2. This is because 
--the review values from MovieLens range from 0 to 5, but the review values from IMDB range rom 0 to 10. 
--So, I tried to put some weight. Thus, I calculated the combined review value by computing the average of the IMDB
--review values and the weighted MovieLens review values. 

--Part h

--new table for part a
CREATE TABLE hw2_a(
movieid VARCHAR NOT NULL PRIMARY KEY,
title VARCHAR,
genres VARCHAR,
year VARCHAR);

INSERT INTO hw2_a
SELECT *,
SUBSTRING(title, '[(]([0-9]{1,4})[)]') AS year
FROM movies
ORDER BY title
LIMIT 10;

--new table for part b
CREATE TABLE hw2_b(
nconst VARCHAR NOT NULL PRIMARY KEY,
primaryname VARCHAR,
birthyear INTEGER,
deathyear INTEGER,
primaryprofession VARCHAR,
knownfortitles VARCHAR,
prof1 varchar,
prof2 varchar,
prof3 varchar,
kft1 varchar,
kft2 varchar,
kft3 varchar,
kft4 varchar);

INSERT INTO hw2_b
select *
      ,split_part(primaryprofession, ',', 1) as prof1
	  ,split_part(primaryprofession, ',', 2) as prof2
	  ,split_part(primaryprofession, ',', 3) as prof3
	  ,split_part(knownfortitles, ',', 1) as kft1
	  ,split_part(knownfortitles, ',', 2) as kft2
	  ,split_part(knownfortitles, ',', 3) as kft3
	  ,split_part(knownfortitles, ',', 4) as kft4
from namebasics
ORDER BY nconst
LIMIT 10;

--new table for part c
CREATE TABLE hw2_c(
userid INTEGER,
movieid INTEGER,
rating double precision,
timestamp INTEGER,
new_timestamp timestamp);

INSERT INTO hw2_c
SELECT *, to_timestamp(timestamp) AS new_timestamp--, 'yyyy-mm-dd HH24:MI:SS')
FROM ratings
LIMIT 10;

--new table for part d
CREATE TABLE hw2_d(
imdbid INTEGER,
movielens_rating double precision,
imdb_rating double precision);

INSERT INTO hw2_d
SELECT  imdbId, AVG(rating) AS MovieLens_rating, AVG(averageRating) AS IMDB_rating
FROM ratings natural join links join 
(SELECT *,
CAST (SUBSTRING(tconst, '([1-9]+[0-9]*)') AS INTEGER) AS mid
FROM titleratings) AS IMDB
ON IMDB.mid = imdbId
GROUP BY imdbId
LIMIT 20;

--new table for part e
CREATE TABLE hw2_e(
movieid INTEGER NOT NULL PRIMARY KEY,
title VARCHAR,
genres VARCHAR,
year VARCHAR,
genre1 VARCHAR,
genre2 VARCHAR,
genre3 varchar,
genre4 varchar,
genre5 varchar);

INSERT INTO hw2_e
SELECT *
	,SUBSTRING(title, '[(]([0-9]{1,4})[)]') AS year
	,split_part(genres, '|', 1) as genre1
	,split_part(genres, '|', 2) as genre2
	,split_part(genres, '|', 3) as genre3
	,split_part(genres, '|', 4) as genre4
	,split_part(genres, '|', 5) as genre5
FROM movies
LIMIT 20;

--new table for part f
CREATE TABLE hw2_f(
tconst VARCHAR NOT NULL PRIMARY KEY,
titletype VARCHAR,
primarytitle VARCHAR,
originaltitle VARCHAR,
isadult INTEGER,
startyear INTEGER,
endyear INTEGER,
runtimeminutes INTEGER,
genres varchar,
newid INTEGER);

INSERT INTO hw2_f
SELECT *
FROM titlebasics,
CAST (SUBSTRING(tconst, '([1-9]+[0-9]*)') AS INTEGER) AS newid
WHERE newid IN 
(SELECT imdbId
FROM links 
WHERE tmdbid = 141971);

--new table for part g
CREATE TABLE hw2_g(
tconst VARCHAR NOT NULL PRIMARY KEY,
title VARCHAR,
imdb_avg float,
imdb_num_contributors INTEGER,
ml_avg float,
ml_num_contributors INTEGER,
avg_of_both float);

INSERT INTO hw2_g
SELECT tconst, primarytitle as title, averagerating as IMDB_avg, numvotes as IMDB_num_contributors, ML_avg, Ml_num_contributors,
( (averagerating + (ml_avg * 2) ) / 2) as avg_of_both
FROM titleratings natural join titlebasics,
CAST (SUBSTRING(tconst, '([1-9]+[0-9]*)') AS INTEGER) AS newid
join 
(SELECT imdbId, AVG(rating) as ML_avg, COUNT(userId) as ML_num_contributors
FROM ratings natural join links
GROUP BY imdbId) as a
ON newid = imdbId
LIMIT 100;

















