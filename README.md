# Overview

The purpose of this fork is to provide a workaround for an issue I observed while using the original plugin. I don't know why, but as I explained in the issue I posted to its repo (see [I seem to be getting descriptions that don't make sense](https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol/issues/14) for details) the glyphs for the various types of things included were off. It was showing classes as fields, methods as variables, functions as values, etc. I'm not exactly a Neovim or Lua expert (quite new at both, in fact), but I took it as an opportunity to whip up a little workaround in my own repo. Feel free to use this repo if you're seeing the same issue and/or add your feedback to that issue posted in the original repo. I don't know whether the problem is real or not (or just something I've screwed up) or whether the author accepts contributions at this point.

The original readme follows below for reference. Please see [the original repository](https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol) for more details.

# cmp-nvim-lsp-document-symbol

nvim-cmp source for textDocument/documentSymbol via nvim-lsp.

The purpose is the demonstration customize `/` search by nvim-cmp.

<video src="https://user-images.githubusercontent.com/629908/139110682-b88e5e1f-f46f-4663-b92e-28b0007f9e52.mp4" width="100%"></video>

# Setup

```lua
require'cmp'.setup.cmdline('/', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  })
})
```

