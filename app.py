from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)
app.secret_key = "bidi_secret_key_123"

ADMIN_DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "lhy521016",
    "database": "bidi_db"
}

USERS = {
    "pm_user": {"password": "PmUser123!", "role": "project_manager_role"},
    "support_user": {"password": "Support123!", "role": "customer_support_role"}
}


def current_db_config():
    if session.get("username") in USERS:
        return {
            "host": ADMIN_DB_CONFIG["host"],
            "user": session["username"],
            "password": USERS[session["username"]]["password"],
            "database": ADMIN_DB_CONFIG["database"]
        }
    return ADMIN_DB_CONFIG


def get_connection(config=None):
    return mysql.connector.connect(**(config or current_db_config()))


def execute_select(query, params=None):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(query, params or ())
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows


def execute_modify(query, params=None):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params or ())
    conn.commit()
    rowcount = cursor.rowcount
    cursor.close()
    conn.close()
    return rowcount


def require_login():
    if "username" not in session:
        flash("Please log in first.", "error")
        return False
    return True


@app.route("/")
def index():
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    db_status = "Not connected"
    try:
        conn = get_connection(ADMIN_DB_CONFIG)
        if conn.is_connected():
            db_status = "Connected to MySQL (bidi_db)"
        conn.close()
    except Exception as e:
        db_status = f"Connection failed: {e}"

    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        user = USERS.get(username)

        if user and user["password"] == password:
            try:
                test_config = {
                    "host": ADMIN_DB_CONFIG["host"],
                    "user": username,
                    "password": password,
                    "database": ADMIN_DB_CONFIG["database"]
                }
                conn = get_connection(test_config)
                conn.close()
                session["username"] = username
                session["role"] = user["role"]
                flash("Login successful. Database queries now use this MySQL user.", "success")
                return redirect(url_for("dashboard"))
            except Error as e:
                flash(f"MySQL login failed for this user: {e}", "error")
        else:
            flash("Invalid username or password.", "error")

    return render_template("login.html", db_status=db_status)


@app.route("/logout")
def logout():
    session.clear()
    flash("Logged out successfully.", "success")
    return redirect(url_for("login"))


@app.route("/dashboard")
def dashboard():
    if not require_login():
        return redirect(url_for("login"))
    return render_template("dashboard.html")


@app.route("/employees")
def employees():
    if not require_login():
        return redirect(url_for("login"))

    department = request.args.get("department", "")
    sort = request.args.get("sort", "EmpID")

    sort_columns = {
        "EmpID": "e.EmpID",
        "Name": "e.Name",
        "HireDate": "e.HireDate",
        "Department": "d.Name"
    }
    order_by = sort_columns.get(sort, "e.EmpID")

    query = """
        SELECT e.EmpID, e.Email, e.Name, e.HireDate,
               d.Name AS DepartmentName, l.Address AS OfficeAddress, l.Country
        FROM Employee e
        JOIN Department d ON e.DepID = d.DepID
        JOIN Location l ON d.LID = l.LID
    """
    params = []

    if department:
        query += " WHERE d.Name = %s"
        params.append(department)

    query += f" ORDER BY {order_by}"

    try:
        rows = execute_select(query, params)
        departments = execute_select("SELECT Name FROM Department ORDER BY Name")
    except Error as e:
        flash(f"Database access error: {e}", "error")
        rows, departments = [], []

    return render_template(
        "employees.html",
        employees=rows,
        departments=departments,
        selected_department=department,
        selected_sort=sort
    )


@app.route("/projects", methods=["GET", "POST"])
def projects():
    if not require_login():
        return redirect(url_for("login"))

    if request.method == "POST":
        action = request.form.get("action")
        try:
            if action == "add_project":
                execute_modify(
                    """
                    INSERT INTO Project (Name, Budget, Status, Priority, startDate, deadline, CID)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        request.form.get("name"),
                        request.form.get("budget"),
                        request.form.get("status"),
                        request.form.get("priority"),
                        request.form.get("startDate"),
                        request.form.get("deadline"),
                        request.form.get("cid")
                    )
                )
                flash("Project added. The insert trigger wrote a ProjectAudit record.", "success")

            elif action == "update_project":
                execute_modify(
                    """
                    UPDATE Project
                    SET Budget = %s, Status = %s, Priority = %s, deadline = %s
                    WHERE PrID = %s
                    """,
                    (
                        request.form.get("new_budget"),
                        request.form.get("new_status"),
                        request.form.get("new_priority"),
                        request.form.get("new_deadline"),
                        request.form.get("prid")
                    )
                )
                flash("Project updated. The update trigger wrote a ProjectAudit record.", "success")

            elif action == "assign_work":
                work_prid = request.form.get("work_prid")
                work_empid = request.form.get("work_empid")
                started = request.form.get("started")

                project_exists = execute_select(
                    "SELECT PrID FROM Project WHERE PrID = %s",
                    (work_prid,)
                )
                employee_exists = execute_select(
                    "SELECT EmpID FROM Employee WHERE EmpID = %s",
                    (work_empid,)
                )

                if not project_exists:
                    flash("Please choose an existing project.", "error")
                elif not employee_exists:
                    flash("Please choose an existing employee.", "error")
                else:
                    execute_modify(
                        """
                        INSERT INTO Works (PrID, EmpID, started)
                        VALUES (%s, %s, %s)
                        """,
                        (work_prid, work_empid, started)
                    )
                    flash("Employee assigned. If the date is too early, the trigger blocks this action.", "success")

            elif action == "delete_project":
                execute_modify("DELETE FROM Project WHERE PrID = %s", (request.form.get("delete_prid"),))
                flash("Project deleted. The delete trigger wrote a ProjectAudit record.", "success")

        except Error as e:
            flash(f"Database error: {e}", "error")
        return redirect(url_for("projects"))

    status_filter = request.args.get("status", "")
    priority_filter = request.args.get("priority", "")
    customer_filter = request.args.get("customer", "")
    sort = request.args.get("sort", "PrID")

    sort_columns = {
        "PrID": "p.PrID",
        "Name": "p.Name",
        "BudgetHigh": "p.Budget DESC",
        "BudgetLow": "p.Budget",
        "Deadline": "p.deadline",
        "Status": "p.Status",
        "Priority": "p.Priority"
    }
    order_by = sort_columns.get(sort, "p.PrID")

    project_query = """
        SELECT p.PrID, p.Name, p.Budget, p.Status, p.Priority,
               p.startDate, p.deadline, p.CID,
               c.Name AS CustomerName, c.Email AS CustomerEmail
        FROM Project p
        JOIN Customer c ON p.CID = c.CID
    """
    where_parts = []
    params = []

    if status_filter:
        where_parts.append("p.Status = %s")
        params.append(status_filter)
    if priority_filter:
        where_parts.append("p.Priority = %s")
        params.append(priority_filter)
    if customer_filter:
        where_parts.append("p.CID = %s")
        params.append(customer_filter)
    if where_parts:
        project_query += " WHERE " + " AND ".join(where_parts)
    project_query += f" ORDER BY {order_by}"

    try:
        projects_data = execute_select(project_query, params)
        customers = execute_select("SELECT CID, Name FROM Customer ORDER BY CID")
        project_options = execute_select("SELECT PrID, Name, startDate FROM Project ORDER BY PrID")
        employees_list = execute_select("SELECT EmpID, Name FROM Employee ORDER BY EmpID")
        works = execute_select("""
            SELECT w.PrID, p.Name AS ProjectName, w.EmpID, e.Name AS EmployeeName, w.started
            FROM Works w
            JOIN Project p ON w.PrID = p.PrID
            JOIN Employee e ON w.EmpID = e.EmpID
            ORDER BY w.PrID, w.EmpID
        """)
    except Error as e:
        flash(f"Database access error: {e}", "error")
        projects_data, customers, project_options, employees_list, works = [], [], [], [], []

    return render_template(
        "projects.html",
        projects=projects_data,
        customers=customers,
        project_options=project_options,
        employees_list=employees_list,
        works=works,
        statuses=["Planned", "Active", "Completed"],
        priorities=["Low", "Medium", "High"],
        selected_status=status_filter,
        selected_priority=priority_filter,
        selected_customer=customer_filter,
        selected_sort=sort
    )


@app.route("/overview")
def overview():
    if not require_login():
        return redirect(url_for("login"))
    try:
        rows = execute_select("SELECT * FROM vw_project_overview ORDER BY PrID")
    except Error as e:
        flash(f"Database access error: {e}", "error")
        rows = []
    return render_template("overview.html", rows=rows)


@app.route("/audit")
def audit():
    if not require_login():
        return redirect(url_for("login"))
    try:
        rows = execute_select("""
            SELECT AuditID, PrID, ProjectName, ActionType,
                   OldBudget, NewBudget, OldStatus, NewStatus,
                   ChangedBy, ActionTime
            FROM ProjectAudit
            ORDER BY AuditID DESC
        """)
    except Error as e:
        flash(f"Database access error: {e}", "error")
        rows = []
    return render_template("audit.html", rows=rows)


if __name__ == "__main__":
    app.run(debug=True)

