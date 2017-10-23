select viols.bbl, 
	pluto.cd, 
	pluto.address,
	pluto.unitsres as residentialunits,
	uc2007, uc2016,
	corpnames,
	count(case when violationclass = 'A' then 1 else null end) as class_a,
	count(case when violationclass = 'B' then 1 else null end) as class_b,
	count(case when violationclass = 'C' then 1 else null end) as class_c,
		sum(case
		when violationclass = 'A' then 1
		when violationclass = 'B' then 1
		when violationclass = 'C' then 1
		else 0 end) as total,
	     concat('<a href="http://whoownswhat.justfix.nyc/address/',
            case 
                  when pluto.borocode = '1' then 'MANHATTAN'
                  when pluto.borocode = '2' then 'BRONX'
                  when pluto.borocode = '3' then 'BROOKLYN'
                  when pluto.borocode = '4' then 'QUEENS'
                  when pluto.borocode = '5' then 'STATEN ISLAND'
             end,
            '/',
            split_part(pluto.address,' ',1),
            '/',
            split_part(pluto.address,' ',2),
            '%20',
            split_part(pluto.address,' ',3),
            '%20',
            split_part(pluto.address,' ',4),
            '" target="_blank">',
            hpd_reg.corpnames,
            ' </a>') as owner,
      concat('<a href="https://hpdonline.hpdnyc.org/HPDonline/Provide_address.aspx?p1=',
            pluto.borocode,
            '&p2=',
            split_part(pluto.address,' ', 1),
            '&p3=',
            split_part(pluto.address,' ',2),
            '+',
            split_part(pluto.address,' ',3),
            '+',
            split_part(pluto.address,' ',4),
            '" target="_blank">',
            '(HPD)</a>') as hpdlink,
      concat('<a href="http://a810-bisweb.nyc.gov/bisweb/PropertyProfileOverviewServlet?boro=',
            pluto.borocode,
            '&block=',
            pluto.block,
            '&lot=',
            pluto.lot,
            '">(BIS)</a>') as bislink,
      concat('<a href="http://a836-acris.nyc.gov/bblsearch/bblsearch.asp?borough=',
            pluto.borocode,
            '&block=',
            pluto.block,
            '&lot=',
            pluto.lot,
            '">(ACRIS)</a>') as acrislink,
      case when ((cast(uc2007 as float) - 
                cast(uc2016 as float)) 
               /cast(uc2007 as float) >= 0.25) then 'yes' else 'no' end as highloss
from hpd_violations viols
left join pluto_16v2 pluto on pluto.bbl = viols.bbl
inner join rentstab on rentstab.ucbbl=viols.bbl
left join hpd_registrations_grouped_by_bbl_with_contacts hpd_reg on hpd_reg.bbl = viols.bbl
where 
	pluto.cd = '${ cd }' 
	and novissueddate >= date_trunc('month', current_date - interval '2 month')
    AND coalesce(uc2007,uc2008, uc2009, uc2010, uc2011, uc2012, uc2013, uc2014,uc2015,uc2016) is not null
group by pluto.cd, 
		 viols.bbl,  
         pluto.address, 
         pluto.unitsres, 
         uc2007, 
         uc2016, 
         corpnames, 
         pluto.borocode, 
         pluto.block, 
         pluto.lot
having count(violationclass) > 9
order by pluto.cd asc, total desc;


