#!/bin/bash 

mongodb1=`getent hosts ${MONGOS} | awk '{ print $1 }'`

mongodb11=`getent hosts ${MONGO11} | awk '{ print $1 }'`
mongodb12=`getent hosts ${MONGO12} | awk '{ print $1 }'`
mongodb13=`getent hosts ${MONGO13} | awk '{ print $1 }'`

mongodb21=`getent hosts ${MONGO21} | awk '{ print $1 }'`
mongodb22=`getent hosts ${MONGO22} | awk '{ print $1 }'`
mongodb23=`getent hosts ${MONGO23} | awk '{ print $1 }'`

mongodb31=`getent hosts ${MONGO31} | awk '{ print $1 }'`
mongodb32=`getent hosts ${MONGO32} | awk '{ print $1 }'`
mongodb33=`getent hosts ${MONGO33} | awk '{ print $1 }'`

port=${PORT:-27017}

echo "Setting for startup.."
echo mongodb1 $mongodb1

echo mongodb11 $mongodb11
echo mongodb12 $mongodb12
echo mongodb13 $mongodb13

echo mongodb21 $mongodb21
echo mongodb22 $mongodb22
echo mongodb23 $mongodb23

echo mongodb31 $mongodb31
echo mongodb32 $mongodb32
echo mongodb33 $mongodb33

echo port $port

echo "Waiting for startup.."
until mongo --host ${mongodb1}:${port} --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
  printf '.'
  sleep 1
done

echo "Started.."

echo init-shard.sh time now: `date +"%T" `
mongo --host ${mongodb1}:${port} <<EOF
   sh.addShard( "${RS1}/${mongodb11}:${PORT1},${mongodb12}:${PORT2},${mongodb13}:${PORT3}" );
   sh.addShard( "${RS2}/${mongodb21}:${PORT1},${mongodb22}:${PORT2},${mongodb23}:${PORT3}" );
   sh.status();
EOF
