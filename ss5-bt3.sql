use md3_ss02;
create table class(
  classId int auto_increment primary key,
  className varchar(100),
  startDate varchar(255),
  status bit
);

create table student (
  studentId int auto_increment primary key,
  studentName varchar(100),
  address varchar(255),
  phone varchar(11),
  class_id int,
  status bit,
   constraint fk_class foreign key (class_id) references class(classId)
);

create table subjects (
   subjectId int auto_increment primary key,
   subjectName varchar(100),
   credit int,
   status bit
);

create table mark (
   markId int auto_increment primary key,
   student_id int,
   subject_id int,
   mark double,
   examTime datetime,
   constraint fk_student foreign key (student_id) references student(studentId),
   constraint fk_sbjects foreign key (subject_id) references subjects(subjectId)
);

select * from class;
insert into class(className, startDate, status )value ('HN-JV231103','2023-11-03',1),
                                                      ('HN-JV231229','2023-12-29',1),
                                                      ('HN-JV230615','2023-06-15',1);
select classId,className,startDate, 
case status when 1 then 'true' when 0 then 'false' end as status from class;

select * from student;

insert into student(studentName, address, phone, class_id,status) 
value ('ho gia hung','ha noi','09876543',1,1),
	  ('pham vang giang','da nang','0987333',1,1),
      ('duong my huyen','japan','09876599',2,1),
      ('hoang minh hieu','nghe an','0987659966',2,1),
      ('nguyen vinh ','ha tinh','09876599',3,1),
      ('nam cao','ha noi','09876599',3,1),
      ('nguyen vien','ha noi','09876599',3,1);
     
select studentId,studentName,address,phone,class_id,
 case status when 1 then 'true' when 0 then 'false' end as status from student; 
 

 
 select * from subjects;
 
 insert into subjects(subjectName,credit,status)value('toan',3,1),
                                                     ('van',3,1),
                                                     ('anh',2,1);
 
select subjectId,subjectName,credit,
 case status when 1 then 'true' when 0 then 'false' end as status from subjects; 
 
 select * from mark;
 insert into mark(student_id,subject_id,mark,examTime)
 value(1,1,7,'2024-05-12 07:00:00'),
      (1,1,7,'2024-03-15 07:00:00'),
      (2,2,8,'2024-05-15 08:00:00'),
      (2,3,9,'2024-03-08 09:00:00'),
      (3,3,10,'2024-02-11 10:00:00');
-- 1. Tạo store procedure lấy ra tất cả lớp học có số lượng học sinh lớn hơn 5
 -- Tạo stored procedure mới
DELIMITER //
create procedure show_class_studentCount()
begin
  select c.classId, c.className, c.startDate, c.status , count(st.studentId) as student_count
  from class c
  join student st on st.class_id = c.classId
  group by c.classId, c.className, c.startDate, c.status
  having student_count >=3;
  
end//

call show_class_studentCount();

-- Tạo store procedure hiển thị ra danh sách môn học có điểm thi là 10

DELIMITER //
create procedure show_subject_mark_10()
begin
  select sb.subjectId, sb.subjectName, sb.credit,
  case sb.status when 1 then 'true' when 0 then 'false' end as status,
  m.mark as subject_mark
  from subjects sb
  join mark m on m.subject_id = sb.subjectId
  where m.mark = 10;
end//

call show_subject_mark_10();

-- Tạo store procedure hiển thị thông tin các lớp học có học sinh đạt điểm 10

DELIMITER //
create procedure show_class_student_mark_10()
begin
  select c.classId,c.className,c.startDate, 
  case c.status when 1 then 'true' when 0 then 'false' end as status,
  m.mark as student_mark_10
  from class c
  join student st on st.class_id = c.classId
  join mark m on m.student_id = st.studentId
  where m.mark = 10;
  
end//

call show_class_student_mark_10();
-- Tạo store procedure thêm mới student và trả ra id vừa mới thêm

DELIMITER //

create procedure add_student(
 in in_studentName varchar(100),
 in in_address varchar(255),
 in in_phone varchar(11),
 in in_class_id int,
 in in_status bit
)
begin
insert into student(studentName, address, phone, class_id,status) 
value (in_studentName,in_address,in_phone,in_class_id,in_status);
	  
select studentId,studentName,address,phone,class_id,
 case status when 1 then 'true' when 0 then 'false' end as status from student; 
 
 select last_insert_id() as studentId;

end//

CALL add_student('Nguyen Van Dung', 'ha noi', '0123456789', 1, 1);

select * from student;
-- Tạo store procedure hiển thị subject chưa được ai thi
-- add new subject 
DELIMITER //
create procedure add_subject(
   in in_subjectName varchar(100),
   in in_credit int,
   in in_status bit
)
begin 
   
 
 insert into subjects(subjectName,credit,status)
 values(in_subjectName,in_credit,in_status);
                                                     
 
select subjectId,subjectName,credit,
 case status when 1 then 'true' when 0 then 'false' end as status from subjects;

end // 

call add_subject('hoa',2,1);
call add_subject('ly',2,1);

select * from subjects;

--  Tạo store procedure hiển thị subject chưa được ai thi

DELIMITER //

create procedure show_subject_notMark()
begin
select sb.subjectId, sb.subjectName, sb.credit, 
CASE sb.status WHEN 1 THEN 'true' ELSE 'false' END AS status
-- c1  dùng hàm not in()
from subjects sb
where sb.subjectId not in(select m.subject_id from mark m);
-- c2 dùng LEFT JOIN mark m ON sb.subjectId = m.subject_id
  -- WHERE m.subject_id IS NULL; 
end//

call show_subject_notMark();


