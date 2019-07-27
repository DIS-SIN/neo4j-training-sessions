import React from "react";
import { Query } from "react-apollo";
import gql from "graphql-tag";
import "./CourseList.css";
import { withStyles } from "@material-ui/core/styles";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  Tooltip,
  Paper,
  TableSortLabel,
  Typography,
  TextField,
  Divider
} from "@material-ui/core";

const styles = theme => ({
  root: {
    maxWidth: 700,
    marginTop: theme.spacing.unit * 3,
    overflowX: "auto",
    margin: "auto"
  },
  img: {
    maxWidth: 25,
    maxHeight: 25
  },
  table: {
    minWidth: 700
  },
  textField: {
    marginLeft: theme.spacing.unit,
    marginRight: theme.spacing.unit,
    minWidth: 300
  }
});

class CourseList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      order_c: "asc",
      orderBy_c: "code",
      order_i: "asc",
      orderBy_i: "name",
      page: 0,
      rowsPerPage: 3,
      usernameFilter: ""
    };
  }

  handleSortRequest_c = property => {
    const orderBy_c = property;
    let order_c = "desc";

    if (this.state.orderBy_c === property && this.state.order_c === "desc") {
      order_c = "asc";
    }

    this.setState({ order_c, orderBy_c });
  };

  handleSortRequest_i = property => {
    const orderBy_i = property;
    let order_i = "desc";

    if (this.state.orderBy_i === property && this.state.order_i === "desc") {
      order_i = "asc";
    }

    this.setState({ order_i, orderBy_i });
  };

  getFilter = () => {
    return this.state.usernameFilter.length > 0
      ? { name_contains: this.state.usernameFilter }
      : {};
  };

  handleFilterChange = filterName => event => {
    const val = event.target.value;

    this.setState({
      [filterName]: val
    });
  };

  render() {
    const { order_c, orderBy_c, order_i, orderBy_i } = this.state;
    const { classes } = this.props;

    return (
      <Paper className={classes.root}>
        <Typography variant="h3" gutterBottom>
          Courses by selected instructor: {this.state.usernameFilter}
        </Typography>

        <TextField
          id="search"
          label="User Name Contains"
          className={classes.textField}
          value={this.state.usernameFilter}
          onChange={this.handleFilterChange("usernameFilter")}
          margin="normal"
          variant="outlined"
          type="text"
          InputProps={{
            className: classes.input
          }}
        />

        <Query
          query={gql`
            query instructorPaginateQuery(
              $first: Int
              $offset: Int
              $orderBy: [_InstructorOrdering]
              $filter: _InstructorFilter
            ) {
              Instructor(
                first: $first
                offset: $offset
                orderBy: $orderBy
                filter: $filter
              ) {
                _id
                name
                instructor_of {
                  uid
                }
              }
            }
          `}
          variables={{
            first: this.state.rowsPerPage,
            offset: this.state.rowsPerPage * this.state.page,
            orderBy: this.state.orderBy_i + "_" + this.state.order_i,
            filter: this.getFilter()
          }}
        >
          {({ loading, error, data }) => {
            console.log(this.getFilter());
            if (loading) return <p>Loading...</p>;
            if (error) return <p>Error</p>;

            return (
              <Table className={this.props.classes.table}>
                <TableHead>
                  <TableRow>
                    <TableCell
                      key="name"
                      sortDirection={orderBy_i === "name" ? order_i : false}
                    >
                      <Tooltip
                        title="Sort"
                        placement="bottom-start"
                        enterDelay={300}
                      >
                        <TableSortLabel
                          active={orderBy_i === "name"}
                          direction={order_i}
                          onClick={() => this.handleSortRequest_i("name")}
                        >
                          Name
                        </TableSortLabel>
                      </Tooltip>
                    </TableCell>
                    <TableCell>Taught offerings</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {data.Instructor.map(n => {
                    return (
                      <TableRow key={n._id}>
                        <TableCell component="th" scope="row">
                          {n.name}
                        </TableCell>
                        <TableCell>{n.instructor_of.length}</TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            );
          }}
        </Query>

        <Divider/>

        <Query
          query={gql`
            query coursePaginateQuery(
              $name: String!
              $first: Int
              $offset: Int
              $orderBy: [_CourseOrdering]
            ) {
              CoursesOfInstructor(name: $name, first: $first, offset: $offset, orderBy: $orderBy) {
                _id
                code
                title
              }
            }
          `}
          variables={{
            name: this.state.usernameFilter,
            first: this.state.rowsPerPage,
            offset: this.state.rowsPerPage * this.state.page,
            orderBy: this.state.orderBy_c + "_" + this.state.order_c
          }}
        >
          {({ loading, error, data }) => {
            if (loading) return <p>Loading...</p>;
            if (error) return <p>Error</p>;

            return (
              <Table className={this.props.classes.table}>
                <TableHead>
                  <TableRow>
                    <TableCell
                      key="code"
                      sortDirection={orderBy_c === "code" ? order_c : false}
                    >
                      <Tooltip
                        title="Sort"
                        placement="bottom-start"
                        enterDelay={300}
                      >
                        <TableSortLabel
                          active={orderBy_c === "code"}
                          direction={order_c}
                          onClick={() => this.handleSortRequest_c("code")}
                        >
                          Code
                        </TableSortLabel>
                      </Tooltip>
                    </TableCell>
                    <TableCell
                      key="title"
                      sortDirection={orderBy_c === "title" ? order_c : false}
                    >
                      <Tooltip
                        title="Sort"
                        placement="bottom-end"
                        enterDelay={300}
                      >
                        <TableSortLabel
                          active={orderBy_c === "title"}
                          direction={order_c}
                          onClick={() => this.handleSortRequest_c("title")}
                        >
                          Title
                        </TableSortLabel>
                      </Tooltip>
                    </TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {data.CoursesOfInstructor.map(n => {
                    return (
                      <TableRow key={n._id}>
                        <TableCell component="th" scope="row">
                          {n.code}
                        </TableCell>
                        <TableCell>{n.title}</TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            );
          }}
        </Query>
      </Paper>
    );
  }
}

export default withStyles(styles)(CourseList);
