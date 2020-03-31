execute "apt-get-update" do
	command "apt-get update"
	ignore_failure true
	action :nothing
end
package "update-notifier-common" do
	notifies :run, resources(:execute => "apt-get-update"), :immediately
end
execute "apt-get-update-periodic" do
	command "apt-get update"
	ignore_failure true
	only_if do
		::File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
		::File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
	end
end
package 'python-pip' do
	not_if 'which pip'
end
pip_version = '8.1.2'
execute "pip==#{pip_version}" do
	command "pip install -U pip==#{pip_version}"
	not_if "test #{pip_version} = `pip list 2>/dev/null | sed -rn 's/^pip \\(([0-9.]+)\\)/\\1/p'`"
end

pip_packages = {
	'ndg-httpsclient' => { 'version' => '0.4.3' => nil },
	'virtualenv' => { 'version' => '15.0.3', 'extras' => nil },
}
pip_packages.each do |package_name, package_info|
	package_version = package_info['version']
	package_extras = package_info['extras']
	package_spec = package_name
	unless package_extras.nil? or package_extras.length < 1
		package_spec = package_spec + '['
		package_extras.each do |package_extra|
			package_spec = package_spec + package_extra + ','
		end
		package_spec[-1] = ']' 
	end
	package_spec = package_spec + '==' + package_version
	execute package_spec do
		command "pip --disable-pip-version-check install -U #{package_spec}"
		not_if "test #{package_version} = `pip --disable-pip-version-check list | sed -rn 's/^#{package_name} \\(([0-9.]+)\\)/\\1/p'`"
	end
end
