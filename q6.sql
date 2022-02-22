SELECT m.name,
       count(*)*100 /
  (SELECT count(*)
   FROM Track
   WHERE Track.MediaTypeId IS NOT NULL) prcmedia
FROM MediaType m
JOIN track t ON m.MediaTypeId = t.MediaTypeId
GROUP BY 1
ORDER BY 2 DESC