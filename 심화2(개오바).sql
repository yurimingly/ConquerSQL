SELECT DName as 부서명 --서브쿼리 tBase2에서 문제에서 제시한 DName(부서명)과 IName(제품명을 가져온다)
	 , IName AS 제품명 
FROM
(
--반품률을 기준으로 부서의 순위를 출력해주되 1 위 부서가 2 개 일 수도 있기에 RANK 를 사용해주고 departmentrratio(부서 별 반품률) 을 기준으로 순위를 출력해 주었다
SELECT DName --서브쿼리 tBase 별칭 에서 DName(부서명)과 
	 , IName --IName(제품명)을 가져온 후
-- 1 위 부서 가 2 개 일 수도 있기에 RANK
	 , RANK() OVER(PARTITION BY DName ORDER BY itemrratio DESC) AS itemSeq
--				  (각 부서 별) 반품이 된 제품        (제일 반품이 많이된 제품 을 기준)으로 순위
	 , RANK() OVER(ORDER BY departmentrratio DESC) AS departmentSeq
	 --           (반품률)을 기준으로 부서의 순위를 출력해주되 해주고  departmentrratio(부서 별 반품률) 을 기준으로 순위를 출력해 주었다
FROM
(/*
 
하기 위해 을 하였고
*/
SELECT DISTINCT tde.DName --DISTINCT 를 사용하여 중복을 제거한다. DName(부서명) 을 출력하기 위해 부서 테이블인 tDepartment에서 부서 명 컬럼인 DName을 가져온다
	  , tit.IName
--IName(제품 명)을 출력하기 위해 제품 테이블인 tItem 에서 제품 명 컬럼인 IName을 가져온다
	  ,SUM(tpr.PCount) OVER(PARTITION BY tit.IName) AS totCount
--PCount(생산량)을 출력하기 위해 생산테이블인 tProduction 에서 생산량 컬럼인 PCount 를 가져온다
	  ,COALESCE(SUM(tre.RCount) OVER(PARTITION BY tit.IName), 0) AS RCount
--합을 위해 SUM 함수를 사용한다
	  ,COALESCE(CAST(CAST(SUM(tre.RCount) OVER(PARTITION BY tit.IName) AS FLOAT) --SUM(tre.RCount)(총 반품량) / SUM(총 생산량)
	  /CAST(SUM(tpr.PCount) OVER(PARTITION BY tit.IName) AS FLOAT) as DECIMAL), 0) AS itemrratio --Itemrratio 제품 별 반품률을 출력하기 위해 
--		   /SUM(총 생산량) 	 		 PARTITION BY에 제품 명 컬럼인 IName을 사용함으로써 각 제품명별로 구하는 GROUP BY 역할을 해주었고 
--    																	COALESCE 함수를 사용해 NULL인 값은 0 으로 출력한다
	  ,CAST(SUM(tre.RCount) OVER(PARTITION BY tde.DName) AS FLOAT) --SUM(tre.RCount)(총 반품량) / SUM(tpr.PCount)(총 생산량)
	  /CAST(SUM(tpr.PCount) OVER(PARTITION BY tde.DName) AS FLOAT) 				   AS departmentrratio --departmentrratio 부서 별 반품률 을 출력
--		   /SUM(총 생산량) 	 		 PARTITION BY 에 부서명 컬럼인 DName을 사용함으로써 각 부서명 별로 구하는 GROUP BY 역할을 해주었고 COALESCE 함수를 사용해 NULL 인 값은 0 으로 출력한다
FROM tOrder AS tor, tProduction AS tpr, tReturn AS tre, titem AS tit, tEmployee AS tem, tDepartment AS tde
where tpr.PNumber = tor.PNumber
and tre.ONumber = tor.ONumber --tReturn(반품 테이블)에 있는 RCount(반품량)을 가져오기 위해 와 한다
and tit.INumber = tpr.INumber
and tem.ENumber = tpr.ENumber
and tde.DNumber = tem.DNumber
ORDER BY tde.DName, tit.IName 
)AS tBase
)AS tBase2
WHERE itemseq = 1 AND departmentseq = 1 
--문제에서 제시한 반품량이 1 등 인 부서면서 해당 부서에서 가장 반품률이 높은 제품을 출력한다
/*
FROM tOrder AS tor
JOIN tProduction AS tpr 
ON tpr.PNumber = tor.PNumber
LEFT OUTER JOIN tReturn AS tre --반품하지 않은 주문 정보까지 출력해주기 위하여 LEFT OUTER JOIN 을 사용한다
ON tre.ONumber = tor.ONumber --tReturn(반품 테이블)에 있는 RCount(반품량)을 가져오기 위해 와 한다
--tReturn(반품 )테이블에 있는 RNumber(주문 코드)와 tOrder(주문 테이블)의 ONumber(주문 코드)를 JOIN
JOIN titem AS tit  
ON tit.INumber = tpr.INumber
JOIN tEmployee AS tem 
ON tem.ENumber = tpr.ENumber
JOIN tDepartment AS tde 
ON tde.DNumber = tem.DNumber
ORDER BY tde.DName, tit.IName 
 */