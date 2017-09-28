pip_installer_path = '/tmp/get-pip.py'
remote_file "download_pip_installer" do
    path pip_installer_path
    source 'https://bootstrap.pypa.io/get-pip.py'
    owner 'root'
    group 'root'
    mode '0500'
    not_if 'which pip'
end
execute 'bootstrap_pip' do
    command "python #{pip_installer_path}"
    not_if "which pip"
end
cookbook_file 'delete_pip_installer' do
    path pip_installer_path
    action :delete
end

pip_packages = {
    'pip' => { 'version' => '8.1.2', 'extras' => nil },
    'ndg-httpsclient' => { 'version' => '0.4.3', 'extras' => nil },
    'botocore' => { 'version' => '1.7.18', 'extras' => nil },
    'pystache' => { 'version' => '0.5.4', 'extras' => nil }
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
        command "pip  --disable-pip-version-check install -U #{package_spec}"
        not_if "test #{package_version} = `pip --disable-pip-version-check list 2>/dev/null | sed -rn 's/^#{package_name} \\(([0-9.]+)\\)/\\1/p'`"
    end
end
