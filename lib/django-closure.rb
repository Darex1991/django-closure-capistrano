load 'deploy' if respond_to?(:namespace) # cap2 differentiator
# Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

require 'rubygems'
require 'railsless-deploy'

################################################
def importdb(fileDirectory,fileToImport,dbIp,dbLogin,dbPwd,dbName,replacecmd)
  if replacecmd.length == 0 then
    replacecmd = " echo 'Replace Command' "
  end

  cmd = "cd #{fileDirectory} && "+
    "tar xjvf #{fileToImport}.tar.bz2 && "+
    replacecmd+" && "+
    "( echo 'SET AUTOCOMMIT=0;';"+
    "echo 'SET FOREIGN_KEY_CHECKS=0;';"+
    " cat #{fileToImport};"+
    " echo 'SET FOREIGN_KEY_CHECKS=1;';"+
    " echo 'COMMIT;'; echo 'SET AUTOCOMMIT=1;';) | mysql -h '#{dbIp}' -u #{dbLogin} -p#{dbPwd} "+
    "#{dbName} "
  return cmd
end
def exportserverdb(dbIp,dbLogin,dbPwd,dbName,tables,exportFilename)
  if(tables.is_a?(Array))
    tables = table.join(' ')
  end
  puts "Exporting database onto server"
  cmd = "cd #{fetch :serverBasePath}/config &&"+
    " mysqldump -h '#{dbIp}' -u #{dbLogin} -p#{dbPwd} "+
    "#{dbName} #{tables} > ./#{exportFilename}"+
    " && tar cjvf ./#{exportFilename}.tar.bz2 ./#{exportFilename}"

  #  download "#{fetch :deploy_to}/shared/system/#{exportFilename}.tar.bz2",
  puts "Downloading: "+"#{fetch :serverBasePath}/config/#{exportFilename}.tar.bz2"+
    " to "+ "./config/sql/"
  sourcefile = "#{fetch :serverBasePath}/config/#{exportFilename}.tar.bz2"
  destfile = "./config/sql/"
  return [cmd,sourcefile,destfile]
end
######################################################################################################################
desc <<-DESC
      Export the local database to a file in config/sql directory.

      This uses the information stored in cake config/database.php file and uses
      the first entry of the database variables in the file, ie not the
      test database login details...
DESC
task :export_database do
  cmd =  "mysqldump -u #{fetch :wpAccess} -p#{fetch :wpAccessPwd}  "+
    "#{fetch :wpAccess} > ./config/sql/localhost.mysql.bup.sql"
  run_locally "#{cmd}"
  cmd = "tar -cjvf localhost.mysql.bup.sql.tar.bz2 localhost.mysql.bup.sql"
  run_locally "cd ./config/sql && #{cmd} && cd ../../"
end
######################################################################################################################
desc <<-DESC
      Export the local database to a file in config/sql directory.

      This uses the information stored in cake config/database.php file and uses
      the first entry of the database variables in the file, ie not the
      test database login details...
DESC
task :export_database_to_remote, :roles => :web do
  export_database
  upload './config/sql/localhost.mysql.bup.sql.tar.bz2',
    "#{fetch :serverBasePath}/config",:via => :scp
  cmd = importdb("#{fetch :serverBasePath}/config/",'localhost.mysql.bup.sql',
    'localhost',"#{fetch :wpAccess}","#{fetch :wpAccessPwd}","#{fetch :wpAccess}",
    ''
  )
  run cmd
end

######################################################################################################################
desc <<-DESC
      Export Remote Datbase To here
DESC
task :export_remote_database_to_here, :roles => :web do
  if !exists?(:table)then
    puts "--------------------------------------------------------------------------"
    puts "Set -s table=TABLENAME to export a specific table."
    puts "--------------------------------------------------------------------------"
    set :table,''
  end
  values = exportserverdb("localhost","#{fetch :wpAccess}",
    "#{fetch :wpAccessPwd}",
    "#{fetch :wpAccess}",
    "#{fetch :table}",
    "production.mysql.bup.sql")
  #  puts values[0]
  run values[0]
  download values[1],values[2],:via => :scp
end

######################################################################################################################
desc <<-DESC
      Import Remote Datbase To here
DESC
task :import_remote_database, :roles => :web do
  export_remote_database_to_here
  cmd = importdb('./config/sql','production.mysql.bup.sql',
    'localhost',"#{fetch :wpAccess}","#{fetch :wpAccessPwd}","#{fetch :wpAccess}",
    ''
  )
  run_locally cmd
end

######################################################################################################################
desc <<-DESC
      Build Static
DESC
task :build_static, :roles => :web do
  run_locally "rm -rf server/static/css/.sass-cache/*"
  run_locally "rm server/static/stylesheets/images/*.*.png"
  run_locally "rm server/static/stylesheets/images/*.*.gif"
  run_locally "rm server/static/stylesheets/images/*.*.svg"
  run_locally "rm server/static/ccss/*"
  run_locally "rm server/static/cjs/*"
  run_locally "rm server/static/stylesheets/*.*.css"
  run_locally "sudo chmod 777 #{fetch :djangoDebug}{"
  run_locally "./manage.py collectstatic --noinput"
end
######################################################################################################################
desc <<-DESC
      Build Closure
DESC
task :build_closure, :roles => :web do
  run_locally " java -jar #{fetch :plovrPath} build config/plovrconfig.json > ./server/static/js/compiled.js"
end
######################################################################################################################
desc <<-DESC
      Watch Closure
DESC
task :watch_closure, :roles => :web do
  build_closure
  run_locally "sh lib/compileclosure.sh #{fetch :javascriptSource}"
end
######################################################################################################################
desc <<-DESC
      Before for deploy
DESC
task :before_deploy, :roles => :web do
  run "rm  #{fetch :serverBasePath}/server/static/stylesheets/images/*.*.png"
  run "rm #{fetch :serverBasePath}/server/static/stylesheets/images/*.*.gif"
  run "rm #{fetch :serverBasePath}/server/static/stylesheets/images/*.*.svg"
  run "rm #{fetch :serverBasePath}/server/static/ccss/*"
  run "rm #{fetch :serverBasePath}/server/static/cjs/*"
  run "rm #{fetch :serverBasePath}/server/static/stylesheets/*.*.css"
  run_locally "replace 'DEBUG = True' 'DEBUG = False' -- #{fetch :basePath}/settings.py"
  run_locally "replace '#{fetch :basePath}' '#{fetch :serverBasePath}' -- #{fetch :basePath}/settings.py"
  run_locally "replace '#{fetch :basePath}' '#{fetch :serverBasePath}' -- #{fetch :basePath}/server/scripts/django.wsgi"
end
######################################################################################################################
desc <<-DESC
      After deploy
DESC
task :after_deploy, :roles => :web do
  run_locally "replace '#{fetch :serverBasePath}' '#{fetch :basePath}' -- #{fetch :basePath}/settings.py"
  run_locally "replace '#{fetch :serverBasePath}' '#{fetch :basePath}' -- #{fetch :basePath}/server/scripts/django.wsgi"
  run_locally "replace 'DEBUG = False' 'DEBUG = True' -- #{fetch :basePath}/settings.py"
end

######################################################################################################################
desc <<-DESC
      Synchronise websites to server.
DESC
task :rsync_to_server, :roles => :web do
  run_locally "rsync -atvz --exclude-from=#{fetch :basePath}/config/rsyncignore  #{fetch :basePath} #{fetch :serverSSH}:#{fetch :serverBasePath}"
end
######################################################################################################################
desc <<-DESC
      Deploy websites to server.
DESC
task :rsync_deploy, :roles => :web do
  build_closure
  build_static
  before_deploy
  rsync_to_server
  after_deploy
end
######################################################################################################################
desc <<-DESC
      Synchronise website config to server.
DESC
task :rsync_settings_to_server do
  run_locally "rsync -atvz  #{fetch :basePath}/config #{fetch :serverSSH}:#{fetch :serverBasePath}/"
end

######################################################################################################################
desc <<-DESC
      Rsync image to localhost
DESC
task :rsync_server_images_to_here do
  run_locally "rsync -atvz  #{fetch :serverSSH}:#{fetch :serverBasePath}/server/static/img/photos #{fetch :basePath}/server/static/img"
end

