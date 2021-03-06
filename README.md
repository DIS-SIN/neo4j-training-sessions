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
    - Step by step help attendees perfoming tasks needed for an end-to-end showcase.
    - Providing an approach how to deal with a real-life example with a set of selective technologies and tools,properly constructed, and tested.
    - Identifying pieces that can be reused later in related projects.
    - Simple to reproduce so every attendee can self-repeat the hands-on whenever and wherever needed.
    - Document well enough so it would be easy to use.

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
- [Presentation](https://www.beautiful.ai/player/-LipKl2Hemgu7Pd7XGC0)

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

---

## Session 2: *Next* job recommendations

### Business case
- Objective: recommending `natural next jobs` from 1M+ job ads.
- Approach:
    + Suggesting jobs based on `collaborative-based filtering` - top most common transitions from a job
    + Using a standard occupation classification system with `tree-like` structure and `clusters` of verified job titles serving as anchor points for matching users' and job ads' job titles. Matching job titles based on `content-based filtering` using Natural Language Processing with ML models for sentence tagging to extract `key phrases` from job title such as `software developer`, `project manager`, ...
    + Improve recommendation quality by using geographical information of user's and job ads' locations

### Technology aspects
- Datasets/APIs/toolkits:
    + `Kaggle Job Recommendation Challenge` contributed by `CareerBuilder`.
    + Standard Occupaction Classifications (SOC) 2010 from US Bureau of Labour and Statistics (BLS) and O*NET organization for occupations, job titles, tech skills, tools used.
    + Stanford Core Natural Language Processing - `Staford CoreLNP` version `3.9.2` for Part-of-Speech tagging job titles, turning them into `key phrases`.
    + Natural Language Toolkit - `NLTK` version `3.4.3` for lemmatization and stemming of English words.
    + OpenStreetMap - `OSM` server for geocoding location's coordinates.
- Technology framework:
    + Neo4j graph database
    + Docker containers as Micro Services:
        * Neo4j `CE` version `3.5.5`, exposing via both `HTTP` (7474) and `Bolt` (7687) interfaces
        * Stanford `3.9.2` POS Tagger, exposing via socket (8001)
        * NLTK-wrapped around by Python `bottle` web framework and `waitress` WSGI server
    + Neo4j browser for query executions

#### For more information:
- [Presentation](https://www.beautiful.ai/player/-LipKeK17bpKUNWAvUpb)

#### For more information:
- [Hands-on](/session_2/README.md)

---

## Session 3: Large data import and simple analysis of survey data

### Business case
- Objective: provide simple statistics for school survey response rate
- Approach:
    + Importing current dataset of registrations and survey reponses
    + Providing simple statistics

### Technology aspects
- Using `neo4j-admin` special `import` feature for large data import at high performance.
- Preparing data - normalize, entities, relationships, headers, etc for import
- Using `apoc.csv.export.query` to export data in `csv` format.

#### For more information:
- [Presentation](https://www.beautiful.ai/player/-LipKZjJUAFuawWsdyOQ)

#### For more information:
- [Hands-on](/session_3/README.md)

---

## Session 4: Data streaming with Kafka

### Business case
- Objective: connecting various apps into the Kafka - Neo4j streaming framework, reducing connectivity  complexity, and enabling data consuming for different scenarios.
- Approach:
    + Integration of Kafka with Neo4j
    + Showcasing ability using different clients (command-line, Java, Python, HTTP)

### Technology aspects
- Creating and running a complete `Kafka` cluster on a single machine.
- Testing connectivity and data producing/consuming features for various clients.
- Showcasing Neo4j `just-in-time data warehousing`.

#### For more information:
- [Presentation](https://www.beautiful.ai/player/-LjH9fE-NRPNuX-QZlkx)

#### For more information:
- [Hands-on](/session_4/README.md)

---

## Session 5: Data visualization

### Business case
- Objectives:

  + Demonstrate capabilities of visualizing to gain insights by discovery.
  + Introduction of different visualization tools and how to use them.

- Approach:
  + CSPS registration/survey dataset
  + Browser

### Technology aspects

  + Tools:
    * `GraphXR` cloud, JS scripts from browser connect to local `Neo4j` instance
    * `Gephi` standalone app, data streaming from a `Neo4j` instance
    * `Node.js` app with `Neovis.js`, perform `Cypher` queries to backend `Neo4j` instance.

#### For more information:
- [Presentation](https://www.beautiful.ai/player/-LjMvJyVTefrlnUmd0mE)

#### For more information:
- [Hands-on](/session_5/README.md)

---

## Session 6: Graph exploration and algorithms

### Business case
- Objectives:

  + Demonstrate capabilities of exploring the graph visually
  + Using virtual graph to group, delegate, refactor subgraphs
  + Showing capabilities with tabular data

- Approach:
  + CSPS registration/survey dataset
  + Browser

### Technology aspects

  + Tools:
    * Exploration with pure `Cypher`
    * Using `virtual` `nodes` and `relationships`
    * Using `Harmonic Centrality` and `Louvain Community Detection`

#### For more information:
- No presentation for this session, only hands-on.

#### For more information:
- [Hands-on](/session_6/README.md)

---

## Session 7: The GRAND Stack

### Business case

Modern tools for building full stack apps

GRANDstack is a combination of technologies that work together to enable developers to build data intensive full stack applications. The components of GRANDstack are:

- GraphQL - A new paradigm for building APIs, GraphQL is a way of describing data and enabling clients to query it.
- React - A JavaScript library for building component based reusable user interfaces.
- Apollo - A suite of tools that work together to create great GraphQL workflows.
- Neo4j Database - The native graph database that allows you to model, store, and query your data the same way you think about it: as a graph.

### Technology aspects

  + Tools:
    * React with Apollo
    * Neo4-GraphQL database plugin
    * neo4j-graphql-js (& Neo4j Javascript Bolt driver)
    * GraphiQL

#### For more information:
- No presentation for this session, only hands-on.

#### For more information:
- [Hands-on](/session_7/README.md)

---

## Session 8: Streaming and visualizing data

### Demonstrating concepts of streaming and visualizing data

- CSPS data consists of course/offering/registration/learner/survey/etc entities

- `GRANDstack` is a combination of technologies that work together to enable developers to build `data intensive full stack applications`.

#### For more information:
- [Hands-on](/session_8/README.md)
