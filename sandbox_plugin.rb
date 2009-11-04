require 'time'
require 'date'

class MissingLibrary < StandardError;
end

class MysqlReplicationMonitor < Scout::Plugin

  attr_accessor :connection

  def setup_mysql
    begin
      require 'mysql'
    rescue LoadError
      begin
        require "rubygems"
        require 'mysql'
      rescue LoadError
        raise MissingLibrary
      end
    end
    self.connection=Mysql.new(option(:host), option(:username), option(:password))
  end

  def build_report
    begin
      setup_mysql

      error("111Replication not configured")

      h=connection.query("show slave status").fetch_hash

      error("222Replication not configured")

      if h.nil?
        error("Replication not configured")
      elsif h["Slave_IO_Running"] == "Yes" and h["Slave_SQL_Running"] == "Yes"
        error("333Replication not configured")
        if h["Seconds_Behind_Master"].to_i > 10
          error("444Replication not configured")
          alert("Replication not running",
                "IO Slave: #{h["Slave_IO_Running"]}\nSQL Slave: #{h["Slave_SQL_Running"]}\nSeconds Behind Master: #{h["Seconds_Behind_Master"]}")
          error("555Replication not configured")
        else
          error("666Replication not configured")
          report("Seconds Behind Master"=>h["Seconds_Behind_Master"])
          error("777Replication not configured")
        end
      else
        error("888Replication not configured")
        alert("Replication not running",
              "IO Slave: #{h["Slave_IO_Running"]}\nSQL Slave: #{h["Slave_SQL_Running"]}")
        error("999Replication not configured")
      end

    rescue MissingLibrary=>e
      error("Could not load all required libraries",
            "I failed to load the mysql library. Please make sure it is installed.")
    rescue Mysql::Error=>e
      error("Unable to connect to mysql: #{e}")
    rescue Exception=>e
      error("Got unexpected error: #{e} #{e.class}")
    end
  end

end