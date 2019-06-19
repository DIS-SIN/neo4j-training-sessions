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

CALL apoc.load.csv('/onet/Occupation%20Data.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
WITH lineNo, TRIM(apoc.convert.toString(list[0])) AS code, TRIM(apoc.convert.toString(list[1])) AS title, TRIM(apoc.convert.toString(list[2])) AS desc
	WHERE lineNo > 1
WITH code, title, desc
    MATCH (occ:Occupation {code: SUBSTRING(code, 0, 7)})
    MERGE (ooc:ONetOcc {code: code})    
        	ON CREATE SET ooc.name = title, ooc.desc = desc
    MERGE (ooc)-[:IN_OCC]->(occ)
RETURN 1;

CREATE CONSTRAINT ON (n:JobTitle) ASSERT n.code IS UNIQUE;

CALL apoc.load.csv('/onet/Alternate%20Titles.txt', {header: false, sep: 'TAB'}) YIELD lineNo, list
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