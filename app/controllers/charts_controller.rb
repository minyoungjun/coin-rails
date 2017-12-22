class ChartsController < ApplicationController
  require 'cassandra'

  def index
    cluster = Cassandra.cluster
    cluster.each_host do |host|
      puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
    end
    keyspace = 'py_casandra'
    session = cluster.connect(keyspace)
    future = session.execute_async("SELECT time, close, vol_btc FROM coins where id=c3113762-4a4c-4be9-8c4f-9f3f98ebe428 AND time >= '2017-09-01 00:00:00+0000' AND time <= '2017-10-01 00:00:00+0000' ORDER BY time ASC LIMIT 300000;", :page_size => 100000)

    future.join

    render plain: future.join
  end
end
