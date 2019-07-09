MATCH (i:Instructor)
  WITH DISTINCT(LOWER(i.name)) AS i, COLLECT(i.name) AS ic
WITH i, ic
  WHERE SIZE(ic) > 1
RETURN i, ic;

MATCH (i:Instructor)
	WHERE i.name IN ['Jean-Philippe Tabet', 'Yvan Bastien', 'Serge Poirier']
WITH i
	MATCH (oi:Instructor)
    	WHERE oi <> i AND LOWER(oi.name) = LOWER(i.name)
WITH [i, oi] AS i_list
  CALL apoc.refactor.mergeNodes(i_list, {properties: 'discard'}) YIELD node
RETURN node;

MATCH (i:Instructor) RETURN COUNT(DISTINCT(LOWER(i.name)));

MATCH (i1:Instructor)
WITH i1
  MATCH (i2:Instructor) WHERE i2 <> i1
WITH i1, i2
  MATCH (i1)-[:INSTRUCTOR_OF]->(o)<-[:INSTRUCTOR_OF]-(i2)
WITH DISTINCT([i1, i2]) AS pair, COUNT(DISTINCT(o)) AS oc
RETURN pair, oc;

MATCH (i1:Instructor)
WITH i1
  MATCH (i2:Instructor) WHERE i2 <> i1
WITH i1, i2
  MATCH (i1)-[:INSTRUCTOR_OF]->(o)<-[:INSTRUCTOR_OF]-(i2)
WITH DISTINCT(i2) AS i2, i1, COUNT(DISTINCT(o)) AS oc
  MERGE (i1)-[r1:TOGETHER]->(i2)
    ON CREATE SET r1.c = oc
  MERGE (i2)-[r2:TOGETHER]->(i1)
    ON CREATE SET r2.c = oc

CALL algo.pageRank.stream('Instructor', 'TOGETHER', {iterations:20, dampingFactor:0.85})
	YIELD nodeId, score
RETURN algo.asNode(nodeId).name AS instructor_name, score
	ORDER BY score DESC LIMIT 20;

CALL algo.pageRank.stream('Instructor', 'TOGETHER', {iterations:20, dampingFactor:0.85})
	YIELD nodeId, score
WITH algo.asNode(nodeId).name AS instructor_name, score
	ORDER BY score DESC LIMIT 20
WITH instructor_name
	MATCH path=(i:Instructor {name: instructor_name})-[:TOGETHER]-(oi:Instructor)
    	WHERE oi <> i
WITH COLLECT(path) AS paths
	CALL apoc.gephi.add('http://10.0.1.167:8080','workspace0', paths) yield nodes, relationships, time
RETURN time

CALL algo.closeness.harmonic.stream('Instructor', 'TOGETHER')
	YIELD nodeId, centrality
RETURN algo.asNode(nodeId).name AS instructor, centrality ORDER BY centrality DESC LIMIT 20;

CALL algo.louvain('Instructor', 'TOGETHER', {write:true, writeProperty:'community'})
YIELD nodes, communityCount, iterations, loadMillis, computeMillis, writeMillis;

MATCH (i:Instructor)
  WITH DISTINCT(i.community) AS cc, COLLECT(i.name) AS i_list
MATCH path=(i1:Instructor)-[:TOGETHER]-(i2:Instructor)
  WHERE i1.name IN i_list AND i2.name IN i_list AND i1.name <> i2.name
RETUDN path

MATCH (i:Instructor)
  WITH DISTINCT(i.community) AS cc, COLLECT(i.name) AS i_list
MATCH path=(i1:Instructor)-[:TOGETHER]-(i2:Instructor)
  WHERE i1.name IN i_list AND i2.name IN i_list AND i1.name <> i2.name
WITH COLLECT(path) AS paths
  CALL apoc.gephi.add('http://10.0.1.167:8080','workspace0', paths) yield nodes, relationships, time
RETURN time
