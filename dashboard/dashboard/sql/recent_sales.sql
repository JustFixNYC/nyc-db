select pluto.cd,
      pluto.bbl,
	pluto.address,
      sales.residentialunits,
      pluto.unitsres,
	sales.saleprice as saleprice,
   	sales.saleprice / nullif(sales.grosssquarefeet, 0) as ppgsf,
	to_char(saledate, 'YYYY-MM-DD') as iso_date,
   	sales.saledate,
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
FROM dof_sales sales
LEFT JOIN pluto_16v2 pluto on sales.bbl = pluto.bbl
INNER JOIN rentstab ON rentstab.ucbbl = pluto.bbl
LEFT JOIN hpd_registrations_grouped_by_bbl_with_contacts hpd_reg on hpd_reg.bbl = pluto.bbl
WHERE pluto.cd is not null
      AND pluto.cd = '${ cd }'
      AND sales.saledate >= date_trunc('month', current_date - interval '2 month')
      AND sales.residentialunits > 0
      AND sales.saleprice > 50000
      AND COALESCE(uc2007,uc2008, uc2009, uc2010, uc2011, uc2012, uc2013, uc2014,uc2015,uc2016) is not null
order by sales.saledate desc;



