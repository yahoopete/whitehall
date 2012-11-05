require 'whitehall/cache_buster'

require 'uri'

class Whitehall::CacheBuster::Varnish
  def purge(urls)
    cache_hosts = File.read('/etc/hosts').lines.map do |line|
      host, *ips = line.split
      ips if host =~ /cache-/
    end.flatten.compact

    paths = urls.map { |url| URI::parse(url).path }
    paths.each do |path|
      cache_hosts.each do |host|
        run("curl -X PURGE http://#{host}:7999#{path}")
      end
    end
  end

  def run(command)
    system command
  end
end
