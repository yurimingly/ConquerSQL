select to_char(tor.odate,'MM') || '월' as 월
	  ,sum(tpr.pcount) as 월별판매량
FROM torder tor, tproduction tpr, temployee tem, tdepartment tde
where tor.pnumber = tpr.pnumber 
and tpr.enumber = tem.enumber 
and tem.dnumber = tde.dnumber 
and tde.dname = '음료생산부'
and to_char(tor.Odate,'YYYY') = '2021'
group by to_char(tor.odate,'MM')
order by to_char(tor.odate,'MM')
;