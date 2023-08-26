local version = {}

local function split_on(input_str,separator)
    local parts,start_idx = {},1

    while true do
        local found_idx = input_str:find(separator,start_idx,true)
        local part      = input_str:sub(start_idx,(found_idx or 0) - 1)

        if part ~= "" then parts[#parts+1] = part end

        if not found_idx then break end

        start_idx = found_idx + #separator
    end

    return parts
end

local function compare_with_wildcard(val1,val2)
    if val1 == "x" or val2 == "x" then
        return 0
    else
        return val1 - val2
    end
end

local function compare_versions(version1,version2)
    local major_cmp = compare_with_wildcard(version1.major,version2.major)
    local minor_cmp = compare_with_wildcard(version1.minor,version2.minor)

    if major_cmp ~= 0 then return major_cmp end
    if minor_cmp ~= 0 then return minor_cmp end

    return compare_with_wildcard(version1.patch,version2.patch)
end

function version.is_within_range(version,range)
    local start_version = range.start_version
    local end_version   = range.end_version

    if range.is_range then
        local start_compatible = true
        local end_compatible   = true

        if start_version then
            start_compatible = compare_versions(version, start_version) >= 0
        end

        if end_version then
            end_compatible = compare_versions(version, end_version) <= 0
        end

        return start_compatible and end_compatible
    elseif start_version or end_version then
        local start_compatible = not start_version or compare_versions(version, start_version) >= 0
        local end_compatible   = not end_version   or compare_versions(version, end_version)   <= 0

        return start_compatible and end_compatible
    else
        return true
    end
end

local function parse_single_version(version_part)
    local parts = split_on(version_part, ".")

    local major = ((parts[1] or "x"):lower() == "x" or parts[1] == "*") and "x" or tonumber(parts[1])
    local minor = ((parts[2] or "x"):lower() == "x" or parts[2] == "*") and "x" or tonumber(parts[2])
    local patch = ((parts[3] or "x"):lower() == "x" or parts[3] == "*") and "x" or tonumber(parts[3])

    return {
        major = major,
        minor = minor,
        patch = patch
    }
end

function version.parse_version(version_str)
    local version_parts = split_on(version_str, "-")

    if #version_parts == 1 then
        return parse_single_version(version_parts[1])
    elseif #version_parts == 2 then
        local range = {
            is_range = true,

            start_version = parse_single_version(version_parts[1]),
            end_version   = parse_single_version(version_parts[2])
        }
        
        return range
    end

    return nil
end

return version
