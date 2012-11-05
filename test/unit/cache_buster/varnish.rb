# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require 'active_support/test_case'
require 'minitest/autorun'

require 'whitehall/cache_buster/varnish'

module Whitehall::CacheBuster
  class VarnishTest < ActiveSupport::TestCase
    test 'purging sends PURGE to cache servers found in /etc/hosts' do
      hosts_file = [
        'another-server   1.2.3.4',
        'cache-server-1     5.6.7.8',
        'something-else     9.0.1.2 4.4.4.4',
        'server-cache-2 3.4.5.6'
      ].join("\n")

      File.stubs(:read).with('/etc/hosts').returns(hosts_file)

      urls = ['http://test.host/url/to/bust', 'http://test.host/another/url']

      varnish = Varnish.new
      varnish.expects(:run).with('curl -X PURGE http://5.6.7.8:7999/url/to/bust')
      varnish.expects(:run).with('curl -X PURGE http://3.4.5.6:7999/url/to/bust')
      varnish.expects(:run).with('curl -X PURGE http://5.6.7.8:7999/another/url')
      varnish.expects(:run).with('curl -X PURGE http://3.4.5.6:7999/another/url')

      varnish.purge(urls)
    end
  end
end
