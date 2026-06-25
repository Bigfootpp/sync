local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestConfig = require(ReplicatedStorage.Tests:FindFirstChild("test.config") or ReplicatedStorage.Tests:FindFirstChild("default.config"))

local function flattenArray(nestedTable: {any}): {any}
    local flatTable: {any} = {}

    local function recurse(item: any)
        if type(item) == "table" then
            for _, value in ipairs(item) do
                recurse(value)
            end
        else
            table.insert(flatTable, item)
        end
    end

    recurse(nestedTable)
    return flatTable
end

local testScripts = flattenArray(TestConfig.Run)
local skipTable = flattenArray(TestConfig.Skip)

local notModuleTrace = {}
local notTestTrace = {}
local skippedTrace = {}

for _, testScript: Instance in testScripts do
    if not testScript:IsA("ModuleScript") then
        table.insert(notModuleTrace, `[{testScript.Name}] Not a module script`)
        continue
    end
    if not testScript.Name:find(".spec") then
        table.insert(notTestTrace, `[{testScript.Name}] Not a test script`)
        continue
    end
    if table.find(skipTable, testScript) then
        table.insert(skippedTrace, `[{testScript.Name}] Skipped`)
        continue
    end
    local success, message = xpcall(function(): boolean | string
        local testFunction = require(testScript)
        return testFunction()
    end, function(errMessage)
        return tostring(errMessage) .. "\n" .. debug.traceback(nil, 2)
    end)

    if success then
        if message == true then
            print(`[{testScript.Name}] Passed`)
        else
            warn(`[{testScript.Name}] Failed, exit message: {message}`)
        end
    else
        warn(`[{testScript.Name}] Crashed`)
        warn(message)
    end
end

for _, trace in skippedTrace do print(trace) end
for _, trace in notTestTrace do print(trace) end
for _, trace in notModuleTrace do print(trace) end