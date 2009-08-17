require 'escape'
require 'fileutils'
require 'open3'

class DeployRunner
  InProgressError = Class.new(StandardError)

  def initialize(config)
    @config = config
  end

  def run
    environment = @config['environment']
    raise InProgressError if status == 'INPROGRESS'
    set_status('INPROGRESS')
    log_path = File.join(APP_ROOT, 'state', 'deploy.out')
    begin
      FileUtils.cd(File.join(APP_ROOT, 'caproot')) do
        FileUtils.rm(log_path) if File.exist?(log_path)
        Open3.popen3(Escape.shell_command(['cap', environment, 'deploy'])) do |stdin, stdout, stderr|
          until stderr.eof?
            data = stderr.readline
            File.open(log_path, 'a') do |file|
              file << data
            end
          end
        end
      end
      if $? == 0
        set_status('DONE')
      else
        set_status('FAILED')
      end
    rescue => e
      set_status('ERROR')
      File.open(log_path, 'a') do |file|
        file.puts("#{e.class.name}: #{e.message}")
        file.puts(e.backtrace)
      end
    end
  end

  private

  def set_status(status)
    File.open(File.join(APP_ROOT, 'state', 'status'), 'w') { |file| file << status }
  end

  def status
    path = File.join(APP_ROOT, 'state', 'status')
    if File.exist?(path)
      IO.read(path)
    end
  end
end
