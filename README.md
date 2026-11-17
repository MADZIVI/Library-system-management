Library-system-management
1. Question base demonstrate and a database using mysql with 20 recordes each table  :
- ERD(bussiness rules)
- Normalisation to 3NF
- Primary/foreign keys
- Constraints
- Views
- Stored procedures
- Functions
- Triggers
- Joins
- Subqueries
- CTEs
- Window functions
- Indexes
- Query optimisation

Schema (3NF, 20 records per table) — 6 tables matching the ERD: `user`, `book`, `loan`, `reservation`, `fine`, `incident_report`.

**How each criterion is covered:**

| Requirement | Implementation |
|---|---|
| **ERD business rules** | Enforced as triggers/procedures: unique ISBN & email (UNIQUE), Rule 3 max 5 active loans, Rule 4 due date = borrow +14 (trigger), Rule 5/6 auto-fine on late return, Rule 7 reservations block borrowing, Rule 8 admin-only book edits, Rule 9 incidents auto-set book status |
| **Normalisation to 3NF** | Documented in comments — atomic values, no partial/transitive dependencies (e.g. book details never duplicated in `loan`) |
| **PK/FK + Constraints** | Surrogate PKs, all FKs with CASCADE/RESTRICT, CHECK constraints on dates and amounts, ENUM domain constraints |
| **Views** | `v_active_loans`, `v_overdue_books`, `v_outstanding_fines`, `v_user_activity`, `v_book_availability` (matching your Section 5 reports) |
| **Stored procedures** | `sp_issue_book`, `sp_return_book`, `sp_pay_fine`, `sp_add_book` (with admin role check) |
| **Functions** | `fn_calculate_fine` (R5/day), `fn_active_loans`, `fn_days_overdue` |
| **Triggers** | Due-date setter, auto-fine on return, status-block on insert, incident status updater |
| **Joins / Subqueries / CTEs / Window functions** | Dedicated demo queries for each, including `WITH RECURSIVE`, RANK(), SUM() OVER, LAG() |
| **Indexes & optimisation** | Composite indexes on FKs, due dates, and title; `EXPLAIN` before/after comparisons |


2. Use Case Diagram — 

**Purpose:** The use case diagram shows *who* interacts with the LMS and *what* each type of user is allowed to do. It maps directly onto the business rules (Rules 2, 3, 7, 8).

### Actors

| Actor | Description |
|---|---|
| **Library User** (Student / Staff) | A registered member who borrows, returns, searches and reserves books. Must be registered before borrowing anything (Rule 2). |
| **Librarian** | Staff member who issues and returns books on the counter, processes fines, and views reports. |
| **Admin** | Has full system access. The *only* actor allowed to add, update or delete books and user records (Rule 8). |

The Librarian and Admin are drawn as **generalisations** of the Library User (they can do everything a user can, plus more).

### Use Cases and Relationships

**User-level functions:**
- **Register / Login** — every other function requires authentication first. All other use cases **«include»** this one.
- **Search Catalogue** — browse books by title/author/ISBN and view availability status.
- **Borrow Book** — «include» Check Registration (Rule 2) and Check Loan Limit (Rule 3 — max 5 active loans); «extend» → *Calculate Fine* only when the return is late.
- **Return Book** — records the return date; automatically triggers fine calculation if past the due date (Rule 5 & 6).
- **Reserve Book** — «extend» Borrow Book: an active reservation blocks other users from borrowing that book (Rule 7). When the reserved book is released, the reserver receives a notification.
- **View Notifications** — receives due-date reminders by email/SMS.

**Librarian-level functions:**
- **Issue Book / Return Book** — the counter-side versions of borrowing and returning.
- **Process Fine Payment** — records payment date and updates fine status (Rule 10).

**Admin-level functions:**
- **Manage Books** (add/update/delete) and **Manage Users** — the system checks `User_Type = 'Admin'` before allowing these operations (Rule 8).
- **Generate Reports** — loan history, overdue items, fine summaries.

**Exception path:** **Report Incident** (damaged/lost book) is linked to the user who had the book, and updates the book status to *Lost* or *Damaged* (Rule 9).


## 3.3 Physical Data Flow Diagram (DFD) — Explanation

**Purpose:** The physical DFD shows *how data actually moves* through the implemented system — which process reads from or writes to which database table (data store). Your diagram is a **Level 1 DFD** (explosion of the single "LMS" process in the context diagram).

### External Entities (sources/sinks of data)
- **Library User** — sends registration, search, borrow, reserve requests; receives notifications.
- **Librarian** — sends issue/return/payment actions.
- **Admin** — sends book/user maintenance actions.
- **Email/SMS Gateway** — receives reminder messages.

### Processes

| # | Process | Input flow | Output flow |
|---|---|---|---|
| 1.0 | **Authenticate & Register User** | User details (from User) | User record → D1; confirmation back |
| 2.0 | **Search Catalogue** | Search criteria | Book availability → User |
| 3.0 | **Issue Book** | ISBN + UserID | New loan → D3; book status update → D2; due date reminder → Gateway |
| 4.0 | **Return Book** | Loan ID | Return date → D3; if late, fine → D5; book status → D2 |
| 5.0 | **Reserve Book** | ISBN + UserID | Reservation → D4; status change → D2 |
| 6.0 | **Process Fine** | Payment details | Paid date → D5; receipt → Librarian |
| 7.0 | **Generate Reports** | Report request | Reports → Librarian/Admin |
| 8.0 | **Maintain Books & Users** | Add/update/delete data | Book/User records → D1, D2 |

### Data Stores (these map 1-to-1 to your MySQL tables)

| Store | Contents | Read by | Written by |
|---|---|---|---|
| **D1** | User | 1.0, 3.0, 5.0 | 1.0, 8.0 |
| **D2** | Book | 2.0, 3.0, 5.0 | 3.0, 4.0, 5.0, 8.0 |
| **D3** | Loan | 4.0, 6.0, 7.0 | 3.0, 4.0 |
| **D4** | Reservation | 3.0, 7.0 | 5.0 |
| **D5** | Fine | 6.0, 7.0 | 4.0, 6.0 |
| **D6** | Incident Report | 7.0 | 4.0 (via report) |

### Key data flows
- *User ID + ISBN* flows into **3.0 Issue Book**, which checks D1 (registered? loan limit?) and D2 (available or reserved?) before writing to D3 — this is Rules 2, 3 and 7 happening as data checks.
- *Return date* flowing into **4.0 Return Book** triggers the *fine calculation* flow into D5 only when the return date is later than the due date — Rule 6 as a conditional data flow.
- *Reminder messages* flow from 3.0 and 4.0 to the **Email/SMS Gateway** — your service rule from the PIECE analysis.

  ## PICTURE OD DIAGRAMS 
1. ERD PICTURE https://github.com/MADZIVI/Library-system-management/blob/main/ERD.png

2. DIALOGUE CHART PICTURE  https://github.com/MADZIVI/Library-system-management/blob/main/Dialogue%20Chart.png

3. DFD PICTURE https://github.com/MADZIVI/Library-system-management/blob/main/DFD.png

4. USECASE PICTURE https://github.com/MADZIVI/Library-system-management/blob/main/USECASE.png

5. GENT CHART PICTURE https://github.com/MADZIVI/Library-system-management/blob/main/gent%20chart.png

