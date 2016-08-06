# RWPromiseKit

Desiciption
-------

A light-weighted Promise library for Objective-C 

#### About Promise

>The Promise object is used for deferred and asynchronous computations. A Promise represents an operation that hasn't completed yet, but is expected in the future.
[Ref](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)

In JavaScript, `Promise` handles asynchronising call beatifully:


```js
getJSON("/posts.json").then(function(posts) {
  // ...
  consume(posts);
}).catch(function(error) {
  console.log('something wrong！', error);
});
```

Usage of RWPromiseKit
-------
Here is a basic example:
```objc
RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
                  resolve(@"result");
                }];
p1.then(^id(NSString* value){
  NSLog(@"%@",value); //result
  return @"resultOfThen";
}).then(^id(NSString* value){
  NSLog(@"%@",value); //resultOfThen
  NSException *e = [NSException exceptionWithName:@"name"
                                           reason:@"reason"
                                         userInfo:@{}];
  @throw e;
  return nil;
}).catch(^(NSError* error){
  NSLog(@"%@",[error description]); //error contains exception
});
```
Using RWPromise is exactly same as using promise in js. `resolve` and `reject` are provided in initial block as input parameters, these two methods are used to change the state of a promise. Block passed in `then` will be invoked when a promise is set to resolved while one in `catch` will be invoked when rejected.

For more infomation about the API of promise in js, please reference [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)

###Suppoted API
- `then`
- `catch`
- `finally`
- `after`
- `retry`
- `timeout`
- `map`
- `filter`
- `reduce`
- `race`
- `all`
- `resolve`
- `reject`

Installation
-------
- Cocoapods
```
pod 'RWPromiseKit', '0.1.0'
```

- Source code

Copy all source files from directory `Class` to your project

Issues and Todo list
-------
- I simplify the usage of `then`. Just pass only one handler block to hanle when last promise is resolved. To reject, you can raise an expection or return a new promise.

- ~~some other API: `map`,`filter`,`reduce`~~
- Integrate with 3rd party lib
- ~~Unit test are not finished~~
- Complicated test cases. 
- Doc with more detail 


License
-------

Licensed under MIT. [Full license here &raquo;](LICENSE)

