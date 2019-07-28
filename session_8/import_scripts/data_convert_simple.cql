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
//
CALL apoc.periodic.iterate(
"
  MATCH (offering:Offering)
    WHERE EXISTS(offering.start_date) AND  EXISTS(offering.end_date)
  RETURN offering
 ", "
 WITH offering
  SET
    offering.start_date = SUBSTRING(offering.start_date, 0, 4) + '-' + SUBSTRING(offering.start_date, 5, 2) + '-' + SUBSTRING(offering.start_date, 8, 2),
    offering.end_date = SUBSTRING(offering.end_date, 0, 4) + '-' + SUBSTRING(offering.end_date, 5, 2) + '-' + SUBSTRING(offering.end_date, 8, 2)
",
{
    batchSize:1024, iterateList:true, parallel:true, concurrency: 16
});
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
//
CALL apoc.periodic.iterate(
"
  MATCH (registration:Registration)
    WHERE EXISTS(registration.date)
  RETURN registration
 ", "
 WITH registration
  SET registration.date = SUBSTRING(registration.date, 0, 4) + '-' + SUBSTRING(registration.date, 5, 2) + '-' + SUBSTRING(registration.date, 8, 2)
",
{
    batchSize:1024, iterateList:true, parallel:true, concurrency: 16
});
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
//
CALL apoc.periodic.iterate(
"
  MATCH (survey:Survey)
    WHERE EXISTS(survey.date)
  RETURN survey
 ", "
 WITH survey
  SET survey.date = SUBSTRING(survey.date, 0, 4) + '-' + SUBSTRING(survey.date, 5, 2) + '-' + SUBSTRING(survey.date, 8, 2)
",
{
    batchSize:1024, iterateList:true, parallel:true, concurrency: 16
});
//
////////////////////////////////////////////////////////////////////////
