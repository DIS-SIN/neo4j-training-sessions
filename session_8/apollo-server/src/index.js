const { makeAugmentedSchema, inferSchema } = require("neo4j-graphql-js");
const { ApolloServer } = require("apollo-server");
const { v1: neo4j } = require("neo4j-driver");

const driver = neo4j.driver(
  process.env.NEO4J_URI || "bolt://neo4j-session-8:7687",
  neo4j.auth.basic(
    process.env.NEO4J_USER || "neo4j",
    process.env.NEO4J_PASSWORD || "##dis@da2019##"
  ),
  { encrypted: true }
);

const schemaInferenceOptions = {
  alwaysIncludeRelationships: false
};

const customTypeDefs = `
  type Query  {
    CoursesOfInstructor(name:String!): [Course] @cypher(statement:"MATCH (i:Instructor) WHERE i.name CONTAINS $name MATCH(i)-[:INSTRUCTOR_OF]-()-[:COURSE_OF]-(c:Course) RETURN DISTINCT(c) AS c")
  }
`;

const inferAugmentedSchema = driver => {
  return inferSchema(driver, schemaInferenceOptions).then(result => {
    console.log("TYPEDEFS:");
    console.log(result.typeDefs);

    return makeAugmentedSchema({
      typeDefs: result.typeDefs + customTypeDefs
    });
  });
};

const createServer = augmentedSchema =>
  new ApolloServer({
    schema: augmentedSchema,
    // inject the request object into the context to support middleware
    // inject the Neo4j driver instance to handle database call
    context: ({ req }) => {
      return {
        driver,
        req
      };
    }
  });

const port = process.env.GRAPHQL_LISTEN_PORT || 4000;

inferAugmentedSchema(driver)
  .then(createServer)
  .then(server => server.listen(port, "0.0.0.0"))
  .then(({ url }) => {
    console.log(`GraphQL API ready at ${url}`);
  })
  .catch(err => console.error(err));
