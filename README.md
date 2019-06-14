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

### Business Perspectives (20 mins) - Neo4j overview
- An example of `Rumor spreading: JOIN-ing infinite number of SQL tables` is discussed to showcase needs for handling graph data is discussed. What traditional do SQL databases offer for these cases, and how can it be solved with `Neo4j`. 
- Three business cases of why, how, and with what results organizations such as `US Army`, `Mosanto`, and `International Consortium of Investigative Journalists (ICIJ)` tranform some of their data, processes, and applications to `Neo4j`.
- A brief discussion of what the `Neo4j` ecosystem consists of, how to get more information, and how to actively start using for your business cases.

### Session Story (10 mins) - the `James Bond` movies datasets
- A dataset of `James Bond` movies is collected by harvesting data from the `IMBD` (www.imdb.com) site and merged with a previously gathered data from `Wikipedia`. This dataset contains basic information about the movies: `IMDB` url, movie name, year of release, synopsis, `IMDB` votes, directors, and actors.
- The dataset is sent through a data processing pipeline consisting of two `Stanford NLP` taggers - Part-of-Speech and Named Entity - to extract *Key Phrases* and *Named Entities* from the synopses.
- All entities are persisted into a graph managed by a local *Dockerized* `Neo4j` container, creatded by using [neo4j-algo-apoc github repo](https://github.com/DIS-SIN/neo4j-algo-apoc).
- A few Cypher queries are used to showcase: how to aggregate data, how to find out relationships, and how to detect similarities in the dataset.
- How can this graph database can be enriched and what purposes it might serve?

#### For more information:
- [Presentation](https://www.beautiful.ai/player/-LhIka_3VR69748r-tqQ)

### Hands-on Lab (30 mins) - `the devil is in details`
1. Get the dataset: 
- harvesting data (movie, directors, actors, rarting, votes, ...) from `imdb.com` with `scrapper-0.1:imdb` as a micro service
- reusing existing data from `Wikipedia` from a tab-separated file

2.  Process the harvested data through a data pipeline called `pipeline-0.1:imdb`
- `stanford-nlp-3.9.2:pos`: Stanford NLP Part-of-Speech tagger docker (as micro service)
- `stanford-nlp-3.9.2:ner`: Stanford NLP Named Entity tagger docker (as micro service)
- store the entities and their relationships in a storage called `neo4j-3.5.5:algo-apoc`, which is a neo4j docker with APOC and ALGO libraries.
    
3. Visualization and queries with Neo4j browser, and answering a few questions
- how the meta graph look like?
- what are the representing features of some movies?
- what is the number pf average votes per movie of an actor?
- what actors, directors participated in most of the film production?
- what actors could have worked with same directors many times (strong influence)


#### For more information:
- [Hands-on](/session_1/README.md)
