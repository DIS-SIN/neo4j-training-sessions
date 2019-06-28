import csv
import sys
from wordcloud import WordCloud

if __name__ == '__main__':

    data_dict = dict()
    with open(sys.argv[1], 'rt') as in_csv_file:
        reader = csv.DictReader(in_csv_file)
        for row in reader:
            data_dict[row['job_title']] = int(row['total_in_use'])

    word_cloud = WordCloud(color='')
    word_cloud.generate_from_frequencies(data_dict)
    word_cloud.to_file('images/' + sys.argv[1][sys.argv[1].rfind('/')+1:-3] + 'png')
