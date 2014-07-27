# Resource collect::file
# Arguments
#	$path: the path of the file
# more arguments will be added later

define collect::file ($path = $name) {
	file { $name :
		ensure => present,
		path => $path,
		content => template('collect/collector.erb')
	}
}