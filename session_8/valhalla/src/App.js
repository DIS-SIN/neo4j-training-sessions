import React, { Component } from "react";

import { ApolloClient } from 'apollo-client';
import { getMainDefinition } from 'apollo-utilities';
import { ApolloLink, split } from 'apollo-link';
import { HttpLink } from 'apollo-link-http';
import { WebSocketLink } from 'apollo-link-ws';
import { InMemoryCache } from 'apollo-cache-inmemory';

import gql from 'graphql-tag';
import { Query } from 'react-apollo';

import "./App.css";
import CourseList from "./CourseList";

const httpLink = new HttpLink({
  uri: 'http://localhost:8000/graphql',
});

const wsLink = new WebSocketLink({
  uri: `ws://localhost:8000/graphql`,
  options: {
    reconnect: true,
  },
});

const terminatingLink = split(
  ({ query }) => {
    const { kind, operation } = getMainDefinition(query);
    return (
      kind === 'OperationDefinition' && operation === 'subscription'
    );
  },
  wsLink,
  httpLink,
);

const link = ApolloLink.from([terminatingLink]);

const cache = new InMemoryCache();

const subscription_client = new ApolloClient({
  link,
  cache,
});

const GET_MESSAGES = gql`
  query {
    messages {
      id
      content
    }
  }
`;

const MESSAGE_CREATED = gql`
  subscription {
    messageCreated {
      id
      content
    }
  }
`;

class Messages extends React.Component {
  componentDidMount() {
    this.props.subscribeToMore({
      document: MESSAGE_CREATED,
      updateQuery: (prev, { subscriptionData }) => {
        if (!subscriptionData.data) return prev;

        return {
          messages: [
            ...prev.messages,
            subscriptionData.data.messageCreated,
          ],
        };
      },
    });
  }

  render() {
    return (
      <ul>
        {this.props.messages.map(message => (
          <li key={message.id}>{message.content}</li>
        ))}
      </ul>
    );
  }
}

class App extends Component {
  render() {
    return (
      <div className="App">
        // <Query query={GET_MESSAGES} client={subscription_client}>
        //   {({ data, loading, subscribeToMore }) => {
        //     if (!data) {
        //       return null;
        //     }
        //
        //     if (loading) {
        //       return <span>Loading ...</span>;
        //     }
        //
        //     return (
        //       <Messages
        //         messages={data.messages}
        //         subscribeToMore={subscribeToMore}
        //       />
        //     );
        //   }}
        // </Query>

        <CourseList />
      </div>
    );
  }
}

export default App;
