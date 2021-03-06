-- Sample for PropertyPromotionActivity
--
-- This sample creates an indexed view that can be used to query promoted properties for the CounterService Sample.

-- An indexed view requires a unique clustered index. In this case we are creating an index on ([InstanceId], [PromotionName])
-- You can opt to use one of the Value columns as a clustered index; however, this only works if there is only one
-- unique PromotionName in the entire view.
if exists (select * from sys.indexes where object_id = object_id(N'[System.Activities.DurableInstancing].[InstancePromotedProperties]') and name = N'CIX_InstancePromotedProperties')
	drop index [CIX_InstancePromotedProperties] on [System.Activities.DurableInstancing].[InstancePromotedProperties] with ( online = off)

create unique clustered index [CIX_InstancePromotedProperties]
	on [System.Activities.DurableInstancing].[InstancePromotedProperties] ([InstanceId], [PromotionName])

-- Create an index on the [Value1] column.
if exists (select * from sys.indexes where object_id = object_id(N'[System.Activities.DurableInstancing].[InstancePromotedProperties]') and name = N'NCIX_InstancePromotedProperties_CounterService')
	drop index [NCIX_InstancePromotedProperties_CounterService] on [System.Activities.DurableInstancing].[InstancePromotedProperties] with ( online = off)

create nonclustered index [NCIX_InstancePromotedProperties_CounterService]
	on [System.Activities.DurableInstancing].[InstancePromotedProperties] ([Value2])

-- Create a view on just the CounterService Promotion to simplify queries
if exists (select * from sys.views where object_id = object_id(N'[dbo].[CounterService]'))
      drop view [dbo].[CounterService]
go

create view [dbo].[CounterService] as
      select [InstanceId],
			 [Value1] as [CounterValue],
			 [Value2] as [CounterValueLastUpdated]
      from [System.Activities.DurableInstancing].[InstancePromotedProperties]
      where [PromotionName] = 'CounterService'
go

-- This query gives the 10 counters that were most recently updated.
-- Note that the query plan takes advantage of the index
select top(10) * from [dbo].[CounterService]
order by([CounterValueLastUpdated])