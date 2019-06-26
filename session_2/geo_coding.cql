////////////////////////////////////////////////////////////////////////
//
// Load data from the CSV files and populate the graph database
//
// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Geocoding all cities
//
CALL apoc.periodic.iterate(
"
    MATCH (c:City)
        WHERE NOT(EXISTS(c.latitude))
    WITH c 
        MATCH (c)-[:IN_STATE]->(s:State)-[:IN_COUNTRY]->(ctr:Country)
    WITH c, c.name + ' ' + s.code + ' ' + ctr.code AS address
    RETURN c, address
","
    WITH c, address
        CALL apoc.spatial.geocodeOnce(address) YIELD location
    WITH c, location
        WHERE location IS NOT NULL
    WITH c, location
        SET c.latitude = location['latitude'], c.longitude = location['longitude']
",
{
    batchSize:1, iterateList:true, parallel:false
});
//
MATCH (c:City)
    WHERE EXISTS(c.latitude) AND EXISTS(c.longitude)
RETURN COUNT(c) AS total_number_of_geocoded_cities;
//
////////////////////////////////////////////////////////////////////////