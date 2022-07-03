namespace :"turbo-replay" do
  task :install do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("./install/task.rb", __dir__)}"
  end
end
