@rvm_username  = node.attribute?(:vagrant) ? 'vagrant' : Chef::Config[:ssh_user]
@rvm_trace     = Chef::Config[:log_level] == 'debug' ? '--trace' : ''

Chef::Log.info "RVM will be installed as user: #{@rvm_username}"

group "rvm" do
  members [ "root" ]
  action :create
end

bash "install RVM" do
  code <<-COMMAND
    su - #{@rvm_username} -m -c 'curl -# -k -L https://get.rvm.io | sudo bash -s stable #{@rvm_trace}'
  COMMAND

  environment 'TERM' => 'dumb'
  not_if      "test -d /usr/local/rvm/ && type rvm"
end

bash "install Ruby #{node.application[:ruby][:version]}" do
  code <<-COMMAND
    su - #{@rvm_username} -m -c 'rvm install #{node.application[:ruby][:version]}'
  COMMAND

  environment 'TERM' => 'dumb'
  not_if      "rvm list | grep #{node.application[:ruby][:version]}"
end