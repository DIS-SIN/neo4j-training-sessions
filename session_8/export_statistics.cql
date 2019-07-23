CALL apoc.export.csv.query(
	"MATCH (c:Course)<-[:BUSINESS_TYPE_OF]-(business_type:BusinessType)
		WHERE business_type.name IN ['Instructor-Led', 'Events']
	WITH c
		MATCH (c)-[:COURSE_OF]->(o:Offering)-[:SURVEYED_FOR]->(s:Survey)
	WITH
		DISTINCT(c) AS c,
		COLLECT(DISTINCT(o.uid)) AS offering_uid_list,
		COUNT(DISTINCT(s)) AS survey_count
	WITH
		c,
		offering_uid_list,
		survey_count
		MATCH (c)-[:COURSE_OF]->(o:Offering)-[:REGISTERED_FOR]->(r:Registration {status: 'Confirmed'})
			WHERE o.uid IN offering_uid_list
	WITH
		DISTINCT(c.code) AS course_code,
		c.title AS course_title,
		SIZE(offering_uid_list) AS number_of_offerings,
		survey_count,
		COUNT(DISTINCT(r)) AS confirmed_registration_count
	RETURN
		course_code,
		course_title,
		number_of_offerings,
		confirmed_registration_count,
		survey_count,
		ROUND(10000.0*survey_count/(1.0*confirmed_registration_count))/100.0 AS response_rate
			ORDER BY response_rate DESC;",
	'/csps/reports/classroom_survey.csv',
	{}
);

CALL apoc.export.csv.query(
	"MATCH (c:Course)<-[:BUSINESS_TYPE_OF]-(business_type:BusinessType)
		WHERE business_type.name IN ['Online']
	WITH c
		MATCH (c)-[:COURSE_OF]->(:Offering)-[:SURVEYED_FOR]->(s:Survey)
	WITH
		DISTINCT(c) AS c,
		MIN(s.date) AS earliest_start_date,
		COUNT(DISTINCT(s)) AS survey_count
	WITH
		c,
		earliest_start_date,
		survey_count
		MATCH (c)-[:COURSE_OF]->(:Offering)-[:REGISTERED_FOR]->(r:Registration {status: 'Confirmed'})
			WHERE earliest_start_date >= r.date
	WITH
		DISTINCT(c.code) AS course_code,
		c.title AS course_title,
		survey_count,
		COUNT(DISTINCT(r)) AS confirmed_registration_count
	RETURN
		course_code,
		course_title,
		confirmed_registration_count,
		survey_count,
		ROUND(10000.0*survey_count/(1.0*confirmed_registration_count))/100.0 AS response_rate
			ORDER BY response_rate DESC;",
	'/csps/reports/online_survey.csv',
	{}
);

// CALL apoc.export.csv.query(
// 	"MATCH (c:Course)<-[:BUSINESS_TYPE_OF]-(business_type:BusinessType)
// 		WHERE business_type.name IN ['Online']
// 	WITH c
// 		MATCH (c)-[:COURSE_OF]->(:Offering)-[:SURVEYED_FOR]->(s:Survey)
// 	WITH
// 		DISTINCT(c) AS c,
// 		MIN(s.date) AS earliest_start_date,
// 		COUNT(DISTINCT(s)) AS survey_count
// 	WITH
// 		c,
// 		earliest_start_date,
// 		survey_count
// 		MATCH (c)-[:COURSE_OF]->(:Offering)-[:REGISTERED_FOR]->(r:Registration {status: 'Confirmed'})
// 			WHERE earliest_start_date >= r.date - DURATION('P7D')
// 	WITH
// 		DISTINCT(c.code) AS course_code,
// 		c.title AS course_title,
// 		survey_count,
// 		COUNT(DISTINCT(r)) AS confirmed_registration_count
// 	RETURN
// 		course_code,
// 		course_title,
// 		confirmed_registration_count,
// 		survey_count,
// 		ROUND(10000.0*survey_count/(1.0*confirmed_registration_count))/100.0 AS response_rate
// 			ORDER BY response_rate DESC;",
// 	'/csps/reports/online_survey.csv',
// 	{}
// );

CALL apoc.export.csv.query(
	"MATCH (c:Course)<-[:BUSINESS_TYPE_OF]-(business_type:BusinessType)
		WHERE business_type.name IN ['Instructor-Led', 'Events']
	WITH c
		MATCH (c)-[:COURSE_OF]->(o:Offering)
	WITH c, o
		MATCH (o)-[:SURVEYED_FOR]->(s:Survey)
	WITH c, o, COUNT(DISTINCT(s)) AS number_of_surveys
	WITH c, o, number_of_surveys
		MATCH (o)-[:REGISTERED_FOR]->(r:Registration {status: 'Confirmed'})
	WITH c, o, number_of_surveys, COUNT(DISTINCT(r)) AS number_of_confirmed_registrations
	RETURN
		c.code AS course_code,
		c.title AS course_title,
		o.uid AS offering,
		number_of_confirmed_registrations,
    number_of_surveys,
		ROUND(10000.0*number_of_surveys/(1.0*number_of_confirmed_registrations))/100.0 AS response_rate
			ORDER BY course_code, offering, response_rate DESC;",
	'/csps/reports/detailed_response_rates.csv',
	{}
);
