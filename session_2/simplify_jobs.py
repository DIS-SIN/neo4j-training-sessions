import csv
import sys

csv.field_size_limit(sys.maxsize)

def load_jobs(input_file, output_file):
    jobs = []

    with open(input_file, 'rt', newline='\r\n') as in_tsv_file:
        reader = csv.DictReader(in_tsv_file, delimiter='\t')
        try:
            for row in reader:
                jobs.append([row['JobID'], row['Title'], row['City'], row['State'], row['Country'], row['Zip5']])
                if len(jobs) % 10000 == 0:
                    print(len(jobs))
        except Exception:
            print('ERROR at: %d', len(jobs))
        
        print('Got %d rows.' % len(jobs))
    
    with open(output_file, 'wt') as out_tsv_file:
        tsv_writer = csv.writer(out_tsv_file, delimiter='\t')
        tsv_writer.writerow(['JobID', 'Title', 'City', 'State', 'Country', 'Zip5'])
        for job in jobs:
            tsv_writer.writerow(job)

if __name__ == '__main__':
    load_jobs(sys.argv[1], sys.argv[2])
