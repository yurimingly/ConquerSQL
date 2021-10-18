select month || '월' as 월
	  ,iName as 제품명
	  ,Pcount as 총판매수량
from 
	(SELECT to_char(tor.oDate,'MM') as Month
		  ,tit.iname as iName
		  ,sum(tpr.pcount) as Pcount
		  ,rank() over (partition by to_char(tor.odate,'MM') order by sum(tpr.pcount) desc) as Seq
	from tproduction tpr , titem tit, torder tor
	where tor.pnumber = tpr.pnumber 
	and tit.inumber = tpr.inumber 
	and to_char(tor.odate,'YYYY')='2021'
	group by to_char(tor.odate,'MM'), tit.iname 
	) as tBase
where Seq = 1
order by Month