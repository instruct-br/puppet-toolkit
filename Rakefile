# frozen_string_literal: true

require 'English'
require 'reek'
require 'rubocop/rake_task'
require 'yamllint/rake_task'
require 'tmpdir'
require 'open-uri'
require 'zip'
require 'fileutils'

desc 'Validate all code'
task validate: ['validate:ruby', 'validate:installers', 'validate:yaml_files']

namespace :validate do
  desc 'Validate Ruby Code'
  task ruby: ['validate:ruby:rubocop', 'validate:ruby:reek']

  YamlLint::RakeTask.new 'yaml_files' do |t|
    t.paths = %w[
      environment.yaml
      local.dist.yaml
      .rubocop.yml
      .travis.yml
    ]
  end

  namespace :ruby do
    RuboCop::RakeTask.new

    desc 'Reek code smells'
    task :reek do
      puts 'Running Reek do detect code smells ...'
      configuration = Reek::Configuration::AppConfiguration.from_path Pathname.new('.config.reek')
      reporter = Reek::Report::TextReport.new
      vagrantfile_examiner = Reek::Examiner.new(File.open('Vagrantfile').read, configuration: configuration)
      rakefile_examiner = Reek::Examiner.new(File.open('Rakefile').read, configuration: configuration)
      reporter.add_examiner vagrantfile_examiner
      reporter.add_examiner rakefile_examiner
      if reporter.smells?
        reporter.show
        raise 'Smell violations found using Reek'
      end
    end
  end

  desc 'Validate Puppet installers'
  task installers: ['validate:installers:shellscript', 'validate:installers:powershell']

  namespace :installers do
    desc 'Validate Shell Script installer'
    task :shellscript do
      puts 'Running shellcheck ...'
      system('shellcheck -s bash puppet-agent-installer.sh bash/bashrc.puppet')
      raise 'Violations found using ShellCheck' unless $CHILD_STATUS.success?
    end

    desc 'Validate PowerShell installer'
    task :powershell do
      puts 'Running Pester and PSAnalyzer ...'
      system("pwsh -Command 'Invoke-Pester -EnableExit -Script ./puppet-agent-installer.tests.ps1'")
      raise 'Violations found using Pester and PSAnalyzer' unless $CHILD_STATUS.success?
    end
  end
end

namespace :update do
  desc 'Update all external tools'
  task all: ['vim_plugin:pathogen', 'vim_plugin:tabular', 'vim_plugin:syntastic', 'git:puppet_hooks']

  namespace :vim_plugin do
    desc 'Update vim plugin Pathogen'
    task :pathogen do
      puts 'Updating Pathogen...'
      File.open('vim/plugins/autoload/pathogen.vim', 'w') do |f|
        f.write(URI.parse('https://tpo.pe/pathogen.vim').read)
      end
    end

    desc 'Update vim plugin Tabular'
    task :tabular do
      puts 'Updating Tabular...'
      tmpdir = Dir.tmpdir
      tabular_zip_file = "#{tmpdir}/tabular-master.zip"

      puts 'Downloading...'
      File.open(tabular_zip_file, 'w') do |f|
        f.write(URI.parse('https://github.com/godlygeek/tabular/archive/master.zip').read)
      end

      puts 'Extracting...'
      FileUtils.rm_rf("#{tmpdir}/tabular-master")
      Zip::File.open(tabular_zip_file) do |zip_file|
        zip_file.each do |entry|
          entry.extract("#{tmpdir}/#{entry.name}")
        end
      end

      puts 'Copying into project...'
      FileUtils.rm_rf('vim/plugins/bundle/tabular')
      FileUtils.cp_r("#{tmpdir}/tabular-master", 'vim/plugins/bundle/tabular')
    end

    desc 'Update vim plugin Syntastic'
    task :syntastic do
      puts 'Updating Syntastic...'
      tmpdir = Dir.tmpdir
      syntastic_zip_file = "#{tmpdir}/syntastic-master.zip"

      puts 'Downloading...'
      File.open(syntastic_zip_file, 'w') do |f|
        f.write(URI.parse('https://github.com/vim-syntastic/syntastic/archive/master.zip').read)
      end

      puts 'Extracting...'
      FileUtils.rm_rf("#{tmpdir}/syntastic-master")
      Zip::File.open(syntastic_zip_file) do |zip_file|
        zip_file.each do |entry|
          entry.extract("#{tmpdir}/#{entry.name}")
        end
      end

      puts 'Copying into project...'
      FileUtils.rm_rf('vim/plugins/bundle/syntastic')
      FileUtils.cp_r("#{tmpdir}/syntastic-master", 'vim/plugins/bundle/syntastic')
    end
  end

  namespace :git do
    desc 'Update Puppet Git hooks'
    task :puppet_hooks do
      puts 'Updating Puppet Git hooks...'
      tmpdir = Dir.tmpdir
      puppet_git_hooks_zip_file = "#{tmpdir}/puppet-git-hooks-master.zip"

      puts 'Downloading...'
      File.open(puppet_git_hooks_zip_file, 'w') do |f|
        f.write(URI.parse('https://github.com/drwahl/puppet-git-hooks/archive/master.zip').read)
      end

      puts 'Extracting...'
      FileUtils.rm_rf("#{tmpdir}/puppet-git-hooks-master")
      Zip::File.open(puppet_git_hooks_zip_file) do |zip_file|
        zip_file.each do |entry|
          entry.extract("#{tmpdir}/#{entry.name}")
        end
      end

      puts 'Copying into project...'
      FileUtils.rm_rf('git/puppet-git-hooks')
      FileUtils.cp_r("#{tmpdir}/puppet-git-hooks-master", 'git/puppet-git-hooks')
    end
  end
end
