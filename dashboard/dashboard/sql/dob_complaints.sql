select pluto.cd, 
    pad.bbl, 
    pluto.address,
	pluto.unitsres as residentialunits, 
    uc2007, 
    uc2016,
    count(distinct complaintnumber) as dobcomplaints,
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

