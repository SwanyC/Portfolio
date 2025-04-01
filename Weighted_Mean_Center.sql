SELECT rid, rast
FROM assignment_8.sfv_nlcd;

SELECT *
FROM assignment_8.surveypoints;

-- The landcover with the most number of survey points.
SELECT ST_VALUE(sfv_nlcd.rast, surveypoints.geom) AS landcover, COUNT(*) AS count
FROM assignment_8.sfv_nlcd, assignment_8.surveypoints
WHERE ST_VALUE(sfv_nlcd.rast, surveypoints.geom) IS NOT NULL
GROUP BY landcover
ORDER BY count DESC
LIMIT 1;

-- The average elevation that the sample points are located in.
WITH samples AS(
	SELECT fid, ST_TRANSFORM(ST_POINT(xcoord::NUMERIC, ycoord::NUMERIC, 32611), 26945) AS geom
	FROM assignment_8.samplepoints
	)
SELECT ROUND(AVG(ST_VALUE(rast, geom))::NUMERIC, 2) AS avg_elevation
FROM samples, assignment_8.sfv_dem
WHERE ST_VALUE(rast, geom) IS NOT NULL;

-- The weighted mean center for each block group.
WITH poppoints AS (
	SELECT (ST_PIXELASCENTROIDS(rast)).val AS population, (ST_PIXELASCENTROIDS(rast)).geom AS geom
	FROM assignment_8.sfv_population
	)
SELECT fips, 
	ST_POINT(
	SUM(ST_X(poppoints.geom) * population) / SUM(population),
	SUM(ST_Y(poppoints.geom) * population) / SUM(population),
	26945
	) AS geom
FROM poppoints
LEFT JOIN assignment_8.bg ON ST_INTERSECTS(bg.geom, poppoints.geom)
GROUP BY fips;

-- Landcovers with the most number of WMCs.
WITH wmc AS(
		WITH poppoints AS (
		SELECT (ST_PIXELASCENTROIDS(rast)).val AS population, (ST_PIXELASCENTROIDS(rast)).geom AS geom
		FROM assignment_8.sfv_population
		)
	SELECT fips, 
		ST_POINT(
		SUM(ST_X(poppoints.geom) * population) / SUM(population),
		SUM(ST_Y(poppoints.geom) * population) / SUM(population),
		26945
		) AS geom
	FROM poppoints
	LEFT JOIN assignment_8.bg ON ST_INTERSECTS(bg.geom, poppoints.geom)
	GROUP BY fips
)
SELECT ST_VALUE(rast, geom) AS landcover, COUNT(*) AS wmc_count
FROM wmc, assignment_8.sfv_nlcd
WHERE ST_VALUE(rast, geom) IS NOT NULL
GROUP BY landcover
ORDER BY wmc_count DESC
LIMIT 1;