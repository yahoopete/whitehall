module DocumentViewAssertions
  def self.included(base)
    base.send(:include, PublicDocumentRoutesHelper)
    base.send(:include, ActionDispatch::Routing::UrlFor)
    base.send(:include, Rails.application.routes.url_helpers)
    Whitehall.stubs(:public_host).returns 'www.test.alphagov.co.uk'
    base.default_url_options[:host] = Whitehall.public_host

  end
end
