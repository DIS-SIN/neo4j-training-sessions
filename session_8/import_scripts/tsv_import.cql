CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/business_type.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:BusinessType {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/city.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:City {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/classification_group.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:ClassificationGroup {code: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/classification.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Classification {code: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/course.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Course {code: list[0]})
      ON CREATE SET
        n.title = list[1],
        n.event_description = list[2];
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/delivery_type.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:DeliveryType {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/department.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Department {code: list[0]})
      ON CREATE SET
        n.name = list[1];
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/instructor.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Instructor {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/language.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Language {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/learner.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Learner {uid: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/offering.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Offering {uid: list[0]})
      ON CREATE SET
        n.start_date = list[1],
        n.end_date = list[2],
        n.month = list[3],
        n.week = list[4],
        n.duration = list[5],
        n.status = list[6];
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/province.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Province {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/question.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Question {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/region.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Region {name: list[0]});
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/registration.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Registration {uid: list[0]})
      ON CREATE SET
        n.scope = list[1],
        n.status = list[2],
        n.no_show = list[3],
        n.date = list[4],
        n.gap = list[5];
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/survey.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MERGE (n:Survey {uid: list[0]})
      ON CREATE SET
        n.date = list[1],
        n.classification = list[2],
        n.department = list[3];
",
{
    batchSize: 100, iterateList:true, parallel:true, concurrency: 8
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/business_type_TO_course.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:BusinessType {name: list[0]}), (e:Course {code: list[1]})
    WITH s, e
      MERGE (s)-[:BUSINESS_TYPE_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/city_TO_learner.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:City {name: list[0]}), (e:Learner {uid: list[1]})
    WITH s, e
      MERGE (s)-[:LOCATED_IN]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/city_TO_offering.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:City {name: list[0]}), (e:Offering {uid: list[1]})
    WITH s, e
      MERGE (s)-[:OFFERED_IN]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/classification_group_TO_classification.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:ClassificationGroup {code: list[0]}), (e:Classification {code: list[1]})
    WITH s, e
      MERGE (s)-[:CLASSIFICATION_GROUP_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/classification_TO_learner.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Classification {code: list[0]}), (e:Learner {uid: list[1]})
    WITH s, e
      MERGE (s)-[:CLASSIFICATION_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/course_TO_offering.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Course {code: list[0]}), (e:Offering {uid: list[1]})
    WITH s, e
      MERGE (s)-[:COURSE_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/delivery_type_TO_course.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:DeliveryType {name: list[0]}), (e:Course {code: list[1]})
    WITH s, e
      MERGE (s)-[:DELIVERY_TYPE_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/department_TO_learner.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Department {code: list[0]}), (e:Learner {uid: list[1]})
    WITH s, e
      MERGE (s)-[:DEPARTMENT_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/instructor_TO_offering.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Instructor {name: list[0]}), (e:Offering {uid: list[1]})
    WITH s, e
      MERGE (s)-[:INSTRUCTOR_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/language_TO_offering.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Language {name: list[0]}), (e:Offering {uid: list[1]})
    WITH s, e
      MERGE (s)-[:LANGUAGE_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/leaner_TO_registration.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Learner {uid: list[0]}), (e:Registration {uid: list[1]})
    WITH s, e
      MERGE (s)-[:LEARNER_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/offering_TO_registration.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Offering {uid: list[0]}), (e:Registration {uid: list[1]})
    WITH s, e
      MERGE (s)-[:REGISTERED_FOR]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/offering_TO_survey.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Offering {uid: list[0]}), (e:Survey {uid: list[1]})
    WITH s, e
      MERGE (s)-[:SURVEYED_FOR]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/province_TO_city.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Province {name: list[0]}), (e:City {name: list[1]})
    WITH s, e
      MERGE (s)-[:PROVINCE_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/question_TO_survey.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Question {name: list[0]}), (e:Survey {uid: list[1]})
    WITH s, e, list
      MERGE (s)-[r:QUESTION_OF]->(e)
        ON CREATE SET r.answer = list[2];
",
{
    batchSize: 100, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/region_TO_province.tsv',
    {
      header: true,
      sep: 'TAB'
  	}
  ) YIELD list
  RETURN list
", "
  WITH list
    MATCH (s:Region {name: list[0]}), (e:Province {name: list[1]})
    WITH s, e
      MERGE (s)-[:REGION_OF]->(e)
",
{
    batchSize: 100, iterateList:true, parallel:false
});
