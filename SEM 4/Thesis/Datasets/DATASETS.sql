--DATASETS
--TARGET_VARIABLE (WHAT TO PREDICT)
select distinct cast(offerid as varchar) BUNDLE_ID, 
bundlename BUNDLE_NAME, bundletype BUNDLE_TYPE,
category BUNDLE_CATEGORY, 
BENEFITS, 
PRICE, 
VALIDITY BUNDLE_VALIDITY_DAYS, 
description as BUNDLE_DESCRIPTION
from postgresql.masters.leap_product_catalog_master


--BUNDLE_CONSUMPTION (DEPLETION) --LIMIT THESE TO ONLY KAMPALA AND CBD
select A.*, SITE_CODE--, REGION, sitename TOWN_NAME, LATITUDE, LONGITUDE 
from 
(
select EVENTDATE, SERVEDMSISDN, 
SUM(voice_og_onnet) OG_ONNET_MINUTES_USED, 
SUM(voice_og_offnet) OG_OFFNET_MINUTES_USED,
SUM(voice_og_ild) OG_INTERNATIONAL_MINUTES_USED,
SUM(voice_og_unclassified) OG_UNCLASSIFIED_MINUTES_USED, 
SUM(total_voice_og) TOTAL_OG_MINUTES_USED,
SUM(voice_ic_onnet) _ONNET_MINUTES_USED, 
SUM(voice_ic_offnet) IC_OFFNET_MINUTES_USED,
SUM(voice_ic_ild) IC_INTERNATIONAL_MINUTES_USED,
SUM(voice_ic_unclassified) IC_UNCLASSIFIED_MINUTES_USED, 
SUM(total_voice_ic) TOTAL_IC_MINUTES_USED
from iceberg.adhoc.br_daily_voice_usage 
where eventdate between DATE '${START_DATE}' and DATE '${END_DATE}'
group by EVENTDATE, SERVEDMSISDN
) A 
INNER join 
(
	select * from 
	(
	select * from 
		(select distinct servedmsisdn,inactivationtime, dense_rank () over(partition by servedmsisdn order by inactivationtime desc) rnk,
		favouritelocation[array_max(filter(map_keys(favouritelocation), x -> x <= '${FINAL_DATE} 00:00:00'))]  as favouritelocation,
		cast(favouritedevice[array_max(filter(map_keys(favouritedevice), x -> x <= '${FINAL_DATE} 00:00:00'))] as varchar) as favdevice ,
		serviceclass[array_max(filter(map_keys(serviceclass), x -> x <= '${FINAL_DATE} 00:00:00'))]  as serviceclass
		from hive.canvas.subscriberdimension
		where   favouritelocation[array_max(filter(map_keys(favouritelocation), x -> x <= '${FINAL_DATE} 00:00:00'))]  is not null
		and cast(favouritedevice[array_max(filter(map_keys(favouritedevice), x -> x <= '${FINAL_DATE} 00:00:00'))] as varchar) is not null
		and serviceclass[array_max(filter(map_keys(serviceclass), x -> x <= '${FINAL_DATE} 00:00:00'))]  is not null
		) where rnk = 1 --and serviceclass not in ('8000000','700001','800001')
	) X 
	left join 
	(
		select * from (
		select lacid, cellid, physicalsiteid site_code, region, state, DISTRICT, LATITUDE, LONGITUDE, sitename 
		, case when upper(region) in ('NORTH', 'WESTNILE') then 'SuperGrowth' when upper(region) in ('WEST 1', 'WEST 2', 'EAST 2') then 'Growth' else 'Core' end market
		, siteclassification siteclass, sitecategory sitecat , dense_rank () over(partition by lacid, cellid order by reportdate desc) rnk
		from postgresql.masters.geo_master) where rnk = 1
	) Y
	on (X.favouritelocation=concat(cast(Y.lacid as varchar),'-',cast(Y.cellid as varchar)))
) B
on A.SERVEDMSISDN = B.SERVEDMSISDN
where B.REGION in (
'KAMPALA',
'CENTRAL 1',
'CENTRAL 2'
)
and TOTAL_OG_MINUTES_USED > 0
and cast(A.SERVEDMSISDN as VARCHAR) in (select SERVEDMSISDN from hive.sre.BR_SAMPLE_SPACE__13403963)
limit 500000;


--SAMPLE_SPACE
select * from hive.sre.BR_SAMPLE_SPACE__13403963



--LOCATION DETAILS
select SITE_CODE, sitename TOWN_NAME, REGION, STATE, DISTRICT, LATITUDE, LONGITUDE, CLUSTER
from (
	select distinct physicalsiteid site_code, region, upper(state) state, locality, DISTRICT, LATITUDE, LONGITUDE
		, case when upper(region) in ('NORTH', 'WESTNILE') then 'SuperGrowth' when upper(region) in ('WEST 1', 'WEST 2', 'EAST 2') then 'Growth' else 'Core' end market
	, siteclassification siteclass, sitecategory sitecat , launchdate, zone, sitename, cluster, territory
	, dense_rank () over(partition by physicalsiteid order by reportdate desc) rnk
from postgresql.masters.geo_master 
 ) where rnk = 1
 
 
 
 
 

--PURCHASE_TIMING (TEMPORAL)
select 
Transaction_Date PURCHASE_DATE,
transactionHOUR PURCHASE_HOUR, 
Charged_Number, 
coalesce(site_code,'Unclassified') AS SITE_ID, 
--coalesce(HANDSET_TYPE, '2G') as HANDSET_TYPE, 
Offering_Id BUNDLE_ID, 
TRANSACTION_CHANNEL,  
PAYMENT_CHANNEL,
--CATEGORY, 
REGION, 
SUM(coalesce(Transaction_Amount, 0)) 	BUNDLE_REVENUE
from (
select Transaction_Date,
substring(Charged_Number,4,12) Charged_Number, 
Reciever_Number,
K.Offering_Id,
Transaction_Amount,
Bundle_Name,
coalesce(description,'N/A') Category,
Transaction_Type,
Bundle_Validity,
Operatorid,
Transaction_Channel,   
Payment_Channel,
Serviceclassid, transactionHOUR
from 
(select transactiondate Transaction_Date,
extprovisionedmsisdn Reciever_Number, extchargedmsisdn Charged_Number,cast(offeringid as varchar) Offering_Id
,extamount Transaction_Amount,extservicetype Transaction_Type,
date_diff('day',cyclebegintime,cycleendtime) Bundle_Validity, 
upper(Operatorid)Operatorid ,upper(extpaymentchannel) Transaction_Channel,
upper(extpaymentmode) Payment_Channel,cast(Serviceclassid as varchar) Serviceclassid, transactionHOUR
from
(select distinct eventtime ,transactiondate,extprovisionedmsisdn , extchargedmsisdn ,OfferingId ,extamount ,extservicetype ,
cyclebegintime,cycleendtime, Operatorid ,extpaymentchannel, extpaymentmode ,Serviceclassid,stdevttypeid, transactionHOUR
from hive.canvas.ocsmonmaininternal where 
transactiondate between DATE '${START_DATE}' and DATE '${END_DATE}' ----------*****change date*******
)
where
--and serviceclassid NOT IN (8000000,700001,800001) 
--and
stdevttypeid = 14001    
and (LOWER(Operatorid) not like '%bonus%' or Operatorid is NULL) and lower(extservicetype) not like '%me%2%u%' and lower(extpaymentmode) not like '%campaign%'
and lower(extpaymentmode) not like '%acquisition%' and extamount > 0) K
left join 
(select distinct cast(offerid as varchar) offering_id,description,bundlename Bundle_Name from postgresql.masters.leap_product_catalog_master) S 
on (K.Offering_Id=S.offering_id) 
union all 
select transactiondate,extchargedmsisdn Charged_Number,extprovisionedmsisdn Reciever_Number,
CASE
WHEN (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=250 THEN '6000463'
WHEN (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=500 THEN '6000464'
WHEN (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=1000 THEN '6000465'
WHEN (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=2000 THEN '6000466'
WHEN (UPPER(additionalinfo) LIKE '%VK%' or UPPER(additionalinfo) LIKE '%LV%') AND initloanamt=500 THEN '6051430'
WHEN (UPPER(additionalinfo) LIKE '%VK%' or UPPER(additionalinfo) LIKE '%LV%') AND initloanamt=1000 THEN '6051437'
WHEN (UPPER(additionalinfo) LIKE '%VK%' or UPPER(additionalinfo) LIKE '%LV%') AND initloanamt=2000 THEN '9999999'
END Offering_Id, 
initloanamt Transaction_amount, 
CASE
WHEN  (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=250 THEN 'BeeraKo_15MB'
WHEN  (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=500 THEN 'BeeraKo_40MB'
WHEN  (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=1000 THEN 'BeeraKo_100MB'
WHEN  (UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%') AND initloanamt=2000 THEN 'BeeraKo_300MB'
WHEN  (UPPER(additionalinfo) LIKE '%VK%' or UPPER(additionalinfo) LIKE '%LV%') AND initloanamt=500 THEN 'BeeraKo_Kawa'
WHEN  (UPPER(additionalinfo) LIKE '%VK%' or UPPER(additionalinfo) LIKE '%LV%') AND initloanamt=1000 THEN 'BeeraKo_Paka'
WHEN  (UPPER(additionalinfo) LIKE '%VK%' or UPPER(additionalinfo) LIKE '%LV%') AND initloanamt=2000 THEN 'BeeraKo_Daily_2000'
END Bundle_Name,
CASE     
WHEN UPPER(additionalinfo) LIKE '%DK%' or UPPER(additionalinfo) LIKE '%LD%' THEN 'Data_OM'
WHEN UPPER(additionalinfo) LIKE '%VK%' or UPPER(additionalinfo) LIKE '%LV%' THEN 'Voice_OM' END CATEGORY,
extservicetype Transaction_Type, 1 Bundle_validity,
case when UPPER(additionalinfo) like '%VK%' then 'VK' when UPPER(additionalinfo) like '%DK%' then 'DK' 
when UPPER(additionalinfo) like '%LV%' then 'LV' when UPPER(additionalinfo) like '%LD%' then 'LD' else 'N/A' end  Operator_Id,
upper(extpaymentchannel) Transaction_Channel,upper(extpaymentmode) Payment_Channel,cast(Serviceclassid as varchar) Serviceclassid, transactionHOUR
from hive.canvas.ocsloanmaininternal   
where 
transactiondate between DATE '${START_DATE}' and DATE '${END_DATE}' ----------*****change date*******
--and serviceclassid NOT IN (8000000,700001,800001) 
and operationtype = 'L'    
and (UPPER(additionalinfo) like '%DK%' OR UPPER(additionalinfo) like '%VK%' OR UPPER(additionalinfo) like '%LD%' or UPPER(additionalinfo) like '%LV%')
) A 
left join 
(
	select * from 
	(
	select * from 
		(select distinct servedmsisdn,inactivationtime, dense_rank () over(partition by servedmsisdn order by inactivationtime desc) rnk,
		favouritelocation[array_max(filter(map_keys(favouritelocation), x -> x <= '${FINAL_DATE} 00:00:00'))]  as favouritelocation,
		cast(favouritedevice[array_max(filter(map_keys(favouritedevice), x -> x <= '${FINAL_DATE} 00:00:00'))] as varchar) as favdevice ,
		serviceclass[array_max(filter(map_keys(serviceclass), x -> x <= '${FINAL_DATE} 00:00:00'))]  as serviceclass
		from hive.canvas.subscriberdimension
		where   favouritelocation[array_max(filter(map_keys(favouritelocation), x -> x <= '${FINAL_DATE} 00:00:00'))]  is not null
		and cast(favouritedevice[array_max(filter(map_keys(favouritedevice), x -> x <= '${FINAL_DATE} 00:00:00'))] as varchar) is not null
		and serviceclass[array_max(filter(map_keys(serviceclass), x -> x <= '${FINAL_DATE} 00:00:00'))]  is not null
		) where rnk = 1 --and serviceclass not in ('8000000','700001','800001')
	) X 
	left join 
	(
		select * from (
		select lacid, cellid, physicalsiteid site_code, region, state
		, case when upper(region) in ('NORTH', 'WESTNILE') then 'SuperGrowth' when upper(region) in ('WEST 1', 'WEST 2', 'EAST 2') then 'Growth' else 'Core' end market
		, siteclassification siteclass, sitecategory sitecat , dense_rank () over(partition by lacid, cellid order by reportdate desc) rnk
		from postgresql.masters.geo_master) where rnk = 1
	) Y
	on (X.favouritelocation=concat(cast(Y.lacid as varchar),'-',cast(Y.cellid as varchar)))
	left join 
	(select cast(tac as varchar) TAC,COALESCE(MANUFACTURER,'Unclassified') MANUFACTURER, COALESCE(MODELNAME,'Unclassified')MODEL_NAME, COALESCE(DEVICETYPE,'Unclassified')DEVICE_TYPE,
	SERVICEVOLTE,NUMBEROFSIMSLOTS,  
	COALESCE(CASE WHEN UPPER(BEARER5G) = 'YES' THEN '5G'
	WHEN UPPER(LTE) = 'YES' OR UPPER(LTEFDDBAND1) = 'YES' OR UPPER(LTEFDDBAND10) = 'YES' OR UPPER(LTEFDDBAND11) = 'YES' OR
	        UPPER(LTEFDDBAND12) = 'YES' OR UPPER(LTEFDDBAND13) = 'YES' OR UPPER(LTEFDDBAND14) = 'YES' OR
	        UPPER(LTEFDDBAND15) = 'YES' OR UPPER(LTEFDDBAND16) = 'YES' OR UPPER(LTEFDDBAND17) = 'YES' OR
	        UPPER(LTEFDDBAND18) = 'YES' OR UPPER(LTEFDDBAND19) = 'YES' OR UPPER(LTEFDDBAND2) = 'YES' OR UPPER(LTEFDDBAND20) = 'YES' OR
	        UPPER(LTEFDDBAND21) = 'YES' OR UPPER(LTEFDDBAND25) = 'YES' OR UPPER(LTEFDDBAND26) = 'YES' OR
	        UPPER(LTEFDDBAND27) = 'YES' OR UPPER(LTEFDDBAND28) = 'YES' OR UPPER(LTEFDDBAND3) = 'YES' OR
	        UPPER(LTEFDDBAND4) = 'YES' OR UPPER(LTEFDDBAND5) = 'YES' OR UPPER(LTEFDDBAND6) = 'YES' OR
	        UPPER(LTEFDDBAND7) = 'YES' OR UPPER(LTEFDDBAND8) = 'YES' OR UPPER(LTEFDDBAND9) = 'YES' OR
	        UPPER(LTETDDBAND33) = 'YES' OR UPPER(LTETDDBAND34) = 'YES' OR UPPER(LTETDDBAND35) = 'YES' OR
	        UPPER(LTETDDBAND36) = 'YES' OR UPPER(LTETDDBAND37) = 'YES' OR UPPER(LTETDDBAND38) = 'YES' OR
	        UPPER(LTETDDBAND39) = 'YES' OR UPPER(LTETDDBAND40) = 'YES' OR UPPER(LTETDDBAND41) = 'YES' OR
	        UPPER(LTETDDBAND42) = 'YES' OR UPPER(LTETDDBAND43) = 'YES' OR UPPER(SERVICEVOLTE) = ('YES') THEN '4G'
	WHEN UPPER(DEVICE3GDCHSDPA) = 'YES' OR UPPER(DEVICE3G2100) = 'YES' OR UPPER(MOBILE3G) = 'YES' OR UPPER(DEVICE3GU900) = 'YES'
	        OR UPPER(DEVICE3GUMTS) = 'YES' THEN '3G'
	WHEN UPPER(EDGE) = 'YES' OR UPPER(MOBILE2G) = 'YES' OR UPPER(MANUFACTURER) = 'FAKE' or TAC IS NOT NULL THEN '2G' ELSE 'Unclassified' end
	, 'Unclassified') HANDSET_TYPE
	from  postgresql.masters.device_master
	) Z
on X.favdevice = Z.tac
) B
on cast(B.servedmsisdn as varchar) = cast(A.Reciever_Number as varchar)
where Serviceclassid not in ('8000000','700001','800001')
and UPPER(CATEGORY) in ('VOICE_OM','VMP','COMBO')
and REGION in (
'KAMPALA',
'CENTRAL 1',
'CENTRAL 2'
)
and Charged_Number in (select substring(FIELD_1, 4, 12) from hive.sre.BR_SAMPLA_SPACE_2_13403963)
--and substring(Charged_Number, 1, 2) LIKE '74%'
group by 
serviceclass,
coalesce(site_code,'Unclassified'), 
--coalesce(HANDSET_TYPE, '2G'), 
--CATEGORY, 
region, 
Transaction_Date,
Charged_Number, Offering_Id, 
TRANSACTION_CHANNEL,  
PAYMENT_CHANNEL, transactionHOUR
--limit 500000;







--CUSTOMER_PROFILE
select * from 
(
select 
--SUBSTRING(cast(X.servedmsisdn*256 as VARCHAR), 4, 12) PHONE_NUMBER,
SUBSTRING(cast(X.servedmsisdn as VARCHAR), 4, 12) PHONE_NUMBER,
DEVICE_TYPE,
case when coalesce(HANDSET_TYPE, '2G') in ('3G','4G','5G') then 'SP' else 'FP' end HANDSET_TYPE, --SP - SMARTPHONE, FP - FEATURE PHONE
SITE_CODE, 
REGION, 
--SITENAME LOCATION, latitude, longitude, 
GENDER,
--GROSSADD,
--Win_Backs, 
--Recon, 
--Churn_30_days, 
--RECCHURN, 
REC_30_DAYS, --ACTIVE in THE last 30 DAYS
--REC_90_DAYS,
QREC, --is A data USER
--QREC100 QREC100MBS, 
AGE, 
AGE_ON_NETWORK TENURE_DAYS, 
VALUESEGMENT, 
SUM(TOTAL_REVENUE) TOTAL_REVENUE, 
--MIN(CAST(FLOOR(rand() * (900000 - 2000 + 3000) + 500) AS INTEGER)) AIRTIME, 
MIN(CAST(FLOOR(rand() * (1005000 - 5000 + 4000) + 1500) AS INTEGER)) MOBILE_MONEY, 
--sum(voicepayg) voicepayg, sum(datapayg) datapayg, sum(smspayg) smspayg,
--sum(voicebundlerevenue) voicebundlerevenue, sum(databundlerevenue) databundlerevenue, sum(smsbundlerevenue) smsbundlerevenue,
--FAVPAYMENTMODE, 
SUM(CALLS) CALLS--, 
--SUM(SMSS) SMSS,
--SUM(MBS) MBS
from 
(
select * from (select distinct servedmsisdn,inactivationtime, 
	dense_rank () over(partition by servedmsisdn order by inactivationtime desc) rnk,
	favouritelocation[array_max(filter(map_keys(favouritelocation), x -> x <= concat(cast(date_add('day',-1,current_date) + interval '1' day as varchar), ' 00:00:00')))]  as favouritelocation,
	favouritedevice[array_max(filter(map_keys(favouritedevice), x -> x <= concat(cast(date_add('day',-1,current_date) + interval '1' day as varchar), ' 00:00:00')))] as favdevice, 
	coalesce(cast(split_part(trim(serviceclass[array_max(filter(map_keys(serviceclass), x -> x <= concat(cast(date_add('day',-1,current_date) + interval '1' day as varchar), ' 00:00:00')))]) , '-',1) as integer), 0)  serviceclass
	from hive.canvas.subscriberdimension) where rnk=1 --and serviceclass not in ('8000000','700001','800001')
) X 
left join 
(
	select * from (
	select lacid, cellid, physicalsiteid site_code, region, SITENAME, latitude, longitude
	, case when upper(region) in ('NORTH', 'WESTNILE') then 'SuperGrowth' when upper(region) in ('WEST 1', 'WEST 2', 'EAST 2') then 'Growth' else 'Core' end market
	, siteclassification siteclass, sitecategory SITE_CATEGORY , dense_rank () over(partition by lacid, cellid order by reportdate desc) rnk
	from postgresql.masters.geo_master) where rnk = 1
) Y
on (X.favouritelocation=concat(cast(Y.lacid as varchar),'-',cast(Y.cellid as varchar)))
left join 
(select cast(tac as varchar) TAC,COALESCE(MANUFACTURER,'Unclassified') MANUFACTURER, COALESCE(MODELNAME,'Unclassified')MODEL_NAME, COALESCE(DEVICETYPE,'Unclassified')DEVICE_TYPE,
SERVICEVOLTE,NUMBEROFSIMSLOTS,  
COALESCE(CASE WHEN UPPER(BEARER5G) = 'YES' THEN '5G'
WHEN UPPER(LTE) = 'YES' OR UPPER(LTEFDDBAND1) = 'YES' OR UPPER(LTEFDDBAND10) = 'YES' OR UPPER(LTEFDDBAND11) = 'YES' OR
        UPPER(LTEFDDBAND12) = 'YES' OR UPPER(LTEFDDBAND13) = 'YES' OR UPPER(LTEFDDBAND14) = 'YES' OR
        UPPER(LTEFDDBAND15) = 'YES' OR UPPER(LTEFDDBAND16) = 'YES' OR UPPER(LTEFDDBAND17) = 'YES' OR
        UPPER(LTEFDDBAND18) = 'YES' OR UPPER(LTEFDDBAND19) = 'YES' OR UPPER(LTEFDDBAND2) = 'YES' OR UPPER(LTEFDDBAND20) = 'YES' OR
        UPPER(LTEFDDBAND21) = 'YES' OR UPPER(LTEFDDBAND25) = 'YES' OR UPPER(LTEFDDBAND26) = 'YES' OR
        UPPER(LTEFDDBAND27) = 'YES' OR UPPER(LTEFDDBAND28) = 'YES' OR UPPER(LTEFDDBAND3) = 'YES' OR
        UPPER(LTEFDDBAND4) = 'YES' OR UPPER(LTEFDDBAND5) = 'YES' OR UPPER(LTEFDDBAND6) = 'YES' OR
        UPPER(LTEFDDBAND7) = 'YES' OR UPPER(LTEFDDBAND8) = 'YES' OR UPPER(LTEFDDBAND9) = 'YES' OR
        UPPER(LTETDDBAND33) = 'YES' OR UPPER(LTETDDBAND34) = 'YES' OR UPPER(LTETDDBAND35) = 'YES' OR
        UPPER(LTETDDBAND36) = 'YES' OR UPPER(LTETDDBAND37) = 'YES' OR UPPER(LTETDDBAND38) = 'YES' OR
        UPPER(LTETDDBAND39) = 'YES' OR UPPER(LTETDDBAND40) = 'YES' OR UPPER(LTETDDBAND41) = 'YES' OR
        UPPER(LTETDDBAND42) = 'YES' OR UPPER(LTETDDBAND43) = 'YES' OR UPPER(SERVICEVOLTE) = ('YES') THEN '4G'
WHEN UPPER(DEVICE3GDCHSDPA) = 'YES' OR UPPER(DEVICE3G2100) = 'YES' OR UPPER(MOBILE3G) = 'YES' OR UPPER(DEVICE3GU900) = 'YES'
        OR UPPER(DEVICE3GUMTS) = 'YES' THEN '3G'
WHEN UPPER(EDGE) = 'YES' OR UPPER(MOBILE2G) = 'YES' OR UPPER(MANUFACTURER) = 'FAKE' or TAC IS NOT NULL THEN '2G' ELSE 'Unclassified' end
, 'Unclassified') HANDSET_TYPE
	from  postgresql.masters.device_master
	) Z
on X.favdevice = Z.tac
--left join  
--( 
----SMS COUNT
--select eventdate, servedmsisdn, COUNT(*) SMSS
--from  hive.canvas.ocssmsinternal 
--where eventdate between DATE '${START_DATE}' and DATE '${END_DATE}'
--group by eventdate, servedmsisdn
--) A
--on X.servedmsisdn = A.servedmsisdn
--left join  
--(
----DATA USAGE
--select
--eventdate, 
--servedmsisdn, 
--sum(totalusage)/1024/1024 as MBS
--from hive.canvas.ocsgprsinternal
--where eventdate >= date '${START_DATE}' and eventdate <= date '${END_DATE}'
--group by 
--eventdate, 
--servedmsisdn
--) B
--on X.servedmsisdn = B.servedmsisdn
left join 
( 
--CALLS
select eventdate, servedmsisdn, COUNT(*) CALLS
from hive.canvas.ocsvoiceinternal 
where eventdate >= date '${START_DATE}' and eventdate <= date '${END_DATE}'
--eventdate between date_add('day',-54,current_date) and  date_add('day',-34,current_date) --------**********change date***************
and lower(datasetname) like '%ocs%voice%'  
--and mainchargedamount > 0
and stdevttypeid = '11000' and substring(cast(servedimsi as varchar),1,3) = '641' 
and coalesce(bnumberbasiscalltype, 0) not in (5,6)
group by eventdate, servedmsisdn
) C
on X.servedmsisdn = C.servedmsisdn
left join 
( 
select 
servedmsisdn, 
--Win_Backs, 
--Recon, 
--Churn_30_days, 
Rec_30_Days, 
--Rec_90_Days, 
AGE_ON_NETWORK
from (
	select snapshotdate dt, servedmsisdn , recstatus , rgestatus, rgelastactivitytime lasttime
	, extract(day from date(snapshotdate) - date(rgelastactivitytime)) AGE_ON_NETWORK,
--	case when activitystatus = 2 then 1 else 0 end Win_Backs,
--	case when activitystatus = 3 then 1 else 0 end Recon,
--	case when activitystatus = 5 then 1 else 0 end Churn_30_days,
	case when recstatus = true then 1 else 0 end Rec_30_Days, 
	case when rec90daysstatus = true then 1 else 0 end Rec_90_Days
	, rank() over (partition by servedmsisdn order by inactivationtime desc) as rnk
	from hive.fractal.subscriber_lifecycle
	where snapshotdate = '${END_DATE}'  and recstatus = true
) where rnk = 1
) D
on X.servedmsisdn = D.servedmsisdn 
left join 
(
select 
servedmsisdn, 
--SUM(case when activitystatus = 'RECChurn' and snapshotdate = '${END_DATE}' then 1 else 0 end) recChurn, 
SUM(case when rec90daysstatus = 1 and snapshotdate = '${END_DATE}' then 1 else 0 end) sysbase,
SUM(case when QREC = 1 and snapshotdate = '${END_DATE}' then 1 else 0 end) QREC,
--SUM(case when qrec100 = 1 and snapshotdate = '${END_DATE}' then 1 else 0 end) qrec100,
--SUM(grossadd) grossadd,
sum(revenue) TOTAL_REVENUE,  
--sum(voicepayg) voicepayg, sum(datapayg) datapayg, sum(smspayg) smspayg,
--sum(voicebundlerevenue) voicebundlerevenue, sum(databundlerevenue) databundlerevenue, sum(smsbundlerevenue) smsbundlerevenue,
dob,
date_diff('year', DATE(dob), current_date) AS age,
VALUESEGMENT, 
case 
	when UPPER(GENDER) = 'FEMALE' then 'F' 
	when UPPER(GENDER) = 'MALE' then 'M' 
	else GENDER
end GENDER--, 
--case when UPPER(FAVPAYMENTMODE) = 'AIRTIME' then 'AIRTIME' when UPPER(FAVPAYMENTMODE) = 'AM' then 'AM' else 'AM' END FAVPAYMENTMODE
from hive.fractal.crystal
where snapshotdate between '${START_DATE}' AND '${END_DATE}'
group by 
servedmsisdn, 
dob,
date_diff('year', DATE(dob), current_date),
VALUESEGMENT, 
case 
	when UPPER(GENDER) = 'FEMALE' then 'F' 
	when UPPER(GENDER) = 'MALE' then 'M' 
	else GENDER
end--, 
--case when UPPER(FAVPAYMENTMODE) = 'AIRTIME' then 'AIRTIME' when UPPER(FAVPAYMENTMODE) = 'AM' then 'AM' else 'AM' END
) E
on X.servedmsisdn = E.servedmsisdn 
group by 
X.servedmsisdn,
DEVICE_TYPE,
case when coalesce(HANDSET_TYPE, '2G') in ('3G','4G','5G') then 'SP' else 'FP' end, 
REGION, 
SITE_CODE, 
--SITENAME, latitude, longitude, 
GENDER,
AGE_ON_NETWORK, 
--GROSSADD,
--Win_Backs, 
--Recon, 
--Churn_30_days, 
--RECCHURN, 
Rec_30_Days, 
--Rec_90_Days,
QREC, 
--QREC100, 
AGE, 
VALUESEGMENT--, 
--FAVPAYMENTMODE
)
where GENDER in ('F','M')
and REGION in (
'KAMPALA',
'CENTRAL 1',
'CENTRAL 2'
)
and '256'||PHONE_NUMBER in (select * from hive.sre.BR_SAMPLA_SPACE_2_13403963)
and PHONE_NUMBER not in (select * from hive.sre.BR_SAMPLe_SPACE_3_13403963)
and PHONE_NUMBER not like '20%' and PHONE_NUMBER like '74%'
and CALLS > 0
and DEVICE_TYPE in ('Phone', 'Tablet', 'Smartwatch', 'Smartphone')
limit 600000;


