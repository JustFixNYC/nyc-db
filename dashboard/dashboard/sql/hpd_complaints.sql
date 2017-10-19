select pluto.cd, 
    hpd.bbl, 
    pluto.address,
    pluto.unitsres as residentialunits, 
    uc2007, uc2016, 
    corpnames,
    count(distinct complaintid) as hpdcomplaints,
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
from hpdcomplaints hpd
left join pluto_16v2 pluto on pluto.bbl=hpd.bbl
inner join rentstab on rentstab.ucbbl=hpd.bbl
left join hpd_registrations_grouped_by_bbl_with_contacts hpd_reg on hpd_reg.bbl = hpd.bbl
where cast(receiveddate as date) >= date_trunc('month', current_date - interval '1 month') and
	pluto.unitsres > 0
    and coalesce(uc2007,uc2008, uc2009, uc2010, uc2011, uc2012, uc2013, uc2014,uc2015,uc2016) is not null
group by pluto.cd, 
		 hpd.bbl, 
         pluto.address, 
         pluto.unitsres, 
         uc2007, 
         uc2016, 
         corpnames, 
         pluto.borocode, 
         pluto.block, 
         pluto.lot
having count(distinct complaintid) > 2
order by pluto.cd asc, hpdcomplaints desc

