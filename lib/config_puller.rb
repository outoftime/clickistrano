require 'fileutils'

module ConfigPuller
  autoload :Github, File.join(File.dirname(__FILE__), 'config_puller', 'github')
  autoload :Local, File.join(File.dirname(__FILE__), 'config_puller', 'local')

  class <<self
    def [](name)
      const_get(name.split("_").map { |part| part.capitalize }.join)
    end
  end

  class Abstract
    ConfigRequestError = Class.new(StandardError)

    def initialize(config)
      @config = config
    end

    private

    def write_file(path, contents)
      file_path = File.join('caproot', path)
      FileUtils.mkdir_p(File.dirname(file_path))
      File.open(file_path, 'w') { |f| f << contents }
    end
  end
end
