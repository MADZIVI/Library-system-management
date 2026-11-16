-- LIBRARY MANAGEMENT SYSTEM (LMS) - MySQL Implementation
-- Vaal University of Technology - Information Systems
-- Section 2: Database Demonstration

-- 1. TABLE CREATION 

-- 1.1 USER TABLE 
CREATE TABLE `user` (
    UserID            INT AUTO_INCREMENT,
    First_Name        VARCHAR(50)  NOT NULL,
    Last_Name         VARCHAR(50)  NOT NULL,
    Email             VARCHAR(100) NOT NULL,
    Phone             VARCHAR(15),
    Registration_Date DATE         NOT NULL DEFAULT (CURRENT_DATE),
    User_Type         ENUM('Student','Staff','Librarian','Admin') NOT NULL DEFAULT 'Student',
    CONSTRAINT pk_user PRIMARY KEY (UserID),
    CONSTRAINT uq_user_email UNIQUE (Email)                       -- Rule: unique identity
);

-- 1.2 BOOK TABLE
CREATE TABLE book (
    ISBN             VARCHAR(20),
    Title            VARCHAR(150) NOT NULL,
    Author           VARCHAR(100) NOT NULL,
    Publisher        VARCHAR(100),
    Publication_Year SMALLINT,
    Status           ENUM('Available','Borrowed','Reserved','Lost','Damaged') NOT NULL DEFAULT 'Available',
    CONSTRAINT pk_book PRIMARY KEY (ISBN)                          -- Rule 1: unique ISBN
);

--1.3 LOAN TABLE
CREATE TABLE loan (
    LoanID      INT AUTO_INCREMENT,
    UserID      INT          NOT NULL,
    ISBN        VARCHAR(20)  NOT NULL,
    Borrow_Date DATE         NOT NULL DEFAULT (CURRENT_DATE),
    Due_Date    DATE,
    Return_Date DATE,
    CONSTRAINT pk_loan PRIMARY KEY (LoanID),
    CONSTRAINT fk_loan_user FOREIGN KEY (UserID) REFERENCES `user`(UserID)
        ON UPDATE CASCADE ON DELETE RESTRICT,                     -- Rule 2: registered users only
    CONSTRAINT fk_loan_book FOREIGN KEY (ISBN) REFERENCES book(ISBN)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_due_after_borrow CHECK (Due_Date >= Borrow_Date),
    CONSTRAINT chk_return_after_borrow CHECK (Return_Date IS NULL OR Return_Date >= Borrow_Date)
);

--1.4 RESERVATION TABLE
CREATE TABLE reservation (
    ReservationID    INT AUTO_INCREMENT,
    UserID           INT          NOT NULL,
    ISBN             VARCHAR(20)  NOT NULL,
    Reservation_Date DATE         NOT NULL DEFAULT (CURRENT_DATE),
    Status           ENUM('Active','Completed','Cancelled') NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_res PRIMARY KEY (ReservationID),
    CONSTRAINT fk_res_user FOREIGN KEY (UserID) REFERENCES `user`(UserID),
    CONSTRAINT fk_res_book FOREIGN KEY (ISBN) REFERENCES book(ISBN)
);

--1.5 FINE TABLE
CREATE TABLE fine (
    FineID      INT AUTO_INCREMENT,
    LoanID      INT           NOT NULL,
    Amount      DECIMAL(8,2)  NOT NULL CHECK (Amount >= 0),
    Issued_Date DATE          NOT NULL DEFAULT (CURRENT_DATE),
    Paid_Date   DATE,
    Status      ENUM('Paid','Unpaid','Waived') NOT NULL DEFAULT 'Unpaid',
    CONSTRAINT pk_fine PRIMARY KEY (FineID),
    CONSTRAINT fk_fine_loan FOREIGN KEY (LoanID) REFERENCES loan(LoanID)
);

--1.6 INCIDENT_REPORT TABLE
CREATE TABLE incident_report (
    IncidentID    INT AUTO_INCREMENT,
    UserID        INT          NOT NULL,
    ISBN          VARCHAR(20)  NOT NULL,
    Report_Date   DATE         NOT NULL DEFAULT (CURRENT_DATE),
    Description   VARCHAR(255) NOT NULL,
    Action_Taken  VARCHAR(255),
    CONSTRAINT pk_incident PRIMARY KEY (IncidentID),
    CONSTRAINT fk_inc_user FOREIGN KEY (UserID) REFERENCES `user`(UserID),
    CONSTRAINT fk_inc_book FOREIGN KEY (ISBN) REFERENCES book(ISBN)
);


-- 2. NORMALISATION TO 3NF 
-- 1NF: All attributes are atomic (no repeating groups; e.g. no multi-
--      valued Author columns - each fact stored once per row).
-- 2NF: All non-key attributes depend on the WHOLE primary key.
--      e.g. In `loan`, Title/Author live in `book` - not duplicated here.
--      No partial dependencies exist because every PK is a single
--      surrogate key (UserID, ISBN, LoanID...).
-- 3NF: No transitive dependencies - non-key attributes do not depend on
--      other non-key attributes.
--      e.g. Fine.Amount does NOT store user name or book title; those
--      are reached through LoanID -> loan -> user/book. Due_Date is
--      derived (Borrow_Date + 14) but kept (materialised) for audit,
--      set ONLY by trigger - never by users - so no update anomalies.

-- 3. SAMPLE DATA - 20 RECORDS PER TABLE

-- 20 USERS 
INSERT INTO `user` (First_Name, Last_Name, Email, Phone, Registration_Date, User_Type) VALUES
('Lerato','Sebela','lerato.sebela@vut.ac.za','0712345671','2024-01-15','Student'),
('Henry','Madzivi','henry.madzivi@vut.ac.za','0712345672','2024-01-16','Student'),
('Palesa','Mashia','palesa.mashia@vut.ac.za','0712345673','2024-01-17','Student'),
('Naledi','Tsotetsi','naledi.tsotetsi@vut.ac.za','0712345674','2024-01-18','Student'),
('Andile','Ndwandwe','andile.ndwandwe@vut.ac.za','0712345675','2024-01-19','Staff'),
('Thabo','Mokoena','thabo.mokoena@vut.ac.za','0712345676','2024-02-01','Student'),
('Karabo','Dlamini','karabo.dlamini@vut.ac.za','0712345677','2024-02-02','Student'),
('Mpho','Dube','mpho.dube@vut.ac.za','0712345678','2024-02-03','Student'),
('Refilwe','Jones','refilwe.jones@vut.ac.za','0712345679','2024-02-04','Student'),
('Sipho','Nkosi','sipho.nkosi@vut.ac.za','0712345680','2024-02-05','Student'),
('Lungelo','Cele','lungelo.cele@vut.ac.za','0712345681','2024-02-06','Staff'),
('Ayanda','Buthelezi','ayanda.buthelezi@vut.ac.za','0712345682','2024-02-07','Student'),
('Kea','Mofokeng','kea.mofokeng@vut.ac.za','0712345683','2024-02-08','Student'),
('Tebogo','Radebe','tebogo.radebe@vut.ac.za','0712345684','2024-02-09','Student'),
('Nokuthula','Zulu','nokuthula.zulu@vut.ac.za','0712345685','2024-02-10','Student'),
('Bongani','Maseko','bongani.maseko@vut.ac.za','0712345686','2024-02-11','Student'),
('Dimpho','Khoza','dimpho.khoza@vut.ac.za','0712345687','2024-02-12','Student'),
('Katlego','Pillay','katlego.pillay@vut.ac.za','0712345688','2024-02-13','Librarian'),
('Vusi','Ndlovu','vusi.ndlovu@vut.ac.za','0712345689','2024-02-14','Librarian'),
('Grace','Admin','grace.admin@vut.ac.za','0712345690','2024-02-15','Admin');

-- 20 BOOKS
INSERT INTO book (ISBN, Title, Author, Publisher, Publication_Year, Status) VALUES
('9780439554936','Harry Potter and the Sorcerer''s Stone','J.K. Rowling','Scholastic',1997,'Available'),
('9780547928227','The Hobbit','J.R.R. Tolkien','Houghton Mifflin',1937,'Available'),
('9780062316097','Think Like a Monk','Jay Shetty','HarperOne',2020,'Available'),
('9780743273565','The Great Gatsby','F. Scott Fitzgerald','Scribner',1925,'Available'),
('9780451524935','1984','George Orwell','Signet Classics',1949,'Available'),
('9780061120084','To Kill a Mockingbird','Harper Lee','J.B. Lippincott',1960,'Available'),
('9780143127741','The Alchemist','Paulo Coelho','HarperOne',1988,'Available'),
('9780307474278','The Da Vinci Code','Dan Brown','Doubleday',2003,'Available'),
('9780316769488','The Catcher in the Rye','J.D. Salinger','Little, Brown',1951,'Available'),
('9781451673319','Fahrenheit 451','Ray Bradbury','Simon & Schuster',1953,'Available'),
('9780062315007','Sapiens','Yuval Noah Harari','Harper',2015,'Available'),
('9780385513227','The 7 Habits of Highly Effective People','Stephen Covey','Free Press',1989,'Available'),
('9781591846352','The Obstacle Is the Way','Ryan Holiday','Portfolio',2014,'Available'),
('9780140283334','The Odyssey','Homer','Penguin Classics',1998,'Available'),
('9780439023528','The Hunger Games','Suzanne Collins','Scholastic',2008,'Available'),
('9781408855652','Harry Potter and the Chamber of Secrets','J.K. Rowling','Bloomsbury',1998,'Available'),
('9780374533557','Thinking, Fast and Slow','Daniel Kahneman','Farrar, Straus',2011,'Available'),
('9780062457714','Atomic Habits','James Clear','Avery',2018,'Available'),
('9780812981605','The Power of Habit','Charles Duhigg','Random House',2012,'Available'),
('9780307887894','The Lean Startup','Eric Ries','Crown Business',2011,'Available');

--20 LOANS 
INSERT INTO loan (UserID, ISBN, Borrow_Date, Due_Date, Return_Date) VALUES
(1,'9780439554936','2025-09-01','2025-09-15','2025-09-14'),
(2,'9780062316097','2025-09-05','2025-09-19',NULL),
(3,'9780743273565','2025-09-10','2025-09-24','2025-09-25'),
(4,'9780547928227','2025-09-12','2025-09-26','2025-09-20'),
(5,'9780061120084','2025-09-15','2025-09-29','2025-09-28'),
(6,'9780451524935','2025-10-01','2025-10-15','2025-10-14'),
(7,'9780143127741','2025-10-03','2025-10-17','2025-10-16'),
(8,'9780307474278','2025-10-05','2025-10-19',NULL),
(9,'9780316769488','2025-10-07','2025-10-21','2025-10-18'),
(10,'9781451673319','2025-10-09','2025-10-23','2025-10-22'),
(11,'9780062315007','2025-10-11','2025-10-25','2025-10-24'),
(12,'9780385513227','2025-10-13','2025-10-27',NULL),
(13,'9781591846352','2025-10-15','2025-10-29','2025-10-26'),
(14,'9780140283334','2025-10-17','2025-10-31','2025-10-30'),
(15,'9780439023528','2025-10-19','2025-11-02','2025-11-01'),
(16,'9781408855652','2025-10-21','2025-11-04',NULL),
(17,'9780374533557','2025-10-23','2025-11-06','2025-11-05'),
(18,'9780062457714','2025-10-25','2025-11-08','2025-11-07'),
(19,'9780812981605','2025-10-27','2025-11-10','2025-11-09'),
(20,'9780307887894','2025-10-29','2025-11-12','2025-11-11');

--20 RESERVATIONS
INSERT INTO reservation (UserID, ISBN, Reservation_Date, Status) VALUES
(1,'9780062315007','2025-10-01','Completed'),
(2,'9780439554936','2025-10-02','Active'),
(3,'9780385513227','2025-10-03','Cancelled'),
(4,'9780143127741','2025-10-04','Completed'),
(5,'9780451524935','2025-10-05','Active'),
(6,'9780062457714','2025-10-06','Completed'),
(7,'9780812981605','2025-10-07','Completed'),
(8,'9780307887894','2025-10-08','Active'),
(9,'9780374533557','2025-10-09','Completed'),
(10,'9781408855652','2025-10-10','Active'),
(11,'9780439023528','2025-10-11','Completed'),
(12,'9780547928227','2025-10-12','Completed'),
(13,'9780307474278','2025-10-13','Active'),
(14,'9781591846352','2025-10-14','Completed'),
(15,'9780061120084','2025-10-15','Cancelled'),
(16,'9780316769488','2025-10-16','Completed'),
(17,'9781451673319','2025-10-17','Active'),
(18,'9780743273565','2025-10-18','Completed'),
(19,'9780062316097','2025-10-19','Active'),
(20,'9780140283334','2025-10-20','Completed');

-- 20 FINES 
INSERT INTO fine (LoanID, Amount, Issued_Date, Paid_Date, Status) VALUES
(2,25.00,'2025-10-01','2025-10-05','Paid'),
(3,10.00,'2025-09-26','2025-09-30','Paid'),
(8,40.00,'2025-11-01',NULL,'Unpaid'),
(12,15.00,'2025-10-30',NULL,'Unpaid'),
(16,5.00,'2025-11-05','2025-11-06','Paid'),
(1,0.00,'2025-09-15','2025-09-15','Paid'),
(4,0.00,'2025-09-27','2025-09-27','Paid'),
(5,0.00,'2025-09-30','2025-09-30','Paid'),
(6,0.00,'2025-10-16','2025-10-16','Paid'),
(7,0.00,'2025-10-18','2025-10-18','Paid'),
(9,0.00,'2025-10-22','2025-10-22','Paid'),
(10,0.00,'2025-10-24','2025-10-24','Paid'),
(11,0.00,'2025-10-26','2025-10-26','Paid'),
(13,0.00,'2025-10-30','2025-10-30','Paid'),
(14,0.00,'2025-11-01','2025-11-01','Paid'),
(15,0.00,'2025-11-03','2025-11-03','Paid'),
(17,0.00,'2025-11-07','2025-11-07','Paid'),
(18,0.00,'2025-11-09','2025-11-09','Paid'),
(19,0.00,'2025-11-11','2025-11-11','Paid'),
(20,0.00,'2025-11-13','2025-11-13','Paid');

-- 20 INCIDENT REPORTS
INSERT INTO incident_report (UserID, ISBN, Report_Date, Description, Action_Taken) VALUES
(2,'9780062316097','2025-10-25','Water damage on cover','User warned; book sent for repair'),
(8,'9780307474278','2025-11-02','Pages torn out by user','Replacement fee charged'),
(12,'9780385513227','2025-11-05','Book misplaced in wrong section','Re-shelved correctly'),
(16,'9781408855652','2025-11-08','Spine damaged from mishandling','Sent to bindery'),
(1,'9780062315007','2025-10-05','Minor coffee stain','No action; noted'),
(3,'9780743273565','2025-09-26','Returned with bent pages','User fined R10'),
(5,'9780061120084','2025-10-02','Cover tear','Repaired by library staff'),
(6,'9780451524935','2025-10-16','Writing found on margins','Cleaning; user warned'),
(7,'9780143127741','2025-10-20','Lost dust jacket','Logged; no charge'),
(9,'9780316769488','2025-10-19','Bent back cover','User warned'),
(10,'9781451673319','2025-10-24','Loose pages','Re-glued'),
(11,'9780062315007','2025-10-28','Highlighter marks found','User fined R20'),
(13,'9781591846352','2025-10-29','Cracked spine','Sent to bindery'),
(14,'9780140283334','2025-11-01','Annotation in pencil','Erased; noted'),
(15,'9780439023528','2025-11-03','Dog-eared pages','No action; noted'),
(17,'9780374533557','2025-11-06','Sticky residue on cover','Cleaned'),
(18,'9780062457714','2025-11-09','Torn bookmark left inside','Removed'),
(19,'9780812981605','2025-11-10','Wrinkled pages from moisture','Aired out'),
(20,'9780307887894','2025-11-12','Cover scratch','No action; noted'),
(4,'9780547928227','2025-09-22','Returned late with minor wear','Fine processed separately');

-- 4. FUNCTIONS
DELIMITER

-- 4.1 Fine calculator: R5 per day overdue (Rule 6)
CREATE FUNCTION fn_calculate_fine(p_loan_id INT) RETURNS DECIMAL(8,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_due DATE; DECLARE v_ret DATE; DECLARE v_days INT;
    SELECT Due_Date, COALESCE(Return_Date, CURDATE()) INTO v_due, v_ret
    FROM loan WHERE LoanID = p_loan_id;
    SET v_days = DATEDIFF(v_ret, v_due);
    IF v_days > 0 THEN RETURN v_days * 5.00;
    ELSE RETURN 0.00; END IF;
END

-- 4.2 Count of a user's ACTIVE loans (supports Rule 3)
CREATE FUNCTION fn_active_loans(p_user_id INT) RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt FROM loan
    WHERE UserID = p_user_id AND Return_Date IS NULL;
    RETURN cnt;
END

-- 4.3 Days a loan is overdue
CREATE FUNCTION fn_days_overdue(p_loan_id INT) RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_due DATE; DECLARE v_ret DATE;
    SELECT Due_Date, COALESCE(Return_Date, CURDATE()) INTO v_due, v_ret
    FROM loan WHERE LoanID = p_loan_id;
    RETURN GREATEST(DATEDIFF(v_ret, v_due), 0);
END

-- 5. STORED PROCEDURES (business-rule enforcement layer)

-- 5.1 Issue a book (enforces Rules 3, 4, 7)
CREATE PROCEDURE sp_issue_book(IN p_user INT, IN p_isbn VARCHAR(20))
BEGIN
    DECLARE v_status VARCHAR(20); DECLARE v_reserver INT;
    SELECT Status INTO v_status FROM book WHERE ISBN = p_isbn;
    IF v_status = 'Lost' OR v_status = 'Damaged' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not available (lost/damaged)';
    END IF;
    IF fn_active_loans(p_user) >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rule 3: user already has 5 active loans';
    END IF;
    -- Rule 7: reserved by someone else?
    SELECT UserID INTO v_reserver FROM reservation
    WHERE ISBN = p_isbn AND Status = 'Active' LIMIT 1;
    IF v_reserver IS NOT NULL AND v_reserver <> p_user THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rule 7: book is reserved by another user';
    END IF;
    INSERT INTO loan (UserID, ISBN) VALUES (p_user, p_isbn);  -- due date set by trigger
    UPDATE book SET Status = 'Borrowed' WHERE ISBN = p_isbn;
END

-- 5.2 Return a book (Rule 5) - fine auto-created by trigger trg_return
CREATE PROCEDURE sp_return_book(IN p_loan INT)
BEGIN
    UPDATE loan SET Return_Date = CURDATE() WHERE LoanID = p_loan;
END

-- 5.3 Pay a fine (Rule 10: records payment date)
CREATE PROCEDURE sp_pay_fine(IN p_fine INT)
BEGIN
    UPDATE fine SET Status = 'Paid', Paid_Date = CURDATE()
    WHERE FineID = p_fine AND Status = 'Unpaid';
END

-- 5.4 Add/update/delete book - Rule 8: ADMIN ONLY
CREATE PROCEDURE sp_add_book(IN p_admin INT, IN p_isbn VARCHAR(20),
    IN p_title VARCHAR(150), IN p_author VARCHAR(100),
    IN p_pub VARCHAR(100), IN p_year SMALLINT)
BEGIN
    DECLARE v_type VARCHAR(20);
    SELECT User_Type INTO v_type FROM `user` WHERE UserID = p_admin;
    IF v_type <> 'Admin' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rule 8: only admins may add books';
    END IF;
    INSERT INTO book (ISBN, Title, Author, Publisher, Publication_Year)
    VALUES (p_isbn, p_title, p_author, p_pub, p_year);
END

-- 6. TRIGGERS

-- 6.1 Rule 4: auto-set due date = borrow date + 14 days
CREATE TRIGGER trg_loan_due_date BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
    IF NEW.Due_Date IS NULL THEN
        SET NEW.Due_Date = DATE_ADD(NEW.Borrow_Date, INTERVAL 14 DAY);
    END IF;
END

-- 6.2 Rule 6: on return, create a fine if overdue
CREATE TRIGGER trg_return_fine AFTER UPDATE ON loan
FOR EACH ROW
BEGIN
    IF OLD.Return_Date IS NULL AND NEW.Return_Date IS NOT NULL THEN
        UPDATE book SET Status = 'Available' WHERE ISBN = NEW.ISBN;
        IF NEW.Return_Date > NEW.Due_Date THEN
            INSERT INTO fine (LoanID, Amount, Issued_Date)
            VALUES (NEW.LoanID, DATEDIFF(NEW.Return_Date, NEW.Due_Date) * 5.00, CURDATE());
        END IF;
    END IF;
END

-- 6.3 Block borrowing a Reserved/Lost/Damaged book directly (Rule 7 safety)
CREATE TRIGGER trg_loan_block_status BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT Status INTO v_status FROM book WHERE ISBN = NEW.ISBN;
    IF v_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book status does not allow borrowing';
    END IF;
END

-- 6.4 Rule 9: incident report updates book status automatically
CREATE TRIGGER trg_incident_status AFTER INSERT ON incident_report
FOR EACH ROW
BEGIN
    IF NEW.Description LIKE '%Lost%' THEN
        UPDATE book SET Status = 'Lost' WHERE ISBN = NEW.ISBN;
    ELSEIF NEW.Description LIKE '%damage%' OR NEW.Description LIKE '%Damage%' THEN
        UPDATE book SET Status = 'Damaged' WHERE ISBN = NEW.ISBN;
    END IF;
END


-- 7. VIEWS (matching the report requirements, Section 5)

-- Active loans (detailed report)
CREATE VIEW v_active_loans AS
SELECT l.LoanID, u.First_Name, u.Last_Name, b.Title, l.Borrow_Date, l.Due_Date,
       DATEDIFF(CURDATE(), l.Due_Date) AS Days_Overdue
FROM loan l JOIN `user` u ON l.UserID = u.UserID
            JOIN book b ON l.ISBN = b.ISBN
WHERE l.Return_Date IS NULL$$

-- Overdue books (exception report)
CREATE VIEW v_overdue_books AS
SELECT * FROM v_active_loans WHERE Days_Overdue > 0$$

-- Users with outstanding fines (exception report)
CREATE VIEW v_outstanding_fines AS
SELECT u.UserID, CONCAT(u.First_Name,' ',u.Last_Name) AS User_Name,
       SUM(f.Amount) AS Outstanding_Fine
FROM fine f JOIN loan l ON f.LoanID = l.LoanID
            JOIN `user` u ON l.UserID = u.UserID
WHERE f.Status = 'Unpaid'
GROUP BY u.UserID, u.First_Name, u.Last_Name$$

-- User activity summary (summary report)
CREATE VIEW v_user_activity AS
SELECT u.UserID, CONCAT(u.First_Name,' ',u.Last_Name) AS User_Name,
       (SELECT COUNT(*) FROM loan l WHERE l.UserID = u.UserID) AS Total_Borrowed,
       (SELECT COUNT(*) FROM loan l WHERE l.UserID = u.UserID AND l.Return_Date IS NOT NULL) AS Total_Returned,
       (SELECT COUNT(*) FROM reservation r WHERE r.UserID = u.UserID) AS Total_Reserved
FROM `user` u;

-- Book availability (detailed)
CREATE VIEW v_book_availability AS
SELECT ISBN, Title, Author, Status,
       CASE WHEN Status = 'Available' THEN 'Ready to issue' ELSE 'Not available' END AS Availability
FROM book;


-- 8. INDEXES

-- FK indexes (MySQL does not always auto-index FKs on all engines/configs)
CREATE INDEX idx_loan_user     ON loan(UserID);
CREATE INDEX idx_loan_isbn     ON loan(ISBN);
CREATE INDEX idx_loan_due      ON loan(Due_Date, Return_Date);   -- overdue queries
CREATE INDEX idx_res_isbn      ON reservation(ISBN, Status);     -- reservation checks
CREATE INDEX idx_fine_loan     ON fine(LoanID, Status);
CREATE INDEX idx_inc_isbn      ON incident_report(ISBN);
CREATE INDEX idx_book_title    ON book(Title(50));               -- search optimisation
CREATE INDEX idx_user_name     ON `user`(Last_Name, First_Name);

-- 9. DEMONSTRATION QUERIES

DELIMITER ;

-- 9.1 JOINS 
-- All loans with full user + book detail (detailed report)
SELECT l.LoanID, CONCAT(u.First_Name,' ',u.Last_Name) AS Borrower,
       b.Title, b.Author, l.Borrow_Date, l.Due_Date, l.Return_Date
FROM loan l
INNER JOIN `user` u ON l.UserID = u.UserID
INNER JOIN book b ON l.ISBN = b.ISBN;

-- LEFT JOIN: every book and its latest loan (if any)
SELECT b.Title, l.Borrow_Date, l.Due_Date
FROM book b LEFT JOIN loan l ON b.ISBN = l.ISBN;

-- 9.2 SUBQUERIES
-- Users who have borrowed more books than the average
SELECT u.First_Name, u.Last_Name,
       (SELECT COUNT(*) FROM loan l WHERE l.UserID = u.UserID) AS Borrowed
FROM `user` u
WHERE (SELECT COUNT(*) FROM loan l WHERE l.UserID = u.UserID) >
      (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM loan GROUP BY UserID) t);

-- Books never borrowed
SELECT Title FROM book
WHERE ISBN NOT IN (SELECT DISTINCT ISBN FROM loan);

-- 9.3 CTEs
-- Monthly circulation summary (summary report)
WITH monthly AS (
    SELECT DATE_FORMAT(Borrow_Date, '%Y-%m') AS Month, COUNT(*) AS Issued
    FROM loan GROUP BY DATE_FORMAT(Borrow_Date, '%Y-%m'))
SELECT * FROM monthly ORDER BY Month;

-- CTE + recursion: days overdue ladder for active loans
WITH RECURSIVE overdue_ladder AS (
    SELECT LoanID, 1 AS n FROM loan WHERE Return_Date IS NULL
    UNION ALL
    SELECT LoanID, n + 1 FROM overdue_ladder WHERE n < 60)
SELECT DISTINCT l.LoanID, l.Due_Date FROM loan l JOIN overdue_ladder o ON l.LoanID = o.LoanID
WHERE l.Due_Date < CURDATE();

-- 9.4 WINDOW FUNCTION
-- Most borrowed books (summary report)
SELECT Title, Author, Times_Borrowed,
       RANK() OVER (ORDER BY Times_Borrowed DESC) AS Popularity_Rank
FROM (SELECT b.Title, b.Author, COUNT(l.LoanID) AS Times_Borrowed
      FROM book b LEFT JOIN loan l ON b.ISBN = l.ISBN
      GROUP BY b.ISBN, b.Title, b.Author) t;

-- Running total of fines per user
SELECT f.FineID, u.UserID, f.Amount,
       SUM(f.Amount) OVER (PARTITION BY u.UserID ORDER BY f.Issued_Date) AS Running_Total
FROM fine f JOIN loan l ON f.LoanID = l.LoanID JOIN `user` u ON l.UserID = u.UserID;

-- LAG: compare each user's borrowing activity month-on-month
WITH user_months AS (
    SELECT l.UserID, DATE_FORMAT(l.Borrow_Date,'%Y-%m') AS Mth, COUNT(*) AS Loans
    FROM loan l GROUP BY l.UserID, DATE_FORMAT(l.Borrow_Date,'%Y-%m'))
SELECT UserID, Mth, Loans,
       LAG(Loans) OVER (PARTITION BY UserID ORDER BY Mth) AS Prev_Month_Loans
FROM user_months;

-- 9.5 QUERY OPTIMISISATION
-- Before: full table scan
EXPLAIN SELECT * FROM loan WHERE UserID = 2 AND Return_Date IS NULL;
-- After idx_loan_user / idx_loan_due: ref-type lookups instead of ALL.

EXPLAIN SELECT Title FROM book WHERE Title LIKE 'Harry%';   -- uses idx_book_title
EXPLAIN SELECT * FROM v_overdue_books;                     -- uses idx_loan_due

-- 10. TESTING THE RULES (uncomment to verify triggers/procedures work)

-- CALL sp_issue_book(1, '9780062315007');      -- blocked: reserved by user 1? ok if owner
-- CALL sp_issue_book(2, '9780439554936');      -- blocked: reserved by another user (Rule 7)
-- CALL sp_add_book(1, '9780000000001','X','Y','Z',2020);  -- blocked: not admin (Rule 8)
-- CALL sp_add_book(20,'9780000000001','X','Y','Z',2020);  -- succeeds
-- CALL sp_return_book(2);                      -- creates fine (Rule 6)
