/* created temp table  */
CREATE TABLE #brands(
		NAME nvarchar(200) NOT NULL);

/* Populing table with existing brands */

INSERT INTO #brands SELECT brand FROM clean_meta WHERE brand not like 'Undefined' GROUP BY brand;

/* Altering undefined values in brand collumn with brand names found on title*/

UPDATE c  SET brand = COALESCE( (SELECT TOP 1 Name FROM #brands b WHERE PATINDEX( '%'+ b.NAME +'%', title ) > 0 ),'Undefined') FROM clean_meta  c WHERE brand  like 'Undefined';
 
 /* Drop temp table*/

DROP TABLE #brands;


  /** Looks like the bought together is incremental meaning that is difficult to related what was bought together with the review 
    ** because the review could have not bought it together but rather in another day week or month ...
*/ 

	SELECT TOP 10 cr.asin , cr.reviewerid, cr.reviewerName, cr.helpfulness, cr."date" ,cm.asin , cm.reviewerid , cm. reviewername,cm.helpfulness,  cm."date"  FROM clean_reviews cr 
    inner join related r ON (cr.asin = r.asin and r."type" like 'bought_together') 
    inner join clean_reviews cm ON(r.relatedid = cm.asin and cm.reviewerid = cm.reviewerid) ORDER BY  newid()
;
	
   
  /* this one counts the number of product that has a relation with bought together and also was reviewed by the same reviewer could be some review that happened in any time*/ 
   	SELECT count(*) FROM clean_reviews crc 
    inner join related r ON (crc.asin = r.asin and r."type" like 'bought_together') 
    inner join clean_reviews crc2 ON(r.relatedid = crc2.asin and crc.reviewerid = crc2.reviewerid);
 
 
 /* this one counts the number of product that has a relation with bought together and also was reviewed by the same reviewer but just the ones reviewed in the same day*/ 
   SELECT cr.asin, count(cr.asin), AVG(cr.numOfWords), avg(cr.helpRate) FROM clean_reviews cr 
    inner join related r ON (cr.asin = r.asin and r."type" like 'bought_together') 
    inner join clean_reviews cr2 ON(r.relatedid = cr2.asin and cr.reviewerid = cr2.reviewerid and cr.date = cr2.date)
	GROUP BY cr.asin, r.asin
    /*I cannot see a way to have 100 percent of centainty that those reviews are related*/  
   
   /**
    * analyzing these two one is related to the other and bought together so you assume that the other one will also have a record saying that this one was also bought together
    but do not have
   B000ARB1UQ B0051U15E4
   */
   
      
 SELECT * FROM related r WHERE r."type" like 'bought_together' ;
 SELECT * FROM related r WHERE r.asin like 'B000ARB1UQ' and r."type" like 'bought_together' ;
 SELECT * FROM related r WHERE r.asin like 'B0051U15E4' and r."type" like 'bought_together' ;
 
 SELECT * FROM related r WHERE r.asin like 'B00FPH4L3U' and r."type" like 'bought_together' ;
 SELECT * FROM related r WHERE r.asin like 'B00GQQ81S0' and r."type" like 'bought_together' ;

 SELECT * FROM reviewr  WHERE r.relatedId like 'B005C4Y7Z8' and r."type" like 'bought_together' ;





SELECT avg(helpRate) AS AVG_HelpRate, avg(numOfWords) AS AVG_numOfWords, rank
FROM clean_reviews cr
inner join clean_meta cm
ON  cr.asin = cm.asin
GROUP BY rank;




SELECT cm.title, count(reviews) AS countOfReviews, AVG(helpRate) 
FROM clean_reviews cr
inner join clean_meta cm
ON cm.asin = cr.asin
GROUP BY title
ORDER BY  countOfReviews DESC;

SELECT cm.title, sum(reviews), AVG(helpRate) AS countOfReviews
FROM clean_reviews cr
inner join clean_meta cm
ON cm.asin = cr.asin
GROUP BY title
ORDER BY  countOfReviews ASC;


/* porcentagem de reviews maiores que 500 palavras*/
SELECT
	round(((100.0 * count(*))/ (
	SELECT
		count(*)
	FROM
		clean_reviews
	WHERE
		numofwords > 500)),2) as Percentege,
	helpfulness
FROM
	clean_reviews
WHERE
	numofwords > 500
GROUP BY
	helpfulness ;

	/* porcentagem de reviews menores que 500 palavras*/

SELECT TOP 500 
	round(((100.0 * count(*))/ (
	SELECT TOP 10
		count(*)
	FROM
		clean_reviews
	WHERE
		numofwords < 500)),2) as Percentege,
	helpfulness
FROM
	clean_reviews
WHERE
	numofwords < 500
GROUP BY
	helpfulness
ORDER BY  newid()

	   	  

	/* porcentagem de rank com produtos feedback*/
SELECT
	round(((100.0 * count(*))/ (
	SELECT
		count(*)
	FROM
		clean_reviews cr
	inner join clean_meta cm on cr.asin = cm.asin
 	WHERE
		rank < 100)),2) as Percentege,
	productFeedback
FROM
	clean_reviews cr
inner join clean_meta cm on cr.asin = cm.asin
WHERE
	rank < 100
GROUP BY
	productFeedback ;

/*checking price*/

SELECT count(reviews)
FROM clean_reviews cr
inner join clean_meta cm on cr.asin = cm.asin
WHERE price < 50 and price > 1


SELECT count(DISTINCT reviews)
FROM clean_reviews cr
inner join clean_meta cm on cr.asin = cm.asin
WHERE price > 50




SELECT  cr.asin ,cr.helpRate,cr.productRating, cm."date" ,cm.asin,cm.productRating,cm.helpRate,  cm."date"  FROM clean_reviews cr 
    inner join related r ON (cr.asin = r.asin and r."type" like 'bought_together') 
    inner join clean_reviews cm ON(r.relatedid = cm.asin )
	group by cr.asin;


SELECT count(DISTINCT mainCategories)
FROM clean_meta



