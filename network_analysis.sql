--This SQL code calculates network analysis. This method may answer many questions such as distance between points, possible routes between points, or neighborhoods that can be serviced by a point.

--Testing Data
SELECT COUNT(*)
FROM network.nodes;

SELECT uid, ST_TRANSFORM(ST_POINT(x::NUMERIC, y::NUMERIC, 2229), 26945) AS geom
FROM network.table_fqhc
WHERE uid = '228';

/* PRACTICE */
WITH fqhc AS(
	SELECT uid, ST_TRANSFORM(ST_POINT(x::NUMERIC, y::NUMERIC, 2229), 26945) AS geom
	FROM network.table_fqhc
	WHERE uid = '229'
)
SELECT nodes.osmid
FROM fqhc, network.nodes
ORDER BY fqhc.geom <-> nodes.geom
LIMIT 1;


-- Shortest distance between points.
SELECT *   	
FROM pgr_dijkstra(
    '
      SELECT 
	  	fid AS id,
        u AS source,
        v AS target,
        length AS cost
      FROM network.edges
    ',
3581264105,
123084259,
directed := false) AS di
LEFT JOIN network.edges
ON di.edge = edges.fid;

--Shortest time between points.
SELECT *   	
FROM pgr_dijkstra(
    '
      SELECT 
	  	fid AS id,
        u AS source,
        v AS target,
        minutes AS cost
      FROM network.edges
    ',
3581264105,
123084259,
directed := false) AS di
LEFT JOIN network.edges
ON di.edge = edges.fid;

--Create service layer - within 3 minutes of the fid.
SELECT *
FROM pgr_drivingDistance(
    '
      SELECT 
	  	fid AS id,
        u AS source,
        v AS target,
        minutes AS cost
      FROM network.edges
    ',
122988901,
3,
directed := false) AS di
LEFT JOIN network.edges
ON di.edge = edges.fid;