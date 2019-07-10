////////////////////////////////////////////////////////////////////////
//
// Prepare data for performing graph algorithms
//
// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
MATCH path=(c:Course)-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-03')
WITH c, o, COLLECT(path) AS paths
 	MATCH path=(inst:Instructor)-[:INSTRUCTOR_OF]->(o)<-[:LANGUAGE_OF]-(lang:Language)
WITH c, o, paths + COLLECT(path) AS paths
	MATCH path=(o)<-[:OFFERED_IN]-(o_cit)<-[:PROVINCE_OF]-(o_pro:Province)<-[:REGION_OF]-(o_reg:Region)
RETURN paths + COLLECT(path) AS paths;
//
MATCH path=(c:Course {code: "G414"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-03')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration)<-[:LEARNER_OF]-(l:Learner)<-[:LOCATED_IN]-(l_cit)<-[:PROVINCE_OF]-(l_pro:Province)<-[:REGION_OF]-(l_reg:Region)
RETURN paths + COLLECT(path) AS paths;
//
MATCH path=(c:Course {code: "G414"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-03')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration)<-[:LEARNER_OF]-(l:Learner)<-[:CLASSIFICATION_OF]-(:Classification)<-[:CLASSIFICATION_GROUP_OF]-(:ClassificationGroup)
RETURN paths + COLLECT(path) AS paths;
//
MATCH path=(c:Course)-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-03')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:SURVEYED_FOR]->(:Survey)<-[:CLASSIFICATION_OF]-(:Classification)<-[:CLASSIFICATION_GROUP_OF]-(:ClassificationGroup)
RETURN paths + COLLECT(path) AS paths;
//
MATCH path=(c:Course)-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-03')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:SURVEYED_FOR]->(s:Survey)<-[:DEPARTMENT_OF]-(d:Department)
RETURN paths + COLLECT(path) AS paths;
//
MATCH path=(c:Course)-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-03')
WITH c, o, COLLECT(path) AS paths
 	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: 'Confirmed'})
WITH c, o, paths + COLLECT(path) AS paths
	MATCH path=(o)-[:SURVEYED_FOR]->(:Survey)
RETURN paths + COLLECT(path) AS paths;
//
MATCH path=(i:Instructor)-[:INSTRUCTOR_OF|COURSE_OF*2]-(c)
WITH DISTINCT(c) AS c, i, COUNT(*) AS w
WITH i, c, w
	CALL apoc.create.vRelationship(i,'TEACHES', {weight: w}, c) YIELD rel
WITH i, COLLECT([rel, c]) AS cc
WITH i, cc ORDER BY SIZE(cc) DESC LIMIT 20
WITH COLLECT([i, cc]) AS paths
	CALL apoc.gephi.add('http://10.1.51.73:8080','workspace0', paths, 'weight') yield nodes, relationships, time
RETURN time;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
MATCH (i1:Instructor)
WITH i1
  MATCH (i2:Instructor) WHERE i2 <> i1
WITH i1, i2
  MATCH (i1)-[:INSTRUCTOR_OF]->(o)<-[:INSTRUCTOR_OF]-(i2)
WITH DISTINCT(i2) AS i2, i1, COUNT(DISTINCT(o)) AS oc
  MERGE (i1)-[r1:TOGETHER]->(i2)
    ON CREATE SET r1.c = oc
  MERGE (i2)-[r2:TOGETHER]->(i1)
    ON CREATE SET r2.c = oc;
//
CALL algo.pageRank.stream('Instructor', 'TOGETHER', {iterations:20, dampingFactor:0.85})
	YIELD nodeId, score
RETURN algo.asNode(nodeId).name AS instructor_name, score
	ORDER BY score DESC LIMIT 20;
//
CALL algo.pageRank.stream('Instructor', 'TOGETHER', {iterations:20, dampingFactor:0.85})
	YIELD nodeId, score
WITH algo.asNode(nodeId).name AS instructor_name, score
	ORDER BY score DESC LIMIT 20
WITH instructor_name
	MATCH path=(i:Instructor {name: instructor_name})-[:TOGETHER]-(oi:Instructor)
    	WHERE oi <> i
WITH COLLECT(path) AS paths
	CALL apoc.gephi.add('http://10.0.1.167:8080','workspace0', paths) yield nodes, relationships, time
RETURN time;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
CALL algo.closeness.harmonic.stream('Instructor', 'TOGETHER')
	YIELD nodeId, centrality
RETURN algo.asNode(nodeId).name AS instructor, centrality ORDER BY centrality DESC LIMIT 20;
//
CALL algo.louvain('Instructor', 'TOGETHER', {write:true, writeProperty:'community'})
YIELD nodes, communityCount, iterations, loadMillis, computeMillis, writeMillis;
//
MATCH (i:Instructor)
  WITH DISTINCT(i.community) AS cc, COLLECT(i.name) AS i_list
MATCH path=(i1:Instructor)-[:TOGETHER]-(i2:Instructor)
  WHERE i1.name IN i_list AND i2.name IN i_list AND i1.name <> i2.name
RETUDN path;
//
MATCH (i:Instructor)
  WITH DISTINCT(i.community) AS cc, COLLECT(i.name) AS i_list
MATCH path=(i1:Instructor)-[:TOGETHER]-(i2:Instructor)
  WHERE i1.name IN i_list AND i2.name IN i_list AND i1.name <> i2.name
WITH COLLECT(path) AS paths
  CALL apoc.gephi.add('http://10.0.1.167:8080','workspace0', paths) yield nodes, relationships, time
RETURN time;
//
////////////////////////////////////////////////////////////////////////
