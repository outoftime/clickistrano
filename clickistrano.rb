$: << File.join(File.dirname(__FILE__), 'lib')

require 'rubygems'
require 'sinatra'
require 'haml'
require 'net/http'
require 'net/https'
require 'cgi'
require 'json'

require 'config_puller'
require 'deploy_runner'

APP_ROOT = File.expand_path(File.dirname(__FILE__))

get '/' do
  if File.exist?('state/last_branch')
    @branch = IO.read('state/last_branch')
  end
  haml :index
end

post '/deploy' do
  branch = params[:branch]
  File.open('state/last_branch', 'w') { |f| f << branch }
  config = File.open('config.yml') { |f| YAML.load(f) }
  ConfigPuller[config['adapter'] || 'github'].new(config).pull(%w(config/deploy.rb Capfile), branch)
  pid = fork do
    DeployRunner.new(config).run
    exit
  end
  Process.detach(pid)
  redirect('/progress')
end

get '/progress' do
  haml :progress
end

get '/status' do
  log_path = File.join(APP_ROOT, 'state', 'deploy.out')
  position = 0
  log = if File.exist?(log_path)
    File.open(log_path) do |file|
      if start = params[:start]
        file.seek(start.to_i, IO::SEEK_SET)
      end
      chunk = file.read
      position = file.pos
      CGI.escapeHTML(chunk).gsub("\n", '<br>')
    end
  else
    ''
  end
  status = IO.read(File.join(APP_ROOT, 'state', 'status'))
  content_type('application/json')
  {
    :log => log,
    :status => status,
    :position => position
  }.to_json
end
