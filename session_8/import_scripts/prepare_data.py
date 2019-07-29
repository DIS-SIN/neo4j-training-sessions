import csv
from pathlib import Path
import traceback
import sys

def read_rows(input_file):
    rows, counter = [], 0

    with open(input_file, 'rt', encoding='utf8', newline='\n') as in_tsv_file:

        print('[>>> %s]' % input_file, end='', flush=True)
        reader = csv.DictReader(in_tsv_file, delimiter='\t')

        try:
            for row in reader:
                rows.append(row)
                counter += 1
                if counter % 100000 == 0:
                    print('.', end='', flush=True)
        except Exception as e:
            traceback.print_exc()
            return None

        print(' Read %d rows.' % counter)

    return rows


def write_rows(output_file, headers, rows):
    with open(output_file, 'wt') as out_tsv_file:

        print('[<<< %s]' % output_file, end='', flush=True)
        tsv_writer = csv.writer(out_tsv_file, delimiter='\t')
        tsv_writer.writerow(headers)
        counter = 1

        for row in rows:
            if counter % 10000 == 0:
                print('.', end='', flush=True)
            tsv_writer.writerow(row)
            counter += 1

    print(' Wrote %d rows.' % counter)


def write_entities(output_file, headers, uid_props_list, rows, split=False, delimiter=','):
    key_set, row_list = set(), []

    for uid, props in uid_props_list:
        for row in rows:
            row_uid_list = [row[uid].strip()] if not split else [s.strip() for s in row[uid].strip().split(delimiter)]

            for row_uid in row_uid_list:
                if not row_uid:
                    continue
                if row_uid not in key_set:
                    row_list.append([row_uid] + [row[c].strip() for c in props])
                    key_set.add(row_uid)

    write_rows(output_file, headers, row_list)


def write_relationships(output_file, headers, uid_pair_list, rows, split=False, delimiter=',', props=None):
    pair_dict = dict()

    for start, end in uid_pair_list:
        for row in rows:
            key_list = [row[start].strip()] if not split else [s.strip() for s in row[start].strip().split(delimiter)]

            for key in key_list:
                val = row[end].strip()
                if not key or not val:
                    continue
                if key not in pair_dict:
                    pair_dict[key] = set() if not props else dict()
                if val not in pair_dict[key]:
                    if not props:
                        pair_dict[key].add(val)
                    else:
                        pair_dict[key][val] = [row[c].strip() for c in props]

    row_list = []
    for key in sorted(pair_dict.keys()):
        for val in pair_dict[key]:
            if not props:
                row_list.append([key, val])
            else:
                row_list.append([key, val] + pair_dict[key][val])

    write_rows(output_file, headers, row_list)


def load_registrations(input_file):
    rows = read_rows(input_file)
    if not rows:
        print('ERROR reading [%s].' % input_file)
        return

    input_dir = input_file[:input_file.rfind('/')+1]

    write_entities(
        input_dir + 'course.tsv',
        ['code:ID(course-ID)', 'title', 'event_description'],
        [['course_code', ['course_title', 'event_description']]],
        rows
    )

    write_entities(
        input_dir + 'business_type.tsv',
        ['name:ID(business_type-ID)'],
        [['business_type', []]],
        rows
    )

    write_relationships(
        input_dir + 'business_type_TO_course.tsv',
        [':START_ID(business_type-ID)', ':END_ID(course-ID)'],
        [['business_type', 'course_code']],
        rows
    )

    write_entities(
        input_dir + 'delivery_type.tsv',
        ['name:ID(delivery_type-ID)'],
        [['delivery_type', []]],
        rows
    )

    write_relationships(
        input_dir + 'delivery_type_TO_course.tsv',
        [':START_ID(delivery_type-ID)', ':END_ID(course-ID)'],
        [['delivery_type', 'course_code']],
        rows
    )

    write_entities(
        input_dir + 'offering.tsv',
        ['uid:ID(offering-ID)', 'start_date', 'end_date', 'month', 'week', 'duration', 'status'],
        [['offering_id', ['start_date', 'end_date', 'month', 'week', 'duration', 'offering_status']]],
        rows
    )

    write_relationships(
        input_dir + 'course_TO_offering.tsv',
        [':START_ID(course-ID)', ':END_ID(offering-ID)'],
        [['course_code', 'offering_id']],
        rows
    )

    write_entities(
        input_dir + 'language.tsv',
        ['name:ID(language-ID)'],
        [['offering_language', []]],
        rows
    )

    write_relationships(
        input_dir + 'language_TO_offering.tsv',
        [':START_ID(language-ID)', ':END_ID(offering-ID)'],
        [['offering_language', 'offering_id']],
        rows
    )

    write_entities(
        input_dir + 'region.tsv',
        ['name:ID(region-ID)'],
        [['offering_region', []], ['learner_region', []]],
        rows
    )

    write_entities(
        input_dir + 'province.tsv',
        ['name:ID(province-ID)'],
        [['offering_province', []],
        ['learner_province', []]],
        rows
    )

    write_entities(
        input_dir + 'city.tsv',
        ['name:ID(city-ID)'],
        [['offering_city', []], ['learner_city', []]],
        rows
    )

    write_relationships(
        input_dir + 'region_TO_province.tsv',
        [':START_ID(region-ID)', ':END_ID(province-ID)'],
        [['offering_region', 'offering_province'], ['learner_region', 'learner_province']],
        rows
    )

    write_relationships(
        input_dir + 'province_TO_city.tsv',
        [':START_ID(province-ID)', ':END_ID(city-ID)'],
        [['offering_province', 'offering_city'], ['learner_province', 'learner_city']],
        rows
    )

    write_relationships(
        input_dir + 'city_TO_offering.tsv',
        [':START_ID(city-ID)', ':END_ID(offering-ID)'],
        [['offering_city', 'offering_id']],
        rows
    )

    write_relationships(
        input_dir + 'city_TO_learner.tsv',
        [':START_ID(city-ID)', ':END_ID(learner-ID)'],
        [['learner_city', 'learner_id']],
        rows
    )

    write_entities(
        input_dir + 'instructor.tsv',
        ['name:ID(instructor-ID)'],
        [['instructor_name', []]],
        rows, split=True
    )

    write_relationships(
        input_dir + 'instructor_TO_offering.tsv',
        [':START_ID(instructor-ID)', ':END_ID(offering-ID)'],
        [['instructor_name', 'offering_id']],
        rows, split=True
    )

    write_entities(
        input_dir + 'registration.tsv',
        ['uid:ID(registration-ID)', 'scope', 'status', 'no_show', 'date', 'gap'],
        [['reg_id', ['scope', 'reg_status', 'no_show', 'reg_date', 'reg_gap']]],
        rows
    )

    write_relationships(
        input_dir + 'offering_TO_registration.tsv',
        [':START_ID(offering-ID)', ':END_ID(registration-ID)'],
        [['offering_id', 'reg_id']],
        rows
    )

    write_entities(
        input_dir + 'learner.tsv',
        ['uid:ID(learner-ID)'],
        [['learner_id', []]],
        rows
    )

    write_relationships(
        input_dir + 'leaner_TO_registration.tsv',
        [':START_ID(learner-ID)', ':END_ID(registration-ID)'],
        [['learner_id', 'reg_id']],
        rows
    )

    write_entities(
        input_dir + 'classification_group.tsv',
        ['code:ID(classification_group-ID)'],
        [['learner_classif_group', []]],
        rows
    )

    write_entities(
        input_dir + 'classification.tsv',
        ['code:ID(classification-ID)'],
        [['learner_classif', []]],
        rows,
    )

    write_relationships(
        input_dir + 'classification_group_TO_classification.tsv',
        [':START_ID(classification_group-ID)', ':END_ID(classification-ID)'],
        [['learner_classif_group', 'learner_classif']],
        rows
    )

    write_relationships(
        input_dir + 'classification_TO_learner.tsv',
        [':START_ID(classification-ID)', ':END_ID(learner-ID)'],
        [['learner_classif', 'learner_id']],
        rows
    )

    write_entities(
        input_dir + 'department.tsv',
        ['code:ID(department-ID)', 'name'],
        [['billing_dept_code', ['billing_dept_name']]],
        rows,
    )

    write_relationships(
        input_dir + 'department_TO_learner.tsv',
        [':START_ID(department-ID)', ':END_ID(learner-ID)'],
        [['billing_dept_code', 'learner_id']],
        rows
    )


def load_surveys(input_file):
    rows = read_rows(input_file)
    if not rows:
        print('ERROR reading [%s].' % input_file)
        return

    input_dir = input_file[:input_file.rfind('/')+1]

    write_entities(
        input_dir + 'survey.tsv',
        ['uid:ID(survey-ID)', 'date', 'classification', 'department'],
        [['survey_id', ['offering_start_date', 'survey_respondent_classification', 'survey_respondent_department']]],
        rows
    )

    write_relationships(
        input_dir + 'offering_TO_survey.tsv',
        [':START_ID(offering-ID)', ':END_ID(survey-ID)'],
        [['offering_id', 'survey_id']],
        rows
    )

    write_entities(
        input_dir + 'question.tsv',
        ['name:ID(question-ID)'],
        [['short_question', []]],
        rows
    )

    write_relationships(
        input_dir + 'question_TO_survey.tsv',
        [':START_ID(question-ID)', ':END_ID(survey-ID)', 'answer'],
        [['short_question', 'survey_id']],
        rows,
        props=['survey_answer']
    )


if __name__ == '__main__':
    if not Path(sys.argv[1]).exists():
        print('File [%s] not found.' % sys.argv[1])
        exit(1)
    if not Path(sys.argv[2]).exists():
    	print('File [%s] not found.' % sys.argv[2])
    	exit(1)
    load_registrations(sys.argv[1])
    load_surveys(sys.argv[2])
