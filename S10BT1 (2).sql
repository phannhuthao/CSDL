-- BT1--

DELIMITER $$

CREATE procedure  UpdateCityPopulation(INOUT city_id INT, IN new_population INT)
BEGIN
 UPDATE city
    SET Population = new_population
    WHERE ID = city_id;
    
    SELECT ID AS CityID, Name, Population
    FROM city
    WHERE ID = city_id;
END $$

DELIMITER ;
 
 -- 2) --
SET @city_id = 100;
CALL UpdateCityPopulation(@city_id, 500000);
SELECT @city_id AS CityID;

-- 3) --
DROP PROCEDURE IF EXISTS UpdateCityPopulation;