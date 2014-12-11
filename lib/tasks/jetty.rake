require 'jettywrapper'

namespace :jetty do
  task :clean do
    FileUtils.rm_rf(MARMOTTA_HOME)
    Jettywrapper.clean
  end
end
