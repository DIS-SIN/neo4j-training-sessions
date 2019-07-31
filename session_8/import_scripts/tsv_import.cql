CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/registration_data.tsv',
    {
      header: true,
      sep: 'TAB',
      mapping: {
      	course_title: {type: 'string'},
        course_code: {type: 'string'},
        event_description: {type: 'string'},
        business_type: {type: 'string'},
        delivery_type: {type: 'string'},
        offering_id: {type: 'string'},
        start_date: {type: 'string'},
        end_date: {type: 'string'},
        month: {type: 'string'},
        week: {type: 'string'},
        duration: {type: 'string'},
        offering_status: {type: 'string'},
        offering_language: {type: 'string'},
        offering_region: {type: 'string'},
        offering_province: {type: 'string'},
        offering_city: {type: 'string'},
        instructor_name: {type: 'string'},
        reg_id: {type: 'string'},
        scope: {type: 'string'},
        reg_status: {type: 'string'},
        no_show: {type: 'string'},
        reg_date: {type: 'string'},
        reg_gap: {type: 'string'},
        learner_id: {type: 'string'},
        learner_region: {type: 'string'},
        learner_province: {type: 'string'},
        learner_city: {type: 'string'},
        learner_classif_group: {type: 'string'},
        learner_classif: {type: 'string'},
        billing_dept_code: {type: 'string'},
        billing_dept_name: {type: 'string'}
      }
  	}
  ) YIELD map
  RETURN map
", "
  WITH map
    MERGE (bt:BusinessType {name: map.business_type})
    MERGE (dt:DeliveryType {name: map.delivery_type})
  	MERGE (c:Course {code: map.course_code})
      ON CREATE SET
        c.title = map.course_title,
        c.event_description = map.event_description
    MERGE (o:Offering {uid: map.offering_id})
      ON CREATE SET
        o.start_date = map.start_date,
        o.end_date = map.end_date,
        o.month = map.month,
        o.week = map.week,
        o.duration = map.duration,
        o.status = map.offering_status
    MERGE (ol:Language {uid: map.offering_language})
    MERGE (oc:City {name: map.offering_city})
    MERGE (op:Provice {name: map.offering_province})
    MERGE (or:Region {name: map.offering_region})
    MERGE (r:Registration {uid: map.reg_id})
      ON CREATE SET
        r.scope = map.scope,
        r.status = map.reg_status,
        r.no_show = map.no_show,
        r.date = map.reg_date,
        r.gap = map.reg_gap
    MERGE (l:Learner {uid: map.learner_id})
    MERGE (lc:City {name: map.learner_city})
    MERGE (lp:Provice {name: map.learner_province})
    MERGE (lr:Region {name: map.learner_region})
    MERGE (cl:Classification {code: map.learner_classif})
    MERGE (cg:ClassificationGroup {code: map.learner_classif_group})
    MERGE (d:Department {code: map.billing_dept_code})
      ON CREATE SET
        d.name = map.billing_dept_name;
",
{
    batchSize: 1000, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
    '/import/csps/registration_data.tsv',
    {
      header: true,
      sep: 'TAB',
      mapping: {
        course_title: {type: 'string'},
        course_code: {type: 'string'},
        event_description: {type: 'string'},
        business_type: {type: 'string'},
        delivery_type: {type: 'string'},
        offering_id: {type: 'string'},
        start_date: {type: 'string'},
        end_date: {type: 'string'},
        month: {type: 'string'},
        week: {type: 'string'},
        duration: {type: 'string'},
        offering_status: {type: 'string'},
        offering_language: {type: 'string'},
        offering_region: {type: 'string'},
        offering_province: {type: 'string'},
        offering_city: {type: 'string'},
        instructor_name: {type: 'string'},
        reg_id: {type: 'string'},
        scope: {type: 'string'},
        reg_status: {type: 'string'},
        no_show: {type: 'string'},
        reg_date: {type: 'string'},
        reg_gap: {type: 'string'},
        learner_id: {type: 'string'},
        learner_region: {type: 'string'},
        learner_province: {type: 'string'},
        learner_city: {type: 'string'},
        learner_classif_group: {type: 'string'},
        learner_classif: {type: 'string'},
        billing_dept_code: {type: 'string'},
        billing_dept_name: {type: 'string'}
      }
    }
  ) YIELD map
  RETURN map
", "
  WITH map
    MATCH (c:Course {code: map.course_code})
  WITH map, c
    MATCH (bt:BusinessType {name: map.business_type})
      MERGE (bt)-[:BUSINESS_TYPE_OF]->(c)
  WITH map, c
    MATCH (dt:DeliveryType {name: map.delivery_type})
      MERGE (dt)-[:DELIVERY_TYPE_OF]->(c)
  WITH map, c
    MATCH (o:Offering {uid: map.offering_id})
      MERGE (c)-[:COURSE_OF]->(o)
  WITH map, o
    MATCH (ol:Language {uid: map.offering_language}), (oc:City {name: map.offering_city}), (op:Provice {name: map.offering_province}), (or:Region {name: map.offering_region})
      MERGE (ol)-[:LANGUAGE_OF]->(o)
      MERGE (oc)-[:OFFERED_IN]->(o)
      MERGE (op)-[:PROVINCE_OF]->(oc)
      MERGE (or)-[:REGION_OF]->(op)
  WITH map, o
    MERGE (r:Registration {uid: map.reg_id})
      MERGE (o)-[:REGISTERED_FOR]->(r)
  WITH map, r
    MERGE (l:Learner {uid: map.learner_id})
      MERGE (l)-[:LEARNER_OF]->(r)
  WITH map, l
    MERGE (lc:City {name: map.learner_city})
      MERGE (lc)-[:LOCATED_IN]->(l)
    MERGE (lp:Provice {name: map.learner_province})
      MERGE (lp)-[:PROVINCE_OF]->(lc)
    MERGE (lr:Region {name: map.learner_region})
      MERGE (lr)-[:REGION_OF]->(lp)
  WITH map, l
    MERGE (cl:Classification {code: map.learner_classif})
      MERGE (cl)-[:CLASSIFICATION_OF]->(l)
    MERGE (cg:ClassificationGroup {code: map.learner_classif_group})
      MERGE (cg)-[:CLASSIFICATION_GROUP_OF]->(cl)
  WITH map, l
    MERGE (d:Department {code: map.billing_dept_code})
      MERGE (d)-[:DEPARTMENT_OF]->(l)
",
{
    batchSize: 1000, iterateList:true, parallel:false
});


CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/survey_data.tsv',
    {
      header: true,
      sep: 'TAB',
      mapping: {
        offering_id: {type: 'string'},
        offering_start_date: {type: 'string'},
        survey_id: {type: 'string'},
        short_question: {type: 'string'},
        survey_respondent_classification: {type: 'string'},
        survey_respondent_department: {type: 'string'}
      }
  	}
  ) YIELD map
  RETURN map
", "
  WITH map
    MATCH (o:Offering {uid: map.offering_id})
    MERGE (q:Question {code: map.short_question})
    MERGE (s:Surver {uid: map.survey_id})
      ON CREATE SET
        s.date = map.offering_start_date,
        s.classification = map.survey_respondent_classification,
        s.department = map.survey_respondent_department;
",
{
    batchSize: 1000, iterateList:true, parallel:false
});

CALL apoc.periodic.iterate("
  CALL apoc.load.csv(
  	'/import/csps/survey_data.tsv',
    {
      header: true,
      sep: 'TAB',
      mapping: {
        offering_id: {type: 'string'},
        offering_start_date: {type: 'string'},
        survey_id: {type: 'string'},
        short_question: {type: 'string'},
        survey_respondent_classification: {type: 'string'},
        survey_respondent_department: {type: 'string'}
      }
  	}
  ) YIELD map
  RETURN map
", "
  WITH map
    MATCH (s:Surver {uid: map.survey_id})
    WITH s
      MATCH (o:Offering {uid: map.offering_id})
      MERGE (o)-[:SURVEYED_FOR]->(s)
    WITH s
      MATCH (q:Question {code: map.short_question})
      MERGE (q)-[r:QUESTION_OF]->(s)
        ON CREATE SET r.answer = map.survey_answer;
",
{
    batchSize: 100, iterateList:true, parallel:false
});
