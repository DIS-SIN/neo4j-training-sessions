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
// SOC 2010 data
//
CREATE CONSTRAINT ON (n:MajorGroup) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:MinorGroup) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:BroadGroup) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:Occupation) ASSERT n.code IS UNIQUE;
//
//
// O*NET Occupation Title data
//
CREATE CONSTRAINT ON (n:ONetOcc) ASSERT n.code IS UNIQUE;
//
CREATE CONSTRAINT ON (n:JobTitle) ASSERT n.code IS UNIQUE;
CREATE INDEX ON :JobTitle(abbr);
//
// 
// UNSPSC data
//
CREATE CONSTRAINT ON (n:UNSPSC_Segment) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:UNSPSC_Family) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:UNSPSC_Class) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:UNSPSC_Commodity) ASSERT n.code IS UNIQUE;
CREATE INDEX ON :UNSPSC_Segment(title);
CREATE INDEX ON :UNSPSC_Family(title);
CREATE INDEX ON :UNSPSC_Class(title);
CREATE INDEX ON :UNSPSC_Commodity(title);
//
CREATE CONSTRAINT ON (n:TechSkill) ASSERT n.name IS UNIQUE;
CREATE CONSTRAINT ON (n:ToolUsed) ASSERT n.name IS UNIQUE;
//
//
// Kaggle Job Recommendation Challenge data
//
CREATE CONSTRAINT ON (n:User) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :User(type);
//
CREATE CONSTRAINT ON (n:DegreeType) ASSERT n.name IS UNIQUE;
CREATE CONSTRAINT ON (n:EducationMajor) ASSERT n.name IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Country) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:State) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :State(code);
CREATE CONSTRAINT ON (n:City) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :City(name);
CREATE CONSTRAINT ON (n:ZipCode) ASSERT n.code IS UNIQUE;
//
CREATE CONSTRAINT ON (n:Job) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :Job(title);
//
CREATE CONSTRAINT ON (n:LSWord) ASSERT n.c IS UNIQUE;
CREATE INDEX ON :LSWord(f);
//
CREATE CONSTRAINT ON (n:LSTitle) ASSERT n.code IS UNIQUE;
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
