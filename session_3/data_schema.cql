////////////////////////////////////////////////////////////////////////
//
// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
// CONSTRAINTS AND INDEXES
//
// 1. Create unique constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT n.property IS UNIQUE;
//
// 2. Create a single-property index
// CREATE INDEX ON :Label(property);
//
// 3. Create a composite index
// CREATE INDEX ON :Label(prop1, …​, propN);
//
// 4. Create node property existence constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT EXISTS(n.property);
//
// 5. Create relationship property existence constraint
// CREATE CONSTRAINT ON ()-[r:relationshipType]-() ASSERT EXISTS(r.property);
//
// 6. Create a Node Key
// ASSERT (variable.propertyName_1, …​, variable.propertyName_n) IS NODE KEY;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
CREATE CONSTRAINT ON (n:Course) ASSERT n.code IS UNIQUE;
CREATE INDEX ON :Course(title);
// properties:
// - event_description
//
CREATE CONSTRAINT ON (n:BusinessType) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:DeliveryType) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Provider) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:BusinessLine) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Offering) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :Offering(status);
CREATE INDEX ON :Offering(start_date);
CREATE INDEX ON :Offering(end_date);
// properties:
// - month
// - week
// - duration
// relationships:
// - Language
// - City
// - Instructor
//
CREATE CONSTRAINT ON (n:Registration) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :Registration(status);
CREATE INDEX ON :Registration(date);
// properties:
// - scope
// - no_show
// - date
// - gap
// relationships:
// - Learner
//
CREATE CONSTRAINT ON (n:Language) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Region) ASSERT n.name IS UNIQUE;
// relationships:
// - Province
//
CREATE CONSTRAINT ON (n:Province) ASSERT n.name IS UNIQUE;
// relationships:
// - City
//
CREATE CONSTRAINT ON (n:City) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Instructor) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Learner) ASSERT n.uid IS UNIQUE;
// relationships:
// - City
// - Registration
//
CREATE CONSTRAINT ON (n:Classification) ASSERT n.code IS UNIQUE;
// relationships:
// - Learner
// - ClassificationGroup
//
CREATE CONSTRAINT ON (n:ClassificationGroup) ASSERT n.code IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Department) ASSERT n.code IS UNIQUE;
CREATE INDEX ON :Department(name);
// relationships:
// - Registration
//
CREATE CONSTRAINT ON (n:Survey) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :Survey(date);
CREATE INDEX ON :Survey(classification);
CREATE INDEX ON :Survey(department);
//relationships:
// - Course
// - Question (answer)
// - Classification
// - Department
//
CREATE CONSTRAINT ON (n:Question) ASSERT n.name IS UNIQUE;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// List all constraints
CALL db.constraints();
//
// List all indexes
CALL db.indexes();
//
// Wait for all indexes online
CALL db.awaitIndexes();
//
////////////////////////////////////////////////////////////////////////
