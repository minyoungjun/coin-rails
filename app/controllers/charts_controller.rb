class ChartsController < ApplicationController
  require 'cassandra'
  require 'json'

  START_TIME = '2017-09-01 00:00:00'
  END_TIME = '2017-09-02 00:00:00'

  def mongo

    client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mydb')
    collection = client[:things]

    start = Time.now

    data = collection.find({ "time" => { "$gt" => DateTime.parse(START_TIME).to_i*1000 , "$lt" => DateTime.parse(END_TIME).to_i*1000}})
    puts "call:" + (Time.now - start).to_s

    time_col = ['x']
    price_col = ['price']

    data.each do |row|
      time_col << row['time']
      price_col << row['close']
    end

    puts "end:" + (Time.now - start).to_s

    result = {"x" => "x", "xFormat": "%Y", "columns" => [time_col, price_col]}

    @json = result.to_json


  end


  def index

    #Cassandra

    cluster = Cassandra.cluster
    cluster.each_host do |host|
      puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
    end
    keyspace = 'py_casandra'
    session = cluster.connect(keyspace)


    start = Time.now
    future = session.execute_async("SELECT time, close, vol_btc FROM coins where id=c3113762-4a4c-4be9-8c4f-9f3f98ebe428 AND time >= '#{START_TIME}+0000' AND time <= '#{END_TIME}+0000' ORDER BY time ASC", :page_size => 100000)
    puts "call:" + (Time.now - start).to_s

    time_col = ['x']
    price_col = ['price']

    future.join.each do |row|
      time_col << row['time'].to_i*1000
      price_col << row['close']
    end

    puts "end:" + (Time.now - start).to_s

    result = {"x" => "x", "xFormat": "%Y", "columns" => [time_col, price_col]}

    @json = result.to_json


  end

  def mysql

    time_col = ['x']
    price_col = ['price']


    start = Time.now
    sql = Minute.where("time BETWEEN ? AND ?", START_TIME, END_TIME)
    puts "call:" + (Time.now - start).to_s

    sql.each do |row|
      time_col << row.time.to_time.to_i*1000
      price_col << row.close
    end

    puts "end:" + (Time.now - start).to_s

    result = {"x" => "x", "xFormat": "%Y", "columns" => [time_col, price_col]}

    @json = result.to_json


  end

  def api
    #cassandra
    cluster = Cassandra.cluster
    cluster.each_host do |host|
      puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
    end
    keyspace = 'py_casandra'
    session = cluster.connect(keyspace)

    future = session.execute_async("SELECT time, close, vol_btc FROM coins where id=c3113762-4a4c-4be9-8c4f-9f3f98ebe428 AND time >= '#{START_TIME}+0000' AND time <= '#{END_TIME}+0000' ORDER BY time ASC;", :page_size => 100000)

    time_col = ['x']
    price_col = ['price']

    counter = 0
    future.join.each do |row|
      time_col << row['time']
      price_col << row['close']
      counter = counter + 1
    end

    puts "COUNT: " + counter.to_s

    result = {"x" => "x", "columns" => [time_col, price_col]}

    render :json => result.to_json

  end

end
