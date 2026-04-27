-- bibliography-break.lua
-- Inserts a page break before the Bibliography heading so that
-- the bibliography always starts on its own page.

function Header(el)
  if FORMAT ~= "docx" then return el end
  local text = pandoc.utils.stringify(el)
  if text:lower() == "bibliography" then
    local pb = pandoc.RawBlock("openxml",
      '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
    )
    return {pb, el}
  end
end
