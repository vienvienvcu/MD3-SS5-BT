use md3_ss02;
create table customer(
   cId int auto_increment primary key,
   cName varchar(100),
   cAge int
);
create table orders (
   o_id int auto_increment primary key,
   c_id int,
   o_date datetime,
   o_totalprice double,
   constraint fk_customer foreign key (c_id)references customer(cId)
);

create table product (
   p_id int auto_increment primary key,
   p_name varchar(255),
   p_price double
);

create table order_detail(
  oid int,
  pid int,
  odquantty int,
  primary key (oid,pid),
  constraint fk_orders foreign key(oid)references orders(o_id),
  constraint fk_product foreign key(pid)references product(p_id)
);
select * from customer ;
insert into customer(cName,cAge) value ('minh quan',10);
insert into customer(cName,cAge) value ('ngoc anh',20),
                                       ('hai ha',50);


select * from product;
insert into product(p_name,p_price) value ('may giat',300);
insert into product(p_name,p_price) value ('tu lanh',500),
                                          ('dieu hoa',700),
                                          ('quat',100),
                                          ('bep dien',200),
                                          ('may hut mui',500);
                                          
  
 

insert into orders(c_id, o_date, o_totalprice) value (1,'2024-09-07',0);
insert into orders(c_id, o_date, o_totalprice) value (2,'2024-09-08',0),
                                                     (3,'2024-09-06',0);
												
insert into order_detail(oid, pid, odquantty) value (1,1,3);
insert into order_detail(oid, pid, odquantty) value (1,2,1),
                                                    (1,3,2),
                                                    (2,5,5),
                                                    (3,6,3);
update orders o
set o.o_totalprice = 
(select ifnull(sum(p.p_price * od.odquantty),0)
from order_detail od 
join product p on od.pid = p.p_id where od.oid = o.o_id
)
where o.o_totalprice is null or o.o_totalprice = 0;

select * from orders;

select * from order_detail;

-- Tạo view hiển thị tất cả customer 

create view all_customer as
select * from customer;

-- Xem tất cả khách hàng từ view

select * from all_customer;
  
 -- Tạo view hiển thị tất cả order có oTotalPrice trên 150000
 
 create view total_price_order as 
 select * from orders 
 where o_totalprice >= 1500;
 
 select * from total_price_order;
 -- Đánh index cho bảng customer ở cột cName
  create index idx_customer_name on customer(cName);
-- Hiển thị các index trong 1 bảng
show index from customer;
-- Đánh index cho bảng product ở cột pName
  create index idx_product_name on product(p_name);
-- Hiển thị các index trong 1 bảng
show index from product;

-- Tạo store procedure hiển thị ra đơn hàng có tổng tiền bé nhất

delimiter //
create procedure get_min_totalprice_orders()
begin
   select * from orders 
   where o_totalprice = (select min(o_totalprice) from orders);
end//

-- Gọi stored procedure để hiển thị đơn hàng có tổng tiền bé nhất
call get_min_totalprice_orders();

-- Tạo store procedure hiển thị người dùng nào mua sản phẩm “May Giat” ít nhất
delimiter //
create procedure get_min_product_maygiat()
begin

   select c.cName, sum(od.odquantty) as count_maygiat 
                            from customer c join orders o on o.c_id = c.cId 
                            join order_detail od on od.oid = o.o_id 
                            join product p on p.p_id = od.pid 
							where p.p_name = 'may giat'
                            group by  c.cId,c.cName 
                            order by count_maygiat asc
                            limit 1;
                           
						
end// 

call get_min_product_maygiat();