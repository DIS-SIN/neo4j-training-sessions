Ínstall/Update neo4j-algo-apoc
Remove old database
Check if ready

Collecting data
- SOC:
    - https://www.bls.gov/soc/soc_structure_2010.xls
- O*NET
    - https://www.onetcenter.org/dl_files/database/db_23_3_text/Occupation%20Data.txt
    - https://www.onetcenter.org/dl_files/database/db_23_3_text/Alternate%20Titles.txt
    - https://www.onetcenter.org/dl_files/database/db_23_3_text/UNSPSC%20Reference.txt
    - https://www.onetcenter.org/dl_files/database/db_23_3_text/Technology%20Skills.txt
    - https://www.onetcenter.org/dl_files/database/db_23_3_text/Tools%20Used.txt
- Kaggle Job Recommendation Challenge
    - https://www.kaggle.com/c/3046/download-all
    - User entityies
    - Job ads

Normalization:
- Cleanup
- Stanford NLP: POS, Lemmatization, Stemming
- Creating entities and relationships

Enrichment
- Job title clustering enrichment

Career graph

1. Occupation classification
2. Similar tracks
3. Career recommendation

Test Stanford CoreNLP docker:

wget --post-data 'President Barack Obama attends an United Nations session in New York.' 'localhost:9000/?properties={"annotators":"ner,pos,lemma","outputFormat":"text"}' -O -

curl --data 'President Barack Obama attends an United Nations session in New York.' 'http://localhost:9000/?properties={%22annotators%22%3A%22tokenize%2Cssplit%2Cpos%22%2C%22outputFormat%22%3A%22json%22}' -o -

Test NLTK NLP docker:
curl -d "@test_data.json" -H"sContent-Type: application/json" -X POST http://localhost:8004/extract

MATCH (user:User {uid: 47})
    WHERE EXISTS(user.history) AND SIZE(user.history) > 0
WITH user
    MATCH (user)-[:U_LST {i: SIZE(user.history)-1}]->(u_lst:LSTitle)
WITH u_lst
    MATCH (u_lst)-[:NEXT]->(j_lst:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, u_lst, COUNT(DISTINCT(j_lst)) AS jc
WITH u_lst, COLLECT([jt, jc]) AS jtc_list
WITH u_lst, jtc_list
    MATCH (u_lst)-[:NEXT]->(j_lst:LSTitle)-[:BEST_MATCH]->(:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, u_lst, jtc_list, COUNT(DISTINCT(j_lst)) AS jc
WITH u_lst, jtc_list + COLLECT([jt, jc]) AS jtc_list
WITH u_lst, jtc_list
    MATCH (u_lst)-[:BEST_MATCH]->(:LSTitle:JT)-[:NEXT]->(j_lst:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, u_lst, jtc_list, COUNT(DISTINCT(j_lst)) AS jc
WITH u_lst, jtc_list + COLLECT([jt, jc]) AS jtc_list
WITH u_lst, jtc_list
    MATCH (u_lst)-[:BEST_MATCH*2]->(:LSTitle)-[:NEXT]->(j_lst:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, u_lst, jtc_list, COUNT(DISTINCT(j_lst)) AS jc
WITH u_lst, jtc_list + COLLECT([jt, jc]) AS jtc_list
WITH u_lst, jtc_list
    MATCH (u_lst)-[:BEST_MATCH*2]->(:LSTitle)-[:NEXT]->(j_lst:LSTitle)-[:BEST_MATCH]->(j_lst:LSTitle:JT)<-[:J_LST]-(jt:JobTitle)
WITH DISTINCT(jt) AS jt, u_lst, jtc_list, COUNT(DISTINCT(j_lst)) AS jc
WITH u_lst, jtc_list + COLLECT([jt, jc]) AS jtc_list
WITH u_lst, REDUCE(m={}, e IN jtc_list | CASE WHEN e[0].code IN m THEN m += {e[0].code: m[e[0].code] + e[1]} ELSE m += {e[0].code: e[1]} END) AS rec_jt_map
RETURN u_lst.code, rec_jt_map;
