Helpers = Helpers or {}
Helpers.CSV = {}
Ext.RegisterConsoleCommand("csv", function(cmd, arg)
    local filePath = arg or "Mods/ConfigCuts/ScriptExtender/Lua/Shared/Data/testData.csv"
    if filePath then
        SDebug("Testing CSV output from file: " .. filePath)
        Helpers.CSV.ParseFromFile(filePath)
    else
        SDebug("Testing debug CSV output")
        Helpers.CSV.ParseFromFile(arg)
    end
end)

function Helpers.CSV.ParseFromFile(filePath)
    filePath = filePath or "Mods/ConfigCuts/ScriptExtender/Lua/Shared/Data/testData.csv"
    local success, data = pcall(Ext.IO.LoadFile, filePath, "data")
    if success and data ~= nil then
        local parsed = {}
        local columnCount = 0
        local columns = {}
        -- create column matcher based on header for number of columns, to parse following rows
        local matcher
        -- grab header columns first from whole first line
        for line in string.gmatch(data, "(.-)\n") do
            -- first line, iterate in chunks separated by commas
            for column in string.gmatch(line, "(.-),") do
                if not matcher then
                    matcher = "%s*(.-)" -- init first
                else
                    matcher = matcher..",%s*(.-)"
                end
                columnCount = columnCount + 1
                table.insert(columns, column)
            end
            -- finish matcher and bail
            matcher = matcher.."%s*$"
            break
        end
        parsed.Headers = columns
        parsed.Rows = {}

        -- Parse an individual row (with variable number of columns depending on file)
        local function rowParse(...)
            local newRowEntry = {}
            for i=1,columnCount do
                newRowEntry[columns[i]] = select(i, ...)
            end
            table.insert(parsed.Rows, newRowEntry)
        end

        local lineCount
        for line in string.gmatch(data, "(.-)\n") do
            if not lineCount then
                -- skip header row and initialize line count
                lineCount = 1
            else
                -- Parse all non-header lines
                lineCount = lineCount + 1
                rowParse(string.match(line, matcher))
            end
        end
        RPrint(parsed)
        return parsed,columns,lineCount
    else
        SDebug("Failed to load file: " .. filePath)
    end
end