# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'cassandra'

START_TIME = "2015-10-01 00:00:00"
END_TIME = "2017-10-01 00:00:00"
TERM = 1440
SIZE = 10

#이동평균선 1년기준 10일 이동평균 구하기
#
#MYSQL
candlesize = Candlesize.find(12)
candledata = candlesize.candledata
#1일씩 들어있음. 5일 종가 평균을 내보자

size = SIZE

temp = []

start_time = Time.now
candledata.each do |candledatum|

  if temp.size > size - 1
    temp.shift
  end

  temp << candledatum

  sum = 0

  temp.each do |temp|
    sum = sum + temp.close
  end

  average = sum/size

  moving = Moving.new
  moving.candlesize_id = candlesize.id
  moving.start_time = candledatum.start_time
  moving.size = size
  moving.candledatum_id = candledatum.id
  moving.average = average
  moving.save


end

puts Time.now - start_time


#cassandra 이동평균 구하기
start_time = Time.now
cluster = Cassandra.cluster
keyspace = 'py_casandra'
session = cluster.connect(keyspace)
size = SIZE

temp = []
session.execute("CREATE TABLE IF NOT EXISTS py_casandra.movings ( start_time timestamp, close float, size int, PRIMARY KEY(size, start_time) ) WITH CLUSTERING ORDER BY (start_time ASC);")

future = session.execute_async("SELECT start_time, close FROM candledata where term = 1440 ORDER BY start_time ASC", :page_size => 100000)

future.join.each do |candledatum|
  if temp.size > size - 1
    temp.shift
  end
  temp << candledatum
  sum = 0
  temp.each do |temp|
    sum  = sum + temp['close']
  end

  average = sum/size

  session.execute("INSERT INTO py_casandra.movings (start_time, close, size) VALUES ('#{candledatum['start_time']}',#{average}, #{size} );")

end

puts Time.now - start_time


#mongodb 이동평균
start_time  = Time.now

client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'mydb')
candledata = client[:candledata]
movingcollection = client[:movings] #collection으로 구분하자.
size = SIZE
temp = []
candledata.find({"term" => TERM*3}, :sort => {'start_time' => 1}).each do |candledatum|
  if temp.size > size - 1
    temp.shift
  end

  temp << candledatum
  sum = 0
  temp.each do |temp|
    sum = sum + temp['close']
  end

  average = sum/size

  movingcollection.insert_one({:start_time => candledatum['start_time'], :average => average, :size => size })

end

puts Time.now - start_time

#cassandra
start = Time.now
cluster = Cassandra.cluster
cluster.each_host do |host|
  puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
end
keyspace = 'py_casandra'
session = cluster.connect(keyspace)
#session.execute("CREATE TABLE IF NOT EXISTS py_casandra.candledata ( start_time timestamp, open float, high float, close float, low float, vol_btc float, vol_currency float, term int, PRIMARY_KEY(term, start_time) ) WITH CLUSTERING ORDER BY (start_time ASC);")

term = TERM

current_time = DateTime.parse(START_TIME)

while(current_time < DateTime.parse(END_TIME))
  last_time = current_time + term.minute - 1.minute
  future = session.execute_async("SELECT time, open, high, close, low FROM coins where id=c3113762-4a4c-4be9-8c4f-9f3f98ebe428 AND time >= '#{current_time.to_s}' AND time <= '#{last_time.to_s}' ORDER BY time ASC", :page_size => 10000000)
  range = future.join

  high = 0
  low = 100000000
  last = range.first
  range.each do |minute|
    if minute['high'] > high
      high = minute['high']
    end
    if minute['low'] < low
      low = minute['low']
    end
    last = minute
  end

  first = range.first

  session.execute("INSERT INTO py_casandra.candledata (start_time, open, high, low, close, term) VALUES ('#{current_time.to_s}', #{first['open']},#{high}, #{low}, #{last['close']}, #{term*3} );")
  current_time = current_time + term.minute

end

puts (Time.now - start)

#mongo
start = Time.now

client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'mydb')
things = client[:things]
collection = client[:candledata] #collection으로 구분하자.

term = TERM

current_time = DateTime.parse(START_TIME)
while (current_time < DateTime.parse(END_TIME))
  last_time = current_time + term.minute - 1.minute
  range = things.find({"time" => {"$gt" => current_time.to_i*1000, "$lt" => last_time.to_i*1000 } } )
  high = 0
  low = 1000000000

  first = range.first
  last = range.first

  range.each do |minute|

    if minute['high'] > high
      high = minute['high']
    end

    if minute['low'] < low
      low = minute['low']
    end

    if minute['time'] < first['time']
      first = minute
    end

    if minute['time'] > last['time']
      last = minute
    end
  end

  collection.insert_one({ :start_time => current_time.to_i*1000, :end_time => last_time.to_i*1000, :high => high, :low => low, :open => first['open'], :close => last['close'], :term => term*3 })
  current_time = current_time + term.minute

end

puts (Time.now - start)


#MYSQL
#
candlesize = Candlesize.new
candlesize.start_time = START_TIME
candlesize.end_time = END_TIME
candlesize.minute = TERM
candlesize.save

current_time = candlesize.start_time

start_time = Time.now
while(current_time < candlesize.end_time)

  range = Minute.where("time BETWEEN ? AND ?", current_time, current_time + candlesize.minute.minute - 1.minute)
  puts "first" + range.first.id.to_s
  puts "last" + range.last.id.to_s

  high = 0
  low = 100000000
  range.each do |minute|
    if minute.high > high
      high = minute.high
    end

    if minute.low < low
      low = minute.low
    end

  end

  candledatum = Candledatum.new
  candledatum.candlesize_id = candlesize.id
  candledatum.start_time = current_time
  candledatum.end_time = current_time + candlesize.minute.minute
  candledatum.high = high
  candledatum.low = low
  candledatum.open = range.first.open
  candledatum.close = range.last.close
  candledatum.save
  current_time = current_time + candlesize.minute.minute

end

puts "TIME: " + (Time.now - start_time).to_s

#MYSQL END
