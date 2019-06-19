CREATE CONSTRAINT ON (n:MajorGroup) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:MinorGroup) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:BroadGroup) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:Occupation) ASSERT n.code IS UNIQUE;

CALL apoc.load.xls('https://www.bls.gov/soc/soc_structure_2010.xls', 'Sheet1!A14:E1434', {header: false}) YIELD list 
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
RETURN 1;

CREATE CONSTRAINT ON (n:ONetOcc) ASSERT n.code IS UNIQUE;

CALL apoc.load.csv('https://www.onetcenter.org/dl_files/database/db_23_3_text/Occupation%20Data.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS code, TRIM(apoc.convert.toString(list[1])) AS title, TRIM(apoc.convert.toString(list[2])) AS desc
	WHERE lineNo > 1
WITH code, title, desc
    MATCH (occ:Occupation {code: SUBSTRING(code, 0, 7)})
    MERGE (ooc:ONetOcc {code: code})    
        	ON CREATE SET ooc.name = title, ooc.desc = desc
    MERGE (ooc)-[:IN_OCC]->(occ)
RETURN 1;

CREATE CONSTRAINT ON (n:JobTitle) ASSERT n.code IS UNIQUE;
CREATE INDEX ON :JobTitle(name);
CREATE INDEX ON :JobTitle(abbr);

CALL apoc.load.csv('https://www.onetcenter.org/dl_files/database/db_23_3_text/Alternate%20Titles.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS code, TRIM(apoc.convert.toString(list[1])) AS title, TRIM(apoc.convert.toString(list[2])) AS short_title
	WHERE lineNo > 0 
WITH code, title, short_title, '(' + short_title + ')' AS pattern
WITH code, title, short_title, CASE WHEN title CONTAINS pattern THEN TRIM(REPLACE(title, pattern, '')) ELSE TRIM(REPLACE(REPLACE(REPLACE(title, short_title, ''), '(', ''), ')', '')) END AS norm_title
WITH code, title, short_title, norm_title
	MERGE (ooc:ONetOcc {code: code})    
	FOREACH (dummy IN CASE WHEN short_title = 'n/a' THEN [1] ELSE [] END |
		MERGE (jt:JobTitle {code: code + ':' + title})    
			ON CREATE SET jt.name = title
		MERGE (jt)-[:IN_OOC]->(ooc)
	)
	FOREACH (dummy IN CASE WHEN short_title <> 'n/a' THEN [1] ELSE [] END |
		MERGE (jt:JobTitle {code: code + ':' + title})    
			ON CREATE SET jt.name = norm_title, jt.abbr = short_title
		MERGE (jt)-[:IN_OOC]->(ooc)
	)
RETURN 1;

CREATE CONSTRAINT ON (n:UNSPSC_Segment) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:UNSPSC_Family) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:UNSPSC_Class) ASSERT n.code IS UNIQUE;
CREATE CONSTRAINT ON (n:UNSPSC_Commodity) ASSERT n.code IS UNIQUE;
CREATE INDEX ON :UNSPSC_Segment(title);
CREATE INDEX ON :UNSPSC_Family(title);
CREATE INDEX ON :UNSPSC_Class(title);
CREATE INDEX ON :UNSPSC_Commodity(title);

CALL apoc.load.csv('https://www.onetcenter.org/dl_files/database/db_23_3_text/UNSPSC%20Reference.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS commodity_code, TRIM(apoc.convert.toString(list[1])) AS commodity_title, TRIM(apoc.convert.toString(list[2])) AS class_code, TRIM(apoc.convert.toString(list[3])) AS class_title, TRIM(apoc.convert.toString(list[4])) AS family_code, TRIM(apoc.convert.toString(list[5])) AS family_title, TRIM(apoc.convert.toString(list[6])) AS segment_code, TRIM(apoc.convert.toString(list[7])) AS segment_title
	WHERE lineNo > 1
WITH commodity_code, commodity_title, class_code, class_title, family_code, family_title, segment_code, segment_title
	MERGE (seg:UNSPSC_Segment {code: segment_code})
		ON CREATE SET seg.title = segment_title
	MERGE (fam:UNSPSC_Family {code: family_code})
		ON CREATE SET fam.title = family_title
	MERGE (cls:UNSPSC_Class {code: class_code})
		ON CREATE SET cls.title = class_title
	MERGE (com:UNSPSC_Commodity {code: commodity_title})
		ON CREATE SET com.title = commodity_title
	MERGE (fam)-[:IN_SEG]->(seg)
	MERGE (cls)-[:IN_FAM]->(fam)
	MERGE (com)-[:IN_CLS]->(cls)
RETURN 1;

CALL apoc.load.csv('https://www.onetcenter.org/dl_files/database/db_23_3_text/UNSPSC%20Reference.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
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
RETURN 1;

CREATE CONSTRAINT ON (n:TechSkill) ASSERT n.name IS UNIQUE;

CALL apoc.load.csv('https://www.onetcenter.org/dl_files/database/db_23_3_text/Technology%20Skills.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS onet_occ_code, TRIM(apoc.convert.toString(list[1])) AS tech_skill_name, TRIM(apoc.convert.toString(list[2])) AS commodity_code, TRIM(apoc.convert.toString(list[4])) AS is_hot
	WHERE lineNo > 1
WITH onet_occ_code, tech_skill, commodity_code, is_hot
	MATCH (ooc:ONetOcc {code: onet_occ_code})
	MERGE (ts:TechSkill {name: tech_skill_name})
		ON CREATE SET ts.is_hot = is_hot
	MERGE (com:UNSPSC_Commodity {code: commodity_code})
	MERGE (ooc)-[:HAS_TECH_SKILL]->(ts)
	MERGE (ts)-[:SKILL_OF_COM]->(com)
RETURN 1;

CREATE CONSTRAINT ON (n:Tool) ASSERT n.name IS UNIQUE;
CALL apoc.load.csv('https://www.onetcenter.org/dl_files/database/db_23_3_text/Tools%20Used.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS onet_occ_code, TRIM(apoc.convert.toString(list[1])) AS tool_name, TRIM(apoc.convert.toString(list[2])) AS commodity_code
	WHERE lineNo > 1
WITH onet_occ_code, tool_name, commodity_code
	MATCH (ooc:ONetOcc {code: onet_occ_code})
	MERGE (tl:Tool {name: tool_name})
	MERGE (com:UNSPSC_Commodity {code: commodity_code})
	MERGE (ooc)-[:USES_TOOL]->(ts)
	MERGE (tl)-[:TOOL_OF_COM]->(com)
RETURN 1;

