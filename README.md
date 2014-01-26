Whiteboard
==========

Whiteboard is an online drawing application that allows users to draw in real time with other collaboraters

Note to developers
==================
Compile the .ls files with "lsc -cb file.ls"; without the 'b' option, lsc will paste in code that will ruin your day


To get this versoin working you need npm. 
 - npm install -g grunt-cli bower
 - npm install && bower install
 
 
Sym-link your bower components. Or read up on grunt and submit a pull request.
 - ln -s ../../bower_components components
 
 
Run that bad boy.
 - grunt
 

Now go to your browser.
You can find your port in the terminal after grunt has finished.
 - localhost:{port-number}
