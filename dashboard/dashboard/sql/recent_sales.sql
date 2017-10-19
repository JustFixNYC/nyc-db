select	pluto.bbl,
	concat(sales.address, ', ', sales.zipcode) as address,
    sales.residentialunits,
    pluto.unitsres,
	sales.saleprice as saleprice,
   	sales.saleprice / nullif(sales.grosssquarefeet, 0) as ppgsf,
	to_char(saledate, 'YYYY-MM-DD') as iso_date,
   	sales.saledate,
	hpd_reg.corpnames,
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
      /*test for high stab loss*/
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



