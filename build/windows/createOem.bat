node -v
cmd /C npm -v
git --version
cmd /C grunt --version
echo Required are "git for windows", node.js with npm and grunt-cli installed globally: "npm install grunt -g"
echo write: "createOem.bat myproject clean" if you want to delete all grunt packets
IF "%1"=="" goto NOPARAM

echo install grunt globally
echo cmd /C npm install grunt-cli -g

if not exist "node_modules" mkdir node_modules

cd node_modules
SET NAME=%1
if not exist "%NAME%.js-controller" git clone https://github.com/ioBroker/ioBroker.js-controller.git 	"%NAME%.js-controller"
if not exist "%NAME%.admin"    		git clone https://github.com/ioBroker/ioBroker.admin.git  			"%NAME%.admin"
if not exist "%NAME%.web" 			git clone https://github.com/ioBroker/ioBroker.web.git 				"%NAME%.web"
if not exist "%NAME%.socketio" 		git clone https://github.com/ioBroker/ioBroker.socketio.git 		"%NAME%.socketio"
if not exist "%NAME%.javascript" 	git clone https://github.com/ioBroker/ioBroker.javascript.git 		"%NAME%.javascript"
if not exist "%NAME%.simple-api" 	git clone https://github.com/ioBroker/ioBroker.simple-api.git 		"%NAME%.simple-api"
if not exist "%NAME%.vis"  			git clone https://github.com/ioBroker/ioBroker.vis.git 				"%NAME%.vis"

echo remove ".git" directories
if exist "%NAME%.js-controller\.git" 	rmdir /S /Q "%NAME%.js-controller\.git"
if exist "%NAME%.admin\.git" 			rmdir /S /Q "%NAME%.admin\.git"
if exist "%NAME%.web\.git" 				rmdir /S /Q "%NAME%.web\.git"
if exist "%NAME%.socketio\.git" 		rmdir /S /Q "%NAME%.socketio\.git"
if exist "%NAME%.javascript\.git" 		rmdir /S /Q "%NAME%.javascript\.git"
if exist "%NAME%.simple-api\.git" 		rmdir /S /Q "%NAME%.simple-api\.git"
if exist "%NAME%.vis\.git" 				rmdir /S /Q "%NAME%.vis\.git"


cd %NAME%.js-controller
if not exist "node_modules\grunt" 					cmd /C npm install grunt@0.4.5
if not exist "node_modules\grunt-replace" 			cmd /C npm install grunt-replace@0.9.3
if not exist "node_modules\grunt-contrib-jshint" 	cmd /C npm install grunt-contrib-jshint@0.11.3
if not exist "node_modules\grunt-jscs" 				cmd /C npm install grunt-jscs@2.3.0
if not exist "node_modules\grunt-http" 				cmd /C npm install grunt-http@2.0.1
echo Todo certificates, repository, icon, readme link
cmd /C grunt rename
cd ..\..

cd node_modules\%NAME%.admin
if not exist "node_modules\grunt" 					cmd /C npm install grunt@0.4.5
if not exist "node_modules\grunt-replace" 			cmd /C npm install grunt-replace@0.9.3
if not exist "node_modules\grunt-contrib-jshint" 	cmd /C npm install grunt-contrib-jshint@0.11.3
if not exist "node_modules\grunt-jscs" 				cmd /C npm install grunt-jscs@2.3.0
if not exist "node_modules\grunt-http" 				cmd /C npm install grunt-http@2.0.1
cmd /C grunt rename
echo Todo icon, readme link
cd ..\..

cd node_modules\%NAME%.web
if not exist "node_modules\grunt" 					cmd /C npm install grunt@0.4.5
if not exist "node_modules\grunt-replace" 			cmd /C npm install grunt-replace@0.9.3
if not exist "node_modules\grunt-contrib-jshint" 	cmd /C npm install grunt-contrib-jshint@0.11.3
if not exist "node_modules\grunt-jscs" 				cmd /C npm install grunt-jscs@2.3.0
if not exist "node_modules\grunt-http" 				cmd /C npm install grunt-http@2.0.1
cmd /C grunt rename
echo Todo icon, readme link
cd ..\..

cd node_modules\%NAME%.socketio
if not exist "node_modules\grunt" 					cmd /C npm install grunt@0.4.5
if not exist "node_modules\grunt-replace" 			cmd /C npm install grunt-replace@0.9.3
if not exist "node_modules\grunt-contrib-jshint" 	cmd /C npm install grunt-contrib-jshint@0.11.3
if not exist "node_modules\grunt-jscs" 				cmd /C npm install grunt-jscs@2.3.0
if not exist "node_modules\grunt-http" 				cmd /C npm install grunt-http@2.0.1
cmd /C grunt rename
echo Todo icon, readme link
cd ..\..

cd node_modules\%NAME%.javascript
if not exist "node_modules\grunt" 					cmd /C npm install grunt@0.4.5
if not exist "node_modules\grunt-replace" 			cmd /C npm install grunt-replace@0.9.3
if not exist "node_modules\grunt-contrib-jshint" 	cmd /C npm install grunt-contrib-jshint@0.11.3
if not exist "node_modules\grunt-jscs" 				cmd /C npm install grunt-jscs@2.3.0
if not exist "node_modules\grunt-http" 				cmd /C npm install grunt-http@2.0.1
cmd /C grunt rename
echo Todo icon, readme link
cd ..\..

cd node_modules\%NAME%.simple-api
if not exist "node_modules\grunt" 					cmd /C npm install grunt@0.4.5
if not exist "node_modules\grunt-replace" 			cmd /C npm install grunt-replace@0.9.3
if not exist "node_modules\grunt-contrib-jshint" 	cmd /C npm install grunt-contrib-jshint@0.11.3
if not exist "node_modules\grunt-jscs" 				cmd /C npm install grunt-jscs@2.3.0
if not exist "node_modules\grunt-http" 				cmd /C npm install grunt-http@2.0.1
cmd /C grunt rename
echo Todo icon, readme link, rename script
cd ..\..


cd node_modules\%NAME%.vis
if not exist "node_modules\grunt" 					cmd /C npm install grunt@0.4.5
if not exist "node_modules\grunt-replace" 			cmd /C npm install grunt-replace@0.9.3
if not exist "node_modules\grunt-contrib-jshint" 	cmd /C npm install grunt-contrib-jshint@0.11.3
if not exist "node_modules\grunt-jscs" 				cmd /C npm install grunt-jscs@2.3.0
if not exist "node_modules\grunt-http" 				cmd /C npm install grunt-http@2.0.1
cmd /C grunt rename
echo Todo icon, readme link, about window
cd ..\..

cd node_modules\%NAME%.admin
cmd /C npm install --production
cd ..\..

cd node_modules\%NAME%.socketio
cmd /C npm install --production
cd ..\..

cd node_modules\%NAME%.simple-api
cmd /C npm install --production
cd ..\..

cd node_modules\%NAME%.web
cmd /C npm install --production
cd ..\..

cd node_modules\%NAME%.javascript
cmd /C npm install --production
cd ..\..

cd node_modules\%NAME%.js-controller
cmd /C npm install --production
cd ..\..

cd node_modules\%NAME%.vis
cmd /C npm install --production
cd ..\..

if not exist "%NAME%.cmd" echo node node_modules\%NAME%.js-controller\%NAME%.js

IF "%2"=="clean" goto DELETEGRUNT

goto END

:DELETEGRUNT
if exist "node_modules\%NAME%.js-controller\node_modules\grunt" 				rmdir /S /Q "node_modules\%NAME%.js-controller\node_modules\grunt"
if exist "node_modules\%NAME%.js-controller\node_modules\grunt-replace" 		rmdir /S /Q "node_modules\%NAME%.js-controller\node_modules\grunt-replace"
if exist "node_modules\%NAME%.js-controller\node_modules\grunt-contrib-jshint" 	rmdir /S /Q "node_modules\%NAME%.js-controller\node_modules\grunt-contrib-jshint"
if exist "node_modules\%NAME%.js-controller\node_modules\grunt-jscs" 			rmdir /S /Q "node_modules\%NAME%.js-controller\node_modules\grunt-jscs"
if exist "node_modules\%NAME%.js-controller\node_modules\grunt-http" 			rmdir /S /Q "node_modules\%NAME%.js-controller\node_modules\grunt-http"

if exist "node_modules\%NAME%.admin\node_modules\grunt" 						rmdir /S /Q "node_modules\%NAME%.admin\node_modules\grunt"
if exist "node_modules\%NAME%.admin\node_modules\grunt-replace" 				rmdir /S /Q "node_modules\%NAME%.admin\node_modules\grunt-replace"
if exist "node_modules\%NAME%.admin\node_modules\grunt-contrib-jshint" 			rmdir /S /Q "node_modules\%NAME%.admin\node_modules\grunt-contrib-jshint"
if exist "node_modules\%NAME%.admin\node_modules\grunt-jscs" 					rmdir /S /Q "node_modules\%NAME%.admin\node_modules\grunt-jscs"
if exist "node_modules\%NAME%.admin\node_modules\grunt-http" 					rmdir /S /Q "node_modules\%NAME%.admin\node_modules\grunt-http"

if exist "node_modules\%NAME%.web\node_modules\grunt" 							rmdir /S /Q "node_modules\%NAME%.web\node_modules\grunt"
if exist "node_modules\%NAME%.web\node_modules\grunt-replace" 					rmdir /S /Q "node_modules\%NAME%.web\node_modules\grunt-replace"
if exist "node_modules\%NAME%.web\node_modules\grunt-contrib-jshint" 			rmdir /S /Q "node_modules\%NAME%.web\node_modules\grunt-contrib-jshint"
if exist "node_modules\%NAME%.web\node_modules\grunt-jscs" 						rmdir /S /Q "node_modules\%NAME%.web\node_modules\grunt-jscs"
if exist "node_modules\%NAME%.web\node_modules\grunt-http" 						rmdir /S /Q "node_modules\%NAME%.web\node_modules\grunt-http"

if exist "node_modules\%NAME%.socketio\node_modules\grunt" 						rmdir /S /Q "node_modules\%NAME%.socketio\node_modules\grunt"
if exist "node_modules\%NAME%.socketio\node_modules\grunt-replace" 				rmdir /S /Q "node_modules\%NAME%.socketio\node_modules\grunt-replace"
if exist "node_modules\%NAME%.socketio\node_modules\grunt-contrib-jshint" 		rmdir /S /Q "node_modules\%NAME%.socketio\node_modules\grunt-contrib-jshint"
if exist "node_modules\%NAME%.socketio\node_modules\grunt-jscs" 				rmdir /S /Q "node_modules\%NAME%.socketio\node_modules\grunt-jscs"
if exist "node_modules\%NAME%.socketio\node_modules\grunt-http" 				rmdir /S /Q "node_modules\%NAME%.socketio\node_modules\grunt-http"

if exist "node_modules\%NAME%.javascript\node_modules\grunt" 					rmdir /S /Q "node_modules\%NAME%.javascript\node_modules\grunt"
if exist "node_modules\%NAME%.javascript\node_modules\grunt-replace" 			rmdir /S /Q "node_modules\%NAME%.javascript\node_modules\grunt-replace"
if exist "node_modules\%NAME%.javascript\node_modules\grunt-contrib-jshint" 	rmdir /S /Q "node_modules\%NAME%.javascript\node_modules\grunt-contrib-jshint"
if exist "node_modules\%NAME%.javascript\node_modules\grunt-jscs" 				rmdir /S /Q "node_modules\%NAME%.javascript\node_modules\grunt-jscs"
if exist "node_modules\%NAME%.javascript\node_modules\grunt-http" 				rmdir /S /Q "node_modules\%NAME%.javascript\node_modules\grunt-http"

if exist "node_modules\%NAME%.vis\node_modules\grunt" 							rmdir /S /Q "node_modules\%NAME%.vis\node_modules\grunt"
if exist "node_modules\%NAME%.vis\node_modules\grunt-replace" 					rmdir /S /Q "node_modules\%NAME%.vis\node_modules\grunt-replace"
if exist "node_modules\%NAME%.vis\node_modules\grunt-contrib-jshint" 			rmdir /S /Q "node_modules\%NAME%.vis\node_modules\grunt-contrib-jshint"
if exist "node_modules\%NAME%.vis\node_modules\grunt-jscs" 						rmdir /S /Q "node_modules\%NAME%.vis\node_modules\grunt-jscs"
if exist "node_modules\%NAME%.vis\node_modules\grunt-http" 						rmdir /S /Q "node_modules\%NAME%.vis\node_modules\grunt-http"

if exist "node_modules\%NAME%.simple-api\node_modules\grunt" 					rmdir /S /Q "node_modules\%NAME%.simple-api\node_modules\grunt"
if exist "node_modules\%NAME%.simple-api\node_modules\grunt-replace" 			rmdir /S /Q "node_modules\%NAME%.simple-api\node_modules\grunt-replace"
if exist "node_modules\%NAME%.simple-api\node_modules\grunt-contrib-jshint" 	rmdir /S /Q "node_modules\%NAME%.simple-api\node_modules\grunt-contrib-jshint"
if exist "node_modules\%NAME%.simple-api\node_modules\grunt-jscs" 				rmdir /S /Q "node_modules\%NAME%.simple-api\node_modules\grunt-jscs"
if exist "node_modules\%NAME%.simple-api\node_modules\grunt-http" 				rmdir /S /Q "node_modules\%NAME%.simple-api\node_modules\grunt-http"

goto END

:NOPARAM
echo please give new name like: create myproject

:END

