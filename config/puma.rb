# only works running > puma, not > rails s Puma
# On dev machine was able to login while a long running process was in progress but could not display first page...
port 3000
threads 2,16 # each worker will have this many threads
workers 2 # 1 for each core. Apparently setting up workers like this means that Puma2 runs in cluster mode
#preload_app! # not for dev, apparently