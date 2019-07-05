// Export course data

CALL apoc.export.json.query(
	"MATCH (c:Course)<-[:BUSINESS_TYPE_OF]-(business_type:BusinessType)
		WHERE business_type.name IN ['Instructor-Led', 'Events']
	WITH c
		MATCH (c)-[:COURSE_OF]->(o:Offering)-[:SURVEYED_FOR]->(s:Survey)
      WHERE o.start_date >= DATE('2019-04-03') AND o.start_date <= DATE('2019-04-05')
	WITH
		DISTINCT(o) AS o, c, COLLECT(DISTINCT(s)) AS survey_list
	WITH
		c, o, survey_list
		  MATCH (o)-[:REGISTERED_FOR]->(r:Registration {status: 'Confirmed'})
	WITH
		DISTINCT(o) AS o, c, survey_list, COLLECT(DISTINCT(r)) AS registration_list
	WITH
		DISTINCT(c) AS c, COLLECT([o, survey_list, registration_list]) AS osr
	RETURN
    	COLLECT([c, osr]) AS courses",
	'/csps/reports/sample_csps_dataset.json',
	{}
);

CALL apoc.export.csv.query(
	"MATCH (c:Course)<-[:BUSINESS_TYPE_OF]-(business_type:BusinessType)
		WHERE business_type.name IN ['Instructor-Led', 'Events']
	WITH c
		MATCH (c)-[:COURSE_OF]->(o:Offering)
        	WHERE o.start_date >= DATE('2019-04-03') AND o.start_date <= DATE('2019-04-05')
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
	'/csps/reports/sample_detailed_response_rates.csv',
	{}
);

CREATE CONSTRAINT ON (n:Echo) ASSERT n.uid IS UNIQUE;
