local HOME_DIR = '/.ygg_store'
local NODE_DIR = fs.combine(HOME_DIR, '.nodes')
local NEXT_ID = 1

if not fs.exists(NODE_DIR) then
	fs.makeDir(NODE_DIR)
end

ERRORS = {
	NOT_EXISTS = 1,
	ALREADY_EXISTS = 2
}

local Node = {
	backing_storage = nil,
	key_table = nil,
}

local function get_node(node_id)
	local node = Node:new(fs.combine(NODE_DIR, node_id))
	node:load()
	return node
end


local function get_property(table, key)
	if not table.key_table then
		table:load()
	end
	if table.key_table[key] then
		if table.key_table[key].type == 'link' then
			return get_node(table.key_table[key].value)
		else
			return table.key_table[key].value
		end
	else
		return ERRORS.NOT_EXISTS
	end
end

local function set_property(tab, key, value)
	if value == new_node() then
		local files = fs.list(NODE_DIR)
		local node_id = tostring(#files + 1)
		local node = Node:new(fs.combine(NODE_DIR, node_id))
		rawget(tab, 'key_table')[key] = {
			type = 'link',
			value = node_id}
		node:save()

	else
		rawget(tab, 'key_table')[key] = {
			type = type(value),
			value = value}
	end
	tab.save(tab)
end

function Node:new(filename)
	o = {
		key_table = {},
		backing_storage = filename
	}

	for k, v in pairs(self) do
		if type(v) == 'function' then
			o[k] = v
		end
	end

	o.__index = get_property
	setmetatable(o, self)
	self.__index = get_property
	self.__newindex = set_property

	
	return o
end

function Node:save()
	assert(self.key_table ~= nil)
	local file = io.open(self.backing_storage, 'w')
	file:write(textutils.serialize(self.key_table))
	file:close()
end

function Node:load()
	assert(fs.exists(self.backing_storage))
	local file = fs.open(self.backing_storage, 'r')

	rawset(
		self,
		'key_table',
		textutils.unserialize(file:readAll()))
	file:close()
end

function namespace_open(name)
	assert(type(name) == 'string')
	local namespace_index = fs.combine(HOME_DIR, name)
	if fs.exists(namespace_index) then
		local node = Node:new(namespace_index)
		node:load()
		return node
	else
		return ERRORS.NOT_EXISTS
	end
end

function namespace_create(name)
	assert(type(name) == 'string')
	local namespace_index = fs.combine(HOME_DIR, name)
	if fs.exists(namespace_index) then
		return ALREADY_EXISTS
	else
		file = io.open(namespace_index, 'w')
		file:write(textutils.serialize({}))
		file:close()
	end
end

function namespace_exists(name)
	return (namespace_open(name) ~= ERRORS.NOT_EXISTS)
end

function new_node()
	return nil
end
