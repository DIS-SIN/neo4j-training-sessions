from queue import Queue
from threading import Thread

from neo4j.v1 import GraphDatabase, Record
from neo4j.v1.types.graph import Node, Path, Relationship

class Neo4jAdapter(object):
    """
    Neo4jAdapter is a data access layer over Neo4j Python Bolt driver:
    - to access Neo4j database directly,
    - for multiple callers,
    - thread-safe.

    It supports following features:
    - implicitly keeps neo4j driver's sessions in a FIFO queue,
    - each user's transaction is carried out in a separate session,
    - three transaction functions: execute_one(), execute_sequential(), execute_parallel(),
    - each transaction function requires a work unit
    - a transaction with a single or multiple cypher queries with arguments and named arguments
    - allows to return none, one or all execution results.
    - convert the results (if required) into [nested] Python instances.
    
    Note: for more information see about a transaction functionsee
    https://neo4j.com/docs/developer-manual/current/drivers/sessions-transactions/
    """

    def __init__(self, database_credentials):
        """
        Create a Neo4j Bolt Driver based on given database credentials
        Create a thread-safe Queue instance to keep the driver sessions
        """
        self.driver = GraphDatabase.driver(
            database_credentials['neo4j_bolt_server'],
            auth=(
                database_credentials['neo4j_user'],
                database_credentials['neo4j_password']
            ),
        )
        self.session_queue = Queue()

    def close(self):
        """
        Explicitly close the Neo4j driver instance
        """
        self.driver.close()

    def get_session(self):
        """
        Sessions are  neo4j driver's sessions and kept a a FIFO queue.
        A new session is created while the queue is empty, 
        meaning they are in used by pending executions.

        The number of sessions in used at anytime is the sum of:
        - the number of pending execute_one() invocations
        - the number of pending execute_sequential() invocations
        - the total number of all cypher queries in pending execute_parallel() invocations
       
        All invocations by all threads using this Neo4jAdapter instance.
        """
        if self.session_queue.empty():
            return self.driver.session()
        else:
            return self.session_queue.get()

    def execute_one(
        self, work, mode="READ_ACCESS", need_result=True, **kw_args
    ):
        """
        This function is to use a work unit containing a cypher query. 
        
        It  passes all keyword arguments to the work unit, 
        execute it in READ_ACCESS or WRITE_ACCESS mode, 
        depending if the transaction can make any modifications 
        to any existing data inside the database.
        
        The function returns result of the execution if required.
        """
        if work is None:
            raise ValueError('No transaction function  is specified.')

        # acquire session from the queue
        session = self.get_session()

        r = self.__execute_transaction(session, work, mode, **kw_args)

        if need_result and r is not None:
            # result is always wrapped into a list if it is a single row
            result = [self.__convert_result(e) for e in r.records()]

        else:
            result = None

        # return the session back to the queue
        self.session_queue.put(session)

        return result

    def execute_sequential(
        self, query_list, need_result=True, last_only=False
    ):
        """
        This function is to run a list of query SEQUENTIALLY.
        
        It is used when there is a number of cypher queries 
        that must be executed in a given order 
        and no any two queries can be executed at the same time.

        Each query in the list consists of:
        - a work unit - a transaction function containing a cypher query
        - access mode
        - keyword arguments

        The function passes all the arguments to the work unit, 
        execute it in READ_ACCESS or WRITE_ACCESS mode, 
        depending if the transaction can make any modifications 
        to any existing data inside the database.
        
        The function returns result of the execution if required.
        """
        if query_list is None or len(query_list) == 0:
            raise ValueError('Empty query list.')

        # acquire session
        session = self.get_session()

        # Run transactions sequentially, one-by-one,
        # collect results into a list if required
        r_list = []
        for query in query_list:
            work_unit, mode, kwargs = query

            # If result is needed, collect them into the r_list
            if need_result:
                r = self.__execute_transaction(
                    session, work_unit, mode, **kwargs
                )
                r_list.append(
                    [self.__convert_result(e) for e in r.records()]
                    if r is not None else None
                )

            else:
                self.__execute_transaction(
                    session, work_unit, mode, **kwargs
                )

        # No need for result
        if not need_result:
            self.session_queue.put(session)  # release the session
            return

        # Only the last request is required.
        if last_only:
            result = r_list[-1] if len(r_list) > 0 else None
        else:
            result = r_list

        # release session
        self.session_queue.put(session)

        return result

    def execute_parallel(self, query_list, need_result=True):
        """
        This function is to run a list of query PARALLEL.
        
        It is used when there is a number of cypher queries
        that can be executed simultaneously without any problems.

        Each query in the list consists of:
        - a work unit - a transaction function containing a cypher query
        - arguments
        - keyword arguments

        The function passes all the arguments to the work unit,
        execute it in READ_ACCESS or WRITE_ACCESS mode,
        depending if the transaction can make any modifications
        to any existing data inside the database.

        The queries are executed in separate threads,
        result are collected if needed from a queue
        The function returns result of the execution if required.
        """
        if query_list is None or len(query_list) == 0:
            raise ValueError('Empty query list.')

        # create queue to collect result if needed
        result_queue = Queue() if need_result else None

        executors, start, remain = [], 0, len(query_list)
        while remain > 0:

            # acquire a session and create a thread to execute a query
            # 'start' value is passed as the execution thread id
            session = self.get_session()
            executor = Thread(
                target=self.__execute_thread,
                args=(start, session, query_list[start], result_queue),
            )
            executors.append(executor)
            start += 1
            remain -= 1

        for executor in executors:
            executor.start()

        for executor in executors:
            executor.join()

        # return if no need for results
        if not need_result:
            return

        # collect all results from the queue,
        # each has an exec_id to indicate from which thread
        r_dict = dict()
        while not result_queue.empty():
            exec_id, result = result_queue.get()
            r_dict[exec_id] = result

        # sort the results to return them in order queries were given
        r_list = [r_dict[exec_id] for exec_id in sorted(r_dict)]
        return r_list

    def __execute_thread(self, exec_id, session, query, queue=None):
        """
        Perform a __execute_transaction by dissect the query,
        assemble the result with execution id into the queue for results
        """
        if query is None:
            raise ValueError('Cannot execute empty query.')

        w_unit, mode, kwargs = query
        r = self.__execute_transaction(session, w_unit, mode, **kwargs)
        if queue is not None:
            queue.put([
                exec_id,
                [self.__convert_result(e) for e in r.records()]
                if r is not None else None
            ])

    @staticmethod
    def __execute_transaction(session, work_unit, mode, **kw_args):
        """
        Perform a read_transaction or write_transaction
        inside the session, passed keyword arguments
        """
        if mode == "READ_ACCESS":
            return session.read_transaction(work_unit, **kw_args)
        else:
            return session.write_transaction(work_unit, **kw_args)

    def __convert_result(self, result):
        """
        Convert [nested] statement results by identifying:
        - the nested structure
        - the data type
        https://neo4j.com/docs/developer-manual/current/drivers/cypher-values/
        """
        if isinstance(result, Record):
            return self.__convert_dict(result)
        if isinstance(result, Node):
            return self.__convert_node(result)
        if isinstance(result, Relationship):
            return self.__convert_relationship(result)
        if isinstance(result, Path):
            return self.__convert_path(result)
        if isinstance(result, list):
            return self.__convert_list(result)
        if isinstance(result, dict):
            return self.__convert_dict(result)
        return result

    @staticmethod
    def __convert_node(result):
        """ Convert a Neo4j node into a python dictionary """
        return {
            'id': result.id,
            'labels': set(result.labels),
            'properties': {i[0]: i[1] for i in result.items()}
        }

    @staticmethod
    def __convert_relationship(result):
        """ Convert a Neo4j relationship into a python dictionary """
        return {
            'id': result.id,
            'type': result.type,
            'properties': {i[0]: i[1] for i in result.items()}
        }

    def __convert_path(self, result):
        """
        Convert a Neo4j path, a sequence of node and relationships
        in Bolt statement result format into a python dictionary
        """
        return {
            'start_node': self.__convert_node(result.start_node),
            'end_node': self.__convert_node(result.end_node),
            'nodes': [
                self.__convert_node(n) for n in result.nodes
            ],
            'relationships': [
                self.__convert_relationship(r)
                for r in result.relationships
            ],
        }

    def __convert_list(self, result):
        """ Convert Bolt list """
        return [self.__convert_result(e) for e in result]

    def __convert_dict(self, result):
        """ Convert Bolt dict/map """
        return {k: self.__convert_result(v) for k, v in result.items()}
