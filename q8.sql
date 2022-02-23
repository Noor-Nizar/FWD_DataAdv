WITH T AS
  (SELECT a.ArtistId,
          sum(il.quantity) amtsold
   FROM Artist a
   JOIN Album al ON a.ArtistId = al.ArtistId
   JOIN Track t ON T.AlbumId = al.AlbumId
   JOIN InvoiceLine il ON il.TrackId = t.TrackId
   GROUP BY 1
   ORDER BY 2 DESC
   LIMIT 10),
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
   ORDER BY 1),
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
            2),
     TGM AS
  (SELECT tga.ArtistId,
          tga.GenreId,
          MAX(tga.cg) cg
   FROM TGA
   JOIN T ON tga.ArtistId = T.ArtistId
   GROUP BY 1)
SELECT a.Name,
       t.amtsold,
       g.Name Genre,
       tgm.cg
FROM TGM
JOIN T ON tgm.ArtistId = t.ArtistId
JOIN Genre g ON g.GenreId = tgm.GenreId
JOIN Artist a ON a.ArtistId = tgm.ArtistId
ORDER BY 2 DESC,
         4 DESC