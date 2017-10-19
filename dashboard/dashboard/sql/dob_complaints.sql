select pluto.cd, 
    pad.bbl, 
    pluto.address,
	pluto.unitsres as residentialunits, 
    uc2007, 
    uc2016,
    corpnames,
    count(distinct complaintnumber) as dobcomplaints,
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
from dobcomplaints dob
left join padadr pad on pad.bin = dob.bin
inner join pluto_16v2 pluto on pluto.bbl=pad.bbl
inner join rentstab on rentstab.ucbbl=pad.bbl
LEFT JOIN hpd_registrations_grouped_by_bbl_with_contacts hpd_reg on hpd_reg.bbl = pad.bbl
where cast(date_entered as date) >= date_trunc('month', current_date - interval '1 month') and
    AND pluto.cd = '${ cd }'
    pluto.unitsres > 0 
	AND COALESCE(uc2007,uc2008, uc2009, uc2010, uc2011, uc2012, uc2013, uc2014,uc2015,uc2016) is not null
group by pad.bbl, 
		 pluto.address, 
         pluto.cd, 
         pluto.unitsres, 
         uc2007, 
         uc2016, 
         corpnames, 
         pluto.borocode, 
         pluto.block, 
         pluto.lot
having count(distinct complaintnumber) > 1
order by pluto.cd asc, dobcomplaints desc

