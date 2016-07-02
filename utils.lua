-- print an object's contents.  if it's a table, it will print it recursively
function print_r (t, x, y, maxDepth)
    local maxDepth = maxDepth or -1
    local print_r_cache={}
    local function sub_print_r(t,indent, maxDepth)
        if maxDepth == 0 then return end
        if (print_r_cache[tostring(t)]) then
            love.graphics.print(indent.."*"..tostring(t), x, y)
            y = y + 20
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        love.graphics.print(indent.."["..pos.."] => "..tostring(t).." {"..(maxDepth == 1 and "...}" or ""), x, y)
                        if maxDepth > 1 then
                            y = y + 20
                            sub_print_r(val,indent..string.rep(" ",string.len(pos)+8), maxDepth - 1)
                            love.graphics.print(indent..string.rep(" ",string.len(pos)+6).."}", x, y)
                        end
                        y = y + 20
                    elseif (type(val)=="string") then
                        love.graphics.print(indent.."["..pos..'] => "'..val..'"', x, y)
                        y = y + 20
                    else
                        love.graphics.print(indent.."["..pos.."] => "..tostring(val), x, y)
                        y = y + 20
                    end
                end
            else
                love.graphics.print(indent..tostring(t), x, y)
                y = y + 20
            end
        end
    end
    if (type(t)=="table") then
        love.graphics.print(tostring(t).." {", x, y)
        y = y + 20
        sub_print_r(t,"  ", maxDepth - 1)
        love.graphics.print("}", x, y)
        y = y + 20
    else
        sub_print_r(t,"  ", maxDepth - 1)
    end
    love.graphics.print("", x, y)
    y = y + 20
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end