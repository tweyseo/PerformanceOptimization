# **app**

## **Overview**

It's a minimalist web framework based on [OpenResty](https://github.com/openresty/openresty) and refer to [lor](https://github.com/sumory/lor).

There will be a series of optimizations on it with LuaJIT's [jit.v](https://github.com/LuaJIT/LuaJIT/blob/master/src/jit/v.lua) module and some LuaJIT tools in [stap](https://github.com/openresty/stapxx#lj-vm-states). the purpose is not only to optimize the framework, but also to practice the [jit.v](https://github.com/LuaJIT/LuaJIT/blob/master/src/jit/v.lua) and LuaJIT tools in [stap](https://github.com/openresty/stapxx#lj-vm-states).

## **Stage**

**2019-3-26 optimize on `add*` operation**:

before:
```
# group 1
'addMiddleware' run [500000] times, elapsed time: 5.3430001735687
'addErrHandler' run [500000] times, elapsed time: 5.3339998722076
'addHandler' run [500000] times, elapsed time: 4.9950001239777
# group 2
'addMiddleware' run [500000] times, elapsed time: 5.2669999599457
'addErrHandler' run [500000] times, elapsed time: 5.3320000171661
'addHandler' run [500000] times, elapsed time: 5.0889999866486
# group 3
'addMiddleware' run [500000] times, elapsed time: 5.231999874115
'addErrHandler' run [500000] times, elapsed time: 5.1549999713898
'addHandler' run [500000] times, elapsed time: 4.8980000019073
```

optimize:
```
```

after:
```
```

## **TODO**