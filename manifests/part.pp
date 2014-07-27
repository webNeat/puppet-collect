# Resource collect::part
#	Part of a file
# Arguments
#	target: the name of the target file
#	content: the content to add to the file
#	source: path to a file to copy as part of the target file; 
#		if specified, content will be ignored
#	order: the order of the part in the final file. 
#		Parts with the same order may be in any relative other 
# more arguments may be added 

define collect::part($target, $content = '', $source = '', $order = 0) {}