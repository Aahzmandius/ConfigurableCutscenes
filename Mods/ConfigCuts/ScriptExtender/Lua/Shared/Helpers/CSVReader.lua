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

---@class CSVFile
---@field Headers string[] # top row of CSV file, column headers (required)
---@field Rows table<string, string>[] # top to bottom array of each row, with key-value pairs for each column

---Parses from a CSV file and returns a table of headers and rows, column headers, and line count
---@param filePath string # eg. - "Mods/ConfigCuts/ScriptExtender/Lua/Shared/Data/testData.csv"
---@return CSVFile?
---@return integer? # line count, including header row
function Helpers.CSV.ParseFromFile(filePath)
    filePath = filePath or "Mods/ConfigCuts/ScriptExtender/Lua/Shared/Data/testData.csv"
    local success, data = pcall(Ext.IO.LoadFile, filePath, "data")
    if success and data ~= nil then
        local parsed = {
            Headers = {},
            Rows = {}
        }
        local columnCount = 0
        local columns = {}

        -- Parse an individual row (with variable number of columns depending on file)
        local function rowParse(...)
            local newRowEntry = {}
            for i=1,columnCount do
                newRowEntry[columns[i]] = select(i, ...)
            end
            table.insert(parsed.Rows, newRowEntry)
        end

        -- create column matcher based on header for number of columns, to parse following rows
        local matcher
        local lineCount
        for line in string.gmatch(data, "(.-)\n") do
            if not lineCount then
                -- first row is header, initialize line count, and create matcher based on headers
                lineCount = 1
                for column in string.gmatch(line, "(.-),") do
                    if not matcher then
                        matcher = "%s*(.-)" -- init first
                    else
                        matcher = matcher..",%s*(.-)"
                    end
                    columnCount = columnCount + 1
                    table.insert(columns, column)
                end
                -- finish matcher and assign columns to parsed
                matcher = matcher.."%s*$"
                parsed.Headers = columns
            else
                -- Parse all non-header lines
                lineCount = lineCount + 1
                rowParse(string.match(line, matcher))
            end
        end
        -- RPrint(parsed)
        return parsed,lineCount
    else
        SDebug("Failed to load file: " .. filePath)
    end
end