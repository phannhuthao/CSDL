-- 3 --
CREATE VIEW View_Album_Artist AS
SELECT 
    album.AlbumId AS AlbumId,
    album.Title AS Album_Title,
    artist.Name AS Artist_Name
FROM album
JOIN artist ON album.ArtistId = artist.ArtistId;

-- 4 -- 
CREATE VIEW View_Customer_Spending AS
SELECT 
    customer.CustomerId,
    customer.FirstName,
    customer.LastName,
    customer.Email,
    COALESCE(SUM(invoice.Total), 0) AS Total_Spending
FROM customer
LEFT JOIN invoice ON customer.CustomerId = invoice.CustomerId
GROUP BY customer.CustomerId;

-- 5 --
CREATE INDEX idx_Employee_LastName ON employee(LastName);

EXPLAIN SELECT * FROM employee WHERE LastName = 'King';


-- 6 --
DELIMITER //
CREATE PROCEDURE GetTracksByGenre(IN GenreId INT)
BEGIN
    SELECT 
        track.TrackId AS TrackId,
        track.Name AS Track_Name,
        album.Title AS Album_Title,
        artist.Name AS Artist_Name
    FROM track
    JOIN album ON track.AlbumId = album.AlbumId
    JOIN artist ON album.ArtistId = artist.ArtistId
    WHERE track.GenreId = GenreId;
END //
DELIMITER ;


-- 7 --
DELIMITER //
CREATE PROCEDURE GetTrackCountByAlbum(IN p_AlbumId INT)
BEGIN
    SELECT 
        COUNT(*) AS Total_Tracks
    FROM track
    WHERE track.AlbumId = p_AlbumId;
END //
DELIMITER ;

-- 8 --
DROP VIEW IF EXISTS View_Album_Artist;
DROP VIEW IF EXISTS View_Customer_Spending;

DROP PROCEDURE IF EXISTS GetTracksByGenre;
DROP PROCEDURE IF EXISTS GetTrackCountByAlbum;

DROP INDEX idx_Employee_LastName ON employee;



