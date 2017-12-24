class CandlesController < ApplicationController
  require 'cassandra'
  require 'json'

  START_TIME = '2016-10-01 12:00:00'
  END_TIME = '2016-10-01 13:00:00'

  def index

    @db = params[:db]

  end

  def api

    start = Time.now
    if params[:db] == "mongo"
      client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mydb')
      collection = client[:things]
      data = collection.find({ "time" => { "$gt" => DateTime.parse(START_TIME).to_i*1000 , "$lt" => DateTime.parse(END_TIME).to_i*1000}})
    elsif params[:db] == "cassandra"
      cluster = Cassandra.cluster
      cluster.each_host do |host|
        puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
      end
      keyspace = 'py_casandra'
      session = cluster.connect(keyspace)
      future = session.execute_async("SELECT time, open, high, close, low FROM coins where id=c3113762-4a4c-4be9-8c4f-9f3f98ebe428 AND time >= '#{START_TIME}+0000' AND time <= '#{END_TIME}+0000' ORDER BY time ASC", :page_size => 100000)
      data = future.join
    elsif params[:db] == "mysql"
      data = Minute.where("time BETWEEN ? AND ?", START_TIME, END_TIME)
    end

    result = []

    data.each do |row|
      if params[:db] == "mysql"
        time_col = row.time.to_time.to_i*1000
      elsif params[:db] == "cassandra"
        time_col = row['time'].to_i*1000
      elsif params[:db] == "mongo"
        time_col = row['time']
      end

      price_row = []
      price_row << row['open']
      price_row << row['high']
      price_row << row['low']
      price_row << row['close']

      result << { "x" => time_col, "y" => price_row }

    end

    puts "*********TIME*********"
    puts params[:db] + ":" + (Time.now - start).to_s
    puts "======================"

    render :json => result.to_json

  end


end
