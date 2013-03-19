***  How to install the WYSWYG Editor TinyMCE to XIMS  ***

1. Download your preferred Version of TinyMCE from http://www.tinymce.com/ (we recommend 3.5_jquery at the moment)
2. There are two options to copy TinyMCE to your local XIMS installation:
	a. Unzip and copy TinyMCE's jscripts-folder to this folder (xims/www/ximsroot/editors/tinymce/)
	b. 	Unzip and copy TinyMCE to xims/www/ximsroot/editors/
		Delete this folder (xims/www/ximsroot/editors/tinymce/) and create a symlink named "tinymce" which points 
		to the "tinymce"-folder of your TinyMCE-Version
		e.g. xims/www/ximsroot/editors/tinymce -> xims/www/ximsroot/editors/tinymce_3.5_jquery/tinymce/
3. Add your preferred plugins, themes, settings in the TinyMCE-init file xims/www/ximsroot/scripts/tinymce_script.js