-- cover-page.lua
-- Generates a cover page from YAML metadata for DOCX output.
--
-- Cover page layout:
--   [top of page]
--   School name
--   [space]
--   Title (bold, centered) — near vertical center
--   [space]
--   Author / Course / Professor / Date — near bottom
--   [page break] → Content → [page break] → Bibliography
--
-- Spacing values are in twips (1 inch = 1440 twips).
-- Page body: 12960 twips (9" at 1440 twips/inch, with 1" top/bottom margins).
-- Adjust space_before values to taste for your school's cover page layout.

local function cpara(text, bold, space_before)
  local rpr = bold and '<w:rPr><w:b/></w:rPr>' or ''
  local run = string.format(
    '<w:r>%s<w:t xml:space="preserve">%s</w:t></w:r>',
    rpr, text
  )
  local spacing = space_before
    and string.format('<w:spacing w:before="%d" w:after="0"/>', space_before)
    or '<w:spacing w:after="0"/>'
  return string.format(
    '<w:p><w:pPr><w:pStyle w:val="Normal"/><w:jc w:val="center"/><w:ind w:firstLine="0"/>%s</w:pPr>%s</w:p>',
    spacing, run
  )
end

local function page_break()
  return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
end

function Pandoc(doc)
  if FORMAT ~= "docx" then return doc end

  local meta = doc.meta
  local s    = pandoc.utils.stringify

  local parts = {}

  -- School name — top of page
  if meta.school then
    table.insert(parts, cpara(s(meta.school), false, nil))
  end

  -- Title — bold, centered, pushed toward vertical center of page
  if meta.title then
    table.insert(parts, cpara(s(meta.title), true, 4800))
  end

  -- Author — space before positions the bottom block near the page foot
  if meta.author then
    local a = meta.author
    local author_text = pandoc.utils.type(a) == "List" and s(a[1]) or s(a)
    table.insert(parts, cpara(author_text, false, 4800))
  end

  -- Course, Professor, Date — tight block, no extra spacing
  if meta.course then
    table.insert(parts, cpara(s(meta.course), false, nil))
  end

  if meta.professor then
    table.insert(parts, cpara(s(meta.professor), false, nil))
  end

  if meta.date then
    table.insert(parts, cpara(s(meta.date), false, nil))
  end

  -- Prepend cover page to document
  local cover = pandoc.RawBlock("openxml", table.concat(parts, "\n"))
  local new_blocks = {cover}
  for _, block in ipairs(doc.blocks) do
    table.insert(new_blocks, block)
  end

  -- Strip metadata so pandoc does not render a duplicate title block
  meta.title  = nil
  meta.author = nil
  meta.date   = nil

  return pandoc.Pandoc(new_blocks, meta)
end
