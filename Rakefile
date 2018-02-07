require 'English'
require 'reek'
require 'rubocop/rake_task'
require 'yamllint/rake_task'
require 'tmpdir'
require 'open-uri'
require 'zip'
require 'fileutils'
require 'open3'

def run_git(arguments, popen_options = {})
  _stdin, stdout, stderr, wait_thread = Open3.popen3("git #{arguments}", popen_options)

  exit_status = wait_thread.value

  abort("Failed to run git: #{stderr.read}") unless exit_status.success?

  stdout
end

def run_vagrant(arguments)
  # FIXME: vagrant or a plugin could prompt the user for input. Need to handle it
  _stdin, stdout, _stderr, wait_thread = Open3.popen3("vagrant --machine-readable #{arguments}")

  exit_status = wait_thread.value

  abort("Error running Vagrant command: #{stdout.read}") unless exit_status.success?

  stdout
end

def vm_status(vm_name)
  output = run_vagrant("status #{vm_name}")

  output.readlines.each do |line|
    _timestamp, _target, type, data = line.strip.split(',')
    return data if type == 'state'
  end

  abort("Error detecting VM '#{vm_name}' status: #{stdout.read}")
end

def vm_running?(vm_name)
  status = vm_status(vm_name)
  status == 'running'
end

def vm_up(vm_name)
  status = vm_status(vm_name)

  command = { 'poweroff' => 'up', 'saved' => 'resume' }

  puts "Starting VM '#{vm_name}' ..."
  run_vagrant("#{command[status]} #{vm_name}")
end

def vm_command(vm_name, command)
  run_vagrant("ssh #{vm_name} --command \"sudo #{command}\"")
end

YamlLint::RakeTask.new do |t|
  t.paths = %w[
    environment.yaml
    local.dist.yaml
    .rubocop.yml
    .travis.yml
  ]
end

desc 'Setup control repo'
task setup_control_repo: %i[clone_control_repo create_control_repo_environments]

desc 'Clone control repo'
task :clone_control_repo do
  abort('The environment variable CONTROL_REPO_URL must exist') unless ENV.key?('CONTROL_REPO_URL')

  control_repo = ENV['CONTROL_REPO_URL']

  puts "Cloning control repo '#{control_repo}' ..."
  run_git("clone #{control_repo} control-repo")

  run_git('fetch --all', chdir: 'control-repo')

  output = run_git('branch --no-color --list', chdir: 'control-repo')
  default_branch = output.read.strip.gsub('* ', '')

  branches = run_git('branch --no-color --list -r', chdir: 'control-repo')

  branches.readlines.each do |branch|
    branch_match = branch.strip.match(/^origin\/(?<name>[\w-]+)$/)

    next if !branch_match && (branch_match[:name] == default_branch)

    run_git("branch #{branch_match[:name]} origin/#{branch_match[:name]}", chdir: 'control-repo')
  end
end

desc 'Create Control Repo Environments'
task :create_control_repo_environments do
  vm_up('puppet') unless vm_running?('puppet')

  output = run_git('branch --no-color --list', chdir: 'control-repo')

  output.readlines.each do |line|
    branch_name_match = line.strip.match(/^(\* )?(?<branch>[\w-]+)$/)
    if branch_name_match
      environment = branch_name_match[:branch]
      puts "Creating symbolic link for environment '#{environment}' ..."
      vm_command('puppet', "ln -s /vagrant/control-repo /etc/puppetlabs/code/environments/#{environment}")
    else
      abort("Failed to detect control-repo branches: '#{line}' is not a valid branch name")
    end
  end
end

desc 'Deploy environment'
task :deploy_environment do
  # TODO: implement r10k call
end

desc 'Setup Puppet Development Kit'
task :pdk do
  # detect OS
  # download and install
end

desc 'Reek code smells'
task :reek do
  reporter = Reek::Report::TextReport.new
  vagrantfile_examiner = Reek::Examiner.new File.open('Vagrantfile')
  rakefile_examiner = Reek::Examiner.new File.open('Rakefile')
  reporter.add_examiner vagrantfile_examiner
  reporter.add_examiner rakefile_examiner
  if reporter.smells?
    reporter.show
    raise 'Smell violations found using Reek'
  end
end

RuboCop::RakeTask.new

desc 'Validate shell scripts'
task :shellcheck do
  system('shellcheck -s bash puppet-agent-installer.sh bash/bashrc.puppet')
  raise 'Violations found using ShellCheck' unless $CHILD_STATUS.success?
end

desc 'Validate powershell script installer'
task :powershellcheck do
  system("pwsh -Command 'Invoke-Pester -EnableExit -Script ./puppet-agent-installer.tests.ps1'")
  raise 'Violations found using Pester and PSAnalyzer' unless $CHILD_STATUS.success?
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
