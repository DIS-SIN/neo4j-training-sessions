import socket
import time

class SocketAdapter(object):

    def __init__(self, conf):
        self.host = conf['host']
        self.port = conf['port']
        self.buffer_size = conf['buffer_size']
        self.wait_time = conf['wait_time']
        self.term_str = conf['term_str']
        self.loop = conf['loop']

    def tag(self, text):
        # start_time = int(round(time.time() * 1000))
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(self.wait_time)
        sock.connect((self.host, self.port))
        sock.sendall(('%s%s' % (text, self.term_str)).encode('utf-8'))
        # print('---> %d' % len(text))

        try:
            data = sock.recv(self.buffer_size)
        except socket.timeout:
            sock.close()
            # elapsed_time = int(round(time.time() * 1000)) - start_time
            # print('T %d' % elapsed_time)
            return ''
        except socket.error as ex:
            print(ex)
            sock.close()
            # elapsed_time = int(round(time.time() * 1000)) - start_time
            # print('D %d' % elapsed_time)
            return ''

        sock.close()
        # elapsed_time = int(round(time.time() * 1000)) - start_time
        # print('D %d' % elapsed_time)
        return data.decode('utf-8')
        

if __name__ == '__main__':

    text = """A passenger plane has crashed shortly after take-off from Kyrgyzstan's capital, Bishkek, killing a large number of those on board. The head of Kyrgyzstan's Civil Aviation Authority said that out of about 90 passengers and crew, only about 20 people have survived. The Itek Air Boeing 737 took off bound for Mashhad, in north-eastern Iran, but turned round some 10 minutes later. An airport spokeswoman said the crew had reported a technical problem. The plane was returning to Bishkek airport but crashed before it could land, the spokeswoman said. Officials from a nearby US base said they were trying to help with the rescue effort. "At the moment rescue teams, fire brigades and medics are rushing to the crash site," a spokeswoman for the US air base located in Manas, 30km (20 miles) from Bishkek, told Russia's RIA news agency. There was confusion over the number of people on board - with reports ranging from 83 to 123. They were understood to include a Kyrgyz school basketball team. Prime Minister Igor Chudinov said 51 of the passengers were foreigners, including people from China, Turkey, Iran and Canada. It was not clear what had caused the plane to crash. The prime minister said the pilot had survived, but "it is difficult to talk to him right now". Airport employees said the fuselage of the plane was destroyed by flames and only the tail remained intact. Yelena Bayalinova, spokeswoman for the Kyrgyz health ministry, told the Interfax news agency that many victims of the crash had suffered burns, and that some were in critical condition. The plane belonged to Itek Air, a Kyrgyz company, but was reportedly operated by Iran Aseman Airlines. Itek Air is on a list of airlines banned from EU airspace because of fears over safety standards."""
    print('----- Original text -----\n%s\n-------------------------\n' % text)

    from tag_chunker import TagChunker

    pos_adapter = SocketAdapter({
        'host': 'localhost',
        'port': 8001,
        'buffer_size': 4096,
        'wait_time': 3,
        'term_str': '\n\n',
        'loop': False
    })

    pos_tagged_text = pos_adapter.tag(text)
    print('--- POS tagged content --\n%s\n-------------------------\n' % pos_tagged_text)

    pos_chunker = TagChunker(
        {
            'I': lambda x: x.endswith('_NN') or x.endswith('_JJ'), # in-chunk tag
            'E': lambda x: x.endswith('_NN') or x.endswith('_NNS') or x.endswith('_VBG'), # chunk-end tag
        },
        lambda x: ' '.join(i[:i.rfind('_')] for i in x)
    )
    for stack in pos_chunker.process(pos_tagged_text):
        print(stack)

    ner_adapter = SocketAdapter({
        'host': 'localhost',
        'port': 8002,
        'buffer_size': 4096,
        'wait_time': 3,
        'term_str': '\n\n',
        'loop': False
    })

    ner_tagged_text = ner_adapter.tag(text)
    print('--- NER tagged content --\n%s\n-------------------------\n' % ner_tagged_text)
    ner_chunker = TagChunker(
        {
            'B': lambda x: x[x.rfind('/')+1:].startswith('B-'), # start-chunk tag
            'I': lambda x: x[x.rfind('/')+1:].startswith('I-'), # in-chunk tag
        },
        lambda x: ' '.join(i[:i.rfind('/')] for i in x)
    )
    for stack in ner_chunker.process(ner_tagged_text):
        print(stack)