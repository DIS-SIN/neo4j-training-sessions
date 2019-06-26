class TagChunker(object):

    def __init__(self, rules, cleaner):
        self.rules  = rules
        self.cleaner = cleaner

    def process(self, text):
        chunks, stack = [], []
        for token in text.split():
            if 'B' in self.rules and self.rules['B'](token):    # new chunk
                if stack:                                       # if there is something in the stack
                    if 'E' in self.rules:                       # if there is a rule how does chunk end
                        if self.rules['E'](stack[-1]):          # check the last one
                            chunks.append(self.cleaner(stack))  # add the stack
                    else:                                       # if no such rule
                         chunks.append(self.cleaner(stack))     # add the stack
                stack = [token]                             # add token to the new stack

            elif 'I' in self.rules and self.rules['I'](token):  # inside chunk
                stack.append(token)                             # just add to the stack

            elif 'E' in self.rules and self.rules['E'](token):  # possible end of chunk
                stack.append(token)                             # just add to the stack

            else:                                               # not a chunk tag
                if stack:                                       # if there is something in the stack
                    if 'E' in self.rules:                       # if there is a rule how does chunk end
                        if self.rules['E'](stack[-1]):          # check the last one
                            chunks.append(self.cleaner(stack))  # add the stack
                    else:                                       # if no such rule
                         chunks.append(self.cleaner(stack))     # add the stack
                    stack = []                                  # empty the stack

        if stack:                                               # if there is something in the stack
            if 'E' in self.rules:                               # if there is a rule how does chunk end
                if self.rules['E'](stack[-1]):                  # check the last one
                    chunks.append(self.cleaner(stack))          # add the stack

        return chunks
