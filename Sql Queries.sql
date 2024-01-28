create schema assignment2;
use assignment2;
set sql_safe_updates =0;
-- backup of all table 
create table petowners_bup as select *from petowners;
create table pet_bup as select *from pets;
create table procedurez_detail_bup as select *from procedures_details;
create table procedures_history_bup as select *from procedures_history;
-- 1. List the names of all pet owners along with the names of their pets.
alter table petowners add primary key (OwnerID);
alter table petowners modify OwnerID int auto_increment;
select po.OwnerID,po.Name , p.Name,p.kind
from petowners po
join pets p on p.OwnerID=po.OwnerID;
--  2. List all pets and their owner names, including pets that don't have recorded  owners.  
 select po.OwnerID, po.Name, po.Surname, p.Name ,p.Kind
from pets p
left join petowners po on po.OwnerID=p.OwnerID;
-- 3. Combine the information of pets and their owners, including those pets  without owners and owners without pets.  
select  po.OwnerID , Po.Name , p.Name
from petowners po
left join pets p on p.OwnerID=po.OwnerID
where p.OwnerID is null;
-- --Find the names of pets along with their owners'
--  names and the details of the  procedures they have undergone. 
  select po.Name ,po.OwnerID ,p.Name,ph.procedureType
  from petowners po
  join pets p on po.OwnerID=p.OwnerID
  join procedures_history ph on p.PetID=ph.petID;
  -- 5. List all pet owners and the number of dogs they own.  
  select po.OwnerId ,Po.Name,count(kind) as Number_of_Dog
  from petowners po
  left join pets p on p.OwnerID=po.OwnerID
  where kind="Dog"
  group by po.OwnerID;
  -- 6. Identify pets that have not had any procedures.  
  select p.Name,p.kind,ph.ProcedureType
  from pets p
  join procedures_history ph on p.PetID=ph.PetID
  where ProcedureType is null;
  -- 7. Find the name of the oldest pet.  
  select Name,kind,Age
  from pets
  where Age=(select max(Age) from pets);
--   8. List all pets who had procedures that cost more than the average cost of all  procedures.  
select p.Name,ph.ProcedureType 
from pets p
join procedures_history ph on p.PetID=ph.PetID
join procedures_details pd on ph.ProcedureSubCode=pd.ProcedureSubCode
where pd.Price>(select avg(Price) from procedures_details ph
group by p.PetID
)
group by p.Name,ph.ProcedureType;
-- --9. Find the details of procedures performed on 'Cuddles' 
select p.Name, Ph.procedureType,Description as Details_Procedure
 from pets p
 join procedures_history ph on p.PetID=ph.PetID
 join procedures_details pd on ph.ProcedureSubCode=pd.ProcedureSubCode
 where p.Name = "Cuddles";
--  10.Create a list of pet owners along with the total cost they have spent on  
--  procedures and display only those who have spent above the average  spending.
SELECT
    po.OwnerID,
    po.Name,
    SUM(pd.Price) as total_price
FROM
    petowners po
JOIN
    pets p ON po.OwnerID = p.OwnerID
JOIN
    procedures_history ph ON ph.PetID = p.PetID
JOIN
    procedures_details pd ON ph.ProcedureSubCode = pd.ProcedureSubCode
GROUP BY
    po.OwnerID, po.Name
HAVING
    SUM(pd.Price) > (
        SELECT AVG(total_price)
        FROM (
            SELECT
                po.OwnerID,
                SUM(pd.Price) as total_price
            FROM
                petowners po
            JOIN
                pets p ON po.OwnerID = p.OwnerID
            JOIN
                procedures_history ph ON ph.PetID = p.PetID
            JOIN
                procedures_details pd ON ph.ProcedureSubCode = pd.ProcedureSubCode
            GROUP BY
                po.OwnerID
        ) AS Spending_Total
    );
    -- 11.List the pets who have undergone a procedure called 'VACCINATIONS'.  
    select p.Name,p.kind,ph.procedureType
    from pets p 
    join procedures_history ph on p.PetID=ph.PetID
    where ph.ProcedureType = "VACCINATIONS";
    -- 12.Find the owners of pets who have had a procedure called 'EMERGENCY'.  
    select po.OwnerID ,po.Name,pd.Description
    from petowners po
    join pets p on p.ownerID=po.ownerID
    join procedures_history ph on p.PetID = ph.PetID
    join procedures_details pd on ph.ProcedureSubCode=pd.ProcedureSubCode
    where pd.Description = "Emergency";
   --  13.Calculate the total cost spent by each pet owner on procedures.
   select po.Name ,sum(pd.Price)
   from petowners po 
     join pets p on p.ownerID=po.ownerID
    join procedures_history ph on p.PetID = ph.PetID
    join procedures_details pd on ph.ProcedureSubCode=pd.ProcedureSubCode
     group by po.Name;
-- 14.Count the number of pets of each kind.  
select kind,count(kind)
from pets
group by kind;
-- 15.Group pets by their kind and gender and count the number of pets in each  group.  
 select kind,Gender ,count(*) as Number_of_pet
 from pets 
 group by kind,Gender;
 -- 16.Show the average age of pets for each kind, but only for kinds that have more  than 5 pets.
 select kind,count(*),avg(age) as Average_Age
 from pets 
 group by kind
 having count(*)> 5;
 -- 17.Find the types of procedures that have an average cost greater than $50. 
 select p.Name,pd.ProcedureType ,po.OwnerID,round(avg(pd.price),2) as Average_cost
 from pets p 
  join petowners po on p.ownerID=po.ownerID
  join procedures_history ph on p.PetID = ph.PetID
  join procedures_details pd on ph.ProcedureSubCode=pd.ProcedureSubCode
  group by  p.Name, po.OwnerID,pd.ProcedureType
  having avg(pd.price) > 50;
--   18.Classify pets as 'Young', 'Adult', or 'Senior' based on their age. 
--   Age less then  3 Young, Age between 3and 8 Adult, else Senior.  
 
 SELECT Name,kind,Age,
    CASE
        WHEN Age < 3 THEN 'Young'
        WHEN Age < 8 THEN 'Adult'
        ELSE 'Senior'
    END AS Classify_by_Age
FROM
    pets;
--  19.Calculate the total spending of each pet owner on procedures, labeling them  as 'Low Spender' for 
-- spending under $100, 'Moderate Spender'
--  for spending  between $100 and $500, and 'High Spender' for spending over $500.  
 select po.OwnerID,po.Name,sum(pd.price) as Total,
 case
     when sum(pd.price) < 100 then "Low Spender"
	 when sum(pd.price)<500 then "Moderate Spender"
     else "High Spender"
end as labling
from petowners po
join pets p on p.ownerID=po.ownerID
join procedures_history ph on p.PetID = ph.PetID
join procedures_details pd on ph.ProcedureSubCode=pd.ProcedureSubCode
group by po.OwnerID;
-- 20.Show the gender of pets with a custom label ('Boy' for male, 'Girl' for female).  
select p.Name , p.Gender,
case
   when Gender ="male" then "Boy"
   else "Girl"
   end as Custom_lable
   from pets p
   join petowners po on p.OwnerID=po.OwnerID;
--    21.For each pet, display the pet's name, the number of procedures they've had,
--    and a status label: 'Regular' for pets with 1 to 3 procedures,'Frequent' for 4 to  7 procedures,
--    and 'Super User' for more than 7 procedures.  
select p.Name ,count(ph.ProcedureType),
case 
   when count(ph.ProcedureType) <=3 then "Regular"
   when count(ph.ProcedureType) <=7 then "Frequent"
   else "Super User"
end as Status_lable
   from pets p
   join petowners po on p.ownerID=po.ownerID
join procedures_history ph on p.PetID = ph.PetID
join procedures_details pd on ph.ProcedureSubCode=pd.ProcedureSubCode
group by p.Name;
-- 22.Rank pets by age within each kind.  
select Name, kind,
rank() over(partition by kind order by age desc) as Rank_number
from pets;
-- second method
select Name, kind,
dense_rank() over(partition by kind order by age desc) as Rank_number
from pets;
-- 23.Assign a dense rank to pets based on their age, regardless of kind
    select Name, kind,
dense_rank() over( order by age desc) as Rank_number
from pets; 
-- 24.For each pet, show the name of the next and previous pet in alphabetical order.  
select Name ,kind,
lead(kind) over(partition by Name) as Next_pets,
lag(kind) over(partition by Name) as previous_pets
from pets;
-- .  25.Show the average age of pets, partitioned by their kind.  
select kind,
avg(Age) over(partition by kind)
from pets; 
-- 26.Create a CTE that lists all pets, then select pets older than 5 years from the  CTE. 
with older as(
select Name,kind , Age from pets
)
select Name ,Age
from older 
where Age <5;
select *from petowners;
select *from pets;
select *from procedures_details;
select *from procedures_history;

