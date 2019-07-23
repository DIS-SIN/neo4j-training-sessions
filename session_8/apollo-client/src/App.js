import React, { Component } from "react";
import "./App.css";
import CourseList from "./CourseList";

class App extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img
            src={process.env.PUBLIC_URL + "/img/grandstack.png"}
            className="App-logo"
            alt="logo"
          />
          <h1 className="App-title">Welcome to GRANDstack</h1>
        </header>

        <CourseList />
      </div>
    );
  }
}

export default App;
