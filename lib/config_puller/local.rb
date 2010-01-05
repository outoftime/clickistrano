using_gems = false
begin
  require 'grit'
rescue LoadError => e
  raise(e) if using_gems
  using_gems = true
  retry
end

module ConfigPuller
  class Local < Abstract
    def pull(files, branch)
      repo = Grit::Repo.new(repository)
      commit = repo.get_head(branch).commit
      files.each do |path|
        write_file(path, (repo.tree(commit.id) / path).data)
      end
    end

    private

    def repository
      @config['repository']
    end
  end
end
