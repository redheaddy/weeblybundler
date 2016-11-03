require 'thor'
require 'weeblybundler/bundle'
require "awesome_print"
require "json"
require "filewatcher"

def watch( path )
  puts 'Watching for changes...'
  FileWatcher.new(path, interval: 0.1).watch() do |filename|
    handleApp(path)
  end
end

def handleApp( path)
  client_id = ENV['WEEBLY_CLIENT_ID']
  secret = ENV['WEEBLY_SECRET']
  domain = ENV['WEEBLY_DOMAIN'] || 'https://www.weebly.com'

  bundle = Weeblybundler::Bundle.new('app', path, domain, {'client_id' => client_id, 'secret' => secret, 'domain' => domain})

  if bundle.is_valid?
    response = bundle.sync('/platform/app')
    begin
      ap JSON.parse(response.body)
    rescue
      ap "There was a problem uploading your element to #{domain}/platform/app"
      ap response.body
      bundle.cleanup
    end
  else
    ap bundle.errors
  end
end

module Weeblybundler
  class CLI < Thor

    desc "app PATH", "Bundles and uploads your weebly platform app."
    option :watch, :type => :boolean
    def app( path )
      if options[:watch]
        return watch(path)
      end

      handleApp(path)
    end

    desc "theme PATH", "Bundles and uploads your weebly platform theme."
    option :publish, :type => :boolean
    def theme( path )
      domain = ENV['WEEBLY_DOMAIN'] || 'https://www.weebly.com'
      site_id = ENV['WEEBLY_SITE_ID']
      token = ENV['WEEBLY_TOKEN']
      email = ENV['WEEBLY_EMAIL']

      bundle = Bundle.new('theme', path, domain, {'domain' => domain, 'site_id' => site_id, 'token' => token, 'email' => email})

      if bundle.is_valid?
        response = bundle.sync('/platform/theme', options[:publish])
        begin
          ap JSON.parse(response)
        rescue
          ap "There was a problem uploading your element to #{domain}/platform/theme"
          ap response.body
          bundle.cleanup
        end
      else
        ap bundle.errors
      end
    end
  end
end
