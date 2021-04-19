#  @synchronized

## @synchronized 实现

```C
@synchronized(obj){
    // ..
}
```

```shell
// 转化为cpp
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fno-objc-arc main.m
```

```C
// 省略其他大致如下
{

// 进入synchronized block 前进入sync
id _sync_obj = (id)obj; // 此处在ARC下时会有默认所有权修饰符__strong，所以会引用对象.
objc_sync_enter(_sync_obj);

try {
    struct _SYNC_EXIT { 
        _SYNC_EXIT(id arg) : sync_exit(arg) {}
        ~_SYNC_EXIT() {
            // 析构时退出sync
            objc_sync_exit(sync_exit);
        }
        id sync_exit;
    } _sync_exit(_sync_obj);
    //...
} catch(id e) {
    //...
}
//@finally
{
    //抛出异常
}
}
```

**@synchronized** 大致操作：
1. 创建一个闭包，并创建引用对象的局部变量，调用 **objc_sync_enter**
2. try-catch包裹 **synchronized block**
3. try闭包中创建结构体 **_SYNC_EXIT** 及其对象，其中析构函数中调用 **objc_sync_exit** 

## objc_sync_enter & objc_sync_exit

```C
// 去除逻辑，去除的就是不做什么，或者只是输出一些log
int objc_sync_enter(id obj)
{
    int result = OBJC_SYNC_SUCCESS;

    if (obj) {
        SyncData* data = id2data(obj, ACQUIRE);
        ASSERT(data);
        data->mutex.lock();
    } else {
        // @synchronized(nil) does nothing
        // ...
        objc_sync_nil(); // 用于debug，无其他内容
    }

    return result;
}

int objc_sync_exit(id obj)
{
    int result = OBJC_SYNC_SUCCESS;
    
    if (obj) {
        // 从
        SyncData* data = id2data(obj, RELEASE);
        if (!data) {
            result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
        } else {
            bool okay = data->mutex.tryUnlock();
            if (!okay) {
                result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
            }
        }
    } else {
        // @synchronized(nil) does nothing
    }
    
    return result;
}
```
## id2data(.., ..)

```C

#define LOCK_FOR_OBJ(obj) sDataLists[obj].lock
#define LIST_FOR_OBJ(obj) sDataLists[obj].data

// 将StripedMap当成是Map就好
static StripedMap<SyncList> sDataLists;

struct SyncList {
    SyncData *data;
    spinlock_t lock; // SyncList的锁

    constexpr SyncList() : data(nil), lock(fork_unsafe_lock) { }
};

typedef struct alignas(CacheLineSize) SyncData {
    struct SyncData* nextData;
    DisguisedPtr<objc_object> object; // @synchronized引用的对象
    // SyncData 对象中的锁会被一些线程使用或等待，threadCount就是数量
    int32_t threadCount;  // number of THREADS using this block 
    recursive_mutex_t mutex; // 与object关联的递归互斥锁
} SyncData;

static SyncData* id2data(id object, enum usage why)
{
    spinlock_t *lockp = &LOCK_FOR_OBJ(object);
    SyncData **listp = &LIST_FOR_OBJ(object);
    SyncData* result = NULL;
    // ...
}
```

**id2data(obj, action)**:
1. 根据 **object** 查找 **SyncData**
2. 如果 **SyncData** 已经存在，**action** 为 
    * **获得** 增加 **threadCount**
    * **释放** 减少 **threadCount**
3. 如果没有则找到一个 **threadCount == 0** 的 **SyncData**，缓存 **object**，并增加相应的 **threadCount**
