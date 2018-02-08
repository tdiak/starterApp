#!/bin/bash

package_exists() {
    return $(dpkg -s $1 | grep installed)
}

PROJECT=$1
CLIENT=$2

GITIGNORE_FILES=(venv html/node_modules html/compiled $PROJECT/db.sqlite3 *.pyc $PROJECT/$PROJECT/localsettings.py)
REQUIREMENTS=(django==1.11 psycopg2)

if [ -z "$PROJECT" ]
    then 
        echo "You need to add project name: sh start.sh <project_name>"
        exit 1
    else
        echo "Your project name: $PROJECT"
fi

if !(package_exists python-virtualenv)
    then
        echo "Dependency python-virtualenv installed"
    else
        apt-get install python-virtualenv
fi

virtualenv venv
source venv/bin/activate

for item in ${REQUIREMENTS[*]}
    do
        pip install $item
    done
django-admin startproject $PROJECT
pip freeze > requirements.txt

mkdir html html/src html/src/components html/dist
touch html/package.json
echo $CLIENT

if [ $CLIENT = "react" ]
    then
        echo "
        {
          \"name\": \"$PROJECT\",
          \"version\": \"1.0.0\",
          \"description\": \"\",
          \"main\": \"index.js\",
          \"author\": \"\",
          \"license\": \"ISC\",
          \"devDependencies\": {
            \"babel-core\": \"^6.26.0\",
            \"babel-loader\": \"^7.1.2\",
            \"babel-preset-es2015\": \"^6.24.1\",
            \"babel-preset-react\": \"^6.24.1\",
            \"css-loader\": \"^0.28.7\",
            \"react\": \"^16.1.0\",
            \"react-dom\": \"^16.1.0\",
            \"sass-loader\": \"^6.0.6\",
            \"style-loader\": \"^0.19.0\",
            \"webpack\": \"^3.8.1\",
            \"webpack-dev-server\": \"^2.9.4\"
          },
          \"dependencies\": {
            \"react-dropzone\": \"^4.2.1\",
            \"react-modal\": \"^3.1.2\"
          }
        }" >> html/package.json

        touch html/webpack.config.js
        echo "
        module.exports = {
            entry: {
                main: './src/scripts/main.js'
            },
            output: {
                filename: './dist/scripts/[name].js'
            },
            devtool: 'source-map',
            module: {
                loaders: [
                    {
                        test: /\.js$/,
                        exclude: /(node_modules|bower_components)/,
                        loader: 'babel-loader',
                        query: {
                            presets: ['react', 'es2015']
                        }
                    }
                ]
            }
        }" >> html/webpack.config.js

elif [ $CLIENT = "vue" ]
    then
        echo "
{
  \"name\": \"$PROJECT\",
  \"version\": \"1.0.0\",
  \"description\": \"Trying Vue.js\",
  \"main\": \"index.js\",
  \"dependencies\": {
    \"vue\": \"1.0.4\"
  },
  \"devDependencies\": {
    \"babel-core\": \"^5.8.25\",
    \"babel-loader\": \"^5.3.2\",
    \"babel-runtime\": \"^5.8.25\",
    \"css-loader\": \"^0.21.0\",
    \"style-loader\": \"^0.13.0\",
    \"template-html-loader\": \"0.0.3\",
    \"vue-hot-reload-api\": \"^1.2.0\",
    \"vue-html-loader\": \"^1.0.0\",
    \"vue-loader\": \"^6.0.0\",
    \"webpack\": \"^1.12.2\",
    \"webpack-dev-server\": \"^1.12.0\"
  },
  \"author\": \"\",
  \"license\": \"ISC\"
}
" >> html/package.json

touch html/webpack.config.js
echo "
    var path = require('path')
    var webpack = require('webpack')
    module.exports = {
       entry: {
                main: './src/scripts/main.js'
            },
            output: {
                filename: './dist/scripts/[name].js'
            },
      module: {
        rules: [
          {
            test: /\.vue$/,
            loader: 'vue-loader',
            options: {
              loaders: {
              }
              // other vue-loader options go here
            }
          },
          {
            test: /\.js$/,
            loader: 'babel-loader',
            exclude: /node_modules/
          },
          {
            test: /\.(png|jpg|gif|svg)$/,
            loader: 'file-loader',
            options: {
              name: '[name].[ext]?[hash]'
            }
          }
        ]
      },
      resolve: {
        alias: {
          'vue$': 'vue/dist/vue.esm.js'
        }
      }" >> html/webpack.config.js

elif [ "$CLIENT" = "angular" ]
    then
        echo "
            {
              \"name\": \"$PROJECT\",
              \"version\": \"1.0.0\",
              \"description\": \"\",
              \"scripts\": {
                \"build\": \"tsc -p src/\",
                \"build:watch\": \"tsc -p src/ -w\",
                \"build:e2e\": \"tsc -p e2e/\",
                \"serve\": \"lite-server -c=bs-config.json\",
                \"serve:e2e\": \"lite-server -c=bs-config.e2e.json\",
                \"prestart\": \"npm run build\",
                \"start\": \"concurrently \\"npm run build:watch\\" \\"npm run serve\\"\",
                \"pree2e\": \"npm run build:e2e\",
                \"e2e\": \"concurrently \\"npm run serve:e2e\\" \\"npm run protractor\\" --kill-others --success first\",
                \"preprotractor\": \"webdriver-manager update\",
                \"protractor\": \"protractor protractor.config.js\",
                \"pretest\": \"npm run build\",
                \"test\": \"concurrently \\"npm run build:watch\\" \\"karma start karma.conf.js\\"\",
                \"pretest:once\": \"npm run build\",
                \"test:once\": \"karma start karma.conf.js --single-run\",
                \"lint\": \"tslint ./src/**/*.ts -t verbose\"
              },
              \"keywords\": [],
              \"author\": \"\",
              \"license\": \"MIT\",
              \"dependencies\": {
                \"@angular/common\": \"~4.3.4\",
                \"@angular/compiler\": \"~4.3.4\",
                \"@angular/core\": \"~4.3.4\",
                \"@angular/forms\": \"~4.3.4\",
                \"@angular/http\": \"~4.3.4\",
                \"@angular/platform-browser\": \"~4.3.4\",
                \"@angular/platform-browser-dynamic\": \"~4.3.4\",
                \"@angular/router\": \"~4.3.4\",
                \"angular-in-memory-web-api\": \"~0.3.0\",
                \"systemjs\": \"0.19.40\",
                \"core-js\": \"^2.4.1\",
                \"rxjs\": \"5.0.1\",
                \"zone.js\": \"^0.8.4\"
              },
              \"devDependencies\": {
                \"concurrently\": \"^3.2.0\",
                \"lite-server\": \"^2.2.2\",
                \"typescript\": \"~2.1.0\",
                \"canonical-path\": \"0.0.2\",
                \"tslint\": \"^3.15.1\",
                \"lodash\": \"^4.16.4\",
                \"jasmine-core\": \"~2.4.1\",
                \"karma\": \"^1.3.0\",
                \"karma-chrome-launcher\": \"^2.0.0\",
                \"karma-cli\": \"^1.0.1\",
                \"karma-jasmine\": \"^1.0.2\",
                \"karma-jasmine-html-reporter\": \"^0.2.2\",
                \"protractor\": \"~4.0.14\",
                \"rimraf\": \"^2.5.4\",
                \"@types/node\": \"^6.0.46\",
                \"@types/jasmine\": \"2.5.36\"
              },
              \"repository\": {}
            }
        " >> package.json
fi

touch html/src/main.js
cd html
npm install
cd ..

touch .gitignore
for item in ${GITIGNORE_FILES[*]}
    do
        echo $item >> .gitignore
    done


cd $PROJECT/$PROJECT

touch localsettings.py

echo "
try:
    from localsettings import *
except Exception:
    print('You need to create localsettings.py file!!')
" >> settings.py
