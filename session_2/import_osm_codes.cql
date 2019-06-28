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
// Import geocodes for all cities
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.csv('/osm/osm_geocoded_cities.tsv', 
        {
            header: true, 
            sep: 'TAB', 
            ignoreQuotations: true,
            mapping: {
                uid: {type: 'string'}, 
                latitude: {type: 'float'},
                longitude: {type: 'float'}
            }
        }
    ) 
    YIELD map
 ", "
    WITH map
        MERGE (c:City {uid: map.uid})
            SET c.latitude = map.latitude, c.longitude = map.longitude
",
{
    batchSize:1000, iterateList:true, parallel:true, concurrency: 8
});
//
MATCH (c:City)
    WHERE EXISTS(c.latitude) AND EXISTS(c.longitude)
RETURN COUNT(c) AS total_number_of_geocoded_cities;
//
MATCH (o:City {name: "Ottawa"})-[:IN_STATE]->(on:State {code: "Ontario"})<-[:IN_STATE]-(t:City {name: "Toronto"}) 
RETURN ROUND(DISTANCE(POINT(o), POINT(t))/1000) AS distance_in_km;
//
////////////////////////////////////////////////////////////////////////