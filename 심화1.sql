--심화 advanced 1.
select Dname as 부서명, Cname as 고객명 --tBase 서브쿼리에서 결과물을 출력한 Dname, Cname 컬럼을 가져옴
from (
	select *
		,rank() over(partition by Dname order by tBase.cnt desc) as seq
		--tBase에서 1등 고객출력하되 여러 명일 수 있기에 rank를 썼고 partition by에 부서명 컬럼인 dname을 써서 부서별 결과를 출력했으며
		--order by에 존재하는 cnt(고객주문횟수)로 순위를 출력해준다
	from 
	(
		select tdp.dname as Dname
			  ,tcu.cname as Cname
			  ,count(tcu.cname) as cnt
		from torder tor, tcustomer tcu, tproduction tpro, temployee tem, tdepartment tdp
		where tor.cnumber = tcu.cnumber --주문테이블.고객코드=고객.고객코드  // 고객테이블 통해 고객명 가져오려고 
		and tor.pnumber = tpro.pnumber --주문.생산코드=생산.생산코드 // 생산테이블에서 생산코드 가져오기
		and tem.enumber = tpro.enumber -- 직원.직원코드=생산.직원코드 // 직원테이블을 통해 직원코드 데이터 가져오기
		and tdp.dnumber = tem.dnumber  --부서.부서코드=직원.부서코드 // 부서 테이블 통해 부서명 가져오기
		group by tdp.dname , tcu.cname	
	) as tBase
) as tBase2
where seq = 1 --제일 많은 구매 횟수를 가진 고객 1명
order by dname