/* Note: Today we are going to explore about indian censes 2021 and there are two dataset , dataset1 (distric,state,growth,
sex_ratio,literacy) and dataset2 (city,state,area_km2,population)*/

select * from dataset1
select * from dataset2

/* EASY LEVEL */

/* Question 1. How many rows are in our dataset ? */

select count(*) from dataset1 
select count(*)from dataset2

/* Question 2.Find the datasets only for Jharkhand and Bihar */
select * from dataset1
where state in ('Jharkhand' , 'Bihar')

-- OR
select * from dataset1
where state like 'Jharkhand' or state like 'Bihar'

/* Question 3.Population of India */

select sum(population) population_of_india from dataset2

/* Question 4. What is the Avg growth rate of Indian population? */

select avg(growth)*100 avg_groth_percentage from dataset1

/* Question 5. What is the Avg growth rate of state population? */

select state,avg(growth)*100 avg_growth_state from dataset1
group by 1 order by 2 desc

/* Question 6. What is avg sex_ration per state ? */

select state,round(avg(sex_ratio)::numeric,0) from dataset1
group by 1 order by 2 asc

/* Question 7. What is avg literacy_rate per state ? */

select state ,round(avg(literacy)::numeric,0) from dataset1
group by 1 order by 2 desc

/* Question 8. Find the literacy>90 in terms of states . */

select state,round(avg(literacy):: numeric,0) from dataset1
group by state having round(avg(literacy):: numeric,0)>90

/*Note: FROM>WHERE>AGGREGATE FUNCTION >GROUP BY>HAVING>SELECT >ORDER BY THIS IS THE CORRECT SQL RUNNING FUNCTION */
/* Question 9. Top 3 state where is the highest growth percentage . */

select state ,round(avg(growth)::numeric*100,0) growth_percentage from dataset1
group by 1 order by 2 desc limit 3

/* Question 10. Find the state that is starting with latter 'a' or 'b'. */

select * from dataset1
where lower(state) like 'a%' or lower(state)like 'b%'

/* Question 11. Find the state that is starting with latter 'A' and ending with latter 'h' */

select * from dataset1
where state like 'A%' and state like '%h'

/* MODERATE LEVEL */

/* Question 1. Find total number of Female and Male population  ? */

/* Note: Lets asume Population=P,Male=M,Female=F and Sex_Ratio=S
P=M+F ,S=F/M , F=S.M ,P=(S.M)+M, P=(S+1)M , P/S+1=M ,M=F/S,P=F/S+F/1,P=F(1+S)/S,PS/(1+S)=F
so F=PS/(1+S) and M=P/(1+S) */

select distric,state ,population ,round(((population*sex_ratio)/(1+sex_ratio))::numeric,0) as female,
round((population/(1+sex_ratio))::numeric,0) as male from
(select a.distric,a.state,a.sex_ratio/1000 as sex_ratio,b.population from dataset1 as a
join dataset2 as b
on a.distric=b.city)a

/* Question 2. Find out state level total number of male and feamle population .*/

select state,sum(population)total_state_population  ,sum(female)total_male_population,sum(male)total_female_population from 
(select distric,state ,population ,round(((population*sex_ratio)/(1+sex_ratio))::numeric,0) as female,
round((population/(1+sex_ratio))::numeric,0) as male from
(select a.distric,a.state,a.sex_ratio/1000 as sex_ratio,b.population from dataset1 as a
join dataset2 as b
on a.distric=b.city)a)b group by 1 order by 2 desc

/* Note Here we are using question 1 's query */

/*Question 3. Which state's Literacy rate is the highest */

select state ,round(avg(literacy)::numeric,0) from dataset1 
group by 1 order by 2 desc 

/* Question 4. Find out total number of literate and illeterate  people for each state . */

select state,sum(population)population ,sum(literate_people)literate_people ,sum(illiterate_people)illiterte_people from
(select state ,population,round(population*literacy::numeric,0) as literate_people ,
round((population*(1-literacy))::numeric,0) illiterate_people from
(select a.distric , a.state,a.literacy/100 literacy ,b.population from dataset1 as a
join dataset2 as b
on a.distric=b.city)a)b
group by 1 order by 2 desc 

/* Question 5. Find out previous year population state wise. */
/* Formula : poulation= previous_population+(growth*previous_population) so ,previous_population=population/(1+growth)*/
select state,sum(population) population ,sum(previous_year_population) previous_year_population from 
(select a.distric,a.state,a.growth ,b.population ,round(population/(1+growth)::numeric,0) previous_year_population  from dataset1 as a
join dataset2 as b
on a.distric =b.city )a
group by 1 order by 2 desc

/* Question 6. how many person on per killometer in previous year and corrent year ? */

/* Note: Process:Firtly we find the previous year total population , then previous year population , then we devided by area to
population and previous year population 
and previous year population */

select total_area_meter,population , previous_year_population ,total_area_meter/population as currect_year_population_area,
total_area_meter/previous_year_population  as previous_year_population_area from
(select sum (total_area_meter) total_area_meter ,sum(population) population ,sum(previous_year_population) previous_year_population from 
(select a.distric,a.state,a.growth ,b.population ,b.area_km2*1000 total_area_meter ,round(population/(1+growth)::numeric,0) previous_year_population  from dataset1 as a
join dataset2 as b
on a.distric =b.city )a)b

/* Question 7. Find the top 3 distric of each state which have highest leteracy rate .*/
select * from 
(select state,distric,literacy,rank()over(partition by state order by literacy desc)rank from dataset1)a
where rank<=3 