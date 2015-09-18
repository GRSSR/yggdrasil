os.loadAPI('/.sys/yggdrasil/yggdrasil')
os.loadAPI('/.sys/red_string')

local READ = 0
local WRITE = 1
local LIST = 3

local MODE = nil

function usage()
	print('ygg [get|set|create|list] [namespace] {address} {value}')
end

local args = {...}

if args[1] == 'get' then
	MODE = READ
elseif args[1] == 'set' then
	MODE = WRITE
elseif args[1] == 'list' then
	MODE = LIST
else
	usage()
	error()
end

local namespace = args[2]
local address = args[3]
local value = args[4]

if MODE == CREATE then

else
	if not yggdrasil.namespace_exists(namespace) then
		print('namespace '..namespace..' does not exist')
		error()
	end

	local ns = yggdrasil.open_namespace(namespace)

	local address = redString.split(address, 99999999, '%.')

	local current_node = ns
	for k, node_name in pairs(address) do
		current_node = current_node[node_name]
	end

	if MODE == READ then
		print(current_node)
	elseif MODE == WRITE then
		current_node = value
	end
end

