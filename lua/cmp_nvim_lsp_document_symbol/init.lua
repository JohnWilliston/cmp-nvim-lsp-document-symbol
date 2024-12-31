local source = {}

local SymbolKind = {
  [1] = 'File',
  [2] = 'Module',
  [3] = 'Namespace',
  [4] = 'Package',
  [5] = 'Class',
  [6] = 'Method',
  [7] = 'Property',
  [8] = 'Field',
  [9] = 'Constructor',
  [10] = 'Enum',
  [11] = 'Interface',
  [12] = 'Function',
  [13] = 'Variable',
  [14] = 'Constant',
  [15] = 'String',
  [16] = 'Number',
  [17] = 'Boolean',
  [18] = 'Array',
  [19] = 'Object',
  [20] = 'Key',
  [21] = 'Null',
  [22] = 'EnumMember',
  [23] = 'Struct',
  [24] = 'Event',
  [25] = 'Operator',
  [26] = 'TypeParameter',
}

local NewSymbolNames = {
   [1] =    "Text",
   [2] =    "Method",
   [3] =    "Function",
   [4] =    "Constructor",
   [5] =    "Field",
   [6] =    "Variable",
   [7] =    "Class",
   [8] =    "Interface",
   [9] =    "Module",
   [10] =   "Property",
   [11] =   "Unit",
   [12] =   "Value",
   [13] =   "Enum",
   [14] =   "Keyword",
   [15] =   "Snippet",
   [16] =   "Color",
   [17] =   "File",
   [18] =   "Reference",
   [19] =   "Folder",
   [20] =   "EnumMember",
   [21] =   "Constant",
   [22] =   "Struct",
   [23] =   "Event",
   [24] =   "Operator",
   [25] =   "TypeParameter",
   [26] =   "(Unknown)",
}

-- I don't know why this is needed, but for some reason the search results
-- come back with the wrong icons for what they are. The original table above,
-- named `SymbolKind` seems to be what the plugin is getting, and correctly at
-- that. But then the number that comes in (e.g., 5 for classes) then gets
-- incorrectly described in the resulting popup as a field. So I added the new
-- symbol names, which I copied from another working plugin, and established
-- a mapping table as best I could to take the input number and map it to are
-- proper output number.
local kindMapping = {
    [1] = 11,   -- File to Unit
    [2] = 9,
    [3] = 0,    -- I don't know what to do with Namespace
    [4] = 0,    -- Package to Module
    [5] = 7,
    [6] = 2,
    [7] = 10,
    [8] = 5,
    [9] = 4,
    [10] = 13,
    [11] = 8,
    [12] = 3,
    [13] = 6,
    [14] = 21,
    [15] = 1,   -- String to Text
    [16] = 12,  -- Number to Value
    [17] = 6,   -- I don't know what to do with Boolean, I guess Variable
    [18] = 6,   -- I guess Array is also Variable
    [19] = 6,   -- I guess Object is also Variable
    [20] = 14,  -- Key to Keyword
    [21] = 21,  -- Null to Constant
    [22] = 20,
    [23] = 23,
    [24] = 24,
    [25] = 24,
    [26] = 25,
}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.is_available = function(self)
  return self:_get_client() ~= nil
end

source.get_keyword_pattern = function()
  return [=[@.*]=]
end

source.get_trigger_characters = function()
  return { '@' }
end

source.complete = function(self, _, callback)
  local client = self:_get_client()
  client.request('textDocument/documentSymbol', { textDocument = vim.lsp.util.make_text_document_params() }, function(err, res)
    if err then
      return callback()
    end

    local items = {}
    local traverse
    traverse = function(nodes, level)
      level = level or 0
      for _, node in ipairs(nodes) do
        local kind_name = SymbolKind[node.kind]
        local mappedKind = kindMapping[node.kind]
        if vim.tbl_contains({ 'Module', 'Namespace', 'Object', 'Class', 'Interface', 'Method', 'Function' }, kind_name) then
          -- node may be LSP DocumentSymbol or SymbolInformation (deprecated)
          local range = node.selectionRange or node.range or (node.location or {}).range
          if range ~= nil then
            local line = vim.api.nvim_buf_get_lines(0, range.start.line, range.start.line + 1, false)[1] or ''
            table.insert(items, {
              label = ('%s%s'):format(string.rep(' ', level), string.gsub(line, '^%s*', '')),
              insertText = ('\\%%%sl'):format(range.start.line + 1),
              filterText = '@' .. node.name,
              sortText = '' .. range.start.line,
              --kind = node.kind,
              kind = mappedKind,
              data = node,
            })
            traverse(node.children or {}, level + 1)
          end
        end
      end
    end
    traverse(res or {})
    callback(items)
  end)
end

source._get_client = function(self)
  for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if self:_get(client.server_capabilities, { 'documentSymbolProvider' }) then
      return client
    end
  end
  return nil
end

source._get = function(_, root, paths)
  local c = root
  for _, path in ipairs(paths) do
    c = c[path]
    if not c then
      return nil
    end
  end
  return c
end

return source
