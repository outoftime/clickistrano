require 'fileutils'

class ConfigPuller
  ConfigRequestError = Class.new(StandardError)

  def initialize(config)
    @config = config
  end

  def pull(files, branch)
    http = Net::HTTP.new('github.com', 443)
    http.use_ssl = true
    files.each do |path|
      request_path = "/#{account}/#{repository}/raw/#{branch}/#{path}?login=#{account}&token=#{token}"
      puts request_path
      response = http.get(request_path)
      if response.code == '200'
        file_path = "caproot/#{path}"
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'w') { |f| f << response.body }
      else
        raise ConfigRequestError, "Got response code #{response.code} when requesting #{request_path}"
      end
    end
  end

  private

  def repository
    @config['repository']
  end

  def account
    @config['account']
  end

  def token
    @config['token']
  end
end
