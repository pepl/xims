***  How to install the Codemirror Editor to XIMS  ***

1. Download your preferred Version of Codemirror-UI from (we recommend version 0.0.14 from https://github.com/jagthedrummer/codemirror-ui at the moment)
2. There are two options to copy Codemirror-UI to your local XIMS installation:
	a. Unzip and copy the contents of the codemirror-ui-folder to this folder (xims/www/ximsroot/editors/codemirror-ui/)
	b. 	Unzip and copy Codemirror-UI to xims/www/ximsroot/editors/
		Delete this folder (xims/www/ximsroot/editors/codemirror-ui/) and create a symlink named "codemirror-ui" which points 
		to the "codemirror-ui"-folder of your CodeMirror-UI-Version
		e.g. xims/www/ximsroot/editors/codemirror-ui -> xims/www/ximsroot/editors/codemirror-ui-0.0.14/