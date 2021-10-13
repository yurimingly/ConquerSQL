--1번 SFWO
select t.ename ,TO_CHAR(t.startdate,'YYYY-MM-DD')
from temployee t 
where t.dnumber in ('D1001','D2001')
order by t.startdate ;

--2번 SFWO
select t.ename ,t.startdate 
from temployee t 
where t.startdate < cast('2020-12-25' as timestamp) - cast('2 year' as interval)
;-- 2020 클수에서 2년 전보다 입사일이 작은것=빠른것

--3번 group by
select t.inumber as 제품코드, sum(t.pcount) as 총생산량 
from tproduction t 
where to_char(t.pdate,'YYYY-MM')='2020-02'
group by t.inumber
order by t.inumber 
;
select t.inumber as 제품코드, sum(t.pcount) as 총생산량 
from tproduction t 
--****************************************
where t.pdate between cast('2020-02-01' as timestamp) and cast('2020-03-01' as timestamp)
group by t.inumber
order by t.inumber 
;

--4번 group by
select t.cnumber as 고객코드, count(t.cnumber) as 주문횟수
from torder t 
where t.pnumber like 'P2%'
group by t.cnumber 
order by t.cnumber 
;
select t.cnumber as 고객코드, count(t.cnumber) as 주문횟수
from torder t 
where substring(t.pnumber,1,2) = 'P2'
group by t.cnumber 
order by t.cnumber 
;

--5번 GROUP BY, HAVING
select t.enumber as 직원코드, su(t.pcount) as 총생산량
from tproduction t 
where t.pdate between cast('2020-01-01' as timestamp) and cast('2020-02-01' as timestamp)
group by t.enumber
having sum(t.pcount) > 500
;

--****************************************
--6. case when
select 
	case 
		when t.inumber ='I1001' then '가위'
		when t.inumber ='I1002' then '풀'
		when t.inumber ='I1003' then '공책'
		when t.inumber ='I1004' then '볼펜'
		when t.inumber ='I1005' then '지우개'
		end AS 제품명
		,sum(t.pcount) as 총생산량
from tproduction t 
where to_char(t.ptdate,'YYYY-MM')='2020-02'
and substring(t.inumber,1,2) = 'I1'
group by t.inumber 
;

--7. Union
select distinct (to_char(t.odate,'MM') ) as 주문
from torder t 
union
select distinct(to_char(t1.rdate,'MM'))as 반품
from treturn t1
;
select to_char(t.odate,'MM') as 주문및반품월
from torder t
group by to_char(t.odate,'MM')
UNION
select to_char(t1.rdate,'MM')
from treturn t1
group by to_char(t1.rdate,'MM')
;

--****************************************
--8. UNION ALL
select '총인원수 :' as 입사년도, count(t.*) as 입사한직원수 
from temployee t
UNION ALL
select to_char(t2.startdate,'YYYY'), count(t2.*)
from temployee t2 
group by to_char(t2.startdate,'YYYY')
;

--****************************************
--9. subquery(select)
/*error
 * select (select t3.dname from temployee t, tdepartment t3 where t.dnumber=t3.dnumber) as 부서명
	   ,t.ename as 직원명, t.eaddr as 주소
from temployee t ,trank t2 , tdepartment t3 
;
*/
select (select t3.dname from tdepartment t3 where t.dnumber = t3.dnumber) as 부서명
,(select t2.rname from trank t2 where t.rnumber = t2.rnumber) as 직급명
,t.ename as 직원명
,t.eaddr as 주소
from temployee t 
;

--****************************************
--10. subquery(where)
/*error
 * select t.ename
from temployee t 
where sum(t.enumber) > avg((select t2.pCount from tproduction t2 group by t2.enumber))
group by t.enumber 
;
 */
select t.ename as 직원명 --가 속해있는 직원테이블
from temployee t 
where t.enumber in ( 
				select t2.enumber --보다 큰 enumber
				from tproduction t2
				where t2.pcount > (
						select avg(t3.pcount) --avg평균
						from tproduction t3 
									)
				)

--11. subquery(where)
--밑에 있는 세 개의 쿼리는 모두 같은 결과를 나타낸다. 의미 역시 같다.길이가 다를뿐
select t.ename 
from temployee t 
where t.enumber in (
			select t2.enumber 
			from tproduction t2, torder t3 , treturn t4 
			where t3.onumber = t4.onumber 
			and t2.pnumber = t3.pnumber 
		  			)
order by t.ename
;
--밑에 있는 두 개의 쿼리는 모두 같은 결과를 나타낸다. 의미 역시 같다.길이가 다를뿐
select t.ename 
from temployee t 
where t.enumber in (
					select t2.enumber 
					from tproduction t2
					where t2.pnumber in (
								select t3.pnumber 
								from torder t3 , treturn t4 
								where t3.onumber = t4.onumber 
								and to_char(t4.rdate,'YYYY-MM')='2022-01'								
										)
					)
order by t.ename
;
--밑에 있는 쿼리는 모두 같은 결과를 나타낸다. 의미 역시 같다.길이가 다를뿐
select t.ename 
from temployee t 
where t.enumber in (
					select t2.enumber 
					from tproduction t2
					where t2.pnumber in (
								select t3.pnumber 
								from torder t3 
								where t3.onumber in (
											select tre.onumber
											from treturn tre
											where to_char(tre.rdate,'YYYY-MM')='2022-01'
													)
										)
					)
order by t.ename
;		

--12. subquery(from)
select t.inumber, sum(t.pcount) as 총생산량
from tproduction t 
where t.pdate between cast('2020-01-01' as timestamp) and cast('2021-01-01' as timestamp)
group by t.inumber 
order by sum(t.pcount) desc
;
--from절에서 사용할 때에는 별칭을 사용해야 한다.
select tBase.inumber as 제품코드, tBase.pcount as 총생산량
from (
select t.inumber , sum(t.pcount) as pcount
from tproduction t 
where t.pdate between cast('2020-01-01' as timestamp) and cast('2020-12-31' as timestamp)
group by t.inumber 
	) as tBase --요고
order by tBase.pCount desc
;

