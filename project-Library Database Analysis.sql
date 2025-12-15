set foreign_key_checks=0;
drop database if exists library;
create database if not exists library;
use library;

create table tbl_publisher (
publisher_publishername varchar(255),
publisher_publisheraddress varchar(255),
publisher_publisherphone varchar(20),
primary key (publisher_publishername));  

create table tbl_borrower (
borrower_CardNo int auto_increment ,
borrower_BorrowerName varchar(255),
borrower_BorrowerAddress varchar(255),
borrower_BorrowerPhone varchar(255),
primary key (borrower_CardNo));
																																																																																																																																																																									
create table tbl_library_branch (
library_branch_branchid int auto_increment,
library_branch_BranchName varchar(255),
library_branch_BranchAddress varchar(255),
primary key (library_branch_branchid));

create table tbl_book(
book_BookID int auto_increment,
book_Title varchar(255) ,
book_PublisherName varchar(255),
primary key (book_BookID),
constraint fk_bookpublisher
foreign key (book_PublisherName)
references tbl_publisher(publisher_publishername)on delete cascade);

create table tbl_book_authors (
BOOK_AUTHORS_AUTHORS_ID INT auto_increment,
book_authors_BookID int,
book_authors_AuthorName varchar(255),
primary key(BOOK_AUTHORS_AUTHORS_ID),
constraint fk_bookauthors
foreign key (book_authors_BookID)
references tbl_book(book_BookID)on delete cascade);

create table tbl_book_copies (
book_copies_copiesid int auto_increment,
book_copies_BookID int,
book_copies_BranchID int,
book_copies_No_Of_Copies int,
primary key (book_copies_copiesid),
constraint fk_bookcopies
foreign key (book_copies_BookID)
references tbl_book(book_BookID)on delete cascade,
constraint fk_bookcopiesbranch
foreign key (book_copies_BranchId)
references tbl_library_branch (library_branch_branchid)on delete cascade);

create table tbl_book_loans (
book_loans_loans_id int auto_increment,
book_loans_BookID int ,
book_loans_BranchID int,
book_loans_CardNo int,
book_loans_DateOut date,
book_loans_DueDate date,
primary key (book_loans_loans_id),
constraint fk_bookloans
foreign key (book_loans_BookID)
references tbl_book(book_BookID)on delete cascade,
constraint fk_bookloansbranch
foreign key (book_loans_BranchID)
references tbl_library_branch (library_branch_branchid)on delete cascade,
constraint fk_bookloanscardno
foreign key (book_loans_CardNo)
references tbl_borrower(borrower_CardNo) on delete cascade);

select * from tbl_publisher;
select * from tbl_book;
select * from tbl_book_authors;
select * from tbl_book_copies;
select * from tbl_book_loans;
select * from tbl_borrower;
select * from tbl_library_branch;

-- 1) How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?

SELECT b.book_BookID, 
b.book_Title, 
bc.book_copies_BranchID, 
bc.book_copies_No_Of_Copies, 
lb.library_branch_BranchName
FROM tbl_Book as b
join tbl_book_copies as bc
on b.book_bookid = bc.book_copies_BookId
JOIN tbl_library_Branch as Lb
ON bc.book_copies_branchid = lb.library_branch_BranchId
WHERE book_Title like 'The Lost Tribe'
AND library_branch_BranchName like 'Sharpstown';

-- 2) How many copies of the book titled "The Lost Tribe" are owned by each library branch?

SELECT  b.book_Title,
sum(bc.book_copies_No_Of_Copies) as total, 
lb.library_branch_BranchName
FROM tbl_Book as b
join tbl_book_copies as bc
on b.book_bookid = bc.book_copies_BookId
JOIN tbl_library_Branch as Lb
ON bc.book_copies_branchid = lb.library_branch_BranchId
WHERE book_Title = 'The Lost Tribe'
group by b.book_Title,lb.library_branch_BranchName ;

-- 3) Retrieve the names of all borrowers who do not have any books checked out.

SELECT *
FROM tbl_Borrower as Bo
LEFT OUTER JOIN tbl_book_Loans as BL
on Bo.borrower_CardNO = BL.book_loans_CardNO
WHERE BL.book_loans_CardNO is NULL;

-- or
 
select * from tbl_borrower as bo
where Bo.borrower_CardNO not in (select book_loans_CardNO from tbl_book_Loans);

-- 4) For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address. 

SELECT b.book_Title, 
Bo.borrower_BorrowerName, 
Bo.borrower_BorrowerAddress
FROM tbl_Book_Loans as BL
JOIN tbl_Library_Branch as LB
on BL.book_loans_BranchID = LB.library_branch_branchid
JOIN tbl_Book as b
on b.book_BookID = BL.book_loans_BookID
JOIN tbl_Borrower as Bo
on bo.borrower_CardNo = BL.book_loans_CardNo
WHERE book_loans_DueDate = '2018-03-02';

-- 5) For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

SELECT LB.library_branch_BranchName, 
Count(BL.book_loans_BranchID) as LoanedOut
FROM tbl_Library_Branch as LB
JOIN tbl_Book_Loans as BL
on LB.library_branch_branchid = BL.book_loans_BranchID
GROUP BY LB.library_branch_BranchName;

-- 6) Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.

SELECT bo.borrower_BorrowerName, 
bo.borrower_BorrowerAddress, 
Count( BL.book_loans_BookID) as Num_of_Books
FROM tbl_Borrower as bo
JOIN tbl_Book_Loans as BL
on bo.borrower_CardNo = BL.book_loans_CardNo
JOIN tbl_Book_Copies as BC
on Bl.book_loans_BookID = bc.book_copies_BookID
GROUP BY bo.borrower_CardNo, bo.borrower_BorrowerName, bo.borrower_BorrowerAddress 
HAVING Count(BL.book_loans_BookID) > 5;

-- 7) For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

SELECT b.book_BookID,
b.book_Title,
BA.book_authors_AuthorName,
Bc.book_copies_No_Of_Copies,
LB.library_branch_BranchName,
LB.library_branch_branchid
FROM tbl_BOOK as b
JOIN tbl_Book_Authors as BA
on b.book_BookID = BA.book_authors_BookID
JOIN tbl_Book_Copies as BC
on bc.book_copies_BookID = b.book_BookID
JOIN tbl_library_Branch as LB
on bc.book_copies_BranchID = LB.library_branch_branchid
WHERE book_authors_AuthorName LIKE 'Stephen King'
AND library_branch_BranchName LIKE 'Central';






