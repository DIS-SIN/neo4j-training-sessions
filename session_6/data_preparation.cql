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
// explore-1-course-offering-instructor-language-location
// graph view
//
MATCH path=(c:Course)-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-03')
WITH c, o, COLLECT(path) AS paths
 	MATCH path=(inst:Instructor)-[:INSTRUCTOR_OF]->(o)<-[:LANGUAGE_OF]-(lang:Language)
WITH c, o, paths + COLLECT(path) AS paths
	MATCH path=(o)<-[:OFFERED_IN]-(o_cit)<-[:PROVINCE_OF]-(o_pro:Province)<-[:REGION_OF]-(o_reg:Region)
RETURN paths + COLLECT(path) AS paths;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// explore-2a-course-offering-registration-learner-location
// graph view
//
MATCH path=(c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration)<-[:LEARNER_OF]-(l:Learner)<-[:LOCATED_IN]-(l_cit)<-[:PROVINCE_OF]-(l_pro:Province)<-[:REGION_OF]-(l_reg:Region)
RETURN paths + COLLECT(path) AS paths;
//
//
// explore-2b-course-offering-location-overview
// graph view
//
MATCH (c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration)<-[:LEARNER_OF]-(l:Learner)<-[:LOCATED_IN]-(city)<-[:PROVINCE_OF]-(prov:Province)<-[:REGION_OF]-(regi:Region)
WITH DISTINCT(city), prov, regi, c, o, COUNT(*) AS rc
	CALL apoc.create.vRelationship(o,'LEANERS', {count: rc}, city) YIELD rel
RETURN c, o, rel, city, prov, regi;
//
//
// explore-2c-course-offering-registration-confirmed
// tabular view
//
MATCH (c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})
WITH DISTINCT(r.date) AS d, COUNT(*) AS count, o, c
RETURN o.uid AS offering, o.start_date AS start_date, o.end_date AS end_date, d AS registration_date, count ORDER BY offering, registration_date;
//
//
// explore-2c-course-offering-registration-confirmed
// virtual graph view
//
MATCH (c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})
WITH DISTINCT(r.date) AS d, COLLECT(r) AS registrations, o, c
WITH c, o, d, registrations
	CALL apoc.create.vNode(['Registrations'], {date: d}) YIELD node AS r
	CALL apoc.create.vRelationship(o, 'HAS', {count: SIZE(registrations)}, r) yield rel
RETURN c, o, rel, r;
//
//
// explore-2d-course-offering-survey
// tabular view
//
MATCH (c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o
	MATCH path=(o)-[:SURVEYED_FOR]->(s:Survey)
WITH DISTINCT(s.date) AS d, COUNT(*) AS count, o, c
RETURN o.uid AS offering, o.start_date AS start_date, o.end_date AS end_date, d AS survey_date, count ORDER BY offering, survey_date;
//
// explore-2d-course-offering-survey
// virtual graph view
//
MATCH (c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o
	MATCH path=(o)-[:SURVEYED_FOR]->(s:Survey)
WITH DISTINCT(s.date) AS d, COLLECT(s) AS surveys, o, c
WITH c, o, d, surveys
	CALL apoc.create.vNode(['Surveys'], {date: d}) YIELD node AS r
	CALL apoc.create.vRelationship(o, 'HAS', {count: SIZE(surveys)}, r) yield rel
RETURN c, o, rel, r;
//
//
// explore-2e-course-offering-registration-confirmed-survey
// tabular view
//
MATCH (c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})
WITH DISTINCT(r.date) AS d, COUNT(*) AS count, o, c ORDER BY o.uid, d
WITH c, o, COLLECT([TOSTRING(d), count]) AS rc,SUM (count) AS cr
	MATCH path=(o)-[:SURVEYED_FOR]->(s:Survey)
WITH DISTINCT(s.date) AS d, COUNT(*) AS count, o, c, rc, cr
WITH c, o, rc, cr, COLLECT([TOSTRING(d), count]) AS sc, SUM (count) AS cs
RETURN o.uid AS offering, o.start_date AS start_date, o.end_date AS end_date, rc AS registrations_per_day, cr AS total_registration, sc AS surveys_per_day, cs AS total_surveys ORDER BY offering;
//
// explore-2e-course-offering-registration-confirmed-survey
// virtual graph view
//
MATCH (c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})
WITH DISTINCT(r.date) AS d, COLLECT(r) AS registrations, o, c
	CALL apoc.create.vNode(['Registrations'], {date: d}) YIELD node AS r
	CALL apoc.create.vRelationship(o, 'HAS', {count: SIZE(registrations)}, r) yield rel
WITH c, o, COLLECT([rel, r]) AS registrations_list
WITH c, o, registrations_list
	MATCH path=(o)-[:SURVEYED_FOR]->(s:Survey)
WITH DISTINCT(s.date) AS d, COLLECT(s) AS surveys, o, c, registrations_list
WITH c, o, registrations_list, d, surveys
	CALL apoc.create.vNode(['Surveys'], {date: d}) YIELD node AS r
	CALL apoc.create.vRelationship(o, 'HAS', {count: SIZE(surveys)}, r) yield rel
RETURN c, o, registrations_list, COLLECT([rel, r]) AS surveys_list
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// explore-3a-course-offering-registration-learner-classification
// graph view
//
MATCH path=(c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})<-[:LEARNER_OF]-(l:Learner)<-[:CLASSIFICATION_OF]-(:Classification)<-[:CLASSIFICATION_GROUP_OF]-(:ClassificationGroup)
RETURN paths + COLLECT(path) AS paths;
//
//
// explore-3b-course-offering-survey-classification
// graph view
//
MATCH path=(c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:SURVEYED_FOR]->(:Survey)<-[:CLASSIFICATION_OF]-(:Classification)<-[:CLASSIFICATION_GROUP_OF]-(:ClassificationGroup)
RETURN paths + COLLECT(path) AS paths;
//
//
// explore-3c-course-offering-registration-learner-survey-classification
// graph view
//
MATCH path=(c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})<-[:LEARNER_OF]-(l:Learner)<-[:CLASSIFICATION_OF]-(:Classification)<-[:CLASSIFICATION_GROUP_OF]-(:ClassificationGroup)
WITH c, o, paths + COLLECT(path) AS paths
	MATCH path=(o)-[:SURVEYED_FOR]->(:Survey)<-[:CLASSIFICATION_OF]-(:Classification)<-[:CLASSIFICATION_GROUP_OF]-(:ClassificationGroup)
RETURN paths + COLLECT(path) AS paths;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// explore-4a-course-offering-registration-learner-department
// graph view
//
MATCH path=(c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})<-[:LEARNER_OF]-(l:Learner)<-[:DEPARTMENT_OF]-(d:Department)
RETURN paths + COLLECT(path) AS paths;
//
//
// explore-4b-course-offering-survey-department
// graph view
//
MATCH path=(c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:SURVEYED_FOR]->(s:Survey)<-[:DEPARTMENT_OF]-(d:Department)
RETURN paths + COLLECT(path) AS paths;
//
// explore-4c-course-offering-registration-learner-survey-department
// graph view
//
MATCH path=(c:Course {code: "G131"})-[:COURSE_OF]->(o:Offering)
   WHERE o.start_date = DATE('2019-04-05')
WITH c, o, COLLECT(path) AS paths
	MATCH path=(o)-[:REGISTERED_FOR]->(r:Registration {status: "Confirmed"})<-[:LEARNER_OF]-(l:Learner)<-[:DEPARTMENT_OF]-(d:Department)
WITH c, o, paths + COLLECT(path) AS paths
	MATCH path=(o)-[:SURVEYED_FOR]->(s:Survey)<-[:DEPARTMENT_OF]-(d:Department)
RETURN paths + COLLECT(path) AS paths;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// insight-1a-top-5-teach-most-offerings-instuctors
// graph view
//
MATCH path=(i:Instructor)-[:INSTRUCTOR_OF|COURSE_OF*2]-(c:Course)
WITH DISTINCT(c) AS c, i, COUNT(*) AS w
WITH i, c, w
	CALL apoc.create.vRelationship(i,'TEACHES', {weight: w}, c) YIELD rel
WITH DISTINCT(i) AS i, COLLECT([rel, c]) AS cc
RETURN i, cc ORDER BY SIZE(cc) DESC LIMIT 5;
//
//
// insight-1b-top-5-most-collaborate-instructors
//
CALL algo.closeness.harmonic(
  'MATCH (i:Instructor) RETURN id(i) AS id',
  'MATCH (i1:Instructor)-[:INSTRUCTOR_OF*2]-(i2:Instructor) RETURN id(i1) as source, id(i2) as target',
  {graph:'cypher', writeProperty: 'centrality'}
);
//
MATCH (i:Instructor)
WITH i ORDER BY i.centrality DESC LIMIT 5
WITH i
	MATCH (i)-[:INSTRUCTOR_OF*2]-(oi:Instructor)
WITH DISTINCT(oi), i, COUNT(*) AS ic
  CALL apoc.create.vRelationship(i, 'COLLABORATE', {count: ic}, oi) yield rel
RETURN i, oi, rel;
//
//
// insight-1c-instructors-communities
//
CALL algo.louvain(
  'MATCH (i:Instructor) RETURN id(i) AS id',
  'MATCH (i1:Instructor)-[r:INSTRUCTOR_OF*2]-(i2:Instructor) RETURN id(i1) AS source, id(i2) AS target, COUNT(DISTINCT(r)) AS weight',
  {graph:'cypher', write: true}
);
//
MATCH (i:Instructor)
  WITH DISTINCT(i.community) AS cc, COLLECT(i.name) AS i_list
MATCH path=(i1:Instructor)-[:TOGETHER]-(i2:Instructor)
  WHERE i1.name IN i_list AND i2.name IN i_list AND i1.name <> i2.name
RETUDN path;
//
MATCH (i:Instructor)
WITH DISTINCT(i.community) AS c, COLLECT(i) AS ic
WITH c, ic
	WHERE SIZE(ic) > 1
WITH c, ic ORDER BY SIZE(ic) DESC LIMIT 5
WITH c, apoc.coll.zip(REVERSE(TAIL(REVERSE(ic))), TAIL(ic)) AS pairs
	UNWIND pairs AS pair
WITH c, pair[0] AS i1, pair[1] AS i2
	CALL apoc.create.vRelationship(i1, 'COLLABORATE', {count: c}, i2) yield rel
RETURN i1, i2, rel;
//
////////////////////////////////////////////////////////////////////////
