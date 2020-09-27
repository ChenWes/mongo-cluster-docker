# mongo-cluster-docker

This is a simple 3 node replica mongodb setup based on official `mongo` docker image using `docker-compose` described in my blogpost at https://warzycha.pl/mongo-db-sharding-docker-example/.

For details description, steps and discussion go to:

1. https://warzycha.pl/mongo-db-sharding-docker-example/
2. https://warzycha.pl/mongo-db-shards-by-location/


架构请参考图片MongoDB.png
1. docker-compose.1.yml中，30011、30012、30013为第一个副本集群（数据分片--shardsvr）
2. docker-compose.2.yml中，30021、30022、30023为第二个副本集群（数据分片--shardsvr）
3. docker-compose.cnf.yml中，30101、30102、30103为第三个副本集群（配置分片--configsvr）
4. docker-compose.shard.yml中，30001为集群入口（应用程序连接就使用这个端口来进行连接）


关于mongod的配置文件，请参考[https://www.jianshu.com/p/f9f1454f251f](!https://www.jianshu.com/p/f9f1454f251f)

# 运行
因为权限的问题，如果是从Windows电脑复制到Linux服务器的，在运行前一定要先进行授权
```
cd scripts && chmod +x setup.sh init-shard.sh setup-cnf.sh && cd ..
```
再运行Docker-Compose脚本
```
docker-compose -f docker-compose.1.yml -f docker-compose.2.yml  -f docker-compose.cnf.yml -f docker-compose.shard.yml up
```



# 运行成功





# 测试

> 暂时是手动的

0. Core tests

对副本集（数据节点）rs1或rs2进行基本的副本集测试  `mongo-1-1` `mongo-1-2` `mongo-1-3` 或者 `mongo-2-1` `mongo-2-2 ` `mongo-2-3`
```js
#mongo命令行
docker exec -it mongo-1-1 mongo

#进入至mongo命令行中，查看副本集状态
rs.status();
```

正常在rs1和rs2两个副本集`members`都有三个节点 



对分片服务器`mongo-router`基本测试 
```js
#mongo命令行
docker exec -it mongo-router mongo

#进入至mongo命令行中，查看分片状态
sh.status();
```

返回的数据:

```
--- Sharding Status --- 
  sharding version: {
        "_id" : 1,
        "minCompatibleVersion" : 5,
        "currentVersion" : 6,
        "clusterId" : ObjectId("5f644adbaa87171ddbdd26df")
  }
  shards:
        {  "_id" : "rs1",  "host" : "rs1/172.21.0.10:27017,172.21.0.5:27017,172.21.0.6:27017",  "state" : 1 }
        {  "_id" : "rs2",  "host" : "rs2/172.21.0.3:27017,172.21.0.7:27017,172.21.0.9:27017",  "state" : 1 }
  active mongoses:
        "4.0.1" : 1
  autosplit:
        Currently enabled: yes
  balancer:
        Currently enabled:  yes
        Currently running:  no
        Failed balancer rounds in last 5 attempts:  0
        Migration Results for the last 24 hours: 
                No recent migrations
  databases:
        {  "_id" : "MES",  "primary" : "rs1",  "partitioned" : false,  "version" : {  "uuid" : UUID("c0016654-6a59-4dc4-bfe0-c7b33dd11f23"),  "lastMod" : 1 } }
        {  "_id" : "config",  "primary" : "config",  "partitioned" : true }
                config.system.sessions
                        shard key: { "_id" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                rs1     1
                        { "_id" : { "$minKey" : 1 } } -->> { "_id" : { "$maxKey" : 1 } } on : rs1 Timestamp(1, 0) 
        {  "_id" : "tajima",  "primary" : "rs2",  "partitioned" : false,  "version" : {  "uuid" : UUID("4cc0b7a4-c817-4df4-b843-3224489210c5"),  "lastMod" : 1 } }
```



# Sharding configuration分片配置

Connect to 'mongos' router and run `queries/shard-status.js` for shard status.

To establish location based partitioning on it just run `queries/init.js`.

# Issues and limitations

It's sometimes stuck on 'mongo-router         | 2017-01-16T21:29:48.573+0000 W NETWORK  [replSetDistLockPinger] No primary detected for
set cnf-serv'. It's because quite random order in `docker-compose`.

My workaround was just to kill all containers related.

```
docker-compose -f docker-compose.1.yml -f docker-compose.2.yml  -f docker-compose.cnf.yml -f docker-compose.shard.yml rm -f
```

Please pull request. :)

Basically `mongosetup` service is now splitted to multiple `yml` files. :)



# 特别注意

该集群现在所有的数据是`没有保存的`，需要`增加节点的保存能力`
按





# 参考

* http://www.sohamkamani.com/blog/2016/06/30/docker-mongo-replica-set/
* https://github.com/singram/mongo-docker-compose
* http://stackoverflow.com/questions/31138631/configuring-mongodb-replica-set-from-docker-compose
* https://gist.github.com/garycrawford/0a45f820e146917d231d
* http://stackoverflow.com/questions/31746182/docker-compose-wait-for-container-x-before-starting-y
* https://docs.docker.com/compose/startup-order/
* http://stackoverflow.com/questions/31138631/configuring-mongodb-replica-set-from-docker-compose
* https://github.com/soldotno/elastic-mongo/blob/master/docker-compose.yml

See more @ `ENV.md`

MIT @ `LICENSE`
