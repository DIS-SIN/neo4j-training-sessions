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
// Load Standard Occupation Classification structure data
//
CALL apoc.load.xls(
    'https://www.bls.gov/soc/soc_structure_2010.xls', 'Sheet1!A14:E1434', 
    { header: false }
) YIELD list 
WITH COLLECT(list) AS row_list
WITH REDUCE(l=[], e IN row_list | 
	CASE 
        WHEN (e[0] IS NOT NULL) THEN l + [e] 
        WHEN (e[0] IS NULL AND e[1] IS NOT NULL) THEN l + [ [l[SIZE(l)-1][0], e[1], e[2], e[3], e[4]] ]
        WHEN (e[0] IS NULL AND e[1] IS NULL AND e[2] IS NOT NULL) THEN l + [ [l[SIZE(l)-1][0], l[SIZE(l)-1][1], e[2], e[3], e[4]] ]
        WHEN (e[0] IS NULL AND e[1] IS NULL AND e[2] IS NULL AND e[3] IS NOT NULL) THEN l + [ [l[SIZE(l)-1][0], l[SIZE(l)-1][1], l[SIZE(l)-1][2], e[3], e[4]] ]
        ELSE l + [ [l[SIZE(l)-1][0], l[SIZE(l)-1][1], l[SIZE(l)-1][2], l[SIZE(l)-1][3], e[4]] ]
	END) AS enhanced_row_list
WITH enhanced_row_list UNWIND enhanced_row_list AS row
WITH row 
	FOREACH (dummy IN CASE WHEN row[1] IS NULL THEN [1] ELSE [] END |
    	MERGE (mjg:MajorGroup {code: TRIM(row[0])})
        	ON CREATE SET mjg.name = TRIM(row[4])
    )
	FOREACH (dummy IN CASE WHEN row[1] IS NOT NULL AND row[2] IS NULL THEN [1] ELSE [] END |
    	MERGE (mjg:MajorGroup {code: TRIM(row[0])})
    	MERGE (mng:MinorGroup {code: TRIM(row[1])})
			ON CREATE SET mng.name = TRIM(row[4])
		MERGE (mng)-[:IN_MJG]->(mjg)
    )
	FOREACH (dummy IN CASE WHEN row[1] IS NOT NULL AND row[2] IS NOT NULL AND row[3] IS NULL THEN [1] ELSE [] END |
    	MERGE (mng:MinorGroup {code: TRIM(row[1])})
    	MERGE (bdg:BroadGroup {code: TRIM(row[2])})
			ON CREATE SET bdg.name = TRIM(row[4])
		MERGE (bdg)-[:IN_MNG]->(mng)
    )
	FOREACH (dummy IN CASE WHEN row[1] IS NOT NULL AND row[2] IS NOT NULL AND row[3] IS NOT NULL THEN [1] ELSE [] END |
    	MERGE (bdg:BroadGroup {code: TRIM(row[2])})
    	MERGE (occ:Occupation {code: TRIM(row[3])})
			ON CREATE SET occ.name = TRIM(row[4])
		MERGE (occ)-[:IN_BDG]->(bdg)
    )
RETURN COUNT(row) AS number_of_rows_processed;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (m:MajorGroup {code: "15-0000"}) RETURN m;
// MATCH (m:MajorGroup {code: "15-0000"})<-[:IN_MJG]-(n:MinorGroup)<-[:IN_MNG]-(b:BroadGroup)<-[:IN_BDG]-(o:Occupation) RETURN m, n, b, o;
// MATCH (m) RETURN m;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load O*NET Occupation Data
//
CALL apoc.load.csv(
    'https://www.onetcenter.org/dl_files/database/db_23_3_text/Occupation%20Data.txt', 
    {
        header: false, 
        sep: 'TAB'
    }
) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS code, TRIM(apoc.convert.toString(list[1])) AS title, TRIM(apoc.convert.toString(list[2])) AS desc
	WHERE lineNo > 1
WITH code, title, desc
    MATCH (occ:Occupation {code: SUBSTRING(code, 0, 7)})
    MERGE (ooc:ONetOcc {code: code})    
        	ON CREATE SET ooc.name = title, ooc.desc = desc
    MERGE (ooc)-[:IN_OCC]->(occ)
RETURN COUNT(code) AS number_of_codes_processed;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (oo:ONetOcc {code: "15-1131.00"}) RETURN oo;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load O*NET Alternate Titles
//
CALL apoc.load.csv(
    'https://www.onetcenter.org/dl_files/database/db_23_3_text/Alternate%20Titles.txt', 
    {
        header: false, sep: 'TAB'
    }
) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS code, TRIM(apoc.convert.toString(list[1])) AS title, TRIM(apoc.convert.toString(list[2])) AS short_title
	WHERE lineNo > 0 
WITH code, title, short_title, '(' + short_title + ')' AS pattern
WITH code, title, short_title, CASE WHEN title CONTAINS pattern THEN TRIM(REPLACE(title, pattern, '')) ELSE TRIM(REPLACE(REPLACE(REPLACE(title, short_title, ''), '(', ''), ')', '')) END AS norm_title
WITH code, title, short_title, norm_title
	MERGE (ooc:ONetOcc {code: code})    
	FOREACH (dummy IN CASE WHEN short_title = 'n/a' THEN [1] ELSE [] END |
		MERGE (jt:JobTitle {code: title})    
		MERGE (jt)-[:IN_OOC]->(ooc)
	)
	FOREACH (dummy IN CASE WHEN short_title <> 'n/a' THEN [1] ELSE [] END |
		MERGE (jt:JobTitle {code: code + ':' + title})    
			ON CREATE SET jt.name = norm_title, jt.abbr = short_title
		MERGE (jt)-[:IN_OOC]->(ooc)
	)
RETURN COUNT(title) AS number_of_titles_processed;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load UNSPSC Reference data
//
CALL apoc.load.csv(
    'https://www.onetcenter.org/dl_files/database/db_23_3_text/UNSPSC%20Reference.txt', 
    {
        header: false, 
        sep: 'TAB'
    }
) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS commodity_code, TRIM(apoc.convert.toString(list[1])) AS commodity_title, TRIM(apoc.convert.toString(list[2])) AS class_code, TRIM(apoc.convert.toString(list[3])) AS class_title, TRIM(apoc.convert.toString(list[4])) AS family_code, TRIM(apoc.convert.toString(list[5])) AS family_title, TRIM(apoc.convert.toString(list[6])) AS segment_code, TRIM(apoc.convert.toString(list[7])) AS segment_title
	WHERE lineNo > 1
WITH commodity_code, commodity_title, class_code, class_title, family_code, family_title, segment_code, segment_title
	MERGE (seg:UNSPSC_Segment {code: segment_code})
		ON CREATE SET seg.title = segment_title
	MERGE (fam:UNSPSC_Family {code: family_code})
		ON CREATE SET fam.title = family_title
	MERGE (cls:UNSPSC_Class {code: class_code})
		ON CREATE SET cls.title = class_title
	MERGE (com:UNSPSC_Commodity {code: commodity_code})
		ON CREATE SET com.title = commodity_title
	MERGE (fam)-[:IN_SEG]->(seg)
	MERGE (cls)-[:IN_FAM]->(fam)
	MERGE (com)-[:IN_CLS]->(cls)
RETURN COUNT(commodity_code) AS number_of_codes_processed;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (seg:UNSPSC_Segment)<-[:IN_SEG]-(fam:UNSPSC_Family)<-[:IN_FAM]-(cls:UNSPSC_Class)<-[:IN_CLS]-(com:UNSPSC_Commodity) RETURN seg, fam, cls, com;
// MATCH (seg:UNSPSC_Segment {title: "Tools and General Machinery"})<-[:IN_SEG]-(fam:UNSPSC_Family)<-[:IN_FAM]-(cls:UNSPSC_Class)<-[:IN_CLS]-(com:UNSPSC_Commodity) RETURN seg, fam, cls, com
// MATCH (seg:UNSPSC_Segment {title: "Tools and General Machinery"})<-[:IN_SEG]-(fam:UNSPSC_Family {title: "Hand tools"})<-[:IN_FAM]-(cls:UNSPSC_Class)<-[:IN_CLS]-(com:UNSPSC_Commodity) RETURN seg, fam, cls, com
// MATCH (seg:UNSPSC_Segment {title: "Tools and General Machinery"})<-[:IN_SEG]-(fam:UNSPSC_Family {title: "Hand tools"})<-[:IN_FAM]-(cls:UNSPSC_Class {title: "Masonry and concrete tools"})<-[:IN_CLS]-(com:UNSPSC_Commodity) RETURN seg, fam, cls, com
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load UNSPSC Technology Skill data
//
CALL apoc.load.csv(
    'https://www.onetcenter.org/dl_files/database/db_23_3_text/Technology%20Skills.txt', 
    {
        header: false, 
        sep: 'TAB'
    }
) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS onet_occ_code, TRIM(apoc.convert.toString(list[1])) AS tech_skill_name, TRIM(apoc.convert.toString(list[2])) AS commodity_code, TRIM(apoc.convert.toString(list[4])) AS is_hot
	WHERE lineNo > 1
WITH onet_occ_code, tech_skill_name, commodity_code, is_hot
	MATCH (ooc:ONetOcc {code: onet_occ_code}), (com:UNSPSC_Commodity {code: commodity_code})
WITH ooc, com, tech_skill_name, is_hot
	MERGE (ts:TechSkill {name: tech_skill_name})
		ON CREATE SET ts.is_hot = is_hot
	MERGE (ooc)-[:HAS_TECH_SKILL]->(ts)
	MERGE (ts)-[:SKILL_OF_COM]->(com)
RETURN COUNT(tech_skill_name) AS number_of_skills_processed;
//
//
//
CALL apoc.load.csv(
    'https://www.onetcenter.org/dl_files/database/db_23_3_text/Tools%20Used.txt', 
    {
        header: false, 
        sep: 'TAB', 
        ignoreQuotations: true
    }
) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS onet_occ_code, TRIM(apoc.convert.toString(list[1])) AS tool_name, TRIM(apoc.convert.toString(list[2])) AS commodity_code
	WHERE lineNo > 1
WITH onet_occ_code, tool_name, commodity_code
	MATCH (ooc:ONetOcc {code: onet_occ_code}), (com:UNSPSC_Commodity {code: commodity_code})
WITH ooc, com, tool_name    
	MERGE (tl:ToolUsed {name: tool_name})
	MERGE (ooc)-[:USES_TOOL]->(tl)
	MERGE (tl)-[:TOOL_OF_COM]->(com)
RETURN COUNT(tool_name) AS number_of_tools_processed;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (oo:ONetOcc {code: "15-1131.00"})-[]-(n) RETURN oo, n;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load User data from Kaggle dataset
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.csv('/kaggle/job-recommendation/users.tsv', 
        {
            header: true, 
            sep: 'TAB', 
            ignoreQuotations: true,
            mapping: {
                UserID: {type: 'int'}, 
                Split: {type: 'string'}, 
                City: {type: 'string'}, 
                State: {type: 'string'},
                Country: {type: 'string'}, 
                ZipCode: {type: 'string'}, 
                DegreeType: {type: 'string'}, 
                Major: {type: 'string'}, 
                GraduationDate: {type: 'string'}, 
                WorkHistoryCount: {type: 'int'}, 
                TotalYearsExperience: {type: 'int'}, 
                CurrentlyEmployed: {type: 'string'}, 
                ManagedOthers: {type: 'string'}, 
                ManagedHowMany: {type: 'int'}
            }
        }
    ) 
    YIELD map
 ", "
    WITH map
        MERGE (u:User {uid: map.UserID})
            ON CREATE 
                SET 
                    u.type = CASE WHEN map.Split = 'Train' THEN false ELSE true END,
                    u.work_history_count = map.WorkHistoryCount,
                    u.total_years_experience = map.TotalYearsExperience,
                    u.currently_employed = CASE WHEN map.CurrentlyEmployed = 'Yes' THEN true ELSE false END,
                    u.managed_others = CASE WHEN map.ManagedOthers = 'Yes' THEN true ELSE false END,
                    u.managed_how_many = map.ManagedHowMany

    WITH map, u
        FOREACH (dummy IN CASE WHEN SIZE(TRIM(map.GraduationDate)) > 0 THEN [1] ELSE [] END |
            SET u.graduated = DATE(SUBSTRING(TRIM(map.GraduationDate), 0, 10))
        )
        FOREACH (dummy IN CASE WHEN SIZE(TRIM(map.DegreeType)) > 0 THEN [1] ELSE [] END |
            MERGE (dt:DegreeType {name: TRIM(REPLACE(map.DegreeType, '\\\'s', ''))})
            MERGE (u)-[:HAS_DEGREE]->(dt)
        )
        FOREACH (dummy IN CASE WHEN SIZE(TRIM(map.Major)) > 0 THEN [1] ELSE [] END |
            MERGE (mj:EducationMajor {name: TRIM(map.Major)})
            MERGE (u)-[:HAS_MAJOR]->(mj)
        )
        FOREACH (dummy IN CASE WHEN SIZE(TRIM(map.City)) > 0 THEN [1] ELSE [] END |
            MERGE (ctr:Country {code: TRIM(map.Country)})
            MERGE (st:State {uid: TRIM(map.Country) + '-' + TRIM(map.State)})
                ON CREATE SET st.code = TRIM(map.State)
            MERGE (cit:City {uid: TRIM(map.Country) + '-' + TRIM(map.State) + '-' + TRIM(map.City)})
                ON CREATE SET cit.name = TRIM(map.City)
            MERGE (zc:ZipCode {code: TRIM(map.ZipCode)})
            MERGE (st)-[:IN_COUNTRY]->(ctr)
            MERGE (cit)-[:IN_STATE]->(st)
            MERGE (u)-[:IN_CITY]->(cit)
            MERGE (u)-[:AT_ZIP]->(zc)
        )
    RETURN 1;
",
{
    batchSize:1000, iterateList:true, parallel:false
});
//
MATCH (u:User) 
    RETURN COUNT(u) AS number_of_users_processed;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (c:Country) RETURN COUNT(c);
// MATCH (c:Country) RETURN c.code;
// MATCH (s:State) RETURN COUNT(s);
// MATCH (s:State) RETURN s.code;
// MATCH (c:City) RETURN COUNT(c);
// MATCH (u:User) RETURN COUNT(u);
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load User (job) history data from Kaggle dataset
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.csv('/kaggle/job-recommendation/user_history.tsv', 
        {
            header: true, 
            sep: 'TAB', 
            ignoreQuotations: true,
            mapping: {
                UserID: {type: 'int'}, 
                JobTitle: {type: 'string'}
            }
        }
    ) 
    YIELD map
    WITH map, TRIM(map.JobTitle) AS job_title
    WITH map, job_title WHERE SIZE(job_title) >= 3
    RETURN map, job_title
 ", "
    WITH map, job_title
        MERGE (u:User {uid: map.UserID})
            SET u.history = CASE WHEN u.history IS NULL THEN [job_title] ELSE u.history + [job_title] END
    RETURN 1;
",
{
    batchSize:1000, iterateList:true, parallel:false
});
//
MATCH (u:User) 
    RETURN SUM(SIZE(u.history)) AS number_of_user_history_entries_processed;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (u:User {uid:72}) RETURN u.history;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (j:Job) RETURN COUNT(j);
// 0
//
// MATCH (c:Country) RETURN COUNT(c);
// 120
//
// MATCH (s:State) RETURN COUNT(s);
// 392
//
// MATCH (c:City) RETURN COUNT(c);
// 15,206
//
// MATCH (zc:ZipCode) RETURN COUNT(zc);
// 21,836
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load (cleanup) Job data from Kaggle dataset
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.csv('/kaggle/job-recommendation/jobs_simplified.tsv', 
        {
            header: true, 
            sep: 'TAB', 
            ignoreQuotations: true,
            mapping: {
                JobID: {type: 'int'}, 
                Title: {type: 'string'}
            }
        }
    ) 
    YIELD map
 ", "
    WITH map
        MERGE (j:Job {uid: map.JobID})
            ON CREATE 
                SET 
                    j.title = TRIM(map.Title),
                    j.city = TRIM(map.City),
                    j.state = TRIM(map.State),
                    j.country = TRIM(map.Country),
                    j.zip_code = TRIM(map.Zip5)
    RETURN 1;
",
{
    batchSize:1000, iterateList:true, parallel:true, concurrency: 8
});
//
MATCH (j:Job)
    RETURN COUNT(j) AS number_of_jobs_processed;
//
//
//
CALL apoc.periodic.iterate(
"
    MATCH (j:Job)
    RETURN j
", "
    WITH j
        FOREACH (dummy IN CASE WHEN SIZE(j.country) > 0 THEN [1] ELSE [] END |
            MERGE (ctr:Country {code: j.country})
        )
    RETURN 1;
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (c:Country)
    RETURN COUNT(c) AS total_number_of_countries;
//
//
//
CALL apoc.periodic.iterate(
"
    MATCH (j:Job)
    RETURN j
", "
    WITH j
        FOREACH (dummy IN CASE WHEN SIZE(j.state) > 0 THEN [1] ELSE [] END |
            MERGE (ctr:Country {code: j.country})
            MERGE (st:State {uid: j.country + '-' + j.state})
                ON CREATE SET st.code = j.state
            MERGE (st)-[:IN_COUNTRY]->(ctr)
        )
    RETURN 1;
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (s:State)
    RETURN COUNT(s) AS total_number_of_states;
//
//
//
CALL apoc.periodic.iterate(
"
    MATCH (j:Job)
    RETURN j
", "
    WITH j
        FOREACH (dummy IN CASE WHEN SIZE(j.city) > 0 THEN [1] ELSE [] END |
            MERGE (st:State {uid: j.country + '-' + j.state})
            MERGE (cit:City {uid: j.country + '-' + j.state + '-' + j.city})
                ON CREATE SET cit.name = j.city
            MERGE (cit)-[:IN_STATE]->(st)
        )
    RETURN 1;
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (c:City)
    RETURN COUNT(c) AS total_number_of_cities;
//
//
//
CALL apoc.periodic.iterate(
"
    MATCH (j:Job)
    RETURN j
", "
    WITH j
        FOREACH (dummy IN CASE WHEN SIZE(j.city) > 0 THEN [1] ELSE [] END |
            MERGE (cit:City {uid: j.country + '-' + j.state + '-' + j.city})
            MERGE (j)-[:IN_CITY]->(cit)
        )
        FOREACH (dummy IN CASE WHEN SIZE(j.zip_code) > 0 THEN [1] ELSE [] END |
            MERGE (zc:ZipCode {code: j.zip_code})
            MERGE (j)-[:AT_ZIP]->(zc)
        )
    RETURN 1;
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (zc:ZipCode)
    RETURN COUNT(zc) AS total_number_of_zip_codes;
//
//
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.csv('/kaggle/job-recommendation/apps.tsv', 
        {
            header: true, 
            sep: 'TAB', 
            ignoreQuotations: true,
            mapping: {
                UserID: {type: 'int'}, 
                JobID: {type: 'int'}
            }
        }
    ) 
    YIELD map
 ", "
    WITH map
        MERGE (u:User {uid: map.UserID})
        MERGE (j:Job {uid: map.JobID})
        MERGE (u)-[:APPLIED]->(j)
    RETURN 1;
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (:User)-[r:APPLIED]->(:Job)
    RETURN COUNT(r) AS total_number_of_job_applications;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// For visualization, use the below in Neo4j browser:
//
// MATCH (j:Job) RETURN COUNT(j);
// 1,092,096
//
// MATCH (c:Country) RETURN COUNT(c);
// 135
//
// MATCH (s:State) RETURN COUNT(s);
// 408
//
// MATCH (c:City) RETURN COUNT(c);
// 20,823
//
// MATCH (zc:ZipCode) RETURN COUNT(zc);
// ?
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// NLP-ing job titles & store lemmatized, stemed key phrases
//
CALL apoc.periodic.iterate(
"
    MATCH (jt:JobTitle) 
    RETURN jt 
","
    WITH jt, COLLECT([jt.code, jt.code]) AS json_data
        CALL apoc.load.jsonParams('http://host.docker.internal:8004/extract', {}, apoc.convert.toJson(json_data)) 
        YIELD value
    WITH jt, value.result AS uid_kpl_list
    WITH jt, uid_kpl_list 
        UNWIND uid_kpl_list AS uid_kpl
    WITH jt, uid_kpl[1] AS kp_list
    WITH jt, REDUCE(l=[], e IN kp_list | l + e) AS kp_list
    WITH jt, apoc.convert.toJson(kp_list) AS j_kp_list, REDUCE(k='', e IN apoc.coll.sort(kp_list) | CASE WHEN SIZE(k) = 0 THEN e ELSE k + '-' + e END) AS j_lst_code
        SET jt.kp_list = j_kp_list, jt.lst_code = j_lst_code
",
{
    batchSize:1000, iterateList:true, parallel:true, concurrency: 8
});
//
MATCH (jt:JobTitle)
    WHERE EXISTS(jt.kp_list) AND SIZE(jt.kp_list) > 0
RETURN COUNT(jt) AS total_number_of_job_titles_processed;
//
//
// Persist lemmatized, stemed key phrases as separate nodes/relationships
//
CALL apoc.periodic.iterate(
"
    MATCH (jt:JobTitle) 
    WITH jt 
        WHERE EXISTS(jt.kp_list)
    RETURN jt    
","
    WITH jt, apoc.convert.fromJsonList(jt.kp_list) AS kp_list
        MERGE (lst:LSTitle {code: jt.lst_code})
            MERGE (jt)-[:J_LST]->(lst)
        FOREACH (w IN kp_list |
            MERGE (lsw:LSWord {c: w})
                ON CREATE SET lsw.f = 1
                ON MATCH SET lsw.f = lsw.f + 1
            MERGE (lst)-[:HAS_LSW]->(lsw)
        )
    RETURN COUNT(jt)
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (:JobTitle)-[r:J_LST]->(:LSTitle)
RETURN COUNT(r) AS total_number_of_words_extracted_from_job_titles;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// NLP-ing Job add's job titles & store lemmatized, stemed key phrases
//
CALL apoc.periodic.iterate(
"
    MATCH (j:Job) 
    WITH j
        WHERE EXISTS(j.title) AND SIZE(j.title) > 0
    RETURN j
","
    WITH j, COLLECT([j.uid, j.title]) AS json_data
        CALL apoc.load.jsonParams('http://host.docker.internal:8004/extract', {}, apoc.convert.toJson(json_data)) 
        YIELD value
    WITH j, value.result AS uid_kpl_list
    WITH j, uid_kpl_list 
        UNWIND uid_kpl_list AS uid_kpl
    WITH j, uid_kpl[1] AS kp_list
    WITH j, REDUCE(l=[], e IN kp_list | l + e) AS kp_list
    WITH j, apoc.convert.toJson(kp_list) AS j_kp_list, REDUCE(k='', e IN apoc.coll.sort(kp_list) | CASE WHEN SIZE(k) = 0 THEN e ELSE k + '-' + e END) AS j_lst_code
        SET j.kp_list = j_kp_list, j.lst_code = j_lst_code
",
{
    batchSize:1000, iterateList:true, parallel:true, concurrency: 8
});
//
MATCH (j:Job)
    WHERE EXISTS(j.kp_list) AND SIZE(j.kp_list) > 0
RETURN COUNT(j.kp_list) AS total_number_of_ad_job_titles_processed;
//
//
// Persist lemmatized, stemed key phrases as separate nodes/relationships
//
CALL apoc.periodic.iterate(
"
    MATCH (j:Job) 
    WITH j 
        WHERE EXISTS(j.kp_list) AND SIZE(j.kp_list) > 0
    RETURN j
","
    WITH j, apoc.convert.fromJsonList(j.kp_list) AS kp_list
        MERGE (lst:LSTitle {code: j.lst_code})
            MERGE (j)-[:A_LST]->(lst)
        FOREACH (w IN kp_list |
            MERGE (lsw:LSWord {c: w})
                ON CREATE SET lsw.f = 1
                ON MATCH SET lsw.f = lsw.f + 1
            MERGE (lst)-[:HAS_LSW]->(lsw)
        )
    RETURN COUNT(j)
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (:Job)-[r:A_LST]->(:LSTitle)
RETURN COUNT(r) AS total_number_of_words_extracted_from_ad_job_titles;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// NLP-ing User's job titles & store lemmatized, stemed key phrases
//
CALL apoc.periodic.iterate(
"
    MATCH (u:User) 
    WITH u
        WHERE EXISTS(u.history) AND SIZE(u.history) > 0
    RETURN u
","
    WITH u
        UNWIND u.history AS job_title
    WITH u, COLLECT([u.uid, job_title]) AS json_data
        CALL apoc.load.jsonParams('http://host.docker.internal:8004/extract', {}, apoc.convert.toJson(json_data)) 
        YIELD value
    WITH u, value.result AS uid_kpl_list
    WITH u, uid_kpl_list 
        UNWIND uid_kpl_list AS uid_kpl
    WITH u, uid_kpl[1] AS kp_list
    WITH u, REDUCE(l=[], e IN kp_list | l + e) AS kp_list
    WITH u, apoc.convert.toJson(kp_list) AS j_kp_list, REDUCE(k='', e IN apoc.coll.sort(kp_list) | CASE WHEN SIZE(k) = 0 THEN e ELSE k + '-' + e END) AS j_lst_code
        SET u.jt_kp_list = CASE WHEN u.jt_kp_list IS NULL THEN [j_kp_list] ELSE u.jt_kp_list + [j_kp_list] END
        SET u.jt_ls_list = CASE WHEN u.jt_ls_list IS NULL THEN [j_lst_code] ELSE u.jt_ls_list + [j_lst_code] END
",
{
    batchSize:1000, iterateList:true, parallel:true, concurrency: 8
});
//
MATCH (u:User)
    WHERE EXISTS(u.jt_kp_list) AND SIZE(u.jt_kp_list) > 0
RETURN SUM(SIZE(u.jt_kp_list)) AS total_number_of_user_job_titles_processed;
//
//
// Persist lemmatized, stemed key phrases as separate nodes/relationships
//
CALL apoc.periodic.iterate(
"
    MATCH (u:User) 
    WITH u
        WHERE EXISTS(u.jt_kp_list) AND SIZE(u.jt_kp_list) > 0
    RETURN u
","
    WITH u, REDUCE(l=[], e IN apoc.coll.zip(u.jt_kp_list, u.jt_ls_list) | CASE WHEN SIZE(l) = 0 THEN [[0, e]] ELSE l + [[l[SIZE(l)-1][0]+1, e]] END) AS jt_kp_ls_list
    WITH u, jt_kp_ls_list
        UNWIND jt_kp_ls_list AS ij_kp_ls_list
    WITH u, ij_kp_ls_list[0] AS idx, apoc.convert.fromJsonList(ij_kp_ls_list[1][0]) AS kp_list, ij_kp_ls_list[1][1] AS lst_code
        MERGE (lst:LSTitle {code: lst_code})
            MERGE (u)-[:U_LST {i: idx}]->(lst)
        FOREACH (w IN kp_list |
            MERGE (lsw:LSWord {c: w})
                ON CREATE SET lsw.f = 1
                ON MATCH SET lsw.f = lsw.f + 1
            MERGE (lst)-[:HAS_LSW]->(lsw)
        )
    RETURN COUNT(u)
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (:User)-[r:U_LST]->(:LSTitle)
RETURN COUNT(r) AS total_number_of_words_extracted_from_user_job_titles;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Connect transitions from User's last job to applied Job
// Note that it is done for only user with `Train` type 
//
CALL apoc.periodic.iterate(
"
    MATCH (user:User)
    WITH user
        WHERE NOT(user.type) AND EXISTS(user.history) AND SIZE(user.history) > 0
    WITH user
    	MATCH (user)-[:U_LST {i: SIZE(user.history)-1}]->(u_lst:LSTitle)
    RETURN user, u_lst
","
    WITH user, u_lst
        MATCH (user)-[:APPLIED]-(job:Job)-[:A_LST]->(j_lst:LSTitle)
    WITH u_lst, j_lst
        MERGE (u_lst)-[r:A_NEXT]->(j_lst)
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (:LSTitle)-[r:A_NEXT]->(:LSTitle)
RETURN COUNT(r) AS total_number_of_transitions_to_applied_jobs;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Connect transitions between User's jobs
// Note that it is done for all users
//
CALL apoc.periodic.iterate(
"
    MATCH (user:User)
	WITH user
        WHERE EXISTS(user.history) AND SIZE(user.history) > 1
    WITH user
    	MATCH (user)-[r:U_LST]->(u_lst:LSTitle)
	WITH user, r.i AS ith, u_lst ORDER BY ith
    WITH user, COLLECT(u_lst) AS job_list
    WITH user, apoc.coll.zip(REVERSE(TAIL(REVERSE(job_list))), TAIL(job_list)) AS pair_list
    RETURN user, pair_list
","        
    WITH user, pair_list
    	UNWIND pair_list AS pair
    WITH user, pair[0] AS s, pair[1] AS d
        MERGE (s)-[r:NEXT]->(d)
			ON CREATE SET r.users = [user.uid]
			ON MATCH SET r.users = CASE WHEN NOT(user.uid IN r.users) THEN r.users + [user.uid] ELSE r.users END
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH ()-[r:NEXT]->()
RETURN COUNT(r) AS total_number_of_user_job_transitions;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Label all LSTitle that has direct reference from JobTitle
//
CALL apoc.periodic.iterate(
"
    MATCH (lst:LSTitle)
		WHERE SIZE((lst)<-[:J_LST]-(:JobTitle)) > 0
    RETURN lst
","        
	WITH lst
    	SET lst:JT
",
{
    batchSize:1000, iterateList:true, parallel:true, concurrency: 8
});
//
MATCH (lst:LSTitle)
RETURN COUNT(lst) AS total_number_of_lemma_stem_titles;
//
MATCH (lst:LSTitle:JT)
RETURN COUNT(lst) AS total_number_of_lemma_stem_titles_with_job_title_reference;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Connects all LSTitle that does not have direct reference from JobTitle
//
CALL apoc.periodic.iterate(
"
    MATCH (lst:LSTitle)
    	WHERE NOT('JT' IN LABELS(lst))
    RETURN lst
"," 
    WITH lst
        MATCH (lst)-[:HAS_LSW]->(w:LSWord)<-[:HAS_LSW]-(j_lst:LSTitle:JT)
	WITH DISTINCT(j_lst) AS j_lst, lst, COUNT(DISTINCT(w)) AS wc
	WITH lst, j_lst, wc
		WHERE SIZE((j_lst)-[:HAS_LSW]->()) = wc
	WITH lst, COLLECT([[j_lst], wc]) AS match_lst_list
	WITH lst, REDUCE(l=NULL, e IN match_lst_list | CASE WHEN l IS NULL THEN e WHEN l IS NOT NULL AND l[1] < e[1] THEN e WHEN l IS NOT NULL AND l[1] = e[1] THEN [l[0]+[e[0][0]], l[1]]  ELSE l END)[0] AS best_match_list
	WITH lst, best_match_list
    	UNWIND best_match_list AS jt_lst
	WITH lst, jt_lst
    	MERGE (lst)-[:BEST_MATCH]->(jt_lst)
",
{
    batchSize:100, iterateList:true, parallel:false
});
//
MATCH (lst:LSTitle)
	WHERE NOT('JT' IN LABELS(lst)) AND SIZE((lst)-[:BEST_MATCH]->()) = 0
RETURN COUNT(lst) AS total_number_of_unmatched_titles;
//
MATCH ()-[r:BEST_MATCH]->()
RETURN COUNT(r) AS total_number_of_best_matches_for_unreferenced_job_titles;
//
////////////////////////////////////////////////////////////////////////
