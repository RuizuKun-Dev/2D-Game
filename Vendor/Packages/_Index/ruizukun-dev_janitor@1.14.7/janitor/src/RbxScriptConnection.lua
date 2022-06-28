local RbxScriptConnection = {}

RbxScriptConnection.Connected = true
RbxScriptConnection.__index = RbxScriptConnection

function RbxScriptConnection:Disconnect()
	if self.Connected then
		self.Connected = false

		self.Connection:Disconnect()
	end
end
function RbxScriptConnection._new(RBXScriptConnection)
	return setmetatable({ Connection = RBXScriptConnection }, RbxScriptConnection)
end
function RbxScriptConnection:__tostring()
	return "RbxScriptConnection<" .. tostring(self.Connected) .. ">"
end

return RbxScriptConnection
