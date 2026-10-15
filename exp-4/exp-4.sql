-- EXPERIMENT 4
-- JOINs, subqueries, set-operation simulations, and EXPLAIN in MySQL.
USE CompanyDB;

-- QUERY 1: INNER JOIN
-- Return employees that have a matching department row.
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;

-- QUERY 2: LEFT JOIN
-- Return all departments, including departments without an employee match.
-- For a department without employees, employee columns would be NULL.
SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name,
    e.salary
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
ORDER BY d.dept_id, e.emp_id;

-- QUERY 3: SELF-JOIN
-- Pair different employees who work in the same department.
-- e1.emp_id < e2.emp_id avoids pairing a row with itself and avoids reversed duplicates.
SELECT
    e1.emp_name AS employee_1,
    e2.emp_name AS employee_2,
    e1.dept_id,
    e1.salary AS salary_1,
    e2.salary AS salary_2
FROM Employee e1
INNER JOIN Employee e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id
ORDER BY e1.dept_id, e1.emp_id, e2.emp_id
LIMIT 10;

-- QUERY 4: THREE-WAY JOIN
-- Combine employee, department, and project information.
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
INNER JOIN Project p ON e.project_id = p.project_id
ORDER BY d.dept_name, e.emp_name;

-- QUERY 5: CORRELATED SUBQUERY
-- Return employees who earn more than the average salary in their own department.
-- The inner query is correlated because it uses the outer row's e.dept_id.
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
)
ORDER BY e.dept_id, e.salary DESC;

-- QUERY 6: EXISTS
-- Return departments with at least one employee earning more than 80,000.
SELECT
    d.dept_id,
    d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 80000
)
ORDER BY d.dept_id;

-- QUERY 7: SIMULATED INTERSECT
-- Find employees who are in department 1 AND earn more than 70,000.
-- In the Experiment 3 sample data, department_id 1 is Engineering.
-- The source PDF's prose calls this department IT; that name does not match Experiment 3's data.
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE dept_id = 1
)
AND emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
)
ORDER BY emp_id;

-- QUERY 8: SIMULATED EXCEPT
-- Find employees earning more than 70,000, excluding department 1.
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
)
AND emp_id NOT IN (
    SELECT emp_id
    FROM Employee
    WHERE dept_id = 1
)
ORDER BY emp_id;

-- QUERY 9A: EXPLAIN for an INNER JOIN
-- Inspect the plan the MySQL optimizer chooses for the query.
EXPLAIN
SELECT e.emp_name, d.dept_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
WHERE e.salary > 70000;

-- QUERY 9B: EXPLAIN for the correlated subquery
EXPLAIN
SELECT e.emp_name, e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- QUERY 9C: EXPLAIN for EXISTS
EXPLAIN
SELECT d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 80000
);
