class ChartsController < ApplicationController
  require 'cassandra'
  require 'json'
  def index

    cluster = Cassandra.cluster
    cluster.each_host do |host|
      puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
    end
    keyspace = 'py_casandra'
    session = cluster.connect(keyspace)
    future = session.execute_async("SELECT time, close, vol_btc FROM coins where id=c3113762-4a4c-4be9-8c4f-9f3f98ebe428 AND time >= '2017-09-01 00:00:00+0000' AND time <= '2017-09-02 00:00:00+0000' ORDER BY time ASC LIMIT 300000;", :page_size => 100000)

    time_col = ['x']
    price_col = ['price']

    future.join.each do |row|
      time_col << row['time'].to_i*1000
      price_col << row['close']
    end

    result = {"x" => "x", "xFormat": "%Y", "columns" => [time_col, price_col]}

    @json = result.to_json

  end

  def mysql

    time_col = ['x']
    price_col = ['price']

    Minute.where("time BETWEEN ? AND ?", '2017-09-01 00:00:00', '2017-09-02 00:00:00').each do |row|
      time_col << row.time.to_time.to_i*1000
      price_col << row.close
    end

    result = {"x" => "x", "xFormat": "%Y", "columns" => [time_col, price_col]}

    @json = result.to_json

  end

  def api

    cluster = Cassandra.cluster
    cluster.each_host do |host|
      puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
    end
    keyspace = 'py_casandra'
    session = cluster.connect(keyspace)
    future = session.execute_async("SELECT time, close, vol_btc FROM coins where id=c3113762-4a4c-4be9-8c4f-9f3f98ebe428 AND time >= '2017-09-01 00:00:00+0000' AND time <= '2017-09-02 00:00:00+0000' ORDER BY time ASC LIMIT 300000;", :page_size => 100000)

    time_col = ['x']
    price_col = ['price']

    future.join.each do |row|
      time_col << row['time']
      price_col << row['close']
    end

    result = {"x" => "x", "columns" => [time_col, price_col]}

    render :json => result.to_json

  end

end
