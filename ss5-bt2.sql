use md3_ss02;
create table accounts(
  id int auto_increment primary key,
  userName varchar(100),
  password varchar(255),
  address varchar(255),
  status bit
);

create table bill(
   id int auto_increment primary key,
   bill_type bit,
   acc_id int,
   created datetime,
   auth_date datetime,
   constraint fk_accounts foreign key (acc_id) references accounts(id)
);
create table product(
  id int auto_increment primary key,
  name varchar (255),
  created date,
  price double,
  stock int,
  status bit
  
);
create table bill_detail(
   id int auto_increment primary key,
   bill_id int,
   product_id int,
   quantity int,
   price double,
    constraint fk_bill foreign key (bill_id) references bill(id),
    constraint fk_product foreign key (product_id) references product(id)
);

select * from accounts;
insert into accounts(userName,password,address,status) 
value('hung','123456','ha noi',1),
     ('cuong','654321','japan',1),
     ('bach','060696','hai duong',1);
select id,userName,password,address, 
case status when 1 then 'true' when 0 then 'false' 
end as status from accounts;

select * from bill;

insert into bill(bill_type,acc_id,created,auth_date) 
value (0,1,'2024-02-11 07:00:00','2024-03-12 07:00:00'),
      (0,1,'2024-10-5 07:00:00','2024-10-10 08:00:00'),
      (1,2,'2024-05-15 07:00:00','2024-05-20 04:00:00'),
      (1,3,'2024-02-01 07:00:00','2024-02-12 06:00:00'),
      (1,2,'2024-02-01 04:00:00','2024-01-12 06:00:00');
select id,
  case bill_type 
    when 1 then 'xuat' 
    when 0 then 'nhap' 
  end as bill_type,acc_id,created,auth_date from bill;

select * from product;
insert into product (name, created, price,stock,status) 
value ('quan dai','2024-02-11 07:00:00',1200,5,1),
      ('ao dai','2024-04-13 07:00:00',1500,8,1),
      ('mu coi','2024-05-11 07:00:00',1600,7,1),
      ('ao ngan','2024-03-17 07:00:00',1300,9,1);
      
select id, name, created, price,stock,
case status when 1 then 'true' when 0 then 'false' 
end as status from product;

select * from bill_detail;

insert into bill_detail(bill_id,product_id,quantity,price)
 value(1,1,3,1200),   
      (1,2,4,1500), 
      (3,2,4,1200), 
      (4,3,7,1600);
      
 
-- Tạo store procedure hiển thị tất cả thông tin account mà đã tạo ra 5 đơn hàng trở lên
delimiter //
create procedure count_min_2_bill()
  
begin
   select a.id, a.userName, a.password,a.address, a.status from accounts a
   join (select acc_id, count(*) as bill_account 
         from bill
         group by acc_id
         having count(*) >=2
          
   ) b on a.id = b.acc_id;
											
end//

call count_min_2_bill();

-- Tạo store procedure hiển thị tất cả sản phẩm chưa được bán
delimiter //
create procedure show_product_notsale()
  
begin
   select p.id, p.name, p.created,p.price,p.stock,p.status from product p
   
   where id not in (select product_id from bill_detail);
   
											
end//
call show_product_notsale();
-- Tạo store procedure hiển thị top 2 sản phẩm được bán nhiều nhất
delimiter //
create procedure show_product_top_2()

begin
   select p.id, p.name, p.created,p.price,p.stock,p.status, sum(bd.quantity) as total_sale from product p
   join bill_detail bd on bd.product_id = p.id
   group by p.id, p.name, p.created,p.price,p.stock,p.status
   order by total_sale desc
   limit 2;
end//

call show_product_top_2();

-- Tạo store procedure thêm tài khoản

delimiter //
create procedure add_accounts(
  in in_userName varchar(100),
  in in_password varchar(255),
  in in_address varchar(255),
  in in_status bit
  )
  begin
  insert into accounts(userName,password,address,status) 
  values(in_userName,in_password,in_address,in_status);
  select id,userName,password,address, 
  case status when 1 then 'true' when 0 then 'false' 
  end as in_status from accounts;
end//
call add_accounts('nguyen mai', 'qwerty', 'ha noi', 1);
call add_accounts('tran hai', 'asdfgh', 'japan', 0);

-- Hiển thị tất cả các tài khoản để kiểm tra kết quả
SELECT * FROM accounts;
-- Tạo store procedure truyền vào bill_id và sẽ hiển thị tất cả bill_detail của bill_id đó

delimiter //
create procedure show_bill_detail(
 in in_bill_id int
)
begin
select bd.id , bd.bill_id, bd.product_id, bd.quantity, bd.price
from bill_detail bd
where bd.bill_id = in_bill_id;
end//

call show_bill_detail(1);
call show_bill_detail(3);

-- Hiển thị tất cả các tài khoản để kiểm tra kết quả
SELECT * FROM accounts;

-- Tạo ra store procedure thêm mới bill và trả về bill_id vừa mới tạo

delimiter //
create procedure add_bill(
   in in_bill_type bit,
   in in_acc_id int,
   in in_created datetime,
   in in_auth_date datetime
)
begin
insert into bill(bill_type,acc_id,created,auth_date) 
values (in_bill_type,in_acc_id,in_created,in_auth_date);
select id,
  case bill_type 
    when 1 then 'xuat' 
    when 0 then 'nhap' 
  end as bill_type,acc_id,created,auth_date from bill;
     -- Trả về id của bill vừa được tạo
    SELECT LAST_INSERT_ID() AS bill_id;
end//
call add_bill(0,1,'2024-07-17 07:00:00','2024-03-12 07:00:00');
call add_bill(1,3,'2024-07-14 07:00:00','2024-03-12 07:00:00');

select * from bill;

-- Tạo store procedure hiển thị tất cả sản phẩm đã được bán trên 5 sản phẩm

delimiter //
create procedure show_product_sale_5()

begin
   select p.id, p.name, p.created, p.price, p.stock, p.status ,sum(bd.quantity) as total_quantity_product
   from product p
   join bill_detail bd on bd.product_id = p.id
   group by p.id, p.name, p.created, p.price, p.stock, p.status
   having total_quantity_product>=5;
end//

call show_product_sale_5();
select * from bill_detail;


