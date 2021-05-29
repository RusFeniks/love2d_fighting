--- Parser for JSON syntax. Inherited from @{l2df.class.parser|l2df.class.parser.BaseParser} class.
-- @classmod l2df.class.parser.json
-- @author Abelidze
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'JsonParser works only with l2df v1.0 and higher')

local json = core.import 'external.json'
local BaseParser = core.import 'class.parser'

local JsonParser = BaseParser:extend()

	--- Method for parsing json formatted string.
	-- @param string str  String for parsing.
	-- @return table
	function JsonParser:parse(str)
		assert(type(str) == 'string', 'Parameter "str" must be a string.')
		return json:decode(str)
	end

	--- Method for dumping table to json format.
	-- @param table data  Table for dumping.
	-- @param[opt=false] boolean noprettify  Disable JSON's prettify if true.
	-- @return string
	function JsonParser:dump(data, noprettify)
		assert(type(data) == 'table', 'Parameter "data" must be a table.')
		return not noprettify and json:encode_pretty(data) or json:encode(data)
	end

return JsonParser