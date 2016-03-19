# RWPromiseKit

## Desiciption
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


##Usage of RWPromise


License
-------

Licensed under MIT. [Full license here &raquo;](LICENSE.txt)

