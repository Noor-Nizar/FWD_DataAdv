-- use this to get least amount of sales for 10th top artist.
WITH T AS
  (SELECT a.ArtistId,
          sum(il.quantity) amtsold
   FROM Artist a
   JOIN Album al ON a.ArtistId = al.ArtistId
   JOIN Track t ON T.AlbumId = al.AlbumId
   JOIN InvoiceLine il ON il.TrackId = t.TrackId
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 10), --incase there are some artists sharing the same sales as 10th
TA AS
  (SELECT a.artistid,
          a.Name
   FROM Artist a
   JOIN Album al ON a.ArtistId = al.ArtistId
   JOIN Track t ON T.AlbumId = al.AlbumId
   JOIN InvoiceLine il ON il.TrackId = t.TrackId
   GROUP BY 1
   HAVING SUM(il.quantity) >=
     (SELECT MIN(T.amtsold)
      FROM T)
   ORDER BY 1), --get the total sales per genre for each artist
 TGA AS
  (SELECT ta.ArtistId,
          g.GenreId,
          SUM(il.Quantity) cg
   FROM TA
   JOIN Album al ON TA.ArtistId = al.ArtistId
   JOIN Track t ON T.AlbumId = al.AlbumId
   JOIN Genre g ON T.GenreId = g.GenreId
   JOIN InvoiceLine il ON T.TrackId = il.TrackId
   GROUP BY 1,
            2), --get the max genre of sales for each artist
 TGM AS
  (SELECT tga.ArtistId,
          tga.GenreId,
          MAX(tga.cg) cg
   FROM TGA
   JOIN T ON tga.ArtistId = T.ArtistId
   GROUP BY 1), --counts the number of artists' other than top genre's tracks released
 tcnpg AS
  (SELECT stgm.ArtistId,
          count(*) cnpg
   FROM TGM stgm
   JOIN album al ON al.ArtistId = stgm.ArtistId
   JOIN Track t ON t.AlbumId = al.AlbumId
   WHERE t.GenreId !=
       (SELECT tgm.GenreId
        FROM tgm
        WHERE stgm.ArtistId = tgm.ArtistId)
   GROUP BY 1), --counts the number of artists' other than top genre's tracks released
 tcpg AS
  (SELECT stgm.ArtistId,
          count(*) cpg
   FROM TGM stgm
   JOIN album al ON al.ArtistId = stgm.ArtistId
   JOIN Track t ON t.AlbumId = al.AlbumId
   WHERE t.GenreId =
       (SELECT tgm.GenreId
        FROM tgm
        WHERE stgm.ArtistId = tgm.ArtistId)
   GROUP BY 1) --joins the data

SELECT a.Name,
       t.amtsold,
       g.Name Genre,
       tgm.cg,
       coalesce(tcnpg.cnpg, 0) cnpg,
       tcpg.cpg
FROM TGM
LEFT JOIN tcnpg ON tgm.ArtistId = tcnpg.ArtistId
JOIN T ON tgm.ArtistId = t.ArtistId
JOIN tcpg ON tgm.ArtistId = tcpg.ArtistId
JOIN Genre g ON g.GenreId = tgm.GenreId
JOIN Artist a ON a.ArtistId = tgm.ArtistId
ORDER BY 2 DESC,
         4 DESC,
         5 DESC,
         6 DESC