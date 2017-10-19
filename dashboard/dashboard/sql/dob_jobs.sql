SELECT
	pluto.cd,
	dobjobs.bbl,
	first(pluto.address) as address,
	first(pluto.unitsres) as residentialunits,
	uc2007, uc2016,
	first(corpnames) as corpnames,
	count(case when dobjobs.jobtype ='A1' then 1 else null end) as a1,
	count(case when dobjobs.jobtype='A2' then 1 else null end) as a2,
	count(case when dobjobs.jobtype='DM' then 1 else null end) as dm,
	sum(case
		when dobjobs.jobtype = 'A1' then 1
		when dobjobs.jobtype = 'A2' then 1
		when dobjobs.jobtype = 'DM' then 1
		else 0 end) as total,
	concat('<a href="http://a810-bisweb.nyc.gov/bisweb/PropertyProfileOverviewServlet?boro=',
       pluto.borocode,
       '&block=',
       pluto.block,
      '&lot=',
       pluto.lot,
      '">View on BIS</a>') as bislink,
     concat('<a href="http://a836-acris.nyc.gov/bblsearch/bblsearch.asp?borough=',
       pluto.borocode,
       '&block=',
       pluto.block,
      '&lot=',
       pluto.lot,
	  '">View on ACRIS</a>') as acrislink,
	case when ((cast(uc2007 as float) - 
                cast(uc2016 as float)) 
               /cast(uc2007 as float) >= 0.25) then 'yes' else 'no' end as highloss

FROM dobjobs
LEFT JOIN pluto_16v2 pluto on dobjobs.bbl = pluto.bbl
INNER JOIN rentstab rentstab on rentstab.ucbbl = dobjobs.bbl
LEFT JOIN hpd_registrations_grouped_by_bbl_with_contacts hpd_reg on hpd_reg.bbl = dobjobs.bbl
WHERE
   pluto.cd = '${ cd }'
   AND dobjobs.latestactiondate >= date_trunc('month', current_date - interval '1 month')
   AND coalesce(uc2007,uc2008, uc2009, uc2010, uc2011, uc2012, uc2013, uc2014,uc2015,uc2016) is not null
group by pluto.cd, 
		 dobjobs.bbl, 
         pluto.address, 
         pluto.unitsres, 
         uc2007, 
         uc2016, 
         corpnames, 
         pluto.borocode, 
         pluto.block, 
         pluto.lot
HAVING ( sum(case
		when dobjobs.jobtype = 'A1' then 1
		when dobjobs.jobtype = 'A2' then 1
		when dobjobs.jobtype = 'DM' then 1
		else 0 end) > 0 )
order by total desc

