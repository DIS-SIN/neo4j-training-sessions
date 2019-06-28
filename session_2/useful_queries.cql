MATCH (mjg:MajorGroup)<-[r1:IN_MJG]-(mng:MinorGroup)<-[r2:IN_MNG]-(bdg:BroadGroup)<-[r3:IN_BDG]-(occ:Occupation)
RETURN mjg, r1, mng, r2, bdg, r3, occ

MATCH (mjg:MajorGroup {name: "Computer and Mathematical Occupations"})<-[r1:IN_MJG]-(mng:MinorGroup)<-[r2:IN_MNG]-(bdg:BroadGroup)<-[r3:IN_BDG]-(occ:Occupation)
RETURN mjg, r1, mng, r2, bdg, r3, occ

MATCH (mjg:MajorGroup {name: "Computer and Mathematical Occupations"})<-[r1:IN_MJG]-(mng:MinorGroup)<-[r2:IN_MNG]-(bdg:BroadGroup {name: "Software Developers and Programmers"})<-[r3:IN_BDG]-(occ:Occupation)<-[r4:IN_OCC]-(onet_occ:ONetOcc)<-[r5:IN_OOC]-(job_title:JobTitle)
RETURN mjg, r1, mng, r2, bdg, r3, occ, r4, onet_occ, r5, job_title

MATCH (mjg:MajorGroup {name: "Computer and Mathematical Occupations"})<-[r1:IN_MJG]-(mng:MinorGroup)<-[r2:IN_MNG]-(bdg:BroadGroup)<-[r3:IN_BDG]-(occ:Occupation)<-[r4:IN_OCC]-(onet_occ:ONetOcc)<-[r5:IN_OOC]-(job_title:JobTitle {code: "Software Designer"})
RETURN mjg, r1, mng, r2, bdg, r3, occ, r4, onet_occ, r5, job_title

MATCH (mjg:MajorGroup {name: "Computer and Mathematical Occupations"})<-[r1:IN_MJG]-(mng:MinorGroup)<-[r2:IN_MNG]-(bdg:BroadGroup)<-[r3:IN_BDG]-(occ:Occupation)<-[r4:IN_OCC]-(onet_occ:ONetOcc)<-[r5:IN_OOC]-(job_title:JobTitle {code: "Software Designer"})
WITH mjg, r1, mng, r2, bdg, r3, occ, r4, onet_occ, r5, job_title
MATCH (onet_occ)-[r6:HAS_TECH_SKILL|USES_TOOL]-(skill_or_tool)
RETURN  mjg, r1, mng, r2, bdg, r3, occ, r4, onet_occ, r5, job_title, r6, skill_or_tool

---

MATCH (user:User)-[r:APPLIED]->(job:Job) RETURN user, r, job ORDER BY user.uid LIMIT 10

MATCH (user:User {uid: 47}) RETURN user.uid, user.history, user.managed_others, user.total_years_experience, user.managed_how_many

MATCH (user:User {uid:47})-[r:APPLIED]->(job:Job) 
WITH user, r, job
MATCH (zc)<-[r1:AT_ZIP]-(user:User {uid: 47})-[r2:IN_CITY]->(c)-[r3:IN_STATE]->(s)-[r4:IN_COUNTRY]->(ctr)
WITH r, job, zc, r1, user, r2, c, r3, s, r4, ctr
MATCH (job)-[r21:IN_CITY]->(c2)-[r31:IN_STATE]->(s2)-[r41:IN_COUNTRY]->(ctr2)
RETURN r, job, zc, r1, user, r2, c, r3, s, r4, ctr, r21, c2, r31, s2, r41, ctr2

---

MATCH (user:User {uid:47}) RETURN user

http://localhost:9000
national space communication programs-special program supervisor
detention officer
passenger screener, tsa

curl -d "@test_data.json" -H"sContent-Type: application/json" -X POST http://localhost:8004/extract

[[1, [["nation", "space", "communic", "program", "special", "program", "supervisor"]]], [2, [["detent", "offic"]]], [3, [["passeng", "screener"], ["tsa"]]]]

---

architecture diagram

---

MATCH (user:User {uid:47})-[r]-(lst:LSTitle)-[r0:BEST_MATCH*0..1]-(jt_lst:LSTitle)-[r1:J_LST]-(jt:JobTitle) RETURN user, r, lst, r0, jt_lst, r1, jt

MATCH (user:User {uid:47})-[r]-(lst1:LSTitle)-[r0:BEST_MATCH*0..1]-(jt_lst:LSTitle:JT)-[r1:BEST_MATCH*0..1]-(lst2:LSTitle)<-[r2:A_LST]-(j:Job) 
RETURN user, r, lst1, r0, jt_lst, r1, lst2, r2, j


MATCH (user:User {uid: 98})
	WHERE EXISTS(user.history) AND SIZE(user.history) > 0
WITH user
	MATCH (user)-[:IN_CITY]->(city:City)
WITH user, city
	MATCH (user)-[r:U_LST {i: SIZE(user.history)-1}]->(u_lst:LSTitle)
WITH user, city, u_lst    
	OPTIONAL MATCH (u_lst)-[r:NEXT]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, apoc.map.fromPairs(COLLECT([jt.code, jc])) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[r:NEXT]->(:LSTitle)-[:BEST_MATCH]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[:BEST_MATCH]->(:LSTitle:JT)-[r:NEXT]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[:BEST_MATCH]-(:LSTitle)-[:BEST_MATCH]-(:LSTitle)-[r:NEXT]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[:BEST_MATCH]-(:LSTitle)-[:BEST_MATCH]-(:LSTitle)-[r:NEXT]->(:LSTitle)-[:BEST_MATCH]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
WITH user, city, u_lst, apoc.map.sortedProperties(jc_map) AS jt_list
WITH user, city, u_lst, jt_list
	UNWIND jt_list AS jc
WITH user, city, u_lst, jc[0] AS jt_code, jc[1] AS c ORDER BY c DESC LIMIT 10
WITH user, city, u_lst, jt_code, c AS rank
    MATCH (jt:JobTitle {code: jt_code})-[:J_LST]->(j_lst:LSTitle)<-[:A_LST|BEST_MATCH*1..2]-(job:Job)-[:IN_CITY]->(job_location:City)
    	WHERE EXISTS(job_location.latitude)
WITH DISTINCT(job) AS job, user, city, u_lst, SUM(rank) AS rank, job_location, DISTANCE(POINT(city), POINT(job_location))/1000 AS distance_in_km
WITH rank, job, distance_in_km
	WHERE distance_in_km < 20.0
RETURN rank, job.uid, job.title, job.city, job.state, job.country, distance_in_km ORDER BY distance_in_km LIMIT 10

MATCH (user:User {uid: 47})
	WHERE EXISTS(user.history) AND SIZE(user.history) > 0
WITH user
	MATCH (user)-[:IN_CITY]->(city:City)
WITH user, city
	MATCH (user)-[r:U_LST {i: SIZE(user.history)-1}]->(u_lst:LSTitle)
WITH user, city, u_lst    
	OPTIONAL MATCH (u_lst)-[r:NEXT]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, apoc.map.fromPairs(COLLECT([jt.code, jc])) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[r:NEXT]->(:LSTitle)-[:BEST_MATCH]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[:BEST_MATCH]->(:LSTitle:JT)-[r:NEXT]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[:BEST_MATCH]-(:LSTitle)-[:BEST_MATCH]-(:LSTitle)-[r:NEXT]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
	OPTIONAL MATCH (u_lst)-[:BEST_MATCH]-(:LSTitle)-[:BEST_MATCH]-(:LSTitle)-[r:NEXT]->(:LSTitle)-[:BEST_MATCH]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, user, city, u_lst, jc_map, SUM(SIZE(r.users)) AS jc
WITH user, city, u_lst, jc_map, COLLECT([jt.code, jc]) AS jt_list
WITH user, city, u_lst, REDUCE(m=jc_map, e IN jt_list | CASE WHEN apoc.map.get(m, e[0], -1) = -1 THEN apoc.map.setKey(m, e[0], e[1]) ELSE apoc.map.setKey(m, e[0], apoc.map.get(m, e[0], -1) + e[1])   END) AS jc_map
WITH user, city, u_lst, jc_map
WITH user, city, u_lst, apoc.map.sortedProperties(jc_map) AS jt_list
WITH user, city, u_lst, jt_list
	UNWIND jt_list AS jc
WITH user, city, u_lst, jc[0] AS jt_code, jc[1] AS c ORDER BY c DESC LIMIT 10
WITH user, city, u_lst, jt_code, c AS rank
    MATCH (jt:JobTitle {code: jt_code})-[:J_LST]->(j_lst:LSTitle)<-[:A_LST|BEST_MATCH*1..2]-(job:Job)-[:IN_CITY]->(job_location:City)
    	WHERE EXISTS(job_location.latitude)
WITH DISTINCT(job) AS job, user, city, u_lst, SUM(rank) AS rank, job_location, DISTANCE(POINT(city), POINT(job_location))/1000 AS distance_in_km
WITH rank, job, distance_in_km
	WHERE distance_in_km < 20.0
RETURN rank, job.uid, job.title, job.city, job.state, job.country, distance_in_km ORDER BY distance_in_km LIMIT 10

---

pip install wordcloud
wordcloud_cli --text test_word_cloud.txt --imagefile images/test_word_cloud.png

---

MATCH (jt:JobTitle)-[:J_LST]->(j_lst:LSTitle)<-[r:BEST_MATCH|U_LST|A_LST]-()
WITH DISTINCT(j_lst) AS j_lst, jt, COUNT(DISTINCT(r)) AS rc ORDER BY rc DESC LIMIT 100
RETURN jt.code AS job_title, rc AS total_in_use

MATCH (jt:JobTitle)-[:J_LST]->(j_lst:LSTitle)<-[r:BEST_MATCH|U_LST|A_LST]-()
	WHERE jt.code CONTAINS 'Software'
WITH DISTINCT(j_lst) AS j_lst, jt, COUNT(DISTINCT(r)) AS rc ORDER BY rc DESC LIMIT 100
RETURN jt.code AS job_title, rc AS total_in_use

MATCH (user:User) WHERE EXISTS(user.history) AND SIZE(user.history) > 0 
WITH user, REDUCE(m=0, e IN user.history | CASE WHEN LOWER(e) CONTAINS 'software' THEN m+1 ELSE m END) AS software_in_title_count 
WITH user, software_in_title_count
	WHERE software_in_title_count > 0
RETURN DISTINCT(user.uid) AS user, user.history AS history, software_in_title_count ORDER BY software_in_title_count DESC LIMIT 10

MATCH (job:Job)
WITH job WHERE EXISTS(job.title) AND LOWER(job.title) CONTAINS 'software' AND LOWER(job.title) CONTAINS 'developer'
RETURN COUNT(job) AS number_of_job_titles_contains_software_developer

MATCH (job:Job)
WITH job WHERE EXISTS(job.title) AND LOWER(job.title) CONTAINS 'software' AND LOWER(job.title) CONTAINS 'developer'
RETURN job.uid, job.title LIMIT 100

MATCH (user:User {uid: 47})-[r1:U_LST {i: SIZE(user.history)-1}]->(user_ls_title:LSTitle)-[r2:BEST_MATCH]-(classified_ls_title:LSTitle:JT)<-[r3:J_LST]-(job_title:JobTitle)-[r4:IN_OOC]->(onet_occupation:ONetOcc)-[r5:HAS_TECH_SKILL|USES_TOOL]->(skill_or_tool)
RETURN user, r1, user_ls_title, r2, classified_ls_title, r3, job_title, r4, onet_occupation, r5, skill_or_tool

MATCH (user:User {uid: 47})-[r1:U_LST {i: SIZE(user.history)-1}]->(user_ls_title:LSTitle)-[r2:BEST_MATCH]-(classified_ls_title:LSTitle:JT)<-[r3:J_LST]-(job_title:JobTitle)-[r4:IN_OOC]->(onet_occupation:ONetOcc)-[r5:HAS_TECH_SKILL|USES_TOOL]->(skill_or_tool)
WITH user, r1, user_ls_title, r2, classified_ls_title, r3, job_title, r4, onet_occupation, r5, skill_or_tool
MATCH (user:User {uid: 47})-[r11:APPLIED]-(job:Job)-[r21:A_LST]->(job_ls_title:LSTitle)-[r31:BEST_MATCH]-(classified_ls_title_2:LSTitle:JT)<-[r41:J_LST]-(job_title_2:JobTitle)-[r51:IN_OOC]->(onet_occupation_2:ONetOcc)
RETURN user, r1, user_ls_title, r2, classified_ls_title, r3, job_title, r4, onet_occupation, r5, skill_or_tool, r11, job, r21, job_ls_title, r31, classified_ls_title_2, r41, job_title_2, r51, onet_occupation_2

MATCH (user:User {uid: 47})-[r1:U_LST {i: SIZE(user.history)-1}]->(user_ls_title:LSTitle)-[r2:BEST_MATCH]-(classified_ls_title:LSTitle:JT)<-[r3:J_LST]-(job_title:JobTitle)-[r4:IN_OOC]->(onet_occupation:ONetOcc)-[r5:HAS_TECH_SKILL|USES_TOOL]->(skill_or_tool)
WITH user, r1, user_ls_title, r2, classified_ls_title, r3, job_title, r4, onet_occupation, r5, skill_or_tool
MATCH (user:User {uid: 47})-[r11:APPLIED]-(job:Job)-[r21:A_LST]->(job_ls_title:LSTitle)-[r31:BEST_MATCH]-(classified_ls_title_2:LSTitle:JT)<-[r41:J_LST]-(job_title_2:JobTitle)-[r51:IN_OOC]->(onet_occupation_2:ONetOcc {code: "13-1161.00"})-[r61:HAS_TECH_SKILL|USES_TOOL]->(skill_or_tool_2)
RETURN user, r1, user_ls_title, r2, classified_ls_title, r3, job_title, r4, onet_occupation, r5, skill_or_tool, r11, job, r21, job_ls_title, r31, classified_ls_title_2, r41, job_title_2, r51, onet_occupation_2, r61, skill_or_tool_2

