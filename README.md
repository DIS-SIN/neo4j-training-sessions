# neo4j-training-sessions

## Neo4j Training Sessions

*8 weekly training sessions to grasp the basic intricacies of `Neo4j` graph database*

### Objectives:
- Seeing the big picture
- Best practices 
- Secret sauces

### Style:
- For non-developers (30 mins): informal, enjoyable, real-life example
- For developers (30 mins): hands-on & reproducible

### Frequency:
- One session per week

### Resources:
- A few online slides
- Most are reproducible dockers, github repos, etc.

--- 

## Session 1: *"I thought Christmas only comes once a year."*

### Business Perspectives
- *Rumor spreading*: a case for `JOIN`-ing infinite number of tables
- 3 `Neo4j` user cases: US Army, Mosanto, and ICIJ 
- Neo4j ecosystem

### The Hands-on Story
`What do we know about the James Bond movies?`

1. Get the dataset: 
- harvesting data (movie, directors, actors, rarting, votes, ...) from `imdb.com` with `scrapper-0.1:imdb` as a micro service
- reusing existing data from `Wikipedia` from a tab-separated file

2.  Process teh harvested data through a data pipeline called `pipeline-0.1:imdb`
-  `stanford-nlp-3.9.2:pos`: Stanford NLP Part-of-Speech tagger docker (as micro service)
- `stanford-nlp-3.9.2:ner`: Stanford NLP Named Entity tagger docker (as micro service)
- store the entities and their relationships in a storage called `neo4j-3.5.5:algo-apoc`, which is a neo4j docker with APOC and ALGO libraries.
    
3. Visualization and queries with Neo4j browser

### For more information:
- [Presentation](/session_1/slide-deck)
- [Hands-on](/session_1/README.md)