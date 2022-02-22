SELECT i.BillingCountry country,
       sum(i.total) * 100 /
  (SELECT sum(i.total)
   FROM invoice i) prcnt
FROM Invoice i
GROUP BY 1
ORDER BY 2 DESC