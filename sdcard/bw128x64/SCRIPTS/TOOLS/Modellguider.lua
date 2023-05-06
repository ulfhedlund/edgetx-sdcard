local toolName = "TNS|Ladda modellguide|TNE"

local function init() 
end

local function run(event)    
    chdir("/SCRIPTS/WIZARD/se")
    return "/SCRIPTS/WIZARD/se/ladda_guide.lua"
end

return {init = init, run = run}
