////////////////////////////////////////////////////////////////////////
//
// Normalize initial data
//
// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
CREATE INDEX ON :Survey(classification);
//
CREATE INDEX ON :Survey(department);
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Merge `Instructor` nodes
//
MATCH (i:Instructor)
  WITH DISTINCT(LOWER(i.name)) AS i, COLLECT(i.name) AS ic
WITH i, ic
  WHERE SIZE(ic) > 1
RETURN i AS instructor, ic AS duplicates;
//
MATCH (i:Instructor)
	WHERE i.name IN ['Jean-Philippe Tabet', 'Yvan Bastien', 'Serge Poirier']
WITH i
	MATCH (oi:Instructor)
    WHERE oi <> i AND LOWER(oi.name) = LOWER(i.name)
WITH [i, oi] AS i_list
  CALL apoc.refactor.mergeNodes(i_list, {properties: 'discard'}) YIELD node
RETURN node.name AS instructor;
//
MATCH (i:Instructor)
RETURN COUNT(DISTINCT(LOWER(i.name))) AS number_of_instructors;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Merge `Survey` to `Classification`
//
CALL apoc.periodic.iterate(
"
  MATCH (survey:Survey)
  WITH DISTINCT(survey.classification) AS survey_classification
  WITH survey_classification
    MATCH (classification:Classification)
      WHERE LOWER(classification.code) = LOWER(survey_classification)
  WITH classification, survey_classification
    MATCH (survey:Survey {classification: survey_classification})
  RETURN classification, COLLECT(survey) AS survey_list
", "
	WITH classification, survey_list
    UNWIND survey_list AS survey
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
",
{
    batchSize:3, iterateList:true, parallel:false
});
//
MATCH (s:Survey)
	WHERE SIZE((s)<-[:CLASSIFICATION_OF]-()) > 0
RETURN COUNT(s) AS number_of_surveys_connected_to_classifications;
//
//
// `CF*` -> `CF *`
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND LOWER(survey.classification) CONTAINS 'maj'
    AND LOWER(survey.classification) CONTAINS 'gen'
MATCH (classification:Classification {code: "CFMajorGeneral - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND LOWER(survey.classification) CONTAINS 'lieu'
    AND LOWER(survey.classification) CONTAINS 'gen'
MATCH (classification:Classification {code: "CFLieutenantGen - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND LOWER(survey.classification) CONTAINS 'brig'
    AND LOWER(survey.classification) CONTAINS 'gen'
MATCH (classification:Classification {code: "CFBrigadierGene - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND LOWER(survey.classification) CONTAINS 'lieu'
    AND LOWER(survey.classification) CONTAINS 'col'
MATCH (classification:Classification {code: "CFLieutenantCol - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND LOWER(survey.classification) CONTAINS 'col'
MATCH (classification:Classification {code: "CFColonel - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND LOWER(survey.classification) CONTAINS 'major'
MATCH (classification:Classification {code: "CFMajor - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND LOWER(survey.classification) CONTAINS 'capt'
MATCH (classification:Classification {code: "CFCaptain - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND (LOWER(survey.classification) CONTAINS 'lieu' OR LOWER(survey.classification) CONTAINS 'lt')
MATCH (classification:Classification {code: "CFLieutenant - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND (LOWER(survey.classification) CONTAINS 'cpl' OR LOWER(survey.classification) CONTAINS 'coporal' OR (LOWER(survey.classification) CONTAINS 'master' AND LOWER(survey.classification) CONTAINS 'seaman'))
MATCH (classification:Classification {code: "CFCorporal - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'cf'
    AND (LOWER(survey.classification) CONTAINS 'serg' OR LOWER(survey.classification) CONTAINS 'warrant' OR LOWER(survey.classification) CONTAINS 'petty' OR LOWER(survey.classification) CONTAINS 'cwo' OR LOWER(survey.classification) CONTAINS 'mwo')
MATCH (classification:Classification {code: "CFSergeant - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
//
// *Student*
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) CONTAINS 'student'
MATCH (classification:Classification {code: "Student - 00"})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
//
// ENG -*
//
MATCH (survey:Survey)
	WHERE SIZE((survey)<-[:CLASSIFICATION_OF]-()) = 0
    AND LOWER(survey.classification) STARTS WITH 'eng -'
MATCH (classification:Classification {code: "EN"+ survey.classification})
  WITH classification, survey
    MERGE (survey)<-[:CLASSIFICATION_OF]-(classification);
//
MATCH (s:Survey)
	WHERE SIZE((s)<-[:CLASSIFICATION_OF]-()) = 0
RETURN COUNT(s) AS number_of_surveys_NOT_connected_to_classifications;
//
CALL apoc.periodic.iterate(
"
  MATCH (survey:Survey)
  WITH DISTINCT(survey.department) AS survey_department
  WITH survey_department
    MATCH (department:Department)
      WHERE LOWER(department.name) = LOWER(survey_department)
  WITH department, survey_department
    MATCH (survey:Survey {department: survey_department})
  RETURN department, COLLECT(survey) AS survey_list
", "
	WITH department, survey_list
    UNWIND survey_list AS survey
  WITH department, survey
    MERGE (survey)<-[:DEPARTMENT_OF]-(department);
",
{
    batchSize:3, iterateList:true, parallel:false
});
//
MATCH (s:Survey)
	WHERE SIZE((s)<-[:DEPARTMENT_OF]-()) > 0
RETURN COUNT(s) AS number_of_surveys_connected_to_departments;
//
// Mapping surveys with irregular department names
//
CALL apoc.periodic.iterate(
"
  WITH [
    ['Public Works and Government Services Canada', 'SVC'],
    ['National Defence and the Canadian Armed Forces - Civilian', 'DND_Civilian'],
    ['National Defence (civilian)', 'DND_Civilian'],
    ['Canadian Forces Morale and Welfare Services', 'DND_Civilian'],
    ['National Defence', 'DND_Military'],
    ['National Defence and the Canadian Armed Forces - Military', 'DND_Military'],
    ['National Defence - military personnel (uniformed)', 'DND_Military'],
    ['Canadian Armed Forces', 'DND_Military'],
    ['DND', 'DND_Military'],
    ['Department of National Defence', 'DND_Military'],
    ['Canadian Forces', 'DND_Military'],
    ['Fisheries and Oceans Canada', 'DFO'],
    ['Health Canada', 'SHC'],
    ['Correctional Service Canada', 'PEN'],
    ['Agriculture and Agri-Food Canada', 'AGR'],
    ['Service Canada', 'CSD'],
    ['Environment Canada', 'DOE'],
    ['Citizenship and Immigration Canada', 'IMC'],
    ['Canadian Heritage', 'PCH'],
    ['Canadian Conservation Institute', 'PCH'],
    ['Industry Canada', 'DUS'],
    ['Innovation, Science and Economic Development', 'DUS'],
    ['Royal Canadian Mounted Police (Public Servant)', 'RCM'],
    ['Royal Canadian Mounted Police (civilan staff)', 'RCMP_Regular and Civilian members'],
    ['Royal Canadian Mounted Police (civilian)', 'RCMP_Regular and Civilian members'],
    ['Royal Canadian Mounted Police (civilan)', 'RCMP_Regular and Civilian members'],
    ['Royal Canadian Mounted Police - uniformed members and civilian members (with RCM number)', 'RCMP_Regular and Civilian members'],
    ['Royal Canadian Mounted Police (Regular Member)', 'RCMP_Regular and Civilian members'],
    ['Royal Canadian Mounted Police (Regular Member)', 'RCMP_Regular and Civilian members'],
    ['Royal Canadian Mounted Police (Civilian Member)', 'RCMP_Regular and Civilian members'],
    ['RCMP Canadian Firearms Program', 'RCMP_Regular and Civilian members'],
    ['Commission for Public Complaints Against the RCMP', 'RPP'],
    ['Natural Sciences and Engineering Research Council of Canada', 'NSE'],
    ['National Research Council Canada', 'NRC'],
    ['Foreign Affairs, Trade and Development Canada', 'EXT'],
    ['Public Service Commission of Canada', 'PSC'],
    ['Justice Canada', 'JUS'],
    ['Canadian Coast Guard', 'DFO'],
    ['Library and Archives Canada', 'BAL'],
    ['Department of Finance Canada', 'FIN'],
    ['Office of Auditor General', 'AUD'],
    ['Office of the Auditor General', 'AUD'],
    ['Communications Security Establishment Canada', 'CSE'],
    ['National Film Board of Canada', 'NFB'],
    ['Social Sciences and Humanities Research Council of Canada', 'SSH'],
    ['Chief Electoral Officer', 'CEO'],
    ['Veterans Review and Appeal Board Canada', 'AVC'],
    ['Office of the Privacy Commissionner', 'OPC'],
    ['Infrastructure Canada', 'INF'],
    ['Public Prosecution Service of Canada', 'PPD'],
    ['Elections Canada', 'CEO'],
    ['Indigenous and Northern Affairs Canada', 'ISC'],
    ['Aboriginal Affairs and Northern Development Canada', 'IAN'],
    ['Office of the Privacy Commissionner of Canada', 'OPC'],
    ['Office of the Commissioner for Federal Judicial Affairs Canada', 'FJA'],
    ['Office of the Information Commissionner', 'OIC'],
    ['Office of the Information Commissioner of Canada', 'OIC'],
    ['Office of the Commissioner of Lobbying of Canada', 'LOB'],
    ['International Joint Commission', 'IJC'],
    ['ATSSC', 'ATS'],
    ['Administrative Tribunals Support Services of Canada', 'ATS'],
    ['Administrative Tribunal Support Service of Canada', 'ATS'],
    ['Administrative Tribunal Support Services Canada', 'ATS'],
    ['Administrative Tribunals Support Services Canada', 'ATS'],
    ['Service canadien d\\'appui aux tribunaux administratifs', 'ATS'],
    ['Polar Knowledge Canada', 'POL'],
    ['FINTRAC', 'CFC'],
    ['Office of the Public Sector Integrity Commissioner of Canada', 'INT'],
    ['Office of the Registrar of the Supreme Court of Canada', 'JSC'],
    ['Patented Medicine Prices Review Board Canada', 'PXR'],
    ['Copyright Board Canada', 'COP'],
    ['Federal Bridge Corporation Limited', 'FBP'],
    ['Passport Canada', 'IMC'],
    ['Canadian Security Intelligence Service', 'PSP']
  ] AS pairs
    UNWIND pairs AS pair
  WITH pair[0] AS survey_department, pair[1] AS department_code
    MATCH (department:Department {code: department_code}), (survey:Survey {department: survey_department})
    	WHERE SIZE((survey)<-[:DEPARTMENT_OF]-()) = 0
  RETURN department, COLLECT(survey) AS survey_list
", "
	WITH department, survey_list
    UNWIND survey_list AS survey
  WITH department, survey
    MERGE (survey)<-[:DEPARTMENT_OF]-(department);
",
{
    batchSize:3, iterateList:true, parallel:false
});
//
MATCH (s:Survey)
	WHERE SIZE((s)<-[:DEPARTMENT_OF]-()) = 0
RETURN COUNT(s) AS number_of_surveys_NOT_connected_to_departments;
//
////////////////////////////////////////////////////////////////////////
