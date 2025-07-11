
drop table if exists #temp_json_str
select json_str = '{
  "user": {
    "id": 123,
    "name": "Alice Johnson",
    "contact": {
      "email": "alice@example.com",
      "phone": "+1-555-0123"
    },
    "preferences": {
      "theme": "dark",
      "notifications": true,
      "languages": ["en", "es"]
    }
  },
  "timestamp": "2025-07-11T10:30:00Z"
}'
into #temp_json_str


--Extract Values
select json_value(json_str, '$.user')
	,json_value(json_str, '$.user.contact.email')
	,json_value(json_str, '$.user.preferences.languages') --will be null since its an array
	,'--> JSON_QUERY'
	,json_query(json_str, '$.user.preferences.languages')
	,'--> ISJSON'
	,isjson(json_str)
	,isjson('')
	,isjson('{}')
	,'--> JSON_MODIFY'
	,json_modify(json_str, '$.user.id', 522)
from #temp_json_str

--- OPEN JSON
select *
from #temp_json_str a
cross apply OPENJSON(a.json_str) b


--PIVOT
select *
from (
	select json_str, [key], [value]
	from #temp_json_str a
	cross apply OPENJSON(a.json_str) b
) as js
PIVOT (
	min([value])
	for [key] in ([user], [timestamp])
) as pv


---------------------------------------
--Open all Values in an Array
DECLARE @json NVARCHAR(MAX) = '{
    "fruits": ["apple", "banana", "orange"],
    "vegetables": ["carrot", "broccoli", "spinach"]
}'

SELECT 'fruit' as category, *
FROM OPENJSON(@json, '$.fruits')

-- Extract from multiple arrays
SELECT 'fruit' as category, [value] as item
FROM OPENJSON(@json, '$.fruits')
UNION ALL
SELECT 'vegetable' as category, [value] as item
FROM OPENJSON(@json, '$.vegetables')