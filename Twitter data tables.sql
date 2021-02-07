CREATE SCHEMA hw4;

CREATE TABLE hw4.PandemicTweetInfo(
created_at VARCHAR,
tweetid INTEGER,
userId INTEGER,
text VARCHAR,
in_reply_to_status_id INTEGER,
raw_tweet_field VARCHAR);

CREATE TABLE hw4.OttomanTweetInfo(
created_at VARCHAR,
tweetid INTEGER,
userid INTEGER,
text VARCHAR,
in_reply_to_status_id INTEGER,
raw_tweet_field VARCHAR);

CREATE TABLE hw4.StaticUserInfo(
userid INTEGER,
username VARCHAR,
screen_name VARCHAR,
userdescription VARCHAR);

CREATE TABLE hw4.DynamicUserInfo(
userid INTEGER,
statuses_count INTEGER,
followers_count INTEGER);

CREATE TABLE hw4.TweetEntity(
tweetid INTEGER,
hashtag VARCHAR);

SELECT *
FROM hw4.pandemictweetinfo;

--Part a
SELECT t.wrd, COUNT(t.wrd) as occ_rate
FROM(
SELECT UNNEST(string_to_array(text, ' ')) as wrd
FROM hw4.ottomantweetinfo) as t
GROUP BY t.wrd
ORDER BY occ_rate DESC
LIMIT 100;

SELECT t.wrd, COUNT(t.wrd) as occ_rate
FROM(
SELECT UNNEST(string_to_array(text, ' ')) as wrd
FROM hw4.pandemictweetinfo) as t
GROUP BY t.wrd
ORDER BY occ_rate DESC
LIMIT 100;

--For the words from ottoman tweet info, most words are neutral. However, it seems that there are a lot of meaningless
--words. There are a lot of non-english words that I cannot understand and many useless words like 'of', 'was', and 'RT'.
--For the words from pandemic tweet info, most words are neutral again. Fortunately, pandemic tweets do not have a lot
--of non-english words, but they still have a lot of meaningless words. It is slightly more negative than ottoman tweets
--because it contains words like outbreak, virus, and cruel.

--Part b
SELECT COUNT(DISTINCT hashtag)
FROM hw4.tweetentity;
--Overall, my Tweet collections have 358 distinct hashtags.

--Part c
SELECT (COUNT(hashtag)::decimal/COUNT(DISTINCT tweetid))
FROM hw4.tweetentity natural join hw4.ottomantweetinfo;
--The average number of hashtags per Tweeting user in ottoman tweet info is 1.66
SELECT (COUNT(hashtag)::decimal/COUNT(DISTINCT tweetid))
FROM hw4.tweetentity natural join hw4.pandemictweetinfo;
--The average number of hashtags per Tweeting user in pandemic tweet info is 1.73

--Part d
SELECT DISTINCT(hashtag)
FROM hw4.tweetentity natural join hw4.ottomantweetinfo
WHERE hashtag in (
SELECT hashtag FROM hw4.tweetentity natural join hw4.pandemictweetinfo);
--The hashtags that are common to Tweets about both shows are Netflix, IMDb, trakt, bancodeseries, and NowWatching.

--Part e
SELECT COUNT(wrd)
FROM(
SELECT UNNEST(string_to_array(text, ' ')) as wrd
FROM hw4.ottomantweetinfo) as t
	 WHERE t.wrd IN (SELECT top
FROM(
SELECT DISTINCT(hashtag) as top
FROM hw4.tweetentity natural join hw4.ottomantweetinfo
WHERE hashtag in (
SELECT hashtag FROM hw4.tweetentity natural join hw4.pandemictweetinfo)) AS z
GROUP BY top);
--For ottoman tweets, the occurrence frequency is 513.

SELECT COUNT(wrd)
FROM(
SELECT UNNEST(string_to_array(text, ' ')) as wrd
FROM hw4.pandemictweetinfo) as t
	 WHERE t.wrd IN (SELECT top
FROM(
SELECT DISTINCT(hashtag) as top
FROM hw4.tweetentity natural join hw4.pandemictweetinfo
WHERE hashtag in (
SELECT hashtag FROM hw4.tweetentity natural join hw4.pandemictweetinfo)) AS z
GROUP BY top);
--For pandemic tweets, the occurrence frequency is 9805.

--Part f
SELECT DISTINCT(userid)
FROM hw4.ottomantweetinfo
WHERE userid IN
(SELECT DISTINCT(userid) FROM hw4.pandemictweetinfo);
--There are four users in common:285280375,2479845637,2733194172, and 16083143.

--Part g
SELECT DISTINCT(userid), cnt, username, screen_name, userdescription, statuses_count, followers_count
FROM(
SELECT userid, COUNT(tweetid) as cnt
FROM
(SELECT * FROM hw4.ottomantweetinfo 
UNION 
SELECT * FROM hw4.pandemictweetinfo) AS x 
GROUP BY userid
ORDER BY cnt DESC
LIMIT 10) as z natural join hw4.staticuserinfo natural join hw4.dynamicuserinfo AS y
ORDER BY cnt DESC;
--The top 10 users are:979879258695745536, 815927344913387520,2926612832, 748379420, 810372591806517249, 2456483730,
--812209998168293376, 16030327, 144737971, 236230642

--Part h
CREATE INDEX otto_text ON hw4.ottomantweetinfo USING gin(to_tsvector('english', "text"));
CREATE INDEX pan_text ON hw4.pandemictweetinfo USING gin(to_tsvector('english', "text"));

--Part i
SELECT text
FROM(
SELECT DISTINCT(wrd), text FROM
(SELECT UNNEST(string_to_array(hashtag, ' ')) as wrd, text
FROM hw4.pandemictweetinfo natural join hw4.tweetentity) as t
WHERE wrd NOT IN
(SELECT UNNEST(string_to_array(text, ' '))
FROM hw4.ottomantweetinfo)) as z
WHERE wrd IN (SELECT UNNEST(string_to_array(text, ' '))
FROM hw4.pandemictweetinfo)

--First, I found the words from hashtags that only appear in pandemic tweet text and removed hashtags that also appeared
--in ottoman tweet text. Using these unique keywords, I retrieved the tweets that contain these keywords. There are 
--hundreds of tweets that contain those keywords. Looking at the tweets, I found out that these tweets are about Coronavirus.
--The keywords set contained words like virus, outbreak, and fear, so I was able to retrieve tweets related to the
--current Coronavirus outbreak. Although there are some tweets that are not related to Coronavirus, a significant 
--number of tweets retrieved are about the outbreak. 





















































































