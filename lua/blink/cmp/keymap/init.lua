local utils = require('blink.cmp.lib.utils')
local keymap = {}

function keymap.setup()
  local mappings = vim.deepcopy(require('blink.cmp.config').keymap)

  -- Handle preset
  if mappings.preset and #vim.tbl_values(mappings) == 1 then
    mappings = require('blink.cmp.keymap.presets').get(mappings.preset)
  end
  if mappings.preset then
    -- Remove 'preset' key from opts to prevent it from being treated as a keymap
    mappings.preset = nil
  end

  -- We set on the buffer directly to avoid buffer-local keymaps (such as from autopairs)
  -- from overriding our mappings. We also use InsertEnter to avoid conflicts with keymaps
  -- applied on other autocmds, such as LspAttach used by nvim-lspconfig and most configs
  vim.api.nvim_create_autocmd('InsertEnter', {
    callback = function()
      if utils.is_blocked_buffer() then return end
      require('blink.cmp.keymap.apply').keymap_to_current_buffer(mappings)
    end,
  })

  -- This is not called when the plugin loads since it first checks if the binary is
  -- installed. As a result, when lazy-loaded on InsertEnter, the event may be missed
  if vim.api.nvim_get_mode().mode == 'i' and not utils.is_blocked_buffer() then
    require('blink.cmp.keymap.apply').keymap_to_current_buffer(mappings)
  end
end

return keymap
