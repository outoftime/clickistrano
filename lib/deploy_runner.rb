require 'escape'
require 'fileutils'
require 'open4'

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
        status = Open4.popen4(Escape.shell_command([@config['cap'], environment, 'deploy'])) do |pid, stdin, stdout, stderr|
          until stderr.eof?
            data = stderr.readline
            File.open(log_path, 'a') do |file|
              file << data
            end
          end
        end
        if status == 0
          set_status('DONE')
        else
          File.open(log_path, 'a') do |file|
            file.puts("#{@config['cap']} exited with status #{status}")
          end
          set_status('FAILED')
        end
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
