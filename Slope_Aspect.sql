--Testing the dataset.
SELECT *
FROM trees;
SELECT *
FROM dem;

--Number of trees within elevations higher than 320 meters.
SELECT geom, tree_id, type, ST_VALUE(rast, geom) AS elevation
FROM trees, dem
WHERE ST_VALUE(rast, geom) IS NOT NULL 
	AND ST_VALUE(rast, geom) >= 320;

--Number of trees of each type in elevations higher than 320 meters.
SELECT type, COUNT(*)
FROM trees, dem
WHERE ST_VALUE(rast, geom) IS NOT NULL 
	AND ST_VALUE(rast, geom) >= 320
GROUP BY type;

--The type of trees located in areas with a slope greater than or equal to 50%.
WITH sloperast AS(
	SELECT rid, ST_SLOPE(rast, 1, '32BF','PERCENT') AS rast
	FROM dem
)
SELECT tree_id, type, ROUND(ST_VALUE(rast, geom)::NUMERIC, 2) AS slope, geom
FROM trees, sloperast
WHERE ST_VALUE(rast, geom) IS NOT NULL 
	AND ST_VALUE(rast, geom) >= 50;

--Number of trees located on the South facing slope.
SELECT tree_id, type, ST_VALUE(ST_ASPECT(rast), geom) AS aspect, geom
FROM trees, dem
WHERE ST_VALUE(ST_ASPECT(rast), geom) IS NOT NULL
	AND ST_VALUE(ST_ASPECT(rast), geom) BETWEEN 112.5 AND 247.5

--Number of trees located on the North facing slope.
SELECT tree_id, type, ST_VALUE(ST_ASPECT(rast), geom) AS aspect, geom
FROM trees, dem
WHERE ST_VALUE(ST_ASPECT(rast), geom) IS NOT NULL
	AND ST_VALUE(ST_ASPECT(rast), geom) BETWEEN 0 AND 67.5
	OR ST_VALUE(ST_ASPECT(rast), geom) BETWEEN 292.5 AND 337.5;





