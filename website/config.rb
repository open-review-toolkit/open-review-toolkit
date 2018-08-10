###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

config[:layout] = 'book'
config[:human_translations] = [:en]
config[:editions] = ['open-review']
config[:ga_code] = 'UA-XXXXXXXX-X'
config[:google_form_action] = 'https://docs.google.com/forms/d/e/XXXXXXXXXXXXXX/formResponse'
config[:google_form_email_field] = 'entry.XXXXXXXX'

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration
activate :directory_indexes
activate :i18n, :mount_at_root => false, :langs => [:en]

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  activate :minify_css
  activate :asset_hash, ignore: ["figures/*", "fonts/bootstrap/*"]

  # Minify Javascript on build
  # activate :minify_javascript
end
